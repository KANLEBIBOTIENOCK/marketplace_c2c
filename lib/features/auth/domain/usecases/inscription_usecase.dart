import '../entities/utilisateur.dart';
import '../repositories/auth_repository.dart';

class InscriptionUsecase {
  final AuthRepository repository;

  const InscriptionUsecase(this.repository);

  Future<Utilisateur> call({
    required String email,
    required String motDePasse,
    required String nom,
  }) {
    return repository.inscrire(email: email, motDePasse: motDePasse, nom: nom);
  }
}
