import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/places_provider.dart';
import 'screens/discover_screen.dart';
import 'screens/place_details_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/place_form_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => PlacesProvider()..loadPlaces(),
      child: const NameatApp(),
    ),
  );
}

class NameatApp extends StatelessWidget {
  const NameatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nameat!',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const DiscoverScreen(),
        '/details': (context) => const PlaceDetailsScreen(),
        '/favorites': (context) => const FavoritesScreen(),
        '/place-form': (context) => const PlaceFormScreen(),
      },
    );
  }
}