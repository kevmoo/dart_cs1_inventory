// Copyright 2026 Google LLC
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Data model for the inventory. Loaded from `data/*.yaml` and
// `items/**/*.yaml`. Everything here is a plain value type so that
// `tool/report.dart` and the tests can share one deterministic view of the
// data.

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// The three FCS1 question formats.
enum ItemType() {
  definitional,
  tracing,
  completion;

  static ItemType parse(String value) =>
      values.firstWhere((e) => e.name == value);
}

/// One of the ten FCS1 concepts (see `data/concepts.yaml`).
final class const Concept({
  required final String id,
  required final String title,

  /// The name used by Tew & Guzdial (2011) for this concept.
  required final String fcs1Name,
  required final String description,

  /// Drill-style practice that would help this concept (free text bullets).
  required final List<String> drills,
});

/// A region of the Dart language spec (or an accepted feature spec).
final class const SpecArea({
  required final String id,
  required final String title,

  /// Section path in `dartLangSpec.tex` or a path under
  /// `dart-lang/language/accepted/`.
  required final String reference,

  /// Display grouping for the gap report (e.g. `Null safety`).
  required final String group,

  /// Whether the FCS1 concept list *claims* to cover this area. Items may
  /// still touch areas outside CS1 scope (e.g. string interpolation) and that
  /// is reported separately.
  required final bool cs1Scope,
  required final String note,
});

final class const Option({
  required final String id,
  required final String text,

  /// Why this option is right (for the key) or wrong (for a distractor).
  required final String rationale,

  /// Distractor that does not compile; cannot be exercised at runtime.
  required final bool compileError,

  /// Analyzer diagnostic code expected for a [compileError] option
  /// (verified by `test/compile_error_test.dart`).
  required final String? diagnostic,
});

final class const Item({
  required final String id,
  required final String concept,
  required final ItemType type,
  required final String prompt,

  /// Completion only: the program with `____` where an option goes.
  required final String? template,

  /// Node in `data/dag.yaml` this item provides evidence for.
  required final String dagNode,

  /// Relative (to the item's directory) path to the Dart program under test;
  /// `null` for definitional items.
  required final String? codeFile,
  required final List<Option> options,
  required final String answer,
  required final List<String> specAreas,

  /// Pseudocode → Dart translation notes specific to this item.
  required final String? dartNotes,
  required final String yamlPath,
}) {
  Option get key => options.firstWhere((o) => o.id == answer);
  Iterable<Option> get distractors => options.where((o) => o.id != answer);
}

final class const DagNode({
  required final String id,
  required final String title,

  /// FCS1 concept this node belongs to, or `null` for scaffolding nodes that
  /// FCS1 doesn't probe directly (e.g. `strings`).
  required final String? concept,
  required final List<String> prerequisites,
  required final String rationale,
});

/// A pseudocode → Dart translation hazard (see
/// `data/translation_issues.yaml`).
final class const TranslationIssue({
  required final String id,
  required final String title,
  required final List<String> concepts,
  required final String problem,
  required final String decision,
});

/// Everything loaded from disk.
final class const Inventory({
  required final String root,
  required final List<Concept> concepts,
  required final List<SpecArea> specAreas,
  required final List<Item> items,
  required final List<DagNode> dag,
  required final List<TranslationIssue> translationIssues,
}) {
  /// Loads from [root] (defaults to the current directory).
  factory Inventory.load([String? root]) {
    root ??= Directory.current.path;
    final concepts = _loadList(
      p.join(root, 'data', 'concepts.yaml'),
      'concepts',
      (m) => Concept(
        id: m['id'] as String,
        title: m['title'] as String,
        fcs1Name: m['fcs1_name'] as String,
        description: m['description'] as String,
        drills: _strings(m['drills']),
      ),
    );
    final specAreas = _loadList(
      p.join(root, 'data', 'spec_areas.yaml'),
      'areas',
      (m) => SpecArea(
        id: m['id'] as String,
        title: m['title'] as String,
        reference: m['reference'] as String,
        group: m['group'] as String,
        cs1Scope: m['cs1_scope'] as bool,
        note: (m['note'] as String?) ?? '',
      ),
    );
    final dag = _loadList(
      p.join(root, 'data', 'dag.yaml'),
      'nodes',
      (m) => DagNode(
        id: m['id'] as String,
        title: m['title'] as String,
        concept: m['concept'] as String?,
        prerequisites: _strings(m['prerequisites']),
        rationale: (m['rationale'] as String?) ?? '',
      ),
    );
    final issues = _loadList(
      p.join(root, 'data', 'translation_issues.yaml'),
      'issues',
      (m) => TranslationIssue(
        id: m['id'] as String,
        title: m['title'] as String,
        concepts: _strings(m['concepts']),
        problem: m['problem'] as String,
        decision: m['decision'] as String,
      ),
    );
    final itemFiles =
        Directory(p.join(root, 'items'))
            .listSync(recursive: true)
            .whereType<File>()
            .where(
              (f) =>
                  f.path.endsWith('.yaml') &&
                  p.basename(f.path) != 'analysis_options.yaml',
            )
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));
    final items = [for (final f in itemFiles) _loadItem(f, root)];
    return Inventory(
      root: root,
      concepts: concepts,
      specAreas: specAreas,
      items: items,
      dag: dag,
      translationIssues: issues,
    );
  }

  Concept concept(String id) => concepts.firstWhere((c) => c.id == id);
  SpecArea specArea(String id) => specAreas.firstWhere((a) => a.id == id);
  Iterable<Item> itemsFor(String concept, [ItemType? type]) => items.where(
    (i) => i.concept == concept && (type == null || i.type == type),
  );
}

Item _loadItem(File file, String root) {
  final m = loadYaml(file.readAsStringSync(), sourceUrl: file.uri) as YamlMap;
  final options = [
    for (final o in m['options'] as YamlList)
      Option(
        id: (o as YamlMap)['id'] as String,
        text: o['text'].toString(),
        rationale: o['rationale'] as String,
        compileError: (o['compile_error'] as bool?) ?? false,
        diagnostic: o['diagnostic'] as String?,
      ),
  ];
  return Item(
    id: m['id'] as String,
    concept: m['concept'] as String,
    type: ItemType.parse(m['type'] as String),
    prompt: m['prompt'] as String,
    template: m['template'] as String?,
    dagNode: m['dag_node'] as String,
    codeFile: m['code_file'] as String?,
    options: options,
    answer: m['answer'] as String,
    specAreas: _strings(m['spec_areas']),
    dartNotes: m['dart_notes'] as String?,
    yamlPath: p.relative(file.path, from: root),
  );
}

List<T> _loadList<T>(String path, String key, T Function(YamlMap) parse) {
  final doc = loadYaml(
    File(path).readAsStringSync(),
    sourceUrl: Uri.file(path),
  );
  return [
    for (final e in (doc as YamlMap)[key] as YamlList) parse(e as YamlMap),
  ];
}

List<String> _strings(Object? value) => switch (value) {
  null => const [],
  YamlList list => [for (final e in list) e as String],
  _ => throw ArgumentError.value(value, 'value', 'expected a list of strings'),
};
