import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waste_wise/activities/login_screen.dart';
import 'package:waste_wise/activities/signup_screen.dart';
import 'package:waste_wise/activities/splash_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyDwdDeSurZMv_swhjnJPve8eBhWGcNpCAc', // paste your api key here
      appId: '1:992542002602:android:cac7dee06f721604b5afd3', //paste your app id here
      messagingSenderId: '992542002602', //paste your messagingSenderId here
      projectId: 'waste-wise-db410', //paste your project id here
    ),
  );
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
