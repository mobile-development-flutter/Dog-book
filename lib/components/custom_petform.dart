// components/custom_petform.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PetRegistrationForm extends StatefulWidget {
  final Function() onPetAdded;

  const PetRegistrationForm({super.key, required this.onPetAdded});

  @override
  State<PetRegistrationForm> createState() => _PetRegistrationFormState();
}

class _PetRegistrationFormState extends State<PetRegistrationForm> {
  String? selectedType;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController breedController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController colorController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    breedController.dispose();
    dobController.dispose();
    colorController.dispose();
    super.dispose();
  }

  Future<void> _registerPet() async {
    if (selectedType != null &&
        nameController.text.isNotEmpty &&
        breedController.text.isNotEmpty &&
        dobController.text.isNotEmpty &&
        colorController.text.isNotEmpty) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('pets').add({
          'ownerId': user.uid,
          'type': selectedType,
          'name': nameController.text,
          'breed': breedController.text,
          'dob': dobController.text,
          'color': colorController.text,
          'createdAt': Timestamp.now(),
        });
        widget.onPetAdded();
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Register Your Pet",
                style: GoogleFonts.poppins(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2B2B2B),
                ),
              ),
              SizedBox(height: 20.h),
              _buildTypeDropdown(),
              SizedBox(height: 15.h),
              _buildTextField(controller: nameController, label: 'Name'),
              SizedBox(height: 15.h),
              _buildTextField(controller: breedController, label: 'Breed'),
              SizedBox(height: 15.h),
              _buildDateOfBirthField(),
              SizedBox(height: 15.h),
              _buildTextField(controller: colorController, label: 'Color'),
              SizedBox(height: 25.h),
              _buildRegisterButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: 'Pet Type',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF38B6FF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF38B6FF), width: 2),
        ),
      ),
      value: selectedType,
      items: ['Dog', 'Cat', 'Bird'].map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedType = value;
        });
      },
    );
  }

  Widget _buildDateOfBirthField() {
    return TextField(
      controller: dobController,
      readOnly: true,
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFF38B6FF),
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                ), dialogTheme: DialogThemeData(backgroundColor: Colors.white),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          dobController.text = DateFormat('yyyy-MM-dd').format(picked);
        }
      },
      decoration: InputDecoration(
        labelText: "Date of Birth",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF38B6FF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF38B6FF), width: 2),
        ),
        suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF38B6FF)),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
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
      ),
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF38B6FF),
        minimumSize: Size(double.infinity, 50.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: _registerPet,
      child: Text(
        "Register",
        style: GoogleFonts.poppins(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}