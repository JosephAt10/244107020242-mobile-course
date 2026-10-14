sealed class Failure {
  const Failure(this.message);
  final String message;
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message);
}

final class LocalFailure extends Failure {
  const LocalFailure(super.message);
}

final class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

final class OperationResult<T> {
  const OperationResult.success(T data) : value = data, failure = null;
  const OperationResult.failure(Failure error) : value = null, failure = error;

  final T? value;
  final Failure? failure;
  bool get isSuccess => failure == null;
}