import '../../features/notes/domain/entities/note.dart';

/// SQLite representation of a note. Mapping stays in the data layer.
class NoteModel {
  const NoteModel({
    this.id,
    required this.title,
    this.body = '',
    required this.updatedAt,
    this.dirty = false,
  });

  final int? id;
  final String title;
  final String body;
  final DateTime updatedAt;
  final bool dirty;

  factory NoteModel.fromMap(Map<String, Object?> map) => NoteModel(
    id: (map['id'] as num?)?.toInt(),
    title: map['title'] as String? ?? '',
    body: map['body'] as String? ?? '',
    updatedAt:
        DateTime.tryParse(map['updated_at'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
    dirty: ((map['dirty'] as num?)?.toInt() ?? 0) == 1,
  );

  factory NoteModel.fromEntity(Note note) => NoteModel(
    id: note.id,
    title: note.title,
    body: note.body,
    updatedAt: note.updatedAt,
    dirty: note.dirty,
  );

  Note toEntity() => Note(
    id: id,
    title: title,
    body: body,
    updatedAt: updatedAt,
    dirty: dirty,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'title': title,
    'body': body,
    'updated_at': updatedAt.toIso8601String(),
    'dirty': dirty ? 1 : 0,
  };
}
