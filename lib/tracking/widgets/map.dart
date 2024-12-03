import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:moblie_app_project/api/tmap_directions_service.dart';

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
  late GoogleMapController _mapController;
  LatLng _currentLatLng =
      const LatLng(36.0821603, 129.398434); // Default location
  bool _isLocationLoaded = false;
  List<LatLng> _polylinePoints = [];
  final TmapDirectionsService _directionsService = TmapDirectionsService();

  @override
  void initState() {
    super.initState();
    _getLocation().then((_) {
      _getRoute();
    });
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
      _isLocationLoaded = true;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                      infoWindow: const InfoWindow(title: 'Current Location'),
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
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      ],
    );
  }
}
