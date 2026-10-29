import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/places_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/place_card.dart';
import '../widgets/roulette_sheet.dart';
import '../widgets/skeleton_card.dart';
import '../providers/auth_provider.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlacesProvider>();
    final name = context.watch<AuthProvider>().displayName;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi, $name! What are you craving today?',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Welcome to Iloilo City, the City of Gastronomy ✨',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search places',
                    ),
                    onChanged: context.read<PlacesProvider>().setSearchQuery,
                  ),
                ),
                const SizedBox(width: 8),
                Badge(
                  isLabelVisible: provider.hasActiveFilters,
                  child: IconButton.filledTonal(
                    tooltip: 'Filters',
                    icon: const Icon(Icons.tune),
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => const FilterSheet(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Category Quick-Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildCategoryChip(context, provider, 'All', null),
                  const SizedBox(width: 8),
                  _buildCategoryChip(context, provider, 'Ilonggo Specialties', 'ilonggo'),
                  const SizedBox(width: 8),
                  _buildCategoryChip(context, provider, 'International', 'international'),
                  const SizedBox(width: 8),
                  _buildCategoryChip(context, provider, 'Cafes & Bakery', 'cafe'),
                  const SizedBox(width: 8),
                  _buildCategoryChip(context, provider, 'Fast Food', 'fast food'),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: provider.status == LoadStatus.success
                    ? () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => RouletteSheet(places: provider.places),
                        )
                    : null,
                icon: const Icon(Icons.casino_outlined),
                label: const Text("Can't decide? Spin for a place"),
              ),
            ),
          ),
          Expanded(child: _buildBody(context, provider)),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, PlacesProvider provider, String label, String? cuisineValue) {
    final isSelected = cuisineValue == null 
        ? provider.cuisineFilter == null 
        : provider.cuisineFilter == cuisineValue;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        provider.setCuisineFilter(selected ? cuisineValue : null);
      },
    );
  }

  Widget _buildBody(BuildContext context, PlacesProvider provider) {
    if (provider.status == LoadStatus.loading) {
      return ListView.builder(
        itemCount: 6, 
        itemBuilder: (context, index) => const SkeletonCard(),
      );
    }
    if (provider.status == LoadStatus.error) {
      return EmptyState(
        icon: Icons.wifi_off,
        title: 'Could not load places',
        message: 'Check your internet connection and try again.',
        actionLabel: 'Retry',
        onAction: context.read<PlacesProvider>().loadPlaces,
      );
    }
    if (provider.places.isEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        title: 'No places found',
        message: provider.hasActiveFilters
            ? 'No places match your filters.'
            : 'Try a different search, or add your own place with Add.',
        actionLabel: provider.hasActiveFilters ? 'Reset filters' : null,
        onAction: provider.hasActiveFilters
            ? context.read<PlacesProvider>().clearFilters
            : null,
      );
    }

    final favorites = context.watch<FavoritesProvider>();
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: provider.places.length,
      itemBuilder: (context, index) {
        final place = provider.places[index];
        return PlaceCard(
          place: place,
          isFavorite: favorites.isFavorite(place.id),
          onFavorite: () {
            final added = !favorites.isFavorite(place.id);
            favorites.toggle(place.id);
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  added
                      ? 'Saved ${place.name} to favorites'
                      : 'Removed ${place.name}',
                ),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          onTap: () =>
              Navigator.pushNamed(context, '/details', arguments: place),
        );
      },
    );
  }
}