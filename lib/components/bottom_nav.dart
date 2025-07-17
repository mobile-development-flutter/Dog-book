// components/bottom_nav.dart
import 'package:flutter/material.dart';


class BottomNavPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    Path path = Path();

    path.moveTo(0, 0);

    path.quadraticBezierTo(size.width * 0.10, 30, size.width * 0.35, 20);

    path.quadraticBezierTo(size.width * 0.5, 90, size.width * 0.65, 20);

    path.quadraticBezierTo(size.width * 0.8, 30, size.width, 0);

    path.lineTo(size.width, size.height + 50);
    path.lineTo(0, size.height + 50);

    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
