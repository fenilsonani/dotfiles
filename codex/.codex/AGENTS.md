# Global Rules

## About me

- Fenil, NYC (`America/New_York`): use this timezone for dates, calendar events, reminders, and schedules.
- This global configuration must contain no secrets, credentials, client internals, or private project details.
- I type fast and leave typos; read for intent.

## How to work with me

- Before non-trivial work, batch the decisions that are mine into one concise question set: product, business, architecture, vendor, or SDK choices. In Plan mode, use the structured user-input tool for up to three short, mutually exclusive questions when useful. Otherwise ask one concise question. Engineering details are yours. Once I say go, run end-to-end with zero check-ins; I am often away for hours.
- If a later finding would reverse one of my decisions, surface it as a question instead of silently changing course.
- "Still not working" means re-diagnose from real evidence (logs, screenshots, curl, the failing command), not retry the same fix.
- For an unfamiliar API or library, search the current official documentation first and implement against the repository's installed version unless I approve an upgrade.
- Spending is real: CI minutes, paid APIs, extra simulators, and wide subagent fan-out all cost money. Avoid unnecessary paid calls. Choose the cheapest subagent model that can reliably complete the assigned work, and escalate individual subagents at runtime only when the task requires it.

## Planning

- Use Plan mode for an architectural decision, 3+ files touched, a new dependency, or an ambiguous specification. Otherwise, just do the work. When Plan mode is unavailable, maintain the same concise checklist with the plan tool.
- Keep planning fast: start with the files the task directly touches and expand only when evidence requires it. A plan is done when it lists the specification, files to change, and the command that proves it works. When I must approve a material decision, present the plan once and wait; that is the only check-in.
- Track the plan as a todo list; tick each item as it lands with a one-line note. Give one high-level summary when the task is done.
- After the same error twice, or when the scope changes, stop and re-plan.
- Exception: for a bug report with an error, log, or failing test, reproduce it, fix the root cause, rerun green, and report. No Plan-mode check-in is needed unless a user-owned decision appears.

## Delegation

- Use subagents when work can run independently and would keep the main context clean: research, exploration, parallel analysis, or work that would pull more than about five files into the main context. Keep small sequential edits inline and avoid unnecessary fan-out.
- Route subagent models by task. Use Luna for narrow searches, mechanical checks, log or test analysis, summaries, and other clear repeatable work. Use Terra for broader codebase exploration, review, or tasks needing more judgment. Use Sol for difficult implementation or analysis when Terra is unlikely to be reliable. Use Astra only for exceptional subproblems that clearly need the strongest reasoning, or when I explicitly request it. Start cheap and retry on a stronger model only when evidence shows the cheaper model is insufficient.
- Keep the configured cheap default when spawning a subagent unless the assignment itself justifies an explicit model override. Do not inherit an expensive parent model merely for convenience.
- Brief each subagent with the paths, findings, and constraints already known so it starts from there instead of re-researching. Re-check a subagent's claims before repeating them.

## Done means verified

- Mark a task complete only after proving it works with proportionate, task-relevant verification: run the repository's existing tests, check logs, or demonstrate the real behavior. If nothing covers the change, perform a manual reproduction and say so in the summary instead of adding a new test tier for a fix.
- A typecheck proves types, not runtime behavior. When the task changes runtime behavior and the necessary access exists, run the real thing: simulator, browser, API request, or equivalent. Never claim that something builds, passes, or is faster without the command and its output.
- Bug fixes require red before and green after with the same command; show both outputs.
- Work to a staff-engineer standard: fix the root cause with a minimal diff that touches only what is necessary. No temporary fixes.
- Ship complete, real implementations: no stubs, placeholders, hard-coded limits, or "phase 2" TODOs.
- For a non-trivial change, take one pass for a simpler design before presenting. If the fix feels hacky, rewrite it from the root cause. Simple, obvious fixes ship as-is. Propose refactors beyond the request; do not perform them without approval.
- Add a short `why` comment only where a non-obvious constraint shaped the implementation. Put repository-wide gotchas in that repository's `AGENTS.md`.

