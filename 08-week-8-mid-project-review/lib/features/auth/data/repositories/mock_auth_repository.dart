import '../../../../core/failure.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/auth_session_model.dart';

/// Demo adapter; replace with Firebase Auth or the campus API for production.
class MockAuthRepository implements AuthRepository {
  @override
  Future<OperationResult<AuthSession>> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    try {
      final safeUser = email.toLowerCase().trim();
      final model = AuthSessionModel.fromMap({
        'access_token': 'mock-access-$safeUser',
        'refresh_token': 'mock-refresh-$safeUser',
      });
      return OperationResult.success(model.toEntity());
    } catch (_) {
      return const OperationResult.failure(
        AuthenticationFailure('Sign in failed. Please try again.'),
      );
    }
  }

  @override
  Future<OperationResult<String>> refresh(String refreshToken) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (refreshToken.isEmpty || refreshToken == 'mock-refresh-expired') {
      return const OperationResult.failure(
        AuthenticationFailure('Refresh token expired. Please sign in again.'),
      );
    }
    return OperationResult.success(
      'mock-access-renewed-${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}
