import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider extends ChangeNotifier {
  static const _key = 'favorite_ids';
  final Set<int> _ids = {};

  bool isFavorite(int id) => _ids.contains(id);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_key) ?? [];
    _ids
      ..clear()
      ..addAll(saved.map(int.parse));
    notifyListeners();
  }

  Future<void> toggle(int id) async {
    if (!_ids.remove(id)) _ids.add(id);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _ids.map((e) => e.toString()).toList());
  }
}
