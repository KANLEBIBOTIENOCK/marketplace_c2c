import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/annonce.dart';
import '../../domain/repositories/annonce_repository.dart';
import '../datasources/annonce_remote_datasource.dart';

class AnnonceRepositoryImpl implements AnnonceRepository {
  final AnnonceRemoteDatasource datasource;
  const AnnonceRepositoryImpl(this.datasource);

  @override
  Future<List<Annonce>> getAnnonces() async {
    try {
      return await datasource.getAnnonces();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Annonce> getAnnonceDetail(String id) async {
    try {
      return await datasource.getAnnonceDetail(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Annonce> publierAnnonce({
    required String titre,
    required String utilisateurId,
    int? categorieId,
    String? description,
    double? prix,
    String? localisation,
    List<String> photos = const [],
  }) async {
    try {
      return await datasource.publierAnnonce(
        titre: titre,
        utilisateurId: utilisateurId,
        categorieId: categorieId,
        description: description,
        prix: prix,
        localisation: localisation,
        photos: photos,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Annonce> modifierAnnonce({
    required String id,
    String? titre,
    int? categorieId,
    String? description,
    double? prix,
    String? localisation,
    List<String>? photos,
  }) async {
    try {
      return await datasource.modifierAnnonce(
        id: id,
        titre: titre,
        categorieId: categorieId,
        description: description,
        prix: prix,
        localisation: localisation,
        photos: photos,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> marquerVendue(String id) async {
    try {
      await datasource.marquerVendue(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> supprimerAnnonce(String id) async {
    try {
      await datasource.supprimerAnnonce(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> uploadPhoto({
    required String userId,
    required String filePath,
    required List<int> fileBytes,
  }) async {
    try {
      return await datasource.uploadPhoto(
        userId: userId,
        filePath: filePath,
        fileBytes: fileBytes,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
