# Week 9 AI log — note title search

## Core prompt

> Role: senior Flutter developer. Context: extend the existing Offline Notes Flutter app using Riverpod, SQLite (`sqflite`), and the current repository flow. Task: add one small feature, note title search with a no-match empty state. Limits: keep the existing architecture; keep domain free of Flutter, Riverpod, SQLite, and Dio; search titles only; trim query whitespace and ignore case; blank query returns every note; do not change note persistence, sync, routes, or unrelated screens. Output a small implementation with a domain test, an empty-state widget test, and manual verification steps. Keep the change under 80 lines where practical.

## Pasted context

- Existing notes are domain values with `id`, `title`, `body`, `updatedAt`, and `dirty` fields; SQLite stores the persisted rows.
- `NoteRepository.fetchNotes()` returns notes ordered by `updated_at DESC` and the notes page watches them through Riverpod.
- Existing app dependencies include Flutter, Riverpod 2, `sqflite`, SharedPreferences, Dio, and GoRouter. No search package is needed.
- Preserve the existing add/edit/delete/offline/sync behavior. No credentials, tokens, or secrets were supplied.

## Initial AI output

The first proposed filter was:

```dart
List<Note> filterNotes(List<Note> notes, String query) {
  final term = query.trim();
  if (term.isEmpty) return notes;
  // Case-insensitive title search.
  return notes.where((note) => note.title.contains(term)).toList();
}
```

It also proposed showing a no-match message and a clear-search action. The code comment claimed case-insensitive matching, but the implementation called `contains` without normalizing either string.

## Verification and manual changes

- Added a regression case with title `Groceries` and query `groceries`. The unnormalized draft does not match, proving the comment's claim false.
- Implemented `FilterNotes` as a pure domain use case. It trims and lowercases the query and compares against lowercased titles; blank queries return all notes.
- Added a plain domain `Note` entity. Kept SQLite `Map` conversion in data `NoteModel` and mapped repository results back to the entity.
- Wired filtering through Riverpod. The notes page owns the query and renders results; `NoSearchResults` presents the no-match message and clear action.
- Tests cover case-insensitive/trimmed matching, blank query, no match, title-only matching, and the empty widget's clear callback.

## Accept/reject table

| Proposal or claim | Decision | Technical reason and evidence |
|---|---|---|
| Search titles and provide a no-match state with clear action | Accept | This is the requested feature. `FilterNotes` implements the rule; widget test checks the copy and callback. |
| `String.contains` is case-insensitive | Reject | False for Dart strings. The `Groceries` / `groceries` regression case exposes the mismatch; final code normalizes both sides. |
| Search the note body as well as title | Reject | Scope is title search. The `list` test string exists only in a body, and the filter returns no result. |
| Put filtering in the widget or SQL repository | Reject | The widget should render state; the storage query is unrelated to this in-memory title rule. Keeping it in a pure use case makes the behavior testable without UI or a database. |

### Evidence checks

The domain import scan below returned no matches (ripgrep exit code 1 means no matching imports were found):

```text
rg "package:(flutter|flutter_riverpod|sqflite|dio)|package:path|shared_preferences" lib/features/notes/domain
No matches found
```

The mapping scan found `toMap` / `fromMap` only in `lib/data/local/note.dart` and its uses in `lib/data/repositories/note_repository.dart`. Test assertions cover the `Groceries` / `groceries` match, a no-match result, body-only text not matching, and the clear-search callback.

## AI challenge reflection

1. **Hallucination found and proof:** the draft's comment promised case-insensitive matching but used case-sensitive `contains`. The mixed-case regression test proves it; lowercasing the title and query fixes it.
2. **Most useful prompt and changes:** the role/context/task/limits/output prompt named the real packages, exact title-only behavior, boundaries, and tests. The explicit constraints prevented changes to persistence and unrelated features.
3. **Refactor made:** moved search out of the widget into `FilterNotes`, introduced the domain entity, and kept SQLite mapping in `NoteModel`.
4. **Hardest decision:** whether to search note bodies. Rejected because the codelab specifically requests title search; the title-only test protects that decision.

## Verification record

The submitted terminal screenshots in `screenshots/` show successful results:

| Command | Recorded result | Evidence |
|---|---|---|
| `flutter analyze` | No issues found. | `screenshots/1.png` |
| `dart format --output=none --set-exit-if-changed .` | Formatted 19 files; 0 changed. | `screenshots/2.png` |
| `flutter test` | All 9 tests passed. | `screenshots/3.png` |

Test files: `test/features/notes/domain/filter_notes_test.dart`, `test/features/notes/presentation/no_search_results_test.dart`, and the existing `test/note_test.dart`.
