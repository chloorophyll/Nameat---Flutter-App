import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Place;
    final favorites = context.watch<FavoritesProvider>();
    final place = context
        .watch<PlacesProvider>()
        .allPlaces
        .firstWhere((p) => p.id == args.id, orElse: () => args);
    final theme = Theme.of(context);

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
          Container(
            height: 180,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _iconFor(place.type),
              size: 80,
              color: theme.colorScheme.onPrimaryContainer,
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