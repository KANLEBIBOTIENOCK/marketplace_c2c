import '../entities/utilisateur.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUsecase {
  final AuthRepository repository;
  const GetCurrentUserUsecase(this.repository);

  Future<Utilisateur?> call() => repository.getCurrentUser();
}
