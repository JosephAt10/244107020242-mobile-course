# Week 11 performance report

## Project and objective

This report covers the existing Offline Notes Flutter app and the Week 11 performance work, verified with Flutter DevTools, static analysis, and automated tests.

## Baseline and after measurements

The before and after DevTools captures are embedded in the README. They show 32 FPS before and 56 FPS after, corresponding to approximately 31.3 ms and 17.9 ms per frame (calculated from the displayed FPS). Both Memory views show 12.1 MB in the Dart Heap row. The capture durations differ, so these readings are observational rather than a controlled benchmark.

| Measurement | Baseline | After optimization |
| --- | --- | --- |
| Average frame rate | 32 FPS (DevTools capture) | 56 FPS (DevTools capture) |
| Approximate average frame time | 31.3 ms (calculated from 32 FPS) | 17.9 ms (calculated from 56 FPS) |
| Jank evidence | Red slow-frame bars visible; numeric total not shown | Red slow-frame bars visible; numeric total not shown |
| Dart heap shown in Memory profile | 12.1 MB | 12.1 MB |
| Flame Chart | No individual frame selected for function-level attribution | No individual frame selected for function-level attribution |

The recordings contain different amounts of activity, so their average FPS is directional evidence only. The screenshots do not show a numeric jank total or a selected Flame Chart function; no such values are inferred.

## Findings and optimizations

1. **Rebuild scope:** the page root watched note, sync-count, and offline-mode state, and the search field used `setState` per keypress. Independent widgets now own their Riverpod subscriptions: the banner watches offline state, the sync row watches sync/offline state, and the notes list watches notes and its query.
2. **Search work:** filtering ran for each keystroke, and query-keyed providers were kept until the container ended. Search now applies after 250 ms of inactivity and its state/result family is auto-disposed when unused.
3. **List painting:** the notes screen already used `ListView.builder`, so that lazy construction is retained. The list viewport now has a `RepaintBoundary` to isolate it from sibling content. The memory profiles show 12.1 MB Dart heap in both captures; retain the boundary only while it remains useful for isolating list painting.

Image optimization and pagination were not added because the reviewed notes/posts UI has no remote image feed or unbounded paginated feed. Adding those mechanisms without such a workload would add complexity without a demonstrated bottleneck.

## Verification commands

The terminal evidence shows clean static analysis and all 13 automated tests passing:

```sh
flutter analyze
flutter test
flutter run --profile
```

## Evidence files

The seven evidence images are embedded in the project README as `screenshots/1.png` through `screenshots/7.png`.

## Reflection

- **Largest observed impact:** the DevTools captures show average FPS rising from 32 to 56. The recordings have different durations, so the increase is directional evidence rather than a controlled benchmark.
- **Verification:** reviewed the Performance and Memory captures and confirmed the analyzer and all 13 tests passed.
- **Trade-offs:** debouncing adds a short delay before results update. `RepaintBoundary` adds a composited layer and memory overhead; the captured Dart heap remained 12.1 MB in both profiles.
- **Premature optimization:** do not add pagination, image caches, or architectural complexity until a real data volume, image workload, or measured trace justifies them.
