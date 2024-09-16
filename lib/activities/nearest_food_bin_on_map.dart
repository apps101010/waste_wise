import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:waste_wise/util/custom_app_bar.dart';

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
  Position? _currentPosition;
  
  CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(0, 0),
    zoom: 14,
  );

  @override
  void initState() {
    super.initState();
    _setCustomMarkerIcon();
    _getCurrentLocation();
    _loadDataFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Waste Wise',),
      body: GoogleMap(
        initialCameraPosition: _initialCameraPosition,
        markers: _markers,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
      ),
    );
  }

  Future<void> _setCustomMarkerIcon() async {
    _customMarkerIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(48, 48)),
      'assets/images/marker.png',
    );
  }

  Future<void> _loadDataFromFirestore() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('data').get();

      if (snapshot.docs.isNotEmpty) {
        Set<Marker> markers = {};

        for (var doc in snapshot.docs) {
          var data = doc.data() as Map<String, dynamic>;
          double latitude = double.parse(data['latitude']);
          double longitude = double.parse(data['longitude']);
          String binName = data['binname'];

          markers.add(
            Marker(
              markerId: MarkerId(doc.id),
              position: LatLng(latitude, longitude),
              icon: _customMarkerIcon ?? BitmapDescriptor.defaultMarker,
              infoWindow: InfoWindow(title: binName),
            ),
          );
        }

        setState(() {
          _markers.addAll(markers);
        });
      }
    } catch (e) {
      print("Error retrieving data: $e");
    }
  }

  void _addInitialMarker() {
    if (_currentPosition != null) {
      setState(() {
        _markers.add(
          Marker(
            markerId: MarkerId('initialMarker'),
            position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            icon: BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(title: 'Current Position'),
          ),
        );
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
        _initialCameraPosition = CameraPosition(
          target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          zoom: 14,
        );
        _mapController.animateCamera(CameraUpdate.newCameraPosition(_initialCameraPosition));
        _addInitialMarker(); // Add the initial marker once the location is available
      });
    } catch (e) {
      print("Error retrieving current location: $e");
    }
  }
}
