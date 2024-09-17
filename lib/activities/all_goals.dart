import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waste_wise/util/custom_app_bar.dart';
import 'package:waste_wise/util/custom_colors.dart';
import 'package:waste_wise/util/custom_snackbar.dart';
import 'package:waste_wise/util/progress_dialog.dart';

class AllGoals extends StatefulWidget {
  const AllGoals({super.key});

  @override
  State<AllGoals> createState() => _AllGoalsState();
}

class _AllGoalsState extends State<AllGoals> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  TextEditingController goalNameController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  List<bool> foodAddedPerDay = [];

  String pickStartDate = "Pick Start Date";
  String pickEndDate = "Pick End Date";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Waste Wise',),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore.collection('goals').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return Center(child: Text('No goals found.'));
                }

                List<DocumentSnapshot> goals = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: goals.length,
                  itemBuilder: (context, index) {
                    var goalData = goals[index];
                    String goalName = goalData['name'];
                    DateTime startDate = DateTime.parse(goalData['startDate']);
                    DateTime endDate = DateTime.parse(goalData['endDate']);
                    List<bool> foodAddedPerDay = List.from(goalData['foodAddedPerDay']);

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              goalName,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          _buildGoalIcons(startDate, endDate, foodAddedPerDay),
                          SizedBox(height: 16),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                showCustomDialog();
              },
              child: Text('Add New Goal'),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildGoalIcons(DateTime startDate, DateTime endDate, List<bool> foodAddedPerDay) {
    int totalDays = endDate.difference(startDate).inDays + 1;

    // Generate a list of icons for each day in the goal period
    List<Widget> icons = List.generate(totalDays, (index) {
      DateTime day = startDate.add(Duration(days: index));
      bool foodAdded = index < foodAddedPerDay.length ? foodAddedPerDay[index] : false;

      return Tooltip(
        message: '${day.day}-${day.month}-${day.year}',
        child: Icon(
          Icons.circle,
          color: foodAdded ? Colors.green : Colors.red,
          size: 24,
        ),
      );
    });

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Wrap(
        spacing: 8.0,
        children: icons,
      ),
    );
  }

  void showCustomDialog() {
    double screenWidth = MediaQuery.of(context).size.width;

    Get.defaultDialog(
      title: 'Enter Your Goal',
      titleStyle: const TextStyle(color: Colors.white),
      titlePadding: const EdgeInsets.all(8.0),
      contentPadding: const EdgeInsets.all(8.0),
      radius: 15,
      backgroundColor: CustomColors.mainButtonColor,
      content: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(6.0),
              color: Colors.white,
              child: TextField(
                controller: goalNameController,
                decoration: const InputDecoration(
                  labelText: 'Goal Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 10),
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
              child: Text('Add Goal Now'),
            ),
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

  void saveGoal() async{
    CustomProgressDialog.showProgressDialog('Please Wait', 'We are adding your Goal');
    try{

      String goalName = goalNameController.text;
      if (goalName.isNotEmpty && startDate != null && endDate != null) {
        DocumentReference docRef =  await firestore.collection('goals').add({
          'name': goalName,
          'startDate': startDate!.toIso8601String(),
          'endDate': endDate!.toIso8601String(),
          'foodAddedPerDay': foodAddedPerDay,
        });

        String newGoalId = docRef.id;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        print(prefs.getString('uid'));
        print(newGoalId);
        await firestore.collection('users').doc(prefs.getString('uid')).update({
          'goalid': newGoalId,
        });
        prefs.setString('goalid', newGoalId);
      }

      Get.back();
      CustomSnackbar.showSnackbar('Success', 'Goal added successfully');
      goalNameController.text = '';
      startDate = null;
      endDate = null;

    }catch(e){
      Get.back();
      CustomSnackbar.showSnackbar('OOPS!', 'Internal server error');
      print(e);
    }

  }

}
