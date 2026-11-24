# Agent Skills for Claude Code

A centralized repository for storing and managing custom agent skills for **Claude Code**.

Skills are structured knowledge packages containing instructions, runbooks, or behavioral guidelines following the [Agent Skills specification](https://agentskills.io/specification) that Claude Code loads on demand. Skills that orchestrate subagents use the `scout`, `planner`, `worker` and `reviewer` agents and the saved workflows from the dotfiles repo (`~/.claude/agents`, `~/.claude/workflows`).

---

## Skills

### `brainstorming`
* **Description**: Explores ideas, requirements, and technical trade-offs through collaborative dialogue to produce validated design documents before writing code.
* **Key Principles**:
  - **Context-First**: Checks existing project state, repository files, and recent commits first.
  - **One Question at a Time**: Asks focused questions iteratively (preferring multiple-choice) to clarify purpose, constraints, and success criteria without overwhelming the user.
  - **Explore Alternatives**: Proposes 2–3 technical approaches with trade-offs and recommendations before settling on a design.
  - **Incremental Validation**: Breaks the design into 200–300 word sections, confirming each part before proceeding.
  - **Design Documentation**: Records the finalized design in `/tmp/brainstorming-<topic>-design.md` (or `/tmp/plans/YYYY-MM-DD-<topic>-design.md`) to avoid repo clutter. Follows strict git safety: prompts the user before copying or committing the plan into the repository.
* **Credits**: Adapted from the open-source repository [obra/superpowers](https://github.com/obra/superpowers) by Jesse Vincent (licensed under MIT).

### `delta-checker`
* **Description**: Audits uncommitted workspace changes (staged and unstaged git diffs) using the "ogur" lazy senior developer persona. Dispatches the isolated `reviewer` subagent to keep large diffs out of the main session context.
* **Checks**:
  - **Typos**: Misspelled identifiers, string keys, and parameters.
  - **Wrong Variable Usage**: Copy-paste slips (e.g., using `width` instead of `height`, loop index confusion, swapped arguments).
  - **Apparent Logic Bugs**: Inverted conditions, missing returns/awaits, off-by-one errors, unchecked nulls (evaluated statically without running code).
* **Output**: A direct list of issues caught, succinct drop-in fixes, and a 1–2 line disclosure of what was skipped and risks.

### `garv`
* **Description**: Adversarial test writer and bug hunter. Runs the saved `garv` workflow: a 4-stage subagent pipeline (`scout` -> `planner` -> `worker` -> `reviewer` as referee) with an automated disqualification retry loop to write clean, minimalist tests exclusively within test directories using the `ogur` philosophy to expose real bugs, regressions, edge-case crashes, and security vulnerabilities without polluting conversation context.
* **Key Features**:
  - **Context-Preserving Subagent Chain**: Executes the entire bug hunt in isolated subagent context windows (`scout` -> `planner` -> `worker` -> `reviewer`), returning only the final certified report to the primary conversation.
  - **Calibrated Reasoning Effort**: Each agent carries its own model and effort: `scout` (haiku, low) for reconnaissance, `planner` (opus, xhigh) for adversarial design, `worker` (sonnet, medium) for writing and running tests, `reviewer` (opus, xhigh) for referee verification.
  - **Bug Bounty Reward System**: Earns points across severity categories (+100 critical/vulnerability, +50 crash/panic/deadlock, +25 logic/desync, +15 protocol mismatch) to climb hunter ranks (Scout to Master Bug Hunter). Passing tests earn 0 points—bounties are awarded strictly for legitimate defects found.
  - **Strict Blast Radius**: Pure test directory confinement (`tests/`, `test/`, `spec/`, etc.). Strictly prohibited from touching application or production code.
  - **Absolute Legitimacy**: Zero tolerance for faked test failures or uncontracted expectations. Every failure must be a genuine defect against specifications or docstrings.
  - **Independent Referee Audit & Automated Retry Loop**: Dispatches `reviewer` as Referee at the end of each run to audit legitimacy and blast radius. If disqualified, invalid files are reverted and the orchestrator automatically re-dispatches the chain with corrective feedback (up to 2 retries) before presenting the final certified findings.

### `ogur`
* **Description**: Lazy senior developer mode (adapted from the ponytail philosophy). Enforces minimal complete changes, strict YAGNI ("the best code is the code never written"), and transparent reporting of what was skipped or unverified.
* **Credits**: Adapted from the popular open-source repository [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) by Dietrich Gebert (licensed under MIT).

### `sid`
* **Description**: Hardware architecture and specification consultant. Uses local hardware manuals, datasheets, and specification documents to answer hardware queries, map software requirements to hardware mechanisms, and verify low-level interactions.
* **Key Features**:
  - **Hardware Manuals Discovery**: Automatically discovers manuals in user library directories (such as `~/Documents/hardware`), common project paths (`./manuals`, `./docs/hardware`, `./specs`), global configuration (`~/.claude/sid.json`), or workspace settings (`.claude/sid.json`, `.sid.json`).
  - **Context-Preserving Scout Delegation**: Dispatches the `scout` subagent to search large hardware PDFs and datasheets via `pdftotext` or helper scripts, returning clean, condensed facts without bloating the conversation context.
  - **Software-to-Hardware Mapping**: Explains the necessary hardware (e.g., interrupt controllers, CSRs, timers, MMIO), register offsets, bitfield layouts, and initialization order when building low-level software like OS dispatchers or device drivers.
  - **Hardware Deep Dive**: Demystifies magic registers, memory-mapped I/O, memory barriers/fences, and hardware/software responsibility boundaries.
  - **Mandatory Source Citations**: Strictly cites source references (manual filename, section, and PDF page numbers or line numbers) for every detail to guarantee verifiable, hallucination-free guidance.
  - **Strictly Read-Only**: Never meddles with or modifies workspace code files; acts purely as an architectural advisor.

---

## Setup

Symlink every skill into `~/.claude/skills/` (or a directory given as the first argument):

```bash
./scripts/link-claude.sh
```

Directory symlinks mean edits take effect immediately; re-run only when adding a new skill. For a single project, link into `<project>/.claude/skills/` instead.

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
3. Run `./scripts/link-claude.sh` to link it into Claude Code.

---

## License

This repository is licensed under the [MIT License](LICENSE).
Credit for the `brainstorming` skill belongs to [obra/superpowers](https://github.com/obra/superpowers) by Jesse Vincent.
Credit for the `ogur` (adapted from ponytail) skill belongs to [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail).
