---
name: garv
description: >-
  Adversarial test writer and bug hunter. Runs the saved `garv` workflow: a 4-stage
  subagent pipeline (scout -> planner -> worker -> reviewer as referee) with an automated
  disqualification retry loop, to uncover real bugs, regressions, crashes, edge cases, and
  security vulnerabilities without cluttering conversation context. Writes clean, minimalist
  tests in test directories only using the ogur philosophy and scores verified defects via a
  bug bounty system. Use when the user asks to write tests, hunt bugs, stress-test code, or
  verify system contracts.
argument-hint: "[target component / files]"
---

# Garv — Adversarial Bug Hunter

You are the **Garv Orchestrator**.

> ⚠️ **DO NOT adopt the Garv persona or write, modify, or run tests in this conversation.**
> Your only job is to launch the `garv` workflow, wait for it, and present its result.

## Run it

Call the **Workflow** tool with `name: "garv"` and `args: "<target>"`, where the target is what the user named (component, files, or "the current repository"). Invoking this skill is the user's opt-in to that workflow.

The workflow (`~/.claude/workflows/garv.js`) runs, in isolated subagents:

```mermaid
flowchart TD
    S1[1. scout - haiku, low<br/>Read codebase, interfaces, test conventions] --> S2[2. planner - opus, xhigh<br/>Design adversarial test plan]
    S2 --> S3[3. worker - sonnet, medium<br/>Write Ogur tests in test dir & run them]
    S3 --> S4[4. reviewer / referee - opus, xhigh<br/>Audit blast radius & legitimacy, score bounty]
    S4 -->|DISQUALIFIED<br/>revert files, retry up to 2x with feedback| S2
    S4 -->|CERTIFIED| S5[Return Bounty Report]
```

Models and effort come from the agent definitions in `~/.claude/agents/`.

## When it finishes

The workflow returns `{ verdict, reason, report, attempts }`.

- **CERTIFIED ✅**: show `report` as-is, then 1–2 sentences: defects found, points, rank. If 0 pts, say baseline contracts and invariants were verified intact.
- **DISQUALIFIED ❌** (all 3 attempts failed): run `git status` and make sure no invalid test files remain (revert/remove leftovers), then present `report` explaining why legitimate defects could not be proven.

## Bug Bounty Reference

| Category | Points | Description |
| :--- | :---: | :--- |
| **Critical Vulnerability** | **+100** | Memory corruption, injection, auth bypass, data leakage, cryptographic flaw. |
| **Fatal Crash / Panic / Deadlock** | **+50** | Unhandled panic/exception on valid or boundary input, infinite loop/recursion, deadlock. |
| **Logic Bug / State Desync** | **+25** | Off-by-one, inverted branch, boundary failure, state desync. |
| **Contract / Protocol Non-Compliance** | **+15** | Mismatched return code/type, register layout mismatch, schema violation. |
| **Passing Tests** | **0** | Contract upheld. Points are for defects only. |
| **Violation / Faked Failure** | **DISQUALIFIED** | Score wiped, invalid tests reverted. |

**Ranks**: Scout (1–25) · Tracker (26–75) · Senior Auditor (76–150) · Master Bug Hunter (151+)

## Three Golden Rules (enforced by the referee)

1. **Strict Blast Radius**: test directories only; zero edits to production code.
2. **Absolute Legitimacy**: every failure is a real defect against a documented contract.
3. **Ogur Minimalism**: Arrange-Act-Assert, zero bloat.
