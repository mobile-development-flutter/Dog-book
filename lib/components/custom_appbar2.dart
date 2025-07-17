// components/custom_appbar2.dart
import 'package:dog_book/screens/home_screens/next_vaccine_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar2 extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onNotificationPressed;

  const CustomAppBar2({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onNotificationPressed,
  });

  @override
  Size get preferredSize => Size.fromHeight(140.h); // <-- Increase height here

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _CurvedAppBarClipper(),
      child: Container(
        height: preferredSize.height, // <-- Important: set height!
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF38B6FF), Color(0xFF2AA3E6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.only(
            top: 10.h,
            left: 16.w,
            right: 16.w,
          ), // added side paddings too
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              showBackButton
                  ? IconButton(
                    icon: Icon(Icons.menu, color: Colors.white, size: 25.sp),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  )
                  : SizedBox(width: 56.w), // to keep spacing
              Expanded(
                child: Center(
                  child: Text(
                    title,
                    style: GoogleFonts.raleway(
                      textStyle: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 2,
                            color: Colors.black.withOpacity(0.2),
                            offset: const Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(FeatherIcons.bell, color: Colors.white, size: 25.sp),
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                PetsListScreen(isNotificationEnabled: true),
                      ),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurvedAppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60); // left side going deeper
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 20, // make the curve bulge a little lower (20 more)
      size.width,
      size.height - 60, // right side going deeper
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
