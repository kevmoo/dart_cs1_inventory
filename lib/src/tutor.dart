// The tutoring engine: an append-only answer log per student, a mastery rule
// over the prerequisite DAG, and deterministic item selection. Everything the
// agent must not be trusted with lives here; `bin/tutor.dart` is a thin shell.

import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:path/path.dart' as p;

import 'model.dart';

/// One recorded answer. Only the *first* answer to a presented item should be
/// logged; the CLI enforces that by logging inside `check` before it reveals
/// anything.
final class const Attempt({
  required final DateTime at,
  required final String item,
  required final String option,
  required final bool correct,

  /// Misconception id of the chosen distractor; `null` when [correct].
  required final String? misconception,
}) {
  factory Attempt.fromJson(Map<String, Object?> json) => Attempt(
    at: DateTime.parse(json['at'] as String),
    item: json['item'] as String,
    option: json['option'] as String,
    correct: json['correct'] as bool,
    misconception: json['misconception'] as String?,
  );

  Map<String, Object?> toJson() => {
    'at': at.toUtc().toIso8601String(),
    'item': item,
    'option': option,
    'correct': correct,
    'misconception': misconception,
  };
}

/// JSON-lines answer log for one student.
final class StudentLog {
  StudentLog(this.file);

  /// `<stateDir>/<student>/log.jsonl`.
  factory StudentLog.inDir(String stateDir, String student) =>
      StudentLog(File(p.join(stateDir, student, 'log.jsonl')));

  final File file;

  List<Attempt> read() {
    if (!file.existsSync()) return const [];
    return [
      for (final line in file.readAsLinesSync())
        if (line.trim().isNotEmpty)
          Attempt.fromJson(jsonDecode(line) as Map<String, Object?>),
    ];
  }

  void append(Attempt attempt) {
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(
      '${jsonEncode(attempt.toJson())}\n',
      mode: FileMode.append,
      flush: true,
    );
  }
}

enum NodeState {
  /// A prerequisite is not yet mastered.
  locked,

  /// Unlocked, evidence still needed.
  available,
  mastered,

  /// No non-definitional items exist for this node; it never blocks
  /// unlocking and is reported so the gap is visible.
  noItems,
}

final class const NodeStatus({
  required final DagNode node,
  required final NodeState state,
  required final int attempts,

  /// Distinct evidence items whose latest answer is correct.
  required final int correct,

  /// Distinct correct evidence items needed for mastery.
  required final int required,
});

final class const CheckResult({
  required final Item item,
  required final Option chosen,
  required final bool correct,
  required final Attempt attempt,
});

/// Pure logic over an [Inventory] and a list of prior [Attempt]s.
final class Tutor {
  Tutor(this.inventory, List<Attempt> attempts)
    : attempts = List.unmodifiable(attempts);

  final Inventory inventory;
  final List<Attempt> attempts;

  /// Distinct evidence items required per node (fewer if the node has fewer).
  static const requiredPerNode = 3;

  /// How many of the most recent answers on a node must all be correct.
  static const recentWindow = 3;

  late final Map<String, Item> _items = {
    for (final i in inventory.items) i.id: i,
  };

  /// DAG nodes in prerequisite order, stable with respect to `dag.yaml`.
  late final List<DagNode> order = _topologicalOrder(inventory.dag);

  bool hasItem(String id) => _items.containsKey(id);

  Item item(String id) {
    final found = _items[id];
    if (found == null) throw ArgumentError.value(id, 'id', 'unknown item');
    return found;
  }

  Iterable<Item> itemsOn(String nodeId) =>
      inventory.items.where((i) => i.dagNode == nodeId);

  /// Items that count as evidence: everything except definitional ones.
  Iterable<Item> evidenceOn(String nodeId) =>
      itemsOn(nodeId).where((i) => i.type != ItemType.definitional);

  Iterable<Attempt> attemptsOn(String itemId) =>
      attempts.where((a) => a.item == itemId);

  /// The most recent answer to [itemId], if any.
  Attempt? latest(String itemId) {
    Attempt? last;
    for (final a in attempts) {
      if (a.item == itemId) last = a;
    }
    return last;
  }

