import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(darkModeProvider);
    final lastOpened = ref.watch(lastOpenedProvider);
    final offline = ref.watch(forceOfflineProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        SwitchListTile(
          title: const Text('Dark theme'),
          subtitle: const Text('Saved on this device'),
          value: theme.valueOrNull ?? false,
          onChanged: theme.isLoading
              ? null
              : (_) => ref.read(darkModeProvider.notifier).toggle(),
        ),
        SwitchListTile(
          title: const Text('Force offline mode'),
          subtitle: const Text('Disable simulated sync and network refresh'),
          value: offline,
          onChanged: (value) =>
              ref.read(forceOfflineProvider.notifier).state = value,
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.schedule),
          title: const Text('Last opened'),
          subtitle: lastOpened.when(
            data: (value) => Text(value == null
                ? 'Not recorded yet'
                : DateTime.tryParse(value)?.toLocal().toString() ?? value),
            loading: () => const Text('Loading…'),
            error: (error, stack) => const Text('Unavailable'),
          ),
        ),
        const ListTile(
          leading: Icon(Icons.storage_outlined),
          title: Text('Storage'),
          subtitle: Text(
              'SharedPreferences for settings; SQLite for notes and cached posts.'),
        ),
      ]),
    );
  }
}

final lastOpenedProvider = FutureProvider<String?>(
    (ref) => ref.watch(prefsRepositoryProvider).getLastOpened());
