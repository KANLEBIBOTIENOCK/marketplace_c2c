import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/avis.dart';
import '../../domain/repositories/avis_repository.dart';
import '../datasources/avis_remote_datasource.dart';

class AvisRepositoryImpl implements AvisRepository {
  final AvisRemoteDatasource datasource;
  const AvisRepositoryImpl(this.datasource);

  @override
  Future<Avis> soumettreAvis({
    required String conversationId,
    required String annonceId,
    required String evaluateurId,
    required String evalueId,
    required int note,
    String? commentaire,
  }) async {
    try {
      return await datasource.soumettreAvis(
        conversationId: conversationId,
        annonceId: annonceId,
        evaluateurId: evaluateurId,
        evalueId: evalueId,
        note: note,
        commentaire: commentaire,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<Avis>> getAvisUtilisateur(String userId) async {
    try {
      return await datasource.getAvisUtilisateur(userId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> aDejaNote({
    required String conversationId,
    required String evaluateurId,
  }) async {
    try {
      return await datasource.aDejaNote(
        conversationId: conversationId,
        evaluateurId: evaluateurId,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
