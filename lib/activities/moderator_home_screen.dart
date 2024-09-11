import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
          const SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 40),
                  Text(
                    'HELLO, JOUHARA !',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: CustomColors.mainButtonColor,
                    ),
                  ),
                  SizedBox(height: 50),
                  CustomButton(text: 'track food waste progress'),
                  SizedBox(height: 50),
                  CustomButton(text: 'search for nearest smart food bin'),
                  SizedBox(height: 50),
                  CustomButton(text: 'View educational content'),
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

  const CustomButton({required this.text});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Get.to(() => NearestFoodBin());
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
