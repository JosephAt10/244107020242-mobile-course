abstract interface class ApiKeyStore {
  Future<String?> read();

  Future<void> save(String value);

  Future<void> delete();
}
