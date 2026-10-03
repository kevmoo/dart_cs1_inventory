// The student-facing tutor CLI. Thin shell over `lib/src/tutor.dart`: all
// selection, grading and logging rules live there and are unit-tested.
//
//   dart run dart_cs1_inventory:tutor next            # JSON: item to present
//   dart run dart_cs1_inventory:tutor check <item> <a|b|c|d>
//   dart run dart_cs1_inventory:tutor status
//   dart run dart_cs1_inventory:tutor interactive     # kitchen-table mode
//
// `next` never prints the key or any rationale. `check` logs the answer
// *before* revealing anything, so the first answer is the one that counts.

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dart_cs1_inventory/dart_cs1_inventory.dart';
import 'package:path/path.dart' as p;

Future<void> main(List<String> args) async {
  final runner =
      CommandRunner<void>(
          'tutor',
          'Serves dart_cs1_inventory items one at a time, grades answers, and '
              'tracks mastery over the prerequisite DAG.',
        )
        ..argParser.addOption(
          'student',
          abbr: 's',
          defaultsTo: 'default',
          help: 'Student name; one answer log per student.',
        )
        ..argParser.addOption(
          'state-dir',
          help:
              'Where answer logs live. Default: \$$stateDirEnv, else the '
              'platform state directory (XDG on Linux).',
        )
        ..addCommand(_NextCommand())
        ..addCommand(_CheckCommand())
        ..addCommand(_StatusCommand())
        ..addCommand(_InteractiveCommand());
  try {
    await runner.run(args);
  } on UsageException catch (e) {
    stderr.writeln(e);
    exitCode = 64;
  }
}

/// Shared context for one invocation.
final class _Session {
  _Session._(this.inventory, this.stateDir, this.student)
    : log = StudentLog.inDir(stateDir, student);

  static Future<_Session> open(ArgResults global) async {
    final root = await packageRoot();
    return _Session._(
      Inventory.load(root),
      resolveStateDir(override: global['state-dir'] as String?),
      global['student'] as String,
    );
  }

  final Inventory inventory;
  final String stateDir;
  final String student;
  final StudentLog log;

  Tutor tutor() => Tutor(inventory, log.read());

  /// Student-facing view of an item: no key, no rationales.
  Map<String, Object?> present(Item item) => {
    'id': item.id,
    'concept': item.concept,
    'type': item.type.name,
    'node': item.dagNode,
    'prompt': item.prompt.trim(),
    'code': switch (item.type) {
      ItemType.definitional => null,
      ItemType.completion => item.template!.trimRight(),
      ItemType.tracing => File(
        p.join(inventory.root, p.dirname(item.yamlPath), item.codeFile!),
      ).readAsStringSync().trimRight(),
    },
    'options': [
      for (final o in item.options) {'id': o.id, 'text': o.text},
    ],
  };

  Map<String, Object?> reveal(CheckResult r, Tutor after) {
    final m = r.chosen.misconception;
    final node = after.statusOf(
      inventory.dag.firstWhere((n) => n.id == r.item.dagNode),
    );
    return {
      'item': r.item.id,
      'option': r.chosen.id,
      'correct': r.correct,
      'answer': r.item.answer,
      'chosen': {
        'text': r.chosen.text,
        'rationale': r.chosen.rationale.trim(),
        if (m != null)
          'misconception': {
            'id': m,
            'title': inventory.misconceptions
                .firstWhere((x) => x.id == m)
                .title,
          },
      },
      'key': {
        'text': r.item.key.text,
        'rationale': r.item.key.rationale.trim(),
      },
      if (r.item.dartNotes case final notes?) 'dart_notes': notes.trim(),
      'node': {
        'id': node.node.id,
        'state': node.state.name,
        'correct': node.correct,
        'required': node.required,
      },
    };
  }

