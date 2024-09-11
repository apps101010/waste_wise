import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:waste_wise/util/custom_app_bar.dart';

class NearestFoodBin extends StatefulWidget {
  const NearestFoodBin({super.key});

  @override
  State<NearestFoodBin> createState() => _NearestFoodBinState();
}

class _NearestFoodBinState extends State<NearestFoodBin> {
  Position? _currentPosition;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
  }

  @override
  Widget build(BuildContext context) {
    User? currentuser = _auth.currentUser;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Waste Wise'),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('data').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final dataDocs = snapshot.data?.docs;

          if (_currentPosition == null || dataDocs == null) {
            return Center(child: CircularProgressIndicator());
          }

          // Calculate distances and sort bins
          List<Map<String, dynamic>> binsWithDistances = dataDocs.map((doc) {
            double? latitude = double.parse(doc['latitude']);
            double? longitude = double.parse(doc['longitude']);

            double distanceInKm = 0.0;
            if (latitude != null && longitude != null) {
              distanceInKm = Geolocator.distanceBetween(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
                latitude,
                longitude,
              ) / 1000; // Convert meters to kilometers
            }

            return {
              'doc': doc,
              'distance': distanceInKm,
            };
          }).toList();

          binsWithDistances.sort((a, b) => a['distance'].compareTo(b['distance']));

          return ListView.builder(
            itemCount: binsWithDistances.length,
            itemBuilder: (context, index) {
              var item = binsWithDistances[index];
              var doc = item['doc'];
              double distanceInKm = item['distance'];

              return Container(
                margin: const EdgeInsets.all(3.0),
                color: Colors.grey[200],
                child: ListTile(
                  title: Text(doc['binname']),
                  subtitle: Text('Quantity: ${doc['binquantity']}\nDistance: ${distanceInKm.toStringAsFixed(2)} km'),
                  onTap: (){
                    // Get.to(() => const PickLocation(), arguments: {'latitude':doc['latitude'],'longitude':doc['longitude'],'status':false});
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red,),
                        onPressed: (){},
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }


  Future<void> requestLocationPermission() async {
    var status = await Permission.location.status;

    if (status.isDenied) {
      // Request location permission
      if (await Permission.location.request().isGranted) {
        // Permission granted
        print('Permission granted');
        await _getCurrentLocation();
      } else {
        // Permission denied, handle accordingly
        print("Location permission denied");
      }
    } else if (status.isGranted) {
      // Permission already granted
      print('Permission already granted');
      await _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });
  }

}
