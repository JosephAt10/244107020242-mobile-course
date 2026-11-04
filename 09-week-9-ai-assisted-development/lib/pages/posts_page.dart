import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_providers.dart';

class PostsPage extends ConsumerWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postsProvider);
    final offline = ref.watch(forceOfflineProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cached posts'),
        actions: [
          IconButton(
            tooltip: 'Refresh from network',
            onPressed: offline
                ? null
                : () => ref.read(postsProvider.notifier).refreshNow(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(offline
              ? 'Showing the local cache; network refresh is paused.'
              : 'Local posts appear first, then refresh from JSONPlaceholder.'),
        ),
        Expanded(
          child: posts.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) =>
                Center(child: Text('Unable to load cached posts: $error')),
            data: (items) => items.isEmpty
                ? const Center(
                    child: Text(
                        'No posts are cached yet. Connect and refresh once.'))
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final post = items[index];
                      return ListTile(
                        title: Text(post['title'] as String? ?? 'Untitled'),
                        subtitle: Text(post['body'] as String? ?? '',
                            maxLines: 3, overflow: TextOverflow.ellipsis),
                      );
                    },
                  ),
          ),
        ),
      ]),
    );
  }
}
