# How to Contribute

We would love to accept your patches and contributions to this project.

## Before you begin

### Sign our Contributor License Agreement

Contributions to this project must be accompanied by a
[Contributor License Agreement](https://cla.developers.google.com/about) (CLA).
You (or your employer) retain the copyright to your contribution; this simply
gives us permission to use and redistribute your contributions as part of the
project.

If you or your current employer have already signed the Google CLA (even if it
was for a different project), you probably don't need to do it again.

Visit <https://cla.developers.google.com/> to see your current agreements or to
sign a new one.

### Review our Community Guidelines

This project follows
[Google's Open Source Community Guidelines](https://opensource.google/conduct/)
and the [Code of Conduct](docs/code-of-conduct.md) in this repository.

### Keep it clean-room

Every item in this repository is original. **Do not contribute material
derived from FCS1, SCS1, or any other access-restricted or secure
assessment** — not item text, not options, not orderings. If you have seen
those instruments, write your items from the concept list alone, as the
existing ones were. See the provenance statement in the [README](README.md).

## Contribution process

### Code reviews

All submissions, including submissions by project members, require review. We
use [GitHub pull requests](https://docs.github.com/articles/about-pull-requests)
for this purpose.

### Adding or changing items

- Follow the schema in [items/README.md](items/README.md); every runnable item
  needs a sibling `.dart` file and a test under `test/items/`.
- Every completion distractor that compiles must print output distinct from the
  key; every `compile_error` distractor must name its `diagnostic`.
- Keep student-facing code student-shaped: no language features outside the
  tracked CS1 scope in `data/spec_areas.yaml`.
- Before opening a PR run:

  ```sh
  dart analyze --fatal-infos
  dart test
  dart run tool/report.dart --check
  dart run tool/balance_keys.dart --dry-run   # must report 0 swaps
  ```

  If `report.dart --check` fails, regenerate with `dart run tool/report.dart`
  and commit `coverage.md` / `dag.md`. If `balance_keys.dart --dry-run` wants
  to swap, run it without `--dry-run` and commit the result.
