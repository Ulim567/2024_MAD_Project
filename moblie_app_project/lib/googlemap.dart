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
  LatLng _currentLatLng = const LatLng(36.0821603, 129.398434);
  Position? _currentPosition;

  @override
  void initState() {
    _getLocation();
    super.initState();
  }

  _getLocation() async {
    var locationPermissions = await Geolocator.checkPermission();
    if (locationPermissions.name != LocationPermission.denied ||
        locationPermissions.name != LocationPermission.deniedForever) {
      _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _currentLatLng =
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
      setState(() {});
    } else {
      await Geolocator.requestPermission();
    }
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
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _currentLatLng,
            zoom: 11.0,
          ),
        ),
      ),
    );
  }
}
