---
name: yolo-random
description: >
  Spend leftover quota on ONE good open-source contribution. Picks a
  beginner-friendly issue from the curated opt-in list in CANDIDATES.md, forks
  the repo, fixes the issue in a throwaway temp dir, opens a single quality PR,
  then deletes the temp dir. Quality over volume, never spam. Use when the user
  says "/yolo random", "yolo random", "fix a random issue", or "use my leftover
  quota on open source".
---

# yolo-random

Burn leftover quota on ONE genuinely useful open-source PR. Quality over volume.
Never spam. Always disclose AI authorship. Respect each repo's CONTRIBUTING.md.

## Hard rules (do not break)

- **ONE issue, ONE PR per invocation.** No batch firing. Many PRs at once looks
  like spam and gets the account flagged by GitHub.
- **Opt-in repos only.** Pick the repo from the live `CANDIDATES.md` (see step 1).
  Never invent a target repo.
- **All work in a throwaway temp dir** from `mktemp -d`. `rm -rf` it at the end,
  on success or failure. NEVER clone into the user's working directory or any of
  their projects. Nothing persists on the user's machine.
- **Disclose AI authorship** in the PR body. If the repo's CONTRIBUTING.md bans
  AI/automated PRs or needs a CLA the user has not signed → abort, pick another.
- **Minimal diff.** Only touch what the issue needs. Never edit unrelated files,
  never touch CI config or secrets.

## Steps

1. **Read candidates (live).** Fetch the current list straight from GitHub so
   curator edits apply without a plugin update:
   ```
   curl -fsSL https://raw.githubusercontent.com/spotwhale/yolo-random/main/CANDIDATES.md
   ```
   If the fetch fails (offline), fall back to `${CLAUDE_PLUGIN_ROOT}/CANDIDATES.md`.
   Show the user the list. Let them pick a repo, or auto-pick the top one if they
   said "just go".

2. **Find an issue** in the chosen repo:
   ```
   gh issue list --repo OWNER/REPO --state open \
     --label "good first issue" --json number,title,url,labels --limit 20
   ```
   Pick one that: has no linked PR, is not contested in comments, has bounded
   scope you can actually finish. If none fit, go back to step 1.

3. **Check CONTRIBUTING.md** via `gh api`. If it bans AI/automated PRs or needs an
   unsigned CLA → drop this repo, return to step 1.

4. **Fork + clone the fork to temp:**
   ```
   gh repo fork OWNER/REPO --clone=false
   d=$(mktemp -d)
   git clone --depth 1 "https://github.com/$(gh api user --jq .login)/REPO" "$d"
   ```

5. **Understand + fix** inside `$d`: reproduce the issue, find the root cause, make
   the minimal change, add or adjust a test, run the repo's test command if cheap.
   If the fix is not clear after reading → abort, pick a different issue. Do not
   guess on someone else's codebase.

6. **Commit + open PR:**
   ```
   cd "$d" && git checkout -b fix/issue-NUMBER
   git commit -am "fix: <short summary> (#NUMBER)"
   git push -u origin fix/issue-NUMBER
   gh pr create --repo OWNER/REPO --head "$(gh api user --jq .login):fix/issue-NUMBER" \
     --title "fix: <summary>" \
     --body "Fixes #NUMBER

<what changed and why>

_Opened with AI assistance (Claude Code)._"
   ```

7. **Clean up:** `rm -rf "$d"`. Report the PR URL to the user.

## When unsure

Ambiguous issue, contested in comments, fix not obvious after reading, or repo
rules unclear → abort and pick another. A clean "found nothing worth a PR today"
beats a low-quality drive-by PR that wastes a maintainer's time.
