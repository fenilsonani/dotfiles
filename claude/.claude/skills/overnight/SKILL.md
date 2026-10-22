---
name: overnight
description: Set up an unattended multi-hour Claude Code run (overnight, "I am out for 7 hours", "don't stop until it's done"). Use when Fenil is about to leave and wants work to continue without him, or asks how to run something overnight.
---

Recipe for a run that survives Fenil being away. Every mechanism here exists in Claude Code 2.1.245; nothing below needs him watching.

## Before he leaves

1. Batch what only he can supply (credentials, account logins, business facts, unbudgeted spend) into ONE `AskUserQuestion`; decide everything else yourself. `askUserQuestionTimeout` is `never`, so a question asked after he leaves blocks until he is back; ask now or decide yourself.
2. State the stopping point explicitly. Default: ship end-to-end (commit, push, PR, merge, deploy) unless he names an earlier stop.
3. Set the goal so the session knows when it is done:

   ```
   /goal <done criteria>; PR merged and deployed
   ```

   Example: `/goal every item in the plan implemented, bun run typecheck && bun run test green, PR merged with verification in the body, deploy green`.

4. Tasks: create one per plan item with `TaskCreate`. The Stop hook refuses to end the turn while tasks are open, which is what his "continue" prompts used to do by hand.

## Running it

- Interactive, named so it can be found later: `claude -n <name>` then the prompt.
- Non-interactive with a hard spend cap: `claude -p "$(cat plan.md)" --max-budget-usd 30 --dangerously-skip-permissions`
- Periodic check (real interval, this syntax): `/loop 30m check local test status and new PR comments; act on anything actionable`
- Usage limit: `autoContinueAtUsageLimit` is on in settings, so the session resumes when the window resets.
- Resume a run from its PR: `claude --from-pr <number>`

## When he is back

One report, once: before/after (measurable), what changed, what was deliberately left alone, what needs his hands. The PR body carries the verification commands and their results.
