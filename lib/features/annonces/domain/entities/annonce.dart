class Annonce {
  final String id;
  final String utilisateurId;
  final int? categorieId;
  final String titre;
  final String? description;
  final double? prix;
  final String statut;
  final String? localisation;
  final List<String> photos;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Annonce({
    required this.id,
    required this.utilisateurId,
    this.categorieId,
    required this.titre,
    this.description,
    this.prix,
    this.statut = 'active',
    this.localisation,
    this.photos = const [],
    this.createdAt,
    this.updatedAt,
  });
}
