import '../../domain/entities/announcement.dart';

/// External representation and mapping are kept in the data layer.
class AnnouncementModel {
  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String body;
  final String category;
  final DateTime updatedAt;

  factory AnnouncementModel.fromMap(Map<String, Object?> map) =>
      AnnouncementModel(
        id: map['id']! as String,
        title: map['title']! as String,
        body: map['body']! as String,
        category: map['category']! as String,
        updatedAt: DateTime.parse(map['updatedAt']! as String),
      );

  Map<String, Object?> toMap() => {
    'id': id,
    'title': title,
    'body': body,
    'category': category,
    'updatedAt': updatedAt.toIso8601String(),
  };

  Announcement toEntity() => Announcement(
    id: id,
    title: title,
    body: body,
    category: category,
    updatedAt: updatedAt,
  );
}
