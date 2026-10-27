import 'package:flutter_test/flutter_test.dart';
import 'package:nameat/models/place.dart';
import 'package:nameat/utils/format.dart';

void main() {
  test('Place.fromJson reads tags and handles missing fields', () {
    final place = Place.fromJson({
      'id': 1,
      'lat': 10.7,
      'lon': 122.5,
      'tags': {
        'name': 'Al Dente',
        'amenity': 'restaurant',
        'cuisine': 'italian',
      },
    });
    expect(place.name, 'Al Dente');
    expect(place.cuisine, 'italian');
    expect(place.budgetLevel, 0);
  });

  test('Place.fromJson builds an address from address tags', () {
    final place = Place.fromJson({
      'id': 2,
      'lat': 10.7,
      'lon': 122.5,
      'tags': {
        'name': 'Kambal Inasal',
        'amenity': 'fast_food',
        'addr:street': 'J. M. Basa Street',
        'addr:city': 'Iloilo City',
      },
    });
    expect(place.address, 'J. M. Basa Street, Iloilo City');
  });

  test('prettyCuisine formats raw tags', () {
    expect(prettyCuisine('donut;coffee_shop'), 'Donut, Coffee shop');
    expect(prettyCuisine(null), 'Cuisine not specified');
  });
}