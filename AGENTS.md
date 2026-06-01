# SigurdOS Client — Agent Onboarding

**You are an AI agent working on the SigurdOS Client Flutter app.** This file is your instruction manual. Read it before modifying code.

**Do not modify this file or `CLAUDE.md` in any PR.** They are AI agent context. Only the repo owner changes them. Any PR that touches either file will be rejected without review.

---

## Reference Documents

| File | When to read it | Purpose |
|------|----------------|---------|
| **`AGENTS.md`** ← you are here | Every session | Agent instructions, workflow, review checklist, rejection triggers, gotchas |
| **`CLAUDE.md`** | Mirror of AGENTS.md | Same content — read whichever your tool prefers |
| **`CONTRIBUTING.md`** | Before ANY PR | Contribution workflow, issue-first requirement |
| **`README.md`** | First time in the repo | Project overview, build commands, license |

---

## What Is This

Flutter mobile app (Android/iOS/Linux/Web) that connects to MeshCore-compatible radios over **BLE, TCP, or USB serial**. Provides direct/channel chat, contact and channel management, on-map node tracking, repeater administration, and on-device message translation.

Three repos form the SigurdOS ecosystem:

| Repo | What | Stack |
|------|------|-------|
| `hermes-gadget/SigurdOS` | MeshCore fork (core library) | C++/PlatformIO, ESP32 |
| `hermes-gadget/SigurdOS-tdeck` | T-Deck LVGL firmware | C++/PlatformIO, LVGL v9 |
| **`hermes-gadget/SigurdOS-client`** ← **you are here** | Flutter mobile app | Dart/Flutter, BLE/USB/TCP |

---

## Quick Start

```bash
cd ~/SigurdOS-client

# Install dependencies
~/flutter/bin/flutter pub get

# Run static analysis
~/flutter/bin/flutter analyze

# Run tests
~/flutter/bin/flutter test

# Build APK
~/flutter/bin/flutter build apk
```

---

## AI Agent Workflow

When working on this codebase, follow this sequence:

1. **Open an issue first** — check if an open issue on `hermes-gadget/SigurdOS-client` covers your plan. No issue = no PR accepted.
2. **Read `CONTRIBUTING.md`** — follow every step.
3. **Load context** — read `AGENTS.md` (or `CLAUDE.md`, they are identical), `KNOWN_ISSUES.md` (if it exists), and relevant source files.
4. **Check the branch** — work is always on `dev`. PRs target `dev`, not `main`.
5. **Run `flutter analyze` and `flutter test`** before any changes to confirm baseline.
6. **Make changes** — keep commits atomic and descriptive.
7. **Run `flutter analyze` and `flutter test` again** — both must pass.
8. **Build the APK** — `flutter build apk` must succeed.
9. **Commit and push** — conventional commit messages (`feat:`, `fix:`, `docs:`, etc.).

### Bug Spotting

If you find a bug while working that is not directly related to your PR, do not ignore it. Add it to `KNOWN_ISSUES.md` using the standard format below. This lets the project catch bugs faster — you found it, you document it, and a maintainer validates it during PR review.

**Standard entry format — insert a new section in `KNOWN_ISSUES.md`:**

```
## Category Area (e.g. Chat, BLE, Settings)

### Short specific title — one line describing the issue
One or two paragraphs explaining what happens, under what conditions, and why. Include the source file and relevant line numbers if known.

**What's needed:** Concrete description of what a fix would look like — approach, trade-offs, and any pitfalls to avoid.
```

Entries are separated by `---`. Place new entries under the right category heading or create a new category heading if none fits.

**Example — the firmware repo uses this exact format:**

```
## Terminal

### Undocumented commands
The built-in serial/diagnostics terminal exposes several internal commands but there is no documentation on what is available or what each command does. Users have to read the source code to discover features.

**What's needed:** A `help` command that lists all available commands with a one-line description.
```

**Important:** Only add issues you have actually observed or can clearly demonstrate from reading the code. Do not add speculative bugs. The maintainer will verify your entry during PR review — if it does not hold up, the entry will be removed before merging.

### PR & Review Workflow

