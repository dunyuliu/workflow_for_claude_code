# Audit report — claims — trading-system headline figures — 2026-04-30

(Numbers below are sanitized — real account refs and $-values redacted or
paraphrased. Real audit output preserved verbatim privately.)

## Per-claim verdict

| # | Claim | Verdict | Δ |
|---|---|---|---|
| 1a | Strategy A 2018-2025 cum +89.3% / +8.30%/yr / α = −5.91 pp | PASS | <0.01 |
| 1b | Strategy B 2020-2025 +32.1% / +4.76%/yr / α = −10.24 pp | PASS | <0.01 |
| 1c | Strategy C 2023-2025 +11.74%/yr / α = −11.13 pp | PASS | 0 |
| 2a | D bucket α mean +3.53%/Q, std 0.68pp, CoV 19% | PASS | 0 |
| 2b | B compounded α mean +10.50%, std 0.82pp | PASS | 0 |
| 2c | A compounded α mean +21.87%, std 0.97pp, CoV 4% | PASS | 0 |
| 2d | A α range across seeds [+20.44%, +22.61%] | PASS | 0 |
| 3a | Cohort total cost = $4,999.88 | **FAIL** | **−$1.00** |
| 3b | 10 names listed | PASS | 0 |
| 4a | ENS picks list | PASS | 0 |
| 4b | Real fills date + accounts | PASS | — |
| 4c | ENS total cost ~$4,979.31 | **PASS-ambiguous** | $0.10 |
| 4d | EPAM cost basis | **DISCREPANCY** | bookkeeping inconsistency |
| 5a | SMA_12mo CAGR +9.55% / α +2.64pp / MaxDD −37.21% | PASS | 0 |
| 5b | BH CAGR +6.50% | **FAIL** | actual +6.92% (1871 default) |
| 5c | Date range "1881-2023" | **FAIL** | data starts 1871 |
| 5d | 1-month lag (no look-ahead) | PASS | confirmed |

## Discrepancies

### D1 — Cohort total cost off by $1.00 (markdown typo)

- **Anchor (sum of 10 line items in markdown)**: $4,998.88
- **Markdown's stated Total row**: $4,999.88
- **Audit prompt copied the wrong total**.
- Reproducer: `python3 -c "print(sum([499.94,499.81,499.96,499.91,499.98,499.91,499.75,499.94,499.92,499.76]))"` → 4998.88.

### D2 — ENS_A EPAM: same position recorded with two different cost bases

- Cohort markdown: EPAM "rolled from prior cohort" at 4.227 sh × $118.27 = $499.94 (B1 carryover)
- positions.csv: EPAM at 4.3802 sh × $114.15 = $500.00 (PROXY at next-day close)
- Both describe today's holding. Different cost basis.
- Probable cause: positions.csv was filled as if EPAM were a fresh PAPER proxy at next-day close; markdown wrote it up as the prior-cohort retention.

### D3 — Backtest claim mixes two runs

- "1881-2023 full history" + "BH +6.50%" don't match the same run that
  produced "SMA_12mo +9.55%" and "α +2.64pp".
- Default run: 1871-2023, BH +6.92%, SMA +9.55%, α +2.64pp ← internally consistent
- 1881-restricted run: BH +6.55%, SMA +9.26%, α +2.70pp
- The headline mixes columns from both runs.
- Reproducer:
  ```
  python3 backtest.py
  python3 backtest.py --start 1881-01
  ```

### D4 — Methodological caveat (sector_etf chained TWR)

`compute_annual_returns.py` discards years where `v_begin <= $1000`
(account-open guard). The chained 6-year cumulative therefore uses 0% for
two startup years. The reported annualized return understates the strategy
by ignoring meaningful early growth.

The claim correctly reproduces against the script — but the methodology
itself is questionable. Score PASS-with-caveat.

## Open questions

- Anchor row for the 2020 startup year shows TWR=+3.10% per
  `anchors_reference.csv`; should it be included rather than zeroed by the
  $1000 guard?
- ENS_A EPAM canonical cost basis needs a single source of truth.

## Final note

Three actionable issues found. All other claims reproduce to basis-point
precision. SPY values verified against fresh price data. Multi-seed alpha
internally consistent. Cohort line items internally consistent except as
noted.

Sign-off rests with the human reviewer.
