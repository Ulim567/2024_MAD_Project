// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart'; // geolocator 임포트
// import 'package:moblie_app_project/tmap_directions_service.dart'; // TmapDirectionsService 임포트
// import 'google_places_service.dart';

// class GoogleTempPage extends StatefulWidget {
//   const GoogleTempPage({super.key});

//   @override
//   State<GoogleTempPage> createState() => _GoogleTempPageState();
// }

// class _GoogleTempPageState extends State<GoogleTempPage> {
//   late GoogleMapController mapController;
//   LatLng _currentLatLng = const LatLng(36.0821603, 129.398434); // 기본 위치
//   TextEditingController _searchController = TextEditingController();
//   List<String> _addressSuggestions = [];
//   LatLng? _searchedLocation;
//   bool _isLocationLoaded = true;

//   final GooglePlacesService _placesService = GooglePlacesService();
//   List<LatLng> _polylinePoints = [];
//   final TmapDirectionsService _directionsService =
//       TmapDirectionsService(); // TmapDirectionsService 사용

//   @override
//   void initState() {
//     super.initState();
//     _getLocation();
//   }

//   Future<void> _getRoute() async {
//     if (_searchedLocation == null) return;

//     // TmapDirectionsService를 사용하여 경로를 가져옵니다.
//     final points = await _directionsService.getDirections(
//       startLat: _currentLatLng.latitude,
//       startLng: _currentLatLng.longitude,
//       endLat: _searchedLocation!.latitude,
//       endLng: _searchedLocation!.longitude,
//     );

//     if (points != null) {
//       setState(() {
//         _polylinePoints = points; // 경로 정보 업데이트
//       });
//     }
//   }

//   Future<void> _getLocation() async {
//     LocationPermission permission = await Geolocator.checkPermission();

//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("위치 권한이 필요합니다.")),
//         );
//         return;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("앱 설정에서 위치 권한을 활성화해주세요."),
//         ),
//       );
//       return;
//     }

//     Position currentPosition = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );

//     setState(() {
//       _currentLatLng =
//           LatLng(currentPosition.latitude, currentPosition.longitude);
//       _isLocationLoaded = true;
//     });
//   }

//   void _onMapCreated(GoogleMapController controller) {
//     mapController = controller;
//   }

//   void _searchLocation(String input) async {
//     final suggestions = await _placesService.getAutocomplete(input);

//     setState(() {
//       _addressSuggestions = suggestions;
//     });
//   }

//   void _onAddressSelected(String address) async {
//     final latLng = await _placesService.getLatLngFromAddress(address);

//     if (latLng != null) {
//       setState(() {
//         _searchedLocation = LatLng(latLng['lat']!, latLng['lng']!);
//         mapController
//             .animateCamera(CameraUpdate.newLatLngZoom(_searchedLocation!, 14));
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Google Places API with Google Maps'),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: _searchController,
//               onChanged: _searchLocation,
//               decoration: InputDecoration(
//                 hintText: 'Search for a location',
//                 suffixIcon: IconButton(
//                   icon: const Icon(Icons.search),
//                   onPressed: () {
//                     _searchLocation(_searchController.text);
//                   },
//                 ),
//                 border: const OutlineInputBorder(),
//               ),
//             ),
//           ),
//           if (_addressSuggestions.isNotEmpty)
//             Expanded(
//               child: ListView.builder(
//                 itemCount: _addressSuggestions.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     title: Text(_addressSuggestions[index]),
//                     onTap: () {
//                       _onAddressSelected(_addressSuggestions[index]);
//                     },
//                   );
//                 },
//               ),
//             ),
//           Expanded(
//             child: _isLocationLoaded
//                 ? GoogleMap(
//                     onMapCreated: _onMapCreated,
//                     initialCameraPosition: CameraPosition(
//                       target: _currentLatLng,
//                       zoom: 11.0,
//                     ),
//                     markers: {
//                       Marker(
//                         markerId: const MarkerId('initialLocation'),
//                         position: _currentLatLng, // 초기 위치
//                         icon: BitmapDescriptor.defaultMarkerWithHue(
//                             BitmapDescriptor.hueGreen),
//                         infoWindow: const InfoWindow(title: 'Initial Location'),
//                       ),
//                       if (_searchedLocation != null)
//                         Marker(
//                           markerId: const MarkerId('searchedLocation'),
//                           position: _searchedLocation!,
//                           infoWindow:
//                               const InfoWindow(title: 'Searched Location'),
//                         ),
//                     },
//                     polylines: {
//                       if (_polylinePoints.isNotEmpty)
//                         Polyline(
//                           polylineId: const PolylineId('route'),
//                           color: Colors.blue,
//                           width: 5,
//                           points: _polylinePoints,
//                         ),
//                     },
//                   )
//                 : const Center(
//                     child: CircularProgressIndicator(),
//                   ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _searchedLocation != null ? _getRoute : null,
//         backgroundColor: _searchedLocation != null ? Colors.blue : Colors.grey,
//         child: const Icon(Icons.directions),
//       ),
//     );
//   }
// }
