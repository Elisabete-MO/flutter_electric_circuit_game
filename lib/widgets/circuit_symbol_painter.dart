import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/first_step_component.dart';
import 'burned_effects_painter.dart';

/// Painter que desenha o símbolo esquemático elétrico técnico (IEC / IEEE)
/// de acordo com o componente e seu estado atual (ex: chave aberta/fechada, LED aceso).
class CircuitSymbolPainter extends CustomPainter {
  CircuitSymbolPainter({
    required this.type,
    this.isActive = false,
    this.isBurned = false,
    required this.color,
    this.activeColor = const Color(0xFFFFB300),
    this.strokeWidth = 2.5,
    this.isVertical = false,
    this.value = 10.0,
    this.animationValue = 0.0,
    this.isJunction = false,
    this.isParallel = false,
  });

  final ComponentType type;
  final bool isActive;
  final bool isBurned;
  final Color color;
  final Color activeColor;
  final double strokeWidth;
  final bool isVertical;
  final double value;
  final double animationValue;
  final bool isJunction;
  final bool isParallel;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isBurned ? const Color(0xFFFF3B7F) : (isActive ? activeColor : color)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = isActive ? activeColor.withValues(alpha: 0.2) : Colors.transparent
      ..style = PaintingStyle.fill;

    if (isVertical) {
      canvas.save();
      canvas.translate(size.width / 2, size.height / 2);
      canvas.rotate(math.pi / 2);
      canvas.translate(-size.height / 2, -size.width / 2);
      // Inverte tamanho para o desenho rotacionado
      final rotatedSize = Size(size.height, size.width);
      final cy = rotatedSize.height / 2;
      final cx = rotatedSize.width / 2;
      _drawComponent(canvas, rotatedSize, cx, cy, paint, fillPaint);
      canvas.restore();
    } else {
      final cy = size.height / 2;
      final cx = size.width / 2;
      _drawComponent(canvas, size, cx, cy, paint, fillPaint);
    }

