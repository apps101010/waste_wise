import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:waste_wise/activities/login_screen.dart';
import 'package:waste_wise/util/custom_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      Get.off(const LoginScreen());
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/bg.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),

                  // Logo Image Section
                  Image.asset(
                    'assets/images/waste.png',
                    height: 210,
                    width: 210,
                  ),
                  const SizedBox(height: 25),

                  // Welcome Text Section
                  RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                              text: 'WASTE',
                            style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.w500,
                              color: CustomColors.mainButtonColor,
                              letterSpacing: 4.0,
                            ),
                          ),
                          TextSpan(
                            text: ' ',
                            style: TextStyle(
                              fontSize: 35,
                            ),
                          ),
                          TextSpan(
                            text: 'WISE',
                            style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              color: CustomColors.mainButtonColor,
                              letterSpacing: 4.0,
                            ),
                          )
                        ]
                      ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'ESTD 2024',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: CustomColors.mainButtonColor,
                      letterSpacing: 1.0,
                    ),
                  )

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
