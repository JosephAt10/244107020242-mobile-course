import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Immutable data shown by the statistics screen.
class StatItem {
  const StatItem({required this.label, required this.value});

  final String label;
  final String value;
}

/// Loads statistics asynchronously and owns the refresh behavior.
class StatsNotifier extends AsyncNotifier<List<StatItem>> {
  StatsNotifier({
    double Function()? randomValue,
    this.delay = const Duration(seconds: 2),
  }) : _randomValue = randomValue ?? Random().nextDouble;

  final double Function() _randomValue;
  final Duration delay;

  /// Riverpod calls this when the provider starts.
  @override
  Future<List<StatItem>> build() => _fetchStats();

  /// Called by the Retry button in the UI.
  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchStats);
  }

  /// Simulates a network request with a 30% chance of failure.
  Future<List<StatItem>> _fetchStats() async {
    await Future<void>.delayed(delay);

    if (_randomValue() < 0.3) {
      throw StateError('Could not load statistics.');
    }

    return const [
      StatItem(label: 'Tasks completed', value: '18'),
      StatItem(label: 'Tasks remaining', value: '7'),
      StatItem(label: 'Completion rate', value: '72%'),
    ];
  }
}

/// The app's one provider for the statistics page.
final statsProvider = AsyncNotifierProvider<StatsNotifier, List<StatItem>>(
  StatsNotifier.new,
);
