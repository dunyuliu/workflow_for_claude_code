#!/bin/bash
# Symlink the commands/, skills/, and agents/ contents of this repo into the
# user's ~/.claude/. Idempotent — safe to re-run after `git pull` to pick up
# new files. Will not overwrite existing symlinks pointing elsewhere unless
# --force is passed.
#
# Usage:
#   bash scripts/install.sh            # normal run
#   bash scripts/install.sh --force    # re-link even if target differs
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_DIR="${HOME}/.claude"
FORCE=0

case "${1:-}" in
    --force) FORCE=1 ;;
    "")      ;;
    *)       echo "Unknown argument: ${1}. Usage: $0 [--force]" >&2; exit 1 ;;
esac

link_one() {
    local src="$1" dst="$2"
    if [ -L "$dst" ]; then
        local existing
        existing="$(readlink "$dst")"
        if [ "$existing" = "$src" ]; then
            echo "  ok   $dst"
            return
        fi
        if [ "$FORCE" = 1 ]; then
            echo "  redo $dst (was --> $existing)"
            ln -sf "$src" "$dst"
            return
        fi
        echo "  SKIP $dst (points to $existing; use --force to update)"
        return
    fi
    if [ -d "$dst" ] && [ ! -L "$dst" ]; then
        echo "  SKIP $dst (real directory exists; refusing to replace)"
        return
    fi
    if [ -e "$dst" ]; then
        if [ "$FORCE" = 1 ]; then
            echo "  redo $dst (was a regular file)"
            rm "$dst"
        else
            echo "  SKIP $dst (regular file exists; use --force)"
            return
        fi
    fi
    ln -s "$src" "$dst" || { echo "  ERROR: failed to create symlink $dst --> $src" >&2; return 1; }
    echo "  link $dst --> $src"
}

mkdir -p "$CLAUDE_DIR/commands" "$CLAUDE_DIR/skills" "$CLAUDE_DIR/agents"

# Use nullglob so empty directories produce no iterations (not a literal "*.md").
shopt -s nullglob

if [ -d "$REPO_DIR/commands" ]; then
    echo "Linking commands:"
    linked=0
    for f in "$REPO_DIR/commands"/*.md; do
        link_one "$f" "$CLAUDE_DIR/commands/$(basename "$f")"
        linked=$((linked + 1))
    done
    [ "$linked" -eq 0 ] && echo "  (none found)"
fi

if [ -d "$REPO_DIR/skills" ]; then
    echo "Linking skills:"
    linked=0
    for d in "$REPO_DIR/skills"/*/; do
        [ -d "$d" ] || continue
        name="$(basename "$d")"
        link_one "${d%/}" "$CLAUDE_DIR/skills/$name"
        linked=$((linked + 1))
    done
    [ "$linked" -eq 0 ] && echo "  (none found)"
fi

if [ -d "$REPO_DIR/agents" ]; then
    echo "Linking agents:"
    linked=0
    for f in "$REPO_DIR/agents"/*.md; do
        link_one "$f" "$CLAUDE_DIR/agents/$(basename "$f")"
        linked=$((linked + 1))
    done
    [ "$linked" -eq 0 ] && echo "  (none found)"
fi

echo
echo "Done. Verify with:"
echo "  ls -la ~/.claude/commands/ ~/.claude/skills/ ~/.claude/agents/"
