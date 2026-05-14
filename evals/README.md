# Evals — regression tests for the auditor prompts

Tiny synthetic projects with planted bugs. Each agent must find the
expected bugs; the eval fails if it doesn't.

## Layout (proposed; not yet populated)

```
evals/
├── README.md                              # this file
├── run_evals.sh                           # runs all cases, prints pass/fail
├── priya-nair/
│   └── case_01_off_by_one_total/
│       ├── project/                       # tiny synthetic project
│       ├── request.md                     # the audit prompt
│       ├── expected_findings.yaml         # expected severity + topic of findings
│       └── notes.md                       # explanation of the planted bug
├── lars-eriksson/
│   └── case_01_silent_nan_dropna/
├── jordan-kim/
│   ├── pipeline/
│   │   └── case_01_inner_join_drops_rows/
│   └── extraction/
│       └── case_01_pdf_misread_digit/
└── sophia-okafor/
    └── case_01_default_value_mismatch/
```

## How a case works

Each case is a self-contained tiny project with:

1. **`project/`** — a small repo (a few files) that contains exactly one
   planted bug appropriate for the agent under test. Other files are
   benign so the agent must localize the issue.
2. **`request.md`** — the audit prompt invoking the relevant agent on
   `project/`.
3. **`expected_findings.yaml`** — what findings should appear (by topic +
   severity), without dictating exact wording.

```yaml
# expected_findings.yaml
must_find:
  - topic: "off-by-one in cumulative total"
    severity: critical | medium
    location_hint: "project/script.py around line 42"
must_not_find:  # noise the agent should NOT flag
  - topic: "code style suggestion"
```

`run_evals.sh` invokes the agent for each case (via Claude Code's `Agent`
tool or the API) and grades the output against `expected_findings.yaml` —
PASS if all `must_find` topics appear and no `must_not_find` topics, FAIL
otherwise.

## Why this matters

Prompt repos drift silently. A subtle wording change in `lars-eriksson.md`
might make it skip whole classes of bugs. Without an eval suite, you find
out at the worst time — when a real audit misses something that ships.

## Status

**Not yet populated.** This README is a placeholder describing the shape.
First case to add: `priya-nair/case_01_off_by_one_total/` (since that
exact bug class showed up in the trading-system real audit — see
`examples/audit-claims_trading-system_2026-04-30/`).

Contributions welcome — small synthetic cases are higher-leverage than
elaborate ones.
