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
  int budgetLevel; 
  bool isFavorite;
  final bool isCustom; 

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
    this.budgetLevel = 0,
    this.isFavorite = false,
    this.isCustom = false,
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
        budgetLevel: map['budgetLevel'] as int? ?? 0,
        isCustom: true,
      );
}