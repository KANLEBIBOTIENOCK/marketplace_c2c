class Conversation {
  final String id;
  final String annonceId;
  final String acheteurId;
  final String vendeurId;
  final DateTime? createdAt;
  // Champs enrichis (join)
  final String? annonceTitre;
  final String? autreNom;
  final String? dernierMessage;
  final int nonLus;

  const Conversation({
    required this.id,
    required this.annonceId,
    required this.acheteurId,
    required this.vendeurId,
    this.createdAt,
    this.annonceTitre,
    this.autreNom,
    this.dernierMessage,
    this.nonLus = 0,
  });
}
