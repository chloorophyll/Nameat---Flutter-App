import 'package:flutter/foundation.dart';
import '../models/place.dart';
import '../services/places_service.dart';

enum LoadStatus { loading, success, error }

class PlacesProvider extends ChangeNotifier {
  final PlacesService _service = PlacesService();

  List<Place> _places = [];
  LoadStatus _status = LoadStatus.loading;
  String _errorMessage = '';
  String _searchQuery = '';

  LoadStatus get status => _status;
  String get errorMessage => _errorMessage;

  List<Place> get places {
    if (_searchQuery.isEmpty) return _places;
    return _places
        .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Future<void> loadPlaces() async {
    _status = LoadStatus.loading;
    notifyListeners();
    try {
      _places = await _service.fetchPlaces();
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
}