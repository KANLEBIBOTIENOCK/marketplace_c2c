import '../entities/conversation.dart';
import '../entities/message.dart';

abstract class ChatRepository {
  Future<Conversation> ouvrirConversation({
    required String annonceId,
    required String acheteurId,
    required String vendeurId,
  });

  Future<List<Conversation>> getMesConversations(String userId);

  Stream<List<Message>> getMessages(String conversationId);

  Future<Message> envoyerMessage({
    required String conversationId,
    required String expediteurId,
    required String contenu,
  });

  Future<void> marquerLu(String conversationId, String userId);
}
