#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# ///
import argparse
import json
import re
import statistics
import sys
from pathlib import Path

STOCK_WORDS = [
    "delve", "delving", "leverage", "leveraging", "robust", "seamless", "seamlessly",
    "comprehensive", "elevate", "unlock", "unlocking", "foster", "streamline",
    "holistic", "holistically", "spearhead", "landscape", "realm", "testament", "crucial", "vital",
    "pivotal", "tapestry", "embark", "harness", "meticulous", "meticulously",
    "intricate", "showcase", "underscore", "underscores", "bolster", "empower",
    "empowering", "game-changer", "cutting-edge", "ever-evolving", "paramount",
    "transformative", "navigate", "navigating", "moreover", "furthermore",
    "additionally", "ultimately", "notably", "invaluable", "synergy", "myriad",
]

STOCK_PHRASES = [
    "it's important to note", "it is important to note", "it's worth noting",
    "it is worth noting", "in today's", "in conclusion", "in summary", "let's dive",
    "dive into", "dive deep", "deep dive", "at the end of the day", "plays a crucial role",
    "plays a key role", "a testament to", "whether you're", "here's the thing",
    "great question", "i hope this", "happy to help", "feel free to", "rest assured",
    "when it comes to", "the world of", "a wide range of", "in order to",
    "serves as a", "stands as a", "it's no secret", "look no further", "the power of",
    "key takeaway", "game changer", "best practices", "fast-paced",
]

CONSTRUCTIONS = {
    "not-x-but-y": re.compile(
        r"\b(?:it'?s|it is|this is|that'?s|that is|isn'?t|is)\s+not\s+(?:just|only|merely|about)?\s*[^.;!?]{1,60}?[,;:—-]+\s*(?:it'?s|but|rather)\b",
        re.I,
    ),
    "not-only-but-also": re.compile(r"\bnot only\b[^.;!?]{1,80}\bbut also\b", re.I),
    "reveal-question": re.compile(r"(?:^|[.!]\s+)(?:The|And the|But the)\s+\w+(?:\s\w+)?\?\s+[A-Z]"),
    "single-word-triad": re.compile(r"\b[A-Za-z][a-z]{2,},\s+[a-z]{3,},?\s+and\s+[a-z]{3,}\b"),
    "em-dash": re.compile(r"—|\s--\s"),
}

NOMINAL = re.compile(r"\b[a-z]{4,}(?:tion|sion|ment|ity|ness|ance|ence)s?\b", re.I)
HEDGES = re.compile(
    r"\b(?:may|might|could potentially|arguably|generally|typically|often|somewhat|perhaps|possibly|essentially|basically)\b",
    re.I,
)
CONCRETE = re.compile(r"\d|`|\"[^\"]+\"|“[^”]+”|\S+\.\w{1,4}\b|https?://")
PROPER = re.compile(r"(?<![.!?]\s)(?<!^)\b[A-Z][a-zA-Z]+")
SENT_SPLIT = re.compile(r"(?<=[.!?])\s+(?=[\"'“(]?[A-Z0-9`])")


def strip_code(text: str) -> str:
    return re.sub(r"```.*?```", lambda m: "\n" * m.group(0).count("\n"), text, flags=re.S)


def paragraphs(text: str) -> list[tuple[int, str]]:
    out: list[tuple[int, str]] = []
    buf: list[str] = []
    start = 0
    for i, line in enumerate(text.splitlines(), 1):
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            if buf:
                out.append((start, " ".join(buf)))
                buf = []
            continue
        if not buf:
            start = i
        buf.append(stripped)
    if buf:
        out.append((start, " ".join(buf)))
    return out


def words(s: str) -> list[str]:
    return re.findall(r"[A-Za-z0-9'’-]+", s)


def cv(xs: list[int]) -> float:
    if len(xs) < 2 or statistics.mean(xs) == 0:
        return 0.0
    return statistics.pstdev(xs) / statistics.mean(xs)


def line_of(text: str, needle_pos: int) -> int:
    return text.count("\n", 0, needle_pos) + 1


