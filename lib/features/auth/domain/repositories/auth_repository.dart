import '../entities/utilisateur.dart';

abstract class AuthRepository {
  Future<Utilisateur> inscrire({
    required String email,
    required String motDePasse,
    required String nom,
  });

  Future<Utilisateur> connecter({
    required String email,
    required String motDePasse,
  });

  Future<void> deconnecter();

  Future<Utilisateur?> getCurrentUser();

  Future<Utilisateur> mettreAJourProfil({
    required String id,
    String? nom,
    String? telephone,
    String? localisation,
    String? photoUrl,
  });
}
