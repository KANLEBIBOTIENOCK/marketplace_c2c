import '../../domain/entities/categorie.dart';

class CategorieModel extends Categorie {
  const CategorieModel({
    required super.id,
    required super.nom,
    super.icone,
    super.parentId,
  });

  factory CategorieModel.fromJson(Map<String, dynamic> json) {
    return CategorieModel(
      id: json['id'] as int,
      nom: json['nom'] as String,
      icone: json['icone'] as String?,
      parentId: json['parent_id'] as int?,
    );
  }
}
