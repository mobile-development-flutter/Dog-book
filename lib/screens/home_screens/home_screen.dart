// screens/home_screens/home_screen.dart
import 'package:dog_book/components/bottom_nav_two.dart';
import 'package:dog_book/components/custom_appbar2.dart';
import 'package:dog_book/components/custom_drawer.dart';
import 'package:dog_book/components/custom_petcard.dart';
import 'package:dog_book/components/custom_petform.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<Map<String, dynamic>> pets = [];
  final PageController _pageController = PageController(viewportFraction: 0.75);

  @override
  void initState() {
    super.initState();
    fetchPets();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> fetchPets() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('pets')
              .where('ownerId', isEqualTo: user.uid)
              .get();

      setState(() {
        pets =
            snapshot.docs.map((doc) {
              final data =
                  doc.data() as Map<String, dynamic>?; // Add null check
              return {
                ...?data, // Null-aware spread operator
                'id': doc.id,
                'name': data?['name'] ?? 'Unnamed Pet', // Safe null access
              };
            }).toList();
      });
    }
  }

  void showAddPetForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => PetRegistrationForm(onPetAdded: fetchPets),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar2(
        title: "Pet Plus",
        showBackButton: true,
        onNotificationPressed: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => const NotificationScreen()),
          // );
        },
      ),
      drawer: const CustomDrawer(),
      backgroundColor: const Color(0xFFF7F7F9),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(right: 220.0.w, top: 16.h),
            child: Text(
              "Your Pets",
              style: GoogleFonts.poppins(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2B2B2B),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child:
                pets.isEmpty
                    ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.pets, size: 48.w, color: Colors.grey[400]),
                        SizedBox(height: 16.h),
                        Text(
                          "No pets yet",
                          style: GoogleFonts.poppins(fontSize: 16.sp),
                        ),
                        TextButton(
                          onPressed: () => showAddPetForm(context),
                          child: Text("Add your first pet"),
                        ),
                      ],
                    )
                    : SizedBox(
                      height:
                          MediaQuery.of(context).size.height *
                          0.6, // 60% of screen
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: pets.length,
                        itemBuilder: (context, index) {
                          return PetCard(pet: pets[index]);
                        },
                      ),
                    ),
          ),
          if (pets.isNotEmpty)
            Expanded(
              flex: 1,
              child: SmoothPageIndicator(
                controller: _pageController,
                count: pets.length,
                effect: const ExpandingDotsEffect(
                  activeDotColor: Color(0xFF38B6FF),
                  dotHeight: 10,
                  dotWidth: 10,
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavTwo(
        onPlusPressed: () => showAddPetForm(context),
      ),
    );
  }
}
