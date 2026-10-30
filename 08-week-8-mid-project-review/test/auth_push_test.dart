import 'package:campus_notify/core/format.dart';
import 'package:campus_notify/features/auth/data/api_errors.dart';
import 'package:campus_notify/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('routeFromMessage handles empty, slash-less, and valid routes', () {
    expect(routeFromMessage({}), '/');
    expect(routeFromMessage({'route': 'announcement/3'}), '/announcement/3');
    expect(routeFromMessage({'route': '/announcement/3'}), '/announcement/3');
    expect(routeFromMessage({'route': '/settings'}), '/');
  });

  test('date formatting is pure and stable', () {
    expect(formatAnnouncementDate(DateTime(2026, 10, 8)), 'Oct 8, 2026');
  });

  test('mock auth creates demo token values for valid credentials', () async {
    final result = await MockAuthRepository().signIn(
      email: 'student@example.edu',
      password: 'secret1',
    );
    expect(result.value?.access, startsWith('mock-access-'));
    expect(result.value?.refresh, startsWith('mock-refresh-'));
  });

  test('expired mock refresh returns an authentication failure', () async {
    final result = await MockAuthRepository().refresh('mock-refresh-expired');
    expect(result.value, isNull);
    expect(result.failure?.message, contains('expired'));
  });
  test('Dio errors map to user-facing messages', () {
    final timeout = DioException(
      requestOptions: RequestOptions(path: '/'),
      type: DioExceptionType.connectionTimeout,
    );
    final unauthorized = DioException(
      requestOptions: RequestOptions(path: '/'),
      response: Response(
        requestOptions: RequestOptions(path: '/'),
        statusCode: 401,
      ),
    );
    expect(userMessageForDio(timeout), contains('timed out'));
    expect(userMessageForDio(unauthorized), contains('session expired'));
  });
}
