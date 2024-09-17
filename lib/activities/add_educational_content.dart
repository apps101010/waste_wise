import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:waste_wise/util/custom_app_bar.dart';
import 'package:waste_wise/util/custom_colors.dart';
import 'package:waste_wise/util/custom_snackbar.dart';
import 'package:waste_wise/util/progress_dialog.dart';

class AddEducationalContent extends StatefulWidget {
  const AddEducationalContent({super.key});

  @override
  State<AddEducationalContent> createState() => _AddEducationalContentState();
}

class _AddEducationalContentState extends State<AddEducationalContent> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  File? _image;
  final picker = ImagePicker();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Waste Wise'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title TextField with custom border
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Enter Title',
                  labelStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: CustomColors.mainButtonColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: CustomColors.mainButtonColor, width: 2.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
        
              // Description TextField with custom border
              TextField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Enter Description',
                  labelStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: CustomColors.mainButtonColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: CustomColors.mainButtonColor, width: 2.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
        
              // Display selected image or placeholder text
              _image != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _image!,
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                ),
              )
                  : const Text(
                'No image selected',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
        
              // Image selection button
              ElevatedButton.icon(
                onPressed: pickImage,
                icon: Icon(Icons.image, color: Colors.white),
                label: Text('Select Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColors.mainButtonColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
        
              // Submit button with loading indicator
              _isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              )
                  : ElevatedButton(
                onPressed: (){
                  if(_validation()){
                    uploadData();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColors.mainButtonColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Add Content'),
              ),
            ],
          ),
        ),
      )

    );
  }

  bool _validation(){
    if(_titleController.text.trim().isEmpty){
      CustomSnackbar.showSnackbar('OOPS!', 'Please enter title');
      return false;
    }else if(_descriptionController.text.trim().isEmpty){
      CustomSnackbar.showSnackbar('OOPS!', 'Please enter description');
      return false;
    }else if(_image == null){
      CustomSnackbar.showSnackbar('OOPS!', 'Please select an image');
      return false;
    }else{
      return true;
    }
  }

  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> uploadData() async {
   CustomProgressDialog.showProgressDialog('Please Wait', 'Your data is being added');
    try {
      // Upload image to Firebase Storage
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child('images/$fileName');
      UploadTask uploadTask = ref.putFile(_image!);
      TaskSnapshot snapshot = await uploadTask;
      String imageUrl = await snapshot.ref.getDownloadURL();

      // Save title, description, and image URL to Firestore
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('posts').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.back();
      CustomSnackbar.showSnackbar('Success', 'Content Added Successfully');
      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _image = null;
      });
    } catch (e) {
      Get.back();
      CustomSnackbar.showSnackbar('OOPS!', 'Internal server error');
      print(e);
    }
  }


}
