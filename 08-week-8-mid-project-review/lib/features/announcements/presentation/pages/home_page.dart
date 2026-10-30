import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../messaging/push_status.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../routes.dart';
import '../providers/announcements_providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(
      title: const Text('Campus Notify'),
      actions: [
        IconButton(
          tooltip: 'Sign out',
          onPressed: () => ref.read(authStateProvider.notifier).logout(),
          icon: const Icon(Icons.logout),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Your campus, in the loop.',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('Important updates for classes, events, and campus life.'),
        const SizedBox(height: 22),
        const _StatusCard(),
        const SizedBox(height: 20),
        Text(
          'Latest announcements',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ref
            .watch(announcementsProvider)
            .when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Column(
                children: [
                  Text(failureMessage(error)),
                  TextButton(
                    onPressed: () => ref.invalidate(announcementsProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
              data: (items) => Column(
                children: items
                    .map(
                      (item) => Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Icon(_iconFor(item.category)),
                          ),
                          title: Text(
                            item.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(item.body),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () =>
                              context.go(AppRoutes.announcement(item.id)),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        const SizedBox(height: 18),
        ref
            .watch(currentUserEmailProvider)
            .when(
              data: (email) => Text(
                email == null ? 'Authenticated session' : 'Signed in · $email',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const Text('Authenticated session'),
            ),
      ],
    ),
  );
}

IconData _iconFor(String category) => switch (category) {
  'schedule' => Icons.event_available,
  'library' => Icons.local_library_outlined,
  _ => Icons.campaign_outlined,
};

class _StatusCard extends StatelessWidget {
  const _StatusCard();

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user_outlined),
              const SizedBox(width: 10),
              Text(
                'Push notification status',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<bool?>(
            valueListenable: messagingReady,
            builder: (_, ready, _) => ValueListenableBuilder<String?>(
              valueListenable: messagingIssue,
              builder: (_, issue, _) => Text(
                ready == true && issue == null
                    ? 'Firebase ready · subscribed to campus-announcement'
                    : issue ?? 'Firebase and notification status is not available yet.',
              ),
            ),
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<String?>(
            valueListenable: tokenPreview,
            builder: (_, preview, _) => Text(
              preview == null
                  ? 'Token preview: unavailable'
                  : 'FCM token preview: $preview',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Full tokens are never shown or written to app logs.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    ),
  );
}
