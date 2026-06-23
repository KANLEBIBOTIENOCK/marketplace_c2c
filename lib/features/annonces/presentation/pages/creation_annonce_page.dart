import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/categorie.dart';
import '../providers/annonce_provider.dart';
import '../providers/categorie_provider.dart';
import '../widgets/categorie_selector.dart';

class CreationAnnoncePage extends ConsumerStatefulWidget {
  const CreationAnnoncePage({super.key});

  @override
  ConsumerState<CreationAnnoncePage> createState() =>
      _CreationAnnoncePageState();
}

class _CreationAnnoncePageState extends ConsumerState<CreationAnnoncePage> {
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prixController = TextEditingController();
  final _localisationController = TextEditingController();

  Categorie? _selectedCategorie;
  final List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    _prixController.dispose();
    _localisationController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 70);
    if (picked.isNotEmpty) {
      setState(() {
        _images.addAll(picked.take(4 - _images.length));
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authProvider).value;
    if (user == null) return;

    // Upload photos
    final List<String> photoUrls = [];
    for (final image in _images) {
      final bytes = await image.readAsBytes();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      try {
        final url = await ref.read(uploadPhotoUsecaseProvider).call(
              userId: user.id,
              filePath: fileName,
              fileBytes: bytes,
            );
        photoUrls.add(url);
      } catch (_) {}
    }

    await ref.read(creationAnnonceProvider.notifier).publier(
          titre: _titreController.text.trim(),
          utilisateurId: user.id,
          categorieId: _selectedCategorie?.id,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          prix: _prixController.text.trim().isEmpty
              ? null
              : double.tryParse(_prixController.text.trim()),
          localisation: _localisationController.text.trim().isEmpty
              ? null
              : _localisationController.text.trim(),
          photos: photoUrls,
        );

    if (!mounted) return;
    final state = ref.read(creationAnnonceProvider);
    state.when(
      data: (annonce) {
        if (annonce != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Annonce publiée avec succès !'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
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
    final creationState = ref.watch(creationAnnonceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle annonce')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photos
              const Text('Photos (max 4)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ..._images.map(
                      (img) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(img.path),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _images.remove(img)),
                                child: const CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Colors.red,
                                  child: Icon(Icons.close,
                                      size: 12, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_images.length < 4)
                      GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate,
                                  color: Colors.grey),
                              Text('Ajouter',
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Titre
              TextFormField(
                controller: _titreController,
                decoration: const InputDecoration(
                  labelText: 'Titre *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),

              // Catégorie
              const Text('Catégorie',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              CategorieSelector(
                selected: _selectedCategorie,
                onSelected: (cat) =>
                    setState(() => _selectedCategorie = cat),
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Prix
              TextFormField(
                controller: _prixController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Prix (FCFA)',
                  border: OutlineInputBorder(),
                  suffixText: 'FCFA',
                ),
              ),
              const SizedBox(height: 16),

              // Localisation
              TextFormField(
                controller: _localisationController,
                decoration: const InputDecoration(
                  labelText: 'Localisation',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Bouton publier
              SizedBox(
                width: double.infinity,
                child: creationState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.publish),
                        label: const Text('Publier l\'annonce'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
