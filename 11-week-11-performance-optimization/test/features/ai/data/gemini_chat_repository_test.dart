import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:week11_performance_optimization/features/ai/data/gemini_chat_repository.dart';
import 'package:week11_performance_optimization/features/ai/domain/api_key_store.dart';
import 'package:week11_performance_optimization/features/ai/domain/chat_message.dart';

class _FakeApiKeyStore implements ApiKeyStore {
  _FakeApiKeyStore(this.value);

  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> save(String value) async => this.value = value;

  @override
  Future<void> delete() async => value = null;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('streams Gemini response chunks and sends the key in a header', () async {
    late http.Request captured;
    final repository = GeminiChatRepository(
      keyStore: _FakeApiKeyStore('test-key-placeholder'),
      clock: () => DateTime(2026, 11, 5),
      client: MockClient((request) async {
        captured = request;
        expect(request.headers['x-goog-api-key'], 'test-key-placeholder');
        expect(request.url.queryParameters.containsKey('key'), isFalse);
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['system_instruction'], isNotNull);
        return http.Response.bytes(
          utf8.encode(
            'data: {"candidates":[{"content":{"parts":[{"text":"Hello "}]}}]}\n\n'
            'data: {"candidates":[{"content":{"parts":[{"text":"student."}]}}]}\n\n',
          ),
          200,
          headers: {'content-type': 'text/event-stream'},
        );
      }),
    );

    final chunks = await repository.replyTo([
      const ChatMessage(role: ChatRole.user, text: 'Help me study'),
    ]).toList();

    expect(chunks, ['Hello ', 'student.']);
    expect(captured.url.path, contains(':streamGenerateContent'));
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('ai_request_count'), 1);
  });

  test('returns a safe setup message when no API key is saved', () async {
    final repository = GeminiChatRepository(
      keyStore: _FakeApiKeyStore(null),
      client: MockClient((request) async => http.Response('', 500)),
    );

    await expectLater(
      repository.replyTo([
        const ChatMessage(role: ChatRole.user, text: 'Question'),
      ]).toList(),
      throwsA(
        isA<AiChatException>().having(
          (error) => error.message,
          'message',
          contains('Add your Gemini API key'),
        ),
      ),
    );
  });
}
