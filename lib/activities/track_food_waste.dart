import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waste_wise/util/custom_app_bar.dart';
import 'package:waste_wise/util/custom_colors.dart';

import 'all_goals.dart';
import 'food_activity.dart';

class TrackFoodWaste extends StatelessWidget {
  const TrackFoodWaste({super.key});

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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 30),
                CustomButton(text: 'History', status: 1),
                SizedBox(height: 30),
                CustomButton(text: 'My Plan', status: 2),
                SizedBox(height: 10),
              ],
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
