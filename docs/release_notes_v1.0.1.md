# Release notes — v1.0.1 — 2026-05-14

## Summary

Structural refactor of the agent team and slash commands. Flattened the
routing hierarchy to two levels, replaced two heavy command files with ten
descriptive thin-wrapper commands, renamed one specialist, and tuned model
assignments to reduce cost.

## Files added

**Agents:**
- `agents/ziyan-chen.md` — renamed from `mary-chen.md`; same role, updated persona

**Commands (new, replacing `audit.md` and `release.md`):**
- `commands/audit-all-victor-reyes.md`
- `commands/audit-code-lars-eriksson.md`
- `commands/audit-data-jordan-kim.md`
- `commands/audit-numerics-priya-nair.md`
- `commands/audit-citations-ziyan-chen.md`
- `commands/audit-physics-rafael-santos.md`
- `commands/audit-math-ingrid-lindqvist.md`
- `commands/audit-spec-sophia-okafor.md`
- `commands/scientific-review-elena-hartmann.md`
- `commands/release-dev-nakamura.md`

**Docs:**
- `docs/release_notes_v1.0.0.md` — archived from repo root

## Files removed

- `agents/mary-chen.md` — renamed to `ziyan-chen.md`
- `commands/audit.md` — replaced by `audit-all-victor-reyes.md` (thin wrapper) + logic moved into `victor-reyes.md`
- `commands/release.md` — replaced by `release-dev-nakamura.md` (thin wrapper) + logic moved into `dev-nakamura.md`

## Content updates

- **`agents/victor-reyes.md`**: 8-section audit framework moved here from `commands/audit.md`; removed redundant "When to inline vs spawn" table; updated `mary-chen` → `ziyan-chen` reference.
- **`agents/dev-nakamura.md`**: Full release workflow steps moved here from `commands/release.md`.
- **`agents/elena-hartmann.md`**: Dispatch section rewritten — now routes directly to specialists instead of relaying through `victor-reyes`. Eliminates the 3-level chain.
- **All specialist agents**: Removed "Usually invoked by / Can be used directly" preamble from descriptions.

## Audit findings and fixes

No `PROJECT_RULES.md` present — audit step skipped per workflow rules.

## Remaining open issues

None.

## Model assignments (post-release state)

| Agent | Model |
|---|---|
| `elena-hartmann` | opus |
| `victor-reyes` | opus |
| `priya-nair` | sonnet |
| `rafael-santos` | sonnet |
| `ingrid-lindqvist` | sonnet |
| `ziyan-chen` | sonnet |
| `jordan-kim` | sonnet |
| `dev-nakamura` | sonnet |
| `lars-eriksson` | haiku |
| `sophia-okafor` | haiku |
