import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../../data/datasources/avis_remote_datasource.dart';
import '../../data/repositories/avis_repository_impl.dart';
import '../../domain/entities/avis.dart';
import '../../domain/usecases/avis_usecases.dart';

final avisDatasourceProvider = Provider<AvisRemoteDatasource>(
  (ref) => AvisRemoteDatasource(Supabase.instance.client),
);

final avisRepositoryProvider = Provider<AvisRepositoryImpl>(
  (ref) => AvisRepositoryImpl(ref.watch(avisDatasourceProvider)),
);

final soumettreAvisUsecaseProvider = Provider(
  (ref) => SoumettreAvisUsecase(ref.watch(avisRepositoryProvider)),
);

final getAvisUtilisateurUsecaseProvider = Provider(
  (ref) => GetAvisUtilisateurUsecase(ref.watch(avisRepositoryProvider)),
);

final aDejaNoteUsecaseProvider = Provider(
  (ref) => ADejaNoteUsecase(ref.watch(avisRepositoryProvider)),
);

// Avis d'un utilisateur
final avisUtilisateurProvider =
    FutureProvider.autoDispose.family<List<Avis>, String>((ref, userId) async {
  return ref.watch(getAvisUtilisateurUsecaseProvider).call(userId);
});

// Vérifier si déjà noté
final dejaNoteProvider = FutureProvider.autoDispose
    .family<bool, ({String conversationId, String evaluateurId})>(
        (ref, params) async {
  return ref.watch(aDejaNoteUsecaseProvider).call(
        conversationId: params.conversationId,
        evaluateurId: params.evaluateurId,
      );
});

// Notifier pour soumettre un avis
class AvisNotifier extends AsyncNotifier<Avis?> {
  @override
  Future<Avis?> build() async => null;

  Future<void> soumettre({
    required String conversationId,
    required String annonceId,
    required String evaluateurId,
    required String evalueId,
    required int note,
    String? commentaire,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(soumettreAvisUsecaseProvider).call(
            conversationId: conversationId,
            annonceId: annonceId,
            evaluateurId: evaluateurId,
            evalueId: evalueId,
            note: note,
            commentaire: commentaire,
          ),
    );
  }
}

final avisNotifierProvider =
    AsyncNotifierProvider<AvisNotifier, Avis?>(AvisNotifier.new);
