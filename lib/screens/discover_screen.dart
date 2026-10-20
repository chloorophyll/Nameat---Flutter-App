import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/places_provider.dart';
import '../widgets/place_card.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlacesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            tooltip: 'Favorites',
            onPressed: () => Navigator.pushNamed(context, '/favorites'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/place-form'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search places',
                border: OutlineInputBorder(),
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
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Could not load places.'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: context.read<PlacesProvider>().loadPlaces,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (provider.places.isEmpty) {
      return const Center(child: Text('No places found.'));
    }

    final favorites = context.watch<FavoritesProvider>();
    return ListView.builder(
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