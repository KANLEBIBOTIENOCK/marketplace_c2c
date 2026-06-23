import '../../domain/entities/categorie.dart';
import '../../domain/repositories/categorie_repository.dart';
import '../datasources/categorie_remote_datasource.dart';

class CategorieRepositoryImpl implements CategorieRepository {
  final CategorieRemoteDatasource datasource;
  const CategorieRepositoryImpl(this.datasource);

  @override
  Future<List<Categorie>> getCategories() => datasource.getCategories();
}
