import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:moblie_app_project/api/tmap_directions_service.dart';
import 'package:moblie_app_project/provider/dbservice.dart';

class FriendRouteMap extends StatefulWidget {
  final String friendUid; // 친구의 UID를 추가로 받도록 변경
  final Function? onRouteLoaded;

  const FriendRouteMap({
    super.key,
    required this.friendUid, // 친구 UID를 필수로 받도록 추가
    this.onRouteLoaded,
  });

  @override
  State<FriendRouteMap> createState() => _FriendRouteMapState();
}

class _FriendRouteMapState extends State<FriendRouteMap> {
  final DatabaseService _databaseService = DatabaseService();
  late GoogleMapController _mapController;
  StreamSubscription<Position>? _positionStream;
  List<LatLng> _polylinePoints = [];
  final TmapDirectionsService _directionsService = TmapDirectionsService();
  final User? user = FirebaseAuth.instance.currentUser;
  LatLng? _friendDestLatLng; // 친구의 현재 위치를 저장할 변수 추가
  LatLng? _friendStartLatLng; // 친구의 현재 위치를 저장할 변수 추가
  LatLng? _trackingLatLng; // 친구의 가장 최근 위치를 저장할 변수

  @override
  void initState() {
    super.initState();
    _trackFriendLocation();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  // 친구의 위치를 실시간으로 추적하는 스트림 함수 호출
  void _trackFriendLocation() {
    _databaseService.trackFriendTrackingInfo(widget.friendUid).listen(
        (trackingInfo) {
      print('Tracking Info: $trackingInfo'); // trackingInfo 데이터 확인
      if (trackingInfo != null) {
        final destinationInfo =
            trackingInfo['destination'] as Map<String, dynamic>?;
        final startInfo = trackingInfo['start'] as Map<String, dynamic>?;
        final records = trackingInfo['records'] as List<dynamic>?;

        print('Destination Info: $destinationInfo'); // Destination 로그 추가
        print('Start Info: $startInfo'); // Start 로그 추가
        print('Records: $records'); // Records 로그 추가

        if (destinationInfo != null && startInfo != null && records != null) {
          records.sort((a, b) {
            final timeA = a['time'] as Timestamp?;
            final timeB = b['time'] as Timestamp?;
            if (timeA == null || timeB == null) return 0;
            return timeB.compareTo(timeA); // 내림차순 정렬
          });

          final latestRecord = records.isNotEmpty ? records.first : null;

          if (latestRecord != null) {
            final latitude = latestRecord['latitude'] as double?;
            final longitude = latestRecord['longitude'] as double?;
            print('Latest Record: $latestRecord'); // 최신 기록 로그

            if (latitude != null && longitude != null) {
              setState(() {
                _trackingLatLng = LatLng(latitude, longitude);
                print(
                    'Tracking LatLng updated: $_trackingLatLng'); // 위치 업데이트 로그
              });
            }
          }

          if (destinationInfo['latitude'] != null &&
              destinationInfo['longitude'] != null) {
            setState(() {
              _friendDestLatLng = LatLng(
                  destinationInfo['latitude'], destinationInfo['longitude']);
              print(
                  'Destination LatLng updated: $_friendDestLatLng'); // 목적지 업데이트 로그
            });
          }

          if (startInfo['latitude'] != null && startInfo['longitude'] != null) {
            setState(() {
              _friendStartLatLng =
                  LatLng(startInfo['latitude'], startInfo['longitude']);
              print(
                  'Start LatLng updated: $_friendStartLatLng'); // 시작 위치 업데이트 로그
            });
          }
          if (_friendStartLatLng != null && _friendDestLatLng != null) {
            _getRoute();
          }
        }
      }
    }, onError: (error) {
      print('Stream Error: $error'); // 에러 로그
    });
  }

  Future<void> _getRoute() async {
    print('Getting route...'); // 경로 가져오기 시작 로그

    if (_friendStartLatLng == null || _friendDestLatLng == null) {
      print('Start or Destination LatLng is null.');
      return;
    }

    print(
        'Requesting directions from Start: $_friendStartLatLng to Destination: $_friendDestLatLng');

    try {
      final points = await _directionsService.getDirections(
        startLat: _friendStartLatLng!.latitude,
        startLng: _friendStartLatLng!.longitude,
        endLat: _friendDestLatLng!.latitude,
        endLng: _friendDestLatLng!.longitude,
      );

      if (points == null || points.isEmpty) {
        print('No route points received.');
        return;
      }

      print('Route points received: ${points.length} points.');

      setState(() {
        _polylinePoints = points;
      });

      print('Polyline updated: $_polylinePoints');

      // 지도 카메라 위치 업데이트
      _mapController.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            _friendStartLatLng!.latitude < _friendDestLatLng!.latitude
                ? _friendStartLatLng!.latitude
                : _friendDestLatLng!.latitude,
            _friendStartLatLng!.longitude < _friendDestLatLng!.longitude
                ? _friendStartLatLng!.longitude
                : _friendDestLatLng!.longitude,
          ),
          northeast: LatLng(
            _friendStartLatLng!.latitude > _friendDestLatLng!.latitude
                ? _friendStartLatLng!.latitude
                : _friendDestLatLng!.latitude,
            _friendStartLatLng!.longitude > _friendDestLatLng!.longitude
                ? _friendStartLatLng!.longitude
                : _friendDestLatLng!.longitude,
          ),
        ),
        100,
      ));

      if (widget.onRouteLoaded != null) {
        widget.onRouteLoaded!();
      }
    } catch (e) {
      print('Error while fetching route: $e'); // 에러 출력
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    final bool shouldLoadMap =
        _trackingLatLng != null && _polylinePoints.isNotEmpty;
    return Stack(
      children: [
        if (!shouldLoadMap)
          Center(
            child: CircularProgressIndicator(), // 로딩 화면 표시
          )
        else
          Column(
            children: [
              Expanded(
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _trackingLatLng!, // trackingLatLng는 null이 아님이 보장됨
                    zoom: 18.0,
                  ),
                  markers: {
                    if (_friendStartLatLng != null)
                      Marker(
                        markerId: const MarkerId('currentLocation'),
                        position: _friendStartLatLng!,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueGreen),
                        infoWindow: const InfoWindow(title: 'Current Location'),
                      ),
                    if (_friendDestLatLng != null)
                      Marker(
                        markerId: const MarkerId('destinationLocation'),
                        position: _friendDestLatLng!,
                        infoWindow:
                            const InfoWindow(title: 'Destination Location'),
                      ),
                  },
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId('route'),
                      color: Colors.blue,
                      width: 5,
                      points: _polylinePoints,
                    ),
                  },
                  circles: {
                    if (_trackingLatLng != null)
                      Circle(
                        circleId: const CircleId('trackingLocation'),
                        center: _trackingLatLng!,
                        radius: 3,
                        fillColor: Colors.red.withOpacity(0.5),
                        strokeColor: Colors.red,
                        strokeWidth: 2,
                      ),
                  },
                ),
              ),
            ],
          ),
      ],
    );
  }
}
