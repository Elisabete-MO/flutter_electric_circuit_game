import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Painter customizado do Estande 09 (Horta Monitorada — Equipe Bio-Tech).
/// Renderiza:
/// - Modo Físico: Estufa com mudas de hortaliças, LED Grow Light cônico,
///   potenciômetro rotativo com dial graduado, sensor LDR fotossensível,
///   capacitor eletrolítico com efeito de carga e jumpers coloridos.
/// - Modo Esquemático: Simbologia IEC (potenciômetro com cursor, LDR com setas,
///   capacitor polarizado, LED emissor e fonte DC).
/// - Animação contínua de elétrons em fluxo na malha energizada.
class HortaMonitoradaPainter extends CustomPainter {
  final int missionIndex;
  final double animValue;
  final bool usePhysicalStyle;

  // Estados dos componentes
  final double potPercent; // 0.0 a 100.0%
  final double luxPercent; // 0.0 a 100.0% (Luz solar ambiente)
  final bool isLedOn;
  final double ledBrightness; // 0.0 a 1.0
  final bool isCapacitorCharging;
  final bool isCapacitorDischarging;
  final double capacitorChargeLevel; // 0.0 a 1.0
  final bool isNightMode;
  final bool isCircuitEnergized;

  HortaMonitoradaPainter({
    required this.missionIndex,
    required this.animValue,
    required this.usePhysicalStyle,
    this.potPercent = 60.0,
    this.luxPercent = 100.0,
    this.isLedOn = true,
    this.ledBrightness = 0.6,
    this.isCapacitorCharging = false,
    this.isCapacitorDischarging = false,
    this.capacitorChargeLevel = 0.0,
    this.isNightMode = false,
    this.isCircuitEnergized = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (usePhysicalStyle) {
      _paintPhysical(canvas, size);
    } else {
      _paintSchematic(canvas, size);
    }
  }

  // =========================================================================
  // MODO FÍSICO REALISTA
  // =========================================================================

  void _paintPhysical(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Bancada da Estufa / Canteiro Hidropônico (lado direito)
    final greenhouseRect = Rect.fromLTWH(
      w * 0.52,
      h * 0.20,
      w * 0.44,
      h * 0.68,
    );
    _drawGreenhouseBed(canvas, greenhouseRect);

    // 2. Módulo de Controle / Protoboard de Automação (lado esquerdo)
    final benchRect = Rect.fromLTWH(
      w * 0.04,
      h * 0.20,
      w * 0.44,
      h * 0.68,
    );
    _drawControlModule(canvas, benchRect);

    // 3. Conexões de Fiação / Jumpers entre Controle e Estufa
    _drawInterconnections(canvas, benchRect, greenhouseRect);
  }

  void _drawGreenhouseBed(Canvas canvas, Rect rect) {
    // Fundo da Estufa com vidro translúcido
    final glassPaint = Paint()
      ..color = isNightMode
          ? const Color(0xFF0F172A).withValues(alpha: 0.85)
          : const Color(0xFFE0F2FE).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    final framePaint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(16));
    canvas.drawRRect(rrect, glassPaint);
    canvas.drawRRect(rrect, framePaint);

    // Suporte da Luminária LED no topo da estufa
    final lampX = rect.center.dx;
    final lampY = rect.top + 30;

    // Cones de Luz do LED Grow Light
    if (isLedOn && ledBrightness > 0.05) {
      final beamPaint = Paint()
        ..shader = RadialGradient(
          center: Alignment.topCenter,
          radius: 0.9,
          colors: [
            const Color(0xFFEC4899).withValues(alpha: 0.45 * ledBrightness), // Rosa/Grow light
            const Color(0xFF3B82F6).withValues(alpha: 0.25 * ledBrightness),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(lampX - 120, lampY, 240, rect.height - 40));

      final beamPath = Path()
        ..moveTo(lampX - 16, lampY + 12)
        ..lineTo(lampX + 16, lampY + 12)
        ..lineTo(rect.right - 20, rect.bottom - 20)
        ..lineTo(rect.left + 20, rect.bottom - 20)
        ..close();
      canvas.drawPath(beamPath, beamPaint);
    }

    // Luminária LED Física
    final lampBodyPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(lampX, lampY), width: 70, height: 18),
        const Radius.circular(6),
      ),
      lampBodyPaint,
    );

    // Emissores LED
    for (int i = -2; i <= 2; i++) {
      final emitterColor = isLedOn && ledBrightness > 0.05
          ? (i.isEven ? const Color(0xFFF43F5E) : const Color(0xFF38BDF8))
          : const Color(0xFF475569);
      canvas.drawCircle(
        Offset(lampX + i * 12, lampY + 4),
        3.5,
        Paint()..color = emitterColor,
      );
    }

    // Bandeja de Plantas na base
    final trayRect = Rect.fromLTWH(
      rect.left + 16,
      rect.bottom - 50,
      rect.width - 32,
      38,
    );
    final trayPaint = Paint()..color = const Color(0xFF3B2F2F); // Substrato orgânico
    canvas.drawRRect(
      RRect.fromRectAndRadius(trayRect, const Radius.circular(8)),
      trayPaint,
    );

    // Mudas de plantas crescendo
    final plantCount = 4;
    final spacing = trayRect.width / (plantCount + 1);
    for (int i = 1; i <= plantCount; i++) {
      final plantX = trayRect.left + i * spacing;
      final plantY = trayRect.top + 4;
      _drawSprout(canvas, plantX, plantY);
    }

    // Rótulo da Estufa
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'ESTUFA BIO-TECH',
        style: GoogleFonts.rajdhani(
          color: isNightMode ? const Color(0xFF94A3B8) : const Color(0xFF475569),
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(rect.left + 16, rect.top + 10));
  }

  void _drawSprout(Canvas canvas, double x, double y) {
    final stemPaint = Paint()
      ..color = const Color(0xFF16A34A)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(x, y + 10), Offset(x, y - 14), stemPaint);

    // Folhas
    final leafPaint = Paint()
      ..color = const Color(0xFF22C55E)
      ..style = PaintingStyle.fill;

    // Folha esquerda
    final leftPath = Path()
      ..moveTo(x, y - 10)
      ..quadraticBezierTo(x - 12, y - 18, x - 14, y - 8)
      ..quadraticBezierTo(x - 6, y - 4, x, y - 8)
      ..close();
    canvas.drawPath(leftPath, leafPaint);

    // Folha direita
    final rightPath = Path()
      ..moveTo(x, y - 12)
      ..quadraticBezierTo(x + 12, y - 20, x + 14, y - 10)
      ..quadraticBezierTo(x + 6, y - 6, x, y - 10)
      ..close();
    canvas.drawPath(rightPath, leafPaint);
  }

  void _drawControlModule(Canvas canvas, Rect rect) {
    // Placa de montagem da automação
    final boardPaint = Paint()..color = const Color(0xFF1E293B);
    final borderPaint = Paint()
      ..color = const Color(0xFF475569)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(16));
    canvas.drawRRect(rrect, boardPaint);
    canvas.drawRRect(rrect, borderPaint);

    // 1. Potenciômetro Rotativo (Canto Superior)
    final potCenter = Offset(rect.left + rect.width * 0.32, rect.top + rect.height * 0.30);
    _drawPotentiometer(canvas, potCenter);

    // 2. Sensor LDR com detector óptico (Canto Superior Direito)
    final ldrCenter = Offset(rect.left + rect.width * 0.75, rect.top + rect.height * 0.30);
    _drawLdrSensor(canvas, ldrCenter);

    // 3. Capacitor Eletrolítico de Reserva (Canto Inferior Esquerdo)
    final capCenter = Offset(rect.left + rect.width * 0.32, rect.top + rect.height * 0.74);
    _drawCapacitor(canvas, capCenter);

    // 4. Fonte de Alimentação 5V DC (Canto Inferior Direito)
    final psuCenter = Offset(rect.left + rect.width * 0.75, rect.top + rect.height * 0.74);
    _drawPowerSupply(canvas, psuCenter);
  }

  void _drawPotentiometer(Canvas canvas, Offset center) {
    // Dial exterior graduado
    final outerDialPaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 30, outerDialPaint);

    // Arco de valor
    final arcRect = Rect.fromCircle(center: center, radius: 26);
    final arcPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (potPercent / 100.0) * (math.pi * 1.5);
    canvas.drawArc(arcRect, math.pi * 0.75, sweepAngle, false, arcPaint);

    // Knob central giratório
    final knobPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawCircle(center, 18, knobPaint);

    // Indicador do ponteiro
    final pointerAngle = math.pi * 0.75 + sweepAngle;
    final pointerEnd = Offset(
      center.dx + math.cos(pointerAngle) * 16,
      center.dy + math.sin(pointerAngle) * 16,
    );
    canvas.drawLine(
      center,
      pointerEnd,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round,
    );

    // Texto
    final tp = TextPainter(
      text: TextSpan(
        text: 'POT: ${potPercent.toStringAsFixed(0)}%',
        style: GoogleFonts.rajdhani(
          color: Colors.white70,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy + 34));
  }

  void _drawLdrSensor(Canvas canvas, Offset center) {
    // Base cerâmica redonda do LDR
    final ldrBasePaint = Paint()..color = const Color(0xFFFBBF24);
    canvas.drawCircle(center, 22, ldrBasePaint);

    // Trilha serpentina fotossensível
    final trackPaint = Paint()
      ..color = const Color(0xFFB45309)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(center.dx - 12, center.dy - 8)
      ..lineTo(center.dx + 12, center.dy - 8)
      ..lineTo(center.dx + 12, center.dy - 2)
      ..lineTo(center.dx - 12, center.dy - 2)
      ..lineTo(center.dx - 12, center.dy + 4)
      ..lineTo(center.dx + 12, center.dy + 4)
      ..lineTo(center.dx + 12, center.dy + 10)
      ..lineTo(center.dx - 12, center.dy + 10);
    canvas.drawPath(path, trackPaint);

    // Raios de luz incidentes
    final sunColor = isNightMode
        ? const Color(0xFF64748B)
        : const Color(0xFFFDE047).withValues(alpha: (luxPercent / 100.0).clamp(0.2, 1.0));
    final rayPaint = Paint()
      ..color = sunColor
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 3; i++) {
      final start = Offset(center.dx + 26 + i * 4, center.dy - 26 + i * 4);
      final end = Offset(center.dx + 12 + i * 4, center.dy - 12 + i * 4);
      canvas.drawLine(start, end, rayPaint);
    }

    final tp = TextPainter(
      text: TextSpan(
        text: isNightMode ? 'LDR: NOITE' : 'LDR: ${luxPercent.toStringAsFixed(0)}%',
        style: GoogleFonts.rajdhani(
          color: Colors.white70,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy + 26));
  }

  void _drawCapacitor(Canvas canvas, Offset center) {
    // Corpo cilíndrico do capacitor eletrolítico
    final capRect = Rect.fromCenter(center: center, width: 28, height: 42);
    final capPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6), Color(0xFF1E3A8A)],
      ).createShader(capRect);
    canvas.drawRRect(RRect.fromRectAndRadius(capRect, const Radius.circular(6)), capPaint);

    // Faixa negativa (branca/cinza)
    final stripeRect = Rect.fromLTWH(capRect.left + 2, capRect.top, 6, capRect.height);
    canvas.drawRect(stripeRect, Paint()..color = const Color(0xFFCBD5E1));

    // Indicador de Carga (barra de preenchimento ou glow)
    if (capacitorChargeLevel > 0.05) {
      final glowPaint = Paint()
        ..color = const Color(0xFF38BDF8).withValues(alpha: 0.5 * capacitorChargeLevel)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawRRect(RRect.fromRectAndRadius(capRect, const Radius.circular(6)), glowPaint);
    }

    final tp = TextPainter(
      text: TextSpan(
        text: 'CAP: ${(capacitorChargeLevel * 100).toStringAsFixed(0)}%',
        style: GoogleFonts.rajdhani(
          color: Colors.white70,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy + 26));
  }

  void _drawPowerSupply(Canvas canvas, Offset center) {
    final psuRect = Rect.fromCenter(center: center, width: 44, height: 38);
    final psuPaint = Paint()..color = const Color(0xFF0F172A);
    final borderPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(RRect.fromRectAndRadius(psuRect, const Radius.circular(8)), psuPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(psuRect, const Radius.circular(8)), borderPaint);

    final tp = TextPainter(
      text: TextSpan(
        text: '5V DC\nFONTE',
        style: GoogleFonts.rajdhani(
          color: const Color(0xFF10B981),
          fontWeight: FontWeight.bold,
          fontSize: 9,
          height: 1.1,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  void _drawInterconnections(Canvas canvas, Rect ctrlRect, Rect greenRect) {
    final wirePaint = Paint()
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final electronPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;

    // Fio Positivo (Vermelho) -> Controle -> LED na estufa
    final p1 = Offset(ctrlRect.right - 10, ctrlRect.top + 40);
    final p2 = Offset(greenRect.left + 20, greenRect.top + 30);
    final pControl = Offset((p1.dx + p2.dx) / 2, p1.dy - 20);

    final pathPos = Path()
      ..moveTo(p1.dx, p1.dy)
      ..quadraticBezierTo(pControl.dx, pControl.dy, p2.dx, p2.dy);
    wirePaint.color = const Color(0xFFEF4444);
    canvas.drawPath(pathPos, wirePaint);

    // Fio Negativo (Preto/Azul escuro)
    final p3 = Offset(greenRect.left + 20, greenRect.top + 42);
    final p4 = Offset(ctrlRect.right - 10, ctrlRect.bottom - 40);
    final pControl2 = Offset((p3.dx + p4.dx) / 2, p4.dy + 20);

    final pathNeg = Path()
      ..moveTo(p3.dx, p3.dy)
      ..quadraticBezierTo(pControl2.dx, pControl2.dy, p4.dx, p4.dy);
    wirePaint.color = const Color(0xFF1E293B);
    canvas.drawPath(pathNeg, wirePaint);

    // Animação de Elétrons se o circuito estiver com corrente
    if (isCircuitEnergized && isLedOn && ledBrightness > 0.05) {
      final metrics = pathPos.computeMetrics().toList();
      if (metrics.isNotEmpty) {
        final metric = metrics.first;
        for (int i = 0; i < 4; i++) {
          final t = (animValue + i * 0.25) % 1.0;
          final tangent = metric.getTangentForOffset(metric.length * t);
          if (tangent != null) {
            canvas.drawCircle(tangent.position, 4.0, electronPaint);
          }
        }
      }
    }
  }

  // =========================================================================
  // MODO ESQUEMÁTICO TÉCNICO (IEC)
  // =========================================================================

  void _paintSchematic(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final wirePaint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final rect = Rect.fromLTWH(w * 0.15, h * 0.22, w * 0.70, h * 0.56);

    // Malha retangular principal
    canvas.drawRect(rect, wirePaint);

    // Fonte 5V DC (Ramo Esquerdo)
    _drawSchematicBattery(canvas, Offset(rect.left, rect.center.dy));

    // Potenciômetro (Ramo Superior Esquerdo)
    _drawSchematicPotentiometer(canvas, Offset(rect.left + rect.width * 0.33, rect.top));

    // LDR Sensor (Ramo Superior Direito)
    _drawSchematicLdr(canvas, Offset(rect.left + rect.width * 0.66, rect.top));

    // LED Grow Light (Ramo Direito)
    _drawSchematicLed(canvas, Offset(rect.right, rect.center.dy));

    // Capacitor (Ramo Inferior Central)
    _drawSchematicCapacitor(canvas, Offset(rect.center.dx, rect.bottom));

    // Elétrons esquemáticos
    if (isCircuitEnergized && isLedOn) {
      final path = Path()
        ..addRect(rect);
      final metric = path.computeMetrics().first;
      final electronPaint = Paint()..color = const Color(0xFFF59E0B);
      for (int i = 0; i < 6; i++) {
        final t = (animValue + i * (1.0 / 6.0)) % 1.0;
        final tangent = metric.getTangentForOffset(metric.length * t);
        if (tangent != null) {
          canvas.drawCircle(tangent.position, 4.0, electronPaint);
        }
      }
    }
  }

  void _drawSchematicBattery(Canvas canvas, Offset center) {
    final bgPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(Rect.fromCenter(center: center, width: 24, height: 40), bgPaint);

    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.square;

    // Placa positiva longa
    canvas.drawLine(Offset(center.dx - 14, center.dy - 8), Offset(center.dx + 14, center.dy - 8), linePaint);
    // Placa negativa curta
    canvas.drawLine(Offset(center.dx - 8, center.dy + 8), Offset(center.dx + 8, center.dy + 8), linePaint..strokeWidth = 4.0);

    final tp = TextPainter(
      text: TextSpan(
        text: '5V DC',
        style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width - 18, center.dy - 6));
  }

  void _drawSchematicPotentiometer(Canvas canvas, Offset center) {
    final bgPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(Rect.fromCenter(center: center, width: 44, height: 26), bgPaint);

    // Resistor retangular
    final rPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawRect(Rect.fromCenter(center: center, width: 34, height: 14), rPaint);

    // Seta do wiper
    final arrowPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(center.dx - 12, center.dy + 16), Offset(center.dx, center.dy + 7), arrowPaint);

    final tp = TextPainter(
      text: TextSpan(
        text: 'R_POT (${potPercent.toStringAsFixed(0)}%)',
        style: GoogleFonts.rajdhani(color: const Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - 22));
  }

  void _drawSchematicLdr(Canvas canvas, Offset center) {
    final bgPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(Rect.fromCenter(center: center, width: 44, height: 26), bgPaint);

    final rPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawRect(Rect.fromCenter(center: center, width: 34, height: 14), rPaint);

    // Setas de luz incidindo
    final arrowPaint = Paint()
      ..color = const Color(0xFFFBBF24)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(center.dx - 16, center.dy - 18), Offset(center.dx - 8, center.dy - 9), arrowPaint);
    canvas.drawLine(Offset(center.dx - 10, center.dy - 18), Offset(center.dx - 2, center.dy - 9), arrowPaint);

    final tp = TextPainter(
      text: TextSpan(
        text: 'LDR (${luxPercent.toStringAsFixed(0)}%)',
        style: GoogleFonts.rajdhani(color: const Color(0xFFFBBF24), fontSize: 10, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - 22));
  }

  void _drawSchematicLed(Canvas canvas, Offset center) {
    final bgPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(Rect.fromCenter(center: center, width: 30, height: 44), bgPaint);

    // Triângulo do diodo
    final dPaint = Paint()
      ..color = isLedOn ? const Color(0xFFEC4899) : Colors.white
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(center.dx - 10, center.dy - 10)
      ..lineTo(center.dx + 10, center.dy - 10)
      ..lineTo(center.dx, center.dy + 8)
      ..close();
    canvas.drawPath(path, dPaint);

    // Barra de cátodo
    canvas.drawLine(
      Offset(center.dx - 10, center.dy + 8),
      Offset(center.dx + 10, center.dy + 8),
      Paint()
        ..color = isLedOn ? const Color(0xFFEC4899) : Colors.white
        ..strokeWidth = 2.5,
    );

    // Setas de emissão de luz
    final arrowPaint = Paint()
      ..color = const Color(0xFFEC4899)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(center.dx + 12, center.dy - 2), Offset(center.dx + 20, center.dy - 8), arrowPaint);
    canvas.drawLine(Offset(center.dx + 14, center.dy + 4), Offset(center.dx + 22, center.dy - 2), arrowPaint);

    final tp = TextPainter(
      text: TextSpan(
        text: 'LED GROW',
        style: GoogleFonts.rajdhani(color: const Color(0xFFEC4899), fontSize: 10, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx + 26, center.dy - 6));
  }

  void _drawSchematicCapacitor(Canvas canvas, Offset center) {
    final bgPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(Rect.fromCenter(center: center, width: 36, height: 26), bgPaint);

    final platePaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..strokeWidth = 3.0;

    // Duas placas paralelas
    canvas.drawLine(Offset(center.dx - 5, center.dy - 12), Offset(center.dx - 5, center.dy + 12), platePaint);
    canvas.drawLine(Offset(center.dx + 5, center.dy - 12), Offset(center.dx + 5, center.dy + 12), platePaint);

    final tp = TextPainter(
      text: TextSpan(
        text: 'C_BACKUP (470µF)',
        style: GoogleFonts.rajdhani(color: const Color(0xFF38BDF8), fontSize: 10, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy + 16));
  }

  @override
  bool shouldRepaint(covariant HortaMonitoradaPainter oldDelegate) {
    return oldDelegate.animValue != animValue ||
        oldDelegate.usePhysicalStyle != usePhysicalStyle ||
        oldDelegate.potPercent != potPercent ||
        oldDelegate.luxPercent != luxPercent ||
        oldDelegate.isLedOn != isLedOn ||
        oldDelegate.ledBrightness != ledBrightness ||
        oldDelegate.isCapacitorCharging != isCapacitorCharging ||
        oldDelegate.isCapacitorDischarging != isCapacitorDischarging ||
        oldDelegate.capacitorChargeLevel != capacitorChargeLevel ||
        oldDelegate.isNightMode != isNightMode ||
        oldDelegate.isCircuitEnergized != isCircuitEnergized;
  }
}
