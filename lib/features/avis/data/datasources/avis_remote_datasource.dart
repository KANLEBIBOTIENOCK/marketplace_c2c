import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../../../../core/errors/app_exception.dart';
import '../models/avis_model.dart';

class AvisRemoteDatasource {
  final SupabaseClient _client;
  AvisRemoteDatasource(this._client);

  Future<AvisModel> soumettreAvis({
    required String conversationId,
    required String annonceId,
    required String evaluateurId,
    required String evalueId,
    required int note,
    String? commentaire,
  }) async {
    try {
      final data = await _client
          .from('avis')
          .insert({
            'conversation_id': conversationId,
            'annonce_id': annonceId,
            'evaluateur_id': evaluateurId,
            'evalue_id': evalueId,
            'note': note,
            'commentaire': commentaire,
          })
          .select()
          .single();
      return AvisModel.fromJson(data);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<List<AvisModel>> getAvisUtilisateur(String userId) async {
    try {
      final data = await _client
          .from('avis')
          .select()
          .eq('evalue_id', userId)
          .order('created_at', ascending: false);
      return (data as List)
          .map((e) => AvisModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<bool> aDejaNote({
    required String conversationId,
    required String evaluateurId,
  }) async {
    try {
      final data = await _client
          .from('avis')
          .select('id')
          .eq('conversation_id', conversationId)
          .eq('evaluateur_id', evaluateurId)
          .maybeSingle();
      return data != null;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
