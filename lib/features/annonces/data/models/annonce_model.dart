import '../../domain/entities/annonce.dart';

class AnnonceModel extends Annonce {
  const AnnonceModel({
    required super.id,
    required super.utilisateurId,
    super.categorieId,
    required super.titre,
    super.description,
    super.prix,
    super.statut,
    super.localisation,
    super.photos,
    super.createdAt,
    super.updatedAt,
  });

  factory AnnonceModel.fromJson(Map<String, dynamic> json) {
    return AnnonceModel(
      id: json['id'] as String,
      utilisateurId: json['utilisateur_id'] as String,
      categorieId: json['categorie_id'] as int?,
      titre: json['titre'] as String,
      description: json['description'] as String?,
      prix: (json['prix'] as num?)?.toDouble(),
      statut: json['statut'] as String? ?? 'active',
      localisation: json['localisation'] as String?,
      photos: json['photos'] != null
          ? List<String>.from(json['photos'] as List)
          : [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'utilisateur_id': utilisateurId,
      'categorie_id': categorieId,
      'titre': titre,
      'description': description,
      'prix': prix,
      'statut': statut,
      'localisation': localisation,
      'photos': photos,
    };
  }
}
