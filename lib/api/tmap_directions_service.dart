import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TmapDirectionsService {
  final String _tmapApiKey = dotenv.env['TMAP_API_KEY']!;

  // 경로 정보를 요청하여 반환하는 메서드
  Future<List<LatLng>?> getDirections({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    final url = Uri.parse(
      'https://apis.openapi.sk.com/tmap/routes/pedestrian?version=1&format=json',
    );

    final headers = {
      'appKey': _tmapApiKey,
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    final body = {
      'startX': startLng.toString(),
      'startY': startLat.toString(),
      'endX': endLng.toString(),
      'endY': endLat.toString(),
      'reqCoordType': 'WGS84GEO',
      'resCoordType': 'WGS84GEO',
      'startName': '출발지',
      'endName': '도착지',
    };

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // API 응답에서 경로 데이터를 추출
        if (data['features'] != null && data['features'].isNotEmpty) {
          final List<LatLng> polyline = [];

          for (var feature in data['features']) {
            if (feature['geometry']['type'] == 'LineString') {
              for (var coord in feature['geometry']['coordinates']) {
                polyline.add(LatLng(coord[1], coord[0])); // 경로 좌표 변환
              }
            }
          }

          return polyline;
        } else {
          print('No route data available.');
        }
      } else {
        // 오류 응답 출력
        print('Failed to fetch directions. Status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching directions: $e');
    }

    return null;
  }
}
