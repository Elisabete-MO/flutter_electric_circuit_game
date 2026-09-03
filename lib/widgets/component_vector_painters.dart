import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Desenhos Vetoriais de Alta Fidelidade (CustomPainters) para Componentes Eletrônicos

// ==========================================================
// 1. VETOR: MOTOR CC DIDÁTICO COM HÉLICE
// ==========================================================
class MotorCcVectorWidget extends StatelessWidget {
  final double size;
  final bool isRunning;
  final double angle; // Ângulo de rotação da hélice em radianos

  const MotorCcVectorWidget({
    super.key,
    this.size = 48.0,
    this.isRunning = false,
    this.angle = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MotorCcPainter(isRunning: isRunning, angle: angle),
      ),
    );
  }
}

class _MotorCcPainter extends CustomPainter {
  final bool isRunning;
  final double angle;

  _MotorCcPainter({required this.isRunning, required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.2;

    // Corpo metálico prateado (Gradiente radial)
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF94A3B8),
          const Color(0xFF475569),
          const Color(0xFF1E293B),
        ],
        center: Alignment.topLeft,
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, bodyPaint);

    // Contorno Neon Cyberpunk
    final borderPaint = Paint()
      ..color = isRunning ? const Color(0xFF10B981) : const Color(0xFF64748B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, radius, borderPaint);

    // Terminais de Conexão (+ / -)
    final terminalPaint = Paint()..color = const Color(0xFFCBD5E1);
    canvas.drawRect(Rect.fromLTWH(center.dx - radius - 3, center.dy - 4, 4, 8), terminalPaint);
    canvas.drawRect(Rect.fromLTWH(center.dx + radius - 1, center.dy - 4, 4, 8), terminalPaint);

    // Eixo Central Metallico
    final axlePaint = Paint()..color = const Color(0xFFE2E8F0);
    canvas.drawCircle(center, radius * 0.25, axlePaint);

    // Hélice de 3 Pás Rotativa
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final bladePaint = Paint()
      ..color = isRunning ? const Color(0xFF34D399) : const Color(0xFF38BDF8)
      ..style = PaintingStyle.fill;

    final bladeBorder = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 0; i < 3; i++) {
      final bladePath = Path();
      bladePath.moveTo(0, 0);
      bladePath.quadraticBezierTo(radius * 0.4, -radius * 0.5, 0, -radius * 0.85);
      bladePath.quadraticBezierTo(-radius * 0.4, -radius * 0.5, 0, 0);
      bladePath.close();

      canvas.drawPath(bladePath, bladePaint);
      canvas.drawPath(bladePath, bladeBorder);
      canvas.rotate(2 * math.pi / 3);
    }

    canvas.restore();

    // Capa Central
    canvas.drawCircle(center, radius * 0.15, Paint()..color = const Color(0xFF0F172A));
  }

  @override
  bool shouldRepaint(covariant _MotorCcPainter oldDelegate) {
    return oldDelegate.isRunning != isRunning || oldDelegate.angle != angle;
  }
}

// ==========================================================
// 2. VETOR: LED INDICADOR (ÂNODE / CÂTODO)
// ==========================================================
class LedVectorWidget extends StatelessWidget {
  final double size;
  final Color ledColor;
  final bool isOn;

  const LedVectorWidget({
    super.key,
    this.size = 48.0,
    this.ledColor = Colors.redAccent,
    this.isOn = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _LedPainter(ledColor: ledColor, isOn: isOn),
      ),
    );
  }
}

class _LedPainter extends CustomPainter {
  final Color ledColor;
  final bool isOn;

  _LedPainter({required this.ledColor, required this.isOn});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Pernas / Terminais Metálicos (Ânodo longo +, Cátodo curto -)
    final legPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Anodo (Esquerda - mais longo)
    canvas.drawLine(Offset(w * 0.38, h * 0.5), Offset(w * 0.38, h * 0.95), legPaint);
    // Catodo (Direita - mais curto)
    canvas.drawLine(Offset(w * 0.62, h * 0.5), Offset(w * 0.62, h * 0.85), legPaint);

    // Domo de Vidro Transparente do LED
    final domePath = Path();
    domePath.moveTo(w * 0.25, h * 0.55);
    domePath.lineTo(w * 0.25, h * 0.35);
    domePath.arcToPoint(
      Offset(w * 0.75, h * 0.35),
      radius: Radius.circular(w * 0.25),
      clockwise: true,
    );
    domePath.lineTo(w * 0.75, h * 0.55);
    domePath.close();

