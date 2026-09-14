import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/stats_provider.dart';
import '../widgets/app_navigation_bar.dart';

/// UI for loading, error, and success states of the statistics request.
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch belongs in build because the UI must rebuild on state changes.
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Failed to load: $error'),
              const SizedBox(height: 12),
              FilledButton(
                // ref.read belongs in callbacks; it does not rebuild the page.
                onPressed: () => ref.read(statsProvider.notifier).retry(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (stats) => ListView.builder(
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];

            return ListTile(
              title: Text(stat.label),
              trailing: Text(stat.value),
            );
          },
        ),
      ),
      bottomNavigationBar: const AppNavigationBar(currentIndex: 1),
    );
  }
}
