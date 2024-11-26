import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _startPosition;
  LatLng? _endPosition;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _startPosition = LatLng(position.latitude, position.longitude);
      _markers.add(Marker(
        markerId: MarkerId("start"),
        position: _startPosition!,
        infoWindow: InfoWindow(title: "출발지"),
      ));
    });
  }

  void _setDestination(LatLng destination) {
    setState(() {
      _endPosition = destination;
      _markers.add(Marker(
        markerId: MarkerId("end"),
        position: _endPosition!,
        infoWindow: InfoWindow(title: "도착지"),
      ));
    });
  }

  Future<void> _getDirections() async {
    if (_startPosition == null || _endPosition == null) return;

    final String apiUrl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${_startPosition!.latitude},${_startPosition!.longitude}&destination=${_endPosition!.latitude},${_endPosition!.longitude}&key=AIzaSyB0NDreHRzw7y2AOGBy-OOt2eGPEyieUOg";

    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final route = data['routes'][0]['overview_polyline']['points'];
      _drawRoute(route);
    } else {
      throw Exception("Failed to fetch directions");
    }
  }

  void _drawRoute(String encodedPolyline) {
    List<LatLng> points = _decodePolyline(encodedPolyline);
    setState(() {
      _polylines.add(Polyline(
        polylineId: PolylineId("route"),
        points: points,
        color: Colors.blue,
        width: 5,
      ));
    });
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return polyline;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Google Maps 길찾기"),
      ),
      body: _startPosition == null
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _startPosition!,
                    zoom: 14.0,
                  ),
                  markers: _markers,
                  polylines: _polylines,
                  onMapCreated: (controller) =>
                      _controller.complete(controller),
                  onTap: _setDestination,
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: ElevatedButton(
                    onPressed: _getDirections,
                    child: Text("길 찾기"),
                  ),
                ),
              ],
            ),
    );
  }
}
