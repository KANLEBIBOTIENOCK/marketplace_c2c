import '../entities/utilisateur.dart';
import '../repositories/auth_repository.dart';

class ConnexionUsecase {
  final AuthRepository repository;
  const ConnexionUsecase(this.repository);

  Future<Utilisateur> call({
    required String email,
    required String motDePasse,
  }) {
    return repository.connecter(
      email: email,
      motDePasse: motDePasse,
    );
  }
}
