import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../../../chat/domain/entities/conversation.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../providers/annonce_provider.dart';
import '../providers/categorie_provider.dart';

class DetailAnnoncePage extends ConsumerWidget {
  final String annonceId;
  const DetailAnnoncePage({super.key, required this.annonceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final annoncesAsync = ref.watch(annoncesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return annoncesAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
      data: (annonces) {
        final annonce =
            annonces.where((a) => a.id == annonceId).firstOrNull;
        if (annonce == null) {
          return const Scaffold(
              body: Center(child: Text('Annonce introuvable')));
        }

        final categorieName = categoriesAsync.value
            ?.where((c) => c.id == annonce.categorieId)
            .firstOrNull
            ?.nom;

        final isOwner = currentUserId == annonce.utilisateurId;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Détail annonce'),
            actions: [
              if (isOwner)
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'vendue') {
                      await ref
                          .read(marquerVendueUsecaseProvider)
                          .call(annonce.id);
                      ref.invalidate(annoncesProvider);
                      if (context.mounted) Navigator.pop(context);
                    } else if (value == 'supprimer') {
                      await ref
                          .read(supprimerAnnonceUsecaseProvider)
                          .call(annonce.id);
                      ref.invalidate(annoncesProvider);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                        value: 'vendue',
                        child: Text('Marquer comme vendue')),
                    const PopupMenuItem(
                        value: 'supprimer',
                        child: Text('Supprimer',
                            style: TextStyle(color: Colors.red))),
                  ],
                ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photos
                if (annonce.photos.isNotEmpty)
                  SizedBox(
                    height: 260,
                    child: PageView.builder(
                      itemCount: annonce.photos.length,
                      itemBuilder: (_, i) => Image.network(
                        annonce.photos[i],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image,
                              size: 64, color: Colors.grey),
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(
                        child:
                            Icon(Icons.image, size: 64, color: Colors.grey)),
                  ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (annonce.statut != 'active')
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: annonce.statut == 'vendue'
                                ? Colors.green
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            annonce.statut == 'vendue' ? 'Vendu' : 'Archivé',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(annonce.titre,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        annonce.prix != null
                            ? '${annonce.prix!.toStringAsFixed(0)} FCFA'
                            : 'Prix à négocier',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (categorieName != null)
                        Row(children: [
                          const Icon(Icons.category,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(categorieName,
                              style: const TextStyle(color: Colors.grey)),
                        ]),
                      if (annonce.localisation != null) ...[
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.location_on,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(annonce.localisation!,
                              style: const TextStyle(color: Colors.grey)),
                        ]),
                      ],
                      const SizedBox(height: 16),
                      const Divider(),
                      if (annonce.description != null &&
                          annonce.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text('Description',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text(annonce.description!,
                            style: const TextStyle(
                                fontSize: 14, height: 1.5)),
                        const SizedBox(height: 16),
                      ],
                      if (annonce.createdAt != null)
                        Text(
                          'Publié le ${annonce.createdAt!.day}/${annonce.createdAt!.month}/${annonce.createdAt!.year}',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Bouton contacter le vendeur — branché sur le chat SP6
          bottomNavigationBar: !isOwner
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (currentUserId == null) return;
                      try {
                        final conv = await ref
                            .read(ouvrirConversationUsecaseProvider)
                            .call(
                              annonceId: annonce.id,
                              acheteurId: currentUserId,
                              vendeurId: annonce.utilisateurId,
                            );
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatPage(conversation: conv),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text('Contacter le vendeur'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}
