#!/usr/bin/env bash
set -euo pipefail

QUERY="${1:-}"
TARGET_DIR="${2:-}"

if [ -z "$QUERY" ]; then
  echo "Usage: $0 <search-term> [manuals-directory]" >&2
  exit 1
fi

# Detect manuals directory from .agents/sid.json if not passed
if [ -z "$TARGET_DIR" ]; then
  if [ -f ".agents/sid.json" ]; then
    TARGET_DIR=$(grep -o '"manuals_dir"[^:]*:[^"]*"[^"]*"' .agents/sid.json | cut -d'"' -f4)
  elif [ -f ".sid.json" ]; then
    TARGET_DIR=$(grep -o '"manuals_dir"[^:]*:[^"]*"[^"]*"' .sid.json | cut -d'"' -f4)
  elif [ -f "$HOME/.agents/sid.json" ]; then
    TARGET_DIR=$(grep -o '"manuals_dir"[^:]*:[^"]*"[^"]*"' "$HOME/.agents/sid.json" | cut -d'"' -f4)
  elif [ -d "manuals" ]; then
    TARGET_DIR="manuals"
  elif [ -d "docs/hardware" ]; then
    TARGET_DIR="docs/hardware"
  elif [ -d "$HOME/Documents/hardware" ]; then
    TARGET_DIR="$HOME/Documents/hardware"
  else
    echo "Error: Manuals directory not provided and not found in .agents/sid.json" >&2
    exit 1
  fi
fi

if [ ! -d "$TARGET_DIR" ]; then
  echo "Error: Directory '$TARGET_DIR' does not exist." >&2
  exit 1
fi

echo "=== Searching text files in $TARGET_DIR for '$QUERY' ==="
grep -rIn --color=never -E "$QUERY" \
  --include="*.txt" --include="*.md" --include="*.h" --include="*.c" --include="*.rst" --include="*.json" \
  "$TARGET_DIR" 2>/dev/null || true

echo ""
echo "=== Searching PDF files in $TARGET_DIR for '$QUERY' ==="
if command -v pdftotext >/dev/null 2>&1; then
  find "$TARGET_DIR" -type f -name "*.pdf" | while read -r pdf; do
    matches=$(pdftotext "$pdf" - 2>/dev/null | awk -v RS='\f' -v q="$QUERY" '
      BEGIN { q_lower = tolower(q) }
      tolower($0) ~ q_lower {
        n = split($0, lines, "\n")
        for (i = 1; i <= n; i++) {
          if (tolower(lines[i]) ~ q_lower) {
            print "  [Page " NR "] " lines[i]
          }
        }
      }
    ' || true)
    if [ -n "$matches" ]; then
      echo "--- Matches in $pdf ---"
      echo "$matches" | head -n 30
      echo ""
    fi
  done
else
  echo "pdftotext not installed; skipping PDF search."
fi
