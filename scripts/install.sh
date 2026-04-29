#!/bin/bash
# Symlink the commands/ and skills/ contents of this repo into the user's
# ~/.claude/. Idempotent — safe to re-run after `git pull` to pick up new
# files. Will not overwrite existing files or existing symlinks pointing
# elsewhere unless --force is passed.
set -eu

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CLAUDE_DIR="${HOME}/.claude"
FORCE=0
[ "${1:-}" = "--force" ] && FORCE=1

link_one() {
    src="$1"
    dst="$2"
    if [ -L "$dst" ]; then
        existing="$(readlink "$dst")"
        if [ "$existing" = "$src" ]; then
            echo "  ok   $dst (already linked)"
            return
        fi
        if [ "$FORCE" = 1 ]; then
            echo "  redo $dst (was --> $existing)"
            ln -sf "$src" "$dst"
            return
        fi
        echo "  SKIP $dst (different symlink target: $existing; use --force)"
        return
    fi
    if [ -e "$dst" ]; then
        if [ "$FORCE" = 1 ]; then
            echo "  redo $dst (was a regular file, replaced)"
            rm "$dst"
            ln -s "$src" "$dst"
            return
        fi
        echo "  SKIP $dst (regular file exists; use --force)"
        return
    fi
    ln -s "$src" "$dst"
    echo "  link $dst --> $src"
}

mkdir -p "$CLAUDE_DIR/commands" "$CLAUDE_DIR/skills"

if [ -d "$REPO_DIR/commands" ]; then
    echo "Linking commands:"
    for f in "$REPO_DIR/commands"/*.md; do
        [ -f "$f" ] || continue
        link_one "$f" "$CLAUDE_DIR/commands/$(basename "$f")"
    done
fi

if [ -d "$REPO_DIR/skills" ]; then
    echo "Linking skills:"
    for d in "$REPO_DIR/skills"/*/; do
        [ -d "$d" ] || continue
        name="$(basename "$d")"
        link_one "${d%/}" "$CLAUDE_DIR/skills/$name"
    done
fi

echo
echo "Done. Verify with:"
echo "  ls -la ~/.claude/commands/ ~/.claude/skills/"
