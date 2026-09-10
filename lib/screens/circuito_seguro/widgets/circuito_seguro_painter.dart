import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Painter de Alta Fidelidade do Estande 08 (Circuito Seguro — Equipe Segurança).
/// Renderiza:
/// - Protoboard Central realista de 830 pontos com canal central e barramentos (+/-)
/// - Bateria 9V Horizontal à direita com acabamento em cobre, terminais e snap clip
/// - Porta-fusível de vidro 5x20mm montado na Protoboard com filamento íntegro/fundido
/// - Chave Seccionadora de Segurança com flip guard vermelho móvel
/// - Resistor de precisão com anéis de cores e LED 5mm de alta luminosidade
/// - Buzzer piezoelétrico para sinalização sonora de segurança
/// - Cabos jumpers realistas em curvas catenárias com pinos encaixados nos furos
/// - Pontas de teste de continuidade e efeito de faíscas/sobrecorrente em curto
/// - Modo Esquemático Técnico IEC/ABNT normatizado
class CircuitoSeguroPainter extends CustomPainter {
  final int missionIndex;
  final double animValue;
  final bool usePhysicalStyle;

  // Estados dos Componentes
  final bool isArmingSwitchClosed;
  final bool isShortCircuitActive;
  final bool isWireBroken;
  final bool isWireRepaired;
  final bool isFuseInserted;
  final bool isFuseBlown;
  final bool isFuseCorrectRating;
  final bool isLedInserted;
  final bool isResistorInserted;
  final bool isBuzzerActive;
  final bool isTestingContinuity;
  final bool isContinuityOk;

  CircuitoSeguroPainter({
    required this.missionIndex,
    required this.animValue,
    required this.usePhysicalStyle,
    this.isArmingSwitchClosed = true,
    this.isShortCircuitActive = false,
    this.isWireBroken = false,
    this.isWireRepaired = true,
    this.isFuseInserted = true,
    this.isFuseBlown = false,
    this.isFuseCorrectRating = true,
    this.isLedInserted = true,
    this.isResistorInserted = true,
    this.isBuzzerActive = false,
    this.isTestingContinuity = false,
    this.isContinuityOk = false,
  });

  bool get isCircuitEnergized =>
      isArmingSwitchClosed &&
      !isShortCircuitActive &&
      (!isWireBroken || isWireRepaired) &&
      (isFuseInserted && !isFuseBlown);

  @override
  void paint(Canvas canvas, Size size) {
    if (usePhysicalStyle) {
      _paintPhysicalWorkbench(canvas, size);
    } else {
      _paintSchematicWorkbench(canvas, size);
    }
  }

  // =========================================================================
  // MODO FÍSICO REALISTA (Protoboard Central, Bateria 9V Horizontal e Componentes)
  // =========================================================================

  void _paintPhysicalWorkbench(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Dimensões e Proporções da Protoboard Central
    final bbLeft = (w * 0.18).clamp(120.0, 240.0);
    final bbWidth = (w * 0.54).clamp(320.0, 560.0);
    final bbTop = (h * 0.22).clamp(70.0, 110.0);
    final bbHeight = (h * 0.56).clamp(180.0, 260.0);
    final breadboardRect = Rect.fromLTWH(bbLeft, bbTop, bbWidth, bbHeight);

    // 2. Bateria 9V na HORIZONTAL (à direita da Protoboard)
    final batWidth = (w * 0.18).clamp(100.0, 145.0);
    final batHeight = (batWidth * 0.60).clamp(60.0, 88.0);
    final batLeft = (bbLeft + bbWidth + (w * 0.04)).clamp(w * 0.76, w * 0.82);
    final batTop = bbTop + (bbHeight - batHeight) * 0.50;
    final batteryRect = Rect.fromLTWH(batLeft, batTop, batWidth, batHeight);

    // Renderizar Elementos
    _drawHorizontal9VBattery(canvas, batteryRect);
    _drawBreadboard(canvas, breadboardRect);
    _drawBreadboardComponents(canvas, breadboardRect);
    _drawJumpersAndWires(canvas, breadboardRect, batteryRect);
  }

