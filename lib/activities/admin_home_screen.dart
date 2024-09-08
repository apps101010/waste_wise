import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:waste_wise/activities/pick_location.dart';
import 'package:waste_wise/util/custom_app_bar.dart';
import 'package:waste_wise/util/custom_colors.dart';
import 'package:waste_wise/util/custom_snackbar.dart';
import 'package:waste_wise/util/progress_dialog.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  var binNameController = TextEditingController();
  var binQuantityControler = TextEditingController();
  var binLocationController = TextEditingController();
  var selectedLat = "";
  var selectedLng = "";

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
    return  Scaffold(
      appBar: const CustomAppBar(title: 'Waste Wise',),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('data')
            .where('userid', isEqualTo: currentuser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final dataDocs = snapshot.data?.docs;

          return ListView.builder(
            itemCount: dataDocs?.length ?? 0,
            itemBuilder: (context, index) {
              var doc = dataDocs![index];
              return Container(
                margin: const EdgeInsets.all(3.0),
                color: Colors.grey[200],
                child: ListTile(
                  title: Text(doc['binname']),
                  subtitle: Text('Quantity: ${doc['binquantity']}'
                  ),
                  onTap: (){
                    Get.to(() => const PickLocation(), arguments: {'latitude':doc['latitude'],'longitude':doc['longitude'],'status':false});
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent,),
                        onPressed: () {
                          updateBinDetailsDialog(doc['binname'], doc['binquantity'], doc['latitude'], doc['longitude'], doc['uniqueid']);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,color: Colors.red,),
                        onPressed: () => _deleteData(doc['uniqueid']),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: CustomColors.mainButtonColor,
    child: Icon(Icons.add,color: Colors.white,),
    elevation: 6.0,
    onPressed: () {
    showCustomDialog();
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
        print('permission granted');
      } else {
        // Permission denied, handle accordingly
        print("Location permission denied");
      }
    } else if (status.isGranted) {
      // Permission already granted
      print('permission already granted');
    }
  }

  void showCustomDialog() {
    double screenWidth = MediaQuery.of(context).size.width;

    Get.defaultDialog(
      title: 'Enter Bin Details',
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
                controller: binNameController,
                decoration: const InputDecoration(
                  labelText: 'Bin Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(6.0),
              color: Colors.white,
              child:  TextField(
                controller: binQuantityControler,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Bin Quantity in kg',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async{
              LatLng? selectedLocation =  await Get.to(() => const PickLocation(), arguments: {'latitude':'33.6995','longitude':'73.0363','status':true});
              if(selectedLocation != null){
                binLocationController.text = '${selectedLocation.latitude},${selectedLocation.longitude}';
                selectedLat = selectedLocation.latitude.toString();
                selectedLng = selectedLocation.longitude.toString();
              }

              },
              child: Container(
                padding: const EdgeInsets.all(6.0),
                color: Colors.white,
                child:  TextField(
                  controller: binLocationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                  enabled: false,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if(_validation()){
                  _saveDataToFirestore();
                }
              },
              child: Text('Add Bin Now'),
            ),
          ],
        ),
      ),
    );
  }

  void updateBinDetailsDialog(String binName, String binQuantity, String latitude, String longitude,String docId) {
    binNameController.text = binName;
    binQuantityControler.text = binQuantity;
    binLocationController.text = '${latitude},${longitude}';
    double screenWidth = MediaQuery.of(context).size.width;

    Get.defaultDialog(
      title: 'Update Bin Details',
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
                controller: binNameController,
                decoration: const InputDecoration(
                  labelText: 'Bin Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(6.0),
              color: Colors.white,
              child:  TextField(
                controller: binQuantityControler,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Bin Quantity in kg',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async{
                LatLng? selectedLocation =  await Get.to(() => const PickLocation(), arguments: {'latitude':latitude,'longitude': longitude,'status':true});
                if(selectedLocation != null){
                  binLocationController.text = '${selectedLocation.latitude},${selectedLocation.longitude}';
                  latitude = selectedLocation.latitude.toString();
                  longitude = selectedLocation.longitude.toString();
                }

              },
              child: Container(
                padding: const EdgeInsets.all(6.0),
                color: Colors.white,
                child:  TextField(
                  controller: binLocationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                  enabled: false,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if(_validation()){
                  _updateData(docId,latitude,longitude);
                }
              },
              child: Text('Update Bin Now'),
            ),
          ],
        ),
      ),
    );
  }

  bool _validation() {
    if(binNameController.text.isEmpty || binNameController.text == ""){
      CustomSnackbar.showSnackbar("Bin Name", "Please enter bin name");
      return false;
    }else if(binQuantityControler.text.isEmpty || binQuantityControler.text == " "){
      CustomSnackbar.showSnackbar("Bin Quantity", "Please enter bin quantity");
      return false;
    }else if(binLocationController.text.isEmpty){
      CustomSnackbar.showSnackbar("Bin Location", "Please select bin location");
      return false;
    }else{
      return true;
    }
  }

  void _saveDataToFirestore() async{
  CustomProgressDialog.showProgressDialog("Please Wait", "Inserting your data");
    try{

      User? user = _auth.currentUser;

      if(user != null){
        String uid = user.uid;
        String docId = _firestore.collection("foodbins").doc().id;

        await _firestore.collection('data').doc(docId).set({
          'userid': uid,
          'binname': binNameController.text.toString(),
          'binquantity': binQuantityControler.text.toString(),
          'latitude': selectedLat,
          'longitude': selectedLng,
          'uniqueid': docId,
        });

        Get.back();
        Get.back();
        CustomSnackbar.showSnackbar('Success', "Data inserted successfully");
        binNameController.text = "";
        binQuantityControler.text = "";
        binLocationController.text = "";
      }

    }catch (e) {
      print(e);
      CustomSnackbar.showSnackbar("OOPS!", "Error in inserting data");
    }
  }

  Future<void> _updateData(String docId,String latitude, String longitude) async {
    CustomProgressDialog.showProgressDialog("Please Wait", "Updating your data");
    try {
      await _firestore.collection('data').doc(docId).update({
        'binname': binNameController.text.toString(),
        'binquantity': binQuantityControler.text.toString(),
        'latitude': latitude,
        'longitude': longitude,
      });

      Get.back();
      Get.back();

      CustomSnackbar.showSnackbar('Success', "Data updated successfully");
      binNameController.text = "";
      binQuantityControler.text = "";
      binLocationController.text = "";
    } catch (e) {
      print(e);
      CustomSnackbar.showSnackbar("OOPS!", "Error in updation process");
    }
  }

  Future<void> _deleteData(String docId) async {
    await _firestore.collection('data').doc(docId).delete();
  }


}
