import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import 'chat_page.dart';

class ConversationsPage extends ConsumerWidget {
  const ConversationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(mesConversationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: conversationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (conversations) {
          if (conversations.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Aucune conversation pour le moment',
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                  SizedBox(height: 8),
                  Text('Contactez un vendeur depuis une annonce',
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(mesConversationsProvider),
            child: ListView.separated(
              itemCount: conversations.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final conv = conversations[index];
                // nonLus vient directement du modèle (colonnes Supabase)
                final nonLus = conv.nonLus;

                return ListTile(
                  leading: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        child: Text(
                          (conv.autreNom ?? '?')[0].toUpperCase(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (nonLus > 0)
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              nonLus > 9 ? '9+' : '$nonLus',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    conv.autreNom ?? 'Utilisateur',
                    style: TextStyle(
                        fontWeight: nonLus > 0
                            ? FontWeight.bold
                            : FontWeight.normal),
                  ),
                  subtitle: Text(
                    conv.annonceTitre ?? 'Annonce',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: nonLus > 0 ? Colors.black87 : Colors.grey,
                        fontWeight: nonLus > 0
                            ? FontWeight.w500
                            : FontWeight.normal),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ChatPage(conversation: conv)),
                    );
                    ref.invalidate(mesConversationsProvider);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
