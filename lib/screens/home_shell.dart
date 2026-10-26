import 'package:flutter/material.dart';
import '../widgets/app_logo.dart';
import 'discover_screen.dart';
import 'favorites_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _page = 0; // 0 = Discover, 1 = Favorites

  // Bottom bar positions: 0 = Discover, 1 = Add, 2 = Favorites
  int get _barIndex => _page == 0 ? 0 : 2;

  void _onBarTap(int index) {
    if (index == 1) {
      Navigator.pushNamed(context, '/place-form');
      return;
    }
    setState(() => _page = index == 0 ? 0 : 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        title: const Row(
          children: [AppLogo(size: 34), SizedBox(width: 10), Text('Nameat!')],
        ),
      ),
      body: IndexedStack(
        index: _page,
        children: const [DiscoverScreen(), FavoritesScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _barIndex,
        onDestinationSelected: _onBarTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline, size: 30),
            label: 'Add place',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}
