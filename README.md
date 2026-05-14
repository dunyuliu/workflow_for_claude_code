# Consilium

Personal Claude Code customizations: slash commands and subagents that follow
you across machines.

## Layout

```
consilium/
├── commands/          # custom slash commands  (--> ~/.claude/commands/)
│   ├── audit.md       #   /audit — single-pass scientific-project audit
│   └── release.md     #   /release — versioned-release workflow
├── agents/            # specialist subagents   (--> ~/.claude/agents/)
│   ├── elena-hartmann.md   #   Editor in Chief — final scientific authority
│   ├── victor-reyes.md     #   audit orchestrator — routes to specialists
│   ├── mary-chen.md        #   senior editor — citations, DOIs, manuscripts
│   ├── priya-nair.md       #   quantitative claims vs raw anchor data
│   ├── lars-eriksson.md    #   code math bugs, edge cases, sign conventions
│   ├── jordan-kim.md       #   data integrity — extraction + pipeline
│   ├── sophia-okafor.md    #   spec drift — docs vs code
│   ├── dev-nakamura.md     #   releases, CI/CD, versioning, build pipelines
│   ├── rafael-santos.md    #   physical validity — units, conservation, BCs
│   └── ingrid-lindqvist.md #   mathematical rigor — derivations, stability, proofs
├── scripts/
│   └── install.sh     # symlink everything into ~/.claude
└── README.md
```

## Install on a new machine

```bash
git clone git@github.com:dunyuliu/consilium.git ~/consilium
bash ~/consilium/scripts/install.sh
```

`install.sh` creates symlinks from `~/.claude/{commands,agents}/<name>` to
files inside this repo, so editing a file here immediately reflects in Claude
Code, and `git pull` updates them.

## When to use which

```
Need a scientific judgment call?
│
├─ Holistic read — is the science sound? Is this publishable?
│  → elena-hartmann (Editor in Chief — dispatches the team as needed)
│
└─ Citations, DOIs, author lists, claim vs abstract, numbers from a cited paper
   → mary-chen

Need to audit a codebase or analysis?
│
├─ Small project, one-shot pre-release sweep
│  → /audit slash command — produces AUDIT.md in one pass
│
├─ Not sure which specialist
│  → victor-reyes (routes and dispatches in parallel)
│
├─ Numeric claim from raw data (CSV, instrument, dataset)
│  → priya-nair
│
├─ Code bugs (math, edge cases, sign conventions)
│  → lars-eriksson
│
├─ Data integrity: raw-source extraction OR pipeline tracing
│  → jordan-kim
│
├─ Docs / preregistration vs implementation drift
│  → sophia-okafor
│
├─ Physical validity (units, conservation, BCs, approximations)
│  → rafael-santos
│
├─ Mathematical rigor (derivations, stability, convergence, linear algebra)
│  → ingrid-lindqvist
│
└─ Big project, release-gate, multi-dimensional
   → victor-reyes — spawns specialists in parallel

Need to release or fix CI?
├─ Cut a release, audit changelog, check version consistency
│  → dev-nakamura (or /release for the automated workflow)
└─ CI pipeline failing, build system broken, deployment issue
   → dev-nakamura
```

## The team

| Agent | Persona | Role |
|---|---|---|
| `elena-hartmann` | Prof. Elena Hartmann, EIC | Final scientific authority. Holistic verdict on manuscripts and analyses. Dispatches the full team when needed. |
| `victor-reyes` | Victor Reyes, Chief of Staff | Audit orchestrator. Routes technical work to the right specialist(s), runs in parallel, aggregates findings. |
| `mary-chen` | Mary Chen, Senior Editor | Manuscript citations and scientific validity. DOI resolution, author verification, claim-vs-abstract mismatch, overclaimed results. |
| `priya-nair` | Dr. Priya Nair, Quant Analyst | Numeric claim verification from raw anchor data (CSV, instrument, brokerage statement). Independent re-derivation. |
| `lars-eriksson` | Lars Eriksson, Senior Engineer | Code auditor. Math errors, edge cases, sign-convention bugs, silent-failure modes at file:line. Read-only. |
| `jordan-kim` | Jordan Kim, Data Engineer | Data integrity. Extraction quality (raw source → anchor) and end-to-end pipeline tracing (drops, duplication, time-alignment). |
| `sophia-okafor` | Sophia Okafor, Tech Writer/Engineer | Spec drift. Docs, methods sections, and configs vs actual code behavior. |
| `dev-nakamura` | Dev Nakamura, Release Engineer | Software releases, CI/CD, versioning, changelog accuracy, build reproducibility, deployment pipelines. |
| `rafael-santos` | Dr. Rafael Santos, Physicist | Physical validity: dimensional analysis, conservation laws, boundary conditions, approximation validity, numerical scheme physics. |
| `ingrid-lindqvist` | Prof. Ingrid Lindqvist, Mathematician | Mathematical rigor: derivation correctness, theorem applicability, numerical stability, linear algebra, inverse problems, statistical assumptions. |

## How it works

- **Independence.** Each subagent runs in its own context and doesn't see your
  prior conversation. This forces re-derivation from raw sources.
- **Read-only specialists.** Auditors verify; they don't fix. Apply fixes, then
  re-run the auditor to confirm.
- **Clear boundaries.** Each agent states what falls outside their scope and who
  to hand off to.
- **Hierarchy.** Elena sits above the team. Victor routes technical work.
  Specialists go deep on one dimension each.
- **Final sign-off rests with the human.**

## Commands (slash)

| Slash | What |
|---|---|
| `/audit` | Single-pass eight-section project audit. Writes `AUDIT.md`. Sections: goal & implementation, inventory & stale, reproducibility, physics & numerics, implementation consistency, logging & errors, performance, top-N priorities. |
| `/release` | Version-bump release workflow. Triggers: `release` (patch), `release minor`, `release major`. Audits against `PROJECT_RULES.md` in the project root, archives release notes, commits as `release: v<X.Y.Z> — <summary>`. |

## Adding a new agent

1. Drop `agents/<name>.md` with frontmatter: `name`, `description`, `tools`, `model`.
2. Write a specific `description:` — Victor and Elena route based on it.
3. Run `bash scripts/install.sh`.
4. Verify: open Claude Code and run `/agents`.

## Adding a new command

1. Drop `commands/<name>.md` (use existing files as templates).
2. Run `bash scripts/install.sh`.

## Roadmap

- `evals/` — regression test cases (planted bugs; agents must find them).
- Statistics specialist for p-hacking, multiple comparisons, study design.
- Security/privacy agent for credential leaks, PII, supply-chain risk.
- GitHub-Action wiring so audits run automatically on PRs.
