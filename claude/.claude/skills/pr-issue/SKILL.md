---
name: pr-issue
description: The standard layout for pull request and issue titles and bodies, built to be read fast. Short outcome title, one or two sentence summary, linked issues, Decisions, a Before/After table (screenshots or GIFs for UI, numbers for performance, output for bug fixes), and Verification. Use whenever opening or editing a PR or filing or editing an issue, on any host (sailfork, GitHub). Takes precedence over writing-style for PR and issue titles and bodies.
---

# PR and issue standard

A reviewer should get the point from the title, the change from the Before/After, and the risk from Decisions,
without reading a paragraph. Write plain standard English: capital "I", normal punctuation, no emoji, no filler
("This PR...", "In this change we..."), no agent branding or attribution lines. Do not apply writing-style here.

## Pull request

### Title

- States the outcome a user or developer sees, in at most 60 characters. Sentence case, no trailing period.
- No `feat:`/`fix:` prefix, no issue number, no branch name. Commits carry the conventional prefix; the title does not.
- Good: `Merge button enables as soon as checks pass`. Bad: `fix(web): update merge logic and refactor hooks`.

### Body

Sections in this order. Leave out a section that has nothing real in it. Never write "N/A".

```markdown
Closes #123 · Refs #98

One or two sentences: what changed and why it matters. No heading above this.

### Before / After
<table, see below>

### Decisions
- Chose X over Y: one-line reason.

### Verification
- `exact command` → result (counts, timings, status codes)

### Notes
- Risk, deploy or migration step, what was deliberately left alone, follow-ups.
```

- **Links** go on the first line: `Closes #N` for each issue this PR finishes, `Refs #N` for related ones. Every PR
  that comes from an issue links it. Name the reviewer with `--reviewer` when the task names one.
- **Decisions**: one bullet per real choice a reviewer might question (library, data shape, trade-off, scope cut).
  Bold the choice, one line of why. Three bullets is typical; zero means you made none worth naming.
- **Verification**: the commands that actually ran this session and what they printed. No "should work".

### Before / After: required for every behavior change

Pick the form that fits the change. When a change has several kinds (UI plus speed), include each table.
Keep cells short (a few words or one short code span); a long command goes in Verification, not in a cell.

**UI change**: screenshots side by side; a GIF or short video for anything that moves (hover, drag, loading,
transitions, a multi-step flow). Same page, same data, same viewport and theme in both shots. Crop to the part
that changed; add a full-page pair only when layout shifted.

```markdown
| Before | After |
| --- | --- |
| ![before](url) | ![after](url) |
| Merge button stays grey after checks pass | Button turns blue the moment the last check lands |
```

**Performance**: numbers, never adjectives. Same machine, same input, median of several runs; name the command.

```markdown
| Metric | Before | After | Change |
| --- | --- | --- | --- |
| p50 page load | 840 ms | 310 ms | -63% |
| Bundle size | 412 KB | 288 KB | -30% |

Measured with `bun run bench:load` (10 runs, median) on an M3 Pro.
```

**Bug fix**: the failing behavior and the fixed behavior, with the same command or steps.

```markdown
| | Before | After |
| --- | --- | --- |
| `sailfork api ... -H 'Content-Type: image/png'` stores | `application/json` | `image/png` |
| Image in the PR body | downloads as a file | shows inline |
```

**API, CLI or output change**: one-liners go in table cells as inline code. Multi-line output goes in two
fenced blocks under bold **Before** and **After** labels, because tables cannot hold code blocks.

**No behavior change** (refactor, internal cleanup): write `No behavior change.` plus the one check that proves it,
and skip the table.

### Media: capture and attach

1. Capture before shots first, on `main` or the deployed site, before switching to the branch.
   - Browser: Claude in Chrome screenshot, or `gif_creator` for a GIF.
   - Any window: `screencapture -x -R x,y,w,h before.png` (region) or `screencapture -v` (video).
   - Terminal output: paste as text, not a screenshot.
2. Keep files small: crop to the change, max 1600 px wide, GIF under 10 MB (or use mp4).
3. Upload, then paste each link into its table cell:
   - **sailfork**: `sailfork attachment upload before.png after.png` prints one `![name](url)` per file.
     (`--attach` on `pr edit`/`issue comment` only appends to the end, so it does not work for tables.)
   - **GitHub**: the API has no upload endpoint for PR bodies. Push the images to an orphan `pr-media`
     branch and link `https://github.com/<owner>/<repo>/raw/pr-media/<pr-branch>/before.png`.
4. Delete the local capture files when the PR is up.

## Issue

### Title

The symptom or the need as a reader would put it, at most 60 characters. `Merge button stays disabled after checks
pass`, not `Bug in merge`.

### Bug body

```markdown
One sentence: who hits it, where, and how bad (blocks work, wrong data, cosmetic).

### Evidence
![screenshot or GIF](url)
`exact error string or log line`

### Steps to reproduce
1. Go to ...
2. Click ...

| Expected | Actual |
| --- | --- |
| Button enables when checks pass | Button stays disabled until refresh |

### Context
- Where: URL, version or commit, browser or OS
- Suspected cause: `path/to/file.ts:42` (only when known)
- Related: #45
```

Evidence is the most useful part of a bug report: attach a screenshot or GIF for anything visible, and paste the
real error text so it is searchable. Upload media the same way as for PRs.

### Feature or task body

```markdown
One or two sentences: the problem today and who it hurts.

### Proposal
What to build, in a few bullets. A mockup or a screenshot of the current state when it is UI.

### Done when
- [ ] Concrete, checkable outcome
- [ ] Another

### Context
Related issues, links, constraints.
```

Set labels, priority, assignee and parent with the host's flags (`sailfork issue create --label --priority
--assignee --parent --blocked-by --attach`) instead of writing them into the body.

## Before sending

- Title at most 60 characters and states an outcome or symptom.
- First line links the issue(s).
- Before/After present for any behavior change, with real media or numbers, not placeholders.
- Every image link resolves (open one).
- No section left empty, no "N/A", no emoji.