  /// Bateria 9V Horizontal Realista
  void _drawHorizontal9VBattery(Canvas canvas, Rect rect) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.shift(const Offset(3, 5)), const Radius.circular(8)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.32)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    const bodyRadius = Radius.circular(8);
    final blackPartWidth = rect.width * 0.72;
    final blackRect = Rect.fromLTWH(rect.left + rect.width - blackPartWidth, rect.top, blackPartWidth, rect.height);
    final blackPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF262626), Color(0xFF171717), Color(0xFF0F172A)],
      ).createShader(blackRect);

    canvas.drawRRect(
      RRect.fromRectAndCorners(blackRect, topRight: bodyRadius, bottomRight: bodyRadius),
      blackPaint,
    );

    final copperPartWidth = rect.width - blackPartWidth;
    final copperRect = Rect.fromLTWH(rect.left, rect.top, copperPartWidth, rect.height);
    final copperPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFEA580C), Color(0xFFD97706), Color(0xFFB45309)],
      ).createShader(copperRect);

    canvas.drawRRect(
      RRect.fromRectAndCorners(copperRect, topLeft: bodyRadius, bottomLeft: bodyRadius),
      copperPaint,
    );

    // Linha divisória
    canvas.drawLine(
      Offset(blackRect.left, rect.top),
      Offset(blackRect.left, rect.bottom),
      Paint()..color = Colors.black.withValues(alpha: 0.8)..strokeWidth = 1.4,
    );

    // Rótulo 9V DC
    final textPainter = TextPainter(
      text: TextSpan(
        text: '9V',
        style: GoogleFonts.rajdhani(
          color: Colors.white.withValues(alpha: 0.90),
          fontWeight: FontWeight.bold,
          fontSize: (rect.height * 0.40).clamp(16.0, 24.0),
          letterSpacing: 2.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(blackRect.center.dx - textPainter.width / 2, blackRect.center.dy - textPainter.height / 2),
    );

    // Polos + e -
    final posTerminalY = rect.top + rect.height * 0.28;
    final negTerminalY = rect.top + rect.height * 0.72;

    _drawText(canvas, '+', Offset(copperRect.center.dx - 4, posTerminalY - 7), const Color(0xFFFEF08A), 12);
    _drawText(canvas, '–', Offset(copperRect.center.dx - 4, negTerminalY - 7), Colors.white, 12);

    // Terminais metálicos e Snap Clip
    final termLeftX = rect.left;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(termLeftX - 3, posTerminalY), width: 6, height: 14), const Radius.circular(2)),
      Paint()..color = const Color(0xFFCBD5E1),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(termLeftX - 3, negTerminalY), width: 6, height: 14), const Radius.circular(2)),
      Paint()..color = const Color(0xFF94A3B8),
    );

    final clipBarRect = Rect.fromLTWH(termLeftX - 10, rect.top + rect.height * 0.12, 7, rect.height * 0.76);
    canvas.drawRRect(RRect.fromRectAndRadius(clipBarRect, const Radius.circular(3)), Paint()..color = const Color(0xFF0F172A));
    canvas.drawCircle(Offset(clipBarRect.center.dx, posTerminalY), 2.2, Paint()..color = const Color(0xFFCBD5E1));
    canvas.drawCircle(Offset(clipBarRect.center.dx, negTerminalY), 2.2, Paint()..color = const Color(0xFFCBD5E1));
  }

  /// Protoboard Central com trilhas e barramentos
  void _drawBreadboard(Canvas canvas, Rect rect) {
    // Sombra da Protoboard
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.shift(const Offset(3, 5)), const Radius.circular(12)),
      Paint()..color = Colors.black.withValues(alpha: 0.25)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );

    // Corpo da Placa (Branco marfim)
    final boardPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF8FAFC), Color(0xFFEDEFEF), Color(0xFFE2E8F0)],
      ).createShader(rect);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(12)), boardPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      Paint()..color = const Color(0xFFCBD5E1)..style = PaintingStyle.stroke..strokeWidth = 1.6,
    );

    // Canal central (Trench)
    final trenchY = rect.top + rect.height * 0.50;
    final trenchRect = Rect.fromLTWH(rect.left + 16, trenchY - 3.5, rect.width - 32, 7);
    canvas.drawRRect(RRect.fromRectAndRadius(trenchRect, const Radius.circular(3)), Paint()..color = const Color(0xFFCBD5E1));

    // Barramentos Superior e Inferior (+ Vermelho e - Azul)
    final topPowerPlusY = rect.top + rect.height * 0.10;
    final topPowerMinusY = rect.top + rect.height * 0.17;
    final botPowerPlusY = rect.top + rect.height * 0.83;
    final botPowerMinusY = rect.top + rect.height * 0.90;

    final busRedPaint = Paint()..color = const Color(0xFFEF4444).withValues(alpha: 0.7)..strokeWidth = 1.5;
    final busBluePaint = Paint()..color = const Color(0xFF3B82F6).withValues(alpha: 0.7)..strokeWidth = 1.5;

    canvas.drawLine(Offset(rect.left + 24, topPowerPlusY), Offset(rect.right - 24, topPowerPlusY), busRedPaint);
    canvas.drawLine(Offset(rect.left + 24, topPowerMinusY), Offset(rect.right - 24, topPowerMinusY), busBluePaint);
    canvas.drawLine(Offset(rect.left + 24, botPowerPlusY), Offset(rect.right - 24, botPowerPlusY), busRedPaint);
    canvas.drawLine(Offset(rect.left + 24, botPowerMinusY), Offset(rect.right - 24, botPowerMinusY), busBluePaint);

    // Furos Metálicos (Grid 14 colunas x 10 linhas)
    final holePaint = Paint()..color = const Color(0xFF64748B)..style = PaintingStyle.fill;
    final holeInner = Paint()..color = const Color(0xFF0F172A)..style = PaintingStyle.fill;

    const numCols = 16;
    final colSpacing = (rect.width - 60) / (numCols - 1);

    for (int col = 0; col < numCols; col++) {
      final x = rect.left + 30 + col * colSpacing;

      // Furos do barramento de alimentação
      for (final py in [topPowerPlusY, topPowerMinusY, botPowerPlusY, botPowerMinusY]) {
        canvas.drawCircle(Offset(x, py), 2.2, holePaint);
        canvas.drawCircle(Offset(x, py), 1.2, holeInner);
      }

      // Furos das trilhas superiores (A-E)
      for (int row = 0; row < 5; row++) {
        final y = rect.top + rect.height * 0.24 + row * (rect.height * 0.046);
        canvas.drawCircle(Offset(x, y), 2.0, holePaint);
        canvas.drawCircle(Offset(x, y), 1.1, holeInner);
      }

      // Furos das trilhas inferiores (F-J)
      for (int row = 0; row < 5; row++) {
        final y = rect.top + rect.height * 0.56 + row * (rect.height * 0.046);
        canvas.drawCircle(Offset(x, y), 2.0, holePaint);
        canvas.drawCircle(Offset(x, y), 1.1, holeInner);
      }
    }

    // Texto de identificação da bancada na borda
    _drawText(canvas, 'PROTOBOARD ELECI-LAB · BANCADA SEGURA', Offset(rect.left + 20, rect.top + 4), const Color(0xFF94A3B8), 8);
  }

  /// Componentes Físicos montados nos furos da Protoboard
  void _drawBreadboardComponents(Canvas canvas, Rect bb) {
    const numCols = 16;
    final colSpacing = (bb.width - 60) / (numCols - 1);

    // Coordenadas das colunas
    final col3X = bb.left + 30 + 2 * colSpacing;
    final col5X = bb.left + 30 + 4 * colSpacing;
    final col8X = bb.left + 30 + 7 * colSpacing;
    final col11X = bb.left + 30 + 10 * colSpacing;
    final col13X = bb.left + 30 + 12 * colSpacing;
    final col15X = bb.left + 30 + 14 * colSpacing;

    final trenchY = bb.top + bb.height * 0.50;

    // 1. Chave Seccionadora com Flip Guard (Colunas 4-5, sobre a vala central)
    _drawSafetySwitchOnBreadboard(canvas, Offset(col5X, trenchY));

    // 2. Porta-Fusível 5x20mm com Tubo de Vidro (Colunas 8-11)
    if (isFuseInserted) {
      _drawGlassFuseOnBreadboard(canvas, col8X, col11X, bb.top + bb.height * 0.33);
    }

    // 3. Resistor Limitador 680Ω (Colunas 11-13)
    if (isResistorInserted) {
      _drawResistorOnBreadboard(canvas, col11X, col13X, bb.top + bb.height * 0.33);
    }

    // 4. LED de Segurança 5mm (Coluna 13-14)
    if (isLedInserted) {
      _drawLedOnBreadboard(canvas, Offset(col13X, bb.top + bb.height * 0.65));
    }

    // 5. Buzzer Piezoelétrico (Coluna 15)
    if (missionIndex >= 3) {
      _drawBuzzerOnBreadboard(canvas, Offset(col15X, bb.top + bb.height * 0.65));
    }

    // 6. Curto-Circuito (M1 e M5): Fio jumper amarelo conectando saída da chave direto ao terra
    if (isShortCircuitActive) {
      _drawShortCircuitJumper(canvas, col5X, trenchY + 12, bb.left + 30 + 5 * colSpacing, bb.top + bb.height * 0.90);
    }

    // 7. Teste de Continuidade (M2)
    if (missionIndex == 1 && isTestingContinuity) {
      _drawContinuityProbesOnBreadboard(canvas, col5X, trenchY - 14, col8X, bb.top + bb.height * 0.33);
    }
  }

  /// Chave de Segurança montada na Protoboard
  void _drawSafetySwitchOnBreadboard(Canvas canvas, Offset center) {
    final baseRect = Rect.fromCenter(center: center, width: 34, height: 34);
    canvas.drawRRect(
      RRect.fromRectAndRadius(baseRect.shift(const Offset(2, 3)), const Radius.circular(6)),
      Paint()..color = Colors.black26,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(baseRect, const Radius.circular(6)),
      Paint()..color = const Color(0xFF1E293B),
    );

    // Terminais metálicos nos furos
    final pinPaint = Paint()..color = const Color(0xFFCBD5E1)..strokeWidth = 2.5;
    canvas.drawLine(Offset(baseRect.left, baseRect.center.dy - 6), Offset(baseRect.left - 6, baseRect.center.dy - 6), pinPaint);
    canvas.drawLine(Offset(baseRect.right, baseRect.center.dy - 6), Offset(baseRect.right + 6, baseRect.center.dy - 6), pinPaint);
    canvas.drawLine(Offset(baseRect.left, baseRect.center.dy + 6), Offset(baseRect.left - 6, baseRect.center.dy + 6), pinPaint);
    canvas.drawLine(Offset(baseRect.right, baseRect.center.dy + 6), Offset(baseRect.right + 6, baseRect.center.dy + 6), pinPaint);

    // Tampa Protetora Vermelha (Flip Guard)
    final guardColor = isArmingSwitchClosed ? const Color(0xFFDC2626) : const Color(0xFF991B1B);
    final guardRect = Rect.fromCenter(
      center: Offset(center.dx, isArmingSwitchClosed ? center.dy - 12 : center.dy - 2),
      width: 24,
      height: 14,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(guardRect, const Radius.circular(3)), Paint()..color = guardColor);

    // Alavanca
    final leverPaint = Paint()..color = const Color(0xFFF1F5F9)..strokeWidth = 3.5..strokeCap = StrokeCap.round;
    if (isArmingSwitchClosed) {
      canvas.drawLine(Offset(center.dx, center.dy + 4), Offset(center.dx, center.dy - 8), leverPaint);
      canvas.drawCircle(Offset(center.dx, center.dy - 8), 3, Paint()..color = const Color(0xFF38BDF8));
    } else {
      canvas.drawLine(Offset(center.dx, center.dy + 4), Offset(center.dx + 8, center.dy + 6), leverPaint);
      canvas.drawCircle(Offset(center.dx + 8, center.dy + 6), 3, Paint()..color = const Color(0xFF64748B));
    }
  }

  /// Fusível de Vidro 5x20mm montado na Protoboard
  void _drawGlassFuseOnBreadboard(Canvas canvas, double x1, double x2, double y) {
    final fuseWidth = x2 - x1;
    final fuseRect = Rect.fromLTWH(x1, y - 8, fuseWidth, 16);

    // Garras de suporte na protoboard
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x1 - 4, y - 10, 8, 20), const Radius.circular(2)), Paint()..color = const Color(0xFF475569));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x2 - 4, y - 10, 8, 20), const Radius.circular(2)), Paint()..color = const Color(0xFF475569));

    // Tubo de Vidro Cilíndrico
    canvas.drawRRect(
      RRect.fromRectAndRadius(fuseRect.shift(const Offset(1, 2)), const Radius.circular(4)),
      Paint()..color = Colors.black12,
    );

    final glassPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isFuseBlown
            ? [const Color(0x88475569), const Color(0xBB1E293B), const Color(0x66475569)]
            : [const Color(0x66E0F2FE), const Color(0x33BAE6FD), const Color(0x8838BDF8)],
      ).createShader(fuseRect);
    canvas.drawRRect(RRect.fromRectAndRadius(fuseRect, const Radius.circular(4)), glassPaint);

    // Terminais Metálicos das extremidades
    final capPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF1F5F9), Color(0xFF94A3B8), Color(0xFF475569)],
      ).createShader(fuseRect);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x1, y - 8, 8, 16), const Radius.circular(2)), capPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x2 - 8, y - 8, 8, 16), const Radius.circular(2)), capPaint);

    // Filamento Interno
    if (isFuseBlown) {
      // Filamento partido com fuligem
      final p1 = Path()..moveTo(x1 + 8, y)..lineTo(x1 + fuseWidth * 0.42, y + 2);
      final p2 = Path()..moveTo(x2 - 8, y)..lineTo(x1 + fuseWidth * 0.58, y - 2);
      canvas.drawPath(p1, Paint()..color = const Color(0xFF0F172A)..strokeWidth = 1.2);
      canvas.drawPath(p2, Paint()..color = const Color(0xFF0F172A)..strokeWidth = 1.2);
      canvas.drawCircle(Offset(fuseRect.center.dx, y), 4.5, Paint()..color = const Color(0xCC000000));
    } else {
      // Filamento metálico íntegro
      canvas.drawLine(
        Offset(x1 + 8, y),
        Offset(x2 - 8, y),
        Paint()
          ..color = isCircuitEnergized ? const Color(0xFFFDE047) : const Color(0xFFCBD5E1)
          ..strokeWidth = 1.6,
      );
    }
  }

  /// Resistor com anéis de precisão nos furos
  void _drawResistorOnBreadboard(Canvas canvas, double x1, double x2, double y) {
    // Pernas do resistor dobradas nos furos
    final leadPaint = Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 2.0..style = PaintingStyle.stroke;
    final leadPath = Path()
      ..moveTo(x1, y)
      ..lineTo(x1 + 6, y)
      ..lineTo(x2 - 6, y)
      ..lineTo(x2, y);
    canvas.drawPath(leadPath, leadPaint);

    // Corpo cerâmico
    final bodyRect = Rect.fromCenter(center: Offset((x1 + x2) / 2, y), width: x2 - x1 - 10, height: 10);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(3)), Paint()..color = const Color(0xFFD4B996));

    // Faixas de cores (680Ω: Azul, Cinza, Marrom, Ouro)
    final bandW = bodyRect.width * 0.12;
    canvas.drawRect(Rect.fromLTWH(bodyRect.left + bodyRect.width * 0.18, bodyRect.top, bandW, 10), Paint()..color = const Color(0xFF2563EB));
    canvas.drawRect(Rect.fromLTWH(bodyRect.left + bodyRect.width * 0.38, bodyRect.top, bandW, 10), Paint()..color = const Color(0xFF64748B));
    canvas.drawRect(Rect.fromLTWH(bodyRect.left + bodyRect.width * 0.58, bodyRect.top, bandW, 10), Paint()..color = const Color(0xFF78350F));
    canvas.drawRect(Rect.fromLTWH(bodyRect.left + bodyRect.width * 0.78, bodyRect.top, bandW * 0.8, 10), Paint()..color = const Color(0xFFEAB308));
  }

  /// LED 5mm com efeito de cúpula e brilho
  void _drawLedOnBreadboard(Canvas canvas, Offset pos) {
    final ledOn = isCircuitEnergized;
    final ledColor = ledOn ? const Color(0xFF10B981) : const Color(0xFF065F46);

    // Brilho volumétrico
    if (ledOn) {
      canvas.drawCircle(
        pos,
        22,
        Paint()
          ..color = const Color(0xFF10B981).withValues(alpha: 0.40)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }

    // Terminal e base
    canvas.drawCircle(pos, 8, Paint()..color = ledColor);
    canvas.drawCircle(pos.translate(-2, -2), 3, Paint()..color = Colors.white.withValues(alpha: ledOn ? 0.8 : 0.2));
    canvas.drawCircle(pos, 8, Paint()..color = const Color(0xFF0F172A).withValues(alpha: 0.3)..style = PaintingStyle.stroke..strokeWidth = 1.2);
  }

  /// Buzzer Piezoelétrico montado
  void _drawBuzzerOnBreadboard(Canvas canvas, Offset pos) {
    canvas.drawCircle(pos.translate(2, 3), 12, Paint()..color = Colors.black26);
    canvas.drawCircle(pos, 12, Paint()..color = const Color(0xFF0F172A));
    canvas.drawCircle(pos, 4, Paint()..color = const Color(0xFF334155));

    if (isCircuitEnergized) {
      final waveRadius = 14 + 6 * (animValue % 1.0);
      final wavePaint = Paint()
        ..color = const Color(0xFF38BDF8).withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8;
      canvas.drawArc(Rect.fromCircle(center: pos, radius: waveRadius), -0.7, 1.4, false, wavePaint);
    }
  }

  /// Fio de Curto Jumper com faíscas
  void _drawShortCircuitJumper(Canvas canvas, double x1, double y1, double x2, double y2) {
    final path = Path()
      ..moveTo(x1, y1)
      ..cubicTo(x1 + 10, y1 + 30, x2 - 10, y2 - 20, x2, y2);

    canvas.drawPath(path.shift(const Offset(1, 2)), Paint()..color = Colors.black26..strokeWidth = 5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFF59E0B)
        ..strokeWidth = 4.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Faíscas didáticas pulsantes no curto
    for (int i = 0; i < 5; i++) {
      final angle = (animValue * math.pi * 2) + (i * math.pi / 2.5);
      final r = 6 + 5 * math.sin(animValue * math.pi * 4 + i);
      final px = x1 + r * math.cos(angle);
      final py = y1 + r * math.sin(angle);
      canvas.drawCircle(Offset(px, py), 2.0, Paint()..color = const Color(0xFFFDE047));
    }
  }

  /// Pontas de Prova de Teste de Continuidade (M2)
  void _drawContinuityProbesOnBreadboard(Canvas canvas, double redX, double redY, double blackX, double blackY) {
    final redProbeCenter = Offset(redX + 15, redY - 24);
    final blackProbeCenter = Offset(blackX - 15, blackY - 24);

    // Haste vermelha
    canvas.drawLine(redProbeCenter, Offset(redX, redY), Paint()..color = const Color(0xFFEF4444)..strokeWidth = 3.5..strokeCap = StrokeCap.round);
    canvas.drawCircle(redProbeCenter, 5, Paint()..color = const Color(0xFFDC2626));

    // Haste preta
    canvas.drawLine(blackProbeCenter, Offset(blackX, blackY), Paint()..color = const Color(0xFF1E293B)..strokeWidth = 3.5..strokeCap = StrokeCap.round);
    canvas.drawCircle(blackProbeCenter, 5, Paint()..color = const Color(0xFF0F172A));

    // LED no testador de continuidade
    final testOk = isContinuityOk;
    final testColor = testOk ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    _drawText(canvas, testOk ? 'CONTINUIDADE OK (BIP)' : 'SEM SINAL (FIO ROMPIDO)', Offset((redX + blackX) / 2 - 45, redY - 38), testColor, 9);
  }

  /// Fios Jumpers que interligam a Bateria e a Protoboard
  void _drawJumpersAndWires(Canvas canvas, Rect bb, Rect bat) {
    const numCols = 16;
    final colSpacing = (bb.width - 60) / (numCols - 1);

    final col5X = bb.left + 30 + 4 * colSpacing;
    final col8X = bb.left + 30 + 7 * colSpacing;
    final col13X = bb.left + 30 + 12 * colSpacing;

    final topPowerPlusY = bb.top + bb.height * 0.10;
    final botPowerMinusY = bb.top + bb.height * 0.90;
    final trenchY = bb.top + bb.height * 0.50;

    final wireRed = Paint()..color = const Color(0xFFDC2626)..strokeWidth = 4.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final wireBlack = Paint()..color = const Color(0xFF1E293B)..strokeWidth = 4.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final wireOrange = Paint()..color = const Color(0xFFF97316)..strokeWidth = 4.0..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final wireShadow = Paint()..color = Colors.black26..strokeWidth = 5.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;

    // 1. Bat(+) -> Barramento Superior (+) da Protoboard
    final pBatPlus = Path()
      ..moveTo(bat.left - 10, bat.top + bat.height * 0.28)
      ..cubicTo(bat.left - 30, bat.top - 10, bb.right - 10, topPowerPlusY - 15, bb.right - 30, topPowerPlusY);
    canvas.drawPath(pBatPlus.shift(const Offset(2, 3)), wireShadow);
    canvas.drawPath(pBatPlus, wireRed);

    // 2. Bat(-) -> Barramento Inferior (-) da Protoboard
    final pBatMinus = Path()
      ..moveTo(bat.left - 10, bat.top + bat.height * 0.72)
      ..cubicTo(bat.left - 30, bat.bottom + 10, bb.right - 10, botPowerMinusY + 15, bb.right - 30, botPowerMinusY);
    canvas.drawPath(pBatMinus.shift(const Offset(2, 3)), wireShadow);
    canvas.drawPath(pBatMinus, wireBlack);

    // 3. Jumper: Barramento(+) -> Entrada da Chave (Col 5)
    final pPowerToSw = Path()
      ..moveTo(bb.left + 30 + 4 * colSpacing, topPowerPlusY)
      ..cubicTo(col5X - 10, topPowerPlusY + 15, col5X - 10, trenchY - 25, col5X, trenchY - 14);
    canvas.drawPath(pPowerToSw.shift(const Offset(1, 2)), wireShadow);
    canvas.drawPath(pPowerToSw, wireRed);

    // 4. Jumper: Saída da Chave -> Fusível (Col 8)
    if (isWireBroken && !isWireRepaired) {
      // Fio quebrado com ponta solta (M2)
      final pBroken1 = Path()..moveTo(col5X, trenchY + 14)..lineTo(col5X + 18, trenchY + 28);
      final pBroken2 = Path()..moveTo(col8X, bb.top + bb.height * 0.33)..lineTo(col8X - 14, bb.top + bb.height * 0.22);
      canvas.drawPath(pBroken1, Paint()..color = const Color(0xFFEF4444)..strokeWidth = 3.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
      canvas.drawPath(pBroken2, Paint()..color = const Color(0xFFEF4444)..strokeWidth = 3.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
      canvas.drawCircle(Offset(col5X + 18, trenchY + 28), 2.5, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(col8X - 14, bb.top + bb.height * 0.22), 2.5, Paint()..color = Colors.white);
    } else {
      final pSwToFuse = Path()
        ..moveTo(col5X, trenchY - 14)
        ..cubicTo(col5X + 12, bb.top + bb.height * 0.20, col8X - 12, bb.top + bb.height * 0.20, col8X, bb.top + bb.height * 0.33);
      canvas.drawPath(pSwToFuse.shift(const Offset(1, 2)), wireShadow);
      canvas.drawPath(pSwToFuse, wireOrange);
    }

    // 5. Jumper: Saída do LED -> Barramento Inferior (-)
    final pLedToGnd = Path()
      ..moveTo(col13X, bb.top + bb.height * 0.65 + 8)
      ..cubicTo(col13X, botPowerMinusY - 10, col13X + 10, botPowerMinusY - 5, col13X + 10, botPowerMinusY);
    canvas.drawPath(pLedToGnd.shift(const Offset(1, 2)), wireShadow);
    canvas.drawPath(pLedToGnd, wireBlack);

    // 6. Animação de Elétrons pelo circuito
    if (isCircuitEnergized || isShortCircuitActive) {
      _drawAnimatedElectrons(canvas, bb, bat, col5X, col8X, col13X, topPowerPlusY, botPowerMinusY, trenchY);
    }
  }

  void _drawAnimatedElectrons(
    Canvas canvas,
    Rect bb,
    Rect bat,
    double col5X,
    double col8X,
    double col13X,
    double topPlusY,
    double botMinusY,
    double trenchY,
  ) {
    final electronColor = isShortCircuitActive ? const Color(0xFFEF4444) : const Color(0xFF38BDF8);
    final electronPaint = Paint()..color = electronColor..style = PaintingStyle.fill;

    for (double t = 0; t < 1.0; t += 0.10) {
      final curT = (t + animValue) % 1.0;
      Offset pt;
      if (curT < 0.30) {
        final subT = curT / 0.30;
        pt = Offset(
          bat.left - 10 + subT * (col5X - (bat.left - 10)),
          bat.top + bat.height * 0.28 + subT * (trenchY - (bat.top + bat.height * 0.28)),
        );
      } else if (curT < 0.60) {
        final subT = (curT - 0.30) / 0.30;
        if (isShortCircuitActive) {
          pt = Offset(col5X + subT * 10, trenchY + subT * (botMinusY - trenchY));
        } else {
          pt = Offset(col5X + subT * (col13X - col5X), bb.top + bb.height * 0.33);
        }
      } else {
        final subT = (curT - 0.60) / 0.40;
        pt = Offset(
          col13X + subT * (bat.left - 10 - col13X),
          botMinusY + subT * (bat.top + bat.height * 0.72 - botMinusY),
        );
      }
      canvas.drawCircle(pt, 2.8, electronPaint);
    }
  }

  // =========================================================================
  // MODO ESQUEMÁTICO TÉCNICO ABNT / IEC
  // =========================================================================

  void _paintSchematicWorkbench(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final batX = w * 0.22;
    final batY = h * 0.50;

    final swX = w * 0.40;
    final swY = h * 0.28;

    final fuseX = w * 0.58;
    final fuseY = h * 0.28;

    final loadX = w * 0.76;
    final loadY = h * 0.50;
    final retY = h * 0.74;

    final linePaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final activePaint = Paint()
      ..color = const Color(0xFF34D399)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final curPaint = isCircuitEnergized ? activePaint : linePaint;

    // Linha Bat(+) -> Chave
    final pBatToSw = Path()
      ..moveTo(batX, batY - 20)
      ..lineTo(batX, swY)
      ..lineTo(swX - 16, swY);
    canvas.drawPath(pBatToSw, curPaint);

    // Chave SPST
    canvas.drawCircle(Offset(swX - 16, swY), 3.0, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(swX + 16, swY), 3.0, Paint()..color = Colors.white);
    if (isArmingSwitchClosed) {
      canvas.drawLine(Offset(swX - 16, swY), Offset(swX + 16, swY), curPaint);
    } else {
      canvas.drawLine(Offset(swX - 16, swY), Offset(swX + 10, swY - 12), curPaint);
    }

    // Chave -> Fusível
    if (isWireBroken && !isWireRepaired) {
      canvas.drawLine(Offset(swX + 16, swY), Offset(swX + 32, swY + 8), Paint()..color = const Color(0xFFEF4444)..strokeWidth = 2.5);
      canvas.drawLine(Offset(fuseX - 22, swY), Offset(fuseX - 38, swY - 8), Paint()..color = const Color(0xFFEF4444)..strokeWidth = 2.5);
    } else {
      canvas.drawLine(Offset(swX + 16, swY), Offset(fuseX - 22, swY), curPaint);
    }

    // Fusível IEC
    final fuseRect = Rect.fromCenter(center: Offset(fuseX, swY), width: 44, height: 16);
    canvas.drawRect(fuseRect, curPaint);
    if (!isFuseBlown) {
      canvas.drawLine(Offset(fuseX - 22, swY), Offset(fuseX + 22, swY), curPaint);
    }

    // Fusível -> Resistor / Carga
    final pFuseToLoad = Path()
      ..moveTo(fuseX + 22, swY)
      ..lineTo(loadX, swY)
      ..lineTo(loadX, loadY - 25);
    canvas.drawPath(pFuseToLoad, curPaint);

    // Resistor Esquemático
    final resPath = Path()..moveTo(loadX, loadY - 25);
    for (int i = 0; i < 4; i++) {
      final sign = (i % 2 == 0) ? 1 : -1;
      resPath.lineTo(loadX + sign * 8, loadY - 25 + (i + 1) * 6);
    }
    resPath.lineTo(loadX, loadY);
    canvas.drawPath(resPath, curPaint);

    // LED Esquemático
    final ledTri = Path()
      ..moveTo(loadX - 10, loadY)
      ..lineTo(loadX + 10, loadY)
      ..lineTo(loadX, loadY + 16)
      ..close();
    canvas.drawPath(ledTri, Paint()..color = isCircuitEnergized ? const Color(0xFF10B981) : Colors.white);
    canvas.drawLine(Offset(loadX - 10, loadY + 16), Offset(loadX + 10, loadY + 16), curPaint);

    // Retorno
    final pRet = Path()
      ..moveTo(loadX, loadY + 16)
      ..lineTo(loadX, retY)
      ..lineTo(batX, retY)
      ..lineTo(batX, batY + 20);
    canvas.drawPath(pRet, curPaint);

    // Fonte DC 9V
    canvas.drawLine(Offset(batX - 16, batY - 8), Offset(batX + 16, batY - 8), Paint()..color = Colors.red..strokeWidth = 3);
    canvas.drawLine(Offset(batX - 8, batY + 8), Offset(batX + 8, batY + 8), Paint()..color = Colors.white..strokeWidth = 3);

    // Rótulos técnicos esquemáticos
    _drawText(canvas, '9V DC', Offset(batX - 45, batY - 6), Colors.white, 10);
    _drawText(canvas, 'S1 (SEGURANÇA)', Offset(swX - 30, swY - 20), const Color(0xFF94A3B8), 9);
    _drawText(canvas, 'F1 (100mA)', Offset(fuseX - 20, swY - 20), const Color(0xFF94A3B8), 9);
    _drawText(canvas, 'R1 (680Ω)', Offset(loadX + 14, loadY - 16), const Color(0xFF94A3B8), 9);
    _drawText(canvas, 'LED1 (STATUS)', Offset(loadX + 14, loadY + 8), const Color(0xFF94A3B8), 9);
  }

  void _drawText(Canvas canvas, String text, Offset offset, Color color, double fontSize) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: GoogleFonts.rajdhani(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CircuitoSeguroPainter oldDelegate) {
    return oldDelegate.animValue != animValue ||
        oldDelegate.usePhysicalStyle != usePhysicalStyle ||
        oldDelegate.isArmingSwitchClosed != isArmingSwitchClosed ||
        oldDelegate.isShortCircuitActive != isShortCircuitActive ||
        oldDelegate.isWireBroken != isWireBroken ||
        oldDelegate.isWireRepaired != isWireRepaired ||
        oldDelegate.isFuseInserted != isFuseInserted ||
        oldDelegate.isFuseBlown != isFuseBlown ||
        oldDelegate.isFuseCorrectRating != isFuseCorrectRating ||
        oldDelegate.isLedInserted != isLedInserted ||
        oldDelegate.isResistorInserted != isResistorInserted ||
        oldDelegate.isBuzzerActive != isBuzzerActive ||
        oldDelegate.isTestingContinuity != isTestingContinuity ||
        oldDelegate.isContinuityOk != isContinuityOk;
  }
}
