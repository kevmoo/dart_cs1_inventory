Private, original Dart concept inventory shaped like FCS1/SCS1: ten CS1
concepts × three question types (definitional, tracing, code completion),
every runnable item backed by tests, a computed map onto the Dart language
spec, and a proposed prerequisite DAG for teaching programming through Dart.

> **Do not publish.** FCS1 (Tew & Guzdial, 2011) and SCS1 (Parker, Guzdial
> & Engleman, 2016) are secure instruments. No item text from either was
> obtained or used; everything here is original. Keep this repo private so
> the items stay useful as an assessment.

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