def is_concrete(sentence: str) -> bool:
    if CONCRETE.search(sentence):
        return True
    body = sentence.split(" ", 1)[1] if " " in sentence else ""
    return any(m.group(0) != "I" for m in PROPER.finditer(body))


def measure(raw: str) -> dict:
    text = strip_code(raw)
    lower = text.lower()
    paras = paragraphs(text)
    sentences: list[tuple[int, str]] = []
    for line, p in paras:
        for s in SENT_SPLIT.split(p):
            s = s.strip()
            if words(s):
                sentences.append((line, s))

    all_words = [w for _, p in paras for w in words(p)]
    n_words = len(all_words) or 1
    per_k = 1000 / n_words

    hits: list[dict] = []
    for w in STOCK_WORDS:
        for m in re.finditer(rf"\b{re.escape(w)}\b", lower):
            hits.append({"line": line_of(text, m.start()), "kind": "stock-word", "match": w})
    for ph in STOCK_PHRASES:
        for m in re.finditer(re.escape(ph), lower):
            hits.append({"line": line_of(text, m.start()), "kind": "stock-phrase", "match": ph})
    for kind, rx in CONSTRUCTIONS.items():
        for m in rx.finditer(text):
            hits.append({"line": line_of(text, m.start()), "kind": kind, "match": m.group(0).strip()[:80]})
    hits.sort(key=lambda h: h["line"])

    sent_lens = [len(words(s)) for _, s in sentences]
    para_lens = [len(words(p)) for _, p in paras]
    concrete = [is_concrete(s) for _, s in sentences]
    generic = [
        {"line": line, "sentence": s[:160]}
        for (line, s), c in zip(sentences, concrete)
        if not c and len(words(s)) >= 12
    ]

    return {
        "words": len(all_words),
        "sentences": len(sentences),
        "paragraphs": len(paras),
        "sentence_len_mean": round(statistics.mean(sent_lens), 1) if sent_lens else 0,
        "sentence_len_cv": round(cv(sent_lens), 2),
        "paragraph_len_cv": round(cv(para_lens), 2),
        "paragraph_len_min": min(para_lens, default=0),
        "paragraph_len_max": max(para_lens, default=0),
        "nominalizations_per_1k": round(len(NOMINAL.findall(text)) * per_k, 1),
        "hedges_per_1k": round(len(HEDGES.findall(text)) * per_k, 1),
        "specific_sentence_ratio": round(sum(concrete) / len(concrete), 2) if concrete else 0,
        "tells": hits,
        "generic_sentences": generic,
    }


def report(m: dict) -> str:
    lines = [
        f"words {m['words']}  sentences {m['sentences']}  paragraphs {m['paragraphs']}",
        f"sentence length mean {m['sentence_len_mean']}  cv {m['sentence_len_cv']}  (human prose usually >= 0.45)",
        f"paragraph length cv {m['paragraph_len_cv']}  min {m['paragraph_len_min']}  max {m['paragraph_len_max']}  (>= 0.55 once past ~300 words)",
        f"nominalizations/1k {m['nominalizations_per_1k']}  (human essays ~32, ChatGPT ~75)",
        f"hedges/1k {m['hedges_per_1k']}",
        f"specific sentences {m['specific_sentence_ratio']:.0%}",
        "",
        f"tells ({len(m['tells'])}):",
    ]
    lines += [f"  L{h['line']}  {h['kind']}: {h['match']}" for h in m["tells"]] or ["  none"]
    lines += ["", f"generic sentences, 12+ words with no number, name, file, code, or quote ({len(m['generic_sentences'])}):"]
    lines += [f"  L{g['line']}  {g['sentence']}" for g in m["generic_sentences"]] or ["  none"]
    return "\n".join(lines)


def main() -> None:
    ap = argparse.ArgumentParser(description="Measure slop tells, rhythm, and specificity in prose.")
    ap.add_argument("file", nargs="?", help="file to measure; reads stdin when omitted")
    ap.add_argument("--json", action="store_true", help="emit JSON instead of a report")
    args = ap.parse_args()
    raw = Path(args.file).read_text() if args.file else sys.stdin.read()
    m = measure(raw)
    print(json.dumps(m, indent=2) if args.json else report(m))


if __name__ == "__main__":
    main()
