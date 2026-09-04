import 'package:flutter/material.dart';

/// Símbolos Esquemáticos Eletrônicos Padronizados (Normas Didáticas ANSI / IEC)
/// Renderização vetorial de alta fidelidade para blueprint esquemático.

// ==========================================================
// 1. SÍMBOLO ESQUEMÁTICO: BATERIA / FONTE CC
// ==========================================================
class SchematicBatteryWidget extends StatelessWidget {
  final double size;
  final Color color;
  final bool is9V;

  const SchematicBatteryWidget({
    super.key,
    this.size = 48.0,
    this.color = const Color(0xFF00E5FF),
    this.is9V = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SchematicBatteryPainter(color: color, is9V: is9V)),
    );
  }
}

class _SchematicBatteryPainter extends CustomPainter {
  final Color color;
  final bool is9V;

  _SchematicBatteryPainter({required this.color, required this.is9V});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cy = h / 2;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final thinPlate = Paint()
      ..color = color
      ..strokeWidth = 3.5;

    final thickPlate = Paint()
      ..color = color
      ..strokeWidth = 1.5;

    // Fios laterais de conexão esquemática
    canvas.drawLine(Offset(0, cy), Offset(w * 0.3, cy), linePaint);
    canvas.drawLine(Offset(w * 0.7, cy), Offset(w, cy), linePaint);

    // Placa Positiva (+) - Mais longa e fina (Esquerda)
    canvas.drawLine(Offset(w * 0.38, cy - (h * 0.35)), Offset(w * 0.38, cy + (h * 0.35)), thinPlate);
    // Placa Negativa (-) - Mais curta e espessa (Direita)
    canvas.drawLine(Offset(w * 0.50, cy - (h * 0.20)), Offset(w * 0.50, cy + (h * 0.20)), thickPlate);

    if (is9V) {
      // Segunda célula para 9V
      canvas.drawLine(Offset(w * 0.56, cy - (h * 0.35)), Offset(w * 0.56, cy + (h * 0.35)), thinPlate);
      canvas.drawLine(Offset(w * 0.64, cy - (h * 0.20)), Offset(w * 0.64, cy + (h * 0.20)), thickPlate);
    }

    // Sinais + e -
    final textPainterPos = TextPainter(
      text: TextSpan(text: '+', style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    );
    textPainterPos.layout();
    textPainterPos.paint(canvas, Offset(w * 0.22, cy - (h * 0.45)));

    final textPainterNeg = TextPainter(
      text: TextSpan(text: '-', style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    );
    textPainterNeg.layout();
    textPainterNeg.paint(canvas, Offset(w * 0.68, cy - (h * 0.45)));
  }

  @override
  bool shouldRepaint(covariant _SchematicBatteryPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.is9V != is9V;
}

// ==========================================================
// 2. SÍMBOLO ESQUEMÁTICO: LÂMPADA INCANDESCENTE (CIRCULO COM X)
// ==========================================================
class SchematicLampWidget extends StatelessWidget {
  final double size;
  final Color color;
  final bool isOn;

  const SchematicLampWidget({
    super.key,
    this.size = 48.0,
    this.color = const Color(0xFF00E5FF),
    this.isOn = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SchematicLampPainter(color: isOn ? Colors.amberAccent : color, isOn: isOn)),
    );
  }
}

class _SchematicLampPainter extends CustomPainter {
  final Color color;
  final bool isOn;

  _SchematicLampPainter({required this.color, required this.isOn});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w * 0.32;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // Conexões laterais
    canvas.drawLine(Offset(0, center.dy), Offset(center.dx - radius, center.dy), linePaint);
    canvas.drawLine(Offset(center.dx + radius, center.dy), Offset(w, center.dy), linePaint);

    // Círculo central do símbolo esquemático
    canvas.drawCircle(center, radius, linePaint);

    // X interno do símbolo esquemático de lâmpada
    final d = radius * 0.65;
    canvas.drawLine(Offset(center.dx - d, center.dy - d), Offset(center.dx + d, center.dy + d), linePaint);
    canvas.drawLine(Offset(center.dx - d, center.dy + d), Offset(center.dx + d, center.dy - d), linePaint);

