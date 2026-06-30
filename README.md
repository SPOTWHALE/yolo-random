# yolo-random

A Claude Code plugin that spends your **leftover quota** on real open-source.

Before your quota resets, run `/yolo random`. It picks one beginner-friendly
issue from a curated opt-in list, fixes it in a throwaway temp dir, opens a
single quality PR, and cleans up after itself. Nothing is installed or left on
your machine.

## Principles

- **One issue, one PR** per run. No spam, no batch firing.
- **Opt-in repos only** — targets come from [`CANDIDATES.md`](./CANDIDATES.md),
  repos that explicitly welcome outside contributions.
- **Non-invasive** — all work happens in `mktemp -d`, deleted when done. Your
  own projects are never touched.
- **Honest** — every PR discloses AI authorship and respects the repo's
  `CONTRIBUTING.md`.

## Install

```
/plugin marketplace add spotwhale/yolo-random
/plugin install yolo-random@yolo-random
```

## Running it passively (no per-step prompts)

The skill decides everything on its own — it never stops to ask "shall I
proceed?". But Claude Code still prompts before shell commands unless you opt in
once. Pick one:

**Option A — throwaway YOLO session (simplest):**

```
claude --dangerously-skip-permissions
> /yolo random
```

Zero prompts, scoped to that one session. Recommended for "burn my quota" runs.

**Option B — scoped allowlist (safer, persists):** add to your
`~/.claude/settings.json`:

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
contributions and whose `CONTRIBUTING.md` does not ban AI-assisted PRs. The
skill re-checks each repo's rules at run time, but the list is the first gate.

## Requirements

- `gh` CLI, authenticated (`gh auth status`).
- A GitHub account that can fork public repos.
