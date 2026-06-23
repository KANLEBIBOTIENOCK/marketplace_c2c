import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/categorie_model.dart';

class CategorieRemoteDatasource {
  final SupabaseClient _client;
  CategorieRemoteDatasource(this._client);

  Future<List<CategorieModel>> getCategories() async {
    try {
      final data = await _client
          .from(SupabaseConstants.categoriesTable)
          .select()
          .order('nom', ascending: true);
      return (data as List)
          .map((e) => CategorieModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