    if (isOn) {
      final glowPaint = Paint()
        ..color = Colors.amberAccent.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(center, radius * 1.3, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SchematicLampPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isOn != isOn;
}

// ==========================================================
// 3. SÍMBOLO ESQUEMÁTICO: INTERRUPTOR SPST / PUSH-BUTTON
// ==========================================================
class SchematicSwitchWidget extends StatelessWidget {
  final double size;
  final Color color;
  final bool isClosed;
  final bool isPushButton;

  const SchematicSwitchWidget({
    super.key,
    this.size = 48.0,
    this.color = const Color(0xFF00E5FF),
    this.isClosed = false,
    this.isPushButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SchematicSwitchPainter(color: color, isClosed: isClosed, isPushButton: isPushButton),
      ),
    );
  }
}

class _SchematicSwitchPainter extends CustomPainter {
  final Color color;
  final bool isClosed;
  final bool isPushButton;

  _SchematicSwitchPainter({required this.color, required this.isClosed, required this.isPushButton});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cy = h / 2;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Fios laterais
    canvas.drawLine(Offset(0, cy), Offset(w * 0.25, cy), linePaint);
    canvas.drawLine(Offset(w * 0.75, cy), Offset(w, cy), linePaint);

    // Dois bornes / pontos esquemáticos
    canvas.drawCircle(Offset(w * 0.25, cy), 4.0, dotPaint);
    canvas.drawCircle(Offset(w * 0.75, cy), 4.0, dotPaint);

    // Haste/Alavanca do interruptor
    if (isClosed) {
      canvas.drawLine(Offset(w * 0.25, cy), Offset(w * 0.75, cy), linePaint..strokeWidth = 3.5);
    } else {
      // Chave aberta (inclinada ~30 graus)
      canvas.drawLine(Offset(w * 0.25, cy), Offset(w * 0.72, cy - (h * 0.35)), linePaint);
    }

    if (isPushButton) {
      // Haste vertical de pressão tipo Push-Button
      final btnY = isClosed ? cy - 6 : cy - (h * 0.35) - 6;
      canvas.drawLine(Offset(w * 0.50, btnY), Offset(w * 0.50, btnY - 10), linePaint);
      canvas.drawLine(Offset(w * 0.38, btnY - 10), Offset(w * 0.62, btnY - 10), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SchematicSwitchPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isClosed != isClosed || oldDelegate.isPushButton != isPushButton;
}

// ==========================================================
// 4. SÍMBOLO ESQUEMÁTICO: LED (TRIÂNGULO + BARRA + FÓTONS)
// ==========================================================
class SchematicLedWidget extends StatelessWidget {
  final double size;
  final Color color;
  final bool isOn;

  const SchematicLedWidget({
    super.key,
    this.size = 48.0,
    this.color = const Color(0xFF00E5FF),
    this.isOn = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SchematicLedPainter(color: isOn ? Colors.greenAccent : color, isOn: isOn)),
    );
  }
}

class _SchematicLedPainter extends CustomPainter {
  final Color color;
  final bool isOn;

  _SchematicLedPainter({required this.color, required this.isOn});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cy = h / 2;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Fios laterais
    canvas.drawLine(Offset(0, cy), Offset(w * 0.3, cy), linePaint);
    canvas.drawLine(Offset(w * 0.7, cy), Offset(w, cy), linePaint);

    // Triângulo Ânodo -> Cátodo
    final trianglePath = Path();
    trianglePath.moveTo(w * 0.30, cy - (h * 0.25));
    trianglePath.lineTo(w * 0.65, cy);
    trianglePath.lineTo(w * 0.30, cy + (h * 0.25));
    trianglePath.close();
    canvas.drawPath(trianglePath, fillPaint);

    // Barra de bloqueio do Cátodo (-)
    canvas.drawLine(Offset(w * 0.65, cy - (h * 0.25)), Offset(w * 0.65, cy + (h * 0.25)), linePaint..strokeWidth = 3.0);

    // Setas de emissão de Luz (Fótons)
    final arrowPaint = Paint()
      ..color = isOn ? Colors.amberAccent : color
      ..strokeWidth = 2.0;

