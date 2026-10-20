import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/place.dart';
import '../services/places_service.dart';

enum LoadStatus { loading, success, error }

class PlacesProvider extends ChangeNotifier {
  static const _customKey = 'custom_places';
  final PlacesService _service = PlacesService();

  List<Place> _apiPlaces = [];
  List<Place> _customPlaces = [];
  LoadStatus _status = LoadStatus.loading;
  String _errorMessage = '';
  String _searchQuery = '';

  LoadStatus get status => _status;
  String get errorMessage => _errorMessage;
  List<Place> get allPlaces => [..._customPlaces, ..._apiPlaces];

  List<Place> get places {
    final all = allPlaces;
    if (_searchQuery.isEmpty) return all;
    return all
        .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Future<void> loadPlaces() async {
    _status = LoadStatus.loading;
    notifyListeners();
    await _loadCustomPlaces();
    try {
      _apiPlaces = await _service.fetchPlaces();
      _status = LoadStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // CREATE
  Future<void> addPlace(Place place) async {
    _customPlaces.insert(0, place);
    await _saveCustomPlaces();
    notifyListeners();
  }

  // UPDATE
  Future<void> updatePlace(Place updated) async {
    final index = _customPlaces.indexWhere((p) => p.id == updated.id);
    if (index == -1) return;
    _customPlaces[index] = updated;
    await _saveCustomPlaces();
    notifyListeners();
  }

  // DELETE
  Future<void> deletePlace(int id) async {
    _customPlaces.removeWhere((p) => p.id == id);
    await _saveCustomPlaces();
    notifyListeners();
  }

  Future<void> _loadCustomPlaces() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_customKey) ?? [];
    _customPlaces = saved
        .map((s) => Place.fromMap(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveCustomPlaces() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _customKey,
      _customPlaces.map((p) => jsonEncode(p.toMap())).toList(),
    );
  }
}