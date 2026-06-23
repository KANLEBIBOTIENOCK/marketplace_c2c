import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/annonce_model.dart';

class AnnonceRemoteDatasource {
  final SupabaseClient _client;
  AnnonceRemoteDatasource(this._client);

  Future<List<AnnonceModel>> getAnnonces() async {
    try {
      final data = await _client
          .from(SupabaseConstants.annoncesTable)
          .select()
          .eq('statut', 'active')
          .order('created_at', ascending: false);
      return (data as List)
          .map((e) => AnnonceModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<AnnonceModel> getAnnonceDetail(String id) async {
    try {
      final data = await _client
          .from(SupabaseConstants.annoncesTable)
          .select()
          .eq('id', id)
          .single();
      return AnnonceModel.fromJson(data);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<AnnonceModel> publierAnnonce({
    required String titre,
    required String utilisateurId,
    int? categorieId,
    String? description,
    double? prix,
    String? localisation,
    List<String> photos = const [],
  }) async {
    try {
      final data = await _client
          .from(SupabaseConstants.annoncesTable)
          .insert({
            'titre': titre,
            'utilisateur_id': utilisateurId,
            'categorie_id': categorieId,
            'description': description,
            'prix': prix,
            'localisation': localisation,
            'photos': photos,
          })
          .select()
          .single();
      return AnnonceModel.fromJson(data);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<AnnonceModel> modifierAnnonce({
    required String id,
    String? titre,
    int? categorieId,
    String? description,
    double? prix,
    String? localisation,
    List<String>? photos,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (titre != null) updates['titre'] = titre;
      if (categorieId != null) updates['categorie_id'] = categorieId;
      if (description != null) updates['description'] = description;
      if (prix != null) updates['prix'] = prix;
      if (localisation != null) updates['localisation'] = localisation;
      if (photos != null) updates['photos'] = photos;

      final data = await _client
          .from(SupabaseConstants.annoncesTable)
          .update(updates)
          .eq('id', id)
          .select()
          .single();
      return AnnonceModel.fromJson(data);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> marquerVendue(String id) async {
    try {
      await _client
          .from(SupabaseConstants.annoncesTable)
          .update({'statut': 'vendue'}).eq('id', id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> supprimerAnnonce(String id) async {
    try {
      await _client
          .from(SupabaseConstants.annoncesTable)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<String> uploadPhoto({
    required String userId,
    required String filePath,
    required List<int> fileBytes,
  }) async {
    try {
      final path = '$userId/$filePath';
      await _client.storage
          .from(SupabaseConstants.annoncesBucket)
          .uploadBinary(path, Uint8List.fromList(fileBytes));
      final url = _client.storage
          .from(SupabaseConstants.annoncesBucket)
          .getPublicUrl(path);
      return url;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
