// components/custom_validation_popup.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomValidationPopup {
  // Show validation message with an animated popup
  static void show(BuildContext context, String message) {
    // Dismiss keyboard if it's open
    FocusScope.of(context).unfocus();
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: _ValidationPopupContent(message: message),
        );
      },
    );
  }
}

class _ValidationPopupContent extends StatefulWidget {
  final String message;
  
  const _ValidationPopupContent({required this.message});

  @override
  State<_ValidationPopupContent> createState() => _ValidationPopupContentState();
}

class _ValidationPopupContentState extends State<_ValidationPopupContent> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    
    // Start animation when widget is built
    _animationController.forward();
    
    // Auto-dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF38B6FF).withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error icon with animated background
            Container(
              width: 60.w,
              height: 60.h,
              decoration: BoxDecoration(
                color: const Color(0xFF38B6FF).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.error_outline_rounded,
                  color: const Color(0xFF38B6FF),
                  size: 32.sp,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            
            // Validation title
            Text(
              "Validation Error",
              style: GoogleFonts.raleway(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1D1E),
              ),
            ),
            SizedBox(height: 8.h),
            
            // Error message
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: const Color(0xFF707B81),
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 20.h),
            
            // OK button
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                width: 120.w,
                height: 45.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF38B6FF),
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Center(
                  child: Text(
                    "OK",
                    style: GoogleFonts.raleway(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}