---
name: deslop
description: Deslop prose so it reads like a person wrote it. Use when asked to deslop, de-AI, humanize, or tighten a draft, or to check whether text sounds AI-written. Works on any text, including your own drafts and reports.
---

Slop is mostly a content problem. Text with nothing specific to say falls back on the most likely phrasing, and the familiar tells show up as a symptom. Fix what is said first and how it sounds second. Swapping words without adding substance just produces the next tic.

The target is a reader who believes a person wrote it because the text says something particular. Detector scores are a side effect. Hill-climbing on a detector teaches the prose to be weird, not good.

## 1. Pick the voice

- **Going out under Fenil's name**: load the `writing-style` skill too. It owns his sentences. This skill owns the editing process.
- **Voice samples supplied** (past posts, messages, a corpus path): read the raw samples and keep them in context while editing. Copy their rhythm, sentence length, and word choice straight from the sentences. A summary of a voice ("direct, dry") produces generic direct dry text, so skip writing one.
- **Neither**: write plain, specific, first-draft-sounding prose for the reader the text is meant for.

## 2. Measure the original

```sh
~/.claude/skills/deslop/scripts/measure.py <file>      # or pipe text on stdin; --json for raw numbers
```

Write the text to a scratch file first if it only exists in chat. Keep this output as the **before** numbers. The script holds the tell list itself, so this skill never has to spell those patterns out.

## 3. Content pass

Go through every sentence the report lists under generic sentences, plus any other sentence that would read the same in anyone's draft on the topic. For each one, do exactly one of these:

- **Ground it**: replace the abstraction with the specific it stands for: the number, the name, the file, the date, the example, the error string. Take it only from the source material, the conversation, or the user.
- **Commit to it**: turn the hedge into a claim someone could disagree with.
- **Cut it**: if it restates a neighbor, announces what comes next, or sums up what was just said, delete the whole sentence.

When a sentence needs a specific that the source does not have, leave an inline `[?: what is missing]` and keep going. Never invent a specific to make prose feel lived in: times, people, numbers, feelings, anecdotes. Made-up texture under someone's name is worse than any tell.

Then fix the order: the point goes first. For long-form pieces under Fenil's name, `writing-style`'s long-form rules take over the structure.

## 4. Surface pass

Rewrite each line the report lists under tells. Rebuild the sentence around a concrete verb and its actual subject instead of swapping in a synonym; synonym swaps keep the same tell. Then match the rhythm to the voice from step 1: vary sentence length, let a paragraph be four words or ninety, and drop formatting (headers, bold, bullets) that the text's medium would not normally use.

## 5. Re-measure

Run the script again on the edited text. The text is done when all of these hold:

- zero tells, or each remaining one kept on purpose and justified in one line (a quoted source, a term of art)
- every surviving generic sentence is one you chose to keep
- the specific-sentence ratio went up
- past ~300 words, paragraph length CV is at least 0.55

A new tell that the rewrite introduced counts as unfinished. Go back to step 4 for that line.

## 6. Hand back

Give back, in this order:

1. The edited text, ready to paste.
2. The `[?: ...]` gaps as a short list of questions, if there are any. Real specifics from the author do more than every other fix combined.
3. One before/after line: tells, specific-sentence ratio, paragraph CV.
