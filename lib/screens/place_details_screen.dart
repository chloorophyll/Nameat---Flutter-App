import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/place.dart';
import '../providers/favorites_provider.dart';
import '../providers/places_provider.dart';
import '../utils/format.dart';
import '../widgets/budget_badge.dart';

class PlaceDetailsScreen extends StatelessWidget {
  const PlaceDetailsScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, Place place) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete place?'),
        content: Text('Remove "${place.name}" from your places?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<PlacesProvider>().deletePlace(place.id);
      if (context.mounted) Navigator.pop(context);
    }
  }

  Future<void> _openInMaps(BuildContext context, Place place) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1'
      '&query=${place.latitude},${place.longitude}',
    );
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Maps')),
      );
    }
  }

  Future<void> _pickPhoto(BuildContext context, Place place) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 70,
    );
    if (picked == null || !context.mounted) return;
    final bytes = await picked.readAsBytes();
    if (!context.mounted) return;
    await context.read<PlacesProvider>().setPhoto(place, base64Encode(bytes));
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'cafe':
        return Icons.local_cafe;
      case 'fast_food':
        return Icons.fastfood;
      default:
        return Icons.restaurant;
    }
  }

  Widget _header(BuildContext context, Place place) {
    final theme = Theme.of(context);
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: place.photo != null
          ? Image.memory(
              base64Decode(place.photo!),
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              gaplessPlayback: true,
            )
          : Icon(
              _iconFor(place.type),
              size: 80,
              color: theme.colorScheme.onPrimaryContainer,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Place;
    final favorites = context.watch<FavoritesProvider>();
    final place = context
        .watch<PlacesProvider>()
        .allPlaces
        .firstWhere((p) => p.id == args.id, orElse: () => args);
    final theme = Theme.of(context);
    final hasLocation = place.latitude != 0 || place.longitude != 0;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: 'Save to favorites',
            icon: Icon(
              favorites.isFavorite(place.id)
                  ? Icons.favorite
                  : Icons.favorite_border,
            ),
            onPressed: () => favorites.toggle(place.id),
          ),
          if (place.isCustom) ...[
            IconButton(
              tooltip: 'Edit place',
              icon: const Icon(Icons.edit),
              onPressed: () => Navigator.pushNamed(
                context,
                '/place-form',
                arguments: place,
              ),
            ),
            IconButton(
              tooltip: 'Delete place',
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmDelete(context, place),
            ),
          ],
        ],
      ),
      body: ListView(
        children: [
          _header(context, place),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _pickPhoto(context, place),
                  icon: const Icon(Icons.add_a_photo_outlined),
                  label: Text(
                    place.photo == null ? 'Add photo' : 'Change photo',
                  ),
                ),
                if (place.photo != null) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () =>
                        context.read<PlacesProvider>().setPhoto(place, null),
                    child: const Text('Remove'),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                BudgetBadge(level: place.budgetLevel),
                const SizedBox(height: 16),
                _InfoRow(
                  icon: Icons.restaurant_menu,
                  label: 'Cuisine',
                  value: prettyCuisine(place.cuisine),
                ),
                _InfoRow(
                  icon: Icons.place_outlined,
                  label: 'Address',
                  value: place.address ?? 'Not available',
                ),
                _InfoRow(
                  icon: Icons.schedule,
                  label: 'Opening hours',
                  value: place.openingHours ?? 'Not available',
                ),
                if (place.notes != null)
                  _InfoRow(
                    icon: Icons.notes,
                    label: 'Notes',
                    value: place.notes!,
                  ),
                const SizedBox(height: 12),
                Text('Set budget level', style: theme.textTheme.labelMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [1, 2, 3].map((level) {
                    return ChoiceChip(
                      label: Text('₱' * level),
                      selected: place.budgetLevel == level,
                      onSelected: (_) => context
                          .read<PlacesProvider>()
                          .setBudget(place, level),
                    );
                  }).toList(),
                ),
                if (hasLocation) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _openInMaps(context, place),
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('Open in Maps'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelMedium),
                Text(value, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}