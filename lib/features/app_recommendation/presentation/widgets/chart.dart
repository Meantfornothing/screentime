import 'package:flutter/material.dart';

/// Placeholder for the complex usage chart visualization
class PlaceholderChart extends StatelessWidget {
  const PlaceholderChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFC7D3C6), // Light background color for the image
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          painter: AbstractShapePainter(),
          child: Container(),
        ),
      ),
    );
  }
}

/// Custom painter to replicate the abstract shape design (Not a widget, but a helper)
class AbstractShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Define colors from the mock-up
    final paintBlue = Paint()..color = const Color(0xFF86A5A8);
    final paintGreen = Paint()..color = const Color(0xFF90C290);
    final paintRed = Paint()..color = const Color(0xFFC98484);
    final paintCircle = Paint()..color = const Color(0xFFD4AF98);

    // Draw the main shapes
    canvas.drawRect(Rect.fromLTWH(0, 0, w * 0.55, h), paintBlue);
    canvas.drawPath(Path()
      ..moveTo(w * 0.55, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.6)
      ..lineTo(w * 0.55, h * 0.45)
      ..close(), paintGreen);
    canvas.drawPath(Path()
      ..moveTo(w * 0.4, h * 0.5)
      ..lineTo(w, h * 0.6)
      ..lineTo(w, h)
      ..lineTo(w * 0.5, h)
      ..close(), paintRed);
    canvas.drawCircle(Offset(w * 0.55, h * 0.45), h * 0.25, paintCircle);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}