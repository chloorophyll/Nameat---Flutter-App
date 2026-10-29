import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/place.dart';
import '../services/geocoding_service.dart';
import '../services/places_service.dart';

enum LoadStatus { loading, success, error }

class PlacesProvider extends ChangeNotifier {
  static const _customKey = 'custom_places';
  static const _budgetKey = 'budget_overrides';
  static const _photoKey = 'photo_overrides';
  static const _addressKey = 'address_cache';

  final PlacesService _service = PlacesService();
  final GeocodingService _geocoder = GeocodingService();

  List<Place> _apiPlaces = [];
  List<Place> _customPlaces = [];
  Map<int, int> _budgets = {};
  Map<int, String> _photos = {};
  Map<int, String> _addresses = {};
  LoadStatus _status = LoadStatus.loading;
  String _errorMessage = '';
  String _searchQuery = '';
  String? _cuisineFilter;
  int _budgetFilter = 0; // 0 = any
  bool _enriching = false;

  LoadStatus get status => _status;
  String get errorMessage => _errorMessage;
  String? get cuisineFilter => _cuisineFilter;
  int get budgetFilter => _budgetFilter;
  bool get hasActiveFilters => _cuisineFilter != null || _budgetFilter != 0;
  List<Place> get allPlaces => [..._customPlaces, ..._apiPlaces];

  List<String> _tokens(String? raw) {
    if (raw == null) return [];
    return raw
        .split(';')
        .map((s) => s.trim().toLowerCase())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  List<String> get cuisines {
    final set = <String>{};
    for (final p in allPlaces) {
      set.addAll(_tokens(p.cuisine));
    }
    return set.toList()..sort();
  }

  
  List<Place> get places {
    return allPlaces.where((p) {
      if (_searchQuery.isNotEmpty &&
          !p.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      if (_cuisineFilter != null) {}
        if (_cuisineFilter != null) {
        final tokens = _tokens(p.cuisine);
        bool matches = false;
        
        if (_cuisineFilter == 'fast_food') {
          matches = tokens.any((t) => 
            t.contains('fast') || 
            t.contains('burger') || 
            t.contains('chicken') ||
            t.contains('fries')
          );
        } else if (_cuisineFilter == 'international') {
          matches = tokens.any((t) => 
            t.contains('chinese') || 
            t.contains('italian') || 
            t.contains('mexican') || 
            t.contains('korean') || 
            t.contains('japanese') ||
            t.contains('international')
          );
        } else if (_cuisineFilter == 'cafe') {
          matches = tokens.any((t) => t.contains('cafe') || t.contains('bakery') || t.contains('coffee'));
        } else if (_cuisineFilter == 'ilonggo') {
          matches = tokens.any((t) => t.contains('ilonggo') || t.contains('batchoy') || t.contains('local') || t.contains('filipino'));
        } else {
          matches = tokens.contains(_cuisineFilter);
        }

        if (!matches) return false;
      }
      return true;
    }).toList();
  }

  Future<void> loadPlaces() async {
    _status = LoadStatus.loading;
    notifyListeners();
    await _loadCustomPlaces();
    await _loadSavedMaps();
    try {
      _apiPlaces = await _service.fetchPlaces();
      for (final p in _apiPlaces) {
        p.budgetLevel = _budgets[p.id] ?? 0;
        p.photo = _photos[p.id];
        p.address ??= _addresses[p.id];
      }
      _status = LoadStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = LoadStatus.error;
    }
    notifyListeners();
    if (_status == LoadStatus.success) unawaited(_enrichAddresses());
  }


  Future<void> _enrichAddresses() async {
    if (_enriching) return;
    _enriching = true;
    try {
      var lookups = 0;
      for (final p in List<Place>.from(_apiPlaces)) {
        if (p.address != null) continue;
        if (lookups >= 30) break;
        lookups++;
        final found = await _geocoder.reverse(p.latitude, p.longitude);
        if (found != null) {
          p.address = found;
          _addresses[p.id] = found;
          await _writeMap(_addressKey, _addresses);
          notifyListeners();
        }
        await Future.delayed(const Duration(milliseconds: 1100));
      }
    } finally {
      _enriching = false;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCuisineFilter(String? cuisine) {
    _cuisineFilter = cuisine;
    notifyListeners();
  }

  void setBudgetFilter(int level) {
    _budgetFilter = level;
    notifyListeners();
  }

  void clearFilters() {
    _cuisineFilter = null;
    _budgetFilter = 0;
    notifyListeners();
  }

  Future<void> setBudget(Place place, int level) async {
    place.budgetLevel = level;
    if (place.isCustom) {
      await _saveCustomPlaces();
    } else {
      _budgets[place.id] = level;
      await _writeMap(_budgetKey, _budgets);
    }
    notifyListeners();
  }


  Future<void> setPhoto(Place place, String? base64Image) async {
    place.photo = base64Image;
    if (place.isCustom) {
      await _saveCustomPlaces();
    } else {
      if (base64Image == null) {
        _photos.remove(place.id);
      } else {
        _photos[place.id] = base64Image;
      }
      await _writeMap(_photoKey, _photos);
    }
    notifyListeners();
  }


  Future<void> addPlace(Place place) async {
    _customPlaces.insert(0, place);
    await _saveCustomPlaces();
    notifyListeners();
  }

  Future<void> updatePlace(Place updated) async {
    final index = _customPlaces.indexWhere((p) => p.id == updated.id);
    if (index == -1) return;
    _customPlaces[index] = updated;
    await _saveCustomPlaces();
    notifyListeners();
  }

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

  Future<Map<String, dynamic>> _readMap(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return {};
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> _writeMap(String key, Map<int, dynamic> map) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      key,
      jsonEncode(map.map((k, v) => MapEntry(k.toString(), v))),
    );
  }

  Future<void> _loadSavedMaps() async {
    _budgets = (await _readMap(
      _budgetKey,
    )).map((k, v) => MapEntry(int.parse(k), v as int));
    _photos = (await _readMap(
      _photoKey,
    )).map((k, v) => MapEntry(int.parse(k), v as String));
    _addresses = (await _readMap(
      _addressKey,
    )).map((k, v) => MapEntry(int.parse(k), v as String));
  }
}
