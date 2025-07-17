// components/custom_drawer.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dog_book/screens/home_screens/behaviour.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final TextEditingController nameController = TextEditingController();
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
      print("User Data: $userData"); // Debugging line
      if (userData != null) {
        setState(() {
          nameController.text = userData['name'] ?? '';
        });
      }
    }
  }

  Future<void> _saveUserProfile() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'name': nameController.text,
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Profile updated successfully!')));
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

  final myTextStyle = GoogleFonts.poppins(
    textStyle: TextStyle(
      color: Colors.white,
      fontSize: 18.sp,
      fontWeight: FontWeight.w500,
    ),
  );

  void logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      context.go('/Spalsh');
      print('User successfully logged out and navigated to Splash screen');
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.blue,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 20.0.w, top: 20.h),
                  child: Image.asset('assets/images/boy.png'),
                ),
                SizedBox(height: 10.h),
                Text(
                  nameController.text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                  child: const Divider(color: Colors.white, thickness: 2),
                ),
              ],
            ),
            SizedBox(height: 40.h),
            ListTile(
              leading: Padding(
                padding: EdgeInsets.only(left: 15.0.w),
                child: const Icon(
                  Icons.person_outline_outlined,
                  color: Colors.white,
                ),
              ),
              title: Text('Profile', style: myTextStyle),
              onTap: () {
                context.go('/profile');
              },
            ),
            SizedBox(height: 10.h),
            ListTile(
              leading: Padding(
                padding: EdgeInsets.only(left: 15.0.w),
                child: const Icon(Icons.home, color: Colors.white),
              ),
              title: Text('Home', style: myTextStyle),
              onTap: () {
                context.go('/home');
              },
            ),
            SizedBox(height: 10.h),
            ListTile(
              leading: Padding(
                padding: EdgeInsets.only(left: 15.0.w),
                child: const Icon(
                  Icons.shopping_cart_checkout_sharp,
                  color: Colors.white,
                ),
              ),
              title: Text('Shop', style: myTextStyle),
              onTap: () {
                context.go('/shop');
              },
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.only(left: 15.0.w),
              child: ListTile(
                leading: const Icon(Icons.pets, color: Colors.white),
                title: Text('Behaviour', style: myTextStyle),
                onTap: () {
                  _showPetBehaviorDialog(context);
                },
              ),
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.only(left: 15.0.w),
              child: ListTile(
                leading: const Icon(
                  Icons.notifications_none,
                  color: Colors.white,
                ),
                title: Text('Notifications', style: myTextStyle),
                onTap: () {
                  context.go('/notification');
                },
              ),
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.only(left: 15.0.w),
              child: ListTile(
                leading: const Icon(Icons.message, color: Colors.white),
                title: Text('Contact Us', style: myTextStyle),
                onTap: () {
                  context.go('/messages');
                },
              ),
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.only(left: 30.0.w),
              child: const Divider(color: Colors.white, thickness: 2),
            ),
            Padding(
              padding: EdgeInsets.only(top: 120.0.h),
              child: ListTile(
                leading: Padding(
                  padding: EdgeInsets.only(left: 15.0.w),
                  child: const Icon(Icons.logout, color: Colors.white),
                ),
                title: Text('Logout', style: myTextStyle),
                onTap: () {
                  logout(context);
                },
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  void _showPetBehaviorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const PetBehaviorDialog(),
    );
  }
}
