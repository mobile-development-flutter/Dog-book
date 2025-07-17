// screens/auth_screens/forgot_password_screen.dart
import 'package:dog_book/components/custom_alert_dialog.dart';
import 'package:dog_book/components/custom_button.dart';
import 'package:dog_book/components/custom_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    final email = _emailController.text.trim();

    // Check if the email field is empty
    if (email.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return CustomAlertDialog(message: 'Please enter an email address.');
        },
      );
      return;
    }

    // Optional: Add a regex to check for valid email format
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      showDialog(
        context: context,
        builder: (context) {
          return CustomAlertDialog(
            message: 'Please enter a valid email address.',
          );
        },
      );
      return;
    }

    try {
      // Attempt to send the password reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) {
          return CustomAlertDialog(
            message: 'Password Reset Link Sent! Check Your Email',
            showImage: true,
            imagePath: 'assets/images/email.png',
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase exceptions
      String errorMessage = 'An error occurred. Please try again.';

      if (e.code == 'user-not-found') {
        errorMessage =
            'No account found with this email. Please check and try again.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email address. Please enter a valid email.';
      }

      // Show error dialog
      showDialog(
        context: context,
        builder: (context) {
          return CustomAlertDialog(message: errorMessage);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Padding(
          padding: EdgeInsets.all(8.0.r),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF707B81),
              ),
              child: Center(child: Icon(Icons.arrow_back_ios, size: 16.sp)),
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "Forgot Password",
              style: GoogleFonts.raleway(
                fontSize: 32.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Center(
            child: Text(
              "Enter Your Email Account To Reset \n Your Password",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF707B81),
              ),
            ),
          ),
          SizedBox(height: 30.h),
          CustomTextfield(
            hint: "Enter your email address",
            controller: _emailController,
          ),
          SizedBox(height: 50.h),
          Center(
            child: CustomButton(
              name: "Reset Password",
              textColor: Colors.white,
              onTap: passwordReset,
              color: const Color(0xFF38B6FF),
            ),
          ),
        ],
      ),
    );
  }
}
