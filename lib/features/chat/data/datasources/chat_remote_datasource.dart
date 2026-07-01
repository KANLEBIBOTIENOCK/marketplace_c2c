import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../../../../core/errors/app_exception.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

class ChatRemoteDatasource {
  final SupabaseClient _client;
  ChatRemoteDatasource(this._client);

  Future<ConversationModel> ouvrirConversation({
    required String annonceId,
    required String acheteurId,
    required String vendeurId,
  }) async {
    try {
      final existing = await _client
          .from('conversations')
          .select()
          .eq('annonce_id', annonceId)
          .eq('acheteur_id', acheteurId)
          .maybeSingle();

      if (existing != null) {
        return ConversationModel.fromJson(existing, acheteurId);
      }

      final data = await _client
          .from('conversations')
          .insert({
            'annonce_id': annonceId,
            'acheteur_id': acheteurId,
            'vendeur_id': vendeurId,
          })
          .select()
          .single();

      return ConversationModel.fromJson(data, acheteurId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<List<ConversationModel>> getMesConversations(String userId) async {
    try {
      final data = await _client
          .from('conversations')
          .select('''
            id, annonce_id, acheteur_id, vendeur_id, created_at,
            acheteur_non_lus, vendeur_non_lus,
            annonce:annonces(titre),
            acheteur:utilisateurs!conversations_acheteur_id_fkey(nom),
            vendeur:utilisateurs!conversations_vendeur_id_fkey(nom)
          ''')
          .or('acheteur_id.eq.$userId,vendeur_id.eq.$userId')
          .order('created_at', ascending: false);

      return (data as List)
          .map(
            (e) =>
                ConversationModel.fromJson(e as Map<String, dynamic>, userId),
          )
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Stream<List<MessageModel>> getMessages(String conversationId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true)
        .map((data) => data.map((e) => MessageModel.fromJson(e)).toList());
  }

  Future<MessageModel> envoyerMessage({
    required String conversationId,
    required String expediteurId,
    required String contenu,
  }) async {
    try {
      final data = await _client
          .from('messages')
          .insert({
            'conversation_id': conversationId,
            'expediteur_id': expediteurId,
            'contenu': contenu,
          })
          .select()
          .single();
      return MessageModel.fromJson(data);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> marquerLu(String conversationId, String userId) async {
    try {
      await _client
          .from('messages')
          .update({'lu': true})
          .eq('conversation_id', conversationId)
          .neq('expediteur_id', userId)
          .eq('lu', false);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
