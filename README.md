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
│   ├── elena-hartmann.md              #   Editor in Chief — final scientific authority
│   ├── victor-reyes.md                #   audit orchestrator — routes to specialists
│   ├── mary-chen.md                   #   senior editor — citations, DOIs, manuscripts
│   ├── priya-nair.md                  #   quantitative claims vs raw anchor data
│   ├── lars-eriksson.md               #   code math bugs, edge cases, sign conventions
│   ├── jordan-kim.md                  #   data integrity — extraction + pipeline
│   └── sophia-okafor.md               #   spec drift — docs vs code
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
Need a scientific judgment call?
│
├─ Holistic read — is the science sound? Is this publishable?
│  → elena-hartmann (Editor in Chief — she dispatches the team as needed)
│
└─ Citations, DOIs, author lists, claim vs abstract, numbers from a cited paper
   → mary-chen

Need to audit a codebase or analysis?
│
├─ Small project, one-shot pre-release sweep
│  → run /audit slash command — gets you AUDIT.md in one pass
│
├─ Not sure which specialist — let someone route it
│  → victor-reyes (dispatches specialists in parallel)
│
├─ Specific numeric claim to verify from raw data (CSV, instrument, dataset)
│  → priya-nair
│
├─ Bug hunt in code (math, edge cases, sign conventions)
│  → lars-eriksson
│
├─ Data integrity: extraction from raw source OR end-to-end pipeline tracing
│  → jordan-kim
│
├─ Docs / preregistration vs implementation drift
│  → sophia-okafor
│
└─ Big project, release-gate, multi-dimensional audit
   → victor-reyes — spawns relevant specialists in parallel

Need to release?
└─ /release [patch|minor|major]
```

## The team

| Agent | Persona | Role |
|---|---|---|
| `elena-hartmann` | Prof. Elena Hartmann, EIC | Final scientific authority. Broad scope. Holistic verdict on manuscripts and analyses. Dispatches the full team when needed. |
| `victor-reyes` | Victor Reyes, Chief of Staff | Audit orchestrator. Routes technical work to the right specialist(s), runs them in parallel, aggregates findings. |
| `mary-chen` | Mary Chen, Senior Editor | Manuscript citations and scientific validity. DOI resolution, author verification, claim-vs-abstract mismatch, overclaimed results. |
| `priya-nair` | Dr. Priya Nair, Quant Analyst | Numeric claim verification. Re-derives every number independently from raw anchor data (CSV, instrument, brokerage statement). |
| `lars-eriksson` | Lars Eriksson, Senior Engineer | Code auditor. Finds math errors, edge cases, sign-convention bugs, and silent-failure modes at file:line. Read-only. |
| `jordan-kim` | Jordan Kim, Data Engineer | Data integrity. Covers both extraction quality (raw source → anchor) and end-to-end pipeline tracing (drops, duplication, time-alignment, reproducibility). |
| `sophia-okafor` | Sophia Okafor, Tech Writer/Engineer | Spec drift. Compares docs, methods sections, and configs to actual code behavior; flags every divergence. |

## How it works (design philosophy)

- **Independence.** Each subagent runs in its own context (`Agent` tool) and
  doesn't see your prior conversation. This forces re-derivation from raw
  sources rather than re-stating prior conclusions.
- **Read-only specialists.** Auditors verify; they don't fix. A separate agent
  (or you) applies fixes, then re-runs the auditor to confirm.
- **Clear boundaries.** Each agent states explicitly what falls outside their
  scope and who to hand off to. Priya handles raw data; Mary handles published
  papers. Jordan handles extraction and pipelines; Lars handles the code that
  runs them.
- **Hierarchy.** Elena sits above the team and makes the final call. Victor
  routes the technical work. Specialists go deep on one dimension each.
- **Final sign-off rests with the human.**

This mirrors Anthropic's published agent-design pattern (see
["Building effective agents"](https://www.anthropic.com/engineering/building-effective-agents),
Dec 2024) — composability over monoliths, evaluation-first, specialized
agents with clear interfaces.

## Commands (slash)

| Slash | What |
|---|---|
| `/audit` | Single-pass eight-section project audit tuned for scientific / numerical / data-pipeline projects. Writes `AUDIT.md`. Sections: goal & implementation, inventory & stale, reproducibility, physics & numerics, implementation consistency, logging & errors, performance, top-N priorities. |
| `/release` | Version-bump release workflow. Triggers: `release` (patch), `release minor`, `release major`. Audits against `PROJECT_RULES.md`, archives release notes, commits as `release: v<X.Y.Z> — <summary>`. Requires a `PROJECT_RULES.md` in the project root — copy `templates/PROJECT_RULES.md` from this repo as a starting point. |

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

- `evals/` — regression test cases (small synthetic projects with planted bugs;
  agents must find them).
- Domain-specific specialty agents (e.g., statistics for p-hacking and multiple
  comparisons; units for dimensional analysis).
- GitHub-Action wiring so audits run automatically on PRs.
- More worked examples spanning trading, geophysics, ML.
