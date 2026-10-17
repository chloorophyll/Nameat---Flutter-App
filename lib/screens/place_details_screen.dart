import 'package:flutter/material.dart';
import '../models/place.dart';

class PlaceDetailsScreen extends StatelessWidget {
  const PlaceDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final place = ModalRoute.of(context)!.settings.arguments as Place;

    return Scaffold(
      appBar: AppBar(title: Text(place.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Cuisine: ${place.cuisine ?? 'Not specified'}\n'
          'Address: ${place.address ?? 'Not available'}\n'
          'Hours: ${place.openingHours ?? 'Not available'}',
        ),
      ),
    );
  }
}