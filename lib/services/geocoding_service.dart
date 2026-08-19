import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location.dart';

class GeocodingService {
  static const String _baseUrl = 'https://geocoding-api.open-meteo.com/v1/search';
  
  final http.Client _client;

  GeocodingService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Location>> searchCities(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final url = Uri.parse(_baseUrl).replace(queryParameters: {
      'name': query,
      'count': '5',
      'language': 'en',
      'format': 'json',
    });

    final response = await _client.get(url).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw Exception('Request timeout');
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List?;
      
      if (results == null || results.isEmpty) {
        return [];
      }

      return results
          .map((json) => Location.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to search cities: ${response.statusCode}');
    }
  }

  Future<List<Location>> searchNearbyCities(double lat, double lon) async {
    // Search for nearby cities by using a radius-based approach
    // Open-Meteo doesn't have a direct nearby search, so we'll search by coordinates
    final url = Uri.parse(_baseUrl).replace(queryParameters: {
      'name': '$lat,$lon',
      'count': '5',
      'language': 'en',
      'format': 'json',
    });

    try {
      final response = await _client.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List?;
        
        if (results == null || results.isEmpty) {
          return [];
        }

        return results
            .map((json) => Location.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      // If reverse geocoding fails, return empty list
    }
    
    return [];
  }

  void dispose() {
    _client.close();
  }
}
