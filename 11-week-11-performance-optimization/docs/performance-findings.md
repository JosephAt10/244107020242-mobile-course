# Performance findings

## Source inspection before changes

The initial Week 10 `NotesPage` watched `notesProvider`, `dirtyCountProvider`, and `forceOfflineProvider` at the page root. Its search field also called `setState` for every character. That meant a keystroke rebuilt the page subtree even though only the search input and visible result list needed the query.

The `searchNotesProvider` was a non-auto-dispose family keyed by both the list and query. Different queries could leave family instances alive for the lifetime of the provider container. The list itself already used `ListView.builder`, so off-screen note rows were already constructed lazily.

The notes and posts screens do not display remote images. The reviewed UI also does not contain a long paginated feed. Image decoding/caching and pagination therefore were not selected as optimizations for this app.

## Changes applied

| Finding | Change | Expected effect | Trade-off / verification |
| --- | --- | --- | --- |
| Root page rebuilt for independent provider changes and each search keystroke. | Split offline banner, sync controls, search field, and list into separate widgets; each consumer watches only its state. | Provider notifications are limited to the relevant subtree. | The profile captures show 32 FPS before and 56 FPS after; different recording durations make this directional evidence. |
| Search filtered on every keypress and query-family entries were retained. | Debounce query updates by 250 ms and make search state/results auto-dispose. | Fewer filter executions while typing and no retained per-query results after leaving the screen. | Search updates after a short pause; the two Memory captures both show 12.1 MB Dart heap. |
| Scrolling note content is a distinct paint area. | Keep `ListView.builder` and put the list viewport inside a `RepaintBoundary`. | Separates list painting from sibling banner/sync content. | The screenshots show 12.1 MB Dart heap in both sessions; they do not isolate the boundary's individual memory cost. |

## DevTools profiling record

Both rows below are transcribed from the saved DevTools profile screenshots. The sessions used the Android profile build, but the screenshots contain different amounts of recorded activity, so the FPS comparison is directional rather than a controlled benchmark.

| Metric | Before | After |
| --- | --- | --- |
| Average frame rate | 32 FPS | 56 FPS |
| Approximate frame time | 31.3 ms | 17.9 ms |
| Jank | Red slow-frame bars visible; numeric total not shown | Red slow-frame bars visible; numeric total not shown |
| Dart heap | 12.1 MB | 12.1 MB |
| Flame Chart | No individual frame selected for function-level attribution | No individual frame selected for function-level attribution |

The before/after FPS and heap values come from the images embedded in the project README (`screenshots/1.png` through `screenshots/7.png`). Frame times are calculated from displayed FPS. Because the recordings have different durations, the FPS change is directional evidence rather than a controlled benchmark.

## Repeatable scenario

The recorded sessions used Flutter DevTools Performance and Memory on the Android profile build. The Performance captures show the frame-time bars and average FPS; the Memory captures show the profile memory chart and Dart Heap size before and after navigation activity. Static analysis and all 13 tests passed, with terminal evidence embedded in the README.