  NodeStatus statusOf(DagNode node) {
    final evidence = evidenceOn(node.id).toList();
    if (evidence.isEmpty) {
      return NodeStatus(
        node: node,
        state: NodeState.noItems,
        attempts: 0,
        correct: 0,
        required: 0,
      );
    }
    final ids = {for (final i in evidence) i.id};
    final onNode = attempts.where((a) => ids.contains(a.item)).toList();
    final correct = evidence.where((i) => latest(i.id)?.correct ?? false);
    final required = math.min(requiredPerNode, evidence.length);
    bool hasType(ItemType t) => evidence.any((i) => i.type == t);
    bool correctType(ItemType t) => correct.any((i) => i.type == t);
    final recent = onNode.skip(math.max(0, onNode.length - recentWindow));
    final mastered =
        correct.length >= required &&
        (!hasType(ItemType.tracing) || correctType(ItemType.tracing)) &&
        (!hasType(ItemType.completion) || correctType(ItemType.completion)) &&
        recent.every((a) => a.correct);
    final state = mastered
        ? NodeState.mastered
        : unlocked(node)
        ? NodeState.available
        : NodeState.locked;
    return NodeStatus(
      node: node,
      state: state,
      attempts: onNode.length,
      correct: correct.length,
      required: required,
    );
  }

  bool mastered(String nodeId) => switch (statusOf(_node(nodeId)).state) {
    NodeState.mastered || NodeState.noItems => true,
    NodeState.locked || NodeState.available => false,
  };

  bool unlocked(DagNode node) => node.prerequisites.every(mastered);

  /// The next item to present, or `null` when every node is mastered.
  ///
  /// Walks nodes in prerequisite order and picks, on the first unlocked and
  /// unmastered node, the item that is least settled: never attempted first,
  /// then latest-wrong, then fewest attempts, then `dag.yaml`/file order. The
  /// item answered most recently is avoided when there is an alternative.
  Item? next() {
    final lastAnswered = attempts.isEmpty ? null : attempts.last.item;
    for (final node in order) {
      if (statusOf(node).state != NodeState.available) continue;
      final candidates = itemsOn(node.id).toList();
      if (candidates.isEmpty) continue;
      int rank(Item i) {
        final last = latest(i.id);
        final settled = last == null
            ? 0
            : last.correct
            ? 2
            : 1;
        final avoid = candidates.length > 1 && i.id == lastAnswered ? 1 : 0;
        return settled * 10000 + avoid * 1000 + attemptsOn(i.id).length;
      }

      candidates.sort((a, b) => rank(a).compareTo(rank(b)));
      return candidates.first;
    }
    return null;
  }

  /// Grades [optionId] for [itemId] and builds the [Attempt] to log. Does not
  /// mutate [attempts]; the caller appends to the [StudentLog] and constructs
  /// a fresh [Tutor] if it needs updated status.
  CheckResult check(String itemId, String optionId, {DateTime? at}) {
    final it = item(itemId);
    final chosen = it.options.where((o) => o.id == optionId).firstOrNull;
    if (chosen == null) {
      throw ArgumentError.value(
        optionId,
        'option',
        'expected one of ${it.options.map((o) => o.id).join(', ')}',
      );
    }
    final correct = chosen.id == it.answer;
    return CheckResult(
      item: it,
      chosen: chosen,
      correct: correct,
      attempt: Attempt(
        at: at ?? DateTime.now(),
        item: it.id,
        option: chosen.id,
        correct: correct,
        misconception: correct ? null : chosen.misconception,
      ),
    );
  }

  /// Misconception id → number of times a distractor carrying it was chosen,
  /// most frequent first.
  List<MapEntry<String, int>> misconceptionCounts() {
    final counts = <String, int>{};
    for (final a in attempts) {
      final m = a.misconception;
      if (m != null) counts.update(m, (n) => n + 1, ifAbsent: () => 1);
    }
    return counts.entries.toList()..sort((a, b) {
      final byCount = b.value.compareTo(a.value);
      return byCount != 0 ? byCount : a.key.compareTo(b.key);
    });
  }

  DagNode _node(String id) => inventory.dag.firstWhere((n) => n.id == id);
}

List<DagNode> _topologicalOrder(List<DagNode> nodes) {
  final done = <String>{};
  final out = <DagNode>[];
  while (out.length < nodes.length) {
    final ready = nodes.firstWhere(
      (n) => !done.contains(n.id) && n.prerequisites.every(done.contains),
      orElse: () => throw StateError('dag.yaml has a cycle'),
    );
    done.add(ready.id);
    out.add(ready);
  }
  return out;
}
