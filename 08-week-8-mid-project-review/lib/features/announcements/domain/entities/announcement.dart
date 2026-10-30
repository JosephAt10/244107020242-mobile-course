class Announcement {
  const Announcement({
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
}
