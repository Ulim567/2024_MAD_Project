import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'google_places_service.dart';

class GoogleTempPage extends StatefulWidget {
  const GoogleTempPage({super.key});

  @override
  State<GoogleTempPage> createState() => _GoogleTempPageState();
}

class _GoogleTempPageState extends State<GoogleTempPage> {
  late GoogleMapController mapController;
  LatLng _currentLatLng = const LatLng(36.0821603, 129.398434); // 기본 위치
  TextEditingController _searchController = TextEditingController();
  List<String> _addressSuggestions = [];
  LatLng? _searchedLocation;

  final GooglePlacesService _placesService = GooglePlacesService();

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // 주소 검색 시 자동완성 결과 얻기
  void _searchLocation(String input) async {
    final suggestions = await _placesService.getAutocomplete(input);

    setState(() {
      _addressSuggestions = suggestions;
    });
  }

  // 자동완성 리스트에서 선택된 주소로 지도 업데이트
  void _onAddressSelected(String address) async {
    final latLng = await _placesService.getLatLngFromAddress(address);

    if (latLng != null) {
      setState(() {
        _searchedLocation = LatLng(latLng['lat']!, latLng['lng']!);
        mapController
            .animateCamera(CameraUpdate.newLatLngZoom(_searchedLocation!, 14));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Places API with Google Maps'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _searchLocation,
              decoration: InputDecoration(
                hintText: 'Search for a location',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _searchLocation(_searchController.text);
                  },
                ),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          if (_addressSuggestions.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _addressSuggestions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_addressSuggestions[index]),
                    onTap: () {
                      _onAddressSelected(_addressSuggestions[index]);
                    },
                  );
                },
              ),
            ),
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _currentLatLng,
                zoom: 11.0,
              ),
              markers: {
                if (_searchedLocation != null)
                  Marker(
                    markerId: const MarkerId('searchedLocation'),
                    position: _searchedLocation!,
                    infoWindow: const InfoWindow(title: 'Searched Location'),
                  ),
              },
            ),
          ),
        ],
      ),
    );
  }
}
