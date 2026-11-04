import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/note.dart';
import '../../domain/usecases/filter_notes.dart';

final filterNotesUseCaseProvider =
    Provider<FilterNotes>((ref) => const FilterNotes());

final searchNotesProvider =
    Provider.family<List<Note>, ({List<Note> notes, String query})>(
        (ref, input) {
  return ref.watch(filterNotesUseCaseProvider)(input.notes, input.query);
});
