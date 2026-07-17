import 'dart:math';
import 'package:flutter/material.dart';

class CatWidget extends StatelessWidget {
  final String mood;
  final int bondLevel;
  final String? equippedAccessory;
  final double animationValue;

  const CatWidget({
    super.key,
    required this.mood,
    required this.bondLevel,
    this.equippedAccessory,
    this.animationValue = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    // Determine scale based on bondLevel (up to 15% larger at max bond)
    final double scale = 1.0 + (bondLevel / 100) * 0.15;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Glow / Aura (increases in size and brightness with bondLevel)
          _buildGlowRing(scale),
          // Interactive Custom Painted Cat
          Transform.scale(
            scale: scale,
            child: SizedBox(
              width: 200,
              height: 200,
              child: CustomPaint(
                painter: CatPainter(
                  mood: mood,
                  bondLevel: bondLevel,
                  equippedAccessory: equippedAccessory,
                  animationValue: animationValue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowRing(double scale) {
    final double baseRadius = 140.0 + (bondLevel / 100) * 60.0;
    final double opacity = 0.15 + (bondLevel / 100) * 0.25;

    return Container(
      width: baseRadius * scale,
      height: baseRadius * scale,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFFFFB5A7).withValues(alpha: opacity),
            const Color(0xFFFFB5A7).withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}

class CatPainter extends CustomPainter {
  final String mood;
  final int bondLevel;
  final String? equippedAccessory;
  final double animationValue;

  CatPainter({
    required this.mood,
    required this.bondLevel,
    required this.equippedAccessory,
    this.animationValue = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;

    // Paints
    final bodyPaint = Paint()
      ..color = const Color(0xFFFFF9F8)
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = const Color(0xFFE5D5D0).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = const Color(0xFF4A3E3D)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillLinePaint = Paint()
      ..color = const Color(0xFF4A3E3D)
      ..style = PaintingStyle.fill;

    final blushPaint = Paint()
      ..color = const Color(0xFFFFB5A7).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    // 1. Draw Tail
    _drawTail(canvas, cx, cy, linePaint, bodyPaint);

    // 2. Draw Body
    _drawBody(canvas, cx, cy, bodyPaint, shadowPaint, linePaint);

    // 3. Draw Ears
    _drawEars(canvas, cx, cy, bodyPaint, linePaint);

    // 4. Draw Head
    _drawHead(canvas, cx, cy, bodyPaint, linePaint);

    // 5. Draw Face Details based on Mood
    _drawFace(canvas, cx, cy, linePaint, fillLinePaint, blushPaint);

    // 6. Draw Accessories (Layered on top)
    if (equippedAccessory != null) {
      _drawAccessory(canvas, cx, cy, linePaint);
    }

    // 7. Draw Ambient Sparkles at High Bond Levels
    if (bondLevel >= 50) {
      _drawAmbientSparkles(canvas, cx, cy);
    }
  }

  void _drawAmbientSparkles(Canvas canvas, double cx, double cy) {
    final Paint sparklePaint = Paint()
      ..color = const Color(0xFFFFD166).withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    // Pulsating size using animationValue
    final double pulse1 = 4.0 + sin(animationValue * pi * 2) * 2.0;
    final double pulse2 = 4.0 + cos(animationValue * pi * 2) * 2.0;

    // Position 1: Top Left
    _drawStar(canvas, cx - 65, cy - 65, pulse1, sparklePaint);

    // Position 2: Top Right
    _drawStar(canvas, cx + 65, cy - 65, pulse2, sparklePaint);

    // If bond level is even higher, add more sparkles
    if (bondLevel >= 75) {
      final Paint pinkSparkle = Paint()
        ..color = const Color(0xFFFFB5A7).withValues(alpha: 0.7)
        ..style = PaintingStyle.fill;
      _drawStar(canvas, cx - 75, cy + 30, pulse2, pinkSparkle);
      _drawStar(canvas, cx + 75, cy + 30, pulse1, pinkSparkle);
    }
  }

  void _drawTail(Canvas canvas, double cx, double cy, Paint linePaint, Paint bodyPaint) {
    final path = Path();
    path.moveTo(cx + 40, cy + 50);
    
    // Smooth wag/flick using animationValue
    final tailOffset = sin(animationValue * pi * 4) * 8.0;

    // Draw curved tail with animated flick
    if (mood == 'playful') {
      path.quadraticBezierTo(cx + 90 + tailOffset, cy + 10, cx + 80 + tailOffset, cy - 40);
      path.quadraticBezierTo(cx + 65, cy - 50, cx + 70, cy - 20);
    } else {
      path.quadraticBezierTo(cx + 80 + tailOffset, cy + 40, cx + 75 + tailOffset / 2, cy + 10);
      path.quadraticBezierTo(cx + 65, cy, cx + 60, cy + 20);
    }
    path.quadraticBezierTo(cx + 50, cy + 45, cx + 40, cy + 50);
    canvas.drawPath(path, bodyPaint);
    canvas.drawPath(path, linePaint);
  }

  void _drawBody(Canvas canvas, double cx, double cy, Paint bodyPaint, Paint shadowPaint, Paint linePaint) {
    // Shadow under the body
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 75), width: 130, height: 18),
      shadowPaint,
    );

    // Body oval
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 45), width: 110, height: 75),
      bodyPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 45), width: 110, height: 75),
      linePaint,
    );

    // Draw little paws
    // Left Paw
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 25, cy + 75), width: 22, height: 16),
      bodyPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 25, cy + 75), width: 22, height: 16),
      linePaint,
    );
    // Right Paw
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 25, cy + 75), width: 22, height: 16),
      bodyPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 25, cy + 75), width: 22, height: 16),
      linePaint,
    );
  }

  void _drawEars(Canvas canvas, double cx, double cy, Paint bodyPaint, Paint linePaint) {
    final innerEarPaint = Paint()
      ..color = const Color(0xFFFCD5CE)
      ..style = PaintingStyle.fill;

    // Left Ear
    final leftEarPath = Path();
    leftEarPath.moveTo(cx - 40, cy - 25);
    leftEarPath.lineTo(cx - 50, cy - 65);
    leftEarPath.lineTo(cx - 15, cy - 40);
    leftEarPath.close();
    canvas.drawPath(leftEarPath, bodyPaint);
    canvas.drawPath(leftEarPath, linePaint);

    final leftInnerEar = Path();
    leftInnerEar.moveTo(cx - 36, cy - 28);
    leftInnerEar.lineTo(cx - 43, cy - 56);
    leftInnerEar.lineTo(cx - 19, cy - 38);
    leftInnerEar.close();
    canvas.drawPath(leftInnerEar, innerEarPaint);

    // Right Ear
    final rightEarPath = Path();
    rightEarPath.moveTo(cx + 40, cy - 25);
    rightEarPath.lineTo(cx + 50, cy - 65);
    rightEarPath.lineTo(cx + 15, cy - 40);
    rightEarPath.close();
    canvas.drawPath(rightEarPath, bodyPaint);
    canvas.drawPath(rightEarPath, linePaint);

    final rightInnerEar = Path();
    rightInnerEar.moveTo(cx + 36, cy - 28);
    rightInnerEar.lineTo(cx + 43, cy - 56);
    rightInnerEar.lineTo(cx + 19, cy - 38);
    rightInnerEar.close();
    canvas.drawPath(rightInnerEar, innerEarPaint);
  }

  void _drawHead(Canvas canvas, double cx, double cy, Paint bodyPaint, Paint linePaint) {
    // Face circle
    canvas.drawCircle(Offset(cx, cy - 10), 52, bodyPaint);
    canvas.drawCircle(Offset(cx, cy - 10), 52, linePaint);
  }

  void _drawFace(Canvas canvas, double cx, double cy, Paint linePaint, Paint fillLinePaint, Paint blushPaint) {
    // Whiskers
    // Left Whiskers
    canvas.drawLine(Offset(cx - 48, cy - 8), Offset(cx - 72, cy - 12), linePaint);
    canvas.drawLine(Offset(cx - 48, cy - 2), Offset(cx - 75, cy - 2), linePaint);
    // Right Whiskers
    canvas.drawLine(Offset(cx + 48, cy - 8), Offset(cx + 72, cy - 12), linePaint);
    canvas.drawLine(Offset(cx + 48, cy - 2), Offset(cx + 75, cy - 2), linePaint);

    // Nose
    final nosePath = Path();
    nosePath.moveTo(cx - 4, cy - 8);
    nosePath.lineTo(cx + 4, cy - 8);
    nosePath.lineTo(cx, cy - 4);
    nosePath.close();
    canvas.drawPath(nosePath, fillLinePaint);

    // Mouth
    canvas.drawArc(
      Rect.fromLTWH(cx - 8, cy - 6, 8, 8),
      0,
      pi,
      false,
      linePaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(cx, cy - 6, 8, 8),
      0,
      pi,
      false,
      linePaint,
    );

    // Blush (always on playful and affectionate, sometimes on content)
    if (mood == 'affectionate' || mood == 'playful' || mood == 'content') {
      canvas.drawCircle(Offset(cx - 32, cy - 1), 6, blushPaint);
      canvas.drawCircle(Offset(cx + 32, cy - 1), 6, blushPaint);
    }

    // Eyes depending on Mood (Blinks periodically on any mood except sleepy/affectionate)
    final isBlinking = animationValue > 0.48 && animationValue < 0.52;

    if (isBlinking && mood != 'sleepy' && mood != 'affectionate') {
      // Closed arcs downwards (blink)
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx - 22, cy - 18), width: 14, height: 10),
        0,
        pi,
        false,
        linePaint,
      );
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx + 22, cy - 18), width: 14, height: 10),
        0,
        pi,
        false,
        linePaint,
      );
    } else if (mood == 'sleepy') {
      // Closed arcs downwards
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx - 22, cy - 18), width: 14, height: 10),
        0,
        pi,
        false,
        linePaint,
      );
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx + 22, cy - 18), width: 14, height: 10),
        0,
        pi,
        false,
        linePaint,
      );
    } else if (mood == 'content') {
      // Smiling closed arcs upwards
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx - 22, cy - 14), width: 14, height: 10),
        pi,
        pi,
        false,
        linePaint,
      );
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx + 22, cy - 14), width: 14, height: 10),
        pi,
        pi,
        false,
        linePaint,
      );
    } else if (mood == 'playful') {
      // Wide open eyes with large pupil
      canvas.drawCircle(Offset(cx - 22, cy - 16), 7, fillLinePaint);
      canvas.drawCircle(Offset(cx + 22, cy - 16), 7, fillLinePaint);
      // Highlights
      final highlightPaint = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(cx - 24, cy - 18), 2.2, highlightPaint);
      canvas.drawCircle(Offset(cx + 20, cy - 18), 2.2, highlightPaint);
    } else if (mood == 'affectionate') {
      // Heart Eyes!
      _drawHeart(canvas, cx - 22, cy - 18, 14);
      _drawHeart(canvas, cx + 22, cy - 18, 14);
    }
  }

  void _drawHeart(Canvas canvas, double x, double y, double size) {
    final heartPaint = Paint()
      ..color = const Color(0xFFFF7B7B)
      ..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(x, y + size / 4);
    path.cubicTo(x + size / 2, y - size / 3, x + size, y + size / 3, x, y + size * 0.95);
    path.cubicTo(x - size, y + size / 3, x - size / 2, y - size / 3, x, y + size / 4);
    canvas.drawPath(path, heartPaint);
  }

  void _drawAccessory(Canvas canvas, double cx, double cy, Paint linePaint) {
    if (equippedAccessory == 'Red Collar') {
      final collarPaint = Paint()
        ..color = const Color(0xFFFF6B6B)
        ..style = PaintingStyle.fill;
      // Collar curved line around neck (bottom of head)
      final collarPath = Path();
      collarPath.moveTo(cx - 36, cy + 30);
      collarPath.quadraticBezierTo(cx, cy + 42, cx + 36, cy + 30);
      collarPath.quadraticBezierTo(cx, cy + 48, cx - 36, cy + 30);
      canvas.drawPath(collarPath, collarPaint);
      canvas.drawPath(collarPath, linePaint);
    } 
    
    else if (equippedAccessory == 'Yellow Bell') {
      final collarPaint = Paint()
        ..color = const Color(0xFFFF6B6B)
        ..style = PaintingStyle.fill;
      final bellPaint = Paint()
        ..color = const Color(0xFFFFD166)
        ..style = PaintingStyle.fill;

      // Collar
      final collarPath = Path();
      collarPath.moveTo(cx - 36, cy + 30);
      collarPath.quadraticBezierTo(cx, cy + 42, cx + 36, cy + 30);
      collarPath.quadraticBezierTo(cx, cy + 48, cx - 36, cy + 30);
      canvas.drawPath(collarPath, collarPaint);
      canvas.drawPath(collarPath, linePaint);

      // Bell
      canvas.drawCircle(Offset(cx, cy + 44), 9, bellPaint);
      canvas.drawCircle(Offset(cx, cy + 44), 9, linePaint);
      // Small details on bell
      canvas.drawCircle(Offset(cx, cy + 44), 2, linePaint);
    } 
    
    else if (equippedAccessory == 'Pink Bow') {
      final bowPaint = Paint()
        ..color = const Color(0xFFFFB5A7)
        ..style = PaintingStyle.fill;

      // Draw pink bow near left ear base
      final bx = cx - 30;
      final by = cy - 35;
      
      final bowPath = Path();
      bowPath.moveTo(bx, by);
      bowPath.lineTo(bx - 12, by - 12);
      bowPath.lineTo(bx - 12, by + 12);
      bowPath.close();
      
      bowPath.moveTo(bx, by);
      bowPath.lineTo(bx + 12, by - 12);
      bowPath.lineTo(bx + 12, by + 12);
      bowPath.close();

      canvas.drawPath(bowPath, bowPaint);
      canvas.drawPath(bowPath, linePaint);
      
      canvas.drawCircle(Offset(bx, by), 5, bowPaint);
      canvas.drawCircle(Offset(bx, by), 5, linePaint);
    } 
    
    else if (equippedAccessory == 'Wizard Hat') {
      final hatPaint = Paint()
        ..color = const Color(0xFFBDB2FF)
        ..style = PaintingStyle.fill;
      final starPaint = Paint()
        ..color = const Color(0xFFFFD166)
        ..style = PaintingStyle.fill;

      // Draw purple cone hat on top of head
      final hatPath = Path();
      hatPath.moveTo(cx - 30, cy - 58);
      hatPath.lineTo(cx, cy - 110); // tip
      hatPath.lineTo(cx + 30, cy - 58);
      hatPath.quadraticBezierTo(cx, cy - 50, cx - 30, cy - 58);
      hatPath.close();

      canvas.drawPath(hatPath, hatPaint);
      canvas.drawPath(hatPath, linePaint);

      // Hat brim
      final brimPath = Path();
      brimPath.moveTo(cx - 40, cy - 56);
      brimPath.quadraticBezierTo(cx, cy - 50, cx + 40, cy - 56);
      brimPath.quadraticBezierTo(cx, cy - 44, cx - 40, cy - 56);
      canvas.drawPath(brimPath, hatPaint);
      canvas.drawPath(brimPath, linePaint);

      // Small star on the hat
      _drawStar(canvas, cx, cy - 80, 6, starPaint);
    } 
    
    else if (equippedAccessory == 'Crown') {
      final crownPaint = Paint()
        ..color = const Color(0xFFFFD166)
        ..style = PaintingStyle.fill;

      // Golden crown on top of head
      final crownPath = Path();
      crownPath.moveTo(cx - 24, cy - 58);
      crownPath.lineTo(cx - 32, cy - 85);
      crownPath.lineTo(cx - 10, cy - 70);
      crownPath.lineTo(cx, cy - 92); // center peak
      crownPath.lineTo(cx + 10, cy - 70);
      crownPath.lineTo(cx + 32, cy - 85);
      crownPath.lineTo(cx + 24, cy - 58);
      crownPath.close();

      canvas.drawPath(crownPath, crownPaint);
      canvas.drawPath(crownPath, linePaint);

      // Small gems on crown peaks
      canvas.drawCircle(Offset(cx - 32, cy - 85), 2.5, Paint()..color = const Color(0xFFFF6B6B));
      canvas.drawCircle(Offset(cx, cy - 92), 2.5, Paint()..color = const Color(0xFFFF6B6B));
      canvas.drawCircle(Offset(cx + 32, cy - 85), 2.5, Paint()..color = const Color(0xFFFF6B6B));
    }
  }

  void _drawStar(Canvas canvas, double cx, double cy, double radius, Paint paint) {
    final path = Path();
    final double step = pi / 5;
    for (int i = 0; i < 10; i++) {
      final double r = (i % 2 == 0) ? radius : radius / 2.2;
      final double angle = i * step - pi / 2;
      final double x = cx + r * cos(angle);
      final double y = cy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CatPainter oldDelegate) {
    return oldDelegate.mood != mood ||
        oldDelegate.bondLevel != bondLevel ||
        oldDelegate.equippedAccessory != equippedAccessory ||
        oldDelegate.animationValue != animationValue;
  }
}
