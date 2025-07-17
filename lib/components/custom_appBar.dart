// components/custom_appBar.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData? leftIcon;
  final Function()? onLeftIconPressed;
  final Widget? rightWidget;
  final Function()? onRightIconPressed;
  final Color backgroundColor;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.leftIcon,
    this.onLeftIconPressed,
    this.rightWidget,
    this.onRightIconPressed,
    this.backgroundColor = const Color(0xFFF7F7F9),
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leftIcon != null
          ? Container(
              margin: EdgeInsets.only(left: 5.0),
              width: 45.0.w,
              height: 45.0.h,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.0),
                  color: Colors.white),
              child: IconButton(
                icon: Icon(leftIcon, color: Colors.black, size: 24.0.sp),
                onPressed: onLeftIconPressed,
              ),
            )
          : null,
      title: Text(title,
          style: GoogleFonts.raleway(
            textStyle: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black),
          )),
      actions: [
        if (rightWidget != null)
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: rightWidget is Icon || rightWidget is IconButton
                ? Container(
                    width: 45.0,
                    height: 45.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Colors.white),
                    child: rightWidget,
                  )
                : rightWidget!,
          ),
      ],
      backgroundColor: backgroundColor,
      iconTheme: const IconThemeData(color: Colors.black, size: 25),
    );
  }
}
