import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/utilisateur.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/connexion_usecase.dart';
import '../../domain/usecases/deconnexion_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/inscription_usecase.dart';

final supabaseClientProvider = Provider<SupabaseClient>(
  (_) => Supabase.instance.client,
);

final authDatasourceProvider = Provider<AuthRemoteDatasource>(
  (ref) => AuthRemoteDatasource(ref.watch(supabaseClientProvider)),
);

final authRepositoryProvider = Provider<AuthRepositoryImpl>(
  (ref) => AuthRepositoryImpl(ref.watch(authDatasourceProvider)),
);

final inscriptionUsecaseProvider = Provider(
  (ref) => InscriptionUsecase(ref.watch(authRepositoryProvider)),
);

final connexionUsecaseProvider = Provider(
  (ref) => ConnexionUsecase(ref.watch(authRepositoryProvider)),
);

final deconnexionUsecaseProvider = Provider(
  (ref) => DeconnexionUsecase(ref.watch(authRepositoryProvider)),
);

final getCurrentUserUsecaseProvider = Provider(
  (ref) => GetCurrentUserUsecase(ref.watch(authRepositoryProvider)),
);

class AuthNotifier extends AsyncNotifier<Utilisateur?> {
  @override
  Future<Utilisateur?> build() async {
    return ref.watch(getCurrentUserUsecaseProvider).call();
  }

  Future<void> inscrire({
    required String email,
    required String motDePasse,
    required String nom,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(inscriptionUsecaseProvider)
          .call(email: email, motDePasse: motDePasse, nom: nom),
    );
  }

  Future<void> connecter({
    required String email,
    required String motDePasse,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(connexionUsecaseProvider)
          .call(email: email, motDePasse: motDePasse),
    );
  }

  Future<void> deconnecter() async {
    await ref.read(deconnexionUsecaseProvider).call();
    state = const AsyncData(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, Utilisateur?>(
  AuthNotifier.new,
);
