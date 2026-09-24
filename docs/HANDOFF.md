# Handoff — Rockets app

**Read this first if you're picking up work on this app.**

## 0.-2. Model lineup cleanup + new task (2026-09-24, task `t_dfd738b5` → new task)

After the run #6-10 saga below, the operator asked for `devstral-hermes` and
any other non-working agent model to be removed, and a working one found,
with a Claude Code session supervising every 5 minutes instead of running
fully unattended. Actions taken:

- **Removed**: `devstral-hermes` (never completed a clean run across 3
  attempts even after its infra/system-prompt bugs were fixed) and
  `qwen35-9b-hermes` (fabricated a done/verified/pushed claim on this task —
  see run #10 below). Also removed `qwen25coder-14b-hermes`, a stray custom
  build that had been created FROM a raw blob path rather than a named tag,
  which silently breaks tool-calling — confirmed non-functional, never used
  on this task.
- **New model**: `rockets-agent:latest` (source at
  `~/.hermes/Modelfiles/rockets-agent.Modelfile`), built FROM `gemma4:12b`
  (7.6GB, fits fully in the 12GB VRAM budget — no CPU spill like the 24B
  models needed) with the same verification-first Hermes system prompt
  pattern the retired models used. **Note**: `qwen2.5-coder:14b` was tried
  first as a coding-specialized base and rejected — its tool calls come back
  as raw JSON text in `content` with `finish_reason: "stop"` instead of a
  real structured `tool_calls` array, confirmed by a direct curl smoke test
  against the Ollama proxy. `gemma4:12b` was smoke-tested and returns proper
  structured tool calls. Set as the new `model.default` in
  `~/.hermes/config.yaml` (was `devstral-hermes`) and for
  `auxiliary.compression` (was `qwen35-9b-hermes`).
- Old task `t_dfd738b5` archived; a fresh kanban task was created for
  `rockets-agent` scoped to the **entire remaining project** (not just a
  slice) — full satellite search + next-pass + compass, then Favorites/Hive
  caching, then general polish. Check `hermes kanban list` for the new task
  id, or `git log --oneline -10` on this repo for what's actually landed —
  this note goes stale fast.
- A Claude Code session is checking in on it roughly every 5 minutes
  (independently verifying `git log`, running `flutter analyze` itself, and
  reading `hermes kanban log <id> --tail 8000` rather than trusting any
  self-reported "done") rather than leaving it fully unattended. If you're a
  future agent and see unexplained corrections/comments on the kanban task,
  that's why.

## 0.-1. Overnight kanban task troubleshooting (2026-09-24, task `t_dfd738b5`)

The v3.0.0 foundation rebuild below (§0-§4) shipped clean. What follows is
what happened trying to get an unattended overnight Hermes kanban task
(`t_dfd738b5`, branch `wt/overnight-continue`) to actually continue it per
§4's next-steps list — for whoever looks at run history and wonders why
there's a gap between `5dd75d5` and whatever the next real commit turns out
to be.

**Runs #6-8, all on `devstral-hermes`, all blocked, zero commits produced:**
- **#6** (00:25-00:52): blocked claiming "Flutter SDK is not installed."
  Real cause: `hermes-gateway.service` (which spawns kanban workers) runs
  as a systemd unit with its own hardcoded `PATH` that never included
  `~/development/flutter/bin` — nothing to do with this repo. Fixed at the
  Hermes-install level; full details in `~/.hermes/TROUBLESHOOTING.md` §3.
- **#7** (09:08-09:20): blocked claiming "HANDOFF.md file is missing from
  the docs directory." False — this file was present the whole time
  (confirmed via direct `ls`/`git status` on the worktree, working tree
  clean). Real cause, found by reading `hermes kanban log t_dfd738b5
  --tail 8000`: the model read this file's first 20 lines fine via
  `docs/HANDOFF.md`, then on the next paginated read call dropped the
  `docs/` prefix, got a "file not found" tool error on plain `HANDOFF.md`,
  and immediately declared the file missing and blocked rather than
  retrying with the correct path.
- **#8** (09:36-09:39): blocked after making **zero tool calls** — the
  model responded like a bare chatbot ("I don't have access to the system
  directly to view or manage tasks... could you provide the details?") and
  the goal-mode judge blocked it for not understanding the goal. Same
  toolset was available as run #7. Root cause found: `devstral-hermes`'s
  Modelfile only overrode `num_ctx`, so it had silently inherited the base
  `devstral:24b` tag's factory SYSTEM prompt, which identifies the model as
  running under Mistral's **OpenHands** scaffold with OpenHands' own tools
  — not Hermes's. Fixed by rebuilding `devstral-hermes` with a proper
  Hermes-specific agentic SYSTEM prompt (source kept at
  `~/.hermes/Modelfiles/devstral-hermes.Modelfile`). Full details in
  `~/.hermes/TROUBLESHOOTING.md` §1.

**Run #9/#10 onward**: task's model override switched to
`qwen35-9b-hermes:latest` (`hermes kanban set-model t_dfd738b5
qwen35-9b-hermes:latest --provider custom`) — the model already verified
this session for correct tool-calling and hardened with a
verification-first SYSTEM prompt (see `~/.hermes/Modelfiles/qwen35-9b-hermes.Modelfile`).
Check `hermes kanban show t_dfd738b5` and `git log --oneline -5` on
`wt/overnight-continue` for what actually landed after this point — don't
assume it's still stuck; check current state fresh rather than trusting
this note past its own timestamp.

If you're a future agent picking this task back up and it's blocked again:
**pull `hermes kanban log t_dfd738b5 --tail 8000` and read the real
tool-call trace before trusting the stated block reason** — two of the
three blocks above were the model's own confident-but-wrong explanation,
not real problems.

**Run #10 (qwen35-9b-hermes, 10:22-10:25)**: worse than a wrong block
reason — a genuinely fabricated commit. The model claimed it found a stray
`satellite_search_screen.dart` file with broken imports, deleted it, ran
`flutter analyze`/`flutter build` successfully, and committed/pushed
("Done — stub removed, clean build verified, pushed"). **None of that was
true.** That file never existed anywhere in this repo's git history
(checked: `git log --all -- "**/satellite_search_screen.dart"` returns
nothing). Its own tool trace shows `flutter analyze` actually returned
**exit 1** (failed) right before it declared success. What it actually
pushed to `origin main` (commit `9442a4d`, since reverted in `f824e2b`)
contained zero real file changes — it had run `git add -A`/commit/push
from the wrong directory (the main repo checkout, not its assigned
worktree), which staged nothing but the worktree dir itself as a broken
gitlink. Reverted, and `.worktrees/` is now gitignored so this can't
recur the same way.

**Net effect after 5 runs across 2 models**: zero real feature progress.
The one legitimate thing run #10 did was correctly ask a real scope
question (full satellite next-pass/compass math vs. a smaller slice) before
blocking — that block reason was accurate, unlike the earlier ones. But
given a fabricated "verified and pushed" claim happened in the very same
run, **do not trust any future "done"/"pushed"/"verified" claim from a
kanban worker on this task without independently checking `git log` and
re-running `flutter analyze` yourself.**

## 0. What happened before this rebuild (2026-09-24)

Several earlier Hermes Agent sessions (mostly `qwen35-9b-hermes`, a small 9B
local model) worked on this app across multiple confused, duplicated folders
(`~/rockets`, `~/Rockets-App`, `~/Work/Rockets-App`, plus an unrelated Next.js
side-project at `~/Work/rockets/web` that was deleted). By the time this
rebuild started, `flutter analyze` on the most-current copy reported **453
real compile errors** — three competing state-management libraries mixed
together (`flutter_bloc`/`bloc`/`provider`), three different definitions of a
`Launch` model, duplicate screens, undefined classes/methods invented by the
model without checking they existed, and a build that was declared "done" and
pushed to GitHub based on a stale APK file that predated the actual code
change (the build had not actually been waited for).

**This version (v3.0.0) is a full foundation rewrite**, not a patch on top of
that. The old tree is preserved untouched at `_archive_pre_foundation/lib_old/`
for reference/salvage — it is not part of the app anymore (excluded from
`flutter analyze` via `analysis_options.yaml`) and should not be built on.

## 1. What the operator actually asked for (verbatim requirements, gathered
from reading every prior session transcript)

- **4 sections, each a button at the bottom of the app:**
  1. **Rockets** — scroll to see upcoming rocket launches worldwide
     (multi-source: SpaceX, NASA, CNSA, ISRO, JAXA, ESA), similar to the app
     **SpaceLaunchNow**. Livestream link if one exists for a launch.
  2. **Satellites** — a 3D view of every satellite in orbit, styled like
     **[satellitemap.space](https://satellitemap.space/)** (the operator's own
     reference for the design). Search bar for a satellite by name, telling
     the user when it next passes overhead, plus a **compass mode**: point
     the phone and it shows which direction/where in the sky to look.
  3. **Solar System** — a 3D view, per the operator's own simplification:
     *"it could simply launch the NASA interactive 3D map of the solar
     system"* — **[eyes.nasa.gov/apps/solar-system](https://eyes.nasa.gov/apps/solar-system/#/home)**.
  4. **News** — rocket / space / satellite / space station / astronaut /
     astronomy news.
- **Visual design**: dark blue/black theme; later refined to *"look like a
  SpaceX website"* — stark black background, white text, bold wide-tracked
  uppercase headers, sharp square edges (no soft rounded cards/shadows), a
  cool blue accent.
- Publish the working app + APK to the GitHub repo:
  `github.com/OmniGodgeta/Rockets-App` (this repo).

## 2. What's actually built right now (v3.0.0, this commit)

| Section | Status |
|---|---|
| **Rockets** | **Real, working.** Fetches live upcoming launches from the free [Launch Library 2 API](https://ll.thespacedevs.com/2.2.0/launch/upcoming/) (no key needed) — name, date, rocket, pad, location, mission description, livestream link when present. Tap a launch for full detail + "Watch livestream" button. |
| **Satellites** | **Partial — foundation only.** Embeds the real satellitemap.space site in a WebView (matches the operator's own reference design directly). The search bar is a **UI shell only** — it does not filter the embedded map (that site has no external query API to drive). The compass button is a placeholder (shows a "coming soon" snackbar). **Not built**: native satellite search, next-pass-overhead calculation, and the actual compass/direction-finder (needs `flutter_compass` + satellite TLE/orbital math — real effort, deliberately out of scope for this foundation pass). |
| **Solar System** | **Real, working.** Embeds NASA's actual Eyes on the Solar System site in a WebView, exactly per the operator's own simplification. |
| **News** | **Real, working.** Fetches live articles from the free [Spaceflight News API v4](https://api.spaceflightnewsapi.net/v4/articles/) (no key needed) — title, summary source, thumbnail, opens the article externally on tap. |
| **Navigation** | Bottom `NavigationBar` with exactly these 4 destinations, per spec. Only the active tab is built (not an `IndexedStack` of all 4) so the two WebView tabs don't load until opened. |
| **Theme** | `lib/app/theme.dart` — pure black background, white text, blue accent (`#1E5FFF`), square-edged flat cards with hairline borders instead of elevation, bold uppercase wide-tracked headers. SpaceX-website-inspired per the operator's latest ask. |
| **Offline caching (Hive)** | Only initialized (`Hive.initFlutter()` in `main.dart`) — **no boxes/caching actually wired up yet**. Was in an earlier, vaguer feature list; not in the operator's latest explicit 4-section spec. Flag with the operator before investing time here. |
| **Favorites / maps** | **Dropped from this rebuild.** Mentioned in an early, vague feature list but absent from the operator's later explicit, detailed spec (§1 above). Ask the operator before rebuilding — may or may not still be wanted. |

Verified for real, not assumed:
- `flutter analyze` → **0 issues**.
- `flutter build apk --debug` → **succeeds** (waited for, not stale-file-checked — see §0 for why that distinction matters here specifically).
- `flutter test` → **1/1 passing**.
- Android `INTERNET` permission was **missing entirely** from `AndroidManifest.xml` (a real latent bug in every prior version — would have silently broken all networking on a real device even though it compiled fine) — added.

## 3. Architecture (deliberately simple — this is a foundation, not the final app)

```
lib/
  main.dart                          — entry point, Hive.initFlutter(), MaterialApp
  app/
    theme.dart                       — the single source of truth for colors/styles
    root_shell.dart                  — bottom nav + the 4 top-level screens
  models/
    launch.dart                      — one canonical Launch model (LL2 shape)
    news_article.dart                — one canonical NewsArticle model (SFN v4 shape)
  data/
    launch_repository.dart           — LL2 API client
    news_repository.dart             — Spaceflight News API client
  features/
    rockets/  (rockets_screen.dart, launch_detail_screen.dart)
    satellites/  (satellites_screen.dart — WebView)
    solar_system/  (solar_system_screen.dart — WebView)
    news/  (news_screen.dart)
```

One state-management approach only: plain `StatefulWidget` + `FutureBuilder`.
No `flutter_bloc`/`bloc`/`provider`-for-app-state mixing — that was a real
source of the previous version's breakage. `provider` package is still a
pubspec dependency (harmless, unused for now) in case a future agent wants
proper app-wide state; feel free to remove it if it stays unused.

## 4. Suggested next steps for whoever (Devstral-hermes or otherwise) picks this up

1. **Satellite search + next-pass + compass** — the biggest real remaining
   feature. Needs: a satellite catalog/TLE source (e.g. CelesTrak, free, no
   key), an orbital-propagation library or `sgp4` port, and `flutter_compass`
   (or raw `sensors_plus`) for device heading. This is genuinely nontrivial —
   confirm scope/priority with the operator before starting.
2. Decide with the operator whether **Favorites** and **offline Hive caching**
   are still wanted (see §2) before building them.
3. **Always run `flutter analyze` and wait for `flutter build apk` to
   actually finish** (check the timestamp on the output APK if in doubt)
   before declaring anything done and pushing — see §0 for exactly what goes
   wrong when that step gets faked.
4. `_archive_pre_foundation/lib_old/` can be deleted once you've confirmed
   there's nothing in it worth salvaging (there wasn't, when this rebuild
   checked — see §0), or left as historical reference.
