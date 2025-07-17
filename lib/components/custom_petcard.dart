// components/custom_petcard.dart

// components/custom_petcard.dart
import 'package:dog_book/screens/home_screens/behaviour.dart';
import 'package:dog_book/screens/home_screens/vaccine_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class PetCard extends StatelessWidget {
  final Map<String, dynamic> pet;

  const PetCard({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
      padding: EdgeInsets.all(20.w),
      constraints: BoxConstraints(
        maxHeight: 280.h, // Set maximum height constraint
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(height: 20.h),
          // Name
          Text(
            pet['name'] ?? 'No Name',
            style: GoogleFonts.raleway(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF38B6FF),
            ),
          ),
          const SizedBox(height: 12),

          // Details in a compact format
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Type', pet['type']),
              _buildDetailRow('Breed', pet['breed']),
              _buildDetailRow('Birth Date', pet['dob']),
              _buildDetailRow('Color', pet['color']),
            ],
          ),
          SizedBox(height: 50.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              VaccinationStatusScreen(petId: pet['id']),
                    ),
                  );
                },
                child: RichText(
                  textAlign: TextAlign.center, // Center align the entire text
                  text: TextSpan(
                    style: GoogleFonts.raleway(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    children: [
                      const TextSpan(text: "Check vaccinations status\n"),
                      TextSpan(
                        text: "click here",
                        style: TextStyle(
                          color: const Color(0xFF38B6FF),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              GestureDetector(
                onTap: () {
                  _showPetBehaviorDialog(context);
                },
                child: RichText(
                  textAlign: TextAlign.center, // Center align the entire text
                  text: TextSpan(
                    style: GoogleFonts.raleway(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    children: [
                      const TextSpan(text: "Check Your Pet Behaviour\n"),
                      TextSpan(
                        text: "click here",
                        style: TextStyle(
                          color: const Color(0xFF38B6FF),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.raleway(fontSize: 16.sp),
          children: [
            TextSpan(
              text: '$label:   ',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            TextSpan(
              text: value ?? 'Unknown',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
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
