// components/bottom_nav_two.dart
import 'package:dog_book/components/bottom_nav.dart';
import 'package:dog_book/screens/home_screens/behaviour.dart';
import 'package:dog_book/screens/home_screens/next_vaccine_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class BottomNavTwo extends StatefulWidget {
  final VoidCallback? onPlusPressed;
  const BottomNavTwo({super.key, this.onPlusPressed});

  @override
  State<BottomNavTwo> createState() => _BottomNavTwoState();
}

class _BottomNavTwoState extends State<BottomNavTwo> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Stack(
        children: [
          CustomPaint(
            painter: BottomNavPainter(),
            child: Container(height: 80.h),
          ),
          Center(
            heightFactor: 0.5,
            child: FloatingActionButton(
              onPressed: widget.onPlusPressed,
              backgroundColor: Color(0xFF38B6FF),
              child: Icon(FontAwesomeIcons.plus, color: Colors.white),
            ),
          ),
          Positioned(
            bottom: 20.h,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(FeatherIcons.home, color: Colors.black54),
                  onPressed: () {
                    context.go('/home');
                  },
                ),
                IconButton(
                  icon: Icon(FontAwesomeIcons.dog, color: Colors.black54),
                  onPressed: () {
                    _showPetBehaviorDialog(context);
                  },
                ),
                SizedBox(width: 60.w),
                IconButton(
                  icon: Icon(FeatherIcons.bell, color: Colors.black54),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                PetsListScreen(isNotificationEnabled: true),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(FeatherIcons.user, color: Colors.black54),
                  onPressed: () {
                    context.go('/profile');
                  },
                ),
              ],
            ),
          ),
        ],
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
