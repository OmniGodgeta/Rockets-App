# Rockets — notes for the next agent

**Read `docs/HANDOFF.md` first** for the full history of what's shipped and
why (v1.2.0-v1.2.2, the ISS longitude bug, etc.). This file tracks the
active roadmap only.

## Roadmap (added 2026-09-26, operator feedback verbatim)

> Okay you're a 98% token usage for the week, add the following text to the
> agent.md file in the roadmap and have the local AI start the work while
> you only supervise him.
>
> I really appreciate what you did in the Universe section it's really
> nice, this is the UI type I enjoy. For Rocket scale you did follow my
> guidelines, I appreciate you made the rectangles to scale but try to use
> a PNG with no background for the rocket so they can fill the rectangle
> properly. Also apply the Universe section UI to the ISS live now. space
> live and rocket history should play from the app itself, have the rocket
> history video start at 4 seconds. Right now both these sections only
> shows open in youtube can't play this video here, for the aurora
> forecast can we have a dark theme, if not it's okay. For the weather
> radar you did add a button to go farther in time but the clouds do not
> move at all, we can't track the weather if it's not tracking.

### v1.2.7 (2026-10-03): Launch Map, People in Space, The Moon

Menu items, in that order, under Star Map. Left uncommitted when the previous
session died mid-emulator-check; finished and checked on the emulator
2026-10-03 (12 launches / 10 pads, pad sheet opens; 14 people, ISS 11 and
Tiangong 3, photos load; last-quarter moon draws the lit half on the left).

- Launch Map reuses `LaunchRepository.fetchUpcoming()` (no extra API call)
  and the same Esri imagery tiles as ISS Live Now. Pads come from
  `Launch.padLatitude` / `padLongitude`, which the API returns as strings.
- People in Space is `AstronautRepository` → Launch Library 2
  `/astronaut/?in_space=true`, Hive-cached one hour. Agency objects have
  `name` and no `abbrev`; the short names are a table in `astronaut.dart`.
  Station is inferred from the latest flight name (Shenzhou → Tiangong,
  otherwise ISS). `test/astronaut_test.dart` pins that shape.
- The Moon is `lib/utils/moon_phase.dart` (Meeus, no network).
  `test/moon_phase_test.dart` pins it to the 2024-04-08 and 2025-03-14
  eclipses, within 2 hours.

### v1.2.6 (2026-10-03, operator asks): radar -> MyRadar, Star Map tracking

- Weather Radar = `ExternalApps.openOrStore(ExternalApps.myRadar)`
  (`com.acmeaom.android.myradar`, in the manifest `<queries>`). The in-app
  radar screen was deleted: don't bring it back.
- Star Map (`stellarium_screen.dart`): injected JS drives Stellarium Web's
  `window._stel.core.yaw/pitch` from `deviceorientationabsolute` (yaw =
  compass bearing, 0 = N, 90 = E, verified on the engine). **Chromium only
  sends orientation events to a focused page**, and a WebView isn't focused
  until touched: `ExternalApps.focusWebViews()` (MainActivity) fixes that.
  Without it tracking silently does nothing until the first tap. Verified on
  the emulator by moving its virtual sensors. No "GET APP" button; the
  cookie banner is auto-clicked. Geolocation is granted to the WebView.

### YouTube playback (v1.2.5, 2026-10-02): read this before touching it

