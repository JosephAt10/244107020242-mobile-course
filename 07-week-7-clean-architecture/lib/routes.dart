abstract final class AppRoutes {
  static const login = '/login';
  static const home = '/';
  static const announcementPattern = '/announcement/:id';

  static String announcement(String id) => '/announcement/$id';
}