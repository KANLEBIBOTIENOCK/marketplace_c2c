import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../avis/presentation/providers/avis_provider.dart';
import '../../../avis/presentation/widgets/star_rating.dart';
import '../providers/auth_provider.dart';
import 'connexion_page.dart';

class ProfilPage extends ConsumerWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).deconnecter();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ConnexionPage()),
                );
              }
            },
          ),
        ],
      ),
      body: authState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (user) {
          if (user == null) return const Center(child: Text('Non connecté'));

          final avisAsync = ref.watch(avisUtilisateurProvider(user.id));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundImage: user.photoUrl != null
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    child: user.photoUrl == null
                        ? const Icon(Icons.person, size: 48)
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                // Note étoiles
                Center(
                  child: Column(
                    children: [
                      StarDisplay(note: user.noteMoyenne, size: 24),
                      const SizedBox(height: 4),
                      Text(
                        user.noteMoyenne > 0
                            ? '${user.noteMoyenne} / 5 (${user.nombreAvis} avis)'
                            : 'Pas encore d\'avis',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _InfoTile(label: 'Nom', value: user.nom ?? '—'),
                _InfoTile(label: 'Email', value: user.email ?? '—'),
                _InfoTile(label: 'Téléphone', value: user.telephone ?? '—'),
                _InfoTile(
                    label: 'Localisation', value: user.localisation ?? '—'),
                const SizedBox(height: 24),
                // Avis reçus
                const Text('Avis reçus',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                avisAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text(e.toString()),
                  data: (avisList) {
                    if (avisList.isEmpty) {
                      return const Text(
                        'Aucun avis pour le moment.',
                        style: TextStyle(color: Colors.grey),
                      );
                    }
                    return Column(
                      children: avisList.map((avis) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                StarDisplay(
                                    note: avis.note.toDouble(), size: 18),
                                if (avis.commentaire != null &&
                                    avis.commentaire!.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(avis.commentaire!,
                                      style: const TextStyle(fontSize: 14)),
                                ],
                                const SizedBox(height: 4),
                                Text(
                                  avis.createdAt != null
                                      ? '${avis.createdAt!.day}/${avis.createdAt!.month}/${avis.createdAt!.year}'
                                      : '',
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
