import '../entities/categorie.dart';
import '../repositories/categorie_repository.dart';

class GetCategoriesUsecase {
  final CategorieRepository repository;
  const GetCategoriesUsecase(this.repository);

  Future<List<Categorie>> call() => repository.getCategories();
}
