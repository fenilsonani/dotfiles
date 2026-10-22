---
name: cleanup-worktrees
description: Audit every git worktree under ~/Developer (size, branch, dirty count, PR state), plus stale Conductor and Codex workspaces and orphaned ~/.claude/projects dirs, then remove what Fenil selects. Use when he asks to clean up worktrees, free disk from workspaces, or after a PR merges.
disable-model-invocation: true
---

A single worktree has reached 40 GB. Clean, merged worktrees and orphans go automatically; anything holding unmerged work waits for Fenil's pick.

## 1. Inventory

For every repo: `for r in ~/Developer/*/; do git -C "$r" rev-parse --is-inside-work-tree >/dev/null 2>&1 && git -C "$r" worktree list --porcelain; done`. Also `ls -d ~/conductor/workspaces/*/* ~/.codex/worktrees/*/* 2>/dev/null`.

For each non-main worktree, collect: path, `du -sh`, branch, `git status --porcelain | wc -l` (dirty count), merged into origin/main or not (`git branch -r --merged origin/main`), PR state (`gh pr list --state all --head <branch> --json number,state`). Done when every worktree has all five fields or an explicit `unknown`.

## 2. Classify and present

One plain table: path, size, branch, dirty, PR. Mark `safe` = clean tree and (merged or PR closed/merged). Everything else is `review`. Include orphans: `~/.claude/projects/*worktree*` dirs whose decoded path no longer exists, and Xcode DerivedData trees whose `WorkspacePath` (from `info.plist`) no longer exists.

## 3. Ask once

`safe` rows and orphans are selected without asking. One `AskUserQuestion` with `multiSelect: true` for the `review` rows only (they hold dirty or unmerged work); with no `review` rows, skip the question.

## 4. Remove the selected, from main

For each pick: `git -C <repo> worktree remove --force <path>`, then `git -C <repo> branch -D <branch>` when the branch is merged, then `git -C <repo> worktree prune`. Orphaned project dirs and DerivedData trees: `rm -rf <dir>`. Finish with `git wtclean` in each touched repo.

## 5. Report

Before and after: `df -h /` free space, number of worktrees per repo, what was skipped and why.
