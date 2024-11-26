import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart'; // 지오코딩을 위한 패키지

class GoogleTempPage extends StatefulWidget {
  const GoogleTempPage({super.key});

  @override
  State<GoogleTempPage> createState() => _GoogleTempPageState();
}

class _GoogleTempPageState extends State<GoogleTempPage> {
  late GoogleMapController mapController;
  LatLng _currentLatLng = const LatLng(36.0821603, 129.398434); // 기본 위치
  bool _isLocationLoaded = false; // 현재 위치 로드 상태 확인
  TextEditingController _searchController =
      TextEditingController(); // 검색 필드 컨트롤러
  LatLng? _searchedLocation; // 검색된 위치 저장

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("위치 권한이 필요합니다.")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("앱 설정에서 위치 권한을 활성화해주세요."),
        ),
      );
      return;
    }

    Position currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentLatLng =
          LatLng(currentPosition.latitude, currentPosition.longitude);
      _isLocationLoaded = true;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _searchLocation(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);

      if (locations.isNotEmpty) {
        Location firstLocation = locations.first;
        setState(() {
          _searchedLocation =
              LatLng(firstLocation.latitude, firstLocation.longitude);
          mapController.animateCamera(
            CameraUpdate.newLatLngZoom(_searchedLocation!, 14),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("주소를 찾을 수 없습니다.")),
        );
      }
    } catch (e) {
      print("Geocoding Error: $e"); // 디버그 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("주소 검색 중 오류 발생: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Maps Sample App'),
          backgroundColor: Colors.green[700],
        ),
        body: Column(
          children: [
            // 검색 입력 필드
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "목적지 주소를 입력하세요",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            _searchLocation(_searchController.text);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
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
                        Marker(
                          markerId: const MarkerId("currentLocation"),
                          position: _currentLatLng,
                          infoWindow: const InfoWindow(title: "현재 위치"),
                        ),
                        if (_searchedLocation != null)
                          Marker(
                            markerId: const MarkerId("searchedLocation"),
                            position: _searchedLocation!,
                            infoWindow: const InfoWindow(title: "검색 위치"),
                          ),
                      },
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
