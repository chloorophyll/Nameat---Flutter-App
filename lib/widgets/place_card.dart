import 'package:flutter/material.dart';
import '../models/place.dart';

class PlaceCard extends StatelessWidget {
  final Place place;
  final VoidCallback onTap;

  const PlaceCard({super.key, required this.place, required this.onTap});

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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: Icon(_iconFor(place.type), size: 32),
        title: Text(place.name),
        subtitle: Text(
          '${place.cuisine ?? 'Cuisine not specified'}\n'
          '${place.address ?? 'Address not available'}',
        ),
        isThreeLine: true,
        onTap: onTap,
      ),
    );
  }
}