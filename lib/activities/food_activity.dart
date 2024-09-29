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

  TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User? currentuser = _auth.currentUser;
    return Scaffold(
      appBar: const CustomAppBar(title: 'Waste Wise'),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by food name...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),
          // The rest of the UI
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('moderator')
                  .where('userid', isEqualTo: currentuser?.uid)
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final dataDocs = snapshot.data?.docs;

                // Filter the documents based on search text
                final filteredDocs = dataDocs?.where((doc) {
                  var foodName = doc['foodname'].toString().toLowerCase();
                  return foodName.contains(_searchText.toLowerCase());
                }).toList();

                if (filteredDocs == null || filteredDocs.isEmpty) {
                  return Center(
                    child: Text('No Food Added By You'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    var doc = filteredDocs[index];
                    var binId = doc['binid'];
                    return FutureBuilder<DocumentSnapshot>(
                        future: _firestore.collection('data').doc(binId).get(),
                        builder: (context, binSnapshot) {
                          if (binSnapshot.hasError) {
                            return Center(
                                child: Text(
                                    'Error fetching bin data: ${binSnapshot.error}'));
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
                                      style: const TextStyle(
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
          ),
        ],
      ),
    );
  }
}
