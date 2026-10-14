import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/failure.dart';
import '../../data/datasources/token_store.dart';
import '../../data/repositories/mock_auth_repository.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in.dart';

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => MockAuthRepository(),
);
final signInProvider = Provider<SignIn>(
  (ref) => SignIn(ref.watch(authRepositoryProvider)),
);
final authStateProvider = AsyncNotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    try {
      return (await ref.read(tokenStoreProvider).readAccess()) != null;
    } catch (_) {
      throw const LocalFailure('Unable to restore the saved session. Please sign in again.');
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(signInProvider)(
        email: email,
        password: password,
      );
      if (result.failure case final Failure failure) throw failure;
      final AuthSession session = result.value!;
      try {
        await ref.read(tokenStoreProvider).save(
          access: session.access,
          refresh: session.refresh,
        );
      } catch (_) {
        throw const LocalFailure('Could not securely save the session. Please retry.');
      }
      ref.invalidate(currentUserEmailProvider);
      return true;
    });
  }

  Future<void> logout() async {
    try {
      await ref.read(tokenStoreProvider).clear();
      ref.invalidate(currentUserEmailProvider);
      state = const AsyncData(false);
    } catch (_) {
      state = AsyncError(
        const LocalFailure('Could not securely end the session. Please retry.'),
        StackTrace.current,
      );
    }
  }
}
final currentUserEmailProvider = FutureProvider<String?>((ref) async {
  try {
    final access = await ref.watch(tokenStoreProvider).readAccess();
    if (access == null) return null;
    return access.startsWith('mock-access-')
        ? access.replaceFirst('mock-access-', '')
        : null;
  } catch (_) {
    throw const LocalFailure('Could not read the signed-in account.');
  }
});