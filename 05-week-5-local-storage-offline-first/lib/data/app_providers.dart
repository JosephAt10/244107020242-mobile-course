import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local/note.dart';
import 'prefs.dart';
import 'repositories/note_repository.dart';
import 'sync.dart';

final prefsRepositoryProvider =
    Provider<PrefsRepository>((ref) => PrefsRepository());
final noteRepositoryProvider =
    Provider<NoteRepository>((ref) => NoteRepository());
final syncServiceProvider = Provider<SyncService>(
    (ref) => SyncService(noteRepository: ref.watch(noteRepositoryProvider)));
final forceOfflineProvider = StateProvider<bool>((ref) => false);

final darkModeProvider =
    AsyncNotifierProvider<DarkModeNotifier, bool>(DarkModeNotifier.new);

class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.watch(prefsRepositoryProvider).getDarkMode();

  Future<void> toggle() async {
    final next = !(state.valueOrNull ?? false);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(prefsRepositoryProvider).setDarkMode(next);
      return next;
    });
  }
}

final notesProvider =
    AsyncNotifierProvider<NotesNotifier, List<Note>>(NotesNotifier.new);

class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() => ref.watch(noteRepositoryProvider).fetchNotes();

  Future<void> add({required String title, required String body}) async {
    await ref.read(noteRepositoryProvider).addNote(title: title, body: body);
    ref.invalidateSelf();
    ref.invalidate(dirtyCountProvider);
  }

  Future<void> saveNote(int id,
      {required String title, required String body}) async {
    await ref
        .read(noteRepositoryProvider)
        .updateNote(id, title: title, body: body);
    ref.invalidateSelf();
    ref.invalidate(dirtyCountProvider);
  }

  Future<void> delete(int id) async {
    await ref.read(noteRepositoryProvider).deleteNote(id);
    ref.invalidateSelf();
    ref.invalidate(dirtyCountProvider);
  }

  Future<int> sync() async {
    final count = await ref.read(syncServiceProvider).syncNotes(
          forceOffline: ref.read(forceOfflineProvider),
        );
    ref.invalidateSelf();
    ref.invalidate(dirtyCountProvider);
    return count;
  }
}

final dirtyCountProvider = FutureProvider<int>(
    (ref) => ref.watch(noteRepositoryProvider).countDirty());

final postsProvider =
    AsyncNotifierProvider<PostsNotifier, List<Map<String, dynamic>>>(
        PostsNotifier.new);

class PostsNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final service = ref.watch(syncServiceProvider);
    final cached = await service.readCachedPosts();
    if (!ref.watch(forceOfflineProvider)) unawaited(_refresh(service));
    return cached;
  }

  Future<void> _refresh(SyncService service) async {
    try {
      await service.refreshPosts();
      state = AsyncData(await service.readCachedPosts());
    } catch (_) {
      // The cached result remains available when the device has no connection.
    }
  }

  Future<void> refreshNow() async {
    if (ref.read(forceOfflineProvider)) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(syncServiceProvider);
      await service.refreshPosts();
      return service.readCachedPosts();
    });
  }
}
