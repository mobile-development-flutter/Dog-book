// screens/home_screens/profile_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dog_book/components/custom_button.dart';
import 'package:dog_book/components/custom_textfield.dart';
import 'package:dog_book/screens/auth_screens/forgot_password_screen.dart';
import 'package:dog_book/screens/home_screens/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../components/custom_appBar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
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
      emailController.text = user.email ?? '';

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        setState(() {
          nameController.text = userDoc['name'] ?? '';
          passwordController.text = '********';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Profile",
        leftIcon: Icons.arrow_back_ios,
        onLeftIconPressed: () => context.go('/home'),
        backgroundColor: const Color(0xFFF7F7F9),
      ),
      backgroundColor: const Color(0xFFF7F7F9),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),
          Center(
            child: Stack(
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/images/boy.png',
                    width: 80.0.w,
                    height: 80.0.h,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 55.h,
                  left: 55.w,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: 20.w,
                      height: 20.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.r),
                        color: Color(0xFF38B6FF),
                      ),
                      child: Icon(
                        FontAwesomeIcons.pen,
                        size: 10.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 40.h),
          _buildProfileField("Your Name", nameController),
          _buildProfileField("Email Address", emailController),
          _buildProfileField("Password", passwordController, isPassword: true),
          Padding(
            padding: EdgeInsets.only(right: 26.0, top: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Recovery Password',
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: Color(0xFF707B81),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 40.h),
          Center(
            child: CustomButton(
              name: "Save Now",
              onTap: () {},
              color: Color(0xFF38B6FF),
              textColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 20.0, top: 15.h),
          child: Text(
            label,
            style: GoogleFonts.raleway(
              textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        CustomTextfield(
          hint: isPassword ? '********' : "Enter $label",
          controller: controller,
          enabled: false,
        ),
      ],
    );
  }
}
