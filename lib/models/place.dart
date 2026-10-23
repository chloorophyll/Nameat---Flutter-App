class Place {
  final int id;
  String name;
  String? cuisine;
  final String type;
  final double latitude;
  final double longitude;
  String? address;
  final String? openingHours;
  String? notes;
  String? photo; // base64-encoded image added by the user
  int budgetLevel; // 0 = not set, 1 to 3 = P, PP, PPP
  bool isFavorite;
  final bool isCustom; // true for places the user added

  Place({
    required this.id,
    required this.name,
    this.cuisine,
    required this.type,
    required this.latitude,
    required this.longitude,
    this.address,
    this.openingHours,
    this.notes,
    this.photo,
    this.budgetLevel = 0,
    this.isFavorite = false,
    this.isCustom = false,
  });

  /// Builds a readable address from whatever address tags the data has.
  static String? _buildAddress(Map<String, dynamic> tags) {
    final parts = <String>[];
    final street = tags['addr:street'] as String?;
    final house = tags['addr:housenumber'] as String?;
    if (street != null) {
      parts.add(house != null ? '$house $street' : street);
    }
    final suburb = tags['addr:suburb'] as String?;
    if (suburb != null) parts.add(suburb);
    final city = tags['addr:city'] as String?;
    if (city != null) parts.add(city);
    return parts.isEmpty ? null : parts.join(', ');
  }

  factory Place.fromJson(Map<String, dynamic> json) {
    final tags = json['tags'] as Map<String, dynamic>? ?? {};
    return Place(
      id: json['id'] as int,
      name: tags['name'] as String? ?? 'Unnamed place',
      cuisine: tags['cuisine'] as String?,
      type: tags['amenity'] as String? ?? 'restaurant',
      latitude: (json['lat'] as num).toDouble(),
      longitude: (json['lon'] as num).toDouble(),
      address: _buildAddress(tags),
      openingHours: tags['opening_hours'] as String?,
    );
  }

  // Used to save user-added places on the device
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'cuisine': cuisine,
    'type': type,
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
    'openingHours': openingHours,
    'notes': notes,
    'photo': photo,
    'budgetLevel': budgetLevel,
  };

  factory Place.fromMap(Map<String, dynamic> map) => Place(
    id: map['id'] as int,
    name: map['name'] as String,
    cuisine: map['cuisine'] as String?,
    type: map['type'] as String? ?? 'restaurant',
    latitude: (map['latitude'] as num).toDouble(),
    longitude: (map['longitude'] as num).toDouble(),
    address: map['address'] as String?,
    openingHours: map['openingHours'] as String?,
    notes: map['notes'] as String?,
    photo: map['photo'] as String?,
    budgetLevel: map['budgetLevel'] as int? ?? 0,
    isCustom: true,
  );
}
