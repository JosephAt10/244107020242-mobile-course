import '../entities/note.dart';

/// Filters notes by title, ignoring letter case and surrounding query spaces.
class FilterNotes {
  const FilterNotes();

  List<Note> call(Iterable<Note> notes, String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return List<Note>.unmodifiable(notes);

    return List<Note>.unmodifiable(
      notes.where((note) => note.title.toLowerCase().contains(normalizedQuery)),
    );
  }
}
