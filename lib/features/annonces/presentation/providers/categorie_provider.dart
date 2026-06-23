import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/categorie_remote_datasource.dart';
import '../../data/repositories/categorie_repository_impl.dart';
import '../../domain/entities/categorie.dart';
import '../../domain/usecases/get_categories_usecase.dart';

final categorieDatasourceProvider = Provider<CategorieRemoteDatasource>(
  (ref) => CategorieRemoteDatasource(Supabase.instance.client),
);

final categorieRepositoryProvider = Provider<CategorieRepositoryImpl>(
  (ref) => CategorieRepositoryImpl(ref.watch(categorieDatasourceProvider)),
);

final getCategoriesUsecaseProvider = Provider(
  (ref) => GetCategoriesUsecase(ref.watch(categorieRepositoryProvider)),
);

final categoriesProvider = FutureProvider<List<Categorie>>((ref) async {
  return ref.watch(getCategoriesUsecaseProvider).call();
});
