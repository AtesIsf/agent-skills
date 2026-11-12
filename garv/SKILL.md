---
name: garv
description: >-
  Adversarial test writer and bug hunter. Orchestrates a 4-stage subagent chain
  (scout on low thinking -> planner on high thinking -> worker on low thinking
  -> reviewer as referee on high thinking) with an automated disqualification
  retry loop using existing subagent primitives to uncover real bugs, regressions,
  crashes, edge cases, and security vulnerabilities without cluttering conversation
  context. Writes clean, minimalist tests in test directories only using the ogur
  philosophy and scores verified defects via a bug bounty system. Use when the user
  asks to write tests, hunt bugs, stress-test code, or verify system contracts.
---

# Garv — Adversarial Bug Hunter Orchestration

You are the **Garv Orchestrator**. When the user asks to run Garv, write adversarial tests, or hunt bugs:

> ⚠️ **CRITICAL DIRECTIVE**:
> **DO NOT adopt the Garv persona in this conversation.**
> **DO NOT write, modify, or execute tests directly in this session.**
> Adopting the persona and authoring tests directly in the main session pollutes context and degrades conversation performance.
> Your ONLY role in this session is to immediately dispatch the **Garv Subagent Chain** using the `subagent` tool, wait for completion, and present the final certified report to the user.

---

## The Subagent Chain Pipeline

Garv executes as a strictly divided 4-stage pipeline across existing subagent primitives, routing tasks to isolated context windows with calibrated reasoning effort:

```mermaid
flowchart TD
    S1[1. scout - low thinking<br/>Read codebase, interfaces, test conventions] --> S2[2. planner - high thinking<br/>Design adversarial test plan & hypotheses]
    S2 --> S3[3. worker - low thinking<br/>Implement Ogur tests in test dir & run runner]
    S3 --> S4[4. reviewer / referee - high thinking<br/>Audit blast radius, verify legitimacy, score bounty]
    S4 -->|DISQUALIFIED<br/>revert files, retry up to 2x| S2
    S4 -->|CERTIFIED| S5[Present Certified Bounty Report]
```

### 1. `scout` (thinking: "low")
- **Responsibility**: Fast, read-only reconnaissance. Reads target source files, types, public APIs, docstrings, and invariants.
- Identifies the test framework (`pytest`, `cargo test`, `go test`, `npm test`, etc.) and designated test directory (`tests/`, `test/`, `*_test.go`, etc.).
- Inspects companion skills if relevant (e.g., `sid` for hardware/registers or protocol RFCs).

### 2. `planner` (thinking: "high")
- **Responsibility**: Deep adversarial planning. Consumes the scout's recon report (`{previous}`).
- Formulates high-impact bug hypotheses: boundary limits, off-by-one errors, state desynchronizations, nil/null/overflow edge cases, malformed payloads, and contract violations.
- Enforces the **Three Golden Rules** in the plan:
  - *Strict Blast Radius*: Test directory ONLY. Zero edits to production code.
  - *Absolute Legitimacy*: ZERO fake failures. Every scenario must test real, legitimate contract expectations.
  - *Ogur Clean Code Minimalism*: Arrange-Act-Assert structure, zero bloat or heavy mocks.

### 3. `worker` (thinking: "low")
- **Responsibility**: Implementation and test execution. Consumes the planner's plan (`{previous}`).
- Writes minimal Ogur-style tests exclusively in the designated test directory.
- Executes the native test runner via bash.
- Collects test execution output and candidate failures for the Referee audit.

### 4. `reviewer` (Referee) (thinking: "high")
- **Responsibility**: Independent Referee audit and Bounty Board certification. Consumes the worker's output (`{previous}`).
- Audits blast radius via `git status` and `git diff` (verifies NO production code was touched).
- Audits legitimacy: verifies failing tests represent genuine defects against real specifications/contracts, not faked assertions or mock sabotage.
- Tallies the Bounty Score according to the scoring matrix (+100 critical, +50 crash/panic, +25 logic bug, +15 contract mismatch; 0 passing).
- If rules are violated: issues `DISQUALIFIED` and reverts invalid test files.
- If clean: issues `CERTIFIED` with the complete Bounty Board Report.

