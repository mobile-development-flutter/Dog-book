// screens/home_screens/edit_profile_screen.dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dog_book/components/custom_textfield.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../../components/custom_appBar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  File? _imageFile;
  String? _profileImageUrl;
  final ImagePicker _picker = ImagePicker();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      Map<String, dynamic>? userData = await getUserData(user.uid);
      if (userData != null) {
        setState(() {
          nameController.text = userData['name'] ?? '';
          emailController.text = userData['email'] ?? '';
          firstNameController.text = userData['firstName'] ?? '';
          lastNameController.text = userData['lastName'] ?? '';
          phoneNumberController.text = userData['phoneNumber'] ?? '';
          _profileImageUrl = userData['profileImageUrl'];
        });
      }
    }
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

  Future<void> updateUserProfile(
    String uid,
    String firstName,
    String lastName,
    String phoneNumber,
    String profileImageUrl,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'profileImageUrl': profileImageUrl,
      });
    } catch (e) {
      print("Error updating user profile: $e");
    }
  }

  Future<void> _saveUserProfile() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    String? profileImageUrl = _profileImageUrl;

    if (_imageFile != null) {
      profileImageUrl = await uploadProfileImage(_imageFile!, user.uid);
    }

    await _firestore.collection('users').doc(user.uid).update({
      'name': nameController.text,
      'email': emailController.text,
      'firstName': firstNameController.text,
      'lastName': lastNameController.text,
      'phoneNumber': phoneNumberController.text,
      'profileImageUrl': profileImageUrl,
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Profile updated successfully!')));
  }

  Future<String?> uploadProfileImage(File imageFile, String uid) async {
    try {
      Reference storageRef = FirebaseStorage.instance.ref().child(
        'profile_images/$uid.jpg',
      );
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading profile image: $e");
      return null;
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      String uid = FirebaseAuth.instance.currentUser!.uid;

      String? imageUrl = await uploadProfileImage(imageFile, uid);

      if (imageUrl != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'profileImageUrl': imageUrl,
        });

        setState(() {
          _profileImageUrl = imageUrl;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Profile",
        onLeftIconPressed: () {
          Navigator.pop(context);
        },
        leftIcon: Icons.arrow_back_ios,
        rightWidget: GestureDetector(
          onTap: () {
            _saveUserProfile();
          },
          child: Text(
            "Done",
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Color(0xFF38B6FF),
              ),
            ),
          ),
        ),
        backgroundColor: const Color(0xFFF7F7F9),
      ),

      backgroundColor: const Color(0xFFF7F7F9),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30.h),
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50.r,
                backgroundImage:
                    _imageFile != null
                        ? FileImage(_imageFile!)
                        : _profileImageUrl != null
                        ? NetworkImage(_profileImageUrl!) as ImageProvider
                        : AssetImage('assets/images/boy.png'),
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              nameController.text,
              style: GoogleFonts.raleway(
                fontSize: 20.sp,
                color: Color(0xFF2B2B2B),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "Change Profile Picture",
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Color(0xFF38B6FF),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 40.h),
            _buildProfileField("First Name", firstNameController),
            _buildProfileField("Last Name", lastNameController),
            _buildProfileField("Mobile Number", phoneNumberController),
            SizedBox(height: 70.h),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(
    String label,
    TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 20.0.w, top: 25.h),
          child: Text(
            label,
            style: GoogleFonts.raleway(
              textStyle: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        CustomTextfield(hint: "Enter $label", controller: controller),
      ],
    );
  }
}
