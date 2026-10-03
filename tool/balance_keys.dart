// Copyright 2026 Google LLC
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Rebalances answer-key positions across items so no letter dominates.
//
//   dart run tool/balance_keys.dart            # rewrite files
//   dart run tool/balance_keys.dart --dry-run  # report planned swaps only
//
// For each item (sorted by id) a target position is drawn from a seeded,
// balanced sequence of a/b/c/d. If the key is not already there, the key
// option and the option at the target position are swapped in:
//   - the item YAML (option blocks move; `id:` lines and `answer:` rewritten)
//   - the item .dart (`optionX` <-> `optionY`, plus any letter-suffixed
//     helpers such as `squareB` / `CounterA`)
//   - the test group for the item (`.optionX` refs and `'x:` / `'key x:`
//     test descriptions)
// Only a single swap per item is performed, to minimise churn.

import 'dart:io';
import 'dart:math';

import 'package:dart_cs1_inventory/dart_cs1_inventory.dart';
import 'package:path/path.dart' as p;

const _letters = ['a', 'b', 'c', 'd'];

void main(List<String> args) {
  final dryRun = args.contains('--dry-run');
  final inv = Inventory.load();
  final items = [...inv.items]..sort((a, b) => a.id.compareTo(b.id));

  final targets = <String>[
    for (var i = 0; i < items.length; i++) _letters[i % 4],
  ]..shuffle(Random(20261003));

  var swaps = 0;
  for (final (i, item) in items.indexed) {
    final from = item.answer;
    final to = targets[i];
    if (from == to) continue;
    swaps++;
    stdout.writeln('${item.id}: $from -> $to');
    if (dryRun) continue;
    _swapYaml(File(p.join(inv.root, item.yamlPath)), from, to);
    if (item.type == ItemType.completion) {
      final dart = File(
        p.join(inv.root, p.dirname(item.yamlPath), item.codeFile),
      );
      dart.writeAsStringSync(_swapSuffixes(dart.readAsStringSync(), from, to));
      final testFile = File(
        p.join(inv.root, 'test', 'items', '${item.concept}_test.dart'),
      );
      testFile.writeAsStringSync(
        _swapInTestGroup(testFile.readAsStringSync(), item.id, from, to),
      );
    }
  }
  stdout.writeln('${dryRun ? 'planned' : 'performed'} $swaps swaps');
}

/// Swaps the `- id: [from]` and `- id: [to]` option blocks and relabels them.
void _swapYaml(File file, String from, String to) {
  final lines = file.readAsStringSync().split('\n');
  final starts = <String, int>{};
  for (final (i, line) in lines.indexed) {
    final m = RegExp(r'^  - id: ([a-d])$').firstMatch(line);
    if (m != null) starts[m.group(1)!] = i;
  }
  final answerLine = lines.indexWhere((l) => l.startsWith('answer: '));
  int endOf(String id) {
    final start = starts[id]!;
    final later = starts.values.where((s) => s > start);
    return later.isEmpty ? answerLine : later.reduce(min);
  }

  final blocks = {
    for (final id in _letters) id: lines.sublist(starts[id]!, endOf(id)),
  };
  List<String> relabel(List<String> block, String id) => [
    '  - id: $id',
    ...block.skip(1),
  ];
  final swapped = {
    ...blocks,
    from: relabel(blocks[to]!, from),
    to: relabel(blocks[from]!, to),
  };
  final firstOption = starts.values.reduce(min);
  final out = [
    ...lines.take(firstOption),
    for (final id in _letters) ...swapped[id]!,
    'answer: $to',
    ...lines.skip(answerLine + 1),
  ];
  file.writeAsStringSync(out.join('\n'));
}

/// Swaps identifier suffixes `...X` <-> `...Y` (e.g. `optionA`, `squareB`).
String _swapSuffixes(String source, String from, String to) {
  final f = from.toUpperCase();
  final t = to.toUpperCase();
  final re = RegExp('\\b([A-Za-z_][A-Za-z_]*)([$f$t])\\b');
  return source.replaceAllMapped(re, (m) {
    final base = m.group(1)!;
    if (base.length < 2 || base == base.toUpperCase()) return m.group(0)!;
    return '$base${m.group(2) == f ? t : f}';
  });
}

/// Applies [_swapSuffixes] and description-letter swaps inside the
/// `group('<id>', ...)` block only.
String _swapInTestGroup(String source, String id, String from, String to) {
  final start = source.indexOf("group('$id'");
  if (start < 0) throw StateError('no test group for $id');
  final next = source.indexOf("\n  group('", start + 1);
  final end = next < 0 ? source.length : next;
  var block = source.substring(start, end);
  block = _swapSuffixes(block, from, to);
  final descRe = RegExp("test\\('(key )?([$from$to]):");
  block = block.replaceAllMapped(descRe, (m) {
    final letter = m.group(2) == from ? to : from;
    return "test('${m.group(1) ?? ''}$letter:";
  });
  return source.replaceRange(start, end, block);
}
