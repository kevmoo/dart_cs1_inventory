// Rebalances answer-key positions across items so no letter dominates.
//
//   dart run tool/balance_keys.dart            # rewrite files
//   dart run tool/balance_keys.dart --dry-run  # report planned swaps only
//
// Incremental: while the most-used letter is more than [_maxSpread] ahead of
// the least-used one (or exceeds [_maxShare]), one item keyed on the most-used
// letter is moved to the least-used letter. Items are chosen by a stable hash
// of their id, so adding items moves at most a handful of existing keys
// instead of reshuffling the whole set. A swap moves the key option and the
// option at the target position in:
//   - the item YAML (option blocks move; `id:` lines and `answer:` rewritten)
//   - the item .dart (`optionX` <-> `optionY`, plus any letter-suffixed
//     helpers such as `squareB` / `CounterA`)
//   - the test group for the item (`.optionX` refs and `'x:` / `'key x:`
//     test descriptions)

import 'dart:io';
import 'dart:math';

import 'package:dart_cs1_inventory/dart_cs1_inventory.dart';
import 'package:path/path.dart' as p;

const _letters = ['a', 'b', 'c', 'd'];

/// Largest allowed gap between the most- and least-used key letter.
const _maxSpread = 2;

/// Mirrors the invariant in `test/inventory_test.dart`.
const _maxShare = 0.4;

void main(List<String> args) {
  final dryRun = args.contains('--dry-run');
  final inv = Inventory.load();
  final keys = {for (final item in inv.items) item.id: item.answer};
  final byId = {for (final item in inv.items) item.id: item};

  Map<String, int> counts() => {
    for (final l in _letters) l: keys.values.where((k) => k == l).length,
  };

  var swaps = 0;
  while (keys.length >= _letters.length) {
    final c = counts();
    final most = _letters.reduce((a, b) => c[a]! >= c[b]! ? a : b);
    final least = _letters.reduce((a, b) => c[a]! <= c[b]! ? a : b);
    final spread = c[most]! - c[least]!;
    if (spread <= _maxSpread && c[most]! / keys.length <= _maxShare) break;

    final candidates = keys.keys.where((id) => keys[id] == most).toList()
      ..sort((a, b) => _stableHash(a).compareTo(_stableHash(b)));
    final id = candidates.first;
    final item = byId[id]!;
    swaps++;
    stdout.writeln('$id: $most -> $least');
    keys[id] = least;
    if (dryRun) continue;
    _swapYaml(File(p.join(inv.root, item.yamlPath)), most, least);
    if (item.type == ItemType.completion) {
      final dart = File(
        p.join(inv.root, p.dirname(item.yamlPath), item.codeFile),
      );
      dart.writeAsStringSync(
        _swapSuffixes(dart.readAsStringSync(), most, least),
      );
      final testFile = File(
        p.join(inv.root, 'test', 'items', '${item.concept}_test.dart'),
      );
      testFile.writeAsStringSync(
        _swapInTestGroup(testFile.readAsStringSync(), item.id, most, least),
      );
    }
  }
  final c = counts();
  stdout.writeln(
    '${dryRun ? 'planned' : 'performed'} $swaps swaps; keys now '
    '${_letters.map((l) => '$l=${c[l]}').join(' ')}',
  );
}

/// FNV-1a over the id; deterministic across Dart versions and platforms.
int _stableHash(String s) {
  var h = 0x811c9dc5;
  for (final unit in s.codeUnits) {
    h = ((h ^ unit) * 0x01000193) & 0xffffffff;
  }
  return h;
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
