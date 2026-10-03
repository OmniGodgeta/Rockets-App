# 2026-10-03 — Launch Map, People in Space, The Moon

A Claude session wrote these three Rockets screens and stopped before
commit, while Peak v1.4.0 was already tagged. This session checked them on
the emulator, fixed a failed refresh that would have shown "0 people",
fixed "1 days", and shipped them as v1.2.7.

Emulator (pixel_api35): Launch Map showed 12 launches from 10 pads and
opened SLC-41. People in Space showed 14 people, 11 on the ISS (Crew-12,
Soyuz MS-29, Crew-13) and 3 on Tiangong (Shenzhou 23), plus the Starman
footnote. The Moon showed last quarter, 47% lit, next new moon Oct 10.

`flutter analyze --fatal-infos` clean. `flutter test` 10/10.
