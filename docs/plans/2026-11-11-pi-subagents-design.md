# Pi Subagents Architecture & Integration Design

- **Date**: 2026-11-11
- **Status**: Validated & Approved
- **Target**: Global Pi configuration (`~/.pi/agent/`) and `agent-skills` repository

---

## 1. Overview & Objectives

Integrate multi-agent delegation into the Pi coding agent harness by installing the reference subagent extension, deploying a versatile 4-agent standard roster (`scout`, `planner`, `reviewer`, `worker`), configuring `vim` as the default external editor, and updating `agent-skills` (specifically `garv`) to invoke subagents using Pi's native `{ agent, task }` schema.

---

## 2. Directory Layout & Architecture

```
~/.pi/agent/
├── settings.json           # Updated with "externalEditor": "vim"
├── extensions/
│   └── subagent/
│       ├── index.ts        # Subagent orchestrator & process manager
│       └── agents.ts       # Agent configuration & discovery parser
├── agents/                 # The 4 standard subagent archetypes
│   ├── scout.md            # Reconnaissance & doc search (read, bash)
│   ├── planner.md          # Architectural planning (read)
│   ├── reviewer.md         # Diff review & Garv referee audits (read, bash)
│   └── worker.md           # General execution & implementation (all tools)
├── prompts/                # Chained multi-agent workflow templates
│   ├── implement.md        # scout -> planner -> worker pipeline
│   └── review.md           # worker -> reviewer loop
└── skills/                 # Global symlinks to agent-skills repository
```

---

## 3. Configuration Details

### A. Global Settings (`~/.pi/agent/settings.json`)
Set `vim` as the external editor so pressing `Ctrl+G` in the interactive TUI opens prompts in `vim`:
```json
{
  "externalEditor": "vim",
  "packages": [
    "npm:@cortexkit/pi-antigravity-auth"
  ],
  "lastChangelogVersion": "1.5.2"
}
```

### B. Subagent Archetype Profiles (`~/.pi/agent/agents/`)

1. **`scout.md`**:
   - **Tools**: `read`, `bash`
   - **System Prompt**: Fast reconnaissance, locating relevant code patterns, and scanning external references or hardware datasheets (e.g., using the `sid` skill). Compresses findings into concise context.
2. **`planner.md`**:
   - **Tools**: `read`
   - **System Prompt**: Generates step-by-step implementation blueprints, risk assessments, and architectural plans. Strictly read-only.
3. **`reviewer.md`**:
   - **Tools**: `read`, `bash`
   - **System Prompt**: Rigorous code reviewer and test auditor. Specializes in auditing `git diff`, evaluating invariants, and executing the **Garv Referee Protocol** (verifying test directory blast radius, test legitimacy, and issuing `CERTIFIED` or `DISQUALIFIED` verdicts). Strictly read-only.
4. **`worker.md`**:
   - **Tools**: `read`, `bash`, `edit`, `write`
   - **System Prompt**: Full-capability generalist agent responsible for implementing features, fixing bugs, and writing tests.

---

## 4. Skill Interoperability & Garv Integration

### Skill Accessibility
Because child subagents spawn as native `pi` headless processes (`pi -p --mode json ...`), they automatically discover all skills in `~/.pi/agent/skills/`.

### Garv Updates
Update `garv/SKILL.md` to replace pseudo-code delegation examples with Pi's standard `subagent` tool schema:
- **Referee Audit**:
  ```json
  subagent({
    "agent": "reviewer",
    "task": "You are the official Garv Referee. Audit the tests just written: 1. BLAST RADIUS: Verify only files in test directories were touched. 2. LEGITIMACY: Verify failing tests represent real defects against specifications. 3. OGUR: Verify simplicity. 4. VERDICT: Issue CERTIFIED or DISQUALIFIED."
  })
  ```
- **Hardware Specs (`sid`)**:
  ```json
  subagent({
    "agent": "scout",
    "task": "Use the sid skill to look up register offsets and bitfield definitions for [Subsystem]."
  })
  ```

---

## 5. Verification & Rollout Plan

1. Deploy extension files to `~/.pi/agent/extensions/subagent/`.
2. Deploy the 4 agent definitions to `~/.pi/agent/agents/`.
3. Deploy workflow prompt templates to `~/.pi/agent/prompts/`.
4. Update `~/.pi/agent/settings.json` with `"externalEditor": "vim"`.
5. Update `garv/SKILL.md` in this repository.
6. Verify subagent execution with a smoke test.
