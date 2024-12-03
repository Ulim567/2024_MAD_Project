import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:moblie_app_project/provider/defaultState.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text_plus/auto_size_text_plus.dart';

class ConfirmRouteWidget extends StatefulWidget {
  const ConfirmRouteWidget({super.key});

  @override
  State<ConfirmRouteWidget> createState() => _ConfirmRouteWidgetState();
}

class _ConfirmRouteWidgetState extends State<ConfirmRouteWidget> {
  @override
  Widget build(BuildContext context) {
    // GoogleMapController를 관리할 변수
    final Completer<GoogleMapController> _controller = Completer();
    var defaultState = context.watch<Defaultstate>();

    CameraPosition initialPosition = CameraPosition(
      target: LatLng(defaultState.latitude, defaultState.longitude),
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
              size: 30,
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    defaultState.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 24),
                  ),
                  AutoSizeText(
                    defaultState.address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            )
          ],
        ),
        const SizedBox(
          height: 15,
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
                position: LatLng(defaultState.latitude, defaultState.longitude),
                infoWindow: InfoWindow(title: defaultState.address),
              ),
            },
          ),
        ),
      ],
    );
  }
}
