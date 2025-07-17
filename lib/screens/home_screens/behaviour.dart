// screens/behaviour.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class PetBehaviorDialog extends StatefulWidget {
  const PetBehaviorDialog({Key? key}) : super(key: key);

  @override
  State<PetBehaviorDialog> createState() => _PetBehaviorDialogState();
}

class _PetBehaviorDialogState extends State<PetBehaviorDialog> {
  String? selectedPetType;
  String? selectedBehavior;
  String resultMessage = '';
  bool hasCheckedBehavior = false;

  final Map<String, Map<String, String>> behaviorData = {
    'Dog': {
      'Wagging tail': 'Your dog is happy now, dog loves you',
      'Red eyes': 'Your dog is angry now, stay away',
      'Laying down': 'Your dog is in sad mood',
      'Hiding': 'Your dog is stressed now',
    },
    'Cat': {
      'Purring': 'Your cat is content and relaxed',
      'Hissing': 'Your cat is annoyed or frightened',
      'Arched back': 'Your cat is scared or aggressive',
      'Kneading': 'Your cat is happy and comfortable',
    },
    'Parrot': {
      'Singing': 'Your parrot is happy and healthy',
      'Feather plucking': 'Your parrot is stressed or bored',
      'Biting': 'Your parrot is scared or territorial',
      'Head bobbing': 'Your parrot is excited or wants attention',
    },
  };

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Pet Behavior Analysis",
                style: GoogleFonts.poppins(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2B2B2B),
                ),
              ),
              SizedBox(height: 20.h),

              // Pet Type Dropdown
              DropdownButtonFormField<String>(
                decoration: _inputDecoration('Pet Type'),
                value: selectedPetType,
                items: ['Dog', 'Cat', 'Parrot'].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: hasCheckedBehavior 
                    ? null // Disable if behavior has been checked
                    : (value) {
                        setState(() {
                          selectedPetType = value;
                          selectedBehavior = null;
                          resultMessage = '';
                        });
                      },
              ),
              SizedBox(height: 15.h),

              // Behavior Dropdown
              if (selectedPetType != null && !hasCheckedBehavior)
                DropdownButtonFormField<String>(
                  decoration: _inputDecoration('Behavior'),
                  value: selectedBehavior,
                  items: behaviorData[selectedPetType]!.keys.map((behavior) {
                    return DropdownMenuItem(
                      value: behavior,
                      child: Text(behavior),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedBehavior = value;
                      resultMessage = '';
                    });
                  },
                ),
              SizedBox(height: 15.h),

              // Check Button (only shown if not checked yet)
              if (!hasCheckedBehavior && selectedBehavior != null)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38B6FF),
                    minimumSize: Size(double.infinity, 50.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (selectedPetType != null && selectedBehavior != null) {
                      setState(() {
                        resultMessage = behaviorData[selectedPetType]![selectedBehavior]!;
                        hasCheckedBehavior = true;
                      });
                    }
                  },
                  child: Text(
                    "Check Behavior",
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),

              // Result Message
              if (resultMessage.isNotEmpty)
                Column(
                  children: [
                    SizedBox(height: 15.h),
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        resultMessage,
                        style: GoogleFonts.raleway(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF2B2B2B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 15.h),
                    // OK Button to close dialog
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF38B6FF),
                        minimumSize: Size(double.infinity, 50.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        "OK",
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF38B6FF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF38B6FF), width: 2),
      ),
    );
  }
  
}