import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waste_wise/activities/admin_home_screen.dart';
import 'package:waste_wise/activities/moderator_home_screen.dart';
import 'package:waste_wise/activities/signup_screen.dart';
import 'package:waste_wise/util/custom_colors.dart';
import 'package:waste_wise/util/custom_snackbar.dart';
import 'package:waste_wise/util/progress_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  RxBool _isPassowrdVisible = true.obs;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  var email = TextEditingController();
  var password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
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
                  children: [
                    const SizedBox(height: 30),
        
                    // Logo Image Section
                    Image.asset(
                      'assets/images/waste.png',
                      height: 190,
                      width: 190,
                    ),
                    const SizedBox(height: 25),
        
                    // Welcome Text Section
                    const Text(
                      'WELCOME',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: CustomColors.mainButtonColor,
                      ),
                    ),
                    const SizedBox(height: 30),
        
                    // Username, Email text field section
                     TextField(
                       controller: email,
                      decoration: const InputDecoration(
                        labelText: 'Enter your email',
                        labelStyle: TextStyle(color: CustomColors.mainButtonColor,fontWeight: FontWeight.bold,fontSize: 14.0),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: CustomColors.mainButtonColor),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: CustomColors.mainButtonColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
        
                    // password text field section
                     Obx(() => TextField(
                       controller: password,
                       obscureText: _isPassowrdVisible.value,
                       decoration: InputDecoration(
                         labelText: 'Password',
                         labelStyle: const TextStyle(color: CustomColors.mainButtonColor,fontWeight: FontWeight.bold,fontSize: 14.0),
                         suffixIcon: IconButton(
                           icon: Icon(
                             _isPassowrdVisible.value
                                 ? Icons.visibility_off
                                 : Icons.visibility,
                             color: Colors.green,
                           ),
                           onPressed: () {
                             _isPassowrdVisible.value = !_isPassowrdVisible.value;
        
                           },
                         ),
                         enabledBorder: const UnderlineInputBorder(
                           borderSide: BorderSide(color: CustomColors.mainButtonColor),
                         ),
                         focusedBorder: const UnderlineInputBorder(
                           borderSide: BorderSide(color: CustomColors.mainButtonColor),
                         ),
                       ),
                     ),),
                    const SizedBox(height: 40),
        
                    // Login button section
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if(_validateFields()){
                            signInUser();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomColors.mainButtonColor,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                        ),
                        child: const Text(
                          'Log In',
                          style: TextStyle(fontSize: 18, color: Colors.white,fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Spacer(),
                    Container(
                      margin: const EdgeInsets.only(bottom: 5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                         const Text(
                           "Don't have an account ? ",
                         style: TextStyle(
                           fontWeight: FontWeight.w500,
                           color: CustomColors.mainButtonColor,
                         ),
                         ),
                          GestureDetector(
                            onTap: () {
                              Get.to(() => const SignupScreen());
        
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 18.0,
                                color: CustomColors.mainButtonColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _validateFields() {
    if (email.text.isEmpty) {
      CustomSnackbar.showSnackbar("Enter Email", "Please enter your email");
      return false;
    }   else if (password.text.isEmpty) {
      CustomSnackbar.showSnackbar("Enter Password", "Please enter your password");
      return false;
    }else{
      return true;
    }
  }

  void signInUser() async {
    CustomProgressDialog.showProgressDialog("Please Wait", "We are checking your credentials");
    try {
      UserCredential userCredential =  await _auth.signInWithEmailAndPassword(email: email.text.toString(), password: password.text.toString());
      String userId =  userCredential.user!.uid;
      User? user = userCredential.user;

      if(user!.emailVerified){

        DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {

          var userData = userDoc.data() as Map<String, dynamic>;
          String fullName = userData['fullName'];
          String email = userData['email'];
          String role = userData['role'];
          String goalId = userData['goalid'];
          String currentTrack = userData['currenttrack'];

          print('UID: $userId');
          print('Full Name: $fullName');
          print('Email: $email');
          print('Role: $role');
          SharedPreferences.setMockInitialValues({});
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("uid", userId);
          prefs.setString("username", fullName);
          prefs.setString("email", email);
          prefs.setString("role", role);
          prefs.setString('goalid', goalId);
          prefs.setString('currenttrack', currentTrack);

          Get.back();
          CustomSnackbar.showSnackbar('Success', "You are logged in successfully");
          if(role == "moderator"){
            Get.off(() => const ModeratorHomeScreen(), arguments: {'username':fullName});
          }else{
            Get.off(() => const AdminHomeScreen());
          }
          print('sigin success');
        } else {
          print('User data not found in Firestore');
        }

      }else{
        Get.back();
        CustomSnackbar.showSnackbar('OOPS!', 'Kindly check your email to verify your account before proceeding');
      }

    } catch (e) {
      Get.back();
      CustomSnackbar.showSnackbar('OOPS!', "username or password is incorrect");
      print(e);
    }
  }

}
