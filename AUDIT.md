# AUDIT.md — consilium — 2026-05-14

## Executive summary

**Top-3 wins**
1. `scripts/install.sh` is idempotent, self-locating, and handles all edge cases correctly (symlink detection, real-dir refusal, `--force` flag).
2. All 10 agent files have consistent frontmatter (`name`, `description`, `tools`, `model`) matching the README's documented schema exactly.
3. The routing hierarchy (Elena → Victor → specialists) is internally consistent across all agent definitions.

**Top-3 risks**
1. `scripts/install.sh:70–80` handles a `skills/` directory that does not exist in the repo and is not documented — dead code block that silently does nothing.
2. `victor-reyes.md:49,74` references `commands/audit.md` by a bare relative path; when Victor runs as a subagent from `~/.claude/agents/`, that path is ambiguous and resolution depends on Victor's file-reading behavior.
3. README install instructions use SSH (`git@github.com:…`) but the actual configured remote is HTTPS (`https://github.com/…`) — first-time clone will fail for users who copy-paste.

---

## 1. Goal & implementation

**What this project does:** A portable Claude Code customization kit — 10 specialist subagents and 2 slash commands — that installs via symlinks into `~/.claude/` so it follows the user across machines after a single `git clone` + `bash install.sh`.

**Main entry point, end-to-end:**

1. User clones the repo and runs `bash scripts/install.sh` (`scripts/install.sh:1`).
2. The script resolves `REPO_DIR` by dereferencing `BASH_SOURCE[0]` through any symlinks (`scripts/install.sh:13–15`).
3. For each `*.md` in `commands/` and `agents/`, `link_one()` creates a symlink at `~/.claude/commands/<name>` or `~/.claude/agents/<name>` (`scripts/install.sh:61–88`).
4. Claude Code loads `~/.claude/agents/*.md` at startup, making the agents available as subagents.
5. Claude Code loads `~/.claude/commands/*.md` as slash commands (`/audit`, `/release`).
6. At runtime: user invokes `/audit` → Claude executes `commands/audit.md` prompt inline → writes `AUDIT.md` to project root. Or user invokes an agent by name → Claude spawns it with its persona and tool list.

**README claims vs implementation:**

| Claim | Status |
|---|---|
| 10 agents listed in README table | Observed: all 10 `.md` files present with matching names |
| `/audit` and `/release` slash commands | Observed: both `commands/*.md` present |
| "symlink everything into `~/.claude`" | Observed: `install.sh` does exactly this |
| Roadmap: `evals/`, statistics specialist, security agent, GitHub Actions | Not present — correctly labeled as roadmap, not dead claims |

**Dead claim — observed:**

README line 82 documents `/release` as requiring no preconditions. `commands/release.md:26` requires `PROJECT_RULES.md` in the project root and halts if absent. No such file exists in this repo. Running `/release` on consilium itself would halt immediately. The README should note this prerequisite.

---

## 2. Inventory & stale items

| Path | Description | Recommendation |
|---|---|---|
| `agents/` (10 files) | Specialist subagent persona definitions | Keep |
| `commands/audit.md` | `/audit` slash command (8-section scientific audit) | Keep |
| `commands/release.md` | `/release` slash command (versioned release workflow) | Keep |
| `scripts/install.sh` | Idempotent symlink installer | Keep |
| `README.md` | Project documentation and onboarding | Keep (fix SSH URL) |
| `LICENSE` | MIT license | Keep |

**Stale / orphaned items:**

| Location | Issue |
|---|---|
| `scripts/install.sh:70–80` | `skills/` block — no `skills/` directory exists or is documented; ships as dead code. Harmless but misleading. |

No `*.bak`, `_old`, `_TEMP`, or empty directories found. No uncommitted working files (`git status` clean at HEAD `9f6b017`).

---

## 3. Reproducibility

