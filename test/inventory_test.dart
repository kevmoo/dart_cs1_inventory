// Structural invariants over `data/` and `items/`. Keeps the inventory
// honest without anyone eyeballing YAML.

import 'dart:io';

import 'package:dart_cs1_inventory/dart_cs1_inventory.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  final inv = Inventory.load();
  final conceptIds = {for (final c in inv.concepts) c.id};
  final areaIds = {for (final a in inv.specAreas) a.id};

  test('ten FCS1 concepts, in FCS1 order', () {
    expect(inv.concepts.map((c) => c.id), [
      'fundamentals',
      'logical_operators',
      'selection',
      'loops_definite',
      'loops_indefinite',
      'arrays',
      'function_params',
      'function_return',
      'recursion',
      'oop',
    ]);
  });

  test('spec area ids are unique', () {
    expect(areaIds, hasLength(inv.specAreas.length));
  });

  test('item ids are unique and match file names', () {
    final ids = <String>{};
    for (final item in inv.items) {
      expect(ids.add(item.id), isTrue, reason: 'duplicate id ${item.id}');
      expect(p.basenameWithoutExtension(item.yamlPath), item.id);
      expect(
        p.basename(p.dirname(item.yamlPath)),
        item.concept,
        reason: '${item.id} lives in the wrong concept directory',
      );
      expect(
        item.id,
        startsWith('${item.concept}_'),
        reason: '${item.id} should be prefixed with its concept',
      );
    }
  });

  test('every (concept, type) cell has at least one item', () {
    final missing = <String>[];
    for (final c in inv.concepts) {
      for (final t in ItemType.values) {
        if (inv.itemsFor(c.id, t).isEmpty) missing.add('${c.id}/${t.name}');
      }
    }
    expect(missing, isEmpty);
  });

  group('items', () {
    for (final item in inv.items) {
      test(item.id, () {
        expect(conceptIds, contains(item.concept));
        expect(item.options, hasLength(4));
        expect(item.options.map((o) => o.id), ['a', 'b', 'c', 'd']);
        expect(item.options.map((o) => o.id), contains(item.answer));
        expect(item.key.compileError, isFalse);
        final texts = item.options.map((o) => o.text.trim()).toSet();
        expect(texts, hasLength(4), reason: 'duplicate option text');
        for (final o in item.options) {
          expect(o.rationale.trim(), isNotEmpty, reason: 'option ${o.id}');
        }
        expect(item.specAreas, isNotEmpty);
        for (final a in item.specAreas) {
          expect(areaIds, contains(a), reason: 'unknown spec area $a');
        }
        if (item.type == ItemType.definitional) {
          expect(item.codeFile, isNull);
        } else {
          final code = File(
            p.join(inv.root, p.dirname(item.yamlPath), item.codeFile),
          );
          expect(code.existsSync(), isTrue, reason: 'missing ${code.path}');
          final source = code.readAsStringSync();
          if (item.type == ItemType.tracing) {
            expect(source, contains('void main()'));
          } else {
            expect(source, contains('// KEY'));
            for (final o in item.options) {
              final fn = 'void option${o.id.toUpperCase()}()';
              expect(
                source.contains(fn),
                !o.compileError,
                reason: '$fn presence must match compile_error',
              );
            }
          }
          final testFile = File(
            p.join(inv.root, 'test', 'items', '${item.concept}_test.dart'),
          );
          expect(testFile.existsSync(), isTrue, reason: testFile.path);
          expect(
            testFile.readAsStringSync(),
            contains("group('${item.id}'"),
            reason: '${item.id} has no test group',
          );
        }
      });
    }
  });

  group('dag', () {
    final ids = {for (final n in inv.dag) n.id};

    test('node ids unique, prerequisites resolve', () {
      expect(ids, hasLength(inv.dag.length));
      for (final n in inv.dag) {
        for (final pre in n.prerequisites) {
          expect(ids, contains(pre), reason: '${n.id} -> $pre');
          expect(pre, isNot(n.id));
        }
        if (n.concept != null) expect(conceptIds, contains(n.concept));
      }
    });

    test('every concept has at least one node', () {
      final covered = {for (final n in inv.dag) ?n.concept};
      expect(covered, containsAll(conceptIds));
    });

    test('acyclic', () {
      final byId = {for (final n in inv.dag) n.id: n};
      final state = <String, int>{}; // 1 = visiting, 2 = done
      void visit(String id, List<String> path) {
        if (state[id] == 2) return;
        if (state[id] == 1) fail('cycle: ${[...path, id].join(' -> ')}');
        state[id] = 1;
        for (final pre in byId[id]!.prerequisites) {
          visit(pre, [...path, id]);
        }
        state[id] = 2;
      }

      for (final id in ids) {
        visit(id, []);
      }
    });
  });
}
