import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:waste_wise/activities/login_screen.dart';
import 'package:waste_wise/util/custom_colors.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  RxBool _isPassowrdVisible = true.obs;
  RxBool _isConfirmPasswordVisible = true.obs;

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
                  const TextField(
                    decoration: InputDecoration(
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
                  const TextField(
                    decoration: InputDecoration(
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
                      onPressed: () {},
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
                            Get.to(const LoginScreen());

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
}
