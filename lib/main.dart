import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/places_provider.dart';
import 'screens/home_shell.dart';
import 'screens/place_details_screen.dart';
import 'screens/place_form_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlacesProvider()..loadPlaces()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()..load()),
      ],
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
      theme: AppTheme.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeShell(),
        '/details': (context) => const PlaceDetailsScreen(),
        '/place-form': (context) => const PlaceFormScreen(),
      },
    );
  }
}
