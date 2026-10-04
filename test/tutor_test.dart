// Unit tests for the tutoring engine against the real inventory and a
// temporary state directory. No agent, no stdin.

import 'dart:convert';
import 'dart:io';

import 'package:dart_cs1_inventory/dart_cs1_inventory.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  final inv = Inventory.load();
  final t0 = DateTime.utc(2026);

  Attempt answer(Tutor t, String item, String option) =>
      t.check(item, option, at: t0).attempt;

  /// Answers [item] correctly.
  Attempt right(Tutor t, String item) => answer(t, item, t.item(item).answer);

  /// Answers [item] with its first distractor.
  Attempt wrong(Tutor t, String item) =>
      answer(t, item, t.item(item).distractors.first.id);

  group('order', () {
    test('is a topological order over dag.yaml, roots first', () {
      final t = Tutor(inv, const []);
      final seen = <String>{};
      for (final n in t.order) {
        expect(n.prerequisites, everyElement(isIn(seen)), reason: n.id);
        seen.add(n.id);
      }
      expect(t.order.first.prerequisites, isEmpty);
      expect(t.order.map((n) => n.id), containsAll(inv.dag.map((n) => n.id)));
      expect(t.order.take(7).map((n) => n.id), [
        'variables_assignment',
        'output_and_strings',
        'sequencing',
        'boolean_expressions',
        'logical_operators',
        'selection',
        'arithmetic_expressions',
      ]);
    });
  });

  group('status', () {
    test('fresh student: roots available, dependents locked', () {
      final t = Tutor(inv, const []);
      final states = {for (final n in t.order) n.id: t.statusOf(n).state};
      // No evidence anywhere, so only nodes whose prerequisites are all
      // noItems/empty can be available.
      for (final n in t.order) {
        final prereqsClear = n.prerequisites.every(
          (q) => states[q] == NodeState.noItems,
        );
        final expected = t.evidenceOn(n.id).isEmpty
            ? NodeState.noItems
            : prereqsClear
            ? NodeState.available
            : NodeState.locked;
        expect(states[n.id], expected, reason: n.id);
      }
      expect(states.values, contains(NodeState.available));
    });

    test('required is min(3, evidence items on the node)', () {
      final t = Tutor(inv, const []);
      for (final n in t.order) {
        final evidence = t.evidenceOn(n.id).length;
        expect(
          t.statusOf(n).required,
          evidence == 0 ? 0 : evidence.clamp(1, 3),
        );
      }
    });
  });

  group('mastery', () {
    // A node with >= 3 evidence items including both tracing and completion.
    final node = inv.dag.firstWhere((n) {
      final e = Tutor(inv, const []).evidenceOn(n.id);
      return e.length >= 3 &&
          e.any((i) => i.type == ItemType.tracing) &&
          e.any((i) => i.type == ItemType.completion);
    });
    final evidence = Tutor(inv, const []).evidenceOn(node.id).toList();
    final tracing = evidence.where((i) => i.type == ItemType.tracing).toList();
    final completion = evidence.firstWhere(
      (i) => i.type == ItemType.completion,
    );

    test('three correct distinct items with both types masters the node', () {
      var t = Tutor(inv, const []);
      final log = <Attempt>[];
      for (final item in [tracing[0], tracing[1], completion]) {
        log.add(right(t, item.id));
        t = Tutor(inv, log);
      }
      expect(t.statusOf(node).state, NodeState.mastered);
      expect(t.statusOf(node).correct, 3);
    });

    test('repeating one item three times does not count as three', () {
      final t0_ = Tutor(inv, const []);
      final log = [for (var i = 0; i < 3; i++) right(t0_, tracing[0].id)];
      final t = Tutor(inv, log);
      expect(t.statusOf(node).correct, 1);
      expect(t.statusOf(node).state, isNot(NodeState.mastered));
    });

    test('tracing-only correct answers never master a mixed node', () {
      final t0_ = Tutor(inv, const []);
      final log = [for (final i in tracing) right(t0_, i.id)];
      final t = Tutor(inv, log);
      expect(t.statusOf(node).state, isNot(NodeState.mastered));
      expect(t.statusOf(node).correct, lessThan(t.statusOf(node).required));
    });

    test('a wrong answer inside the recent window blocks mastery', () {
      final t0_ = Tutor(inv, const []);
      final log = [
        right(t0_, tracing[0].id),
        right(t0_, tracing[1].id),
        right(t0_, completion.id),
        wrong(t0_, tracing[0].id),
      ];
      final t = Tutor(inv, log);
      expect(t.statusOf(node).state, isNot(NodeState.mastered));
      // Latest answer to tracing[0] is wrong, so it no longer counts.
      expect(t.statusOf(node).correct, 2);
    });

    test('immediate warm retry after a miss does not credit until another item '
        'intervenes', () {
      final t0_ = Tutor(inv, const []);
      final log = [
        right(t0_, tracing[0].id),
        right(t0_, tracing[1].id),
        wrong(t0_, completion.id),
        right(t0_, completion.id),
        right(t0_, completion.id),
      ];
      var t = Tutor(inv, log);
      expect(t.isCredited(completion.id, hasAlternatives: true), isFalse);
      expect(t.statusOf(node).correct, 2);
      expect(t.statusOf(node).state, NodeState.available);

      // Intervening attempt on another item, then cold correct on completion.
      log
        ..add(right(t0_, tracing[0].id))
        ..add(right(t0_, completion.id));
      t = Tutor(inv, log);
      expect(t.isCredited(completion.id, hasAlternatives: true), isTrue);
      expect(t.statusOf(node).correct, 3);
      expect(t.statusOf(node).state, NodeState.mastered);
    });

    test('definitional items are not evidence', () {
      final def = inv.items.firstWhere((i) => i.type == ItemType.definitional);
      final t0_ = Tutor(inv, const []);
      final t = Tutor(inv, [right(t0_, def.id)]);
      final n = inv.dag.firstWhere((n) => n.id == def.dagNode);
      expect(t.statusOf(n).correct, 0);
    });
  });

  group('next', () {
    test('is deterministic and starts with a tracing item on root node', () {
      final t = Tutor(inv, const []);
      final a = t.next()!;
      expect(Tutor(inv, const []).next()!.id, a.id);
      expect(a.dagNode, 'variables_assignment');
      expect(a.type, ItemType.tracing);
      final node = inv.dag.firstWhere((n) => n.id == a.dagNode);
      expect(t.statusOf(node).state, NodeState.available);
    });

    test('never repeats the item just answered when alternatives exist', () {
      var t = Tutor(inv, const []);
      final log = <Attempt>[];
      for (var i = 0; i < 20; i++) {
        final item = t.next();
        if (item == null) break;
        log.add(wrong(t, item.id));
        t = Tutor(inv, log);
        final after = t.next();
        if (after == null) break;
        final siblings = t.evidenceOn(item.dagNode).length;
        if (siblings > 1 && after.dagNode == item.dagNode) {
          expect(after.id, isNot(item.id), reason: 'round $i');
        }
      }
    });

    test(
      'never repeats a just-missed item even when all siblings are credited',
      () {
        final t0_ = Tutor(inv, const []);
        final first = t0_.next()!;
        final siblings = t0_.evidenceOn(first.dagNode).toList();
        expect(siblings.length, greaterThan(1));
        final log = [
          for (final s in siblings.skip(1)) right(t0_, s.id),
          wrong(t0_, first.id),
        ];
        final t = Tutor(inv, log);
        final nextItem = t.next()!;
        expect(nextItem.dagNode, first.dagNode);
        expect(nextItem.id, isNot(first.id));
      },
    );

    test('prefers unattempted items, then latest-wrong, then fewest tries', () {
      var t = Tutor(inv, const []);
      final first = t.next()!;
      final node = first.dagNode;
      final onNode = t.evidenceOn(node).toList();
      if (onNode.length < 2) return; // nothing to discriminate
      t = Tutor(inv, [right(t, first.id)]);
      final second = t.next()!;
      expect(second.dagNode, node);
      expect(second.id, isNot(first.id));
      expect(t.latest(second.id), isNull);
    });

    test(
      'returns null once every node is mastered in exact required steps',
      () {
        var t = Tutor(inv, const []);
        final log = <Attempt>[];
        final expectedSteps = t.order
            .map((n) => t.statusOf(n).required)
            .fold<int>(0, (a, b) => a + b);
        // Answer everything correctly until next() runs dry; bounded.
        for (var i = 0; i < 500; i++) {
          final item = t.next();
          if (item == null) break;
          expect(item.type, isNot(ItemType.definitional));
          log.add(right(t, item.id));
          t = Tutor(inv, log);
        }
        expect(t.next(), isNull);
        expect(log, hasLength(expectedSteps));
        for (final n in t.order) {
          expect(
            t.statusOf(n).state,
            anyOf(NodeState.mastered, NodeState.noItems),
            reason: n.id,
          );
        }
      },
    );
  });

  group('check', () {
    test('records misconception for a distractor, null for the key', () {
      final t = Tutor(inv, const []);
      final item = inv.items.firstWhere((i) => i.type == ItemType.tracing);
      final d = item.distractors.first;
      final r = t.check(item.id, d.id, at: t0);
      expect(r.correct, isFalse);
      expect(r.attempt.misconception, d.misconception);
      final k = t.check(item.id, item.answer, at: t0);
      expect(k.correct, isTrue);
      expect(k.attempt.misconception, isNull);
    });

    test('consecutiveMissesOn counts trailing misses and resets on hit', () {
      final t0_ = Tutor(inv, const []);
      final items = inv.items
          .where((i) => i.type == ItemType.tracing)
          .take(2)
          .toList();
      final a = items[0].id;
      final b = items[1].id;
      expect(t0_.consecutiveMissesOn(a), 0);
      final t1 = Tutor(inv, [wrong(t0_, a)]);
      expect(t1.consecutiveMissesOn(a), 1);
      final t2 = Tutor(inv, [wrong(t0_, a), right(t0_, b), wrong(t0_, a)]);
      expect(t2.consecutiveMissesOn(a), 2);
      final t3 = Tutor(inv, [
        wrong(t0_, a),
        right(t0_, b),
        wrong(t0_, a),
        right(t0_, a),
      ]);
      expect(t3.consecutiveMissesOn(a), 0);
    });

    test('rejects unknown item and option', () {
      final t = Tutor(inv, const []);
      expect(() => t.check('nope', 'a'), throwsArgumentError);
      expect(() => t.check(inv.items.first.id, 'z'), throwsArgumentError);
    });

    test('misconceptionCounts sorts by count then id', () {
      final t = Tutor(inv, const []);
      final item = inv.items.firstWhere((i) => i.type == ItemType.tracing);
      final d = item.distractors.toList();
      final log = [
        wrong(t, item.id),
        wrong(t, item.id),
        answer(t, item.id, d[1].id),
      ];
      final counts = Tutor(inv, log).misconceptionCounts();
      expect(counts.first.key, d[0].misconception);
      expect(counts.first.value, 2);
    });
  });

  group('StudentLog and CLI check', () {
    late Directory tmp;
    setUp(() => tmp = Directory.systemTemp.createTempSync('cs1_'));
    tearDown(() => tmp.deleteSync(recursive: true));

    test('round-trips attempts as JSON lines', () {
      final log = StudentLog.inDir(tmp.path, 'kid');
      expect(log.read(), isEmpty);
      final t = Tutor(inv, const []);
      final a = wrong(t, inv.items.first.id);
      log
        ..append(a)
        ..append(right(t, inv.items.first.id));
      expect(log.file.path, p.join(tmp.path, 'kid', 'log.jsonl'));
      final back = log.read();
      expect(back, hasLength(2));
      expect(back.first.toJson(), a.toJson());
      expect(back.last.correct, isTrue);
    });

    test(
      'CLI check withholds key on 1st miss and reveals on 2nd miss or --reveal',
      () {
        final item = inv.items.firstWhere((i) => i.type == ItemType.tracing);
        final wrongOpt = item.distractors.first.id;

        Map<String, Object?> runCheck(List<String> extra) {
          final res = Process.runSync(Platform.executable, [
            'bin/tutor.dart',
            '--state-dir=${tmp.path}',
            'check',
            ...extra,
            item.id,
            wrongOpt,
          ], workingDirectory: inv.root);
          expect(res.exitCode, 0, reason: '${res.stderr}');
          return jsonDecode(res.stdout as String) as Map<String, Object?>;
        }

        final miss1 = runCheck(const []);
        expect(miss1['correct'], isFalse);
        expect(miss1['consecutive_misses'], 1);
        expect(miss1.containsKey('answer'), isFalse);
        expect(miss1.containsKey('key'), isFalse);

        final miss2 = runCheck(const []);
        expect(miss2['correct'], isFalse);
        expect(miss2['consecutive_misses'], 2);
        expect(miss2['answer'], item.answer);
        expect(miss2['key'], isNotNull);

        // Fresh student with --reveal on 1st miss.
        final revealed = Process.runSync(Platform.executable, [
          'bin/tutor.dart',
          '--state-dir=${tmp.path}',
          '--student=other',
          'check',
          '--reveal',
          item.id,
          wrongOpt,
        ], workingDirectory: inv.root);
        expect(revealed.exitCode, 0, reason: '${revealed.stderr}');
        final revJson =
            jsonDecode(revealed.stdout as String) as Map<String, Object?>;
        expect(revJson['consecutive_misses'], 1);
        expect(revJson['answer'], item.answer);
        expect(revJson['key'], isNotNull);
      },
    );
  });

  group('locations', () {
    test('packageRoot points at this package', () async {
      final root = await packageRoot();
      expect(File(p.join(root, 'pubspec.yaml')).existsSync(), isTrue);
      expect(Directory(p.join(root, 'items')).existsSync(), isTrue);
    });

    test('state dir precedence: flag, env, platform default', () {
      final env = {'HOME': '/h', 'XDG_STATE_HOME': '/xdg', stateDirEnv: '/e'};
      expect(
        resolveStateDir(override: '/f', environment: env),
        p.absolute('/f'),
      );
      expect(resolveStateDir(environment: env), p.absolute('/e'));
      final noEnv = {'HOME': '/h', 'XDG_STATE_HOME': '/xdg'};
      final dflt = resolveStateDir(environment: noEnv);
      expect(dflt, isNot(contains('/.dart_cs1')));
      expect(p.basename(dflt), 'dart_cs1_inventory');
    });
  });
}
