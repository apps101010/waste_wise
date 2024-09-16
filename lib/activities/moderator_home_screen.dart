import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waste_wise/activities/food_activity.dart';
import 'package:waste_wise/activities/nearest_food_bin.dart';
import 'package:waste_wise/activities/nearest_food_bin_on_map.dart';
import 'package:waste_wise/util/custom_app_bar.dart';
import 'package:waste_wise/util/custom_colors.dart';

class ModeratorHomeScreen extends StatefulWidget {
  const ModeratorHomeScreen({super.key});

  @override
  State<ModeratorHomeScreen> createState() => _ModeratorHomeScreenState();
}

class _ModeratorHomeScreenState extends State<ModeratorHomeScreen> {
  Map<String, dynamic> _arguments = Get.arguments;
  String _userName = '';
  @override
  void initState(){
    super.initState();
    _userName = _arguments['username'];
    requestLocationPermission();
  }

  Future<void> requestLocationPermission() async {
    var status = await Permission.location.status;

    if (status.isDenied) {
      if (await Permission.location.request().isGranted) {
        print('Permission granted');
      } else {
        print("Location permission denied");
      }
    } else if (status.isGranted) {
      print('Permission already granted');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Waste Wise',),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg.png',
              fit: BoxFit.cover,
            ),
          ),
          // Main Content
           SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'HELLO, $_userName!',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: CustomColors.mainButtonColor,
                    ),
                  ),
                  SizedBox(height: 30),
                  CustomButton(text: 'track food waste progress',status: 1),
                  SizedBox(height: 30),
                  CustomButton(text: 'search for nearest smart food bin', status: 2),
                  SizedBox(height: 30),
                  CustomButton(text: 'View educational content', status: 3),
                  SizedBox(height: 30),
                  CustomButton(text: 'Check Food Bin On Map', status: 4),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final int status;

  const CustomButton({required this.text,required this.status});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        if(status == 1){
          Get.to(() => FoodActivity());
        }else if(status == 2){
          Get.to(() => NearestFoodBin());
        }else if(status == 3){

        }else if(status == 4){
          Get.to(() => NearestFoodBinOnMap());
        }

      },
      child: Container(
        padding: const EdgeInsets.all(40.0),
        margin: const EdgeInsets.only(left: 40.0,right: 40.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: CustomColors.mainButtonColor,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
