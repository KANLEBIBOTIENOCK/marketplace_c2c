import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/errors/app_exception.dart' as app_error;
import '../models/utilisateur_model.dart';

class AuthRemoteDatasource {
  final SupabaseClient _client;

  AuthRemoteDatasource(this._client);

  Future<UtilisateurModel> inscrire({
    required String email,
    required String motDePasse,
    required String nom,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: motDePasse,
        data: {'nom': nom},
      );
      if (response.user == null) {
        throw const app_error.AuthException('Inscription échouée.');
      }
      await _client
          .from(SupabaseConstants.utilisateursTable)
          .update({'nom': nom})
          .eq('id', response.user!.id);

      final data = await _client
          .from(SupabaseConstants.utilisateursTable)
          .select()
          .eq('id', response.user!.id)
          .single();

      return UtilisateurModel.fromJson(data);
    } on app_error.AuthException {
      rethrow;
    } catch (e) {
      throw app_error.AuthException(e.toString());
    }
  }

  Future<UtilisateurModel> connecter({
    required String email,
    required String motDePasse,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: motDePasse,
      );
      if (response.user == null) {
        throw const app_error.AuthException('Connexion échouée.');
      }
      final data = await _client
          .from(SupabaseConstants.utilisateursTable)
          .select()
          .eq('id', response.user!.id)
          .single();

      return UtilisateurModel.fromJson(data);
    } on app_error.AuthException {
      rethrow;
    } catch (e) {
      throw app_error.AuthException(e.toString());
    }
  }

  Future<void> deconnecter() async {
    await _client.auth.signOut();
  }

  Future<UtilisateurModel?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    try {
      final data = await _client
          .from(SupabaseConstants.utilisateursTable)
          .select()
          .eq('id', user.id)
          .single();
      return UtilisateurModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<UtilisateurModel> mettreAJourProfil({
    required String id,
    String? nom,
    String? telephone,
    String? localisation,
    String? photoUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (nom != null) updates['nom'] = nom;
      if (telephone != null) updates['telephone'] = telephone;
      if (localisation != null) updates['localisation'] = localisation;
      if (photoUrl != null) updates['photo_url'] = photoUrl;

      await _client
          .from(SupabaseConstants.utilisateursTable)
          .update(updates)
          .eq('id', id);

      final data = await _client
          .from(SupabaseConstants.utilisateursTable)
          .select()
          .eq('id', id)
          .single();

      return UtilisateurModel.fromJson(data);
    } catch (e) {
      throw app_error.ServerException(e.toString());
    }
  }
}
