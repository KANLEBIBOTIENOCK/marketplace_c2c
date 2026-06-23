class Categorie {
  final int id;
  final String nom;
  final String? icone;
  final int? parentId;

  const Categorie({
    required this.id,
    required this.nom,
    this.icone,
    this.parentId,
  });
}
