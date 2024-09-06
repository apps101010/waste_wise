import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:waste_wise/util/custom_colors.dart';

class CustomProgressDialog{

  static void showProgressDialog(String title,String content){
    Get.defaultDialog(
      title: title,
      titleStyle: const TextStyle(fontSize: 17.0,color: Colors.white,letterSpacing: 1.0,fontWeight: FontWeight.bold),
      titlePadding: const EdgeInsets.all(10.0),
      backgroundColor: CustomColors.mainButtonColor,
      barrierDismissible: false,
      content: Column(
        children: [
          const SpinKitWave(color: Colors.white,size: 30.0,),
          const SizedBox(height: 10.0),
          Text(
            content,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15.0,
              color: Colors.white,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

}