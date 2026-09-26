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

### Still open - pick these up

1. **Rocket Scales: real PNG images with no background.**
   `lib/features/rocket_scale/rocket_scale_screen.dart` currently fetches
   each rocket's photo via `WikipediaThumbnail` (`lib/utils/
   wikipedia_thumbnail.dart`, `circular: false, fit: BoxFit.contain`) inside
   an accurately-scaled height box - the box sizing is correct and should
   NOT change. The problem is the *source image*: a Wikipedia infobox photo
   is an arbitrary rectangular photograph (often on a white/sky background,
   often not even the whole rocket top-to-bottom), so `BoxFit.contain`
   leaves a lot of the height-accurate box empty. The operator wants a real
   PNG with a transparent (no) background per rocket instead, so the
   drawing fills the box the way a proper side-view rocket diagram would.
   This needs REAL image URLs, not invented ones - the established failure
   mode on this exact project is a model inventing a plausible-sounding
   URL that 404s. Before wiring anything in, verify every URL actually
   resolves to an image (`curl -s -o /dev/null -w "%{http_code} %{content_type}\n" <url>`
   must show `200` and an image content-type) - do this for all ~16
   rockets in `lib/data/rocket_scale_data.dart` before writing any Dart.
   Good sources to check: Wikimedia Commons often has separate
   transparent-background technical diagrams distinct from the infobox
   photo (search on commons.wikimedia.org, not just the Wikipedia article's
   own infobox image) - check each file's actual page to confirm it's a
   PNG with real transparency, not a photo with a white background (those
   won't look right in a dark-themed app either). If a genuinely
   transparent, correctly-shaped image can't be found and verified for a
   given rocket, leave that one on the current photo-in-a-box rather than
   wiring in an invented or unverified URL.
2. **Apply the Scale-of-the-Universe UI style to ISS Live Now.** The
   operator explicitly likes `lib/features/scale/scale_screen.dart`'s look
   (dark cards, `AppTheme.surface`/`AppTheme.surfaceBorder` bordered boxes,
   `WikipediaThumbnail` circular badges, the accent-colored size readout
   pill) and wants that visual language applied to
   `lib/features/satellites/iss_live_now_screen.dart`. This is a styling/
   layout pass, not a rebuild - keep the real map, the footprint circle,
   the follow logic, and the trajectory line from the current
   implementation (all real, working, recently fixed - see
   `docs/HANDOFF.md`'s v1.2.2 entry for why the trajectory math is
   correctness-critical and must not be touched here). Focus this task on
   the STATS PANEL below the map (`_StatTile` widgets for LATITUDE/
   LONGITUDE/ALTITUDE/NEXT PASS) and general chrome (card borders, spacing,
   accent color usage) to match scale_screen.dart's visual style, not the
   map itself.
3. **Aurora Forecast: dark theme if feasible.**
   `lib/features/aurora/aurora_screen.dart` is a raw WebView of
   spaceweather.gov's own page, which has its own light theme baked into
   its HTML - there is no clean native way to override another site's
   styling. The operator said "if not it's okay" - so try ONE reasonable
   approach (inject a dark-mode CSS override via
   `_controller.runJavaScript(...)` after the page loads, in
   `setNavigationDelegate`'s `onPageFinished` callback - look at how other
   screens in this app use `WebViewController` for the right pattern) and
   if the result looks broken/unreadable rather than genuinely improved,
   leave the screen as-is and say so in the commit message rather than
   shipping a half-working CSS hack.
4. **Weather Radar: the animate button doesn't actually move the clouds.**
   `lib/features/radar/radar_screen.dart`'s `TileLayer` for the radar
   overlay (around line 179, `urlTemplate: _radarTileUrlTemplate`) has no
   explicit `key`. `_radarTileUrlTemplate` is a getter that changes with
   `_frameIndex`, and the play button (added in commit `5b0d23a`) does
   correctly advance `_frameIndex` via `setState` - but if the visible
   tiles never update, the most likely cause is flutter_map/Flutter's own
   image caching treating this as the "same" layer since only a prop
   changed, not the widget's identity. **First thing to try**: give that
   `TileLayer` `key: ValueKey(_radarTileUrlTemplate)` so Flutter fully
   reconstructs it (and its tile cache) on every frame change, and confirm
   the fix by actually checking a change in what's rendered (e.g.
   temporarily log `_radarTileUrlTemplate` on each frame change with
   `debugPrint` and confirm it's really a different URL each time, not just
   confirm the key change compiles). If that alone doesn't fix it, check
   whether flutter_map's own tile cache (`TileLayer`'s `tileProvider` /
   any FMTC-style disk cache) needs an explicit "don't cache across
   different urlTemplates" setting - do not guess, check the installed
   flutter_map version's actual source
   (`~/.pub-cache/hosted/pub.dev/flutter_map-*/lib/src/layer/tile_layer/`)
   for how it decides whether to refetch.

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
