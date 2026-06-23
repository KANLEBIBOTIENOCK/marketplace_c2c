class Utilisateur {
  final String id;
  final String? nom;
  final String? email;
  final String? telephone;
  final String? photoUrl;
  final String? localisation;
  final double noteMoyenne;
  final int nombreAvis;
  final bool statutVerification;
  final DateTime? createdAt;

  const Utilisateur({
    required this.id,
    this.nom,
    this.email,
    this.telephone,
    this.photoUrl,
    this.localisation,
    this.noteMoyenne = 0.0,
    this.nombreAvis = 0,
    this.statutVerification = false,
    this.createdAt,
  });
}
