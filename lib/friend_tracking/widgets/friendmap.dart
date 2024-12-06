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
    _getRoute();
    _trackFriendLocation();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  // 친구의 위치를 실시간으로 추적하는 스트림 함수 호출
  void _trackFriendLocation() {
    _databaseService
        .trackFriendTrackingInfo(widget.friendUid)
        .listen((trackingInfo) {
      if (trackingInfo != null) {
        final destinationInfo =
            trackingInfo['destination'] as Map<String, dynamic>?;
        final startInfo = trackingInfo['start'] as Map<String, dynamic>?;
        final records = trackingInfo['records'] as List<dynamic>?;

        if (destinationInfo != null && startInfo != null && records != null) {
          // records 배열을 time을 기준으로 내림차순으로 정렬
          records.sort((a, b) {
            final timeA = a['time'] as Timestamp?;
            final timeB = b['time'] as Timestamp?;
            if (timeA == null || timeB == null) return 0;
            return timeB.compareTo(timeA); // 내림차순 정렬
          });

          // 가장 최근의 records 데이터를 가져오기
          final latestRecord = records.isNotEmpty ? records.first : null;

          if (latestRecord != null) {
            final latitude = latestRecord['latitude'] as double?;
            final longitude = latestRecord['longitude'] as double?;

            if (latitude != null && longitude != null) {
              setState(() {
                _trackingLatLng = LatLng(latitude, longitude); // 최신 좌표 저장
              });
            }
          }

          // destination과 start 위치 처리
          if (destinationInfo['latitude'] != null &&
              destinationInfo['longitude'] != null) {
            setState(() {
              _friendDestLatLng = LatLng(
                  destinationInfo['latitude'], destinationInfo['longitude']);
            });
          }

          if (startInfo['latitude'] != null && startInfo['longitude'] != null) {
            setState(() {
              _friendStartLatLng =
                  LatLng(startInfo['latitude'], startInfo['longitude']);
            });
          }
        }
      }
    });
  }

  // 경로를 가져오는 함수
  Future<void> _getRoute() async {
    if (_friendStartLatLng != null && _friendDestLatLng != null) {
      final points = await _directionsService.getDirections(
        startLat: _friendStartLatLng!.latitude,
        startLng: _friendStartLatLng!.longitude,
        endLat: _friendDestLatLng!.latitude,
        endLng: _friendDestLatLng!.longitude,
      );

      if (points != null) {
        setState(() {
          _polylinePoints = points;
        });

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
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _trackingLatLng ?? const LatLng(0, 0), // 기본값 제공
                  zoom: 11.0,
                ),
                markers: {
                  if (_friendStartLatLng != null) // null 체크 추가
                    Marker(
                      markerId: const MarkerId('currentLocation'),
                      position: _friendStartLatLng!,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueGreen),
                      infoWindow: const InfoWindow(title: 'Current Location'),
                    ),
                  if (_friendDestLatLng != null) // null 체크 추가
                    Marker(
                      markerId: const MarkerId('destinationLocation'),
                      position: _friendDestLatLng!,
                      infoWindow:
                          const InfoWindow(title: 'Destination Location'),
                    ),
                },
                polylines: {
                  if (_polylinePoints.isNotEmpty)
                    Polyline(
                      polylineId: const PolylineId('route'),
                      color: Colors.blue,
                      width: 5,
                      points: _polylinePoints,
                    ),
                },
                circles: {
                  if (_trackingLatLng != null) // null 체크 추가
                    Circle(
                      circleId: const CircleId('trackingLocation'),
                      center: _trackingLatLng!,
                      radius: 10,
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
