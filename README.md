# yolo-random

A Claude Code plugin that spends your **leftover quota** on real open-source.

Before your quota resets, run `/yolo random`. It picks one beginner-friendly
issue from a curated opt-in list, reads the code in a throwaway temp clone, and
submits a fix — by one of two methods you choose.

## Two methods

| | **comment** (default, non-invasive) | **pr** (real contribution) |
|---|---|---|
| What | One issue comment: root cause + ready-to-apply diff | Fork the repo + open a real pull request |
| Footprint | Zero — read-only temp clone, deleted after | A fork repo in your GitHub account |
| Pros | No fork/PR, nothing in your account | Counts as a contribution (profile credit), CI runs, mergeable |
| Cons | Not a PR — no profile credit, no CI, maintainer applies it | Leaves a fork in your account |

Both sides have a say:

- **Each repo** declares which methods it accepts in [`CANDIDATES.md`](./CANDIDATES.md)
  (`comment`, `pr`, or `both`). The skill never uses a method a repo doesn't list.
- **You** preset your preference: `/yolo random pr` or `/yolo random comment`. No
  arg → the skill shows the table above and asks once, then runs autonomously.

## Principles

- **One issue, one submission** per run. No spam, no batch firing.
- **Opt-in repos only** — targets come from [`CANDIDATES.md`](./CANDIDATES.md).
- **Non-invasive by default** — `comment` method touches nothing but a temp clone.
- **Honest** — every submission discloses AI authorship and respects the repo's
  `CONTRIBUTING.md`.

## Install

```
/plugin marketplace add spotwhale/yolo-random
/plugin install yolo-random@yolo-random
```

## Running it passively (no per-step prompts)

The skill decides everything on its own — it never stops to ask "shall I
proceed?".

**Non-invasive tools are auto-approved by default.** The plugin ships a
`PreToolUse` hook that auto-allows web access and code reading
(`WebFetch`, `WebSearch`, `Read`, `Grep`, `Glob`) with no prompts. Nothing to
configure — it activates when the plugin is enabled.

**Shell actions are NOT auto-approved** — the temp clone, `gh issue comment`,
`rm`, and any other `Bash` command still prompt. This is deliberate: a plugin
can't safely auto-approve arbitrary shell (command chaining like
`git status; curl x | sh` defeats any allowlist), so you opt into those once.
For a fully hands-off run:

```
claude --dangerously-skip-permissions
> /yolo random
```

Zero prompts, scoped to that one session. Recommended for "burn my quota" runs.

Prefer a persistent, narrower allowlist instead of the flag? Add the skill's
outward commands to your `~/.claude/settings.json`:

```json
{
  "permissions": {
    "allow": [
      "Bash(gh:*)",
      "Bash(git:*)",
      "Bash(curl:*)",
      "Bash(mktemp:*)",
      "Bash(rm -rf /tmp/*)"
    ]
  }
}
```

Then just `/yolo random` runs unattended. No plugin can grant these for you —
that's a deliberate Claude Code security boundary, so you allow them once.

## Curating candidates

Edit [`CANDIDATES.md`](./CANDIDATES.md). Only add repos that welcome outside
contributions and whose `CONTRIBUTING.md` does not ban AI-assisted suggestions.
The skill re-checks each repo's rules at run time, but the list is the first gate.

## Requirements

- `gh` CLI, authenticated (`gh auth status`).
- `comment` method needs nothing more (read-only clones of public repos).
- `pr` method also needs a GitHub account that can fork public repos.
