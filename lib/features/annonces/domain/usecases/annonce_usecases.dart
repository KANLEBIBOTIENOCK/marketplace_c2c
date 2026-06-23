import '../entities/annonce.dart';
import '../repositories/annonce_repository.dart';

class GetAnnoncesUsecase {
  final AnnonceRepository repository;
  const GetAnnoncesUsecase(this.repository);
  Future<List<Annonce>> call() => repository.getAnnonces();
}

class GetAnnonceDetailUsecase {
  final AnnonceRepository repository;
  const GetAnnonceDetailUsecase(this.repository);
  Future<Annonce> call(String id) => repository.getAnnonceDetail(id);
}

class PublierAnnonceUsecase {
  final AnnonceRepository repository;
  const PublierAnnonceUsecase(this.repository);
  Future<Annonce> call({
    required String titre,
    required String utilisateurId,
    int? categorieId,
    String? description,
    double? prix,
    String? localisation,
    List<String> photos = const [],
  }) =>
      repository.publierAnnonce(
        titre: titre,
        utilisateurId: utilisateurId,
        categorieId: categorieId,
        description: description,
        prix: prix,
        localisation: localisation,
        photos: photos,
      );
}

class ModifierAnnonceUsecase {
  final AnnonceRepository repository;
  const ModifierAnnonceUsecase(this.repository);
  Future<Annonce> call({
    required String id,
    String? titre,
    int? categorieId,
    String? description,
    double? prix,
    String? localisation,
    List<String>? photos,
  }) =>
      repository.modifierAnnonce(
        id: id,
        titre: titre,
        categorieId: categorieId,
        description: description,
        prix: prix,
        localisation: localisation,
        photos: photos,
      );
}

class MarquerVendueUsecase {
  final AnnonceRepository repository;
  const MarquerVendueUsecase(this.repository);
  Future<void> call(String id) => repository.marquerVendue(id);
}

class SupprimerAnnonceUsecase {
  final AnnonceRepository repository;
  const SupprimerAnnonceUsecase(this.repository);
  Future<void> call(String id) => repository.supprimerAnnonce(id);
}

class UploadPhotoUsecase {
  final AnnonceRepository repository;
  const UploadPhotoUsecase(this.repository);
  Future<String> call({
    required String userId,
    required String filePath,
    required List<int> fileBytes,
  }) =>
      repository.uploadPhoto(
        userId: userId,
        filePath: filePath,
        fileBytes: fileBytes,
      );
}
