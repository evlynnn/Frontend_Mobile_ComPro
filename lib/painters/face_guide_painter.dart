import 'package:flutter/material.dart';

class FaceGuidePainter extends CustomPainter {
  final Color color;

  FaceGuidePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final ovalWidth = size.width * 0.7;
    final ovalHeight = size.height * 0.5;

    final rect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: ovalWidth,
      height: ovalHeight,
    );

    // Draw dashed oval
    final path = Path()..addOval(rect);

    // Draw corner guides
    final guideLength = 30.0;
    final guideOffset = 20.0;

    // Top-left
    canvas.drawLine(
      Offset(centerX - ovalWidth / 2 + guideOffset, centerY - ovalHeight / 2),
      Offset(centerX - ovalWidth / 2 + guideOffset + guideLength,
          centerY - ovalHeight / 2),
      paint,
    );
    canvas.drawLine(
      Offset(centerX - ovalWidth / 2, centerY - ovalHeight / 2 + guideOffset),
      Offset(centerX - ovalWidth / 2,
          centerY - ovalHeight / 2 + guideOffset + guideLength),
      paint,
    );

    // Top-right
    canvas.drawLine(
      Offset(centerX + ovalWidth / 2 - guideOffset, centerY - ovalHeight / 2),
      Offset(centerX + ovalWidth / 2 - guideOffset - guideLength,
          centerY - ovalHeight / 2),
      paint,
    );
    canvas.drawLine(
      Offset(centerX + ovalWidth / 2, centerY - ovalHeight / 2 + guideOffset),
      Offset(centerX + ovalWidth / 2,
          centerY - ovalHeight / 2 + guideOffset + guideLength),
      paint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(centerX - ovalWidth / 2 + guideOffset, centerY + ovalHeight / 2),
      Offset(centerX - ovalWidth / 2 + guideOffset + guideLength,
          centerY + ovalHeight / 2),
      paint,
    );
    canvas.drawLine(
      Offset(centerX - ovalWidth / 2, centerY + ovalHeight / 2 - guideOffset),
      Offset(centerX - ovalWidth / 2,
          centerY + ovalHeight / 2 - guideOffset - guideLength),
      paint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(centerX + ovalWidth / 2 - guideOffset, centerY + ovalHeight / 2),
      Offset(centerX + ovalWidth / 2 - guideOffset - guideLength,
          centerY + ovalHeight / 2),
      paint,
    );
    canvas.drawLine(
      Offset(centerX + ovalWidth / 2, centerY + ovalHeight / 2 - guideOffset),
      Offset(centerX + ovalWidth / 2,
          centerY + ovalHeight / 2 - guideOffset - guideLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
