class Location {
  final String name;
  final String? region;
  final String country;
  final double latitude;
  final double longitude;
  final String? nickname;
  final String? tag;
  final bool isFavorite;
  final int order;

  Location({
    required this.name,
    this.region,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.nickname,
    this.tag,
    this.isFavorite = false,
    this.order = 0,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      name: json['name'] as String,
      region: json['admin1'] as String?,
      country: json['country'] as String? ?? 'Unknown',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      nickname: json['nickname'] as String?,
      tag: json['tag'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      order: json['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'region': region,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'nickname': nickname,
      'tag': tag,
      'isFavorite': isFavorite,
      'order': order,
    };
  }

  String get displayName {
    if (nickname != null && nickname!.isNotEmpty) {
      return nickname!;
    }
    if (region != null && region!.isNotEmpty && country != 'Unknown') {
      return '$name, $region, $country';
    }
    if (country != 'Unknown') {
      return '$name, $country';
    }
    return name;
  }

  String get fullDisplayName {
    if (nickname != null && nickname!.isNotEmpty) {
      return '$nickname ($name)';
    }
    if (region != null && region!.isNotEmpty && country != 'Unknown') {
      return '$name, $region, $country';
    }
    if (country != 'Unknown') {
      return '$name, $country';
    }
    return name;
  }

  Location copyWith({
    String? name,
    String? region,
    String? country,
    double? latitude,
    double? longitude,
    String? nickname,
    String? tag,
    bool? isFavorite,
    int? order,
  }) {
    return Location(
      name: name ?? this.name,
      region: region ?? this.region,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      nickname: nickname ?? this.nickname,
      tag: tag ?? this.tag,
      isFavorite: isFavorite ?? this.isFavorite,
      order: order ?? this.order,
    );
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
