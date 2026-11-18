import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week12_testing_quality_assurance/data/app_providers.dart';
import 'package:week12_testing_quality_assurance/data/prefs.dart';
import 'package:week12_testing_quality_assurance/data/repositories/note_repository.dart';
import 'package:week12_testing_quality_assurance/features/notes/domain/entities/note.dart';
import 'package:week12_testing_quality_assurance/pages/notes_page.dart';

class _FakePrefsRepository extends PrefsRepository {
  @override
  Future<void> markOpenedNow() async {}
}

class _FakeNoteRepository extends NoteRepository {
  _FakeNoteRepository({this.failFetch = false, this.failAdd = false})
    : super(openDb: () => throw UnimplementedError());

  final bool failFetch;
  final bool failAdd;
  final List<Note> notes = [];

  @override
  Future<List<Note>> fetchNotes() async {
    if (failFetch) throw Exception('database unavailable');
    return List.unmodifiable(notes);
  }

  @override
  Future<Note> addNote({required String title, String body = ''}) async {
    if (failAdd) throw Exception('database is read-only');
    final note = Note(
      id: notes.length + 1,
      title: title,
      body: body,
      updatedAt: DateTime(2026, 1, 1),
      dirty: true,
    );
    notes.add(note);
    return note;
  }

  @override
  Future<int> countDirty() async => notes.where((note) => note.dirty).length;
}

Widget _testApp(_FakeNoteRepository repository) => ProviderScope(
  overrides: [
    prefsRepositoryProvider.overrideWithValue(_FakePrefsRepository()),
    noteRepositoryProvider.overrideWithValue(repository),
  ],
  child: const MaterialApp(home: NotesPage()),
);

void main() {
  testWidgets('rejects a blank title and keeps the editor open', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(_FakeNoteRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('New note'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a title'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(find.text('No notes yet. Add one to get started.'), findsOneWidget);
  });

  testWidgets('saves a valid note and displays it in the list', (tester) async {
    final repository = _FakeNoteRepository();
    await tester.pumpWidget(_testApp(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('New note'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('note-title-field')),
      'Read the material',
    );
    await tester.enterText(
      find.byKey(const Key('note-body-field')),
      'Week 12 testing',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Read the material'), findsOneWidget);
    expect(repository.notes, hasLength(1));
    expect(repository.notes.single.body, 'Week 12 testing');
  });

  testWidgets('shows a friendly message when saving fails', (tester) async {
    await tester.pumpWidget(_testApp(_FakeNoteRepository(failAdd: true)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('New note'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('note-title-field')),
      'Cannot save',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Could not save note. Try again.'), findsOneWidget);
  });

  testWidgets('shows retry UI when notes cannot be loaded', (tester) async {
    await tester.pumpWidget(_testApp(_FakeNoteRepository(failFetch: true)));
    await tester.pumpAndSettle();

    expect(find.text('Could not load notes.'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });
}
