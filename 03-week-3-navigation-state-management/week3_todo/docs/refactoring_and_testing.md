# Refactoring and Testing

## Changes Made

- Moved each ToDo row into `TodoTile`.
- Added `unfinishedTodosProvider`, which derives unfinished tasks from `todoListProvider`.
- Added GoRouter routes for `/` and `/stats`.
- Added a shared `NavigationBar` for switching between the ToDo list and statistics page.
- Opening Statistics from the navigation bar pushes `/stats`, so the system back button returns to the ToDo list.
- Added a widget test that adds a task through the user interface.

## Verification

- `ProviderScope` still wraps `MyApp`, so ToDo state remains available when routes change.
- `StatsPage` continues to handle loading, error, and data with `AsyncValue.when`.
- The ToDo provider creates new list instances for every state change.

## Commands

```bash
flutter analyze
flutter test
```