**For reviewers (maintainer only beyond step 5):**
1. List PRs: `gh pr list --repo hermes-gadget/SigurdOS-client --state open`
2. Check diff: `gh pr diff N`
3. Analyze: `~/flutter/bin/flutter analyze` (zero warnings)
4. Test: `~/flutter/bin/flutter test` (all pass)
5. Run the [Code Audit Checklist](#code-audit-checklist) — check every applicable item
6. Merge: `gh pr merge N --squash --delete-branch --repo hermes-gadget/SigurdOS-client`
7. If merge fails (conflicts): cherry-pick new commits only, or squash-merge locally
8. If PR branch has stale commits: cherry-pick new commits onto dev, close PR

---

## Code Audit Checklist

Before submitting a PR (or before merging someone else's), use this checklist to catch common failure modes in Flutter/Dart code. If you are an AI agent contributing code, run through this before pushing.

#### State Management & Provider
- [ ] Providers are wired in `main.dart` `MultiProvider` — not created ad-hoc in widgets
- [ ] `Consumer<T>` or `context.watch<T>()` used for reactive UI — not manual `addListener`
- [ ] No `BuildContext` captured across async gaps — use `context.mounted` guard
- [ ] `ChangeNotifier` dispose logic handles all subscriptions

#### BLE / Transport Protocol
- [ ] Frame size respected — `maxFrameSize = 172` bytes from `meshcore_protocol.dart`
- [ ] Byte 0 is the command/response/push code — correct code mapping used
- [ ] Disconnection handled gracefully — auto-navigate back to scanner
- [ ] Connection state transitions are valid (disconnected → scanning → connecting → connected)
- [ ] No memory leak in frame streams — subscriptions disposed properly

#### UI / Widgets
- [ ] `const` constructors used where possible (performance)
- [ ] Material 3 widgets only — no Cupertino or custom widget frameworks
- [ ] No hardcoded strings that should be in `l10n/` ARB files
- [ ] `centerTitle: true` on AppBars
- [ ] Handles disconnection without crash (auto-navigate to scanner)
- [ ] `StatelessWidget + Consumer` pattern preferred over `StatefulWidget`

#### Storage & Persistence
- [ ] Keys scoped by device public key prefix (10 hex chars) where per-radio data
- [ ] `SharedPreferences` writes debounced for high-frequency operations (unread counts)
- [ ] No blocking I/O on the UI thread

#### Testing
- [ ] Tests added or updated for every change
- [ ] `flutter analyze` passes with zero warnings
- [ ] `flutter test` passes (all tests)
- [ ] New screens have basic widget tests

#### Known Issue Detection
- [ ] Does the diff reference any unfixed issue in `KNOWN_ISSUES.md`?
- [ ] Does the PR add new entries to `KNOWN_ISSUES.md`? Verify each one is real by checking the source code. Remove any that are speculative.
- [ ] Did testing reveal new edge cases worth documenting?

---

## Rejection Triggers

| Trigger | Why |
|---------|-----|
| `flutter analyze` produces any warnings or errors | Analysis must be clean — zero warnings |
| `flutter test` has any failures | Test suite must pass completely |
| Premature abstractions (helpers created for single use) | Adds unnecessary complexity — wait until needed in 3+ places |
| Hardcoded strings that belong in ARB localization files | Breaks i18n — all user-facing strings go in `lib/l10n/` |
| Missing `const` on widgets that don't change | Missed performance optimisation |
| `StatefulWidget` where `Consumer<T>` would work | Prefer `StatelessWidget + Provider` pattern |
| `BuildContext` used across async gaps without `mounted` check | Crashes on disposed widget — use `context.mounted` guard |
| Frame protocol violations (wrong byte 0, exceeding 172 bytes) | Breaks communication with connected device |
| Feature flags or backward-compatibility shims for old protocol versions | Dead code path — protocol versions are not additive |
| Commented-out code, dead code paths, or `// TODO:` without issue reference | Unmaintainable — each TODO needs a tracking issue |
| Broad changes touching 100+ files without clear scope | Impossible to review — split into focused PRs |

---

## Gotchas & Pitfalls

| Gotcha | Details |
|--------|---------|
| Frame size | `maxFrameSize = 172` bytes — byte 0 is the command code, so 171 bytes max payload |
| Device key scoping | Storage keys use first 10 hex chars of device pubkey — missing prefix = cross-device data leak |
| BLE on web | Unsupported in non-Chrome browsers — use `ChromeRequiredScreen` |
| USB on macOS | Device name resolution via `ioreg` in `macos_usb_device_names.dart` |
| Reboot command | UI sends `sendCliCommand('reboot')` — the `cmdReboot` code exists but no frame builder is wired |
| Companion radio format | `cmdSendTxtMsg` expects `[cmd][txt_type][attempt][timestamp x4][pub_key_prefix x6][text...]` — wrong format breaks compat |
| Group text packets | Payload is `[channel_hash (1)][MAC (2)][encrypted data...]` — sender not in payload; derive from path bytes |
| Identity hash | `PATH_HASH_SIZE` is 1 byte (pubkey prefix) — flooded packets append this as they traverse hops |
| Foreground service | `flutter_foreground_task` keeps BLE alive in background — android manifest must match |
| `intl` import | Required by `flutter_localizations` — don't remove from pubspec even if not directly imported |
