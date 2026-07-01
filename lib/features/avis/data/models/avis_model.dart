import '../../domain/entities/avis.dart';

class AvisModel extends Avis {
  const AvisModel({
    required super.id,
    required super.conversationId,
    required super.annonceId,
    required super.evaluateurId,
    required super.evalueId,
    required super.note,
    super.commentaire,
    super.createdAt,
  });

  factory AvisModel.fromJson(Map<String, dynamic> json) {
    return AvisModel(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      annonceId: json['annonce_id'] as String,
      evaluateurId: json['evaluateur_id'] as String,
      evalueId: json['evalue_id'] as String,
      note: json['note'] as int,
      commentaire: json['commentaire'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'conversation_id': conversationId,
        'annonce_id': annonceId,
        'evaluateur_id': evaluateurId,
        'evalue_id': evalueId,
        'note': note,
        'commentaire': commentaire,
      };
}
