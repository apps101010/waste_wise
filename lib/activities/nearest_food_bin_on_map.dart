import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NearestFoodBinOnMap extends StatefulWidget {
  const NearestFoodBinOnMap({super.key});

  @override
  State<NearestFoodBinOnMap> createState() => _NearestFoodBinOnMapState();
}

class _NearestFoodBinOnMapState extends State<NearestFoodBinOnMap> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  BitmapDescriptor? _customMarkerIcon;

  @override
  void initState() {
    super.initState();
    _setCustomMarkerIcon();
    _addInitialMarker();
    _loadDataFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Google Map")),
      body: GoogleMap(
        initialCameraPosition: _initialCameraPosition,
        markers: _markers,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
      ),
    );
  }

  // Initial camera position (you can change this to a specific location)
  static const LatLng _initialPosition = LatLng(31.4625, 74.2465); // Example: Islamabad

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: _initialPosition,
    zoom: 14,
  );

  // Load a custom marker icon
  Future<void> _setCustomMarkerIcon() async {
    _customMarkerIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(48, 48)),
      'assets/images/marker.png',  // Your custom icon path in the assets folder
    );
  }


  // Load data from Firestore
  Future<void> _loadDataFromFirestore() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('data').get();

      if (snapshot.docs.isNotEmpty) {
        Set<Marker> markers = {};

        for (var doc in snapshot.docs) {
          // Extract data
          var data = doc.data() as Map<String, dynamic>;
          double latitude = double.parse(data['latitude']);
          double longitude = double.parse(data['longitude']);
          String binName = data['binname'];

          print(latitude);

          // Add marker with custom icon or default marker icon
          markers.add(
            Marker(
              markerId: MarkerId(doc.id),
              position: LatLng(latitude, longitude),
              icon: BitmapDescriptor.defaultMarker,
              infoWindow: InfoWindow(title: binName),
            ),
          );
        }

        // Update state with markers
        setState(() {
          _markers.addAll(markers);
        });
      }
    } catch (e) {
      print("Error retrieving data: $e");
    }
  }

  // Add a marker on the initial camera position
  void _addInitialMarker() {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('initialMarker'),
          position: _initialPosition,
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(title: 'Initial Position'),
        ),
      );
    });
  }
}
