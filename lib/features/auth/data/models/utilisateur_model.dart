import '../../domain/entities/utilisateur.dart';

class UtilisateurModel extends Utilisateur {
  const UtilisateurModel({
    required super.id,
    super.nom,
    super.email,
    super.telephone,
    super.photoUrl,
    super.localisation,
    super.noteMoyenne,
    super.nombreAvis,
    super.statutVerification,
    super.createdAt,
  });

  factory UtilisateurModel.fromJson(Map<String, dynamic> json) {
    return UtilisateurModel(
      id: json['id'] as String,
      nom: json['nom'] as String?,
      email: json['email'] as String?,
      telephone: json['telephone'] as String?,
      photoUrl: json['photo_url'] as String?,
      localisation: json['localisation'] as String?,
      noteMoyenne: (json['note_moyenne'] as num?)?.toDouble() ?? 0.0,
      nombreAvis: (json['nombre_avis'] as int?) ?? 0,
      statutVerification: (json['statut_verification'] as bool?) ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'email': email,
      'telephone': telephone,
      'photo_url': photoUrl,
      'localisation': localisation,
      'note_moyenne': noteMoyenne,
      'nombre_avis': nombreAvis,
      'statut_verification': statutVerification,
    };
  }
}
