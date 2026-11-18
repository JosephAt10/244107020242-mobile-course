import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/gemini_chat_repository.dart';
import '../../domain/chat_message.dart';
import '../providers/ai_providers.dart';

class AiChatPage extends ConsumerStatefulWidget {
  const AiChatPage({super.key});

  @override
  ConsumerState<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends ConsumerState<AiChatPage> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _sending = false;
  String? _error;
  String? _lastQuestion;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send([String? retryText]) async {
    final question = (retryText ?? _inputController.text).trim();
    if (question.isEmpty || _sending) return;
    if (retryText == null) {
      _inputController.clear();
      _messages.add(ChatMessage(role: ChatRole.user, text: question));
      _lastQuestion = question;
    }
    final replyIndex = _messages.length;
    _messages.add(const ChatMessage(role: ChatRole.model, text: ''));
    setState(() {
      _sending = true;
      _error = null;
    });
    _scrollToBottom();

    try {
      await for (final chunk
          in ref
              .read(chatRepositoryProvider)
              .replyTo(_messages.take(replyIndex).toList())) {
        if (!mounted) return;
        final current = _messages[replyIndex];
        _messages[replyIndex] = ChatMessage(
          role: current.role,
          text: '${current.text}$chunk',
        );
        setState(() {});
        _scrollToBottom();
      }
    } catch (error) {
      if (!mounted) return;
      _messages.removeAt(replyIndex);
      setState(() => _error = _friendlyMessage(error));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  String _friendlyMessage(Object error) => error is AiChatException
      ? error.message
      : 'The AI assistant is unavailable. Retry later or continue using your notes offline.';

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasKey = ref.watch(hasAiApiKeyProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Study Assistant'),
        actions: [
          IconButton(
            tooltip: 'AI settings',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.key_outlined),
          ),
          IconButton(
            tooltip: 'Clear conversation',
            onPressed: _sending
                ? null
                : () => setState(() {
                    _messages.clear();
                    _error = null;
                    _lastQuestion = null;
                  }),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          MaterialBanner(
            leading: const Icon(Icons.privacy_tip_outlined),
            content: const Text(
              'Only messages you type are sent to Gemini. Do not include private or sensitive data.',
            ),
            actions: [
              TextButton(
                onPressed: () => context.push('/settings'),
                child: const Text('API key settings'),
              ),
            ],
          ),
          hasKey.when(
            data: (ready) => ready
                ? const SizedBox.shrink()
                : const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Add a Gemini API key in Settings to enable chat.',
                    ),
                  ),
            loading: () => const LinearProgressIndicator(),
            error: (error, stack) =>
                const Text('Secure storage is unavailable.'),
          ),
          if (_error != null)
            MaterialBanner(
              leading: const Icon(Icons.cloud_off_outlined),
              content: Text(_error!),
              actions: [
                TextButton(
                  onPressed: _sending || _lastQuestion == null
                      ? null
                      : () => unawaited(_send(_lastQuestion)),
                  child: const Text('Retry'),
                ),
                TextButton(
                  onPressed: () => setState(() => _error = null),
                  child: const Text('Dismiss'),
                ),
              ],
            ),
          Expanded(
            child: _messages.isEmpty
                ? const _ChatEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) => _MessageBubble(
                      message: _messages[index],
                      waiting:
                          _sending &&
                          index == _messages.length - 1 &&
                          _messages[index].text.isEmpty,
                    ),
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: 1000,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => unawaited(_send()),
                      decoration: const InputDecoration(
                        hintText: 'Ask a study question…',
                        border: OutlineInputBorder(),
                        counterText: '',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Send message',
                    onPressed: _sending ? null : () => unawaited(_send()),
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatEmptyState extends StatelessWidget {
  const _ChatEmptyState();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, size: 48),
          const SizedBox(height: 12),
          Text(
            'Ask a study question',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'For example: “Can you explain the difference between a class and an object?”',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.waiting});

  final ChatMessage message;
  final bool waiting;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    final colors = Theme.of(context).colorScheme;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? colors.primaryContainer : colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(18),
        ),
        child: waiting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(message.text),
      ),
    );
  }
}
