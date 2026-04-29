---
description: Release workflow — bump version, audit against PROJECT_RULES.md, write release notes reconciled against the final filesystem state, then commit.
---

<!-- 20260427 - v1 -->

# Release Workflow

When I say `release` (patch), `release minor`, or `release major`, execute this end to end.

## Trigger → version bump

- `release` → bump C (patch)
- `release minor` → bump B, reset C to 0
- `release major` → bump A, reset B and C to 0
- If no prior release note exists, start at `release_notes_v1.0.0.md`.

## Steps (in order)

1. **Inspect changes.** Run `git status` and `git diff HEAD` to see staged + unstaged changes. If git is unavailable, state that clearly and continue with all non-git steps.

2. **Find the current version.** Search both repo root and `docs/` for files matching `release_notes_v*.md`. The current version is the highest semver across both locations (by parsed A.B.C, not mtime or filename sort).

3. **Archive old notes.** If `docs/` does not exist, create it. Move every existing `release_notes_v*.md` from the repo root into `docs/`. Do not delete any release notes.

4. **Audit the project against `PROJECT_RULES.md`.** If `PROJECT_RULES.md` does not exist, stop and ask me to create it rather than improvising rules. The audit must check:
    - new or unprocessed files
    - naming-rule violations
    - duplicate or outdated files
    - cross-file consistency: totals, dates, travelers, bookings, summaries, and any other reconciliation fields defined in `PROJECT_RULES.md`
    - master documents that need updating
    - files that need renaming

5. **Apply fixes.** For each audit finding:
    - If the fix is mechanical (rename, move, update a total, sync a date), apply it.
    - If the fix requires human judgment, do not invent one. Record it under "remaining open issues" in the release note.

6. **Write the new release note** at the repo root as `release_notes_v<new>.md`. It describes the post-audit final state, reconciled against the actual filesystem — not the pre-audit state and not the raw git diff.

7. **Re-verify.** After all edits, re-read the new release note and spot-check every claim against the actual filesystem and master documents. Fix any drift.

8. **Commit.** Stage all changes and commit with: `release: v<A.B.C> — <one-line summary>`.

## Release note schema (use this section order)

1. Version and date
2. Summary of scope
3. Files added / removed / renamed / cleaned up
4. Content updates to master documents
5. Audit findings and fixes
6. Remaining open issues, unknowns, or pending bookings
7. Totals or cost changes
8. Assumptions used (including any fixed FX assumptions)

## Hard rules

- Never skip the audit.
- Never write the release note from git diff alone — reconcile against the final filesystem state.
- Never delete old release notes; only move them to `docs/`.
- Never invent fixes for findings that need human judgment; list them as open issues.
- New release notes go at the repo root. They are archived to `docs/` on the next release run.