    canvas.drawLine(Offset(w * 0.50, cy - (h * 0.25)), Offset(w * 0.62, cy - (h * 0.45)), arrowPaint);
    canvas.drawLine(Offset(w * 0.62, cy - (h * 0.45)), Offset(w * 0.58, cy - (h * 0.45)), arrowPaint);
    canvas.drawLine(Offset(w * 0.62, cy - (h * 0.45)), Offset(w * 0.62, cy - (h * 0.41)), arrowPaint);

    canvas.drawLine(Offset(w * 0.60, cy - (h * 0.20)), Offset(w * 0.72, cy - (h * 0.40)), arrowPaint);
    canvas.drawLine(Offset(w * 0.72, cy - (h * 0.40)), Offset(w * 0.68, cy - (h * 0.40)), arrowPaint);
    canvas.drawLine(Offset(w * 0.72, cy - (h * 0.40)), Offset(w * 0.72, cy - (h * 0.36)), arrowPaint);
  }

  @override
  bool shouldRepaint(covariant _SchematicLedPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isOn != isOn;
}

// ==========================================================
// 5. SÍMBOLO ESQUEMÁTICO: RESISTOR (ZIG-ZAG / ZIGZAG NORMA ANSI)
// ==========================================================
class SchematicResistorWidget extends StatelessWidget {
  final double size;
  final Color color;
  final String label;

  const SchematicResistorWidget({
    super.key,
    this.size = 48.0,
    this.color = const Color(0xFF00E5FF),
    this.label = 'R',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SchematicResistorPainter(color: color, label: label)),
    );
  }
}

class _SchematicResistorPainter extends CustomPainter {
  final Color color;
  final String label;

  _SchematicResistorPainter({required this.color, required this.label});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cy = h / 2;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Fios laterais
    canvas.drawLine(Offset(0, cy), Offset(w * 0.20, cy), linePaint);
    canvas.drawLine(Offset(w * 0.80, cy), Offset(w, cy), linePaint);

    // Zig-Zag do Resistor
    final zigPath = Path();
    zigPath.moveTo(w * 0.20, cy);
    zigPath.lineTo(w * 0.25, cy - (h * 0.20));
    zigPath.lineTo(w * 0.35, cy + (h * 0.20));
    zigPath.lineTo(w * 0.45, cy - (h * 0.20));
    zigPath.lineTo(w * 0.55, cy + (h * 0.20));
    zigPath.lineTo(w * 0.65, cy - (h * 0.20));
    zigPath.lineTo(w * 0.75, cy + (h * 0.20));
    zigPath.lineTo(w * 0.80, cy);

    canvas.drawPath(zigPath, linePaint);

    if (label.isNotEmpty) {
      final textPainter = TextPainter(
        text: TextSpan(text: label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(w * 0.40, cy - (h * 0.45)));
    }
  }

  @override
  bool shouldRepaint(covariant _SchematicResistorPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.label != label;
}

// ==========================================================
// 6. SÍMBOLO ESQUEMÁTICO: MOTOR CC (CÍRCULO COM M)
// ==========================================================
class SchematicMotorWidget extends StatelessWidget {
  final double size;
  final Color color;
  final bool isRunning;

  const SchematicMotorWidget({
    super.key,
    this.size = 48.0,
    this.color = const Color(0xFF00E5FF),
    this.isRunning = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SchematicMotorPainter(color: isRunning ? Colors.greenAccent : color, isRunning: isRunning)),
    );
  }
}

class _SchematicMotorPainter extends CustomPainter {
  final Color color;
  final bool isRunning;

  _SchematicMotorPainter({required this.color, required this.isRunning});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w * 0.30;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // Conexões laterais
    canvas.drawLine(Offset(0, center.dy), Offset(center.dx - radius, center.dy), linePaint);
    canvas.drawLine(Offset(center.dx + radius, center.dy), Offset(w, center.dy), linePaint);

    // Círculo central do Motor
    canvas.drawCircle(center, radius, linePaint);

    // Letra M no centro
    final textPainter = TextPainter(
      text: TextSpan(text: 'M', style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx - (textPainter.width / 2), center.dy - (textPainter.height / 2)));
  }

