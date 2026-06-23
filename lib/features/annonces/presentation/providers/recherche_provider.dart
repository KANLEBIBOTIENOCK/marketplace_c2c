import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../../data/models/annonce_model.dart';
import '../../domain/entities/annonce.dart';

class RechercheParams {
  final String query;
  final int? categorieId;
  final double? prixMin;
  final double? prixMax;
  final String tri;

  const RechercheParams({
    this.query = '',
    this.categorieId,
    this.prixMin,
    this.prixMax,
    this.tri = 'recent',
  });

  RechercheParams copyWith({
    String? query,
    int? categorieId,
    double? prixMin,
    double? prixMax,
    String? tri,
    bool resetCategorie = false,
    bool resetPrixMin = false,
    bool resetPrixMax = false,
  }) {
    return RechercheParams(
      query: query ?? this.query,
      categorieId: resetCategorie ? null : (categorieId ?? this.categorieId),
      prixMin: resetPrixMin ? null : (prixMin ?? this.prixMin),
      prixMax: resetPrixMax ? null : (prixMax ?? this.prixMax),
      tri: tri ?? this.tri,
    );
  }

  bool get isEmpty =>
      query.isEmpty &&
      categorieId == null &&
      prixMin == null &&
      prixMax == null &&
      tri == 'recent';
}

class RechercheParamsNotifier extends Notifier<RechercheParams> {
  @override
  RechercheParams build() => const RechercheParams();

  void update(RechercheParams Function(RechercheParams) updater) {
    state = updater(state);
  }
}

final rechercheParamsProvider =
    NotifierProvider<RechercheParamsNotifier, RechercheParams>(
      () => RechercheParamsNotifier(),
    );

final rechercheProvider = FutureProvider.autoDispose<List<Annonce>>((
  ref,
) async {
  final params = ref.watch(rechercheParamsProvider);
  final client = Supabase.instance.client;

  // Construire les filtres progressivement
  var builder = client.from('annonces').select().eq('statut', 'active');

  if (params.query.isNotEmpty) {
    builder = builder.textSearch(
      'search_vector',
      params.query,
      config: 'french',
      type: TextSearchType.websearch,
    );
  }
  if (params.categorieId != null) {
    builder = builder.eq('categorie_id', params.categorieId!);
  }
  if (params.prixMin != null) {
    builder = builder.gte('prix', params.prixMin!);
  }
  if (params.prixMax != null) {
    builder = builder.lte('prix', params.prixMax!);
  }

  // Appliquer le tri en dernière étape (retourne PostgrestTransformBuilder)
  final ascending = params.tri == 'prix_asc';
  final orderColumn = params.tri == 'recent' ? 'created_at' : 'prix';

  final data = await builder.order(orderColumn, ascending: ascending);

  return (data as List)
      .map((e) => AnnonceModel.fromJson(e as Map<String, dynamic>))
      .toList();
});
