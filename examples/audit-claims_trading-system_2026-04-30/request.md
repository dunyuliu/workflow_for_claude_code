# Request: claims audit — trading-system project

Audit the highest-stakes quantitative claims in a personal trading-system
project. You have Read/Bash/Grep/Glob/WebFetch.

## Claims under audit

1. **Portfolio annual returns vs SPY** for three sub-strategies, 2018-2025
   (per `compute_annual_returns.py` output):
   - Strategy A 8-yr cumulative TWR +89.3%, annualized +8.30%/yr vs SPY +14.21%/yr → α = -5.91 pp/yr
   - Strategy B 6-yr +32.1%, annualized +4.76%/yr vs SPY +14.99%/yr → α = -10.24 pp/yr
   - Strategy C 3-yr +11.74%/yr vs SPY +22.87%/yr → α = -11.13 pp/yr

2. **Multi-seed model alpha** (4 seeds × 24 folds, summary CSVs):
   - 0-3mo bucket α mean = +3.53%/Q, std 0.68pp, CoV 19%
   - 6mo compounded α mean = +10.50%, std 0.82pp
   - 12mo compounded α mean = +21.87%, std 0.97pp, CoV 4%
   - Range across seeds (12mo): [+20.44%, +22.61%]

3. **Cohort cost basis** per cohort markdown:
   - 10 names @ ~$500 each = $4,999.88 total filled YYYY-MM-DD
   - {ticker list}

4. **Subsequent cohort entry record** per cohort markdown + positions ledger:
   - 10 picks across 2 accounts (3 + 6) + 1 carried over from prior cohort
   - Claimed total cost: ~$4,979.31

5. **Long-history backtest claim** per `backtest.py` on a 142-year monthly dataset:
   - 1881-2023 full history: strategy CAGR +9.55% vs BH +6.50% → α = +2.64 pp/yr
   - Strategy MaxDD -37.21% vs BH MaxDD -76.80%

## Anchor sources (trust precedence)

- `transactions/anchors_reference.csv` — canonical year-end balances 2013-2025
- `transactions/fidelity_anchors_*.csv` — raw per-(account,year) anchor rows
- `output/eval/sp500_raw63d_v1.2.0*_summary.csv` — eval results per seed
- `sp500_pe_timed/shiller_data.csv` — long-history monthly dataset
- `output/cohort_plan.md` and `output/positions.csv` — cohort fill records

## Out of scope

- Strategy CHOICES (audit numbers, not decisions).
- Backtest haircut sizing (qualitative, not numeric).
- Anchor-extraction completeness (known incomplete; uses implied_net_flow).
- Paper-only seed cohorts beyond verifying entry prices.

## Identity checks to run

- For cumulative: chain-link per-year TWRs; should match headline.
- For multi-seed: 12mo α should match (1+a03)(1+a36)(1+a69)(1+a912)−1.
- For cohort cost basis: sum of 10 lots = published total.
- For backtest: re-derive on the cached dataset; verify 1-month lag.

Use the standard output schema from `agents/auditor-claims.md`.
This audit operates at the **application layer**.
