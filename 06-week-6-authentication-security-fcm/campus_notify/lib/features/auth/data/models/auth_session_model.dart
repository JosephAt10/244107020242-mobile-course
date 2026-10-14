import '../../domain/entities/auth_session.dart';

class AuthSessionModel {
  const AuthSessionModel({required this.accessToken, required this.refreshToken});
  final String accessToken;
  final String refreshToken;

  factory AuthSessionModel.fromMap(Map<String, Object?> map) => AuthSessionModel(
        accessToken: map['access_token']! as String,
        refreshToken: map['refresh_token']! as String,
      );

  AuthSession toEntity() =>
      AuthSession(access: accessToken, refresh: refreshToken);
}