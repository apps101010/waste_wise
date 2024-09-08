import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:waste_wise/util/custom_app_bar.dart';
import 'package:waste_wise/util/custom_colors.dart';
import 'package:waste_wise/util/custom_snackbar.dart';

class PickLocation extends StatefulWidget {
  const PickLocation({super.key});

  @override
  State<PickLocation> createState() => _PickLocationState();
}

class _PickLocationState extends State<PickLocation> {
  final Map<String,dynamic> argumentData = Get.arguments;
  GoogleMapController? _mapController;
  LatLng? _pickedLocation;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Pick Location',),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(double.parse(argumentData['latitude']), double.parse(argumentData['longitude'])), // Default location (Islamabad, Pakistan)
                  zoom: 14,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                  setState(() {
                    _pickedLocation = LatLng(double.parse(argumentData['latitude']), double.parse(argumentData['longitude']));
                  });
                },
                onTap: (position) {
                  setState(() {
                    _pickedLocation = position;
                  });
                },
                markers: _pickedLocation != null
                    ? {
                  Marker(
                    markerId: MarkerId('picked-location'),
                    position: _pickedLocation!,
                  ),
                }
                    : {},
              ),
            ),
            Visibility(
              visible: argumentData['status'],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColors.mainButtonColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (_pickedLocation != null) {
                      Navigator.pop(context, _pickedLocation);
                    } else {
                      CustomSnackbar.showSnackbar('OOPS!', "Please pick a location by tapping on the map.");
                    }
                  },
                  child: const Text('Proceed Now'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
