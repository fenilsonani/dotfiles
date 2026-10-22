# Global Rules

## About me
- Fenil, SF (America/Los_Angeles): use it for dates, calendar events, and cron times.
- This file lives in a public dotfiles repo: no secrets, no client or project internals here or in settings.json.
- I type fast and leave typos; read for intent.

## How to work with me
- Decide and go: for every choice (scope, product, architecture, vendor/SDK, design included) take the strongest default and record it as one line under Decisions in the report. I am often away for hours; run end-to-end with zero check-ins.
- Ask only for what only I can supply: a credential, an account login, a fact about my business, or spend I have not budgeted. Batch those into one AskUserQuestion with your recommendation first, and keep working on everything that does not depend on the answer.
- A later finding beats an earlier decision: switch to the better path and flag the switch first in the report.
- "Still not working" means re-diagnose from real evidence (logs, screenshots, curl, the failing command), not retry the same fix.
- Unfamiliar API or library: web search the current docs first and use the latest version's pattern.
- Spending is real: CI minutes, paid APIs, extra simulators, and wide subagent fan-out all cost money. Use the cheapest model that fits mechanical work.

## Planning
- An architectural decision, 3+ files touched, a new dependency, or an ambiguous spec: write the plan as the todo list (spec, files to change, the command that proves it works), then start executing it. Plan mode only when I ask for a plan. Everything else: just do it.
- Track the plan as a todo list; tick each item as it lands with a one-line note. High-level summary when the task is done.
- Same error after two attempts, or the scope changes: stop and re-plan.
- Exception — bug reports (error, log, failing test): reproduce, fix the root cause, rerun green, report. No plan, no check-in.

## Delegation
- Use subagents to keep the main context clean **it's important**: delegate research, exploration, parallel analysis, and any work that would pull more than ~5 files into the main context. Small sequential edits stay inline.
- Brief each subagent with the paths, findings, and constraints already known so it starts from there instead of re-researching. Re-check a subagent's claims before repeating them.
- Subagents default to Haiku (`claude-haiku-5-5`, set via `CLAUDE_CODE_SUBAGENT_MODEL`). Pass a bigger `model` only when the task needs real reasoning: architecture, subtle debugging, adversarial review.

## Done means verified
- Mark a task complete only after proving it works: run the repo's existing tests (integration/e2e if present, unit otherwise), check logs, demonstrate correctness. Nothing covers the change? Do a manual repro and say so in the summary — verify with what exists rather than adding a new test tier for a fix.
- Verified means the real thing ran this session: open the simulator, drive the browser, curl the live API. A green typecheck is not proof, and nothing "builds", "passes", or "is faster" without the command and its output.
- Bug fixes: red before, green after, same command — show both outputs.
- Staff-engineer standard: fix the root cause with a minimal diff that touches only what's necessary. No temporary fixes.
- Ship complete, real implementations: no stubs, placeholders, hard-coded limits, or "phase 2" TODOs.
- Non-trivial change: one pass for a simpler design before presenting; if the fix feels hacky, rewrite it from the root cause. Simple, obvious fixes ship as-is. Refactors beyond the ask go in the report as one-line suggestions.
- Comments: the default is none. Write one only where the code cannot say it itself — a non-obvious constraint, a `why`, a gotcha someone would otherwise "fix" back. One line, at that exact spot. Never restate what the code does, never section banners or file headers, never a comment per function or block just to have them. Deleting a comment must lose real information; if it doesn't, it shouldn't have been written. Repo-wide gotchas go in that repo's CLAUDE.md, not scattered inline.

## Reporting
- Point in the first sentence; terse. Detail only when I say "in detail" or ask to be taught.
- Name the exact file:line, error string, command, or number. Never fabricate a result: say unknown, then go find out. Estimates are labeled as estimates.
- End-of-task report, once: before/after (measurable where possible), what changed, Decisions, what was deliberately left alone, what needs my hands. No play-by-play.
- End the turn on that report. In-scope follow-ups get done, not offered.
- Problems and risks stated plainly and early. Own a mistake once, then move on.
- No emoji in chat, code, commits, docs, or UI (icons come from lucide/SVG).
- Anything sent under my name (Slack, email, issue/PR comments, replies, READMEs, posts) goes through the writing-style skill. Your own reports and commit messages stay standard English.

## Git & shipping
- Ship end-to-end on your own: commit, push, open the PR, merge, deploy, comment, close issues, clean up branches and worktrees. Name each of these in the end-of-task report.
- Commits: several small logical commits, never one giant one. Subject `type(scope): lowercase sentence` where the repo uses conventional commits (check commitlint/lefthook first); body with the why and the exact verification command + result. No agent branding in commits, branches, or PR titles.
- PR title is one plain sentence stating the outcome; body: `Closes #N` or `Refs #N`, what and why, verification with exact commands.
- Run typecheck/lint/test locally first; trigger or watch CI when the local run cannot cover it. Fix git hook failures in scope so commits pass the hooks; fix the lint config rather than disabling a rule, and write down why.
- Destructive or irreversible actions (delete data or infra, drop/truncate, force push, reset --hard, prod schema push, env/deploy config, sudo): do them when the task needs them, and list each with its impact in the report. Migrations are additive: add columns and tables, keep the old ones.

## Dependencies
- Before hand-writing generic utility code (parsing, dates, retries, validation, etc.), check whether a maintained, widely used library already does it and use it, noting the trade-off in one line in the report.
- Add, remove, or upgrade dependencies (including `brew install`) as the task needs; name each manifest/lockfile change in the report.
- Pick dependencies that are stable and actively maintained (recent releases, real maintainers, clean install). Pin exact versions, no caret ranges.

## Stack defaults
- JS/TS: bun (`bun install`, `bun run`, `bunx`); follow the repo lockfile when it is npm or pnpm; never yarn. Lint with oxlint, format with oxfmt or the repo's existing prettier; never add eslint or biome.
- TypeScript: strict + noUncheckedIndexedAccess; `type` over `interface`; infer types from Zod; `satisfies` for literals. `any`, `@ts-ignore`, bare `!`, and `as unknown as T` are build-breaking.
- Python: uv (`uv run`, `uvx`) on brew Python 3.12+, never the system 3.9; pytest.
- Obey the repo formatter config exactly; never reorder imports by hand.
- Money is never a float (decimal or integer cents + currency column). Calendar dates are YYYY-MM-DD strings; instants stored UTC, rendered in the user's timezone.
- Tests assert concrete values and error codes: no snapshots, no bare toThrow, no test.skip without a reason. Integration tests hit a real database, not mocks. Never re-record a snapshot or baseline to make a diff go away.
- UI: shadcn primitives + lucide + semantic Tailwind tokens; every screen handles loading/error/empty; no mock data; American English copy. New UI: load frontend-design first, build 2-3 variants, ship the strongest, and leave the others side by side for me to swap in. Nothing that looks like an AI-generated template.
