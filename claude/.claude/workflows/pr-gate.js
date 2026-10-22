// pr-gate: adversarial pre-PR gate. Run with Workflow({name: "pr-gate", args: {base: "main"}}).
// Hunts what slips past a green typecheck: stubs and placeholders, verification claims in commit
// bodies that do not reproduce, spec drift from the linked issue, and UI screens missing states.
// Every finding is then attacked by a skeptic; only the survivors are reported.
export const meta = {
  name: 'pr-gate',
  description: 'Adversarial pre-PR gate: stubs, false-green verification claims, spec drift, missing UI states',
  whenToUse: 'Before opening a PR (or before /ship) on any non-trivial branch',
  phases: [
    { title: 'Find', detail: '4 lenses over git diff base...HEAD' },
    { title: 'Refute', detail: 'one skeptic per finding, default refuted when uncertain' },
  ],
}

const base = (args && args.base) || 'main'
const range = `${base}...HEAD`

const FINDINGS = {
  type: 'object',
  properties: {
    findings: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          file: { type: 'string' },
          line: { type: 'integer' },
          claim: { type: 'string', description: 'one sentence: what is wrong and the evidence' },
          severity: { type: 'string', enum: ['high', 'medium', 'low'] },
        },
        required: ['file', 'line', 'claim', 'severity'],
      },
    },
  },
  required: ['findings'],
}

const VERDICT = {
  type: 'object',
  properties: {
    refuted: { type: 'boolean' },
    why: { type: 'string' },
  },
  required: ['refuted', 'why'],
}

const COMMON = `You are gating a pull request. Work only from the real repo state: run git and the repo's commands yourself, quote file:line. Return structured findings only; an empty list is a valid answer.`

const LENSES = [
  {
    key: 'stubs',
    prompt: `${COMMON}
Run: git diff ${range}. Report every stub, placeholder, TODO/FIXME, "phase 2" note, hard-coded limit or magic cap, mock or sample data left in non-test code, oxlint-disable / eslint-disable / @ts-ignore / @ts-expect-error, bare non-null "!" on a possibly-undefined value, "as unknown as", test.skip / it.skip / xit, re-recorded snapshot, and emoji in code, docs, or UI strings. One finding per site.`,
  },
  {
    key: 'claims',
    prompt: `${COMMON}
Run: git log ${base}..HEAD --format=%B. For every "Verified:" / "verified with" / "tests pass" style claim in a commit body or the PR draft, run the named command exactly as written. Report a finding for each claim whose real output does not match the claim (different count, failures, command does not exist). Also report any commit body that has no verification claim at all.`,
  },
  {
    key: 'spec',
    prompt: `${COMMON}
Find the issue this branch references (branch name like type/<number>-slug, or "Closes #N" in commit bodies; use gh issue view <N>). List each acceptance criterion or explicit request in the issue that git diff ${range} does not satisfy, with the evidence. If no issue is linked, report that as one low-severity finding and stop.`,
  },
  {
    key: 'states',
    prompt: `${COMMON}
For each new or changed screen, page, or component in git diff ${range} (tsx, svelte, vue, swift views): report a finding when it lacks a loading state, an error state, or an empty state that the data source can produce; when copy is not American English; when it renders mock data; or when it duplicates an existing component instead of reusing it.`,
  },
]

phase('Find')
const found = (await parallel(LENSES.map(l => () =>
  agent(l.prompt, { label: `find:${l.key}`, phase: 'Find', schema: FINDINGS, model: 'sonnet' })
))).filter(Boolean).flatMap((r, i) => r.findings.map(f => ({ ...f, lens: LENSES[i].key })))
log(`${found.length} raw findings`)

if (found.length === 0) return { confirmed: [], refuted: [], base }

phase('Refute')
const judged = await parallel(found.map(f => () =>
  agent(`${COMMON}
A reviewer claims, at ${f.file}:${f.line} (lens: ${f.lens}, severity ${f.severity}):
"${f.claim}"
Try to REFUTE it: open the file, run the command, check the issue. Refute when the claim is wrong, already handled elsewhere in the diff, or not a real defect for this PR. Default to refuted=true if you cannot confirm it. When it stands, say in one line what must change.`,
    { label: `refute:${f.file.split('/').pop()}:${f.line}`, phase: 'Refute', schema: VERDICT })
    .then(v => ({ ...f, verdict: v }))
))

const confirmed = judged.filter(Boolean).filter(j => j.verdict && !j.verdict.refuted)
const refuted = judged.filter(Boolean).filter(j => j.verdict && j.verdict.refuted)
log(`${confirmed.length} confirmed, ${refuted.length} refuted`)
return {
  base,
  confirmed: confirmed.map(c => ({ file: c.file, line: c.line, severity: c.severity, lens: c.lens, claim: c.claim, fix: c.verdict.why })),
  refuted: refuted.map(r => ({ file: r.file, line: r.line, claim: r.claim, why: r.verdict.why })),
}
