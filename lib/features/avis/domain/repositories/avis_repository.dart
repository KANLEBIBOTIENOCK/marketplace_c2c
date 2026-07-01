import '../entities/avis.dart';

abstract class AvisRepository {
  Future<Avis> soumettreAvis({
    required String conversationId,
    required String annonceId,
    required String evaluateurId,
    required String evalueId,
    required int note,
    String? commentaire,
  });

  Future<List<Avis>> getAvisUtilisateur(String userId);

  Future<bool> aDejaNote({
    required String conversationId,
    required String evaluateurId,
  });
}
