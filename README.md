# workflow_for_claude_code

Personal Claude Code customizations: slash commands, subagents, skills, and
audit templates that follow you across machines.

## Layout

```
workflow_for_claude_code/
├── commands/             # custom slash commands     (--> ~/.claude/commands/)
│   ├── audit.md          #   /audit — single-pass scientific-project audit
│   └── release.md        #   /release — versioned-release workflow
├── agents/                            # specialist subagents  (--> ~/.claude/agents/)
│   ├── auditor.md                     #   orchestrator — routes to specialists
│   ├── auditor-claims.md              #   verify numeric claims vs anchors
│   ├── auditor-code.md                #   read code, find math/edge-case bugs
│   ├── auditor-pipeline.md            #   trace one item end-to-end
│   ├── auditor-data-quality.md        #   raw-source-vs-extracted verification
│   └── auditor-spec-drift.md          #   docs vs code drift
├── skills/                            # custom skills         (--> ~/.claude/skills/)
│                                      #   (empty — drop new skills/<name>/SKILL.md here)
├── templates/
│   └── PROJECT_RULES.md               # per-project rulebook for /release
├── examples/                          # real audit reports — copy/paste templates
├── evals/                             # regression-test cases for the prompts
│                                      #   (skeleton only — see evals/README.md)
├── scripts/
│   └── install.sh                     # symlink everything into ~/.claude
└── README.md
```

## Install on a new machine

```bash
git clone git@github.com:dunyuliu/workflow_for_claude_code.git ~/workflow_for_claude_code
bash ~/workflow_for_claude_code/scripts/install.sh
```

`install.sh` creates symlinks from `~/.claude/{commands,agents,skills}/<name>` to
files inside this repo, so editing a file here immediately reflects in Claude
Code, and `git pull` updates them.

## When to use which

```
Need to audit something?
│
├─ Small project, one-shot pre-release sweep
│  → run /audit slash command — gets you AUDIT.md in one pass
│
├─ Specific numeric claim to verify
│  → ask Claude to use the auditor-claims subagent
│
├─ Bug hunt in code (math, edge cases, sign conventions)
│  → auditor-code subagent
│
├─ Reproducibility / data-flow tracing
│  → auditor-pipeline subagent
│
├─ Raw-source-vs-extracted verification (PDFs, scans, APIs)
│  → auditor-data-quality subagent
│
├─ Docs / preregistration vs implementation
│  → auditor-spec-drift subagent
│
└─ Big project, release-gate, multi-dimensional audit
   → ask Claude to use the auditor orchestrator subagent — it spawns the
      relevant specialists in parallel and aggregates findings

Need to release?
└─ /release [patch|minor|major]
```

## How auditing works (design philosophy)

- **Independence.** Each subagent runs in its own context (`Agent` tool) and
  doesn't see your prior conversation. This forces re-derivation from raw
  sources rather than re-stating prior conclusions.
- **Read-only.** Auditors verify; they don't fix. A separate agent (or you)
  applies fixes, then re-runs the auditor to confirm.
- **Anchor precedence.** Each specialist defines its trust hierarchy: official
  source > raw measurement > reference CSV > derived script > prior report.
- **Standardized output.** Every audit produces a structured report with
  PASS / FAIL per claim, severity, file:line citations, and reproducers.
- **Final sign-off rests with the human reviewer.**

This mirrors Anthropic's published agent-design pattern (see
["Building effective agents"](https://www.anthropic.com/engineering/building-effective-agents),
Dec 2024) — composability over monoliths, evaluation-first, specialized
agents with clear interfaces.

## Commands (slash)

| Slash | What |
|---|---|
| `/audit` | Single-pass eight-section project audit tuned for scientific / numerical / data-pipeline projects. Writes `AUDIT.md`. Sections: goal & implementation, inventory & stale, reproducibility, physics & numerics, implementation consistency, logging & errors, performance, top-N priorities. |
| `/release` | Version-bump release workflow. Triggers: `release` (patch), `release minor`, `release major`. Audits against `PROJECT_RULES.md`, archives release notes, commits as `release: v<X.Y.Z> — <summary>`. Requires a `PROJECT_RULES.md` in the project root — copy `templates/PROJECT_RULES.md` from this repo as a starting point. |

## Agents (subagents)

| Agent | What |
|---|---|
| `auditor` | Orchestrator. Diagnoses scope, dispatches specialists in parallel for big audits. Use this if unsure which to invoke. |
| `auditor-claims` | Verifies specific numeric claims vs anchor data. Independent re-derivation. |
| `auditor-code` | Reads source, finds math / edge / sign-convention / silent-failure bugs at file:line. |
| `auditor-pipeline` | Traces one item end-to-end through every stage; flags drops / duplications / time-misalignment. |
| `auditor-data-quality` | Samples raw sources (PDFs, scans, APIs); verifies extraction matches the source. |
| `auditor-spec-drift` | Compares docs / preregistration / configs to actual code behavior. |

## Examples

Real audit outputs live under `examples/`. Each one shows: (1) the request
prompt that invoked the auditor, (2) the produced report, (3) a short
reflection on what was useful and what the audit missed.

Add a new example any time you run an audit on a real project — that's how
the repo gains real-world coverage.

## Adding a new command

1. Drop `commands/<name>.md` into this repo (use existing files as templates).
2. Run `bash scripts/install.sh` (idempotent — only creates missing links).
3. Commit and push.
4. On other machines: `git pull && bash scripts/install.sh`.

## Adding a new agent

1. Drop `agents/<name>.md` with proper frontmatter (`name`, `description`,
   `tools`, `model`).
2. Run `bash scripts/install.sh`.
3. Verify it's discoverable: open Claude Code and run `/agents`.

## Adding a skill

Place under `skills/<name>/SKILL.md` following the
[Claude skills format](https://docs.claude.com/skills). Then
`bash scripts/install.sh`.

## Roadmap

- `evals/` — regression test cases (small synthetic projects with planted
  bugs; auditors must find them).
- Domain-specific specialty agents (e.g., `auditor-statistics` for p-hacking
  and multiple-comparisons; `auditor-units` for dimensional analysis).
- GitHub-Action wiring so audits run automatically on PRs.
- More worked examples spanning trading, geophysics, ML.
