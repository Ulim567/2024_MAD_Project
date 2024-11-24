import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleTempPage extends StatefulWidget {
  const GoogleTempPage({super.key});

  @override
  State<GoogleTempPage> createState() => _GoogleTempPageState();
}

class _GoogleTempPageState extends State<GoogleTempPage> {
  late GoogleMapController mapController;
  LatLng _currentLatLng = const LatLng(36.0821603, 129.398434); // 기본 위치
  bool _isLocationLoaded = false; // 현재 위치 로드 상태 확인

  @override
  void initState() {
    super.initState();
    _getLocation();
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Maps Sample App'),
          backgroundColor: Colors.green[700],
        ),
        body: _isLocationLoaded
            ? GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _currentLatLng,
                  zoom: 11.0,
                ),
              )
            : const Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}
