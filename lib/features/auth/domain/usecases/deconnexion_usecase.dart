import '../repositories/auth_repository.dart';

class DeconnexionUsecase {
  final AuthRepository repository;

  const DeconnexionUsecase(this.repository);

  Future<void> call() => repository.deconnecter();
}
