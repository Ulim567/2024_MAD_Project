import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TmapService {
  final String apiKey = dotenv.env['TMAP_API_KEY']!; // .env 파일에서 API 키를 불러옵니다.

  // POI 통합 검색 API 호출
  Future<List<Map<String, dynamic>>> getAutocomplete(
      String searchKeyword) async {
    final url =
        'https://apis.openapi.sk.com/tmap/pois?version=1&format=json&searchKeyword=$searchKeyword&resCoordType=WGS84GEO&reqCoordType=WGS84GEO&count=10';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'appKey': apiKey,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final pois = data['searchPoiInfo']['pois']['poi'] as List;

      return pois
          .map((poi) => {
                'name': poi['name'],
                'lat': double.parse(poi['noorLat']),
                'lng': double.parse(poi['noorLon']),
                'address': poi['newAddressList']['newAddress'][0]
                        ['fullAddressRoad'] ??
                    '주소 정보 없음',
              })
          .toList();
    } else {
      throw Exception('Failed to load POI results');
    }
  }

  // 좌표 변환 API 호출
  Future<Map<String, double>?> convertCoordinates(
      double noorLat, double noorLon) async {
    final url =
        'https://apis.openapi.sk.com/tmap/geo/coordconvert?version=1&format=json';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'appKey': apiKey,
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'lat': noorLat,
        'lon': noorLon,
        'fromCoord': 'EPSG3857',
        'toCoord': 'WGS84GEO',
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'lat': data['coordinate']['lat'],
        'lng': data['coordinate']['lon'],
      };
    } else {
      throw Exception('Failed to convert coordinates');
    }
  }
}
