import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:waste_wise/util/custom_app_bar.dart';

class ShowOnMap extends StatefulWidget {
  const ShowOnMap({super.key});

  @override
  State<ShowOnMap> createState() => _ShowOnMapState();
}

class _ShowOnMapState extends State<ShowOnMap> {
  final Map<String, dynamic> _argumentsData = Get.arguments;
  GoogleMapController? mapController;

  LatLng? _currentLocation;
  LatLng? _binLocation;

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  double _distanceInMeters = 0.0;

  @override
  void initState() {
    super.initState();
    _currentLocation = LatLng(_argumentsData['currentlatitude'], _argumentsData['currentlongitude']);
    _binLocation = LatLng(double.parse(_argumentsData['endlatitude']), double.parse(_argumentsData['endlongitude']));
    _setMarkersAndPolyline();
    _calculateDistance();
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Waste Wise'),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLocation!,
              zoom: 14.0,
            ),
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(top: 20.0),
              color: Colors.white,
              child: Text(
                "Distance: ${_argumentsData['distance'].toStringAsFixed(2)} km",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _setMarkersAndPolyline() {
    _markers.add(Marker(
      markerId: const MarkerId("start"),
      position: _currentLocation!,
      infoWindow: const InfoWindow(title: "Current Location"),
    ));
    _markers.add(Marker(
      markerId: const MarkerId("end"),
      position: _binLocation!,
      infoWindow: InfoWindow(title: _argumentsData['binname']),
    ));

    _polylines.add(Polyline(
      polylineId: const PolylineId("line"),
      visible: true,
      points: [_currentLocation!, _binLocation!],
      width: 5,
      color: Colors.blue,
    ));
  }

  void _calculateDistance() async {
    double distanceInMeters = Geolocator.distanceBetween(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      _binLocation!.latitude,
      _binLocation!.longitude,
    );

    setState(() {
      _distanceInMeters = distanceInMeters;
    });
  }
}
