# Agent instructions for contributors

This file is for agents **editing this repository**. It is not the tutoring
protocol; a learner's agent drives `bin/tutor.dart` and must never read
`items/`. That protocol will live in a separate skill.

## What this repo is

An original, clean-room Dart concept inventory shaped like FCS1/SCS1: 46
multiple-choice items across ten concepts × three types, a prerequisite DAG, a
misconception catalog, and a tutor CLI. Read [README.md](README.md) and
[items/README.md](items/README.md) before touching items.

## Hard rules

1. **Clean-room.** Never fetch, quote, paraphrase or "reconstruct" FCS1, SCS1,
   or any secure assessment. Write items from the concept list and the Dart spec
   only. If you are unsure whether something is derived, do not add it.
2. **Student-shaped code.** Student-facing `items/**/*.dart` use only features
   in CS1 scope (`data/spec_areas.yaml`, `cs1_scope: true`): `var`, explicit
   types, `if`/loops/lists/functions/simple classes. No `final`, cascades,
   primary constructors, `switch`, named or optional parameters, inheritance,
   getters, `static`, null-aware operators. If an item is _about_ a gap feature,
   it belongs in a tracked gap, not in `items/`.
3. **Every distractor names a misconception.** `misconception:` must be an id
   from `data/misconceptions.yaml`; the key must not have one. Reuse an existing
   id when it fits; add a new one only for a genuinely new wrong model, and
   prefer a specific id over `bounds.off_by_one` / `trace.wrong_operation`.
4. **Truth comes from running code.** Option text for tracing and completion
   items is verified by `test/items/<concept>_test.dart`, which runs the
   program. Never assert output you have not executed.
5. **Generated files are generated.** Do not hand-edit `coverage.md` or
   `dag.md`; run `dart run tool/report.dart`. CI runs `--check`.
6. **Keys stay balanced.** After adding or editing items, run
   `dart run tool/balance_keys.dart` (CI requires `planned 0 swaps`).

## Adding an item

1. Pick the concept, type, and `dag_node`. Copy a sibling item's YAML as the
   template; the schema is in `items/README.md`.
2. Write the program (`<id>.dart`): tracing items are a plain `void main()` that
   only prints; completion items have `void optionA()..optionD()` with `// KEY`
   above the key's function; distractors that would not compile are left out of
   the `.dart` file and marked `compile_error: true` + `diagnostic:` in the
   YAML.
3. Add `group('<id>', ...)` to `test/items/<concept>_test.dart` asserting what
   each option prints (or throws).
4. Run the checks below; then `tool/balance_keys.dart` and `tool/report.dart`.

## Checks (all must pass before a PR)

```sh
dart analyze --fatal-infos
dart test
dart run tool/report.dart --check
dart run tool/balance_keys.dart --dry-run   # expect "planned 0 swaps"
npx --yes prettier@3.9.6 --check "**/*.md"
```

## Layout cheatsheet

| Path                       | Role                                                  |
| -------------------------- | ----------------------------------------------------- |
| `items/<concept>/`         | Item YAML + Dart programs (student-facing)            |
| `data/misconceptions.yaml` | Catalog every distractor cites                        |
| `data/dag.yaml`            | Prerequisite graph the tutor walks                    |
| `data/spec_areas.yaml`     | Dart spec areas; `cs1_scope` defines allowed features |
| `lib/src/model.dart`       | Loader and value types                                |
| `lib/src/tutor.dart`       | Mastery rule, item selection, answer log              |
| `bin/tutor.dart`           | Student-facing CLI (`next`, `check`, `status`)        |
| `test/inventory_test.dart` | Referential-integrity invariants                      |
| `tool/`                    | Maintainer scripts (report, key balancing)            |

## Conventions

- Branch + PR; `main` requires green `test` and `markdown` checks.
- Dart: `dart format`, lints from `analysis_options.yaml`;
  `items/analysis_options.yaml` deliberately relaxes student-hostile lints.
- Markdown: Prettier (`.prettierrc.json`); generated files are range-ignored.
- Keep PRs to one concern: content, engine, or docs.
