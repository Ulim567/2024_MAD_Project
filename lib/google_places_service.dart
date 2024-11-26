import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GooglePlacesService {
  final String apiKey =
      dotenv.env['GOOGLE_API_KEY']!; // .env 파일에서 API 키를 불러옵니다.

  // 주소 자동완성 API 호출
  Future<List<String>> getAutocomplete(String input) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&language=ko&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final predictions = data['predictions'] as List;

      return predictions
          .map((prediction) => prediction['description'] as String)
          .toList();
    } else {
      throw Exception('Failed to load autocomplete results');
    }
  }

  // 주소를 좌표로 변환하는 API 호출
  Future<Map<String, double>?> getLatLngFromAddress(String address) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'].isNotEmpty) {
        final location = data['results'][0]['geometry']['location'];
        return {
          'lat': location['lat'],
          'lng': location['lng'],
        };
      }
      return null;
    } else {
      throw Exception('Failed to get coordinates from address');
    }
  }
}
