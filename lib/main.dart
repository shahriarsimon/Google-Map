import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location_package;
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GoogleMapPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GoogleMapPage extends StatefulWidget {
  @override
  _GoogleMapPageState createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  GoogleMapController? mapController;
  final location = location_package.Location();
  LatLng _currentPosition = LatLng(23.8103, 90.4125);

  @override
  void initState() {
    super.initState();
    getUserLocation();
  }

  Future<void> getUserLocation() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    location_package.PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == location_package.PermissionStatus.denied ||
        permissionGranted == location_package.PermissionStatus.deniedForever) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != location_package.PermissionStatus.granted) return;
    }

    LocationData userLocation = await location.getLocation();

    setState(() {
      _currentPosition =
          LatLng(userLocation.latitude!, userLocation.longitude!);
    });

    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_currentPosition, 16),
    );
  }

  Future<void> goToSearchedLocation(String address) async {
    if (address.isEmpty) return;
    var locations = await locationFromAddress(address);
    if (locations.isNotEmpty) {
      LatLng newPosition =
      LatLng(locations.first.latitude, locations.first.longitude);
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(newPosition, 16),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Google Map Example")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
            CameraPosition(target: _currentPosition, zoom: 14),
            onMapCreated: (controller) {
              mapController = controller;
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          Positioned(
            top: 15,
            left: 15,
            right: 15,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              color: Colors.white,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search place',
                  suffixIcon: Icon(Icons.search),
                ),
                onSubmitted: (value) async {
                  await goToSearchedLocation(value);
                },
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 15,
            child: FloatingActionButton(
              onPressed: () async {
                await getUserLocation();
              },
              child: Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
