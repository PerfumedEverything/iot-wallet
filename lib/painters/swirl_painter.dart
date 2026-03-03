import 'package:flutter/material.dart';

class SwirlPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Path path = Path();
    path.moveTo(size.width / 2, 0);
    path.quadraticBezierTo(
      size.width,
      size.height * 0.25,
      size.width * 0.7,
      size.height * 0.5,
    );
    path.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.75,
      0,
      size.height * 0.9,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(SwirlPainter oldDelegate) => false;
}
