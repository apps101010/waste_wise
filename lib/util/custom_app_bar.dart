import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waste_wise/util/custom_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  const CustomAppBar({super.key,required this.title,this.actions});

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
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}