    if (isBurned) {
      drawBurnedSmokeAndEmbers(
        canvas,
        size,
        size.width / 2,
        size.height / 2,
        animationValue,
        isDark: true,
      );
    }
  }

  void _drawComponent(Canvas canvas, Size size, double cx, double cy, Paint paint, Paint fillPaint) {
    switch (type) {
      case ComponentType.battery:
        _drawBattery(canvas, size, cx, cy, paint);
        break;
      case ComponentType.connectingWire:
        _drawConnectingWire(canvas, size, cx, cy, paint);
        break;
      case ComponentType.switchComponent:
        _drawSwitch(canvas, size, cx, cy, paint);
        break;
      case ComponentType.bulb:
        _drawBulb(canvas, size, cx, cy, paint, fillPaint);
        break;
      case ComponentType.resistor:
        _drawResistor(canvas, size, cx, cy, paint, fillPaint);
        break;
      case ComponentType.diode:
        _drawDiode(canvas, size, cx, cy, paint, fillPaint);
        break;
      case ComponentType.led:
        _drawLED(canvas, size, cx, cy, paint, fillPaint);
        break;
      case ComponentType.motor:
        _drawMotor(canvas, size, cx, cy, paint, fillPaint);
        break;
      case ComponentType.potentiometer:
        _drawPotentiometer(canvas, size, cx, cy, paint, fillPaint);
        break;
      case ComponentType.powerSupply:
        _drawPowerSupply(canvas, size, cx, cy, paint, fillPaint);
        break;
      case ComponentType.fuse:
        _drawFuse(canvas, size, cx, cy, paint, fillPaint);
        break;
      case ComponentType.capacitor:
        _drawCapacitor(canvas, size, cx, cy, paint, fillPaint);
        break;
      case ComponentType.buzzer:
        _drawBuzzer(canvas, size, cx, cy, paint, fillPaint);
        break;
    }
  }

  void _drawBattery(Canvas canvas, Size size, double cx, double cy, Paint paint) {
    final leftX = 0.0;
    final rightX = size.width;
    final bLeft = cx - 14.0;
    final bRight = cx + 14.0;

    canvas.drawLine(Offset(leftX, cy), Offset(bLeft, cy), paint);
    canvas.drawLine(Offset(bRight, cy), Offset(rightX, cy), paint);

    final negPaint = Paint()
      ..color = paint.color
      ..strokeWidth = strokeWidth * 2.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(bLeft, cy - 16), Offset(bLeft, cy + 16), negPaint);

    final posPaint = Paint()
      ..color = paint.color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(bRight, cy - 26), Offset(bRight, cy + 26), posPaint);
  }

  void _drawConnectingWire(Canvas canvas, Size size, double cx, double cy, Paint paint) {
    final leftX = 0.0;
    final rightX = size.width;

    if (isParallel) {
      // Duas linhas paralelas para a fiação em paralelo
      final dy = 5.0;
      canvas.drawLine(Offset(leftX, cy - dy), Offset(rightX, cy - dy), paint);
      canvas.drawLine(Offset(leftX, cy + dy), Offset(rightX, cy + dy), paint);
    } else {
      // Linha horizontal principal centralizada na altura cy (alinhada com os terminais dos soquetes)
      canvas.drawLine(Offset(leftX, cy), Offset(rightX, cy), paint);

      if (isJunction) {
        // Haste vertical de junção de nó apenas se for um nó/bifurcação
        canvas.drawLine(Offset(cx, cy), Offset(cx, size.height * 0.85), paint);

        final dotPaint = Paint()
          ..color = paint.color
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(cx, cy), strokeWidth * 1.5, dotPaint);
      }
    }
  }

  void _drawSwitch(Canvas canvas, Size size, double cx, double cy, Paint paint) {
    final leftX = 0.0;
    final rightX = size.width;
    final p1 = Offset(cx - 28, cy);
    final p2 = Offset(cx + 28, cy);

    canvas.drawLine(Offset(leftX, cy), p1, paint);
    canvas.drawLine(p2, Offset(rightX, cy), paint);

    final dotPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(p1, strokeWidth * 1.6, dotPaint);
    canvas.drawCircle(p2, strokeWidth * 1.6, dotPaint);

    if (isActive) {
      canvas.drawLine(p1, p2, paint..strokeWidth = strokeWidth * 1.2);
    } else {
      canvas.drawLine(p1, Offset(p1.dx + 28, cy - 20), paint);
    }
  }

  void _drawBulb(Canvas canvas, Size size, double cx, double cy, Paint paint, Paint fillPaint) {
    final leftX = 0.0;
    final rightX = size.width;
    final radius = 26.0;

    canvas.drawLine(Offset(leftX, cy), Offset(cx - radius, cy), paint);
    canvas.drawLine(Offset(cx + radius, cy), Offset(rightX, cy), paint);

    if (isActive) {
      canvas.drawCircle(Offset(cx, cy), radius, fillPaint);
    }
    canvas.drawCircle(Offset(cx, cy), radius, paint);

    final offset = radius * 0.707;
    canvas.drawLine(Offset(cx - offset, cy - offset), Offset(cx + offset, cy + offset), paint);
    canvas.drawLine(Offset(cx - offset, cy + offset), Offset(cx + offset, cy - offset), paint);
  }

  void _drawResistor(Canvas canvas, Size size, double cx, double cy, Paint paint, Paint fillPaint) {
    final leftX = 0.0;
    final rightX = size.width;
    final width = 62.0;
    final height = 26.0;

    final rect = Rect.fromCenter(center: Offset(cx, cy), width: width, height: height);

    canvas.drawLine(Offset(leftX, cy), Offset(rect.left, cy), paint);
    canvas.drawLine(Offset(rect.right, cy), Offset(rightX, cy), paint);

    canvas.drawRect(rect, fillPaint);
    canvas.drawRect(rect, paint);
  }

  void _drawDiode(Canvas canvas, Size size, double cx, double cy, Paint paint, Paint fillPaint) {
    final leftX = 0.0;
    final rightX = size.width;
    final triWidth = 36.0;
    final triHeight = 32.0;

    final pLeft = cx - triWidth / 2;
    final pRight = cx + triWidth / 2;

    canvas.drawLine(Offset(leftX, cy), Offset(pLeft, cy), paint);
    canvas.drawLine(Offset(pRight, cy), Offset(rightX, cy), paint);

    final path = Path()
      ..moveTo(pRight, cy - triHeight / 2)
      ..lineTo(pLeft, cy)
      ..lineTo(pRight, cy + triHeight / 2)
      ..close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);

    canvas.drawLine(Offset(pLeft, cy - triHeight / 2), Offset(pLeft, cy + triHeight / 2), paint);
  }

  void _drawLED(Canvas canvas, Size size, double cx, double cy, Paint paint, Paint fillPaint) {
    _drawDiode(canvas, size, cx, cy, paint, fillPaint);

    final arrowPaint = Paint()
      ..color = isActive ? activeColor : paint.color
      ..strokeWidth = strokeWidth * 0.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final arrowStart1 = Offset(cx, cy - 18);
    final arrowEnd1 = Offset(cx - 14, cy - 32);

    final arrowStart2 = Offset(cx + 12, cy - 15);
    final arrowEnd2 = Offset(cx - 2, cy - 29);

    _drawArrow(canvas, arrowStart1, arrowEnd1, arrowPaint);
    _drawArrow(canvas, arrowStart2, arrowEnd2, arrowPaint);
  }

  void _drawMotor(Canvas canvas, Size size, double cx, double cy, Paint paint, Paint fillPaint) {
    final leftX = 0.0;
    final rightX = size.width;
    final radius = 26.0;

    final brushWidth = 6.0;
    final brushHeight = 11.0;

    final leftBrushRect = Rect.fromCenter(center: Offset(cx - radius - brushWidth / 2, cy), width: brushWidth, height: brushHeight);
    final rightBrushRect = Rect.fromCenter(center: Offset(cx + radius + brushWidth / 2, cy), width: brushWidth, height: brushHeight);

    canvas.drawLine(Offset(leftX, cy), Offset(leftBrushRect.left, cy), paint);
    canvas.drawLine(Offset(rightBrushRect.right, cy), Offset(rightX, cy), paint);

    final brushPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;
    canvas.drawRect(leftBrushRect, brushPaint);
    canvas.drawRect(rightBrushRect, brushPaint);

    if (isActive) {
      canvas.drawCircle(Offset(cx, cy), radius, fillPaint);
    }
    canvas.drawCircle(Offset(cx, cy), radius, paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: 'M',
        style: TextStyle(
          color: paint.color,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(cx - textPainter.width / 2, cy - textPainter.height / 2),
    );

    if (isActive) {
      final rotArcPaint = Paint()
        ..color = activeColor
        ..strokeWidth = strokeWidth * 0.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final arcRadius = radius + 8.0;
      final angleOffset = (DateTime.now().millisecondsSinceEpoch / 200) % (2 * math.pi);
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: arcRadius),
        angleOffset,
        1.5 * math.pi,
        false,
        rotArcPaint,
      );

      final arrowTip = Offset(
        cx + arcRadius * math.cos(angleOffset + 1.5 * math.pi),
        cy + arcRadius * math.sin(angleOffset + 1.5 * math.pi),
      );
      canvas.drawCircle(arrowTip, strokeWidth, Paint()..color = activeColor);
    }
  }

  void _drawPotentiometer(Canvas canvas, Size size, double cx, double cy, Paint paint, Paint fillPaint) {
    _drawResistor(canvas, size, cx, cy, paint, fillPaint);
    final arrowPaint = Paint()
      ..color = paint.color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    _drawArrow(canvas, Offset(cx - 22, cy + 24), Offset(cx + 22, cy - 24), arrowPaint);
  }

  void _drawPowerSupply(Canvas canvas, Size size, double cx, double cy, Paint paint, Paint fillPaint) {
    final leftX = 0.0;
    final rightX = size.width;
    final radius = 26.0;

    canvas.drawLine(Offset(leftX, cy), Offset(cx - radius, cy), paint);
    canvas.drawLine(Offset(cx + radius, cy), Offset(rightX, cy), paint);

    canvas.drawCircle(Offset(cx, cy), radius, fillPaint);
    canvas.drawCircle(Offset(cx, cy), radius, paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: 'V~',
        style: TextStyle(
          color: paint.color,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(canvas, Offset(cx - textPainter.width / 2, cy - textPainter.height / 2));
  }

  void _drawFuse(Canvas canvas, Size size, double cx, double cy, Paint paint, Paint fillPaint) {
    final leftX = 0.0;
    final rightX = size.width;
    final width = 56.0;
    final height = 24.0;

    final rect = Rect.fromCenter(center: Offset(cx, cy), width: width, height: height);

    canvas.drawLine(Offset(leftX, cy), Offset(rightX, cy), paint);
    canvas.drawRect(rect, fillPaint);
    canvas.drawRect(rect, paint);
  }

  void _drawCapacitor(Canvas canvas, Size size, double cx, double cy, Paint paint, Paint fillPaint) {
    final leftX = 0.0;
    final rightX = size.width;
    final gap = 12.0;
    final plateHeight = 34.0;

    final pLeft = cx - gap / 2;
    final pRight = cx + gap / 2;

    canvas.drawLine(Offset(leftX, cy), Offset(pLeft, cy), paint);
    canvas.drawLine(Offset(pRight, cy), Offset(rightX, cy), paint);

    canvas.drawLine(Offset(pLeft, cy - plateHeight / 2), Offset(pLeft, cy + plateHeight / 2), paint..strokeWidth = strokeWidth * 1.4);
    canvas.drawLine(Offset(pRight, cy - plateHeight / 2), Offset(pRight, cy + plateHeight / 2), paint..strokeWidth = strokeWidth * 1.4);
  }

  void _drawBuzzer(Canvas canvas, Size size, double cx, double cy, Paint paint, Paint fillPaint) {
    final leftX = 0.0;
    final rightX = size.width;
    final radius = 22.0;

    final pLeft = cx - radius;
    final pRight = cx + radius;

    canvas.drawLine(Offset(leftX, cy), Offset(pLeft, cy), paint);
    canvas.drawLine(Offset(pRight, cy), Offset(rightX, cy), paint);

    final path = Path()
      ..addArc(Rect.fromCircle(center: Offset(cx, cy), radius: radius), -math.pi / 2, math.pi);

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);
    canvas.drawLine(Offset(cx, cy - radius), Offset(cx, cy + radius), paint);
  }

  void _drawArrow(Canvas canvas, Offset from, Offset to, Paint paint) {
    canvas.drawLine(from, to, paint);
    final angle = math.atan2(to.dy - from.dy, to.dx - from.dx);
    final arrowSize = 5.0;

    final path = Path()
      ..moveTo(to.dx, to.dy)
      ..lineTo(
        to.dx - arrowSize * math.cos(angle - math.pi / 6),
        to.dy - arrowSize * math.sin(angle - math.pi / 6),
      )
      ..moveTo(to.dx, to.dy)
      ..lineTo(
        to.dx - arrowSize * math.cos(angle + math.pi / 6),
        to.dy - arrowSize * math.sin(angle + math.pi / 6),
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CircuitSymbolPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.isActive != isActive ||
        oldDelegate.isBurned != isBurned ||
        oldDelegate.color != color ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.value != value ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.isJunction != isJunction ||
        oldDelegate.isParallel != isParallel;
  }
}
