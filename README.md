# Agent Skills

A centralized repository for storing and managing custom AI agent skills across different coding assistants and agent providers.

Skills are structured knowledge packages containing instructions, runbooks, or behavioral guidelines that an AI agent loads progressively on demand.

---

## Repository Structure

```text
agent-skills/
├── LICENSE                 # MIT License
├── README.md               # Repository documentation and setup instructions
├── scripts/                # Provider-specific linking scripts
│   ├── link-agy.sh         # Google Antigravity (agy)
│   ├── link-claude.sh      # Claude Code
│   └── link-codex.sh       # OpenAI Codex
├── ponytail/               # Ponytail skill
│   └── SKILL.md
└── thought-partner/        # Scaffolding for thought-partner skill
    └── SKILL.md
```

---

## Skills

### `ponytail`
* **Description**: Lazy senior developer mode. Enforces minimal complete changes, strict YAGNI ("the best code is the code never written"), and transparent reporting of what was skipped or unverified.
* **Credits**: Adapted from the popular open-source repository [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) by Dietrich Gebert (licensed under MIT).

### `thought-partner`
* **Description**: Minimal scaffolding for the `thought-partner` skill (unconfigured / ready for custom definition).

---

## Global Setup (Provider-Specific Scripts)

Executable scripts are provided in `scripts/` to create symbolic links in the global configuration directories of supported agent providers:

### 1. Antigravity / agy (`link-agy.sh`)
Links skills to `~/.gemini/config/skills/`:
```bash
./scripts/link-agy.sh
```

### 2. Claude Code (`link-claude.sh`)
Links skills to `~/.claude/skills/`:
```bash
./scripts/link-claude.sh
```

### 3. OpenAI Codex (`link-codex.sh`)
Links skills to `~/.codex/skills/`:
```bash
./scripts/link-codex.sh
```

> **Note**: Each script accepts an optional custom destination directory as its first argument (e.g., `./scripts/link-agy.sh /custom/path/skills`).

---

## Manual Setup

If you prefer to link skills manually or use workspace-specific linking:

### Symlink Globally

```bash
# Antigravity (agy)
mkdir -p ~/.gemini/config/skills
ln -sfn "$PWD/ponytail" ~/.gemini/config/skills/ponytail
ln -sfn "$PWD/thought-partner" ~/.gemini/config/skills/thought-partner

# Claude Code
mkdir -p ~/.claude/skills
ln -sfn "$PWD/ponytail" ~/.claude/skills/ponytail
ln -sfn "$PWD/thought-partner" ~/.claude/skills/thought-partner

# Codex
mkdir -p ~/.codex/skills
ln -sfn "$PWD/ponytail" ~/.codex/skills/ponytail
ln -sfn "$PWD/thought-partner" ~/.codex/skills/thought-partner
```

### Workspace / Project-Specific Setup

To link a skill into an individual project workspace:

* **Antigravity / agy**:
  ```bash
  mkdir -p /path/to/project/.agents/skills
  ln -sfn /path/to/agent-skills/ponytail /path/to/project/.agents/skills/ponytail
  ```
* **Claude Code**:
  ```bash
  mkdir -p /path/to/project/.claude/skills
  ln -sfn /path/to/agent-skills/ponytail /path/to/project/.claude/skills/ponytail
  ```

---

## Adding a New Skill

1. Create a directory for your skill:
   ```bash
   mkdir my-new-skill
   ```
2. Add a `SKILL.md` with YAML frontmatter:
   ```markdown
   ---
   name: my-new-skill
   description: >-
     When the agent should use this skill.
   ---

   # My New Skill
   ```
3. Run the provider script (e.g., `./scripts/link-agy.sh`) to link the new skill.

---

## License

This repository is licensed under the [MIT License](LICENSE).
Credit for the `ponytail` skill belongs to [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail).