    // Glow Efeito se Ligado
    if (isOn) {
      final glowPaint = Paint()
        ..color = ledColor.withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawPath(domePath, glowPaint);
    }

    // Corpo de Vidro Colorido
    final glassPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          isOn ? Colors.white : ledColor.withValues(alpha: 0.8),
          ledColor,
          isOn ? ledColor : const Color(0xFF1E293B),
        ],
        center: const Alignment(-0.3, -0.4),
      ).createShader(domePath.getBounds());

    canvas.drawPath(domePath, glassPaint);

    // Anel de Base Flangeada do LED
    final flangePath = Path();
    flangePath.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.2, h * 0.53, w * 0.6, h * 0.08),
      const Radius.circular(3),
    ));
    canvas.drawPath(flangePath, Paint()..color = ledColor.withValues(alpha: 0.9));

    // Elemento Interno (Anvil e Post)
    final internalPaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(w * 0.42, h * 0.5), Offset(w * 0.45, h * 0.35), internalPaint);
    canvas.drawLine(Offset(w * 0.58, h * 0.5), Offset(w * 0.55, h * 0.38), internalPaint);
  }

  @override
  bool shouldRepaint(covariant _LedPainter oldDelegate) {
    return oldDelegate.ledColor != ledColor || oldDelegate.isOn != isOn;
  }
}

// ==========================================================
// 3. VETOR: RESISTOR DE PROTEÇÃO COM FAIXAS DE COR
// ==========================================================
class ResistorVectorWidget extends StatelessWidget {
  final double size;
  final String resistanceValue; // ex: "680"

  const ResistorVectorWidget({
    super.key,
    this.size = 48.0,
    this.resistanceValue = '680',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ResistorPainter(resistanceValue: resistanceValue),
      ),
    );
  }
}

class _ResistorPainter extends CustomPainter {
  final String resistanceValue;

  _ResistorPainter({required this.resistanceValue});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final centerY = h / 2;

    // Fios Condutores Axiais
    final wirePaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(w * 0.05, centerY), Offset(w * 0.25, centerY), wirePaint);
    canvas.drawLine(Offset(w * 0.75, centerY), Offset(w * 0.95, centerY), wirePaint);

    // Corpo Cerâmico (Bege / Creme / Tan)
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.22, centerY - (h * 0.18), w * 0.56, h * 0.36),
      const Radius.circular(8),
    );

    final bodyPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFFDE68A),
          const Color(0xFFF59E0B),
          const Color(0xFFD97706),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(bodyRect.outerRect);

    canvas.drawRRect(bodyRect, bodyPaint);
    canvas.drawRRect(bodyRect, Paint()..color = const Color(0xFF78350F)..style = PaintingStyle.stroke..strokeWidth = 1.2);

    // Faixas de Código de Cores do Resistor (Para 680Ω: Azul, Cinza, Castanho, Dourado)
    final band1 = Paint()..color = Colors.blue.shade800; // 6
    final band2 = Paint()..color = Colors.grey.shade800; // 8
    final band3 = Paint()..color = Colors.brown.shade700; // 10^1 (x10 = 680)
    final bandGold = Paint()..color = const Color(0xFFF59E0B); // Tolerância 5%

    final bandWidth = w * 0.06;
    final bandHeight = h * 0.36;
    final startY = centerY - (bandHeight / 2);

    canvas.drawRect(Rect.fromLTWH(w * 0.30, startY, bandWidth, bandHeight), band1);
    canvas.drawRect(Rect.fromLTWH(w * 0.40, startY, bandWidth, bandHeight), band2);
    canvas.drawRect(Rect.fromLTWH(w * 0.50, startY, bandWidth, bandHeight), band3);
    canvas.drawRect(Rect.fromLTWH(w * 0.65, startY, bandWidth, bandHeight), bandGold);
  }

  @override
  bool shouldRepaint(covariant _ResistorPainter oldDelegate) => false;
}

// ==========================================================
// 4. VETOR: INTERRUPTOR PUSH-BUTTON (PRESSÃO)
// ==========================================================
class PushButtonVectorWidget extends StatelessWidget {
  final double size;
  final bool isPressed;

  const PushButtonVectorWidget({
    super.key,
    this.size = 48.0,
    this.isPressed = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PushButtonPainter(isPressed: isPressed),
      ),
    );
  }
}

