import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDatasource datasource;
  const ChatRepositoryImpl(this.datasource);

  @override
  Future<Conversation> ouvrirConversation({
    required String annonceId,
    required String acheteurId,
    required String vendeurId,
  }) async {
    try {
      return await datasource.ouvrirConversation(
        annonceId: annonceId,
        acheteurId: acheteurId,
        vendeurId: vendeurId,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<Conversation>> getMesConversations(String userId) async {
    try {
      return await datasource.getMesConversations(userId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<List<Message>> getMessages(String conversationId) {
    return datasource.getMessages(conversationId);
  }

  @override
  Future<Message> envoyerMessage({
    required String conversationId,
    required String expediteurId,
    required String contenu,
  }) async {
    try {
      return await datasource.envoyerMessage(
        conversationId: conversationId,
        expediteurId: expediteurId,
        contenu: contenu,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> marquerLu(String conversationId, String userId) async {
    try {
      await datasource.marquerLu(conversationId, userId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
