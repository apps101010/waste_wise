import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:waste_wise/util/custom_app_bar.dart';

class ShowEducationalContentDetail extends StatelessWidget {
  const ShowEducationalContentDetail({super.key});

  @override
  Widget build(BuildContext context) {
    Map<String,dynamic> arguments = Get.arguments;
    return Scaffold(
      appBar: const CustomAppBar(title: 'Waste Wise'),
      body: Card( 
        elevation: 5.0,
        margin: const EdgeInsets.all(5.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with fixed height and BoxFit.cover
              Container(
                height: 300, // Fixed height for the image
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  child: Image.network(
                    arguments['imageUrl'],
                    fit: BoxFit.fill,
                    width: double.infinity,
                  ),
                ),
              ),

              // Divider line after the image
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Divider(
                  thickness: 2,
                  color: Colors.grey.shade300,
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Center(
                  child: Text(
                    arguments['title'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),

              // Divider line after the title
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Divider(
                  thickness: 1.5,
                  color: Colors.grey.shade300,
                ),
              ),

              // Description
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
              //   child: Center(
              //     child: Text(
              //       arguments['description'],
              //       textAlign: TextAlign.center,
              //       style: const TextStyle(
              //         fontSize: 15,
              //         height: 1.5,
              //         color: Colors.black54,
              //       ),
              //     ),
              //   ),
              // ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Center(
                  child: Linkify(
                    onOpen: (link) async {
                      Uri uri = Uri.parse(link.url);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      } else {
                        throw 'Could not launch $link';
                      }
                    },
                    text: arguments['description'],
                    style: const TextStyle(color: Colors.black54, fontSize: 15, height: 1.5, ),
                    linkStyle: const TextStyle(color: Colors.blue),
                  ),
                ),
              ),

              // Bottom padding for spacing
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

