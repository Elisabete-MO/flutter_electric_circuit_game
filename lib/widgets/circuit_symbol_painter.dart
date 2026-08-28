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
    final bLeft = cx - 8;
    final bRight = cx + 8;

    // Linha contínua da extremidade esquerda até a placa positiva e da placa negativa até a extremidade direita
    canvas.drawLine(Offset(leftX, cy), Offset(bLeft, cy), paint);
    canvas.drawLine(Offset(bRight, cy), Offset(rightX, cy), paint);

    // Terminal da esquerda (linha longa - polo positivo)
    final posPaint = Paint()
      ..color = paint.color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(bLeft, cy - 18), Offset(bLeft, cy + 18), posPaint);

    // Terminal da direita (linha mais curta e mais grossa - polo negativo)
    final negPaint = Paint()
      ..color = paint.color
      ..strokeWidth = strokeWidth * 2.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(bRight, cy - 10), Offset(bRight, cy + 10), negPaint);
  }

  void _drawConnectingWire(Canvas canvas, Size size, double cx, double cy, Paint paint) {
    final leftX = 0.0;
    final rightX = size.width;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;

    canvas.drawLine(Offset(leftX, topY), Offset(rightX, topY), paint);
    canvas.drawLine(Offset(cx, topY), Offset(cx, bottomY), paint);

    final dotPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, topY), strokeWidth * 1.5, dotPaint);
  }

  void _drawSwitch(Canvas canvas, Size size, double cx, double cy, Paint paint) {
    final leftX = 0.0;
    final rightX = size.width;
    final p1 = Offset(cx - 20, cy);
    final p2 = Offset(cx + 20, cy);

    // Fios de entrada e saída contínuos
    canvas.drawLine(Offset(leftX, cy), p1, paint);
    canvas.drawLine(p2, Offset(rightX, cy), paint);

    // Bornes do interruptor
    final dotPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(p1, strokeWidth * 1.4, dotPaint);
    canvas.drawCircle(p2, strokeWidth * 1.4, dotPaint);

    // Lâmina/Contato do interruptor
    if (isActive) {
      canvas.drawLine(p1, p2, paint..strokeWidth = strokeWidth * 1.2);
    } else {
      canvas.drawLine(p1, Offset(p1.dx + 20, cy - 14), paint);
    }
  }

  void _drawBulb(Canvas canvas, Size size, double cx, double cy, Paint paint, Paint fillPaint) {
    final leftX = 0.0;
    final rightX = size.width;
    final radius = 18.0;

    // Fios laterais estendidos
    canvas.drawLine(Offset(leftX, cy), Offset(cx - radius, cy), paint);
    canvas.drawLine(Offset(cx + radius, cy), Offset(rightX, cy), paint);

    // Círculo principal da lâmpada
    if (isActive) {
      canvas.drawCircle(Offset(cx, cy), radius, fillPaint);
    }
    canvas.drawCircle(Offset(cx, cy), radius, paint);

    // X interno do símbolo
    final offset = radius * 0.707;
    canvas.drawLine(Offset(cx - offset, cy - offset), Offset(cx + offset, cy + offset), paint);
    canvas.drawLine(Offset(cx - offset, cy + offset), Offset(cx + offset, cy - offset), paint);
  }

  void _drawResistor(Canvas canvas, Size size, double cx, double cy, Paint paint, Paint fillPaint) {
    final leftX = 0.0;
    final rightX = size.width;
    final width = 44.0;
    final height = 20.0;

    final rect = Rect.fromCenter(center: Offset(cx, cy), width: width, height: height);

    // Fios laterais estendidos
    canvas.drawLine(Offset(leftX, cy), Offset(rect.left, cy), paint);
    canvas.drawLine(Offset(rect.right, cy), Offset(rightX, cy), paint);

    // Retângulo do resistor (IEC)
    canvas.drawRect(rect, fillPaint);
    canvas.drawRect(rect, paint);
  }

  void _drawDiode(Canvas canvas, Size size, double cx, double cy, Paint paint, Paint fillPaint) {
    final leftX = 0.0;
    final rightX = size.width;
    final triWidth = 24.0;
    final triHeight = 22.0;

    final pLeft = cx - triWidth / 2;
    final pRight = cx + triWidth / 2;

    // Fios
    canvas.drawLine(Offset(leftX, cy), Offset(pLeft, cy), paint);
    canvas.drawLine(Offset(pRight, cy), Offset(rightX, cy), paint);

    // Triângulo do anodo -> catodo
    final path = Path()
      ..moveTo(pLeft, cy - triHeight / 2)
      ..lineTo(pRight, cy)
      ..lineTo(pLeft, cy + triHeight / 2)
      ..close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);

    // Barra vertical no catodo
    canvas.drawLine(Offset(pRight, cy - triHeight / 2), Offset(pRight, cy + triHeight / 2), paint);
  }

  void _drawLED(Canvas canvas, Size size, double cx, double cy, Paint paint, Paint fillPaint) {
    _drawDiode(canvas, size, cx, cy, paint, fillPaint);

    final arrowPaint = Paint()
      ..color = isActive ? activeColor : paint.color
      ..strokeWidth = strokeWidth * 0.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final arrowStart1 = Offset(cx, cy - 14);
    final arrowEnd1 = Offset(cx + 10, cy - 24);

    final arrowStart2 = Offset(cx + 8, cy - 12);
    final arrowEnd2 = Offset(cx + 18, cy - 22);

    _drawArrow(canvas, arrowStart1, arrowEnd1, arrowPaint);
    _drawArrow(canvas, arrowStart2, arrowEnd2, arrowPaint);
  }

  void _drawMotor(Canvas canvas, Size size, double cx, double cy, Paint paint, Paint fillPaint) {
    final leftX = 0.0;
    final rightX = size.width;
    final radius = 18.0;

    // Fios estendidos das extremidades até o início das escovas
    final brushWidth = 5.0;
    final brushHeight = 8.0;

    final leftBrushRect = Rect.fromCenter(center: Offset(cx - radius - brushWidth / 2, cy), width: brushWidth, height: brushHeight);
    final rightBrushRect = Rect.fromCenter(center: Offset(cx + radius + brushWidth / 2, cy), width: brushWidth, height: brushHeight);

    canvas.drawLine(Offset(leftX, cy), Offset(leftBrushRect.left, cy), paint);
    canvas.drawLine(Offset(rightBrushRect.right, cy), Offset(rightX, cy), paint);

    // Escovas de carvão laterais (Carbon Brushes do símbolo NBR/IEEE)
    final brushPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;
    canvas.drawRect(leftBrushRect, brushPaint);
    canvas.drawRect(rightBrushRect, brushPaint);

    // Círculo principal do motor
    if (isActive) {
      canvas.drawCircle(Offset(cx, cy), radius, fillPaint);
    }
    canvas.drawCircle(Offset(cx, cy), radius, paint);

    // Letra M no centro
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'M',
        style: TextStyle(
          color: paint.color,
          fontSize: 18,
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

    // Seta curva de rotação animada ao redor do motor quando ativo (Rotation Arc)
    if (isActive) {
      final rotArcPaint = Paint()
        ..color = activeColor
        ..strokeWidth = strokeWidth * 0.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final arcRadius = radius + 6.0;
      final angleOffset = (DateTime.now().millisecondsSinceEpoch / 200) % (2 * math.pi);
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: arcRadius),
        angleOffset,
        1.5 * math.pi,
        false,
        rotArcPaint,
      );

      // Ponta da seta
      final arrowTip = Offset(
        cx + arcRadius * math.cos(angleOffset + 1.5 * math.pi),
        cy + arcRadius * math.sin(angleOffset + 1.5 * math.pi),
      );
      canvas.drawCircle(arrowTip, strokeWidth, Paint()..color = activeColor);
    }
  }

  void _drawPotentiometer(Canvas canvas, Size size, double cx, double cy, Paint paint, Paint fillPaint) {
    _drawResistor(canvas, size, cx, cy, paint, fillPaint);
    // Seta diagonal do potenciômetro atraves do resistor
    final arrowPaint = Paint()
      ..color = paint.color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    _drawArrow(canvas, Offset(cx - 16, cy + 18), Offset(cx + 16, cy - 18), arrowPaint);
  }

  void _drawPowerSupply(Canvas canvas, Size size, double cx, double cy, Paint paint, Paint fillPaint) {
    final leftX = 0.0;
    final rightX = size.width;
    final radius = 18.0;

    canvas.drawLine(Offset(leftX, cy), Offset(cx - radius, cy), paint);
    canvas.drawLine(Offset(cx + radius, cy), Offset(rightX, cy), paint);

    canvas.drawCircle(Offset(cx, cy), radius, fillPaint);
    canvas.drawCircle(Offset(cx, cy), radius, paint);

    // Texto DC ou V
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'V~',
        style: TextStyle(
          color: paint.color,
          fontSize: 14,
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
    final width = 36.0;
    final height = 16.0;

    final rect = Rect.fromCenter(center: Offset(cx, cy), width: width, height: height);

    // Fio passando reto pelo meio do retângulo do fusível
    canvas.drawLine(Offset(leftX, cy), Offset(rightX, cy), paint);
    canvas.drawRect(rect, fillPaint);
    canvas.drawRect(rect, paint);
  }

  void _drawCapacitor(Canvas canvas, Size size, double cx, double cy, Paint paint, Paint fillPaint) {
    final leftX = 0.0;
    final rightX = size.width;
    final gap = 8.0;
    final plateHeight = 24.0;

    final pLeft = cx - gap / 2;
    final pRight = cx + gap / 2;

    canvas.drawLine(Offset(leftX, cy), Offset(pLeft, cy), paint);
    canvas.drawLine(Offset(pRight, cy), Offset(rightX, cy), paint);

    // Placa Esquerda
    canvas.drawLine(Offset(pLeft, cy - plateHeight / 2), Offset(pLeft, cy + plateHeight / 2), paint..strokeWidth = strokeWidth * 1.4);

    // Placa Direita
    canvas.drawLine(Offset(pRight, cy - plateHeight / 2), Offset(pRight, cy + plateHeight / 2), paint..strokeWidth = strokeWidth * 1.4);
  }

  void _drawBuzzer(Canvas canvas, Size size, double cx, double cy, Paint paint, Paint fillPaint) {
    final leftX = 0.0;
    final rightX = size.width;
    final radius = 14.0;

    final pLeft = cx - radius;
    final pRight = cx + radius;

    canvas.drawLine(Offset(leftX, cy), Offset(pLeft, cy), paint);
    canvas.drawLine(Offset(pRight, cy), Offset(rightX, cy), paint);

    // Semicírculo do Buzzer
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
        oldDelegate.animationValue != animationValue;
  }
}