  @override
  bool shouldRepaint(covariant _SchematicMotorPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isRunning != isRunning;
}

// ==========================================================
// 7. SÍMBOLO ESQUEMÁTICO: MULTÍMETRO DIDÁTICO (VOLTÍMETRO V / AMPERÍMETRO A)
// ==========================================================
class SchematicMeterWidget extends StatelessWidget {
  final double size;
  final Color color;
  final String meterType; // 'V' ou 'A'

  const SchematicMeterWidget({
    super.key,
    this.size = 48.0,
    this.color = const Color(0xFF00E5FF),
    this.meterType = 'V',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SchematicMeterPainter(color: color, meterType: meterType)),
    );
  }
}

class _SchematicMeterPainter extends CustomPainter {
  final Color color;
  final String meterType;

  _SchematicMeterPainter({required this.color, required this.meterType});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w * 0.30;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // Círculo do instrumento de medição
    canvas.drawCircle(center, radius, linePaint);

    // Letra V ou A
    final textPainter = TextPainter(
      text: TextSpan(text: meterType, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx - (textPainter.width / 2), center.dy - (textPainter.height / 2)));
  }

  @override
  bool shouldRepaint(covariant _SchematicMeterPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.meterType != meterType;
}

// ==========================================================
// 8. CUSTOM PAINTER ESQUEMÁTICO COM TRANÇADO BLUEPRINT CYAN
// ==========================================================
// ==========================================================
// 8. CUSTOM PAINTER ESQUEMÁTICO COM TRANÇADO PADRONIZADO (ESTANDE 3 & 4)
// ==========================================================
class SchematicCircuitWirePainter extends CustomPainter {
  final bool isClosed;
  final double animationValue;
  final bool switchInserted;
  final Color wireColor;

