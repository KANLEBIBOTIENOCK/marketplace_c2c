import '../entities/conversation.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class OuvrirConversationUsecase {
  final ChatRepository repository;
  const OuvrirConversationUsecase(this.repository);

  Future<Conversation> call({
    required String annonceId,
    required String acheteurId,
    required String vendeurId,
  }) =>
      repository.ouvrirConversation(
        annonceId: annonceId,
        acheteurId: acheteurId,
        vendeurId: vendeurId,
      );
}

class GetMesConversationsUsecase {
  final ChatRepository repository;
  const GetMesConversationsUsecase(this.repository);

  Future<List<Conversation>> call(String userId) =>
      repository.getMesConversations(userId);
}

class GetMessagesUsecase {
  final ChatRepository repository;
  const GetMessagesUsecase(this.repository);

  Stream<List<Message>> call(String conversationId) =>
      repository.getMessages(conversationId);
}

class EnvoyerMessageUsecase {
  final ChatRepository repository;
  const EnvoyerMessageUsecase(this.repository);

  Future<Message> call({
    required String conversationId,
    required String expediteurId,
    required String contenu,
  }) =>
      repository.envoyerMessage(
        conversationId: conversationId,
        expediteurId: expediteurId,
        contenu: contenu,
      );
}

class MarquerLuUsecase {
  final ChatRepository repository;
  const MarquerLuUsecase(this.repository);

  Future<void> call(String conversationId, String userId) =>
      repository.marquerLu(conversationId, userId);
}
