import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  TextEditingController goalNameController = TextEditingController();
  TextEditingController goalTargetController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  List<bool> foodAddedPerDay = [];

  String pickStartDate = "Pick Start Date";
  String pickEndDate = "Pick End Date";

  @override
  Widget build(BuildContext context) {
    User? currentuser = _auth.currentUser;
    return Scaffold(
      appBar: CustomAppBar(title: 'Waste Wise',),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore.collection('goals')
                  .where('userid', isEqualTo: currentuser?.uid)
                  .orderBy('startDate', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('No goals found.'));
                }

                List<DocumentSnapshot> goals = snapshot.data!.docs;

                if(goals.isEmpty){
                  return const Center(child: Text('No Data Available'),);
                }

                return ListView.builder(
                  itemCount: goals.length,
                  itemBuilder: (context, index) {
                    var goalData = goals[index];
                    String goalName = goalData['name'];
                    int target = goalData['target'];
                    int remaining = goalData['remaining'];
                    DateTime startDate = DateTime.parse(goalData['startDate']);
                    DateTime endDate = DateTime.parse(goalData['endDate']);
                    List<bool> foodAddedPerDay = List.from(goalData['foodAddedPerDay']);

                    return Card(
                      elevation: 4.0,
                      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    goalName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: CustomColors.mainButtonColor,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.flag,
                                  color: CustomColors.mainButtonColor,
                                ),
                              ],
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'Target : ${target} | Remaining : ${remaining}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),

                          _buildGoalIcons(startDate, endDate, foodAddedPerDay),
                          const SizedBox(height: 10),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed: () {
                goalNameController.text = '';
                goalTargetController.text = '';
                startDateController.text = '';
                endDateController.text = '';
                showCustomDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomColors.mainButtonColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                elevation: 5,
                shadowColor: Colors.green[400],
              ),
              child: const Text(
                'Add New Goal',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      )

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

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 8.0),
        child: Wrap(
          spacing: 8.0,
          children: icons,
        ),
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
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(6.0),
                color: Colors.white,
                child: TextField(
                  controller: goalNameController,
                  decoration: const InputDecoration(
                    labelText: 'Goal Name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              Container(
                padding: EdgeInsets.all(6.0),
                color: Colors.white,
                child: TextField(
                  controller: goalTargetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Goal Target in kg',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              InkWell(
                onTap: () async{
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
                    startDateController.text = formatDate(startDate!);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(6.0),
                  color: Colors.white,
                  child: TextField(
                    enabled: false,
                    controller: startDateController,
                    decoration: const InputDecoration(
                      labelText: 'Pick Start Date',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              // const SizedBox(height: 10),
              // ElevatedButton(
              //   onPressed: () async {
              //     DateTime? picked = await showDatePicker(
              //       context: context,
              //       initialDate: DateTime.now(),
              //       firstDate: DateTime(2020),
              //       lastDate: DateTime(2100),
              //     );
              //     if (picked != null) {
              //       setState(() {
              //         startDate = picked;
              //         _generateFoodAddedPerDay();
              //       });
              //     }
              //   },
              //   child: Text(
              //     startDate == null
              //         ? 'Pick Start Date'
              //         : formatDate(startDate!),
              //   ),
              // ),
              // SizedBox(height: 10),

              InkWell(
                onTap: () async{
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
                    endDateController.text = formatDate(endDate!);
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(6.0),
                  color: Colors.white,
                  child: TextField(
                    enabled: false,
                    controller: endDateController,
                    decoration: const InputDecoration(
                      labelText: 'Pick End Date',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),

              // ElevatedButton(
              //   onPressed: () async {
              //     DateTime? picked = await showDatePicker(
              //       context: context,
              //       initialDate: DateTime.now(),
              //       firstDate: DateTime(2020),
              //       lastDate: DateTime(2100),
              //     );
              //     if (picked != null) {
              //       setState(() {
              //         endDate = picked;
              //         _generateFoodAddedPerDay();
              //       });
              //     }
              //   },
              //   child: Text(
              //     endDate == null
              //         ? 'Pick End Date'
              //         : formatDate(endDate!),
              //   ),
              // ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if(_validation()){
                    saveGoal();
                  }
                },
                child: const Text('Add Goal Now',style: TextStyle(color: CustomColors.mainButtonColor)),
              ),
            ],
          ),
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

  bool _validation(){
    if(goalNameController.text.trim().isEmpty){
      CustomSnackbar.showSnackbar('OOPS!', 'Enter goal name');
      return false;
    }else if(goalTargetController.text.trim().isEmpty){
      CustomSnackbar.showSnackbar('OOPS!', 'Enter goal target');
      return false;
    }else if(startDateController.text.trim().isEmpty){
      CustomSnackbar.showSnackbar('OOPS!', 'Select start date');
      return false;
    }else if(endDateController.text.trim().isEmpty){
      CustomSnackbar.showSnackbar('OOPS!', 'Select end date');
      return false;
    }else{
      return true;
    }
  }

  void saveGoal() async{
    CustomProgressDialog.showProgressDialog('Please Wait', 'We are adding your Goal');
    try{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String goalName = goalNameController.text;
      if (goalName.isNotEmpty && startDate != null && endDate != null) {
        DocumentReference docRef =  await firestore.collection('goals').add({
          'name': goalName,
          'target':int.parse(goalTargetController.text.toString()),
          'remaining':int.parse(goalTargetController.text.toString()),
          'startDate': startDate!.toIso8601String(),
          'endDate': endDate!.toIso8601String(),
          'foodAddedPerDay': foodAddedPerDay,
          'userid': prefs.getString('uid'),
        });

        String newGoalId = docRef.id;

        print(prefs.getString('uid'));
        print(newGoalId);

        await firestore.collection('users').doc(prefs.getString('uid')).update({
          'goalid': newGoalId,
        });
        prefs.setString('goalid', newGoalId);
      }

      Get.back();
      Get.back();
      CustomSnackbar.showSnackbar('Success', 'Goal added successfully');
      goalNameController.text = '';
      goalTargetController.text = '';
      startDateController.text = '';
      endDateController.text = '';
      startDate = null;
      endDate = null;

    }catch(e){
      Get.back();
      CustomSnackbar.showSnackbar('OOPS!', 'Internal server error');
      print(e);
    }

  }

}
