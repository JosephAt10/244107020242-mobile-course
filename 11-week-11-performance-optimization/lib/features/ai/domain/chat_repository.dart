import 'chat_message.dart';

abstract interface class ChatRepository {
  Stream<String> replyTo(List<ChatMessage> conversation);
}
