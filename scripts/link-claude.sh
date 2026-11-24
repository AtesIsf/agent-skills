#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="${1:-$HOME/.claude/skills}"

mkdir -p "$TARGET_DIR"
for skill_dir in "$REPO_ROOT"/*/; do
  if [ -f "$skill_dir/SKILL.md" ]; then
    name="$(basename "$skill_dir")"
    ln -sfn "${skill_dir%/}" "$TARGET_DIR/$name"
    echo "  ✔ $name -> $TARGET_DIR/$name"
  fi
done
echo "Done. New skills appear in the next Claude Code session."
