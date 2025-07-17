// screens/auth_screens/login_screen.dart
import 'package:dog_book/components/custom_alert_dialog.dart';
import 'package:dog_book/components/custom_button.dart';
import 'package:dog_book/components/custom_textfield.dart';
import 'package:dog_book/screens/auth_screens/forgot_password_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void login() async {
    // show loading circle
    showDialog(
      context: context,
      builder:
          (context) => const Center(
            child: CircularProgressIndicator(color: Color(0xFF38B6FF)),
          ),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // pop loading circle
      if (context.mounted) Navigator.pop(context);

      // Navigate to the home page if credentials are correct
      if (context.mounted) {
        context.go('/home');
      }
    }
    // display any errors
    on FirebaseAuthException catch (error) {
      // pop loading circle
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) {
          return CustomAlertDialog(message: error.code);
        },
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F7F9),
      appBar: AppBar(
        backgroundColor: Color(0xFFF7F7F9),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              context.go('/onboard');
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
              child: Padding(
                padding: EdgeInsets.only(top: 40.0.h),
                child: Text(
                  "Welcome Again",
                  style: GoogleFonts.raleway(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w700,
                  ),
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
            SizedBox(height: 70.h),
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
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.only(left: 220.0.w),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ForgotPasswordScreen(),
                    ),
                  );
                },
                child: Text(
                  "Recovery Password",
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: const Color(0xFF707B81),
                  ),
                ),
              ),
            ),
            SizedBox(height: 50.h),
            Center(
              child: CustomButton(
                name: "Sign In",
                textColor: Colors.white,
                onTap: login,
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
            SizedBox(height: 50.h),
            Padding(
              padding: EdgeInsets.only(left: 80.0.w),
              child: Row(
                children: [
                  Text(
                    'New User?',
                    style: GoogleFonts.raleway(
                      fontSize: 15.sp,
                      color: const Color(0xFF6A6A6A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 5.h),
                  GestureDetector(
                    onTap: () {
                      context.go('/register');
                    },
                    child: Text(
                      'Create Account',
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
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
