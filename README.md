An open, original concept inventory for learning to program *through* Dart:
ten CS1 concepts × three question types (definitional, tracing, code
completion), every runnable item backed by tests, a computed map onto the
Dart language spec, and a proposed prerequisite graph for sequencing
instruction.

## Provenance (clean-room statement)

The ten-concept × three-question-type structure follows the published
design of FCS1 (Tew & Guzdial, SIGCSE 2011) and SCS1 (Parker, Guzdial &
Engleman, ICER 2016). Those are secure research instruments distributed under
terms of use. **No item text, options, or ordering from FCS1 or SCS1 was
obtained, viewed, or used** in creating this repository; only the concept
list and question-type scheme described in the papers were consulted. Every
item here is original.

Contributors must keep it that way: do not contribute material derived from
FCS1, SCS1, or any other access-restricted assessment.

## What this is (and is not)

- **Is:** a formative, openly inspectable item bank for teaching, self-check,
  drills, and curriculum sequencing, with tests that pin every item's
  behaviour to the current Dart SDK.
- **Is not:** a validated psychometric instrument. Public items cannot be a
  secure summative measure, and no validity study has been done. Do not cite
  scores from it as comparable to FCS1/SCS1 results.

## Layout

| Path | What |
| --- | --- |
| `items/<concept>/` | One YAML per item; tracing/completion items have a sibling `.dart` program. Schema in [items/README.md](items/README.md). |
| `test/items/` | One test file per concept: asserts the key output and what each distractor actually prints. |
| `test/inventory_test.dart` | Structural invariants: every concept × type cell populated, 4 distinct options, valid spec refs, code files exist, DAG acyclic. |
| `data/concepts.yaml` | The ten FCS1 concepts with drill-practice flags. |
| `data/spec_areas.yaml` | Dart spec areas (stable section titles / feature-spec paths), CS1-scope flag, gap grouping. |
| `data/translation_issues.yaml` | Pseudocode → Dart hazards and the decision taken for each. |
| `data/dag.yaml` | Prerequisite graph nodes and edges with rationale. |
| `tool/report.dart` | Generates `coverage.md` and `dag.md` deterministically. |
| `tool/balance_keys.dart` | Rebalances answer-key positions across YAML, Dart and tests (seeded). |
| `test/compile_error_test.dart` | Substitutes every `compile_error` option into its template and asserts `dart analyze` reports the named diagnostic. |
| `coverage.md` | Generated: item matrix, spec areas exercised, gap list, translation issues, drill candidates. |
| `dag.md` | Generated: Mermaid graph, levels, node table, open questions. |

## Commands

```sh
dart test                          # item tests + invariants
dart run tool/report.dart          # regenerate coverage.md and dag.md
dart run tool/report.dart --check  # fail if the generated files are stale
dart run tool/balance_keys.dart    # spread answer keys across a/b/c/d
```

## Authoring an item

1. Copy a sibling item in `items/<concept>/`, keep the `<concept>_<type>_<n>`
   naming.
2. Tracing: the `.dart` is the exact program shown; the key is its output.
   Completion: `optionA()`..`optionD()` are the program with each option
   substituted; mark the key `// KEY`; every runnable distractor must print
   something different.
3. Tag `spec_areas` with ids from `data/spec_areas.yaml`; add a new area there
   rather than inventing an id.
4. Add a `group('<item_id>', ...)` to `test/items/<concept>_test.dart`.
5. `dart test && dart run tool/report.dart`.
