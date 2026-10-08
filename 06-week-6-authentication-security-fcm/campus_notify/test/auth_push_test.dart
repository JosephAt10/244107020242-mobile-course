import 'package:campus_notify/data/api_errors.dart';
import 'package:campus_notify/data/auth_repository.dart';
import 'package:campus_notify/routes.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('routeFromMessage handles empty and slash-less routes', () {
    expect(routeFromMessage({}), '/');
    expect(routeFromMessage({'route': 'announcement/3'}), '/announcement/3');
    expect(routeFromMessage({'route': '/announcement/3'}), '/announcement/3');
  });

  test('data payload carries the announcement id', () {
    const data = {'route': '/announcement/3', 'id': '3'};
    expect(data['id'], '3');
    expect(routeFromMessage(data), '/announcement/3');
  });

  test('mock auth creates session values for valid demo credentials', () async {
    final session = await AuthRepository().login(
      email: 'student@example.edu',
      password: 'secret1',
    );
    expect(session.access, startsWith('mock-access-'));
    expect(session.refresh, startsWith('mock-refresh-'));
  });

  test('failed refresh is reported so the caller can clear the session', () async {
    await expectLater(
      AuthRepository().refresh('mock-refresh-expired'),
      throwsFormatException,
    );
  });

  test('Dio errors map to user-facing timeout and unauthorized messages', () {
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
