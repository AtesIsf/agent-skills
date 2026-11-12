#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PI_AGENT_DIR="${PI_CODING_AGENT_DIR:-$HOME/.pi/agent}"
TARGET_DIR="${1:-$PI_AGENT_DIR/skills}"

mkdir -p "$TARGET_DIR"

echo "Linking skills to Pi [$TARGET_DIR]..."

for skill_dir in "$REPO_ROOT"/*/; do
  if [ -f "$skill_dir/SKILL.md" ]; then
    skill_name="$(basename "$skill_dir")"
    ln -sfn "$skill_dir" "$TARGET_DIR/$skill_name"
    echo "  ✔ Linked $skill_name -> $TARGET_DIR/$skill_name"
  fi
done

echo "Done! Pi skills are linked."
echo "Tip: Run '/reload' in an active Pi session to pick up new skills, or invoke via '/skill:<name>'."
