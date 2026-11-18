import 'package:flutter_test/flutter_test.dart';
import 'package:week12_testing_quality_assurance/features/ai/domain/daily_request_policy.dart';

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
