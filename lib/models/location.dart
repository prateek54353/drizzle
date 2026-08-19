class Location {
  final String name;
  final String? region;
  final String country;
  final double latitude;
  final double longitude;

  Location({
    required this.name,
    this.region,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      name: json['name'] as String,
      region: json['admin1'] as String?,
      country: json['country'] as String? ?? 'Unknown',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'region': region,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  String get displayName {
    if (region != null && region!.isNotEmpty && country != 'Unknown') {
      return '$name, $region, $country';
    }
    if (country != 'Unknown') {
      return '$name, $country';
    }
    return name;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Location &&
        other.name == name &&
        other.region == region &&
        other.country == country &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode {
    return Object.hash(name, region, country, latitude, longitude);
  }
}
