import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:waste_wise/activities/login_screen.dart';
import 'package:waste_wise/util/custom_colors.dart';
import 'package:waste_wise/util/custom_snackbar.dart';
import 'package:waste_wise/util/progress_dialog.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  RxBool _isPassowrdVisible = true.obs;
  RxBool _isConfirmPasswordVisible = true.obs;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  var email = TextEditingController();
  var password = TextEditingController();
  var fullName = TextEditingController();
  var confirmPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
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
                  const SizedBox(height: 10),

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

                  // Email text field section
                   TextField(
                    controller: email,
                    decoration: const InputDecoration(
                      labelText: 'Email or Phone Number',
                      labelStyle: TextStyle(color: CustomColors.mainButtonColor,fontWeight: FontWeight.bold,fontSize: 14.0),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: CustomColors.mainButtonColor),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: CustomColors.mainButtonColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),

                  // Full name section
                   TextField(
                     controller: fullName,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      labelStyle: TextStyle(color: CustomColors.mainButtonColor,fontWeight: FontWeight.bold,fontSize: 14.0),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: CustomColors.mainButtonColor),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: CustomColors.mainButtonColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),

                  // password text field section
                   Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      )),
                      const SizedBox(height: 3),
                      const Text(
                        'Must contain a number and least of six characters',
                        style: TextStyle(
                          fontSize: 12,
                          color: CustomColors.mainButtonColor,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  // confirm password text field section
                   Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => TextField(
                        controller: confirmPassword,
                        obscureText: _isConfirmPasswordVisible.value,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          labelStyle: const TextStyle(color: CustomColors.mainButtonColor,fontWeight: FontWeight.bold,fontSize: 14.0),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.green,
                            ),
                            onPressed: () {
                              _isConfirmPasswordVisible.value = !_isConfirmPasswordVisible.value;

                            },
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: CustomColors.mainButtonColor),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: CustomColors.mainButtonColor),
                          ),
                        ),
                      )),
                      const SizedBox(height: 3),
                      const Text(
                        'Must contain a number and least of six characters',
                        style: TextStyle(
                            fontSize: 12,
                            color: CustomColors.mainButtonColor,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Sign up button section
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if(_validateFields()){
                          signUpUser();
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
                        'Sign Up',
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
                          "Have an account ? ",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: CustomColors.mainButtonColor,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.to(() => const LoginScreen());

                          },
                          child: const Text(
                            'Login',
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
    );
  }

  bool _validateFields() {
    if (email.text.isEmpty) {
      CustomSnackbar.showSnackbar("Enter Email", "Please enter your email");
      return false;
    } else if (fullName.text.isEmpty) {
      CustomSnackbar.showSnackbar("Enter Name", "Please enter your name");
      return false;
    }  else if (password.text.isEmpty) {
      CustomSnackbar.showSnackbar("Enter Password", "Please enter your password");
      return false;
    } else if (confirmPassword.text.isEmpty) {
      CustomSnackbar.showSnackbar("Confirm Password", "Please enter your password again");
      return false;
    }else if(!_isPasswordValid()){
      CustomSnackbar.showSnackbar("OOPS!", "password should be 6 characters long and must contain at least one number");
      return false;
  } else if(password.text.toString() != confirmPassword.text.toString()){
      CustomSnackbar.showSnackbar("OOPS!", "Your password does not match");
      return false;
    }else{
      return true;
    }
  }

  bool _isPasswordValid() {
    return RegExp(r'^(?=.*[0-9])[a-zA-Z0-9]{6,}$').hasMatch(password.text.toString());
  }

  void signUpUser() async {
    CustomProgressDialog.showProgressDialog("Please Wait", "We are checking your details");
      try {
        // Create user with Firebase Authentication
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email.text.toString(),
          password: password.text.toString(),
        );

        // Get the created user's UID
        String uid = userCredential.user!.uid;

        // Store additional data in Firestore
        await _firestore.collection('users').doc(uid).set({
          'fullName': fullName.text.toString(),
          'email': email.text.toString(),
          'role': 'moderator',
        });

        // You can also navigate to a different screen after successful signup
        // Navigator.of(context).pushReplacement(
        //   MaterialPageRoute(builder: (context) => SuccessScreen()),
        // );
        Get.back();
        Get.back();
        CustomSnackbar.showSnackbar("Success", "You have registered Successfully");
        print('Signup success');
      } catch (e) {
        Get.back();
        if (e is FirebaseAuthException) {
          if(e.code == "email-already-in-use"){
            CustomSnackbar.showSnackbar("Account Exist", "The email address is already in use by another account");
          }
          print('Error code: ${e.code}');
          print('Error message: ${e.message}');
          print('Error stackTrace: ${e.stackTrace}');
        } else {
          CustomSnackbar.showSnackbar('OOPS!!', "Firebase Internal Error");
          print('General error: ${e.toString()}');
        }
        print({e.toString()});
        // Handle errors (e.g., show a dialog with the error message)
      }
  }
}