**Install is reproducible** — no compiled artifacts, no deps, no seeds, no randomness. A fresh clone + `bash scripts/install.sh` yields the same symlink state.

**Observed issues:**

| Issue | Location | Severity |
|---|---|---|
| README install uses SSH URL (`git@github.com:dunyuliu/consilium.git`) | `README.md:32` | Medium — remote is configured as HTTPS; SSH clone will fail for users without SSH keys set up for this host |
| README prescribes clone path `~/consilium` | `README.md:32–33` | Low — `install.sh` self-locates correctly from any path; the prescribed path is convention, not a hardcoded requirement |
| No `PROJECT_RULES.md` in repo | repo root | Medium — `/release` halts and asks for this file; undocumented prerequisite |

---

## 4. Physics & numerics

**Not applicable.** This is a pure-text prompt and shell-script repo. No numeric variables, units, constants, conservation laws, or NaN risk.

---

## 5. Implementation consistency

**Agent frontmatter consistency — observed clean:**

All 10 agents carry `name`, `description`, `tools`, and `model` in frontmatter. All use `model: opus`. Tool lists are differentiated by role (e.g., `Agent` only for victor-reyes and elena-hartmann who spawn subagents; `WebFetch` for citation/research agents; read-only tools for auditors who don't fix).

**Cross-reference ambiguity — observed:**

| Location | Issue |
|---|---|
| `agents/victor-reyes.md:49` | `"follow the 8-section framework in commands/audit.md directly"` — bare relative path. When Victor runs as a subagent from `~/.claude/agents/`, `commands/audit.md` is not a standard relative path from that location. Victor has `Read` in his tool list, so he could read `~/.claude/commands/audit.md`, but the path in his instructions points nowhere obvious. Suspected: Victor resolves this by reading the symlinked file, but this is implicit and fragile. |
| `agents/victor-reyes.md:74` | Same reference in the inline-vs-spawn table |

**Routing consistency — observed clean:**

Elena's dispatch table (spawn victor-reyes for technical, mary-chen for citations) is consistent with Victor's decision tree. Victor's specialist list matches the 10 agents present. No agent is routed to a specialist that doesn't exist.

---

## 6. Logging & error handling

**Install script error handling — observed:**

| Behavior | Location | Assessment |
|---|---|---|
| `set -euo pipefail` at top | `scripts/install.sh:9` | Good — exits on any unhandled error |
| `symlink fails → prints ERROR to stderr, continues` | `scripts/install.sh:55` | Acceptable — single-file failure doesn't abort the batch |
| Real directory at target → `SKIP` (no overwrite) | `scripts/install.sh:42–45` | Good — protects existing user customizations |
| `--force` flag required to re-link to a different source | `scripts/install.sh:34–39` | Good — explicit opt-in for destructive re-link |

No runtime logging for the agents or commands themselves — they are prompts, not running processes. N/A.

---

## 7. Performance & scaling

**Not applicable.** The install script runs once and creates O(N) symlinks where N ≤ ~20. No IO bottlenecks, no memory scaling concerns.

---

## 8. Top priorities

Ranked by (impact × ease), each actionable in under 1 day:

| Rank | Finding | Action | Effort |
|---|---|---|---|
| 1 | README install URL is SSH; remote is HTTPS | Change `README.md:32` from `git@github.com:dunyuliu/consilium.git` to `https://github.com/dunyuliu/consilium.git` | 2 min |
| 2 | `/release` requires `PROJECT_RULES.md` — undocumented | Add one line to `README.md` commands table: "Requires `PROJECT_RULES.md` in project root." | 5 min |
| 3 | `scripts/install.sh:70–80` — dead `skills/` block | Remove the block, or create `skills/` and document it | 5 min |
| 4 | `victor-reyes.md:49,74` — ambiguous `commands/audit.md` path | Change to absolute reference `~/.claude/commands/audit.md`, or add a note that Victor should read it from that path | 10 min |
