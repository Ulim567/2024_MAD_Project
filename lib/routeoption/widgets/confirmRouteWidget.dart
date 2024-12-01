import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ConfirmRouteWidget extends StatefulWidget {
  final String address;
  final double latitude;
  final double longitude;

  const ConfirmRouteWidget({
    super.key,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<ConfirmRouteWidget> createState() => _ConfirmRouteWidgetState();
}

class _ConfirmRouteWidgetState extends State<ConfirmRouteWidget> {
  @override
  Widget build(BuildContext context) {
    // GoogleMapController를 관리할 변수
    final Completer<GoogleMapController> _controller = Completer();

    CameraPosition initialPosition = CameraPosition(
      target: LatLng(widget.latitude, widget.longitude),
      zoom: 17,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 10,
        ),
        const Text(
          "선택하신 도착지가\n맞는지 확인해주세요",
          style: TextStyle(fontSize: 24),
        ),
        const SizedBox(
          height: 35,
        ),
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: Colors.black54,
            ),
            Text(
              widget.address,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        // Google Maps 위젯
        SizedBox(
          height: 300,
          width: double.infinity,
          child: GoogleMap(
            initialCameraPosition: initialPosition,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            markers: {
              Marker(
                markerId: MarkerId('destination'),
                position: LatLng(widget.latitude, widget.longitude),
                infoWindow: InfoWindow(title: widget.address),
              ),
            },
          ),
        ),
      ],
    );
  }
}