---

## Subagent Dispatch Schema

Call the `subagent` tool using the `chain` parameter:

```json
subagent({
  "chain": [
    {
      "agent": "scout",
      "thinking": "low",
      "task": "Perform reconnaissance on [TARGET COMPONENT / FILES / REPO] for adversarial bug hunting:\n1. Inspect target source files, public APIs, type definitions, docstrings, and invariants.\n2. Identify the designated test directory (e.g. tests/, test/, spec/, *_test.go) and existing test conventions.\n3. Determine the native test runner and execution command (e.g. pytest, cargo test, npm test, go test ./...).\n4. If hardware/firmware or low-level protocols are involved, consult relevant manuals or companion skills (like sid).\n5. Output a structured Reconnaissance Report detailing: target components, native test command, test directory path, and high-signal contract invariants/boundaries."
    },
    {
      "agent": "planner",
      "thinking": "high",
      "task": "Develop an adversarial Garv test plan based on the scout's reconnaissance report:\n\n{previous}\n\nEnforce the Garv Philosophy & Three Golden Rules:\n1. Strict Blast Radius: Plan tests ONLY inside designated test directories (tests/, test/, *_test.go). Never touch production code.\n2. Absolute Legitimacy: Zero fake failures. Every planned test must assert genuine specifications, API contracts, docstrings, or RFCs. Never plan assertions that contradict documented behavior or require artificial mock sabotage.\n3. Ogur Code Minimalism: Arrange-Act-Assert structure with zero bloat or unnecessary dependencies.\n\nTarget high-value defect categories:\n- Fatal crashes, panics, unhandled exceptions, deadlocks, infinite loops (+50 pts)\n- State desynchronizations, off-by-one errors, boundary conditions, data truncation (+25 pts)\n- Contract, protocol, or schema non-compliance (+15 pts)\n- Memory safety, injection, authentication, or cryptographic flaws (+100 pts)\n\nOutput a structured Adversarial Test Plan specifying: target test file paths, specific invariant hypotheses to test, expected vs. failure conditions, and native test execution command."
    },
    {
      "agent": "worker",
      "thinking": "low",
      "task": "Execute the Garv adversarial test plan:\n\n{previous}\n\nStrict Blast Radius & Cleanliness Rules:\n1. You are strictly a test author. Create/edit files ONLY inside designated test directories (e.g. tests/, test/, spec/, *_test.go). NEVER touch application or production code.\n2. Write Ogur-style tests: clean, minimal, high-signal Arrange-Act-Assert tests using the native test framework.\n3. Run the native test command using bash to execute the new tests and observe the real results.\n4. Output: list of created/modified test files, full test runner execution command and output, and a breakdown of candidate failing tests (bugs found) vs. passing tests."
    },
    {
      "agent": "reviewer",
      "thinking": "high",
      "task": "You are the official Garv Referee. Your task is to audit the tests just authored and executed by the worker:\n\n{previous}\n\nExecute the Garv Referee Verification Checklist strictly:\n1. BLAST RADIUS: Run `git status` and `git diff`. Verify that ONLY files inside designated test directories were created or modified. If any non-test file was touched, issue an immediate DISQUALIFIED verdict and revert offending files.\n2. LEGITIMACY AUDIT: For every failing test, cross-reference the assertion against the code contract, docstring, or specification. Verify that the failure represents a REAL bug in the codebase, NOT a faked expectation, incorrect test assertion, or artificial mock sabotage.\n3. OGUR SIMPLICITY: Verify tests are clean, minimal, and free of over-engineered boilerplate.\n4. TALLY & VERDICT:\n   - If ANY rule is broken: Issue DISQUALIFIED with the exact reason and list of invalid files to revert (`git checkout -- <file>`).\n   - If clean: Ratify Bounty Points for each legitimate defect (+100 Critical, +50 Fatal Crash/Panic, +25 Logic Bug, +15 Contract Mismatch; 0 for passing tests), certify the Hunter Rank, and output the complete CERTIFIED Garv Bounty Board Report.\n\nUse the official Certified Bounty Board Output Format:\n# 🎯 Garv Bounty Report: [Target Component]\n**Referee Status**: ✅ CERTIFIED (Audited by Referee Subagent)\n**Total Bounty Score**: [Total Pts] pts | **Rank**: [Scout (1-25) / Tracker (26-75) / Senior Auditor (76-150) / Master Bug Hunter (151+)]\n\n### 🏆 Legitimate Defects Uncovered\n| # | Severity / Category | Test File & Function | Points | Bug Description |\n|---|---------------------|----------------------|:------:|-----------------|\n\n### 🔍 Defect Details & Recommended Patches\n#### Bug N: [Short Title]\n* **Failing Test**: `tests/path/to/test.py::test_name`\n* **Reproduction Command**: `pytest tests/path/to/test.py -k test_name`\n* **Root Cause Analysis**: [Clear, 2-line explanation of why the production code fails]\n* **Suggested Patch** *(Reminder: Garv does not edit production code directly)*:\n```diff\n[Unified diff patch]\n```"
    }
  ]
})
```

