import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/place.dart';
import '../providers/favorites_provider.dart';
import '../providers/places_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Place;
    final favorites = context.watch<FavoritesProvider>();
    // Look up the latest version so edits show up right away
    final place = context
        .watch<PlacesProvider>()
        .allPlaces
        .firstWhere((p) => p.id == args.id, orElse: () => args);

    return Scaffold(
      appBar: AppBar(
        title: Text(place.name),
        actions: [
          IconButton(
            icon: Icon(
              favorites.isFavorite(place.id)
                  ? Icons.favorite
                  : Icons.favorite_border,
            ),
            onPressed: () => favorites.toggle(place.id),
          ),
          if (place.isCustom) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Navigator.pushNamed(
                context,
                '/place-form',
                arguments: place,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmDelete(context, place),
            ),
          ],
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Cuisine: ${place.cuisine ?? 'Not specified'}\n'
          'Budget: ${place.budgetLevel == 0 ? 'Not set' : '₱' * place.budgetLevel}\n'
          'Address: ${place.address ?? 'Not available'}\n'
          'Hours: ${place.openingHours ?? 'Not available'}\n'
          'Notes: ${place.notes ?? 'None'}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}