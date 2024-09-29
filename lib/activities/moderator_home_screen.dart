import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waste_wise/activities/add_goals.dart';
import 'package:waste_wise/activities/all_goals.dart';
import 'package:waste_wise/activities/food_activity.dart';
import 'package:waste_wise/activities/nearest_food_bin.dart';
import 'package:waste_wise/activities/nearest_food_bin_on_map.dart';
import 'package:waste_wise/activities/show_educational_content.dart';
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
  String? currentDate;
  @override
  void initState() {
    super.initState();
    _userName = _arguments['username'];
    requestLocationPermission();
    DateTime now = DateTime.now();
    currentDate = "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";

    checkEntry(currentDate!);

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
                  CustomButton(text: 'Educational Resources', status: 3),
                  SizedBox(height: 30),
                  CustomButton(text: 'Check Food Bin On Map', status: 4),
                  SizedBox(height: 30),
                  CustomButton(text: 'My Plan', status: 5),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void checkEntry(String cDate) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getString('currenttrack') == 'current'){
      showReminderDialog();
    }else{
      String? sDate = prefs.getString('currenttrack');
      DateTime currentDate = DateTime.parse(formatDateForComparison(cDate));
      DateTime saveDate = DateTime.parse(formatDateForComparison(sDate!));

      if(saveDate.isBefore(currentDate)){
        showReminderDialog();
      }else{
        print('all ok');
      }
    }

  }


  void showReminderDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Container(

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Close Icon
                Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                    onTap: () {
                      Get.back(); // Close the dialog
                    },
                    child: const Icon(
                      Icons.close,
                      color: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Message
                const Text(
                  "Please log today’s food to meet your goal.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: CustomColors.mainButtonColor,
                  ),
                ),
                const SizedBox(height: 20),

                // Button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      Get.to(() => const NearestFoodBin());


                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColors.mainButtonColor,
                      foregroundColor: Colors.white
                    ),
                    child: const Text('Enter Food Now',),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  String formatDateForComparison(String date) {
    List<String> parts = date.split('-');
    return '${parts[2]}-${parts[1]}-${parts[0]}'; // Converts from 'dd-MM-yyyy' to 'yyyy-MM-dd'
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
          Get.to(() => ShowEducationalContent(),arguments: {'visibility':false});
        }else if(status == 4){
          Get.to(() => NearestFoodBinOnMap());
        }else if(status == 5){
          Get.to(() => AllGoals());
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
