import 'package:flutter_test/flutter_test.dart';
import 'package:week11_performance_optimization/features/ai/domain/daily_request_policy.dart';

void main() {
  const policy = DailyRequestPolicy(limit: 20);

  test('allows requests below the daily limit', () {
    expect(policy.allows(requestsToday: 19), isTrue);
  });

  test('blocks requests at and above the daily limit', () {
    expect(policy.allows(requestsToday: 20), isFalse);
    expect(policy.allows(requestsToday: 21), isFalse);
  });
}
