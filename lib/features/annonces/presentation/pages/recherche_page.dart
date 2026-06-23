import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/categorie_provider.dart';
import '../providers/recherche_provider.dart';
import '../widgets/annonce_card.dart';
import 'detail_annonce_page.dart';

class RecherchePage extends ConsumerStatefulWidget {
  const RecherchePage({super.key});

  @override
  ConsumerState<RecherchePage> createState() => _RecherchePageState();
}

class _RecherchePageState extends ConsumerState<RecherchePage> {
  final _searchController = TextEditingController();
  final _prixMinController = TextEditingController();
  final _prixMaxController = TextEditingController();
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    _prixMinController.dispose();
    _prixMaxController.dispose();
    super.dispose();
  }

  void _appliquerRecherche() {
    final prixMin = double.tryParse(_prixMinController.text.trim());
    final prixMax = double.tryParse(_prixMaxController.text.trim());
    ref.read(rechercheParamsProvider.notifier).update((state) => state.copyWith(
          query: _searchController.text.trim(),
          prixMin: prixMin,
          prixMax: prixMax,
          resetPrixMin: _prixMinController.text.isEmpty,
          resetPrixMax: _prixMaxController.text.isEmpty,
        ));
  }

  void _resetFiltres() {
    _searchController.clear();
    _prixMinController.clear();
    _prixMaxController.clear();
    ref.read(rechercheParamsProvider.notifier).state =
        const RechercheParams();
  }

  @override
  Widget build(BuildContext context) {
    final params = ref.watch(rechercheParamsProvider);
    final resultats = ref.watch(rechercheProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recherche'),
        actions: [
          if (!params.isEmpty)
            TextButton(
              onPressed: _resetFiltres,
              child: const Text('Réinitialiser'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher une annonce...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    ),
                    onSubmitted: (_) => _appliquerRecherche(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.tune,
                    color: _showFilters
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  onPressed: () =>
                      setState(() => _showFilters = !_showFilters),
                  tooltip: 'Filtres',
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _appliquerRecherche,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),

          // Panneau filtres
          if (_showFilters)
            Container(
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Catégorie
                  const Text('Catégorie',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  categoriesAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text(e.toString()),
                    data: (categories) => Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        FilterChip(
                          label: const Text('Toutes'),
                          selected: params.categorieId == null,
                          onSelected: (_) => ref
                              .read(rechercheParamsProvider.notifier)
                              .update((s) => s.copyWith(resetCategorie: true)),
                        ),
                        ...categories.map((cat) => FilterChip(
                              label: Text(cat.nom),
                              selected: params.categorieId == cat.id,
                              onSelected: (_) => ref
                                  .read(rechercheParamsProvider.notifier)
                                  .update((s) => s.copyWith(
                                      categorieId: cat.id)),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Prix
                  const Text('Prix (FCFA)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _prixMinController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Min',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 10),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('—'),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _prixMaxController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Max',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Tri
                  const Text('Trier par',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: [
                      ChoiceChip(
                        label: const Text('Plus récent'),
                        selected: params.tri == 'recent',
                        onSelected: (_) => ref
                            .read(rechercheParamsProvider.notifier)
                            .update((s) => s.copyWith(tri: 'recent')),
                      ),
                      ChoiceChip(
                        label: const Text('Prix ↑'),
                        selected: params.tri == 'prix_asc',
                        onSelected: (_) => ref
                            .read(rechercheParamsProvider.notifier)
                            .update((s) => s.copyWith(tri: 'prix_asc')),
                      ),
                      ChoiceChip(
                        label: const Text('Prix ↓'),
                        selected: params.tri == 'prix_desc',
                        onSelected: (_) => ref
                            .read(rechercheParamsProvider.notifier)
                            .update((s) => s.copyWith(tri: 'prix_desc')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _appliquerRecherche,
                      child: const Text('Appliquer'),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Résultats
          Expanded(
            child: resultats.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (annonces) {
                if (annonces.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          params.query.isNotEmpty
                              ? 'Aucun résultat pour "${params.query}"'
                              : 'Aucune annonce trouvée',
                          style: const TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Text(
                            '${annonces.length} résultat${annonces.length > 1 ? 's' : ''}',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: annonces.length,
                        itemBuilder: (context, index) {
                          final annonce = annonces[index];
                          return AnnonceCard(
                            annonce: annonce,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailAnnoncePage(
                                    annonceId: annonce.id),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
