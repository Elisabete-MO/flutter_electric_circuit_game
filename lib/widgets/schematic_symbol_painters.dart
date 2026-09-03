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
