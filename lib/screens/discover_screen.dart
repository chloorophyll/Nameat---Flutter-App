import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/places_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/place_card.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlacesProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/place-form'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search places',
              ),
              onChanged: context.read<PlacesProvider>().setSearchQuery,
            ),
          ),
          Expanded(child: _buildBody(context, provider)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, PlacesProvider provider) {
    if (provider.status == LoadStatus.loading) {
      return const Center(child: CircularProgressIndicator());
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
      return const EmptyState(
        icon: Icons.search_off,
        title: 'No places found',
        message: 'Try a different search, or add your own place with +.',
      );
    }

    final favorites = context.watch<FavoritesProvider>();
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: provider.places.length,
      itemBuilder: (context, index) {
        final place = provider.places[index];
        return PlaceCard(
          place: place,
          isFavorite: favorites.isFavorite(place.id),
          onFavorite: () => favorites.toggle(place.id),
          onTap: () =>
              Navigator.pushNamed(context, '/details', arguments: place),
        );
      },
    );
  }
}