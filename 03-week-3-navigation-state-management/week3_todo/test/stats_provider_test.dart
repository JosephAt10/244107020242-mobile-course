import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:week3_todo/providers/stats_provider.dart';

void main() {
  test('StatsNotifier returns three items after a successful request', () async {
    final container = ProviderContainer(
      overrides: [
        statsProvider.overrideWith(
          () => StatsNotifier(
            randomValue: () => 0.9,
            delay: Duration.zero,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(
      container.read(statsProvider),
      const AsyncLoading<List<StatItem>>(),
    );

    final stats = await container.read(statsProvider.future);

    expect(stats, hasLength(3));
    expect(stats.first.label, 'Tasks completed');
  });

  test('StatsNotifier exposes an error when the request fails', () async {
    final container = ProviderContainer(
      overrides: [
        statsProvider.overrideWith(
          () => StatsNotifier(
            randomValue: () => 0.1,
            delay: Duration.zero,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(statsProvider.future),
      throwsA(isA<StateError>()),
    );

    expect(container.read(statsProvider).hasError, isTrue);
  });
}