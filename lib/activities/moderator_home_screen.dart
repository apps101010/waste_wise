import 'package:flutter/material.dart';
import 'package:waste_wise/util/custom_app_bar.dart';
import 'package:waste_wise/util/custom_colors.dart';

class ModeratorHomeScreen extends StatefulWidget {
  const ModeratorHomeScreen({super.key});

  @override
  State<ModeratorHomeScreen> createState() => _ModeratorHomeScreenState();
}

class _ModeratorHomeScreenState extends State<ModeratorHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: 'Waste Wise',),
      body: Center(child: Text('Admin Home Screen')),
    );
  }
}
