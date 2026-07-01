class Avis {
  final String id;
  final String conversationId;
  final String annonceId;
  final String evaluateurId;
  final String evalueId;
  final int note;
  final String? commentaire;
  final DateTime? createdAt;

  const Avis({
    required this.id,
    required this.conversationId,
    required this.annonceId,
    required this.evaluateurId,
    required this.evalueId,
    required this.note,
    this.commentaire,
    this.createdAt,
  });
}