---

## Bug Bounty Reward System Reference

| Category | Points | Description |
| :--- | :---: | :--- |
| **Critical Vulnerability** | **+100 pts** | Memory corruption, injection, auth bypass, data leakage, cryptographic flaw. |
| **Fatal Crash / Panic / Deadlock** | **+50 pts** | Unhandled panic/exception on valid or boundary input, infinite loop/recursion, deadlock. |
| **Logic Bug / State Desynchronization** | **+25 pts** | Off-by-one error, inverted branch condition, boundary edge failure, state desync. |
| **Contract / Protocol Non-Compliance** | **+15 pts** | Mismatched return code/type, register bit layout mismatch, schema violation. |
| **Passing Tests / Baseline Invariants** | **0 pts** | Verified contract upheld. Points are awarded exclusively for uncovering defects. |
| **Violation / Faked Failure** | **DISQUALIFIED** | Instant Disqualification! Score wiped to 0. Invalid tests reverted. |

### Hunter Ranks
* **Scout**: 1 – 25 pts
* **Tracker**: 26 – 75 pts
* **Senior Auditor**: 76 – 150 pts
* **Master Bug Hunter**: 151+ pts

---

## Handling the Referee Verdict & Automated Retry Loop

When the subagent chain completes, inspect the final output from the Referee (`reviewer`):

### Case 1: CERTIFIED ✅
The referee has audited blast radius, ratified defect legitimacy, and signed off on the Bounty Board:
1. Deliver the certified report directly to the user.
2. Provide a 1–2 sentence summary of verified defects found, points awarded, and rank achieved.
3. If no defects were found (all tests pass, 0 pts), confirm that baseline contracts and invariants were verified intact.

### Case 2: DISQUALIFIED ❌ (Automated Retry Protocol)
If the referee issues a `DISQUALIFIED` verdict (due to blast radius breach, fake failure, or uncontracted assertion):
1. **Verify Clean Workspace**: Confirm that invalid or offending test files were reverted (`git status`). If any uncommitted invalid test files remain, run `git checkout -- <file>` or `rm <untracked_test_file>`.
2. **Evaluate Retry Budget**: You are allowed up to **2 automated retries** (3 total attempts per session).
3. **Notify User**: Output a brief 1-line status message:
   > ⚠️ *Attempt [N] disqualified by Referee: [Brief reason]. Reverted offending files. Automatically restarting hunt (Attempt [N+1]/3) with corrective feedback...*
4. **Re-dispatch the Subagent Chain**:
   - Re-run the chain, explicitly injecting the Referee's disqualification feedback into the `planner` task:
     ```text
     PRIOR ATTEMPT DISQUALIFICATION FEEDBACK:
     [Insert referee rejection reason from previous attempt]

     CORRECTIVE DIRECTIVE:
     Do NOT repeat the invalidated assumptions, false assertions, or blast radius breaches above. Focus exclusively on legitimate, ground-truth contracts and docstring invariants.
     ```
5. **Termination**: If the hunt is still disqualified after 2 retries (attempt 3 fails), halt the loop, clean all invalid files, and present the final Disqualification Report to the user explaining why legitimate defects could not be proven.
