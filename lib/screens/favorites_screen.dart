import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/places_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/place_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final places = context
        .watch<PlacesProvider>()
        .allPlaces
        .where((p) => favorites.isFavorite(p.id))
        .toList();
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'Your favorites',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: places.isEmpty
                ? const EmptyState(
                    icon: Icons.favorite_border,
                    title: 'No favorites yet',
                    message: 'Tap the heart on a place to save it here.',
                  )
                : ListView.builder(
                    itemCount: places.length,
                    itemBuilder: (context, index) {
                      final place = places[index];
                      return PlaceCard(
                        place: place,
                        isFavorite: true,
                        onFavorite: () => favorites.toggle(place.id),
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/details',
                          arguments: place,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
