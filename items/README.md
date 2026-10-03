# Item format

One directory per concept. Every item has a YAML file; tracing and completion
items also have a Dart file next to it.

```
items/<concept>/<concept>_<def|trace|complete>_<n>.yaml
items/<concept>/<concept>_<trace|complete>_<n>.dart
```

## YAML schema

```yaml
id: loops_definite_trace_1          # == file basename
concept: loops_definite             # id from data/concepts.yaml
type: tracing                       # definitional | tracing | completion
dag_node: definite_loops            # node in data/dag.yaml this item is evidence for
prompt: |                           # what the student reads above the code
  What does this program print?
code_file: loops_definite_trace_1.dart   # omit for definitional
template: |                         # completion only: code with `____`
  ...
options:                            # exactly 4, ids a..d, one is the key
  - id: a
    text: "30"
    rationale: Why it is right / wrong (one sentence, names the misconception).
    compile_error: true             # optional; distractor can't be run
    diagnostic: non_bool_condition  # required with compile_error; checked by
                                    # test/compile_error_test.dart via dart analyze
answer: b
spec_areas: [statements.for, expressions.assignment]   # ids from data/spec_areas.yaml
dart_notes: >-                      # optional: pseudocode -> Dart hazards
  ...
```

## Dart file conventions

- **Tracing**: a plain program with `void main()` that only uses `print`.
  Exactly what the student sees. Tests import it and capture `print`.
- **Completion**: one `void optionA()` … `void optionD()` per option, each a
  complete program with that option substituted into the blank. The key is
  marked `// KEY`. Distractors that would not compile are omitted from the Dart
  file and flagged `compile_error: true` in YAML, with the analyzer diagnostic
  named in `rationale`.
- Student-shaped code: explicit types are fine, `var` is fine, no clever idioms
  unless the item is _about_ that idiom. Keep programs under ~15 lines.
- Every tracing/completion item id appears as a `group('<id>', ...)` in
  `test/items/<concept>_test.dart`; `test/inventory_test.dart` enforces this.
- Answer-key positions must stay balanced (no letter > 40%). Write the item with
  whatever order reads naturally, then run `dart run tool/balance_keys.dart` —
  it swaps YAML blocks, `optionX` functions and test references consistently.
