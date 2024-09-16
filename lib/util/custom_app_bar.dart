import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:waste_wise/activities/login_screen.dart';
import 'package:waste_wise/util/custom_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const CustomAppBar({super.key,required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: CustomColors.mainButtonColor,
      ),
      backgroundColor: CustomColors.mainButtonColor,
      iconTheme: const IconThemeData(color: Colors.white),
      centerTitle: true,
      title: Container(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            letterSpacing: 2.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      actions: <Widget>[
        PopupMenuButton<String>(
          onSelected: (String value) {
            if(value == 'Logout'){
              Get.off(() => LoginScreen());
            }
          },
          offset: const Offset(0, 40),
          itemBuilder: (BuildContext context) {
            return <String>['Logout'].map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice),
              );
            }).toList();
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}