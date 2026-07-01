import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../providers/avis_provider.dart';
import '../widgets/star_rating.dart';

class NotationPage extends ConsumerStatefulWidget {
  final String conversationId;
  final String annonceId;
  final String evalueId;
  final String evalueNom;

  const NotationPage({
    super.key,
    required this.conversationId,
    required this.annonceId,
    required this.evalueId,
    required this.evalueNom,
  });

  @override
  ConsumerState<NotationPage> createState() => _NotationPageState();
}

class _NotationPageState extends ConsumerState<NotationPage> {
  int _note = 0;
  final _commentaireController = TextEditingController();

  @override
  void dispose() {
    _commentaireController.dispose();
    super.dispose();
  }

  Future<void> _soumettre() async {
    if (_note == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une note')),
      );
      return;
    }
    final evaluateurId =
        Supabase.instance.client.auth.currentUser?.id ?? '';
    if (evaluateurId.isEmpty) return;

    await ref.read(avisNotifierProvider.notifier).soumettre(
          conversationId: widget.conversationId,
          annonceId: widget.annonceId,
          evaluateurId: evaluateurId,
          evalueId: widget.evalueId,
          note: _note,
          commentaire: _commentaireController.text.trim().isEmpty
              ? null
              : _commentaireController.text.trim(),
        );

    if (!mounted) return;
    final state = ref.read(avisNotifierProvider);
    state.when(
      data: (avis) {
        if (avis != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Avis soumis avec succès !'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      },
      error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      ),
      loading: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final avisState = ref.watch(avisNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Laisser un avis')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 40,
              backgroundColor:
                  Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                widget.evalueNom[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 32,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Comment s\'est passée votre transaction\navec ${widget.evalueNom} ?',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            StarRating(
              initialNote: _note,
              onChanged: (n) => setState(() => _note = n),
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              _note == 0 ? 'Touchez une étoile pour noter' : _labelNote(_note),
              style: TextStyle(
                color: _note == 0
                    ? Colors.grey
                    : Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _commentaireController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Commentaire (optionnel)',
                border: OutlineInputBorder(),
                hintText: 'Partagez votre expérience...',
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: avisState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _soumettre,
                      icon: const Icon(Icons.send),
                      label: const Text('Soumettre l\'avis'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _labelNote(int note) {
    switch (note) {
      case 1: return 'Très mauvais';
      case 2: return 'Mauvais';
      case 3: return 'Correct';
      case 4: return 'Bien';
      case 5: return 'Excellent !';
      default: return '';
    }
  }
}
