import '../routes.dart';

/// Parse FCM data without depending on Firebase, Flutter, or GoRouter.
String routeFromMessage(Map<String, dynamic> data) {
  final raw = data['route'];
  if (raw is! String || raw.trim().isEmpty) return AppRoutes.home;

  final route = raw.startsWith('/') ? raw : '/$raw';
  final match = RegExp(r'^/announcement/([A-Za-z0-9_-]+)$').firstMatch(route);
  return match == null
      ? AppRoutes.home
      : AppRoutes.announcement(match.group(1)!);
}

String formatAnnouncementDate(DateTime date) {
  final local = date.toLocal();
  final month = const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][local.month - 1];
  return '$month ${local.day}, ${local.year}';
}
