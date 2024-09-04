import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waste_wise/activities/login_screen.dart';
import 'package:waste_wise/activities/signup_screen.dart';
import 'package:waste_wise/activities/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Waste Wise',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
