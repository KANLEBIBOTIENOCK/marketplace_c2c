import '../entities/avis.dart';
import '../repositories/avis_repository.dart';

class SoumettreAvisUsecase {
  final AvisRepository repository;
  const SoumettreAvisUsecase(this.repository);

  Future<Avis> call({
    required String conversationId,
    required String annonceId,
    required String evaluateurId,
    required String evalueId,
    required int note,
    String? commentaire,
  }) =>
      repository.soumettreAvis(
        conversationId: conversationId,
        annonceId: annonceId,
        evaluateurId: evaluateurId,
        evalueId: evalueId,
        note: note,
        commentaire: commentaire,
      );
}

class GetAvisUtilisateurUsecase {
  final AvisRepository repository;
  const GetAvisUtilisateurUsecase(this.repository);

  Future<List<Avis>> call(String userId) =>
      repository.getAvisUtilisateur(userId);
}

class ADejaNoteUsecase {
  final AvisRepository repository;
  const ADejaNoteUsecase(this.repository);

  Future<bool> call({
    required String conversationId,
    required String evaluateurId,
  }) =>
      repository.aDejaNote(
        conversationId: conversationId,
        evaluateurId: evaluateurId,
      );
}
