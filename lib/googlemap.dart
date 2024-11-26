import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart'; // geolocator 임포트
import 'google_places_service.dart';

class GoogleTempPage extends StatefulWidget {
  const GoogleTempPage({super.key});

  @override
  State<GoogleTempPage> createState() => _GoogleTempPageState();
}

class _GoogleTempPageState extends State<GoogleTempPage> {
  late GoogleMapController mapController;
  LatLng _currentLatLng = const LatLng(36.0821603, 129.398434); // 기본 위치
  TextEditingController _searchController = TextEditingController();
  List<String> _addressSuggestions = [];
  LatLng? _searchedLocation;
  bool _isLocationLoaded = false;

  final GooglePlacesService _placesService = GooglePlacesService();

  @override
  void initState() {
    super.initState();
    _getLocation(); // 현재 위치 가져오기
  }

  Future<void> _getLocation() async {
    // 현재 권한 상태 확인
    LocationPermission permission = await Geolocator.checkPermission();

    // 권한 요청 및 상태 확인
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // 권한이 거부된 경우
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("위치 권한이 필요합니다.")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // 권한이 영구적으로 거부된 경우
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("앱 설정에서 위치 권한을 활성화해주세요."),
        ),
      );
      return;
    }
    // 권한이 허용된 경우 위치 가져오기
    Position currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // 현재 위치 업데이트
    setState(() {
      _currentLatLng =
          LatLng(currentPosition.latitude, currentPosition.longitude);
      _isLocationLoaded = true;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // 주소 검색 시 자동완성 결과 얻기
  void _searchLocation(String input) async {
    final suggestions = await _placesService.getAutocomplete(input);

    setState(() {
      _addressSuggestions = suggestions;
    });
  }

  // 자동완성 리스트에서 선택된 주소로 지도 업데이트
  void _onAddressSelected(String address) async {
    final latLng = await _placesService.getLatLngFromAddress(address);

    if (latLng != null) {
      setState(() {
        _searchedLocation = LatLng(latLng['lat']!, latLng['lng']!);
        mapController
            .animateCamera(CameraUpdate.newLatLngZoom(_searchedLocation!, 14));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Places API with Google Maps'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _searchLocation,
              decoration: InputDecoration(
                hintText: 'Search for a location',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _searchLocation(_searchController.text);
                  },
                ),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          if (_addressSuggestions.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _addressSuggestions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_addressSuggestions[index]),
                    onTap: () {
                      _onAddressSelected(_addressSuggestions[index]);
                    },
                  );
                },
              ),
            ),
          Expanded(
            child: _isLocationLoaded
                ? GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _currentLatLng,
                      zoom: 11.0,
                    ),
                    markers: {
                      if (_searchedLocation != null)
                        Marker(
                          markerId: const MarkerId('searchedLocation'),
                          position: _searchedLocation!,
                          infoWindow:
                              const InfoWindow(title: 'Searched Location'),
                        ),
                    },
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          ),
        ],
      ),
    );
  }
}
