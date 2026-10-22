---
name: ship
description: Turn the current dirty tree into small logical commits, push the branch, open the PR in Fenil's format, then stop. Use when he says commit, push, ship, make a PR, file a PR, or "commit in multiple commits". Never merges, never triggers CI.
argument-hint: "[issue-number] [--hold]"
disable-model-invocation: true
---

Stopping point is the open PR. `--hold` = steps 1 to 4 only, no push.

## 1. Conventions of this repo

`ls commitlint.config.* lefthook.yml .githooks .husky 2>/dev/null`; read any scope enum. With commitlint: subject `type(scope): lowercase sentence`, 50 to 70 chars. Without: plain imperative sentence. No emoji, no Co-Authored-By, no agent branding.

## 2. Gates, locally

Run the repo's own gate (`bun run verify`, `bun run typecheck && bun run lint && bun run test`, `make check`, whatever the repo documents). A red gate is fixed in scope; hook bypass flags are never used. CI is not triggered by hand.

## 3. Group the diff into concerns

`git status --porcelain` and `git diff --stat`. Bucket hunks by concern (one feature slice, one refactor, one config change). Files mixing concerns get `git add -p`. Order the buckets so every commit builds on its own. Done when every changed path is in exactly one bucket.

## 4. One commit per bucket

`git add -- <paths>` then commit with a subject and a body. Body: 1 to 3 short paragraphs wrapped at 72: why the change exists, the non-obvious decision, then `Verified: <exact command> -> <result or count>`. Use `-F` with a temp file or a heredoc for the body.

## 5. Push and open the PR

`git push -u origin HEAD`, then `gh pr create --title "<one plain sentence stating the outcome>" --body-file <tmp>` with:

```
Closes #N        (or Refs #N when the issue stays open)

### What and why
...

### Verification
<exact gate commands and their counts>

### Deploy        (only when a deploy step or env change is involved)
...
```

## 6. Report and stop

Print the PR URL and the commit list (`git log --oneline origin/main..HEAD`). Stop.
