import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/utilisateur.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource datasource;

  const AuthRepositoryImpl(this.datasource);

  @override
  Future<Utilisateur> inscrire({
    required String email,
    required String motDePasse,
    required String nom,
  }) async {
    try {
      return await datasource.inscrire(
        email: email,
        motDePasse: motDePasse,
        nom: nom,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<Utilisateur> connecter({
    required String email,
    required String motDePasse,
  }) async {
    try {
      return await datasource.connecter(email: email, motDePasse: motDePasse);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> deconnecter() => datasource.deconnecter();

  @override
  Future<Utilisateur?> getCurrentUser() => datasource.getCurrentUser();

  @override
  Future<Utilisateur> mettreAJourProfil({
    required String id,
    String? nom,
    String? telephone,
    String? localisation,
    String? photoUrl,
  }) {
    return datasource.mettreAJourProfil(
      id: id,
      nom: nom,
      telephone: telephone,
      localisation: localisation,
      photoUrl: photoUrl,
    );
  }
}
