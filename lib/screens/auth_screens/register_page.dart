// screens/auth_screens/register_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dog_book/components/custom_button.dart';
import 'package:dog_book/components/custom_textfield.dart';
import 'package:dog_book/components/custom_validation_popup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordController =
      TextEditingController();

  // Validation patterns
  final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // Password should have at least 8 characters, one uppercase letter, one lowercase letter, and one number
  final RegExp _passwordRegExp = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );

  String? _validateEmail(String email) {
    if (email.isEmpty) {
      return "Email cannot be empty";
    }
    if (!_emailRegExp.hasMatch(email)) {
      return "Please enter a valid email address";
    }
    return null;
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return "Password cannot be empty";
    }
    if (!_passwordRegExp.hasMatch(password)) {
      return "Password must have at least 8 characters, include an uppercase letter, lowercase letter, number, and special character";
    }
    return null;
  }

  // register method
  void registerUser() async {
    // Validate inputs first
    String? emailError = _validateEmail(_emailController.text.trim());
    String? passwordError = _validatePassword(_passwordController.text.trim());

    if (emailError != null) {
      CustomValidationPopup.show(context, emailError);
      return;
    }

    if (passwordError != null) {
      CustomValidationPopup.show(context, passwordError);
      return;
    }

    // show loading circle
    showDialog(
      context: context,
      builder:
          (context) => const Center(
            child: CircularProgressIndicator(color: Color(0xFF38B6FF)),
          ),
    );

    // make sure passwords match
    if (_passwordController.text != _confirmpasswordController.text) {
      Navigator.pop(context); // close loading dialog
      CustomValidationPopup.show(context, "Passwords don't match!");
      return; // exit function
    }

    try {
      // Create user
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      // Ensure userCredential is not null
      if (userCredential.user != null) {
        // Save user details in Firestore
        await saveUserData(
          userCredential.user!.uid,
          _nameController.text,
          _emailController.text,
        );
      }

      Navigator.pop(context); // close loading dialog
      context.go('/home'); // navigate to home page
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // close loading dialog
      // Format Firebase error messages to be more user-friendly
      String errorMessage = _getReadableErrorMessage(e.code);
      CustomValidationPopup.show(context, errorMessage);
    }
  }

  // Helper method to convert Firebase error codes to user-friendly messages
  String _getReadableErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        return 'This email is already registered. Please use a different email or login.';
      case 'invalid-email':
        return 'The email address is not valid. Please check and try again.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled. Please contact support.';
      case 'weak-password':
        return 'The password is too weak. Please choose a stronger password.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection and try again.';
      default:
        return 'An error occurred during registration: $errorCode';
    }
  }

  Future<void> saveUserData(String uid, String name, String email) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'phoneNumber': '', // Placeholder
        'profileImageUrl': '', // Placeholder for profile image URL
      });
    } catch (e) {
      print("Error saving user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F9),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              context.go('/login');
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Register Account",
                style: GoogleFonts.raleway(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Center(
              child: Text(
                "Fill your details or continue with \n social media",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF707B81),
                ),
              ),
            ),
            SizedBox(height: 40.h),
            CustomTextfield(
              hint: "Enter your name",
              controller: _nameController,
            ),
            SizedBox(height: 20.h),
            CustomTextfield(
              hint: "Enter your email address",
              controller: _emailController,
            ),
            SizedBox(height: 20.h),
            CustomTextfield(
              hint: "Enter your password",
              isPassword: true,
              controller: _passwordController,
            ),
            SizedBox(height: 5.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                "Password must have at least 8 characters, one uppercase letter, one lowercase letter, one number, and one special character",
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: const Color(0xFF707B81),
                ),
              ),
            ),
            SizedBox(height: 15.h),
            CustomTextfield(
              hint: "Re - enter your password",
              isPassword: true,
              controller: _confirmpasswordController,
            ),
            SizedBox(height: 40.h),
            Center(
              child: CustomButton(
                name: "Sign Up",
                textColor: Colors.white,
                onTap: registerUser,
                color: const Color(0xFF38B6FF),
              ),
            ),
            SizedBox(height: 20.h),
            Center(
              child: CustomButton(
                image: Image.asset(
                  'assets/images/google.png',
                  width: 24.w,
                  height: 24.h,
                ),
                name: "Sign In With Google",
                textColor: const Color(0xFF2B2B2B),
                onTap: () {},
                color: const Color(0xFFF7F7F9),
              ),
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.only(left: 70.0.w),
              child: Row(
                children: [
                  Text(
                    'Already Have An Account?',
                    style: GoogleFonts.raleway(
                      fontSize: 15.sp,
                      color: const Color(0xFF6A6A6A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 5.h),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Text(
                      'Log In',
                      style: GoogleFonts.raleway(
                        fontSize: 15.sp,
                        color: const Color(0xFF1A1D1E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
