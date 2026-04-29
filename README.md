# workflow_for_claude_code

Personal Claude Code customizations: slash commands, skills, and audit
templates that follow you across machines.

## Layout

```
workflow_for_claude_code/
├── commands/             # custom slash commands (--> ~/.claude/commands/)
│   └── audit.md          #   /audit — scientific-computing project audit
├── skills/               # custom skills (--> ~/.claude/skills/)  [empty for now]
├── scripts/
│   └── install.sh        # symlink commands/skills into ~/.claude
└── README.md
```

## Install on a new machine

```bash
git clone git@github.com:dunyuliu/workflow_for_claude_code.git ~/workflow_for_claude_code
bash ~/workflow_for_claude_code/scripts/install.sh
```

`install.sh` creates symlinks from `~/.claude/commands/<name>.md` to the
files inside this repo, so editing a file here immediately reflects in
Claude Code, and `git pull` updates them.

## Commands

| Slash | What |
|---|---|
| `/audit` | Eight-section project audit tuned for scientific / numerical / data-pipeline projects. Writes `AUDIT.md` in the working dir. Sections: goal & implementation, inventory & stale, reproducibility, physics & numerics, implementation consistency, logging & errors, performance, top-N priorities. |
| `/release` | Version-bump release workflow. Triggers: `release` (patch), `release minor`, `release major`. Audits the project against `PROJECT_RULES.md`, archives old release notes to `docs/`, writes new `release_notes_v<X.Y.Z>.md` reconciled against the post-audit filesystem state, commits as `release: v<X.Y.Z> — <summary>`. Requires a `PROJECT_RULES.md` in the project root. |

## Adding a new command

1. Drop `commands/<name>.md` into this repo.
2. Run `bash scripts/install.sh` (idempotent — only creates missing links).
3. Commit and push.
4. On other machines: `git pull && bash scripts/install.sh`.

## Adding a skill

Place under `skills/<name>/SKILL.md` following the
[Claude skills format](https://docs.claude.com/skills). Then
`bash scripts/install.sh` to wire it into `~/.claude/skills/`.
