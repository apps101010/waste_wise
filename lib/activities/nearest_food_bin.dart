import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waste_wise/activities/show_map.dart';
import 'package:waste_wise/util/custom_app_bar.dart';
import 'package:waste_wise/util/custom_colors.dart';
import 'package:waste_wise/util/custom_snackbar.dart';
import 'package:waste_wise/util/progress_dialog.dart';

class NearestFoodBin extends StatefulWidget {
  const NearestFoodBin({super.key});

  @override
  State<NearestFoodBin> createState() => _NearestFoodBinState();
}

class _NearestFoodBinState extends State<NearestFoodBin> {
  Position? _currentPosition;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var _foodNameController = TextEditingController();
  var _foodQuantityController = TextEditingController();

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
            return const Center(child: CircularProgressIndicator());
          }

          final dataDocs = snapshot.data?.docs;

          if (_currentPosition == null || dataDocs == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if(dataDocs.isEmpty){
            return Center(child: Text('No Data Available'),);
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

              return InkWell(
                onTap: (){
                  if(doc['remainingbincapacity'] != 0){
                    showCustomDialog(doc['uniqueid'],doc['remainingbincapacity']);
                  }else{
                    CustomSnackbar.showSnackbar('OOPS!', 'The Bin is currently full. You can not add more food into it');
                  }

                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [CustomColors.mainButtonColor, CustomColors.mainColorLowShade], // Green gradient
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: Offset(0, 5), // Shadow position
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Bin Name
                            Text(
                              doc['binname'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Capacity Row with Icon
                            Row(
                              children: [
                                const Icon(Icons.storage, color: Colors.white70, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  'Capacity: ${doc['binquantity']} kg | Remaining: ${doc['remainingbincapacity']} kg',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16), // Spacing before button

                            // Button Positioned at the Bottom
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  Get.to(() => ShowOnMap(), arguments: {'currentlatitude': _currentPosition?.latitude,'currentlongitude': _currentPosition?.longitude,
                                    'endlatitude':doc['latitude'],'endlongitude': doc['longitude'], 'binname':doc['binname'],'distance':distanceInKm});
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  backgroundColor: Colors.white, // White button for contrast
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12), // Rounded button corners
                                  ),
                                ),
                                child: const Text(
                                  'Check On Map',
                                  style: TextStyle(
                                    color: Color(0xFF43a047), // Matching button text color
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Distance at Top Right Corner
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: CustomColors.mainButtonColor,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${distanceInKm.toStringAsFixed(2)} km',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: CustomColors.mainButtonColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
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
      if (await Permission.location.request().isGranted) {
        print('Permission granted');
        await _getCurrentLocation();
      } else {
        print("Location permission denied");
      }
    } else if (status.isGranted) {
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

  void showCustomDialog(String binId,int remaining) {
    double screenWidth = MediaQuery.of(context).size.width;

    Get.defaultDialog(
      title: 'Add Food',
      titleStyle: const TextStyle(color: Colors.white),
      titlePadding: const EdgeInsets.all(10),
      contentPadding: const EdgeInsets.all(10),
      radius: 15,
      backgroundColor: CustomColors.mainButtonColor,
      content: Container(
        width: screenWidth * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(6.0),
              color: Colors.white,
              child: TextField(
                controller: _foodNameController,
                decoration: const InputDecoration(
                  labelText: 'Food Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(6.0),
              color: Colors.white,
              child:  TextField(
                controller: _foodQuantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Food Quantity in KG',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if(_validation()){
                  if(remaining >= int.parse(_foodQuantityController.text)){
                    _saveDataToFirestore(binId,remaining);
                  }else{
                    CustomSnackbar.showSnackbar("OOPS!", "The food quantity should not be greater than $remaining kg");
                  }

                }
              },
              child: Text('Add Food Now',style: TextStyle(color: CustomColors.mainButtonColor),),
            ),
          ],
        ),
      ),
    );
  }

  bool _validation(){
    if(_foodNameController.text.trim().isEmpty){
      CustomSnackbar.showSnackbar('OOPS!', 'Enter food name');
      return false;
    }else if(_foodQuantityController.text.trim().isEmpty){
      CustomSnackbar.showSnackbar('OOPS!', 'Enter food quantity');
      return false;
    }else{
      return true;
    }
  }

  void _saveDataToFirestore(String binId, int remainingCapacity) async{
    int finalRemaining = remainingCapacity - int.parse(_foodQuantityController.text);
    CustomProgressDialog.showProgressDialog("Please Wait", "Inserting your data");
    DateTime dateTime = DateTime.now();
    try{

      User? user = _auth.currentUser;

      if(user != null){
        String uid = user.uid;
        String docId = _firestore.collection("foodbins").doc().id;

        await _firestore.collection('moderator').doc(docId).set({
          'userid': uid,
          'foodname': _foodNameController.text.toString().trim(),
          'foodquantity': _foodQuantityController.text.toString(),
          'date': formatDateTime(dateTime),
          'binid': binId,
          'uniqueid': docId,
        });
        await _firestore.collection('data').doc(binId).update({
          'remainingbincapacity': finalRemaining,
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? goalId = prefs.getString('goalid');

        // new code for goals
        _firestore.collection('goals').doc(goalId).get().then((docSnapshot){

          if(docSnapshot.exists){
            var goalData = docSnapshot.data()!;
            DateTime startDate = DateTime.parse(goalData['startDate']);
            DateTime endDate = DateTime.parse(goalData['endDate']);
            List<bool> foodAddedPerDay = List.from(goalData['foodAddedPerDay']);

            int todayIndex = DateTime.now().difference(startDate).inDays;

            if (todayIndex >= 0 && todayIndex < foodAddedPerDay.length) {
              setState(() {
                foodAddedPerDay[todayIndex] = true;
              });

              // Update the goal document in Firestore
              _firestore.collection('goals').doc(goalId).update({
                'foodAddedPerDay': foodAddedPerDay,
              }).then((_) {
                print('Food added and goal updated successfully');
              }).catchError((error) {
                print('Failed to update goal: $error');
              });

            }
          }
        });

        // goals code end

        Get.back();
        Get.back();
        CustomSnackbar.showSnackbar('Success', "Food Added Successfully");
        _foodNameController.text = "";
        _foodQuantityController.text = "";
      }

    }catch (e) {
      Get.back();
      print(e);
      CustomSnackbar.showSnackbar("OOPS!", "Internal server error");
    }
  }

  String formatDateTime(DateTime dateTime) {
    String period = dateTime.hour >= 12 ? 'PM' : 'AM';
    String hour = dateTime.hour % 12 == 0 ? '12' : (dateTime.hour % 12).toString().padLeft(2, '0');
    return '${dateTime.day}-${dateTime.month}-${dateTime.year} $hour:${dateTime.minute.toString().padLeft(2, '0')} $period';
  }

}
