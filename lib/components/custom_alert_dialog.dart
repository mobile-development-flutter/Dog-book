// components/custom_alert_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAlertDialog extends StatelessWidget {
  final String message;
  final bool showImage; 
  final String? imagePath; 

  const CustomAlertDialog({
    Key? key,
    required this.message,
    this.showImage = false, 
    this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[300],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.r), 
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min, 
        children: [
          if (showImage && imagePath != null) ...[
           
            Container(
              width: 40.w, 
              height: 40.w,
              decoration: BoxDecoration(
                color: const Color(0xFF38B6FF), 
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding:
                     EdgeInsets.all(12.0.r), 
                child: Image.asset(
                  imagePath!,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 20.h), 
          ],
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                color: Colors.black, 
                fontSize: 18.sp,
              ),
            ),
          ),
        ],
      ),
      actions: [
        Center(
          child: Container(
            width: 70.w,
            height: 30.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFF38B6FF), 
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context); 
              },
              child: Text(
                'OK',
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500, 
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
