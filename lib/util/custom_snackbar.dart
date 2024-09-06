import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waste_wise/util/custom_colors.dart';

class CustomSnackbar{

  static void showSnackbar(String title,String text){
    Get.snackbar(
        title,
        text,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: CustomColors.mainButtonColor,
      margin: const EdgeInsets.all(10.0),
      overlayBlur: 5,
      titleText: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      messageText: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
        ),
      )
    );
  }
}