`ed2512c`'s diagnosis below was incomplete: playback still failed on every
video. The player's own error screen said **152-4**
(youtube_player_iframe's wrapper) and **153** (bare embed URL): YouTube rejects
embeds that don't identify the embedding app. `RobustYoutubePlayer` now loads
`https://www.youtube.com/embed/<id>` directly in a WebView with
`Referer: https://com.shadowswords.rockets/`. Playback was verified on the
emulator when the Referer was `https://com.example.rockets/` (live ISS stream
and Rocket History, fullscreen). Remove the Referer and it breaks again.
youtube_player_iframe was dropped. The Referer must stay the same string as
`applicationId`.

### Already fixed directly (do not redo)

- **Space Live / Rocket History playback** - the actual bug was
  `RobustYoutubePlayer` (`lib/utils/robust_youtube_player.dart`) treating
  ANY `onWebResourceError` as fatal, when a WebView loading YouTube's embed
  page routinely hits benign sub-resource errors (blocked ad/analytics
  requests, a missing favicon) unrelated to whether the video plays. That's
  why it always fell back to "Open in YouTube" - fixed by removing
  `onWebResourceError` entirely; only the IFrame API's own `value.error`
  (real numbered YouTube errors) triggers the fallback now. Also added
  `startSeconds` support; Rocket History now starts at 4s. Commit
  `ed2512c`. **If it's still showing "can't play here" after this, that's a
  genuinely new problem - don't assume the old diagnosis still applies,
  re-investigate from scratch** (check `value.error`'s actual code via a
  debug print, don't guess).

### Status 2026-10-02 (v1.2.3): all four items below are DONE

Audited and finished by Claude Code. The local agent's attempts at #3/#4 were
unverified and didn't work, #1/#2 weren't really done, and it had left
`flutter analyze --fatal-infos` failing on main. Details in CHANGELOG v1.2.3.
The items are kept below for history only. Don't redo them.

**Orbit math: don't undo these** (`lib/utils/orbit_utils.dart`):
- `orbit.tPlusEpoch()` returns SECONDS; `getPosition()` wants MINUTES. Always `/ 60.0`.
- Never use `Julian.fromFullDate`: it's a day off in some months. Use `_julian()`.
- Never reuse an `Orbit` across steps: it carries state and gives wrong positions.
- `test/orbit_utils_test.dart` pins a live reference fix. If it fails, the math broke.

**Still worth doing** (not on the operator's list):
- Releases are signed with this PC's `~/.android/debug.keystore` (no
  key.properties). Updates only install over each other if every release
  uses that same key. Verify with `apksigner verify --print-certs`.
- On a real phone, check that the ISS "next visible pass" readout shows up
  (the emulator never gave a GPS fix). Pass math is unit-checked: Ottawa,
  Oct 13-16 morning passes.

### Package id (v1.2.9)

`com.shadowswords.rockets`. Android treats this as a different app from
`com.example.rockets`, so 1.2.8 will not update in place. Uninstall the old
copy, then install 1.2.9. Same debug signing key as the earlier releases.
YouTube's Referer is `https://com.shadowswords.rockets/`.

### Still open

- **H3** and **Starship + Super Heavy (V2)** on Rocket Scales still use the
  Wikipedia photo. Rechecked 2026-10-03: Commons has no transparent
  side-view diagram for either (H3 is photos and a logo; Starship's only
  transparent stack drawing is the FAA V3 sheet, which is already
  `starship_v3.png`). Do not invent a URL or generate a stand-in.

### Closed - do not redo

1. **Rocket Scales diagrams** (v1.2.8). Every other rocket uses a bundled
   transparent side view in `assets/rockets/` (credits in that folder's
   `CREDITS.md` and the info button). The height box math must not change.
   Long March 5, Atlas V (500-series, cropped from `Atlas V family.png`),
   and Delta IV Heavy were the last three added. `test/rocket_scale_assets_test.dart`
   checks each PNG actually has an alpha channel.
2. **ISS Live Now uses the Scale of the Universe panel style** (v1.2.8).
   The panel under the map is a centered circular badge, wide-tracked
   headline, accent readout pill, and bordered stat cards with accent
   values. Map zoom buttons use the same bordered surface. Do not touch
   the trajectory math (`docs/HANDOFF.md` v1.2.2).
3. **Aurora Forecast dark theme** already shipped: the WebView inverts the
   page and inverts images back (`aurora_screen.dart`). Leave it.
4. **Weather Radar is gone** (v1.2.6). The menu opens MyRadar. Do not
   bring `radar_screen.dart` back.

### Process for all of the above

- `flutter analyze --fatal-infos` from the repo root must exit 0 before any
  commit - actually run it, don't just claim it passes.
- Any native-dependency change needs a real `flutter build apk --debug`,
  not just analyze.
- Commit style: `feat:`/`fix:` with a body explaining the real change, not
  a generic message. Push to `origin main` yourself when a numbered item is
  genuinely done and verified - don't leave real work uncommitted.
- If genuinely blocked or unsure about scope on any item, say so in a
  kanban comment/block rather than guessing and shipping something
  half-right.
