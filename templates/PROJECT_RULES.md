# PROJECT_RULES.md — template

> **How to use:** copy this file to your project root, then fill in / delete each
> section. The `/release` command reads it before each release; if a section is
> empty, that audit step is skipped. The single line "pass all the tests" is
> usually a regression — if that's literally all your project rules are, say so
> explicitly under "## Tests" so future-you knows it's intentional.

---

## Naming rules

Conventions to enforce. Examples:

- File names: `<topic>_<YYYY-MM-DD>.md` for dated documents.
- Code files: `snake_case.py`, no spaces, no version suffixes.
- Branches: `feat/<topic>` / `fix/<topic>` / `docs/<topic>`.
- Cohort / batch files: `COHORT_<version>_<hp>_<strategy>_<date>.md` (or your
  project's equivalent self-describing pattern).

(Delete any line that doesn't apply.)

## Cross-file consistency / reconciliation fields

Fields that should match across multiple files. Examples:

- Total dollar amounts in summary doc match sum of line items in detail docs.
- Dates in calendar/itinerary match dates in master schedule.
- Version number in `setup.py` matches `CHANGELOG.md` matches `release_notes_v*.md`.
- Active model / strategy / configuration name in main README matches what's
  actually deployed.

(Each line should be specific enough that an auditor can mechanically check.)

## Master documents to keep updated

Documents that other documents must align with:

- `README.md` — keep accurate after every successful change.
- `CHANGELOG.md` — append on every release; never rewrite history.
- `<your project's spec / design doc>` — update when behavior changes.
- `<your project's plan>` — update when status changes.

## Files to archive vs delete

- Old release notes: archive to `docs/`, never delete.
- `*.bak`, `_old`, `_TEMP`: delete, unless modified within last 7 days.
- Unreferenced scripts: archive to `archive/` after verifying nothing imports them.

## Tests

How tests must behave for a release to ship:

- All unit tests pass: `pytest -q`.
- Linting clean: `ruff check`.
- (Or for a non-code project: define your "tests" — could be checklists,
  reconciliation scripts, dry-runs.)

## Forbidden actions during release

Things `/release` must not do automatically:

- Force-push.
- Delete files modified in the last 7 days.
- Rewrite git history.
- Change version numbers in dependencies / lock files.
- Push to the remote without explicit user confirmation.

## Project-specific rules

Add anything else specific to this project. Examples:

- **Trading-system project**: every cohort file is append-only. Past plans are
  never overwritten — superseded plans get a footer pointing to the replacement.
- **Scientific project**: every figure must be reproducible from a script in
  `scripts/figures/`; no manual Excel exports.
- **Data project**: schema changes require an updated `metadata.yaml`.

---

## Minimal rule (placeholder for tiny projects)

If you have nothing else, at least:

- Pass all the tests before tagging a release.
- Update CHANGELOG.md.
- Don't delete data.
