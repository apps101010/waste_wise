import 'package:flutter/material.dart';
import 'package:waste_wise/util/custom_app_bar.dart';
import 'package:waste_wise/util/custom_colors.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: 'Waste Wise',),
      body: Center(child: Text('Admin Home Screen')),
    );
  }
}
