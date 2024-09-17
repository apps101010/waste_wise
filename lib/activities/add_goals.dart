import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:waste_wise/util/custom_app_bar.dart';

class AddGoals extends StatefulWidget {
  const AddGoals({super.key});

  @override
  State<AddGoals> createState() => _AddGoalsState();
}

class _AddGoalsState extends State<AddGoals> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Controllers for goal details
  TextEditingController goalNameController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  List<bool> foodAddedPerDay = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Waste Wise',),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: goalNameController,
              decoration: InputDecoration(
                labelText: 'Goal Name',
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          startDate = picked;
                          _generateFoodAddedPerDay();
                        });
                      }
                    },
                    child: Text(
                      startDate == null
                          ? 'Pick Start Date'
                          : formatDate(startDate!),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          endDate = picked;
                          _generateFoodAddedPerDay();
                        });
                      }
                    },
                    child: Text(
                      endDate == null
                          ? 'Pick End Date'
                          : formatDate(endDate!),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                saveGoal();
              },
              child: Text('Set Goal'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                addFoodToBin();
              },
              child: Text('Add Food Today'),
            ),
            SizedBox(height: 20),
            // Display Icons for Goal Days
            _buildGoalIcons(),
          ],
        ),
      ),
    );
  }

  // Function to format date as 'yyyy-MM-dd'
  String formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // Function to generate the boolean list for each day in the goal range
  void _generateFoodAddedPerDay() {
    if (startDate != null && endDate != null) {
      int dayCount = endDate!.difference(startDate!).inDays + 1;
      foodAddedPerDay = List.generate(dayCount, (index) => false);
    }
  }

  // Function to display the icons based on the goal duration
  Widget _buildGoalIcons() {
    if (startDate == null || endDate == null) {
      return Text('Please select both start and end dates.');
    }

    return Wrap(
      spacing: 8.0,
      children: List.generate(foodAddedPerDay.length, (index) {
        bool foodAdded = foodAddedPerDay[index];
        return Icon(
          foodAdded ? Icons.check_circle : Icons.cancel,
          color: foodAdded ? Colors.green : Colors.red,
          size: 32,
        );
      }),
    );
  }

  void saveGoal() {
    String goalName = goalNameController.text;
    if (goalName.isNotEmpty && startDate != null && endDate != null) {
      firestore.collection('goals').add({
        'name': goalName,
        'startDate': startDate!.toIso8601String(),
        'endDate': endDate!.toIso8601String(),
        'foodAddedPerDay': foodAddedPerDay, // Store array of bools
      });
    }
  }

  void addFoodToBin() {
    print(startDate);
    // Mark the food as added for today's date in the goal range
    if (startDate != null && endDate != null) {
      int todayIndex = DateTime.now().difference(startDate!).inDays;
      if (todayIndex >= 0 && todayIndex < foodAddedPerDay.length) {
        setState(() {
          foodAddedPerDay[todayIndex] = true;
        });

        // Update the goal document in Firestore
        firestore.collection('goals').get().then((QuerySnapshot querySnapshot) {
          querySnapshot.docs.forEach((doc) {
            DateTime start = DateTime.parse(doc['startDate']);
            DateTime end = DateTime.parse(doc['endDate']);

            if (start == startDate && end == endDate && doc['name'] == goalNameController.text) {
              firestore.collection('goals').doc(doc.id).update({
                'foodAddedPerDay': foodAddedPerDay,
              });
            }
          });
        });
      }
    }
  }
}
