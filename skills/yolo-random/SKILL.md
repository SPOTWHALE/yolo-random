---
name: yolo-random
description: >
  Spend leftover quota on ONE good open-source contribution. Picks a
  beginner-friendly issue from the curated opt-in list in CANDIDATES.md and
  submits a fix by one of two methods: a non-invasive issue COMMENT (diff for a
  maintainer to apply, no fork) or a real PULL REQUEST (fork + PR). Each candidate
  repo declares which methods it accepts; the user picks their preferred method
  (pros/cons below). Quality over volume, never spam. Use when the user says
  "/yolo random", "yolo random", "solve a random issue", or "use my leftover
  quota on open source". Optional arg: "pr" or "comment" to preset the method.
---

# yolo-random

Burn leftover quota on ONE genuinely useful open-source contribution. Quality
over volume. Never spam. Always disclose AI authorship. Respect each repo's
CONTRIBUTING.md.

**Run end-to-end without stopping for confirmation** once the method is decided.
The only stops are the method choice (step 0, if not preset) and the hard-rule
aborts below, where you pick a different target instead of asking.

## The two methods

| | **comment** (default, non-invasive) | **pr** (real contribution) |
|---|---|---|
| What | Post one issue comment: root cause + a ready-to-apply diff | Fork the repo, open a real pull request |
| Footprint | Zero — only a read-only temp clone, deleted after | A fork repo in your GitHub account |
| Pros | No fork, no PR, nothing in your account; lowest friction | Counts as a contribution (shows on your profile), CI runs, directly mergeable |
| Cons | Not a PR — no profile credit, no CI, maintainer must apply it, lower acceptance | Leaves a fork in your account; more steps |

## Choosing the method (two sides)

- **Candidate (repo) side:** each entry in `CANDIDATES.md` has a `Method` field
  listing what that repo accepts: `comment`, `pr`, or `both`. Never use a method
  a repo does not list.
- **Coder (user) side:** the user's preference comes from the invocation arg
  (`/yolo random pr` or `/yolo random comment`). If no arg is given, present the
  pros/cons table above and ask once which they prefer, then run autonomously.
- **Reconcile:** use the user's preferred method if the chosen repo accepts it.
  If it doesn't, tell the user and either use the method the repo does accept or
  pick a different candidate that supports their preference.

## Hard rules (do not break)

- **ONE issue, ONE submission per invocation.** No batch firing — looks like spam,
  gets the account flagged.
- **Opt-in repos only**, from the live `CANDIDATES.md` (step 1). Never invent a target.
- **Honor the repo's declared `Method`.** Never open a PR on a `comment`-only repo.
- **All code reading in a throwaway temp dir** (`mktemp -d`), `rm -rf` at the end,
  success or failure. Never clone into the user's projects.
- **Disclose AI authorship** in the comment/PR body. If CONTRIBUTING.md bans
  AI/automated contributions (or needs an unsigned CLA for the `pr` path) → abort,
  pick another.
- **Minimal diff.** Only what the issue needs. Never touch unrelated files, CI, or secrets.

## Steps

0. **Decide method.** Read the user's arg (`pr`/`comment`). If absent, show the
   pros/cons table and ask once. Remember the choice for this run.

1. **Read candidates (live):**
   ```
   curl -fsSL https://raw.githubusercontent.com/spotwhale/yolo-random/main/CANDIDATES.md
   ```
   Fallback to `${CLAUDE_PLUGIN_ROOT}/CANDIDATES.md` if offline. Auto-pick the top
   repo whose `Method` supports the chosen method; do not stop to ask.

2. **Find an issue:**
   ```
   gh issue list --repo OWNER/REPO --state open \
     --label "good first issue" --json number,title,url,labels --limit 20
   ```
   Pick one with no linked PR, not contested, bounded scope. None fit → back to step 1.

3. **Check CONTRIBUTING.md** via `gh api`. Bans AI / unsolicited contributions
   (or unsigned CLA for `pr`) → drop repo, back to step 1.

4. **Read code in a temp clone** (public, read-only):
   ```
   d=$(mktemp -d); git clone --depth 1 "https://github.com/OWNER/REPO" "$d"
   ```

5. **Solve** inside `$d`: reproduce, root-cause, make the minimal change, run the
   repo's tests if cheap. Capture the patch: `cd "$d" && git diff > /tmp/yolo.patch`.
   Fix not clear after reading → abort, pick a different issue.

6. **Submit, per chosen method:**

   **comment:**
   ```
   gh issue comment NUMBER --repo OWNER/REPO --body "$(cat <<'EOF'
   **Proposed fix for this issue**

   Root cause: <one paragraph>

   Suggested change:

   ```diff
   <contents of /tmp/yolo.patch>
   ```

   <how it was verified>

   _Posted with AI assistance (Claude Code) as a suggestion for a maintainer to review and apply._
   EOF
   )"
   ```

   **pr** (only if repo's Method allows it):
   ```
   gh repo fork OWNER/REPO --clone=false
   me=$(gh api user --jq .login)
   cd "$d" && git remote add fork "https://github.com/$me/REPO" \
     && git checkout -b fix/issue-NUMBER \
     && git commit -am "fix: <summary> (#NUMBER)" \
     && git push -u fork fix/issue-NUMBER
   gh pr create --repo OWNER/REPO --head "$me:fix/issue-NUMBER" \
     --title "fix: <summary>" \
     --body "Fixes #NUMBER

   <what changed and why>

   _Opened with AI assistance (Claude Code)._"
   ```

7. **Clean up:** `rm -rf "$d" /tmp/yolo.patch`. Report the comment/PR URL.

## When unsure

Ambiguous issue, contested in comments, fix not obvious, or repo rules unclear →
abort and pick another. A clean "found nothing worth submitting today" beats a
low-quality drive-by that wastes a maintainer's time.
