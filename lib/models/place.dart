class Place {
  final int id;
  final String name;
  final String? cuisine;
  final String type;
  final double latitude;
  final double longitude;
  final String? address;
  final String? openingHours;
  int budgetLevel;
  bool isFavorite;

  Place({
    required this.id,
    required this.name,
    this.cuisine,
    required this.type,
    required this.latitude,
    required this.longitude,
    this.address,
    this.openingHours,
    this.budgetLevel = 1,
    this.isFavorite = false,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    final tags = json['tags'] as Map<String, dynamic>? ?? {};
    return Place(
      id: json['id'] as int,
      name: tags['name'] as String? ?? 'Unnamed place',
      cuisine: tags['cuisine'] as String?,
      type: tags['amenity'] as String? ?? 'restaurant',
      latitude: (json['lat'] as num).toDouble(),
      longitude: (json['lon'] as num).toDouble(),
      address: tags['addr:street'] as String?,
      openingHours: tags['opening_hours'] as String?,
    );
  }
}