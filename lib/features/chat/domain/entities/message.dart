class Message {
  final String id;
  final String conversationId;
  final String expediteurId;
  final String contenu;
  final bool lu;
  final DateTime? createdAt;

  const Message({
    required this.id,
    required this.conversationId,
    required this.expediteurId,
    required this.contenu,
    this.lu = false,
    this.createdAt,
  });
}
