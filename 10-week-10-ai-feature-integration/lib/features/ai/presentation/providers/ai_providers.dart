import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/gemini_chat_repository.dart';
import '../../data/secure_api_key_store.dart';
import '../../domain/chat_repository.dart';

final secureApiKeyStoreProvider = Provider<SecureApiKeyStore>(
  (ref) => SecureApiKeyStore(),
);

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return GeminiChatRepository(keyStore: ref.watch(secureApiKeyStoreProvider));
});

final hasAiApiKeyProvider = FutureProvider<bool>((ref) async {
  final key = await ref.watch(secureApiKeyStoreProvider).read();
  return key != null && key.trim().isNotEmpty;
});
