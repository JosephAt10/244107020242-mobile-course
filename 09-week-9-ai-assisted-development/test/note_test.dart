import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/data/app_providers.dart';
import 'package:week5_offline_notes/data/local/note.dart';
import 'package:week5_offline_notes/data/repositories/note_repository.dart';
import 'package:week5_offline_notes/features/notes/domain/entities/note.dart';

class FakeNoteRepository extends NoteRepository {
  FakeNoteRepository({this.items = const [], this.throwError = false})
      : super(openDb: () => throw UnimplementedError());

  final List<Note> items;
  final bool throwError;

  @override
  Future<List<Note>> fetchNotes() async {
    if (throwError) throw Exception('db locked (simulated)');
    return items;
  }

  @override
  Future<int> countDirty() async => items.where((note) => note.dirty).length;
}

void main() {
  test('model supplies safe defaults for missing fields', () {
    final note = NoteModel.fromMap({'title': 'Groceries'}).toEntity();
    expect(note.title, 'Groceries');
    expect(note.body, '');
    expect(note.dirty, isFalse);
    expect(note.updatedAt, DateTime.fromMillisecondsSinceEpoch(0));
  });

  test('dirty flag survives model serialization', () {
    final note = Note(
      title: 'Draft',
      updatedAt: DateTime(2026, 9, 18),
      dirty: true,
    );
    final model = NoteModel.fromMap(NoteModel.fromEntity(note).toMap());
    expect(model.toEntity().dirty, isTrue);
  });

  test('notes provider loads through a fake repository', () async {
    final container = ProviderContainer(overrides: [
      noteRepositoryProvider.overrideWithValue(FakeNoteRepository(items: [
        Note(title: 'Test note', updatedAt: DateTime(2026)),
      ])),
    ]);
    addTearDown(container.dispose);
    final notes = await container.read(notesProvider.future);
    expect(notes, hasLength(1));
    expect(notes.first.title, 'Test note');
  });

  test('notes provider forwards repository errors', () async {
    final container = ProviderContainer(overrides: [
      noteRepositoryProvider
          .overrideWithValue(FakeNoteRepository(throwError: true)),
    ]);
    addTearDown(container.dispose);
    await expectLater(
      container.read(notesProvider.future),
      throwsA(isA<Exception>()),
    );
  });
}
