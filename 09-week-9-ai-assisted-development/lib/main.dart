import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'data/app_providers.dart';
import 'pages/notes_page.dart';
import 'pages/note_detail_page.dart';
import 'pages/posts_page.dart';
import 'pages/settings_page.dart';

void main() {
  runApp(const ProviderScope(child: OfflineNotesApp()));
}

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const NotesPage()),
    GoRoute(
      path: '/note/:id',
      builder: (context, state) =>
          NoteDetailPage(noteId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(path: '/posts', builder: (context, state) => const PostsPage()),
    GoRoute(
        path: '/settings', builder: (context, state) => const SettingsPage()),
  ],
);

class OfflineNotesApp extends ConsumerWidget {
  const OfflineNotesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkMode = ref.watch(darkModeProvider);
    return MaterialApp.router(
      title: 'Offline Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF356859)),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF78B7A1),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode:
          darkMode.valueOrNull == true ? ThemeMode.dark : ThemeMode.light,
      routerConfig: _router,
    );
  }
}
