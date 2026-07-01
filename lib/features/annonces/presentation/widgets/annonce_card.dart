import 'package:flutter/material.dart';
import '../../domain/entities/annonce.dart';

class AnnonceCard extends StatelessWidget {
  final Annonce annonce;
  final VoidCallback onTap;

  const AnnonceCard({
    super.key,
    required this.annonce,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Photo flexible — pas de hauteur fixe
            AspectRatio(
              aspectRatio: 1.2,
              child: annonce.photos.isNotEmpty
                  ? Image.network(
                      annonce.photos.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    annonce.titre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    annonce.prix != null
                        ? '${annonce.prix!.toStringAsFixed(0)} FCFA'
                        : 'Prix à négocier',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  if (annonce.localisation != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 11, color: Colors.grey),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            annonce.localisation!,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.image, size: 40, color: Colors.grey),
      ),
    );
  }
}
