class AuthSession {
  const AuthSession({required this.access, required this.refresh});

  final String access;
  final String refresh;
}

/// Demo-only mock authentication. Replace this adapter with Firebase Auth or
/// an HTTPS campus API before using real accounts. Never treat these values as JWTs.
class AuthRepository {
  Future<AuthSession> login({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!email.contains('@') || password.length < 6) {
      throw const FormatException('Enter a valid email and a password of at least 6 characters.');
    }
    final safeUser = email.toLowerCase().trim();
    return AuthSession(
      access: 'mock-access-$safeUser',
      refresh: 'mock-refresh-$safeUser',
    );
  }

  Future<String> refresh(String refreshToken) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (refreshToken.isEmpty || refreshToken == 'mock-refresh-expired') {
      throw const FormatException('Refresh token expired. Please sign in again.');
    }
    return 'mock-access-renewed-${DateTime.now().millisecondsSinceEpoch}';
  }
}
