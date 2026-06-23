import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/categorie.dart';
import '../providers/categorie_provider.dart';

class CategorieSelector extends ConsumerWidget {
  final Categorie? selected;
  final void Function(Categorie) onSelected;

  const CategorieSelector({
    super.key,
    required this.onSelected,
    this.selected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Erreur : $e'),
      data: (categories) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: categories.map((cat) {
          final isSelected = selected?.id == cat.id;
          return ChoiceChip(
            label: Text(cat.nom),
            avatar: cat.icone != null
                ? Icon(
                    _iconFromName(cat.icone!),
                    size: 18,
                    color: isSelected ? Colors.white : null,
                  )
                : null,
            selected: isSelected,
            onSelected: (_) => onSelected(cat),
            selectedColor: Theme.of(context).colorScheme.primary,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : null,
              fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _iconFromName(String name) {
    switch (name) {
      case 'devices':
        return Icons.devices;
      case 'checkroom':
        return Icons.checkroom;
      case 'directions_car':
        return Icons.directions_car;
      case 'home':
        return Icons.home;
      case 'build':
        return Icons.build;
      case 'restaurant':
        return Icons.restaurant;
      case 'sports_soccer':
        return Icons.sports_soccer;
      case 'menu_book':
        return Icons.menu_book;
      case 'chair':
        return Icons.chair;
      case 'category':
      default:
        return Icons.category;
    }
  }
}
