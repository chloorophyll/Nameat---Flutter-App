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

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlacesProvider>();

    return Scaffold(
      body: Column(
        children: [
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
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
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