## Reporting

- Put the point in the first sentence and stay terse. Add detail only when I say "in detail" or ask to be taught.
- Name the exact file and line, error string, command, or number. Never fabricate a result; say unknown and ask. Label estimates as estimates.
- Report once at the end: before and after, what changed, what was deliberately left alone, and what needs my hands. During long-running work, give only concise status updates.
- State problems and risks plainly and early. Own a mistake once, then move on.
- No emoji in chat, code, commits, docs, or UI. Icons come from Lucide or SVG.
- Anything sent under my name (Slack, email, issue or PR comments, replies, READMEs, posts) goes through the `writing-style` skill. Your own reports and commit messages stay in standard American English.

## Git and shipping

- For an explicitly authorized shipping workflow, the default stopping point is commit, push, and open the PR. Merge, deploy, GitHub comments, closing issues, and deleting branches or worktrees wait for my explicit yes.
- Use several small logical commits, never one giant commit. Use subject `type(scope): lowercase sentence` where the repository uses conventional commits; check commitlint and Lefthook first. The body states why and includes the exact verification command and result.
- Never add `Co-Authored-By` lines or agent branding to commits, branches, PR titles, or PR bodies.
- A PR title is one plain sentence stating the outcome. Its body includes `Closes #N` or `Refs #N`, what and why, and verification with exact commands.
- Never trigger CI on your own; run typecheck, lint, and tests locally. Fix hook failures in scope; never use `--no-verify`, never disable a lint rule, and never create an empty commit to poke CI.
- Destructive or irreversible actions (delete data or infrastructure, drop or truncate, force push, `reset --hard`, production schema push, environment or deploy configuration, `sudo`) require the action and impact stated and an explicit yes. Batch approvals into one question. Migrations are additive; never drop columns or tables to make a change fit.
- Native Codex command hooks enforce these rules. After explicit approval, the allowed escape hatch is `CODEX_OK=<merge|deploy|deps|destructive|bigcommit> <command>` for the matching action only.

## Dependencies

- Before hand-writing generic utility code such as parsing, dates, retries, or validation, check whether a maintained, widely used library already does it and propose it in one line with the tradeoff.
- Adding, removing, or upgrading a dependency, including any manifest or lockfile change during a bug fix, requires explicit user approval first. Permission or bypass mode is not user approval.
- Choose stable, actively maintained dependencies with recent releases, real maintainers, and a clean install. Pin exact versions; no caret ranges.

## Stack defaults

- Repository-specific instructions and existing conventions override these defaults.
- JavaScript and TypeScript: use Bun (`bun install`, `bun run`, `bunx`); follow the repository lockfile when it is npm or pnpm; never use Yarn. Lint with Oxlint and format with Oxfmt or the repository's existing Prettier. Never add ESLint or Biome.
- TypeScript: strict plus `noUncheckedIndexedAccess`; prefer `type` over `interface`; infer types from Zod; use `satisfies` for literals. `any`, `@ts-ignore`, bare `!`, and `as unknown as T` are build-breaking.
- Python: use `uv` (`uv run`, `uvx`) on Homebrew Python 3.12 or newer, never the system Python 3.9; use pytest.
- Obey the repository formatter config exactly; never reorder imports by hand.
- Money is never a float: use decimal or integer cents plus a currency column. Calendar dates are `YYYY-MM-DD` strings; store instants in UTC and render them in the user's timezone.
- Tests assert concrete values and error codes: no snapshots, no bare `toThrow`, and no `test.skip` without a reason. Integration tests hit a real database, not mocks. Never re-record a snapshot or baseline to make a diff disappear.
- UI uses shadcn primitives, Lucide, and semantic Tailwind tokens when the repository does. Every screen handles loading, error, and empty states. No mock data. Use American English. For new UI, load the `frontend-design` skill first, then show variants side by side for me to choose. Nothing should look like an AI-generated template.
