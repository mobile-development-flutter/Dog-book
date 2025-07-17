// components/custom_textfield.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextfield extends StatefulWidget {
  final String hint;
  final bool isPassword;
  final bool enabled;
  final TextEditingController? controller;

  const CustomTextfield({
    super.key,
    required this.hint,
    this.isPassword = false,
    required this.controller,
    this.enabled = true,
  });

  @override
  State<CustomTextfield> createState() => _CustomTextfieldState();
}

class _CustomTextfieldState extends State<CustomTextfield> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 20.0.w, left: 15.w),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.isPassword ? _obscureText : false,
        enabled: widget.enabled, // Disable or enable the text field
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: GoogleFonts.poppins(
            fontSize: 15.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFB5B5B5),
          ),
          contentPadding:
              EdgeInsets.symmetric(vertical: 15.h, horizontal: 10.w),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: widget.enabled
              ? Colors.white
              : Colors.white, // Change background color when disabled
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFFB5B5B5),
                  ),
                  onPressed: widget.enabled
                      ? () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        }
                      : null,
                )
              : null,
        ),
        style: GoogleFonts.poppins(
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF2B2B2B),
        ),
      ),
    );
  }
}
