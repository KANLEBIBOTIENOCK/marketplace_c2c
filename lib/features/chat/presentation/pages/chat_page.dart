import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../../../avis/presentation/pages/notation_page.dart';
import '../../../avis/presentation/providers/avis_provider.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../providers/chat_provider.dart';

class ChatPage extends ConsumerStatefulWidget {
  final Conversation conversation;
  const ChatPage({super.key, required this.conversation});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  late final String _currentUserId;
  final List<_LocalMessage> _pending = [];

  @override
  void initState() {
    super.initState();
    _currentUserId = Supabase.instance.client.auth.currentUser!.id;
    Future.microtask(() => ref
        .read(marquerLuUsecaseProvider)
        .call(widget.conversation.id, _currentUserId));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _envoyer() async {
    final texte = _controller.text.trim();
    if (texte.isEmpty) return;
    _controller.clear();
    final tempId = 'local_${DateTime.now().microsecondsSinceEpoch}';
    final local = _LocalMessage(
      tempId: tempId,
      contenu: texte,
      expediteurId: _currentUserId,
      createdAt: DateTime.now(),
    );
    setState(() => _pending.add(local));
    _scrollToBottom();
    try {
      await ref.read(envoyerMessageUsecaseProvider).call(
            conversationId: widget.conversation.id,
            expediteurId: _currentUserId,
            contenu: texte,
          );
      if (mounted) setState(() => _pending.removeWhere((m) => m.tempId == tempId));
    } catch (e) {
      if (mounted) {
        setState(() => _pending.removeWhere((m) => m.tempId == tempId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  List<Message> _fusionner(List<Message> stream) {
    final idsConfirmes = stream.map((m) => m.id).toSet();
    final locaux = _pending
        .map((m) => Message(
              id: m.tempId,
              conversationId: widget.conversation.id,
              expediteurId: m.expediteurId,
              contenu: m.contenu,
              createdAt: m.createdAt,
            ))
        .where((m) => !idsConfirmes.contains(m.id))
        .toList();
    final tous = [...stream, ...locaux];
    tous.sort((a, b) =>
        (a.createdAt ?? DateTime(0)).compareTo(b.createdAt ?? DateTime(0)));
    return tous;
  }

  String get _autreId => _currentUserId == widget.conversation.acheteurId
      ? widget.conversation.vendeurId
      : widget.conversation.acheteurId;

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider(widget.conversation.id));
    final dejaNoteAsync = ref.watch(dejaNoteProvider((
      conversationId: widget.conversation.id,
      evaluateurId: _currentUserId,
    )));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.conversation.autreNom ?? 'Conversation',
                style: const TextStyle(fontSize: 16)),
            if (widget.conversation.annonceTitre != null)
              Text(widget.conversation.annonceTitre!,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          // Bouton notation — visible seulement si pas encore noté
          dejaNoteAsync.when(
            data: (dejaNote) => dejaNote
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.star_outline),
                    tooltip: 'Laisser un avis',
                    onPressed: () async {
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NotationPage(
                            conversationId: widget.conversation.id,
                            annonceId: widget.conversation.annonceId,
                            evalueId: _autreId,
                            evalueNom:
                                widget.conversation.autreNom ?? 'Utilisateur',
                          ),
                        ),
                      );
                      if (result == true) {
                        ref.invalidate(dejaNoteProvider((
                          conversationId: widget.conversation.id,
                          evaluateurId: _currentUserId,
                        )));
                      }
                    },
                  ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (messages) {
                final tous = _fusionner(messages);
                if (tous.isEmpty) {
                  return const Center(
                    child: Text('Commencez la conversation !',
                        style: TextStyle(color: Colors.grey)),
                  );
                }
                _scrollToBottom();
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: tous.length,
                  itemBuilder: (_, i) {
                    final msg = tous[i];
                    return _MessageBubble(
                      message: msg.contenu,
                      isMine: msg.expediteurId == _currentUserId,
                      time: msg.createdAt,
                      isPending: msg.id.startsWith('local_'),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Votre message...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: (_) => _envoyer(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _envoyer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocalMessage {
  final String tempId;
  final String contenu;
  final String expediteurId;
  final DateTime createdAt;
  _LocalMessage({
    required this.tempId,
    required this.contenu,
    required this.expediteurId,
    required this.createdAt,
  });
}

class _MessageBubble extends StatelessWidget {
  final String message;
  final bool isMine;
  final DateTime? time;
  final bool isPending;
  const _MessageBubble({
    required this.message,
    required this.isMine,
    this.time,
    this.isPending = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: isMine
              ? Theme.of(context).colorScheme.primary.withValues(
                  alpha: isPending ? 0.6 : 1.0)
              : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(message,
                style: TextStyle(
                    color: isMine ? Colors.white : Colors.black87,
                    fontSize: 14)),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (time != null)
                  Text(
                    '${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                        fontSize: 10,
                        color:
                            isMine ? Colors.white70 : Colors.grey.shade500),
                  ),
                if (isPending && isMine) ...[
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(
                        strokeWidth: 1.5, color: Colors.white70),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
