#!/bin/bash
# Symlink the commands/ and agents/ contents of this repo into ~/.claude/.
# Idempotent — safe to re-run after `git pull`. Will not overwrite existing
# symlinks pointing elsewhere unless --force is passed.
#
# Usage:
#   bash scripts/install.sh            # normal run
#   bash scripts/install.sh --force    # re-link even if target differs
set -euo pipefail
shopt -s nullglob   # globs that match nothing produce zero iterations, not a literal string

# Resolve the real repo root even if this script is invoked via a symlink.
_script="${BASH_SOURCE[0]}"
while [ -L "$_script" ]; do _script="$(readlink "$_script")"; done
REPO_DIR="$(cd "$(dirname "$_script")/.." && pwd)"
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
            return 0
        fi
        if [ "$FORCE" = 1 ]; then
            echo "  redo $dst (was --> $existing)"
            ln -sf "$src" "$dst"
            return 0
        fi
        echo "  SKIP $dst (points to $existing; use --force to update)"
        return 0
    fi
    if [ -d "$dst" ] && [ ! -L "$dst" ]; then
        echo "  SKIP $dst (real directory exists; refusing to replace)"
        return 0
    fi
    if [ -e "$dst" ]; then
        if [ "$FORCE" = 1 ]; then
            echo "  redo $dst (was a regular file)"
            rm "$dst" || { echo "  ERROR: cannot remove $dst" >&2; return 1; }
        else
            echo "  SKIP $dst (regular file exists; use --force)"
            return 0
        fi
    fi
    ln -s "$src" "$dst" || { echo "  ERROR: failed to create symlink $dst --> $src" >&2; return 1; }
    echo "  link $dst --> $src"
}

mkdir -p "$CLAUDE_DIR/commands" "$CLAUDE_DIR/agents"

if [ -d "$REPO_DIR/commands" ]; then
    echo "Linking commands:"
    linked=0
    for f in "$REPO_DIR/commands"/*.md; do
        link_one "$f" "$CLAUDE_DIR/commands/$(basename "$f")" && linked=$((linked + 1))
    done
    [ "$linked" -eq 0 ] && echo "  (none found)"
fi

if [ -d "$REPO_DIR/agents" ]; then
    echo "Linking agents:"
    linked=0
    for f in "$REPO_DIR/agents"/*.md; do
        link_one "$f" "$CLAUDE_DIR/agents/$(basename "$f")" && linked=$((linked + 1))
    done
    [ "$linked" -eq 0 ] && echo "  (none found)"
fi

echo
echo "Done. Verify with:"
echo "  ls -la ~/.claude/commands/ ~/.claude/agents/"
