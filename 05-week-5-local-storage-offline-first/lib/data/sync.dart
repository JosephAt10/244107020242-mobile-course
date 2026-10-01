import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';

import 'local/db.dart';
import 'repositories/note_repository.dart';

class SyncService {
  SyncService({
    NoteRepository? noteRepository,
    Future<Database> Function()? openDb,
    Dio? dio,
  })  : _notes = noteRepository ?? NoteRepository(openDb: openDb),
        _openDb = openDb ?? openNotesDb,
        _dio = dio ??
            Dio(BaseOptions(
                connectTimeout: const Duration(seconds: 5),
                receiveTimeout: const Duration(seconds: 8)));

  final NoteRepository _notes;
  final Future<Database> Function() _openDb;
  final Dio _dio;

  Future<int> syncNotes({required bool forceOffline}) async {
    if (forceOffline) return 0;
    final dirtyCount = await _notes.countDirty();
    if (dirtyCount == 0) return 0;
    // The codelab has no write API, so this delay simulates a successful upload.
    await Future<void>.delayed(const Duration(seconds: 1));
    await _notes.markAllSynced();
    return dirtyCount;
  }

  Future<List<Map<String, dynamic>>> readCachedPosts() async {
    final db = await _openDb();
    final rows = await db.query('cached_posts', orderBy: 'id ASC');
    return rows
        .map((row) =>
            jsonDecode(row['payload']! as String) as Map<String, dynamic>)
        .toList();
  }

  Future<void> refreshPosts() async {
    final response = await _dio
        .get<List<dynamic>>('https://jsonplaceholder.typicode.com/posts');
    final posts = response.data ?? const [];
    final db = await _openDb();
    final batch = db.batch();
    for (final value in posts) {
      final post = Map<String, dynamic>.from(value as Map);
      batch.insert(
        'cached_posts',
        {
          'id': post['id'],
          'payload': jsonEncode(post),
          'cached_at': DateTime.now().toIso8601String()
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
}
