import '../entities/annonce.dart';

abstract class AnnonceRepository {
  Future<List<Annonce>> getAnnonces();
  Future<Annonce> getAnnonceDetail(String id);
  Future<Annonce> publierAnnonce({
    required String titre,
    required String utilisateurId,
    int? categorieId,
    String? description,
    double? prix,
    String? localisation,
    List<String> photos,
  });
  Future<Annonce> modifierAnnonce({
    required String id,
    String? titre,
    int? categorieId,
    String? description,
    double? prix,
    String? localisation,
    List<String>? photos,
  });
  Future<void> marquerVendue(String id);
  Future<void> supprimerAnnonce(String id);
  Future<String> uploadPhoto({
    required String userId,
    required String filePath,
    required List<int> fileBytes,
  });
}
