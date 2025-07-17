import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class AddVaccineForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;
  final String petName;

  const AddVaccineForm({
    super.key,
    required this.onSubmit,
    required this.petName,
  });

  @override
  State<AddVaccineForm> createState() => _AddVaccineFormState();
}

class _AddVaccineFormState extends State<AddVaccineForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _vaccineController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _vetController = TextEditingController();
  final TextEditingController _nextDateController = TextEditingController();
  String? _selectedStatus = 'Completed';
  File? _vaccineImage;
  bool _isUploading = false;

  @override
  void dispose() {
    _vaccineController.dispose();
    _dateController.dispose();
    _vetController.dispose();
    _nextDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF38B6FF),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(date);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _vaccineImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_vaccineImage == null) return null;

    try {
      setState(() {
        _isUploading = true;
      });

      final fileName =
          '${widget.petName}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = FirebaseStorage.instance.ref().child(
        'vaccine_images/$fileName',
      );
      final uploadTask = storageRef.putFile(_vaccineImage!);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
      return null;
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final imageUrl = await _uploadImage();

      widget.onSubmit({
        'petName': widget.petName,
        'vaccine': _vaccineController.text,
        'vaccinatedDate': _dateController.text,
        'vet': _vetController.text,
        'status': _selectedStatus!,
        'nextVaccinationDate':
            _nextDateController.text.isNotEmpty
                ? _nextDateController.text
                : null,
        'imageUrl': imageUrl,
        'createdAt': DateTime.now().toIso8601String(),
      });
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Add Vaccine Record ",
              style: GoogleFonts.poppins(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2B2B2B),
              ),
            ),
            SizedBox(height: 20.h),

            // Vaccine Type
            TextFormField(
              controller: _vaccineController,
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              decoration: _inputDecoration('Vaccine Name'),
            ),
            SizedBox(height: 15.h),

            // Vaccinated Date
            TextFormField(
              controller: _dateController,
              readOnly: true,
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              decoration: _inputDecoration('Vaccination Date').copyWith(
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.calendar_today,
                    color: Color(0xFF38B6FF),
                  ),
                  onPressed: () => _selectDate(_dateController),
                ),
              ),
              onTap: () => _selectDate(_dateController),
            ),
            SizedBox(height: 15.h),

            // Veterinary Surgeon
            TextFormField(
              controller: _vetController,
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              decoration: _inputDecoration('Veterinary Surgeon'),
            ),
            SizedBox(height: 15.h),

            // Status Dropdown
            DropdownButtonFormField<String>(
              decoration: _inputDecoration('Status'),
              value: _selectedStatus,
              items:
                  ['Completed', 'Scheduled', 'Pending']
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ),
                      )
                      .toList(),
              onChanged: (value) => setState(() => _selectedStatus = value),
            ),
            SizedBox(height: 15.h),

            // Next Vaccination Date (optional)
            TextFormField(
              controller: _nextDateController,
              readOnly: true,
              decoration: _inputDecoration(
                'Next Vaccination Date (optional)',
              ).copyWith(
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.calendar_today,
                    color: Color(0xFF38B6FF),
                  ),
                  onPressed: () => _selectDate(_nextDateController),
                ),
              ),
              onTap: () => _selectDate(_nextDateController),
            ),
            SizedBox(height: 15.h),

            // Image Upload Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Vaccination Record Image",
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8.h),
                GestureDetector(
                  onTap: _isUploading ? null : _pickImage,
                  child: Container(
                    height: 150.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF38B6FF),
                        width: 1,
                      ),
                    ),
                    child:
                        _vaccineImage != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _vaccineImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                            : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  size: 40.w,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  "Tap to upload image",
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),
                if (_vaccineImage != null)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(
                      "Image selected",
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: Colors.green,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 25.h),

            // Submit Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF38B6FF),
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isUploading ? null : _submitForm,
              child:
                  _isUploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                        "Save Vaccine Record",
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
            ),
          ],
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
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    );
  }
}