class _PushButtonPainter extends CustomPainter {
  final bool isPressed;

  _PushButtonPainter({required this.isPressed});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Base Quadrada Metálica de Modulo Tactile
    final baseRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.15, h * 0.25, w * 0.7, h * 0.6),
      const Radius.circular(8),
    );

    final basePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF475569), Color(0xFF1E293B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(baseRect.outerRect);

    canvas.drawRRect(baseRect, basePaint);

    // 4 Pinos Metálicos nos Cantos
    final pinPaint = Paint()..color = const Color(0xFFCBD5E1);
    canvas.drawRect(Rect.fromLTWH(w * 0.05, h * 0.3, w * 0.1, h * 0.1), pinPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.05, h * 0.6, w * 0.1, h * 0.1), pinPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.85, h * 0.3, w * 0.1, h * 0.1), pinPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.85, h * 0.6, w * 0.1, h * 0.1), pinPaint);

    // Botão Vermelho de Atuação Central
    final buttonOffsetY = isPressed ? h * 0.05 : 0.0;
    final capRadius = w * 0.22;
    final capCenter = Offset(w * 0.5, (h * 0.55) + buttonOffsetY);

    final capPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          isPressed ? Colors.redAccent : const Color(0xFFEF4444),
          const Color(0xFFB91C1C),
        ],
        center: Alignment.topLeft,
      ).createShader(Rect.fromCircle(center: capCenter, radius: capRadius));

    canvas.drawCircle(capCenter, capRadius, capPaint);
    canvas.drawCircle(capCenter, capRadius, Paint()..color = Colors.red.shade900..style = PaintingStyle.stroke..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(covariant _PushButtonPainter oldDelegate) {
    return oldDelegate.isPressed != isPressed;
  }
}

// ==========================================================
// 5. VETOR: BATERIA DIDÁTICA (4.5V / 9V)
// ==========================================================
class BatteryVectorWidget extends StatelessWidget {
  final double size;

  const BatteryVectorWidget({super.key, this.size = 48.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _BatteryPainter()),
    );
  }
}

class _BatteryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Corpo da Bateria
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.2, h * 0.25, w * 0.6, h * 0.65),
      const Radius.circular(6),
    );

    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0F766E), Color(0xFF064E3B), Color(0xFF022C22)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bodyRect.outerRect);

    canvas.drawRRect(bodyRect, bodyPaint);
    canvas.drawRRect(bodyRect, Paint()..color = const Color(0xFF10B981)..style = PaintingStyle.stroke..strokeWidth = 1.5);

    // Pólos / Terminais da Bateria (+ e -)
    final posTerm = Paint()..color = const Color(0xFFEF4444);
    final negTerm = Paint()..color = const Color(0xFF3B82F6);

    canvas.drawRect(Rect.fromLTWH(w * 0.3, h * 0.12, w * 0.14, h * 0.13), posTerm);
    canvas.drawRect(Rect.fromLTWH(w * 0.56, h * 0.12, w * 0.14, h * 0.13), negTerm);

    // Rótulo 9V / 4.5V
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '4.5V',
        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(w * 0.32, h * 0.48));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==========================================================
// 6. VETOR: LÂMPADA INCANDESCENTE
// ==========================================================
class BulbVectorWidget extends StatelessWidget {
  final double size;
  final bool isOn;

  const BulbVectorWidget({super.key, this.size = 48.0, this.isOn = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _BulbPainter(isOn: isOn)),
    );
  }
}

class _BulbPainter extends CustomPainter {
  final bool isOn;

  _BulbPainter({required this.isOn});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Glow amarelado se aceso
    if (isOn) {
      canvas.drawCircle(
        Offset(w * 0.5, h * 0.4),
        w * 0.35,
        Paint()
          ..color = Colors.amber.withValues(alpha: 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }

    // Domo de Vidro
    final glassPath = Path();
    glassPath.addOval(Rect.fromCircle(center: Offset(w * 0.5, h * 0.38), radius: w * 0.28));

    final glassPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          isOn ? Colors.amberAccent : Colors.white24,
          isOn ? Colors.amber : const Color(0xFF334155),
        ],
      ).createShader(glassPath.getBounds());

    canvas.drawPath(glassPath, glassPaint);

    // Base Rosqueada Metálica de Latão
    final basePaint = Paint()..color = const Color(0xFFD97706);
    canvas.drawRect(Rect.fromLTWH(w * 0.38, h * 0.62, w * 0.24, h * 0.2), basePaint);

