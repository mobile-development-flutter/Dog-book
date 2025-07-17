// components/custom_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  final String name;
  final VoidCallback onTap;
  final Color color;
  final Color textColor;
  final Image? image;

  const CustomButton({
    super.key,
    required this.name,
    required this.onTap,
    required this.color,
    required this.textColor,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 315.w,
        height: 50.h,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12), color: color),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (image != null) ...[
              image!,
              SizedBox(width: 20.w),
            ],
            Text(
              name,
              style: GoogleFonts.raleway(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
