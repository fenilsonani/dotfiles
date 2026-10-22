---
name: latest-docs
description: Look up the current official docs for a library or API at the version installed in this repo and return a short brief with the up-to-date call pattern. Use before implementing anything with an unfamiliar, recently upgraded, or fast-moving API (Next, AI SDK, Better Auth, Drizzle, Tailwind, Swift, Cloudflare).
argument-hint: "<package or API> [question]"
context: fork
allowed-tools: WebSearch, WebFetch, Read, Grep, Glob, Bash(grep:*), Bash(cat:*), Bash(jq:*), Bash(ls:*)
---

Training-era patterns are often one major version behind what this repo pins. Find the installed version first, then read the docs for that version.

## 1. Installed version

Check, in order, whichever exists: `bun.lock` / `package-lock.json` / `pnpm-lock.yaml` (the `<pkg>@x.y.z` entry), `package.json`, `Package.resolved`, `uv.lock`, `Cargo.lock`, `wrangler.toml` compatibility date. Quote the exact version.

## 2. Read the current docs

WebSearch `<pkg> <major.minor> docs <topic>` and `<pkg> changelog <major>`; WebFetch the official docs page and, when the signature matters, the source on GitHub at that tag. Prefer the vendor's site over blog posts.

## 3. Brief, at most 15 lines

- Version found and where.
- The call pattern as a code snippet, for that version.
- Breaking changes since the previous major that touch this question.
- Two URLs.
- Anything unconfirmed is marked `unknown`, never guessed.

Suggest `mattpocock-skills:research` when the question needs a longer investigation or a written record in the repo.