  Map<String, Object?> status(Tutor t) {
    final nodes = [for (final n in t.order) t.statusOf(n)];
    return {
      'student': student,
      'state_dir': stateDir,
      'log': log.file.path,
      'attempts': t.attempts.length,
      'mastered': nodes.where((s) => s.state == NodeState.mastered).length,
      'of': nodes.where((s) => s.state != NodeState.noItems).length,
      'nodes': [
        for (final s in nodes)
          {
            'id': s.node.id,
            'title': s.node.title,
            'state': s.state.name,
            'attempts': s.attempts,
            'correct': s.correct,
            'required': s.required,
          },
      ],
      'misconceptions': [
        for (final e in t.misconceptionCounts())
          {
            'id': e.key,
            'title': inventory.misconceptions
                .firstWhere((x) => x.id == e.key)
                .title,
            'count': e.value,
          },
      ],
    };
  }
}

void _emit(Object? json) =>
    stdout.writeln(const JsonEncoder.withIndent('  ').convert(json));

abstract class _SessionCommand extends Command<void> {
  @override
  Future<void> run() async => runWith(await _Session.open(globalResults!));

  Future<void> runWith(_Session s);
}

final class _NextCommand extends _SessionCommand {
  @override
  String get name => 'next';
  @override
  String get description =>
      'Print the next item to present (JSON). Never includes the key.';

  @override
  Future<void> runWith(_Session s) async {
    final t = s.tutor();
    final item = t.next();
    if (item == null) {
      _emit({'done': true, 'message': 'Every node with items is mastered.'});
      return;
    }
    _emit({'done': false, 'item': s.present(item)});
  }
}

final class _CheckCommand extends _SessionCommand {
  @override
  String get name => 'check';
  @override
  String get description =>
      'Grade an answer: `check <item-id> <a|b|c|d>`. Logs first, then '
      'reveals the key and rationales.';
  @override
  String get invocation => 'tutor check <item-id> <option>';

  @override
  Future<void> runWith(_Session s) async {
    final rest = argResults!.rest;
    if (rest.length != 2) usageException('Expected <item-id> <option>.');
    final before = s.tutor();
    if (!before.hasItem(rest[0])) usageException('Unknown item ${rest[0]}.');
    final option = rest[1].toLowerCase();
    if (!before.item(rest[0]).options.any((o) => o.id == option)) {
      usageException('Option must be one of a, b, c, d.');
    }
    final result = before.check(rest[0], option);
    s.log.append(result.attempt);
    _emit(s.reveal(result, s.tutor()));
  }
}

final class _StatusCommand extends _SessionCommand {
  @override
  String get name => 'status';
  @override
  String get description =>
      'Mastery per DAG node, misconception counts, and where the log lives.';

  @override
  Future<void> runWith(_Session s) async => _emit(s.status(s.tutor()));
}

final class _InteractiveCommand extends _SessionCommand {
  @override
  String get name => 'interactive';
  @override
  String get description =>
      'Answer items at the terminal without an agent. `q` to quit.';

  @override
  Future<void> runWith(_Session s) async {
    while (true) {
      final item = s.tutor().next();
      if (item == null) {
        stdout.writeln('Every node with items is mastered. 🎉');
        return;
      }
      final view = s.present(item);
      stdout
        ..writeln()
        ..writeln('── ${item.id} ──')
        ..writeln(view['prompt']);
      if (view['code'] case final String code) {
        stdout
          ..writeln()
          ..writeln(code)
          ..writeln();
      }
      for (final o in item.options) {
        stdout.writeln('  ${o.id}) ${o.text.replaceAll('\n', r'\n')}');
      }
      final answer = _ask('Your answer (a-d, q to quit): ');
      if (answer == null || answer == 'q') return;
      if (!item.options.any((o) => o.id == answer)) {
        stdout.writeln('Please answer a, b, c or d.');
        continue;
      }
      final result = s.tutor().check(item.id, answer);
      s.log.append(result.attempt);
      stdout
        ..writeln(result.correct ? '✅ Correct.' : '❌ Not quite.')
        ..writeln(result.chosen.rationale.trim());
      if (!result.correct) {
        stdout.writeln('Key: ${item.answer}) ${item.key.rationale.trim()}');
      }
    }
  }

  String? _ask(String prompt) {
    stdout.write(prompt);
    return stdin.readLineSync()?.trim().toLowerCase();
  }
}
