import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

/// Looks up a street address from coordinates using OpenStreetMap Nominatim.
class GeocodingService {
  Future<String?> reverse(double latitude, double longitude) async {
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
        'format': 'jsonv2',
        'lat': '$latitude',
        'lon': '$longitude',
        'zoom': '18',
        'addressdetails': '1',
      });
      final response = await http
          .get(
            uri,
            headers: kIsWeb
                ? {}
                : {'User-Agent': 'Nameat/1.0 (student project)'},
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final address = data['address'] as Map<String, dynamic>?;
      if (address == null) return data['display_name'] as String?;

      final parts = <String>[];
      void add(String key) {
        final value = address[key];
        if (value is String && value.isNotEmpty && !parts.contains(value)) {
          parts.add(value);
        }
      }

      add('road');
      add('suburb');
      final city =
          address['city'] ?? address['town'] ?? address['municipality'];
      if (city is String && city.isNotEmpty && !parts.contains(city)) {
        parts.add(city);
      }
      if (parts.isEmpty) return data['display_name'] as String?;
      return parts.join(', ');
    } catch (_) {
      return null; // lookup is optional, so failures are silent
    }
  }
}
