import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../main.dart' show messagingIssue, messagingReady, startPushService, tokenPreview;
import '../providers/auth_provider.dart';
import '../routes.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => startPushService());
  }

  @override
  Widget build(BuildContext context) {
    final email = ref.read(tokenStoreProvider).readAccess();
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Notify'), actions: [
        IconButton(tooltip: 'Sign out', onPressed: () => ref.read(authStateProvider.notifier).logout(), icon: const Icon(Icons.logout)),
      ]),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text('Your campus, in the loop.', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Important updates for classes, events, and campus life.'),
        const SizedBox(height: 22),
        _StatusCard(),
        const SizedBox(height: 20),
        Text('Latest announcements', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _AnnouncementTile(id: '3', title: 'Schedule changed', subtitle: 'Mobile class moved to Room A2 at 1:00 PM', icon: Icons.event_available),
        _AnnouncementTile(id: '2', title: 'Library hours', subtitle: 'The library is open until 8:00 PM this week.', icon: Icons.local_library_outlined),
        _AnnouncementTile(id: '1', title: 'Welcome to campus', subtitle: 'Your weekly campus digest is ready.', icon: Icons.campaign_outlined),
        const SizedBox(height: 18),
        FutureBuilder<String?>(future: email, builder: (context, snapshot) => Text(
          snapshot.data == null ? 'Authenticated session' : 'Signed in · ${snapshot.data!.replaceFirst('mock-access-', '')}',
          style: Theme.of(context).textTheme.bodySmall)),
      ]),
    );
  }
}

class _StatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Icon(Icons.verified_user_outlined), const SizedBox(width: 10),
        Text('Push notification status', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))]),
      const SizedBox(height: 12),
      ValueListenableBuilder<bool?>(
        valueListenable: messagingReady,
        builder: (_, ready, __) => ValueListenableBuilder<String?>(
          valueListenable: messagingIssue,
          builder: (_, issue, __) => Text(
            ready == true && issue == null
                ? 'Firebase ready · subscribed to campus-announcement'
                : issue ?? 'Firebase and notification status is not available yet.',
          ),
        ),
      ),
      const SizedBox(height: 12),
      ValueListenableBuilder<String?>(valueListenable: tokenPreview, builder: (_, preview, __) => Text(
        preview == null ? 'Token preview: unavailable' : 'FCM token preview: $preview')),
      const SizedBox(height: 8),
      const Text('Full tokens are never shown or written to app logs.', style: TextStyle(color: Colors.grey)),
    ])),
  );
}

class _AnnouncementTile extends StatelessWidget {
  const _AnnouncementTile({required this.id, required this.title, required this.subtitle, required this.icon});
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(leading: CircleAvatar(child: Icon(icon)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle), trailing: const Icon(Icons.chevron_right), onTap: () => context.go(AppRoutes.announcement(id))),
  );
}
