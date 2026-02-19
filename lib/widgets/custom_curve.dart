import 'package:flutter/material.dart';

class SCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, 0);

    // First quadratic Bézier curve to create the first bend
    path.quadraticBezierTo(
      0,
      size.height * 0.3,
      size.width * 0.2,
      size.height * 0.3,
    );

    // Line to the point where the second curve starts
    path.lineTo(size.width * .8, size.height * 0.3);

    // Second quadratic Bézier curve to create the second bend
    path.quadraticBezierTo(
      size.width,
      size.height * 0.3,

      size.width,
      size.height * 0.6,
    );

    // Line to the bottom-right corner
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    // Close the path
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
