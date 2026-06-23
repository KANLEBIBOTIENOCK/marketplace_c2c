import '../entities/categorie.dart';

abstract class CategorieRepository {
  Future<List<Categorie>> getCategories();
}
