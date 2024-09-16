import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:waste_wise/util/custom_app_bar.dart';
import 'package:waste_wise/util/custom_colors.dart';

class FoodActivity extends StatefulWidget {
  const FoodActivity({super.key});

  @override
  State<FoodActivity> createState() => _FoodActivityState();
}

class _FoodActivityState extends State<FoodActivity> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    User? currentuser = _auth.currentUser;
    return Scaffold(
      appBar: const CustomAppBar(title: 'Waste Wise'),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('moderator')
            .where('userid', isEqualTo: currentuser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
             return Center(child: CircularProgressIndicator());
          }

          final dataDocs = snapshot.data?.docs;

          if(dataDocs!.isEmpty){
            return Center(child: Text('No Food Added By You'),);
          }

          return ListView.builder(
            itemCount: dataDocs?.length ?? 0,
            itemBuilder: (context, index) {
              var doc = dataDocs![index];
              var binId = doc['binid'];
              return FutureBuilder<DocumentSnapshot>(
                  future: _firestore.collection('data').doc(binId).get(),
                  builder: (context, binSnapshot) {
                    if (binSnapshot.hasError) {
                      return Center(
                          child: Text(
                              'Error fetching bin data: ${binSnapshot.error}'));
                    }

                    if (!binSnapshot.hasData) {
                      // return const Center(child: CircularProgressIndicator());
                    }

                    var binData = binSnapshot.data;
                    var binName = binData?['binname'] ?? 'Unknown';
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            CustomColors.mainButtonColor,
                            CustomColors.mainColorLowShade
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    doc['foodname'],
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'Date: ${doc['date']}',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                'Quantity: ${doc['foodquantity']}',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.grey[800],
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                'Food Bin: $binName',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
            },
          );
        },
      ),
    );
  }
}
