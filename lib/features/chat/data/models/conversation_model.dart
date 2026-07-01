import '../../domain/entities/conversation.dart';

class ConversationModel extends Conversation {
  const ConversationModel({
    required super.id,
    required super.annonceId,
    required super.acheteurId,
    required super.vendeurId,
    super.createdAt,
    super.annonceTitre,
    super.autreNom,
    super.dernierMessage,
    super.nonLus,
  });

  factory ConversationModel.fromJson(
      Map<String, dynamic> json, String currentUserId) {
    final isAcheteur = json['acheteur_id'] == currentUserId;
    final autreUtilisateur = isAcheteur
        ? json['vendeur'] as Map<String, dynamic>?
        : json['acheteur'] as Map<String, dynamic>?;

    final nonLus = isAcheteur
        ? (json['acheteur_non_lus'] as int? ?? 0)
        : (json['vendeur_non_lus'] as int? ?? 0);

    return ConversationModel(
      id: json['id'] as String,
      annonceId: json['annonce_id'] as String,
      acheteurId: json['acheteur_id'] as String,
      vendeurId: json['vendeur_id'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      annonceTitre:
          (json['annonce'] as Map<String, dynamic>?)?['titre'] as String?,
      autreNom: autreUtilisateur?['nom'] as String?,
      nonLus: nonLus,
    );
  }
}
