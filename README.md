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
├── delta-checker/          # Pre-commit delta auditor for typos, variable slips, and logic bugs
│   └── SKILL.md
├── ponytail/               # "Lazy senior dev" minimalism skill
│   └── SKILL.md
└── sid/                    # Hardware architecture and specification consultant
    ├── SKILL.md
    └── scripts/
        └── search-manuals.sh
```

---

## Skills

### `delta-checker`
* **Description**: Audits uncommitted workspace changes (staged and unstaged git diffs) using the "ponytail" lazy senior developer persona.
* **Checks**:
  - **Typos**: Misspelled identifiers, string keys, and parameters.
  - **Wrong Variable Usage**: Copy-paste slips (e.g., using `width` instead of `height`, loop index confusion, swapped arguments).
  - **Apparent Logic Bugs**: Inverted conditions, missing returns/awaits, off-by-one errors, unchecked nulls (evaluated statically without running code).
* **Output**: A direct list of issues caught, succinct drop-in fixes, and a 1–2 line disclosure of what was skipped and risks.

### `ponytail`
* **Description**: Lazy senior developer mode. Enforces minimal complete changes, strict YAGNI ("the best code is the code never written"), and transparent reporting of what was skipped or unverified.
* **Credits**: Adapted from the popular open-source repository [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) by Dietrich Gebert (licensed under MIT).

### `sid`
* **Description**: Hardware architecture and specification consultant. Uses local hardware manuals, datasheets, and specification documents to answer hardware queries, map software requirements to hardware mechanisms, and verify low-level interactions.
* **Key Features**:
  - **Workspace Setup**: Prompts for the manuals directory on first run and caches it in `.agents/sid.json`.
  - **Software-to-Hardware Mapping**: Explains the necessary hardware (e.g., interrupt controllers, CSRs, timers, MMIO), register offsets, bitfield layouts, and initialization order when building low-level software like OS dispatchers or device drivers.
  - **Hardware Deep Dive**: Demystifies magic registers, memory-mapped I/O, memory barriers/fences, and hardware/software responsibility boundaries.
  - **Strictly Read-Only**: Never meddles with or modifies workspace code files; acts purely as an architectural advisor.

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

> **Note**: Each script accepts an optional custom destination directory as its first argument (e.g., `./scripts/link-agy.sh /custom/path/skills`). Because directory symlinks are used, changes to existing skills take effect immediately without re-running the script. Re-run only when adding a new skill directory.

---

## Manual Setup

If you prefer to link skills manually or use workspace-specific linking:

### Symlink Globally

```bash
# Antigravity (agy)
mkdir -p ~/.gemini/config/skills
ln -sfn "$PWD/delta-checker" ~/.gemini/config/skills/delta-checker
ln -sfn "$PWD/ponytail" ~/.gemini/config/skills/ponytail
ln -sfn "$PWD/sid" ~/.gemini/config/skills/sid

# Claude Code
mkdir -p ~/.claude/skills
ln -sfn "$PWD/delta-checker" ~/.claude/skills/delta-checker
ln -sfn "$PWD/ponytail" ~/.claude/skills/ponytail
ln -sfn "$PWD/sid" ~/.claude/skills/sid

# Codex
mkdir -p ~/.codex/skills
ln -sfn "$PWD/delta-checker" ~/.codex/skills/delta-checker
ln -sfn "$PWD/ponytail" ~/.codex/skills/ponytail
ln -sfn "$PWD/sid" ~/.codex/skills/sid
```

### Workspace / Project-Specific Setup

To link a skill into an individual project workspace:

* **Antigravity / agy**:
  ```bash
  mkdir -p /path/to/project/.agents/skills
  ln -sfn /path/to/agent-skills/sid /path/to/project/.agents/skills/sid
  ```
* **Claude Code**:
  ```bash
  mkdir -p /path/to/project/.claude/skills
  ln -sfn /path/to/agent-skills/sid /path/to/project/.claude/skills/sid
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
