import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/announcements_providers.dart';

class AnnouncementPage extends ConsumerWidget {
  const AnnouncementPage({required this.id, super.key});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Announcement')),
    body: ref
        .watch(announcementByIdProvider(id))
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(failureMessage(error)),
                TextButton(
                  onPressed: () => ref.invalidate(announcementByIdProvider(id)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (announcement) {
            if (announcement == null) {
              return const Center(child: Text('Announcement not found.'));
            }
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.campaign,
                          size: 42,
                          color: Color(0xFF2457D6),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          announcement.title,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          announcement.body,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Announcement ID · ${announcement.id}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
  );
}
