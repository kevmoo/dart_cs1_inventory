// Verifies that every `compile_error: true` option really fails to compile,
// with the diagnostic named in the YAML. Each option is substituted into the
// item's `template:` and all programs are analyzed in one `dart analyze` run.

import 'dart:io';

import 'package:dart_cs1_inventory/dart_cs1_inventory.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  final inv = Inventory.load();
  final cases = [
    for (final item in inv.items)
      for (final o in item.options)
        if (o.compileError) (item: item, option: o),
  ];

  late Directory dir;
  // file path -> set of lowercase diagnostic codes
  late Map<String, Set<String>> diagnostics;

  setUpAll(() {
    dir = Directory.systemTemp.createTempSync('cs1_compile_error_');
    for (final (:item, :option) in cases) {
      File(p.join(dir.path, '${item.id}_${option.id}.dart'))
          .writeAsStringSync(item.template!.replaceAll('____', option.text));
    }
    final result = Process.runSync('dart', [
      'analyze',
      '--format=machine',
      dir.path,
    ]);
    // Machine format: SEVERITY|TYPE|CODE|PATH|LINE|COL|LEN|MESSAGE
    diagnostics = {};
    for (final line in (result.stdout as String).split('\n')) {
      final parts = line.split('|');
      if (parts.length < 4) continue;
      diagnostics
          .putIfAbsent(p.basename(parts[3]), () => {})
          .add(parts[2].toLowerCase());
    }
  });

  tearDownAll(() => dir.deleteSync(recursive: true));

  for (final (:item, :option) in cases) {
    test('${item.id} option ${option.id} -> ${option.diagnostic}', () {
      final found = diagnostics['${item.id}_${option.id}.dart'] ?? const {};
      expect(found, contains(option.diagnostic));
    });
  }

  test('the key of every completion item compiles cleanly', () {
    final keysDir = Directory.systemTemp.createTempSync('cs1_keys_');
    addTearDown(() => keysDir.deleteSync(recursive: true));
    for (final item in inv.items.where((i) => i.type == ItemType.completion)) {
      File(p.join(keysDir.path, '${item.id}.dart'))
          .writeAsStringSync(item.template!.replaceAll('____', item.key.text));
    }
    final result = Process.runSync('dart', [
      'analyze',
      '--format=machine',
      keysDir.path,
    ]);
    final errors = (result.stdout as String)
        .split('\n')
        .where((l) => l.startsWith('ERROR|'))
        .toList();
    expect(errors, isEmpty);
  });
}
