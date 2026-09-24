# Handoff — Rockets app

**Read this first if you're picking up work on this app.**

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
