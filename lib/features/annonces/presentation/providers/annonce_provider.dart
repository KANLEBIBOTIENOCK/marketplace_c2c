import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/annonce_remote_datasource.dart';
import '../../data/repositories/annonce_repository_impl.dart';
import '../../domain/entities/annonce.dart';
import '../../domain/usecases/annonce_usecases.dart';

final annonceDatasourceProvider = Provider<AnnonceRemoteDatasource>(
  (ref) => AnnonceRemoteDatasource(Supabase.instance.client),
);

final annonceRepositoryProvider = Provider<AnnonceRepositoryImpl>(
  (ref) => AnnonceRepositoryImpl(ref.watch(annonceDatasourceProvider)),
);

final getAnnoncesUsecaseProvider = Provider(
  (ref) => GetAnnoncesUsecase(ref.watch(annonceRepositoryProvider)),
);

final publierAnnonceUsecaseProvider = Provider(
  (ref) => PublierAnnonceUsecase(ref.watch(annonceRepositoryProvider)),
);

final uploadPhotoUsecaseProvider = Provider(
  (ref) => UploadPhotoUsecase(ref.watch(annonceRepositoryProvider)),
);

final marquerVendueUsecaseProvider = Provider(
  (ref) => MarquerVendueUsecase(ref.watch(annonceRepositoryProvider)),
);

final supprimerAnnonceUsecaseProvider = Provider(
  (ref) => SupprimerAnnonceUsecase(ref.watch(annonceRepositoryProvider)),
);

// Liste des annonces du catalogue
final annoncesProvider = FutureProvider<List<Annonce>>((ref) async {
  return ref.watch(getAnnoncesUsecaseProvider).call();
});

// State pour la création d'annonce
class CreationAnnonceNotifier extends AsyncNotifier<Annonce?> {
  @override
  Future<Annonce?> build() async => null;

  Future<void> publier({
    required String titre,
    required String utilisateurId,
    int? categorieId,
    String? description,
    double? prix,
    String? localisation,
    List<String> photos = const [],
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(publierAnnonceUsecaseProvider).call(
            titre: titre,
            utilisateurId: utilisateurId,
            categorieId: categorieId,
            description: description,
            prix: prix,
            localisation: localisation,
            photos: photos,
          ),
    );
  }
}

final creationAnnonceProvider =
    AsyncNotifierProvider<CreationAnnonceNotifier, Annonce?>(
  CreationAnnonceNotifier.new,
);
