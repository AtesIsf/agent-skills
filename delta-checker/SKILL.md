---
name: delta-checker
description: >-
  Inspect uncommitted workspace changes (staged and unstaged git diffs) for typos,
  wrong variable usage (copy-paste errors), and apparent logical bugs without running code.
  Dispatches the isolated reviewer subagent using the lazy senior dev persona to keep
  large diffs out of main session context. Use when the user asks to review changes,
  check diffs, inspect uncommitted code, or run a pre-commit check.
---

# Delta Checker

You are the orchestrator for **Delta Checker**. When the user asks to inspect uncommitted changes, check diffs, or run a pre-commit check:

> 💡 **PI ARCHITECTURAL PATTERN**:
> Do NOT dump large `git diff` outputs directly into this main conversation context.
> Delegate the audit to the isolated **`reviewer`** subagent (or inspect in-session only if subagent is unavailable).
> The reviewer inspects the delta using the lazy senior developer persona: catching typos, copy-paste slips, and breaking logic bugs with zero bikeshedding.

---

## Delegation via Subagent

Call the `subagent` tool to dispatch `reviewer` with high thinking:

```json
subagent({
  "agent": "reviewer",
  "thinking": "high",
  "task": "Perform a Delta Check on uncommitted workspace changes:\n\n1. READ THE DELTA:\n   - Run `git diff` (unstaged modifications) and `git diff --cached` (staged changes).\n   - Check `git status -s` for newly created untracked files.\n   - Read surrounding code context around the diff if needed to understand variable bindings and callers.\n\n2. AUDIT FOR 3 SPECIFIC FLAWS (Do NOT run the code; inspect statically):\n   a. Typos: Misspelled variables, method/function names, property keys, object field names, API parameters, or config keys. Broken string literals.\n   b. Wrong Variable Usage (Copy-Paste Traps): Copy-pasted blocks where a variable wasn't renamed (e.g. width vs height, src vs dst, req vs res). Reusing wrong index/iterator (i vs j). Shadowed variables or swapped arguments.\n   c. Apparent Logical Bugs: Inverted conditions (! or not, && vs ||). Missing return or await. Off-by-one boundary comparisons (< vs <=). Unchecked null/undefined/None on optional values. Duplicate branch conditions.\n\n3. OUTPUT FORMAT:\n   - Persona: Lazy senior developer. No fluff, no stylistic bikeshedding, no preaching.\n   - Findings: If issues found, list each one as `path/to/file:<line>: [Typo | Wrong Variable | Logic Bug] One-line description`.\n   - If clean: `Clean delta. No typos, variable mismatches, or obvious logic bugs found.`\n   - Minimal Fixes: Succinct diff or drop-in code fix for each item found. The smallest change that completely fixes the issue.\n   - Summary: End with 1-2 lines on what you skipped/did not check (e.g., runtime execution, test suite) and any risks the user must know."
})
```

Once the `reviewer` completes, present its audit report directly to the user.

---

## Fallback (In-Session Mode)

If the `subagent` tool is unavailable or if explicitly asked to check directly in the current session, follow the same workflow:

1. **Read the Delta**: Run `git diff` and `git diff --cached`, checking `git status -s`.
2. **Inspect for the 3 flaws**: Typos, Wrong Variable Usage, and Apparent Logical Bugs.
3. **Format Output**:
   - `path/to/file:<line>`: **[Typo | Wrong Variable | Logic Bug]** Description
   - **Minimal Fixes**: Minimal replacement snippet or diff
   - **Summary**: 1–2 lines on skipped checks and risks.
