import 'package:campus_notify/core/failure.dart';
import 'package:campus_notify/features/auth/domain/entities/auth_session.dart';
import 'package:campus_notify/features/auth/domain/repositories/auth_repository.dart';
import 'package:campus_notify/features/auth/domain/usecases/sign_in.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository(this.signInResult);
  final OperationResult<AuthSession> signInResult;

  @override
  Future<OperationResult<AuthSession>> signIn({
    required String email,
    required String password,
  }) async => signInResult;

  @override
  Future<OperationResult<String>> refresh(String refreshToken) async =>
      const OperationResult.failure(AuthenticationFailure('refresh expired'));
}

void main() {
  test('SignIn returns a successful session from the fake repository', () async {
    const session = AuthSession(access: 'access', refresh: 'refresh');
    final result = await SignIn(FakeAuthRepository(
      const OperationResult.success(session),
    ))(email: ' STUDENT@EXAMPLE.EDU ', password: 'secret1');
    expect(result.value, same(session));
    expect(result.failure, isNull);
  });

  test('SignIn returns validation failure for invalid credentials', () async {
    final result = await SignIn(FakeAuthRepository(
      const OperationResult.failure(AuthenticationFailure('not expected')),
    ))(email: 'bad', password: 'short');
    expect(result.value, isNull);
    expect(result.failure, isA<ValidationFailure>());
  });
}