import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/chat_message.dart';
import '../domain/chat_repository.dart';
import '../domain/daily_request_policy.dart';
import '../domain/api_key_store.dart';

class GeminiChatRepository implements ChatRepository {
  GeminiChatRepository({
    required ApiKeyStore keyStore,
    http.Client? client,
    DateTime Function()? clock,
    DailyRequestPolicy policy = const DailyRequestPolicy(),
  }) : _keyStore = keyStore,
       _client = client ?? http.Client(),
       _clock = clock ?? DateTime.now,
       _policy = policy;

  static const systemPrompt =
      'You are a friendly study assistant for a college student. '
      'Answer in clear English, in at most two short sentences. '
      'Do not claim access to campus schedules, accounts, or private records. '
      'If you do not know, say so and suggest checking an official source. '
      'Never ask the user to share passwords, API keys, or sensitive personal data.';
  static const _model = 'gemini-3.5-flash-lite';
  final ApiKeyStore _keyStore;
  final http.Client _client;
  final DateTime Function() _clock;
  final DailyRequestPolicy _policy;

  @override
  Stream<String> replyTo(List<ChatMessage> conversation) async* {
    if (conversation.isEmpty || conversation.last.role != ChatRole.user) {
      throw const AiChatException('Enter a message to start the chat.');
    }
    final key = await _keyStore.read();
    if (key == null || key.trim().isEmpty) {
      throw const AiChatException(
        'Add your Gemini API key in Settings before starting a chat.',
      );
    }
    await _consumeDailyRequest();

    final uri = Uri.https(
      'generativelanguage.googleapis.com',
      '/v1beta/models/$_model:streamGenerateContent',
      {'alt': 'sse'},
    );
    final request = http.Request('POST', uri)
      ..headers.addAll({
        'Content-Type': 'application/json; charset=utf-8',
        'x-goog-api-key': key,
        'Accept': 'text/event-stream',
      })
      ..body = jsonEncode({
        'system_instruction': {
          'parts': [
            {'text': systemPrompt},
          ],
        },
        'contents': [
          for (final message in conversation.take(11))
            {
              'role': message.role.name,
              'parts': [
                {'text': message.text},
              ],
            },
        ],
        'generationConfig': {'maxOutputTokens': 256, 'temperature': 0.4},
      });

    try {
      final response = await _client
          .send(request)
          .timeout(
            const Duration(seconds: 45),
            onTimeout: () => throw const AiChatException(
              'The AI service took too long. Check your connection and retry.',
            ),
          );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        // Consume the error body without retaining or logging key material.
        await response.stream.drain<void>();
        throw AiChatException(_messageForStatus(response.statusCode));
      }

      var receivedText = false;
      await for (final line
          in response.stream
              .transform(utf8.decoder)
              .transform(const LineSplitter())) {
        if (!line.startsWith('data:')) continue;
        final payload = line.substring(5).trim();
        if (payload.isEmpty || payload == '[DONE]') continue;
        final decoded = jsonDecode(payload);
        if (decoded is! Map<String, dynamic>) continue;
        final candidates = decoded['candidates'];
        if (candidates is! List || candidates.isEmpty) continue;
        final content = candidates.first['content'];
        if (content is! Map<String, dynamic>) continue;
        final parts = content['parts'];
        if (parts is! List) continue;
        for (final part in parts) {
          if (part is Map<String, dynamic> && part['text'] is String) {
            final text = part['text'] as String;
            if (text.isNotEmpty) {
              receivedText = true;
              yield text;
            }
          }
        }
      }
      if (!receivedText) {
        throw const AiChatException(
          'The AI returned an empty reply. Please retry or check an official source.',
        );
      }
    } on AiChatException {
      rethrow;
    } on TimeoutException {
      throw const AiChatException(
        'The AI service took too long. Check your connection and retry.',
      );
    } on SocketException {
      throw const AiChatException(
        'No internet connection. Your notes are still available offline.',
      );
    } on http.ClientException {
      throw const AiChatException(
        'Could not reach the AI service. Check your connection and retry.',
      );
    } on FormatException {
      throw const AiChatException(
        'The AI service returned an unreadable reply. Please retry.',
      );
    }
  }

  Future<void> _consumeDailyRequest() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _clock().toLocal();
    final dayKey = '${today.year}-${today.month}-${today.day}';
    final savedDay = prefs.getString('ai_request_day');
    final count = savedDay == dayKey
        ? prefs.getInt('ai_request_count') ?? 0
        : 0;
    if (!_policy.allows(requestsToday: count)) {
      throw const AiChatException(
        'Daily AI request limit reached. Try again tomorrow.',
      );
    }
    await prefs.setString('ai_request_day', dayKey);
    await prefs.setInt('ai_request_count', count + 1);
  }

  String _messageForStatus(int statusCode) => switch (statusCode) {
    400 || 401 || 403 =>
      'Gemini rejected the request or API key. Check the key and API access in Settings.',
    429 => 'Gemini rate limit reached. Wait a little, then retry.',
    >= 500 =>
      'Gemini is temporarily unavailable. Retry later or study offline.',
    _ =>
      'The AI request failed ($statusCode). Retry or continue with your notes.',
  };
}

class AiChatException implements Exception {
  const AiChatException(this.message);

  final String message;

  @override
  String toString() => message;
}
