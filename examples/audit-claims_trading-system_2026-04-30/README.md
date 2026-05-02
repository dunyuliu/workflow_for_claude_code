# Example: claims audit on a trading-system project

**When**: 2026-04-30
**Auditor**: `auditor-claims` (run as `general-purpose` with the system prompt
inlined, before subagent registration was active).
**Subject**: a personal trading system with portfolio reconstruction +
strategy backtests + cohort tracker.

## What was asked

Verify five categories of headline numeric claims against their anchor sources:

1. Multi-year portfolio returns vs SPY (TWR + α), 2018-2025.
2. Multi-seed model alpha (4 seeds × 24 folds; bucketed at 3/6/12-mo).
3. Cohort cost basis ($5K real-money cohort).
4. Cohort entry record (per-account fills, total).
5. Backtest result on a 142-year dataset (CAGR + max drawdown + lookahead check).

Anchors specified: per-account year-end CSV, multi-seed eval CSVs, cohort
markdown, positions ledger, Shiller monthly dataset.

## What it found (sanitized)

| # | Severity | Issue |
|---|---|---|
| 1 | Low | Cohort plan markdown's `Total` row was off by $1.00 from the sum of its own line items — a typo in the markdown. |
| 2 | Medium | Same position carried two different cost bases in two different files (ENS_A's EPAM lot: $499.94 in plan markdown vs $500.00 proxy in positions.csv). Bookkeeping drift, not money lost. |
| 3 | Medium | Backtest claim mixed two different runs: the date range and the BH baseline number were copied from a 1881-restricted run while the strategy CAGR / α numbers came from the default 1871 run. Internally inconsistent header. |
| 4 | Advisory | A 0% TWR was silently used in a chained annual-TWR computation when the start-of-year balance was below a $1000 guard threshold. The published cumulative return therefore under-states the strategy by ignoring two account-startup years. |

All other claims (~17 of 21) reproduced to basis-point precision against the
anchors.

## What was useful

- **Caught a real bookkeeping inconsistency** (issue 2) that nobody had noticed.
- **Found internal contradiction** in a published header (issue 3) between
  date-range and the metric values — the kind of error humans skim past.
- **Surfaced a methodology caveat** (issue 4) about a silent guard clause that
  changes the meaning of an aggregate.

## What it missed (and why)

- It did NOT verify the **anchors themselves**. If the YEI PDF extraction had
  dropped a digit, this audit wouldn't catch it (that's `auditor-data-quality`'s
  job).
- It did NOT verify the **code behind the anchors** — the back-walk logic, the
  classifier rules, the Modified Dietz implementation. (That's `auditor-code`).
- It did NOT trace **end-to-end data flow** for any single trade, so silent
  losses in the master CSV vs broker CSV would slip through. (That's
  `auditor-pipeline`).

This is by design — `auditor-claims` is the narrowest specialty. For a
release-gate audit, also dispatch `auditor-code` + `auditor-pipeline` +
`auditor-data-quality` + `auditor-spec-drift` via the `auditor` orchestrator.

## The prompt that invoked it

See `request.md` next to this file. It follows the standard `auditor-claims`
shape: numbered claims + anchor paths + out-of-scope items + identity checks
to run.

## The output

See `report.md` for the structured audit report. The format follows the
schema in `agents/auditor-claims.md`.

## Reflections for next time

- For numeric claims, always provide **both the claimed value and the anchor
  path** in the request. The auditor wastes time hunting for anchors otherwise.
- Specify **out-of-scope items explicitly** (e.g., "don't audit the haircut
  prior — it's qualitative"). Otherwise the auditor will spend cycles on them.
- Identity-check guidance accelerates the audit (e.g., "compounded A α should
  match (1+a03)(1+a36)(1+a69)(1+a912)−1"). Without it, the agent re-derives
  these from scratch.
- Privacy: the actual report contains real account references and dollar
  values. Sanitize before sharing externally — paraphrase numbers as
  "$1.00 typo in cost-basis total" rather than quoting the real total.