    // Filamento interno de Tungstênio
    final filamentPaint = Paint()
      ..color = isOn ? Colors.white : Colors.amber
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final filPath = Path();
    filPath.moveTo(w * 0.42, h * 0.50);
    filPath.lineTo(w * 0.47, h * 0.32);
    filPath.lineTo(w * 0.53, h * 0.32);
    filPath.lineTo(w * 0.58, h * 0.50);
    canvas.drawPath(filPath, filamentPaint);
  }

  @override
  bool shouldRepaint(covariant _BulbPainter oldDelegate) => oldDelegate.isOn != isOn;
}

// ==========================================================
// 7. VETOR: MULTÍMETRO DIGITAL / MEDIDOR DE PANEL
// ==========================================================
class MeterVectorWidget extends StatelessWidget {
  final double size;
  final String meterType; // 'V' ou 'A'
  final Color accentColor;

  const MeterVectorWidget({
    super.key,
    this.size = 48.0,
    this.meterType = 'V',
    this.accentColor = const Color(0xFF0284C7),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _MeterPainter(meterType: meterType, accentColor: accentColor)),
    );
  }
}

class _MeterPainter extends CustomPainter {
  final String meterType;
  final Color accentColor;

  _MeterPainter({required this.meterType, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final radius = w * 0.42;

    // Corpo do medidor (gradiente escuro)
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.08, h * 0.08, w * 0.84, h * 0.84),
      Radius.circular(radius * 0.25),
    );
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1E293B), Color(0xFF0F172A), Color(0xFF020617)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bodyRect.outerRect);
    canvas.drawRRect(bodyRect, bodyPaint);

    // Borda externa
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..color = accentColor.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Display digital
    final displayRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.18, h * 0.18, w * 0.64, h * 0.28),
      const Radius.circular(4),
    );
    canvas.drawRRect(
      displayRect,
      Paint()..color = const Color(0xFF064E3B),
    );
    canvas.drawRRect(
      displayRect,
      Paint()
        ..color = const Color(0xFF10B981).withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // Símbolo do tipo no display
    final symbolPainter = TextPainter(
      text: TextSpan(
        text: meterType == 'V' ? 'V' : 'mA',
        style: TextStyle(
          color: const Color(0xFF34D399),
          fontSize: size.width * 0.16,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    symbolPainter.layout();
    symbolPainter.paint(
      canvas,
      Offset(cx - symbolPainter.width / 2, h * 0.22),
    );

    // Marcas de escala (pseudo-analog)
    final scalePaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i <= 10; i++) {
      final angle = -math.pi * 0.75 + (i / 10) * math.pi * 1.5;
      final innerR = radius * 0.55;
      final outerR = radius * 0.72;
      final p1 = Offset(cx + math.cos(angle) * innerR, cy + math.sin(angle) * innerR);
      final p2 = Offset(cx + math.cos(angle) * outerR, cy + math.sin(angle) * outerR);
      canvas.drawLine(p1, p2, scalePaint);
    }

    // Agulha (apontando para ~70% da escala)
    final needleAngle = -math.pi * 0.75 + 0.7 * math.pi * 1.5;
    final needleLen = radius * 0.68;
    final needlePaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + math.cos(needleAngle) * needleLen, cy + math.sin(needleAngle) * needleLen),
      needlePaint,
    );

    // Pivô da agulha
    canvas.drawCircle(Offset(cx, cy), 2.5, Paint()..color = const Color(0xFFCBD5E1));

    // Terminais de conexão (inferior)
    final terminalRed = Paint()..color = const Color(0xFFEF4444);
    final terminalBlack = Paint()..color = const Color(0xFF1E293B);
    canvas.drawCircle(Offset(w * 0.3, h * 0.88), w * 0.06, terminalRed);
    canvas.drawCircle(Offset(w * 0.7, h * 0.88), w * 0.06, terminalBlack);
    canvas.drawCircle(Offset(w * 0.3, h * 0.88), w * 0.03, Paint()..color = Colors.white24);
    canvas.drawCircle(Offset(w * 0.7, h * 0.88), w * 0.03, Paint()..color = Colors.white24);
  }

  @override
  bool shouldRepaint(covariant _MeterPainter oldDelegate) =>
      oldDelegate.meterType != meterType || oldDelegate.accentColor != accentColor;
}
