import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class KakaoDirectionsService {
  final String _kakaoApiKey = dotenv.env['KAKAO_API_KEY']!;

  // 경로 정보를 요청하여 반환하는 메소드
  Future<List<LatLng>?> getDirections({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    final url = Uri.parse(
      'https://apis-navi.kakaomobility.com/v1/directions?'
      'origin=$startLng,$startLat&destination=$endLng,$endLat'
      '&waypoints=&priority=RECOMMEND&car_fuel=GASOLINE&car_hipass=false'
      '&alternatives=false&road_details=false',
    );

    final headers = {
      'Authorization': 'KakaoAK $_kakaoApiKey',
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Ensure the API response contains route data
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0]['sections'][0]['roads'];

          List<LatLng> polyline = [];
          for (var point in route) {
            polyline.add(LatLng(point[1], point[0])); // 경로 좌표 변환 (위도, 경도 순)
          }

          return polyline;
        } else {
          print('No route data available.');
        }
      } else {
        // Print the full response body to understand the error
        print('Failed to fetch directions. Status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching directions: $e');
    }

    return null;
  }
}
