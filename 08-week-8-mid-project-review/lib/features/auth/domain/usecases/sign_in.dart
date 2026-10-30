import '../../../../core/failure.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';
import '../validators/campus_email_validator.dart';

class SignIn {
  const SignIn(this._repository);
  final AuthRepository _repository;

  Future<OperationResult<AuthSession>> call({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (!isValidCampusEmail(normalizedEmail) || password.length < 6) {
      return const OperationResult.failure(
        ValidationFailure(
          'Enter a valid email and a password of at least 6 characters.',
        ),
      );
    }
    try {
      return await _repository.signIn(
        email: normalizedEmail,
        password: password,
      );
    } catch (_) {
      return const OperationResult.failure(
        AuthenticationFailure('Sign in failed. Please retry.'),
      );
    }
  }
}
