import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart'; // dotenv 패키지 사용

class GoogleDirectionsService {
  // .env 파일에서 API 키를 가져옴
  final String _apiKey = dotenv.env['GOOGLE_API_KEY']!;

  Future<List<List<double>>?> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    // 요청 URL 로그로 출력
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$_apiKey');
    print('Requesting directions from: $url');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Response data: $data'); // 전체 응답 로그

        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0]; // 첫 번째 경로
          print('First route: $route'); // 첫 번째 경로 데이터 로그

          if (route['overview_polyline'] != null &&
              route['overview_polyline']['points'] != null) {
            final points = route['overview_polyline']['points'];
            print('Polyline points: $points'); // Polyline 문자열 로그

            return _decodePolyline(points);
          } else {
            print('No overview_polyline found in the route.');
          }
        } else {
          print('No routes found in the response.');
        }
      } else {
        print(
            'Failed to fetch directions. HTTP status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching directions: $e');
    }

    return null;
  }

  List<List<double>> _decodePolyline(String polyline) {
    List<List<double>> points = [];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0;
      int b;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add([lat / 1E5, lng / 1E5]);
    }

    print('Decoded polyline points: $points'); // 디코딩된 좌표 로그
    return points;
  }
}
