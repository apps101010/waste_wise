import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waste_wise/activities/add_educational_content.dart';
import 'package:waste_wise/activities/show_educational_content_detail.dart';
import 'package:waste_wise/util/custom_app_bar.dart';
import 'package:waste_wise/util/custom_colors.dart';

class ShowEducationalContent extends StatefulWidget {
  const ShowEducationalContent({super.key});

  @override
  State<ShowEducationalContent> createState() => _ShowEducationalContentState();
}

class _ShowEducationalContentState extends State<ShowEducationalContent> {
  final CollectionReference _collectionRef =
  FirebaseFirestore.instance.collection('posts');

  @override
  Widget build(BuildContext context) {
    Map<String,dynamic> arguments = Get.arguments;
    return Scaffold(
      appBar: const CustomAppBar(title: 'Waste Wise'),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text("Error fetching data"));
                }

                final items = snapshot.data!;

                if(items.isEmpty){
                  return const Center(child: Text('No content added yet'),);
                }

                return ListView.builder(
                  padding: EdgeInsets.all(8.0),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(vertical: 5.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(8),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            item['imageUrl'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          item['title'],
                          maxLines: 1,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: CustomColors.mainButtonColor,
                          ),
                        ),
                        subtitle: Text(
                          item['description'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        onTap: (){
                          Get.to(() => const ShowEducationalContentDetail(), arguments: {'title': item['title'], 'description': item['description'], 'imageUrl': item['imageUrl'],},);
                        },
                        trailing: const Icon(
                          Icons.arrow_forward_ios_sharp,
                          size: 17.0,
                          color: CustomColors.mainButtonColor,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Visibility(
            visible: arguments['visibility'],
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton(
                  onPressed: (){
                    Get.to(() => const AddEducationalContent());
                  },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColors.mainButtonColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  )
                ),
                  child: const Text('Add New Content'),),
            ),
          ),
        ],
      )

    );
  }

  Future<List<Map<String, dynamic>>> _fetchData() async {
    QuerySnapshot querySnapshot = await _collectionRef.get();
    return querySnapshot.docs.map((doc) {
      return {
        "id": doc.id,
        "title": doc['title'],
        "description": doc['description'],
        "imageUrl": doc['imageUrl'],
      };
    }).toList();
  }
}
