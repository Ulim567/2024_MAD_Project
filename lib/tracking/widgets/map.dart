import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:moblie_app_project/api/tmap_directions_service.dart';
import 'package:moblie_app_project/provider/dbservice.dart';

class RouteMap extends StatefulWidget {
  final LatLng destination;
  final Function? onRouteLoaded;

  const RouteMap({
    super.key,
    required this.destination,
    this.onRouteLoaded,
  });

  @override
  State<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> {
  final DatabaseService _databaseService = DatabaseService();
  late GoogleMapController _mapController;
  LatLng _currentLatLng =
      const LatLng(36.0821603, 129.398434); // Default location Default location
  // LatLng _trackingLatLng = LatLng(36.0821603, 129.398434);
  bool _isLocationLoaded = false;
  bool _isTrackingEnabled = false; // Tracking state
  StreamSubscription<Position>? _positionStream;
  List<LatLng> _polylinePoints = [];
  final TmapDirectionsService _directionsService = TmapDirectionsService();
  final User? user = FirebaseAuth.instance.currentUser;
  Circle? _trackingCircle;
  @override
  void initState() {
    super.initState();
    _getLocation().then((_) {
      _getRoute();
      Future.delayed(Duration(seconds: 1), () {
        _startTracking();
      });
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel(); // Cancel position stream when widget is disposed
    super.dispose();
  }

  // Fetch route from current location to destination
  Future<void> _getRoute() async {
    final points = await _directionsService.getDirections(
      startLat: _currentLatLng.latitude,
      startLng: _currentLatLng.longitude,
      endLat: widget.destination.latitude,
      endLng: widget.destination.longitude,
    );

    if (points != null) {
      setState(() {
        _polylinePoints = points; // Update polyline points
      });

      _mapController.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            _currentLatLng.latitude < widget.destination.latitude
                ? _currentLatLng.latitude
                : widget.destination.latitude,
            _currentLatLng.longitude < widget.destination.longitude
                ? _currentLatLng.longitude
                : widget.destination.longitude,
          ),
          northeast: LatLng(
            _currentLatLng.latitude > widget.destination.latitude
                ? _currentLatLng.latitude
                : widget.destination.latitude,
            _currentLatLng.longitude > widget.destination.longitude
                ? _currentLatLng.longitude
                : widget.destination.longitude,
          ),
        ),
        100,
      ));

      if (widget.onRouteLoaded != null) {
        widget.onRouteLoaded!();
      }
    }
  }

  // Get the current location of the device
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
      // ignore: deprecated_member_use
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentLatLng =
          LatLng(currentPosition.latitude, currentPosition.longitude);
      // _trackingLatLng = _currentLatLng;
      _isLocationLoaded = true;
    });
    final String uid = user!.uid;
    await _databaseService.sendTrackingStartInfo(
        uid, _currentLatLng.latitude, _currentLatLng.longitude);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<bool> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("위치 권한이 필요합니다.")),
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("앱 설정에서 위치 권한을 활성화해주세요.")),
      );
      return false;
    }

    return true;
  }

  void _startTracking() async {
    if (_isTrackingEnabled) {
      // Stop tracking
      _positionStream?.cancel();
    } else {
      // Start tracking
      final permission = await _requestLocationPermission();
      if (!permission) return;

      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0, // Update only when moving
        ),
      ).listen((Position position) async {
        final newLatLng = LatLng(position.latitude, position.longitude);
        final currentTime = Timestamp.now(); // 현재 시간
        final String uid = user!.uid;
        // 새로운 위치 기록 생성
        Map<String, dynamic> newRecord = {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'time': currentTime,
        };

        // Firestore에 위치 기록 추가
        await _databaseService.addRecordToTrackingInfo(uid, newRecord);

        setState(() {
          // _trackingLatLng = newLatLng;
          // 트래킹용 빨간 원을 업데이트
          _trackingCircle = Circle(
            circleId: const CircleId('tracking'),
            center: newLatLng,
            radius: 1.0, // 원의 크기
            fillColor: Colors.red.withOpacity(0.5), // 빨간색
            strokeColor: Colors.red, // 빨간색 테두리
            strokeWidth: 2,
          );
        });

        _mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: newLatLng,
              zoom: 20.0,
              bearing: position.heading, // 사용자 방향
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
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
                          markerId: const MarkerId('currentLocation'),
                          position: _currentLatLng,
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueGreen),
                          infoWindow:
                              const InfoWindow(title: 'Current Location'),
                        ),
                        Marker(
                          markerId: const MarkerId('destinationLocation'),
                          position: widget.destination,
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
                      circles: _trackingCircle != null
                          ? {_trackingCircle!} // 트래킹 원이 있을 경우 추가
                          : {},
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}
