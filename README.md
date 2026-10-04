An open, original concept inventory for learning to program _through_ Dart: ten
CS1 concepts × three question types (definitional, tracing, code completion),
every runnable item backed by tests, a computed map onto the Dart language spec,
and a proposed prerequisite graph for sequencing instruction.

## Provenance (clean-room statement)

The ten-concept × three-question-type structure follows the published design of
FCS1 (Tew & Guzdial, SIGCSE 2011) and SCS1 (Parker, Guzdial & Engleman, ICER
2016). Those are secure research instruments distributed under terms of use.
**No item text, options, or ordering from FCS1 or SCS1 was obtained, viewed, or
used** in creating this repository; only the concept list and question-type
scheme described in the papers were consulted. Every item here is original.

Contributors must keep it that way: do not contribute material derived from
FCS1, SCS1, or any other access-restricted assessment.

## What this is (and is not)

- **Is:** a formative, openly inspectable item bank for teaching, self-check,
  drills, and curriculum sequencing, with tests that pin every item's behaviour
  to the current Dart SDK.
- **Is not:** a validated psychometric instrument. Public items cannot be a
  secure summative measure, and no validity study has been done. Do not cite
  scores from it as comparable to FCS1/SCS1 results.

## License and contributing

BSD-3-Clause (see [LICENSE](LICENSE)) for code, data and item text alike. Source
files carry no per-file headers, so what the learner reads in `items/` is
exactly the program under question.

See [CONTRIBUTING.md](CONTRIBUTING.md) for the clean-room rule and the pre-PR
checklist.

## Layout

| Path                           | What                                                                                                                            |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------- |
| `items/<concept>/`             | One YAML per item; tracing/completion items have a sibling `.dart` program. Schema in [items/README.md](items/README.md).       |
| `test/items/`                  | One test file per concept: asserts the key output and what each distractor actually prints.                                     |
| `test/inventory_test.dart`     | Structural invariants: every concept × type cell populated, 4 distinct options, valid spec refs, code files exist, DAG acyclic. |
| `data/concepts.yaml`           | The ten FCS1 concepts with drill-practice flags.                                                                                |
| `data/spec_areas.yaml`         | Dart spec areas (stable section titles / feature-spec paths), CS1-scope flag, gap grouping.                                     |
| `data/translation_issues.yaml` | Pseudocode → Dart hazards and the decision taken for each.                                                                      |
| `data/dag.yaml`                | Prerequisite graph nodes and edges with rationale.                                                                              |
| `data/misconceptions.yaml`     | Catalog of named wrong models; every distractor cites one, so a wrong answer is evidence for a specific misconception.          |
| `tool/report.dart`             | Generates `coverage.md` and `dag.md` deterministically.                                                                         |
| `tool/balance_keys.dart`       | Rebalances answer-key positions across YAML, Dart and tests (seeded).                                                           |
| `test/compile_error_test.dart` | Substitutes every `compile_error` option into its template and asserts `dart analyze` reports the named diagnostic.             |
| `coverage.md`                  | Generated: item matrix, spec areas exercised, gap list, translation issues, drill candidates.                                   |
| `dag.md`                       | Generated: Mermaid graph, levels, node table, open questions.                                                                   |

## Using the tutor

`bin/tutor.dart` serves items one at a time and tracks mastery over the
prerequisite DAG. It is built to be driven by a coding agent (JSON in, JSON out)
but also runs at a terminal.

```sh
dart pub global activate --source git https://github.com/kevmoo/dart_cs1_inventory
tutor next                       # the next item to present; never includes the key
tutor check <item-id> <a|b|c|d>  # logs the answer, then reveals rationale (and key on hit, 2nd+ miss, or --reveal)
tutor status                     # mastery per node, misconception counts
tutor interactive                # no agent: answer at the terminal
```

Inside a checkout, `dart run dart_cs1_inventory:tutor …` works from any
directory. The tool locates its own `items/` and `data/`; the current working
directory never matters.

Rules the CLI enforces so an agent cannot leak or drift:

- `next` is deterministic: lowest unlocked, unmastered node in prerequisite
  order; serves `tracing` before `completion` in numeric item order, avoids
  repeating the item just answered when alternatives exist, and ensures a
  `completion` item is served once tracing evidence is satisfied.
- `check` writes the answer to the log _before_ revealing anything. On a first
  consecutive miss on an item, `check` returns only the chosen distractor's
  rationale and misconception (`consecutive_misses: 1`), withholding `answer`
  and `key` so the agent can coach the student to re-trace without giving away
  the letter; `answer` and `key` are revealed on a correct answer, a 2nd+
  consecutive miss, or `--reveal`.
- Mastery of a node requires distinct cold-credited evidence items (up to three,
  including at least one `tracing` and one `completion` item where the node has
  them); an immediate back-to-back retry after a miss does not credit the item
  until another item has intervened. Definitional items never count.

Answer logs live under the platform state directory
(`~/.local/state/dart_cs1_inventory/<student>/log.jsonl` on Linux, via
`package:cli_util`), overridable with `--state-dir` or `$DART_CS1_STATE`.
`tutor status` prints the resolved path.

## Commands

```sh
dart test                          # item tests + invariants + tutor engine
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
