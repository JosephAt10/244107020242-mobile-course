import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/api_key_store.dart';

class SecureApiKeyStore implements ApiKeyStore {
  SecureApiKeyStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _keyName = 'gemini_api_key';
  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() => _storage.read(key: _keyName);

  @override
  Future<void> save(String value) async {
    final key = value.trim();
    if (key.isEmpty) {
      throw ArgumentError.value(value, 'value', 'API key cannot be empty');
    }
    await _storage.write(key: _keyName, value: key);
  }

  @override
  Future<void> delete() => _storage.delete(key: _keyName);
}
