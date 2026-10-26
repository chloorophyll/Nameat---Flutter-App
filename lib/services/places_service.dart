import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import '../models/place.dart';

class PlacesService {
  static const _url = 'https://overpass-api.de/api/interpreter';
  static const _query = '''
[out:json][timeout:25];
node["amenity"~"restaurant|cafe|fast_food"]["name"](10.67,122.52,10.76,122.60);
out 100;
''';

  Future<List<Place>> fetchPlaces() async {
    try {
      final response = await http
          .post(
            Uri.parse(_url),
            headers: kIsWeb ? {} : {'User-Agent': 'Nameat/1.0'},
            body: {'data': _query},
          )
          .timeout(const Duration(seconds: 40));

      if (response.statusCode != 200) {
        throw Exception('status ${response.statusCode}');
      }
      final places = _parse(response.body);
      debugPrint('SOURCE: LIVE API (${places.length} places)');
      return places;
    } catch (e) {
      debugPrint('SOURCE: FALLBACK FILE. Live call failed: $e');
      final text = await rootBundle.loadString('assets/sample_places.json');
      return _parse(text);
    }
  }

  List<Place> _parse(String body) {
    final data = jsonDecode(body) as Map<String, dynamic>;
    final elements = data['elements'] as List<dynamic>;
    return elements
        .map((e) => Place.fromJson(e as Map<String, dynamic>))
        .where((p) => p.name != 'Unnamed place')
        .toList();
  }
}
