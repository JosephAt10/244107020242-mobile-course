import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/features/notes/domain/entities/note.dart';
import 'package:week5_offline_notes/features/notes/domain/usecases/filter_notes.dart';

void main() {
  final filterNotes = const FilterNotes();
  final notes = [
    Note(title: 'Groceries', body: 'milk', updatedAt: DateTime(2026)),
    Note(
        title: 'Class notes',
        body: 'Groceries list in body',
        updatedAt: DateTime(2026)),
    Note(title: 'Read later', updatedAt: DateTime(2026)),
  ];

  test('matches title without case sensitivity or surrounding query spaces',
      () {
    final result = filterNotes(notes, '  groceries ');
    expect(result.map((note) => note.title), ['Groceries']);
  });

  test('returns all notes for an empty query', () {
    expect(filterNotes(notes, '   '), hasLength(3));
  });

  test('returns no notes when title has no match', () {
    expect(filterNotes(notes, 'missing'), isEmpty);
  });

  test('searches titles only, not note bodies', () {
    expect(filterNotes(notes, 'list'), isEmpty);
  });
}
