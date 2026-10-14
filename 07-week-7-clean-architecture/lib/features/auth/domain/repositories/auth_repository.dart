import '../../../../core/failure.dart';
import '../entities/auth_session.dart';

abstract interface class AuthRepository {
  Future<OperationResult<AuthSession>> signIn({
    required String email,
    required String password,
  });

  Future<OperationResult<String>> refresh(String refreshToken);
}