---
name: still
description: Re-diagnose from real evidence after a fix did not take. Use when Fenil says still, again, not working, same error, why is it still, or repeats a bug you already "fixed". No code edits until the evidence is on screen.
---

The previous fix rested on an assumption that was wrong. Retrying a variant of it is what frustrates Fenil most. Evidence first, then one new hypothesis, then the fix.

## 1. Freeze

No Edit or Write until step 4. List every fix already attempted this session, one line each: what changed, what it assumed.

## 2. Restate the symptom

His exact words, plus where it was seen (URL, simulator, curl, CLI). If the symptom is not reproducible on your side, say so now and ask for the artifact (screenshot, log, request id).

## 3. Collect evidence, in this order, and quote the tail of each

- Rerun the exact failing command verbatim, not a variant.
- Web: drive the real page with Chrome MCP: screenshot, `read_console_messages`, `read_network_requests` (failed requests first).
- API / Workers: `curl -i <url>`; tail the running service's logs (`bunx wrangler tail --format json`, server stdout, docker logs).
- iOS: `xcrun simctl io <udid> screenshot <path>` then Read it; `xcrun simctl spawn <udid> log stream --level debug --predicate 'processImagePath contains "<AppName>"'`.
- Staleness: is the running code the edited code? `git log -1`, build timestamp, deploy version id, which worktree, which port, cached bundle.

Done when you can quote the exact error string or the exact wrong value.

## 4. One line

"Previous fix assumed X; evidence shows Y." If Y is still unclear, invoke `mattpocock-skills:diagnosing-bugs` to build a tight feedback loop before touching code.

## 5. Fix, then prove it with the same command

Red before, green after, on the command from step 3. Report both outputs. If the fix needed a different check, say why.