  SchematicCircuitWirePainter({
    required this.isClosed,
    required this.animationValue,
    this.switchInserted = true,
    this.wireColor = const Color(0xFF1E293B),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final batteryX = size.width * 0.18;
    final lampX = size.width * 0.82;
    final switchCenterX = size.width * 0.50;

    final centerY = size.height * 0.50;
    final topWireY = centerY;
    final bottomWireY = centerY + 65.0;

    // Path 1 (Positivo VCC - Vermelho): Bateria(+) -> Switch(A)
    final path1 = Path()
      ..moveTo(batteryX, centerY)
      ..lineTo(switchCenterX - 47.5, topWireY);

    // Path 2 (Intermediário - Laranja/Dourado): Switch(B) -> Lâmpada(A)
    final path2 = Path()
      ..moveTo(switchCenterX + 47.5, topWireY)
      ..lineTo(lampX, centerY);

    // Path 3 (Negativo Retorno - Azul): Lâmpada(B) -> Bateria(-)
    final path3 = Path()
      ..moveTo(lampX, centerY + 47.5)
      ..lineTo(lampX, bottomWireY)
      ..lineTo(batteryX, bottomWireY)
      ..lineTo(batteryX, centerY + 47.5);

    void drawWireSegment(Path path, Color activeColor, Color inactiveColor) {
      final color = isClosed ? activeColor : inactiveColor;
      final glowPaint = Paint()
        ..color = color.withValues(alpha: isClosed ? 0.35 : 0.0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      final wirePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, wirePaint);
    }

    drawWireSegment(path1, const Color(0xFFEF4444), const Color(0xFF94A3B8));
    drawWireSegment(path2, const Color(0xFFF97316), const Color(0xFF94A3B8));
    drawWireSegment(path3, const Color(0xFF2563EB), const Color(0xFF94A3B8));

    // Terminal dots com acabamento de cobre metálico (Idêntico ao Estande 4)
    void drawPin(Offset pos) {
      final pinPaint = Paint()..color = isClosed ? const Color(0xFFB87333) : const Color(0xFF64748B);
      canvas.drawCircle(pos, 4.5, pinPaint);
    }

    drawPin(Offset(batteryX, centerY));
    drawPin(Offset(switchCenterX - 47.5, topWireY));
    drawPin(Offset(switchCenterX + 47.5, topWireY));
    drawPin(Offset(lampX, centerY));
    drawPin(Offset(lampX, centerY + 47.5));
    drawPin(Offset(batteryX, centerY + 47.5));

    // Elétrons em movimento se o circuito estiver fechado
    if (isClosed) {
      final electronGlow = Paint()
        ..color = const Color(0xFFFDE047)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
      final electronPaint = Paint()
        ..color = const Color(0xFFFEF08A)
        ..style = PaintingStyle.fill;

      final fullPath = Path()
        ..addPath(path1, Offset.zero)
        ..addPath(path2, Offset.zero)
        ..addPath(path3, Offset.zero);

      const totalDots = 14;
      final metrics = fullPath.computeMetrics();
      for (final metric in metrics) {
        final length = metric.length;
        for (int i = 0; i < totalDots; i++) {
          final distance = ((animationValue + (i / totalDots)) % 1.0) * length;
          final tangent = metric.getTangentForOffset(distance);
          if (tangent != null) {
            canvas.drawCircle(tangent.position, 5.0, electronGlow);
            canvas.drawCircle(tangent.position, 3.5, electronPaint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// CustomPainter para a Missão 3 (Dois Ramos Independentes em Paralelo)
class SchematicCircuitWirePainterM3 extends CustomPainter {
  final bool branch1Closed;
  final bool branch2Closed;
  final double animationValue;

  SchematicCircuitWirePainterM3({
    required this.branch1Closed,
    required this.branch2Closed,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final batteryX = size.width * 0.18;
    final lampX = size.width * 0.82;
    final switchCenterX = size.width * 0.50;

    final centerY = 90.0;
    final yRamo1 = 40.0;
    final yRamo2 = 140.0;
    final yBottom = 165.0;

    void drawWireSegment(Path path, Color activeColor, Color inactiveColor, bool isActive) {
      final color = isActive ? activeColor : inactiveColor;
      final glowPaint = Paint()
        ..color = color.withValues(alpha: isActive ? 0.35 : 0.0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      final wirePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, wirePaint);
    }

    // Ramo 1 (Superior): Vermelho VCC -> Laranja -> Azul Retorno
    final path1Vcc = Path()
      ..moveTo(batteryX, centerY - 20.0)
      ..lineTo(batteryX, yRamo1)
      ..lineTo(switchCenterX - 47.5, yRamo1);
    final path1Jumper = Path()
      ..moveTo(switchCenterX + 47.5, yRamo1)
      ..lineTo(lampX, yRamo1)
      ..lineTo(lampX, centerY - 20.0);

    drawWireSegment(path1Vcc, const Color(0xFFEF4444), const Color(0xFF94A3B8), branch1Closed);
    drawWireSegment(path1Jumper, const Color(0xFFF97316), const Color(0xFF94A3B8), branch1Closed);

    // Ramo 2 (Inferior): Vermelho VCC -> Laranja
    final path2Vcc = Path()
      ..moveTo(batteryX, centerY + 20.0)
      ..lineTo(batteryX, yRamo2)
      ..lineTo(switchCenterX - 47.5, yRamo2);
    final path2Jumper = Path()
      ..moveTo(switchCenterX + 47.5, yRamo2)
      ..lineTo(lampX, yRamo2);

    drawWireSegment(path2Vcc, const Color(0xFFEF4444), const Color(0xFF94A3B8), branch2Closed);
    drawWireSegment(path2Jumper, const Color(0xFFF97316), const Color(0xFF94A3B8), branch2Closed);

    // Linha de retorno comum (Azul)
    final isAnyClosed = branch1Closed || branch2Closed;
    final returnPath = Path()
      ..moveTo(lampX, yRamo2 + 20.0)
      ..lineTo(lampX, yBottom)
      ..lineTo(batteryX, yBottom)
      ..lineTo(batteryX, centerY + 40.0);

    drawWireSegment(returnPath, const Color(0xFF2563EB), const Color(0xFF94A3B8), isAnyClosed);

    // Bornes de Cobre
    void drawPin(Offset pos, bool isActive) {
      final pinPaint = Paint()..color = isActive ? const Color(0xFFB87333) : const Color(0xFF64748B);
      canvas.drawCircle(pos, 4.5, pinPaint);
    }

    drawPin(Offset(switchCenterX - 47.5, yRamo1), branch1Closed);
    drawPin(Offset(switchCenterX + 47.5, yRamo1), branch1Closed);
    drawPin(Offset(switchCenterX - 47.5, yRamo2), branch2Closed);
    drawPin(Offset(switchCenterX + 47.5, yRamo2), branch2Closed);

    // Eletrons animados nos ramos ativos
    final electronGlow = Paint()
      ..color = const Color(0xFFFDE047)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
    final electronPaint = Paint()
      ..color = const Color(0xFFFEF08A)
      ..style = PaintingStyle.fill;

    if (branch1Closed) {
      final fullPath1 = Path()..addPath(path1Vcc, Offset.zero)..addPath(path1Jumper, Offset.zero);
      for (final metric in fullPath1.computeMetrics()) {
        final length = metric.length;
        for (int i = 0; i < 10; i++) {
          final distance = ((animationValue + (i / 10)) % 1.0) * length;
          final tangent = metric.getTangentForOffset(distance);
          if (tangent != null) {
            canvas.drawCircle(tangent.position, 5.0, electronGlow);
            canvas.drawCircle(tangent.position, 3.5, electronPaint);
          }
        }
      }
    }

    if (branch2Closed) {
      final fullPath2 = Path()..addPath(path2Vcc, Offset.zero)..addPath(path2Jumper, Offset.zero);
      for (final metric in fullPath2.computeMetrics()) {
        final length = metric.length;
        for (int i = 0; i < 10; i++) {
          final distance = ((animationValue + (i / 10)) % 1.0) * length;
          final tangent = metric.getTangentForOffset(distance);
          if (tangent != null) {
            canvas.drawCircle(tangent.position, 5.0, electronGlow);
            canvas.drawCircle(tangent.position, 3.5, electronPaint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// CustomPainter para a Missão 4 (Conferência de Ramo Inútil vs Série)
class SchematicCircuitWirePainterM4 extends CustomPainter {
  final bool isClosed;
  final bool switchInMainBranch;
  final double animationValue;

  SchematicCircuitWirePainterM4({
    required this.isClosed,
    required this.switchInMainBranch,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final batteryX = size.width * 0.18;
    final lampX = size.width * 0.82;
    final switchCenterX = size.width * 0.50;

    final centerY = size.height * 0.50;
    final topParallelY = centerY - 55.0;
    final mainBranchY = centerY;
    final bottomWireY = centerY + 65.0;

    void drawWireSegment(Path path, Color activeColor, Color inactiveColor) {
      final color = isClosed ? activeColor : inactiveColor;
      final glowPaint = Paint()
        ..color = color.withValues(alpha: isClosed ? 0.35 : 0.0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      final wirePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, wirePaint);
    }

    // Ramo Principal (Vermelho -> Laranja -> Azul)
    final mainPathVcc = Path()
      ..moveTo(batteryX, centerY)
      ..lineTo(switchCenterX - 47.5, mainBranchY);
    final mainPathJumper = Path()
      ..moveTo(switchCenterX + 47.5, mainBranchY)
      ..lineTo(lampX, mainBranchY);

    // Ramo Paralelo (Inútil no topo)
    final parallelPath = Path()
      ..moveTo(batteryX + 15, mainBranchY)
      ..lineTo(batteryX + 15, topParallelY)
      ..lineTo(switchCenterX - 47.5, topParallelY)
      ..moveTo(switchCenterX + 47.5, topParallelY)
      ..lineTo(lampX - 15, topParallelY)
      ..lineTo(lampX - 15, mainBranchY);

    // Retorno do fundo (Azul)
    final returnPath = Path()
      ..moveTo(lampX, centerY + 47.5)
      ..lineTo(lampX, bottomWireY)
      ..lineTo(batteryX, bottomWireY)
      ..lineTo(batteryX, centerY + 47.5);

    drawWireSegment(mainPathVcc, const Color(0xFFEF4444), const Color(0xFF94A3B8));
    drawWireSegment(mainPathJumper, const Color(0xFFF97316), const Color(0xFF94A3B8));
    drawWireSegment(parallelPath, const Color(0xFFEF4444), const Color(0xFF94A3B8));
    drawWireSegment(returnPath, const Color(0xFF2563EB), const Color(0xFF94A3B8));

    // Bornes de Cobre
    void drawPin(Offset pos) {
      final pinPaint = Paint()..color = isClosed ? const Color(0xFFB87333) : const Color(0xFF64748B);
      canvas.drawCircle(pos, 4.5, pinPaint);
    }

    drawPin(Offset(switchCenterX - 47.5, topParallelY));
    drawPin(Offset(switchCenterX + 47.5, topParallelY));
    drawPin(Offset(switchCenterX - 47.5, mainBranchY));
    drawPin(Offset(switchCenterX + 47.5, mainBranchY));

    if (isClosed) {
      final electronGlow = Paint()
        ..color = const Color(0xFFFDE047)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
      final electronPaint = Paint()
        ..color = const Color(0xFFFEF08A)
        ..style = PaintingStyle.fill;

      final fullPath = Path()
        ..addPath(mainPathVcc, Offset.zero)
        ..addPath(mainPathJumper, Offset.zero)
        ..addPath(returnPath, Offset.zero);

      for (final metric in fullPath.computeMetrics()) {
        final length = metric.length;
        for (int i = 0; i < 12; i++) {
          final distance = ((animationValue + (i / 12)) % 1.0) * length;
          final tangent = metric.getTangentForOffset(distance);
          if (tangent != null) {
            canvas.drawCircle(tangent.position, 5.0, electronGlow);
            canvas.drawCircle(tangent.position, 3.5, electronPaint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// CustomPainter para circuito Bateria-Motor CC (2 componentes, sem chave)
class SchematicCircuitWirePainterMotor extends CustomPainter {
  final bool isClosed;
  final double animationValue;
  final Color wireColor;

  SchematicCircuitWirePainterMotor({
    required this.isClosed,
    required this.animationValue,
    this.wireColor = const Color(0xFF1E293B),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final batteryX = size.width * 0.18;
    final motorX = size.width * 0.82;
    final centerY = size.height * 0.48;
    final topWireY = 35.0;
    final bottomWireY = centerY + 75.0;

    void drawWireSegment(Path path, Color activeColor, Color inactiveColor) {
      final color = isClosed ? activeColor : inactiveColor;
      final glowPaint = Paint()
        ..color = color.withValues(alpha: isClosed ? 0.35 : 0.0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      final wirePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, wirePaint);
    }

    final topPathVcc = Path()
      ..moveTo(batteryX, centerY - 47.5)
      ..lineTo(batteryX, topWireY)
      ..lineTo(motorX, topWireY)
      ..lineTo(motorX, centerY - 47.5);

    final bottomPathGnd = Path()
      ..moveTo(motorX, centerY + 47.5)
      ..lineTo(motorX, bottomWireY)
      ..lineTo(batteryX, bottomWireY)
      ..lineTo(batteryX, centerY + 47.5);

    drawWireSegment(topPathVcc, const Color(0xFFEF4444), const Color(0xFF94A3B8));
    drawWireSegment(bottomPathGnd, const Color(0xFF2563EB), const Color(0xFF94A3B8));

    void drawPin(Offset pos) {
      final pinPaint = Paint()..color = isClosed ? const Color(0xFFB87333) : const Color(0xFF64748B);
      canvas.drawCircle(pos, 4.5, pinPaint);
    }

    drawPin(Offset(batteryX, centerY - 47.5));
    drawPin(Offset(batteryX, centerY + 47.5));
    drawPin(Offset(motorX, 70.0));
    drawPin(Offset(motorX, 145.0));

    if (isClosed) {
      final electronGlow = Paint()
        ..color = const Color(0xFFFDE047)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
      final electronPaint = Paint()
        ..color = const Color(0xFFFEF08A)
        ..style = PaintingStyle.fill;

      final fullPath = Path()
        ..addPath(topPathVcc, Offset.zero)
        ..addPath(bottomPathGnd, Offset.zero);

      const totalDots = 12;
      final metrics = fullPath.computeMetrics();
      for (final metric in metrics) {
        final length = metric.length;
        for (int i = 0; i < totalDots; i++) {
          final distance = ((animationValue + (i / totalDots)) % 1.0) * length;
          final tangent = metric.getTangentForOffset(distance);
          if (tangent != null) {
            canvas.drawCircle(tangent.position, 5.0, electronGlow);
            canvas.drawCircle(tangent.position, 3.5, electronPaint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
