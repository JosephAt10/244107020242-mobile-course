// import 'package:dio/dio.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'dart:async';

// import 'api_client.dart';
// import 'models/post.dart';
// import 'repositories/post_repository.dart';

// final dioProvider = Provider<Dio>((ref) => createDio());

// final postRepositoryProvider = Provider<PostRepository>(
//   (ref) => PostRepository(ref.watch(dioProvider)),
// );

// class PostListNotifier extends AsyncNotifier<List<Post>> {
//   @override
//   Future<List<Post>> build() async {
//     // Exceptions from the repository automatically become AsyncError.
//     // Automatic retry is disabled in the provider declaration below
//     // so errors are final and easy to test.
//     final repository = ref.watch(postRepositoryProvider);
//     return repository.fetchPosts();
//   }

//   Future<void> refresh() async {
//     state = const AsyncLoading();
//     try {
//       final repository = ref.read(postRepositoryProvider);
//       state = AsyncData(await repository.fetchPosts());
//     } catch (e, st) {
//       state = AsyncError(e, st);
//     }
//   }
// }

// final postListProvider = AsyncNotifierProvider<PostListNotifier, List<Post>>(
//   PostListNotifier.new,
//   // Disable Riverpod 3 automatic retry so errors are final
//   // and testable (otherwise the provider future in tests
//   // would retry and hang).
//   retry: (retryCount, error) => null,
// );

// String friendlyErrorMessage(Object error) {
//   if (error is DioException) {
//     switch (error.type) {
//       case DioExceptionType.connectionTimeout:
//       case DioExceptionType.sendTimeout:
//       case DioExceptionType.receiveTimeout:
//         return 'Slow connection or timeout. Check your internet and retry.';
//       case DioExceptionType.connectionError:
//         return 'Cannot reach the server. Check your internet connection.';
//       case DioExceptionType.badResponse:
//         final code = error.response?.statusCode;
//         if (code == 404) return 'Data not found (404).';
//         if (code == 401 || code == 403) {
//           return 'Access denied ($code). Check your credentials.';
//         }
//         return 'Server problem ($code). Try again later.';
//       default:
//         return 'A network error occurred. Try again.';
//     }
//   }
//   return 'An unexpected error occurred: $error';
// }

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';
import 'models/comment.dart';
import 'repositories/comment_repository.dart';

final dioProvider = Provider<Dio>((ref) {
  return createDio();
});

final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  return CommentRepository(ref.watch(dioProvider));
});

class CommentListNotifier extends AsyncNotifier<List<Comment>> {
  CommentListNotifier(this.postId);

  final int postId;

  @override
  Future<List<Comment>> build() {
    return ref.watch(commentRepositoryProvider).fetchComments(postId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading<List<Comment>>();

    state = await AsyncValue.guard(
      () => ref.read(commentRepositoryProvider).fetchComments(postId),
    );
  }
}

final commentListProvider =
    AsyncNotifierProvider.family<CommentListNotifier, List<Comment>, int>(
      CommentListNotifier.new,
    );

String friendlyErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return 'The request timed out. Check your connection and try again.';

      case DioExceptionType.connectionError:
        return 'Cannot reach the server. Check your internet connection.';

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;

        if (statusCode == 404) {
          return 'Comments were not found (404).';
        }
        if (statusCode == 500) {
          return 'The server had a problem (500). Try again later.';
        }
        return 'The server returned an error ($statusCode). Try again later.';

      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
        return 'A network error occurred. Try again.';

    }
  }

  return 'An unexpected error occurred. Try again.';
}
