abstract final class AppRoutes {
  static const login = '/login';
  static const home = '/';
  static const announcementPattern = '/announcement/:id';

  static String announcement(String id) => '/announcement/$id';
}

/// Converts FCM data into a safe in-app route without depending on Firebase.
String routeFromMessage(Map<String, dynamic> data) {
  final raw = data['route'];
  if (raw is! String || raw.trim().isEmpty) return AppRoutes.home;

  final route = raw.startsWith('/') ? raw : '/$raw';
  // Only accept the announcement route supported by this app.
  final match = RegExp(r'^/announcement/([A-Za-z0-9_-]+)$').firstMatch(route);
  return match == null ? AppRoutes.home : AppRoutes.announcement(match.group(1)!);
}
