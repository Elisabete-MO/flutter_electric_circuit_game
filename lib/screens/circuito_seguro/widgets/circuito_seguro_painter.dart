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

  /// Protoboard Central com acabamento plástico ABS, coordenadas e barramentos
  void _drawBreadboard(Canvas canvas, Rect rect) {
    // 1. Sombra suave da Protoboard na mesa
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.shift(const Offset(4, 6)), const Radius.circular(14)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // 2. Chassi da Placa (Plástico ABS fosco marfim/off-white)
    final boardPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFAFAFA), Color(0xFFF1F5F9), Color(0xFFE2E8F0)],
      ).createShader(rect);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(12)), boardPaint);

    // Borda chanfrada de precisão
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      Paint()
        ..color = const Color(0xFFCBD5E1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // Encaixes laterais de expansão (dentes macho/fêmea típicos de protoboards reais)
    final notchPaint = Paint()..color = const Color(0xFFE2E8F0);
    final notchBorder = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (double ny = rect.top + rect.height * 0.28; ny <= rect.top + rect.height * 0.72; ny += rect.height * 0.40) {
      final leftNotch = Rect.fromCenter(center: Offset(rect.left, ny), width: 6, height: 16);
      canvas.drawRRect(RRect.fromRectAndRadius(leftNotch, const Radius.circular(2)), notchPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(leftNotch, const Radius.circular(2)), notchBorder);

      final rightNotch = Rect.fromCenter(center: Offset(rect.right, ny), width: 6, height: 16);
      canvas.drawRRect(RRect.fromRectAndRadius(rightNotch, const Radius.circular(2)), notchPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(rightNotch, const Radius.circular(2)), notchBorder);
    }

    // 3. Canaleta Central (Trench) com sombra interna de profundidade
    final trenchY = rect.top + rect.height * 0.50;
    final trenchRect = Rect.fromLTWH(rect.left + 24, trenchY - 4.5, rect.width - 48, 9);
    final trenchPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF94A3B8), Color(0xFFCBD5E1), Color(0xFFE2E8F0)],
      ).createShader(trenchRect);
    canvas.drawRRect(RRect.fromRectAndRadius(trenchRect, const Radius.circular(3)), trenchPaint);
    canvas.drawLine(
      Offset(trenchRect.left + 4, trenchY),
      Offset(trenchRect.right - 4, trenchY),
      Paint()..color = const Color(0xFF64748B)..strokeWidth = 1.2,
    );

    // 4. Barramentos de Alimentação (+ Vermelho e - Azul)
    final topPowerPlusY = rect.top + rect.height * 0.08;
    final topPowerMinusY = rect.top + rect.height * 0.15;
    final botPowerMinusY = rect.top + rect.height * 0.85;
    final botPowerPlusY = rect.top + rect.height * 0.92;

    final busLeft = rect.left + 32.0;
    final busRight = rect.right - 32.0;

    _drawPowerRailLine(canvas, Offset(busLeft, topPowerPlusY), Offset(busRight, topPowerPlusY), const Color(0xFFEF4444), '+');
    _drawPowerRailLine(canvas, Offset(busLeft, topPowerMinusY), Offset(busRight, topPowerMinusY), const Color(0xFF3B82F6), '–');
    _drawPowerRailLine(canvas, Offset(busLeft, botPowerMinusY), Offset(busRight, botPowerMinusY), const Color(0xFF3B82F6), '–');
    _drawPowerRailLine(canvas, Offset(busLeft, botPowerPlusY), Offset(busRight, botPowerPlusY), const Color(0xFFEF4444), '+');

    // 5. Matriz de Furos (24 colunas x 10 linhas + barramentos) e Coordenadas
    _drawBreadboardGrid(canvas, rect, topPowerPlusY, topPowerMinusY, botPowerMinusY, botPowerPlusY);

    // 6. Inscrição técnica elegante
    _drawText(
      canvas,
      'ELECI-LAB · PROTOBOARD 830 TIE-POINTS · CIRCUITO SEGURO',
      Offset(rect.left + 34, rect.top + 2),
      const Color(0xFF94A3B8),
      7.5,
    );
  }

  void _drawPowerRailLine(Canvas canvas, Offset start, Offset end, Color color, String sign) {
    canvas.drawLine(start, end, Paint()..color = color.withValues(alpha: 0.85)..strokeWidth = 1.6);
    final signPainter = TextPainter(
      text: TextSpan(text: sign, style: GoogleFonts.rajdhani(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
      textDirection: TextDirection.ltr,
    )..layout();
    signPainter.paint(canvas, Offset(start.dx - 12, start.dy - signPainter.height / 2));
    signPainter.paint(canvas, Offset(end.dx + 4, end.dy - signPainter.height / 2));
  }

  void _drawBreadboardGrid(
    Canvas canvas,
    Rect rect,
    double topPowerPlusY,
    double topPowerMinusY,
    double botPowerMinusY,
    double botPowerPlusY,
  ) {
    const cols = 24;
    final startX = rect.left + 36.0;
    final stepX = (rect.width - 72.0) / (cols - 1);

    final rowStepTop = (rect.height * 0.24) / 4;
    final rowStartYTop = rect.top + rect.height * 0.22;

    final rowStepBot = (rect.height * 0.24) / 4;
    final rowStartYBot = rect.top + rect.height * 0.55;

    // Rótulos de Linhas (a..e no topo e f..j na base)
    final rowLabelsTop = ['a', 'b', 'c', 'd', 'e'];
    for (int r = 0; r < 5; r++) {
      final ly = rowStartYTop + r * rowStepTop;
      _drawText(canvas, rowLabelsTop[r], Offset(startX - 14, ly - 4.5), const Color(0xFF94A3B8), 7.5);
      _drawText(canvas, rowLabelsTop[r], Offset(rect.right - 26, ly - 4.5), const Color(0xFF94A3B8), 7.5);
    }

    final rowLabelsBot = ['f', 'g', 'h', 'i', 'j'];
    for (int r = 0; r < 5; r++) {
      final ly = rowStartYBot + r * rowStepBot;
      _drawText(canvas, rowLabelsBot[r], Offset(startX - 14, ly - 4.5), const Color(0xFF94A3B8), 7.5);
      _drawText(canvas, rowLabelsBot[r], Offset(rect.right - 26, ly - 4.5), const Color(0xFF94A3B8), 7.5);
    }

    for (int col = 0; col < cols; col++) {
      final cx = startX + col * stepX;

      // Barramento superior
      _drawSingleBreadboardHole(canvas, Offset(cx, topPowerPlusY));
      _drawSingleBreadboardHole(canvas, Offset(cx, topPowerMinusY));

      // Banco superior (a..e)
      for (int r = 0; r < 5; r++) {
        _drawSingleBreadboardHole(canvas, Offset(cx, rowStartYTop + r * rowStepTop));
      }

      // Banco inferior (f..j)
      for (int r = 0; r < 5; r++) {
        _drawSingleBreadboardHole(canvas, Offset(cx, rowStartYBot + r * rowStepBot));
      }

      // Barramento inferior
      _drawSingleBreadboardHole(canvas, Offset(cx, botPowerMinusY));
      _drawSingleBreadboardHole(canvas, Offset(cx, botPowerPlusY));

      // Números das colunas serigrafados (1, 5, 10, 15, 20, 24)
      if (col == 0 || (col + 1) % 5 == 0 || col == cols - 1) {
        final colNum = (col + 1).toString();
        final numPainter = TextPainter(
          text: TextSpan(text: colNum, style: GoogleFonts.rajdhani(color: const Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 8.0)),
          textDirection: TextDirection.ltr,
        )..layout();
        numPainter.paint(canvas, Offset(cx - numPainter.width / 2, rect.top + rect.height * 0.17));
        numPainter.paint(canvas, Offset(cx - numPainter.width / 2, rect.top + rect.height * 0.80));
      }
    }
  }

  /// Furo quadrado com pino de mola niquelado
  void _drawSingleBreadboardHole(Canvas canvas, Offset center) {
    // Borda metálica do orifício
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCircle(center: center, radius: 2.4), const Radius.circular(0.8)),
      Paint()..color = const Color(0xFF94A3B8),
    );
    // Cavidade escura interna
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCircle(center: center, radius: 1.6), const Radius.circular(0.5)),
      Paint()..color = const Color(0xFF0F172A),
    );
    // Reflexo da mola interna de contato
    canvas.drawCircle(center.translate(-0.4, -0.4), 0.7, Paint()..color = const Color(0xFFCBD5E1));
  }

  /// Componentes Físicos montados nos furos da Protoboard
  void _drawBreadboardComponents(Canvas canvas, Rect bb) {
    const cols = 24;
    final startX = bb.left + 36.0;
    final stepX = (bb.width - 72.0) / (cols - 1);

    final rowStepTop = (bb.height * 0.24) / 4;
    final rowStartYTop = bb.top + bb.height * 0.22;

    final rowStepBot = (bb.height * 0.24) / 4;
    final rowStartYBot = bb.top + bb.height * 0.55;

    // Coordenadas das colunas-chave
    final col4X = startX + 3 * stepX;
    final col7X = startX + 6 * stepX;
    final col11X = startX + 10 * stepX;
    final col13X = startX + 12 * stepX;
    final col17X = startX + 16 * stepX;
    final col19X = startX + 18 * stepX;
    final col21X = startX + 20 * stepX;

    final rowCY = rowStartYTop + 2 * rowStepTop;
    final rowDY = rowStartYTop + 3 * rowStepTop;
    final rowGY = rowStartYBot + 1 * rowStepBot;
    final trenchY = bb.top + bb.height * 0.50;

    // 1. Chave Seccionadora com Flip Guard (Coluna 4, sobre a vala central)
    _drawSafetySwitchOnBreadboard(canvas, Offset(col4X, trenchY));

    // 2. Porta-Fusível 5x20mm com Tubo de Vidro (Coluna 7 até Coluna 11, Linha C)
    if (isFuseInserted) {
      _drawGlassFuseOnBreadboard(canvas, col7X, col11X, rowCY);
    }

    // 3. Resistor de Precisão 680Ω (Coluna 13 até Coluna 17, Linha C)
    if (isResistorInserted) {
      _drawResistorOnBreadboard(canvas, col13X, col17X, rowCY);
    }

    // 4. LED de Segurança 5mm (Coluna 17 e Coluna 19, Linha G)
    if (isLedInserted) {
      _drawLedOnBreadboard(canvas, Offset(col17X, rowGY), Offset(col19X, rowGY));
    }

    // 5. Buzzer Piezoelétrico (Coluna 21, Banco Inferior)
    if (missionIndex >= 3) {
      _drawBuzzerOnBreadboard(canvas, Offset(col21X, rowGY));
    }

    // 6. Curto-Circuito (M1 e M5): Fio jumper conectando a saída da chave direto ao terra
    if (isShortCircuitActive) {
      final botPowerMinusY = bb.top + bb.height * 0.85;
      _drawShortCircuitJumper(canvas, col4X, trenchY + 14, startX + 5 * stepX, botPowerMinusY);
    }

    // 7. Teste de Continuidade (M2) com Pontas de Prova
    if (missionIndex == 1 && isTestingContinuity) {
      _drawContinuityProbesOnBreadboard(canvas, col4X + 18, trenchY - 14, col7X - 18, rowCY);
    }
  }

  /// Chave de Segurança montada na Protoboard com armadura vermelha móvel
  void _drawSafetySwitchOnBreadboard(Canvas canvas, Offset center) {
    final baseRect = Rect.fromCenter(center: center, width: 36, height: 36);

    // Sombra da chave
    canvas.drawRRect(
      RRect.fromRectAndRadius(baseRect.shift(const Offset(2, 4)), const Radius.circular(6)),
      Paint()..color = Colors.black38..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Base plástica industrial
    canvas.drawRRect(
      RRect.fromRectAndRadius(baseRect, const Radius.circular(6)),
      Paint()..color = const Color(0xFF1E293B),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(baseRect, const Radius.circular(6)),
      Paint()..color = const Color(0xFF475569)..style = PaintingStyle.stroke..strokeWidth = 1.2,
    );

    // Parafusos nos 4 cantos da base
    final screwPaint = Paint()..color = const Color(0xFF94A3B8);
    for (final corner in [
      Offset(baseRect.left + 4, baseRect.top + 4),
      Offset(baseRect.right - 4, baseRect.top + 4),
      Offset(baseRect.left + 4, baseRect.bottom - 4),
      Offset(baseRect.right - 4, baseRect.bottom - 4),
    ]) {
      canvas.drawCircle(corner, 1.6, screwPaint);
      canvas.drawLine(corner.translate(-1, 0), corner.translate(1, 0), Paint()..color = const Color(0xFF0F172A)..strokeWidth = 0.6);
    }

    // Terminais de inserção nos furos da protoboard (topo e fundo)
    final pinPaint = Paint()..color = const Color(0xFFCBD5E1)..strokeWidth = 2.4..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(center.dx, baseRect.top), Offset(center.dx, baseRect.top - 6), pinPaint);
    canvas.drawLine(Offset(center.dx, baseRect.bottom), Offset(center.dx, baseRect.bottom + 6), pinPaint);

    // Flip Guard (Armadura Articulada Vermelha)
    if (isArmingSwitchClosed) {
      // FECHADA/ARMADA: Proteção cobrindo a alavanca
      final guardRect = Rect.fromCenter(center: center.translate(0, -2), width: 22, height: 26);
      final guardGrad = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFEF4444), Color(0xFFDC2626), Color(0xFF991B1B)],
      ).createShader(guardRect);
      canvas.drawRRect(RRect.fromRectAndRadius(guardRect, const Radius.circular(4)), Paint()..shader = guardGrad);
      canvas.drawRRect(RRect.fromRectAndRadius(guardRect, const Radius.circular(4)), Paint()..color = const Color(0xFF7F1D1D)..style = PaintingStyle.stroke..strokeWidth = 1.2);

      // Friso de relevo
      canvas.drawLine(Offset(guardRect.left + 4, guardRect.center.dy), Offset(guardRect.right - 4, guardRect.center.dy), Paint()..color = Colors.white.withValues(alpha: 0.5)..strokeWidth = 1.4);

      // LED indicador na chave
      canvas.drawCircle(center.translate(0, 7), 2.5, Paint()..color = const Color(0xFF38BDF8));
    } else {
      // ABERTA/DESARMADA: Tampa levantada em perspectiva
      final guardPath = Path()
        ..moveTo(baseRect.left + 4, baseRect.top - 6)
        ..lineTo(baseRect.right - 4, baseRect.top - 6)
        ..lineTo(baseRect.right - 8, baseRect.top - 20)
        ..lineTo(baseRect.left + 8, baseRect.top - 20)
        ..close();
      canvas.drawPath(guardPath, Paint()..color = const Color(0xFFDC2626));
      canvas.drawPath(guardPath, Paint()..color = const Color(0xFF7F1D1D)..style = PaintingStyle.stroke..strokeWidth = 1.2);

      // Alavanca metálica livre exposta
      final leverPaint = Paint()..color = const Color(0xFFE2E8F0)..strokeWidth = 3.5..strokeCap = StrokeCap.round;
      canvas.drawLine(center.translate(0, 4), center.translate(0, -6), leverPaint);
      canvas.drawCircle(center.translate(0, -6), 3.2, Paint()..color = const Color(0xFF64748B));
    }
  }

  /// Fusível de Vidro 5x20mm montado com clips prateados nos furos
  void _drawGlassFuseOnBreadboard(Canvas canvas, double x1, double x2, double y) {
    final fuseWidth = x2 - x1;
    final fuseRect = Rect.fromLTWH(x1, y - 9, fuseWidth, 18);

    // 1. Clips Metálicos de Suporte (Latão Niquelado) nas colunas da protoboard
    final clipPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFE2E8F0), Color(0xFF94A3B8), Color(0xFF475569)],
      ).createShader(Rect.fromLTWH(x1 - 5, y - 12, 10, 24));

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x1 - 5, y - 12, 10, 24), const Radius.circular(3)), clipPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x2 - 5, y - 12, 10, 24), const Radius.circular(3)), clipPaint);

    // Pinos de inserção dos clips na protoboard
    canvas.drawCircle(Offset(x1, y + 12), 2.2, Paint()..color = const Color(0xFFCBD5E1));
    canvas.drawCircle(Offset(x2, y + 12), 2.2, Paint()..color = const Color(0xFFCBD5E1));

    // 2. Sombra do Tubo de Vidro
    canvas.drawRRect(
      RRect.fromRectAndRadius(fuseRect.shift(const Offset(2, 3)), const Radius.circular(5)),
      Paint()..color = Colors.black26..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // 3. Cápsula de Vidro Cilíndrica Translúcida
    final glassPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isFuseBlown
            ? [const Color(0x66475569), const Color(0x991E293B), const Color(0x44475569)]
            : [const Color(0x77E0F2FE), const Color(0x33BAE6FD), const Color(0x8838BDF8)],
      ).createShader(fuseRect);
    canvas.drawRRect(RRect.fromRectAndRadius(fuseRect, const Radius.circular(5)), glassPaint);

    // Brilho especular superior do vidro
    canvas.drawLine(
      Offset(x1 + 10, y - 5),
      Offset(x2 - 10, y - 5),
      Paint()..color = Colors.white.withValues(alpha: 0.85)..strokeWidth = 1.4..strokeCap = StrokeCap.round,
    );

    // 4. Ponteiras Metálicas Cromadas das Extremidades
    final capWidth = 10.0;
    final capGrad = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFFFFFF), Color(0xFFCBD5E1), Color(0xFF64748B), Color(0xFF334155)],
    );
    final leftCapRect = Rect.fromLTWH(x1, y - 9, capWidth, 18);
    final rightCapRect = Rect.fromLTWH(x2 - capWidth, y - 9, capWidth, 18);

    canvas.drawRRect(RRect.fromRectAndRadius(leftCapRect, const Radius.circular(3)), Paint()..shader = capGrad.createShader(leftCapRect));
    canvas.drawRRect(RRect.fromRectAndRadius(rightCapRect, const Radius.circular(3)), Paint()..shader = capGrad.createShader(rightCapRect));

    // 5. Filamento Interno e Rótulo
    if (isFuseBlown) {
      // Filamento rompido com bolha de fusão e fuligem escura
      final p1 = Path()..moveTo(x1 + capWidth, y)..lineTo(x1 + fuseWidth * 0.40, y + 2);
      final p2 = Path()..moveTo(x2 - capWidth, y)..lineTo(x1 + fuseWidth * 0.60, y - 2);
      canvas.drawPath(p1, Paint()..color = const Color(0xFF0F172A)..strokeWidth = 1.4);
      canvas.drawPath(p2, Paint()..color = const Color(0xFF0F172A)..strokeWidth = 1.4);

      // Fuligem preta no centro
      canvas.drawCircle(fuseRect.center, 5.5, Paint()..color = Colors.black.withValues(alpha: 0.65)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2));
      canvas.drawCircle(Offset(x1 + fuseWidth * 0.40, y + 2), 1.8, Paint()..color = const Color(0xFF475569));
      canvas.drawCircle(Offset(x1 + fuseWidth * 0.60, y - 2), 1.8, Paint()..color = const Color(0xFF475569));
    } else {
      // Filamento metálico íntegro
      final filColor = isCircuitEnergized ? const Color(0xFFFDE047) : const Color(0xFFCBD5E1);
      final filPath = Path()
        ..moveTo(x1 + capWidth, y)
        ..quadraticBezierTo(fuseRect.center.dx, y + (isCircuitEnergized ? 2.5 : 1.5), x2 - capWidth, y);
      canvas.drawPath(filPath, Paint()..color = filColor..strokeWidth = 1.6);

      if (isCircuitEnergized) {
        canvas.drawCircle(fuseRect.center, 2.0, Paint()..color = const Color(0xFFFEF08A));
      }
    }

    // Inscrição miniatura na tampa
    _drawText(canvas, 'F100mA', Offset(fuseRect.center.dx - 12, y + 10), const Color(0xFF64748B), 7);
  }

  /// Resistor com pernas axiais dobradas e faixas de código de cores
  void _drawResistorOnBreadboard(Canvas canvas, double x1, double x2, double y) {
    // 1. Pernas de Arame Prateado Rígido entrando nos furos
    final leadPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final bodyWidth = (x2 - x1) * 0.55;
    final bodyCenter = Offset((x1 + x2) / 2, y);

    // Perna esquerda: furo x1 -> centro
    canvas.drawLine(Offset(x1, y), Offset(bodyCenter.dx - bodyWidth / 2, y), leadPaint);
    // Perna direita: centro -> furo x2
    canvas.drawLine(Offset(bodyCenter.dx + bodyWidth / 2, y), Offset(x2, y), leadPaint);

    // Pontas de solda/furo
    canvas.drawCircle(Offset(x1, y), 2.2, Paint()..color = const Color(0xFFCBD5E1));
    canvas.drawCircle(Offset(x2, y), 2.2, Paint()..color = const Color(0xFFCBD5E1));

    // 2. Sombra do Resistor
    final bodyRect = Rect.fromCenter(center: bodyCenter, width: bodyWidth, height: 11);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect.shift(const Offset(2, 3)), const Radius.circular(4)),
      Paint()..color = Colors.black26..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // 3. Corpo Cerâmico (Haltere com extremidades abauladas)
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFDE68A), Color(0xFFE2C9A7), Color(0xFFB49B7A)],
      ).createShader(bodyRect);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(4)), bodyPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(4)), Paint()..color = const Color(0xFF92673B)..style = PaintingStyle.stroke..strokeWidth = 0.8);

    // 4. Faixas de Cores do Resistor 680Ω (Azul, Cinza, Marrom, Ouro)
    final bandWidth = bodyWidth * 0.11;
    final startBandX = bodyRect.left + bodyWidth * 0.16;
    final bandSpacing = bodyWidth * 0.20;

    canvas.drawRect(Rect.fromLTWH(startBandX, bodyRect.top, bandWidth, 11), Paint()..color = const Color(0xFF2563EB)); // 6 (Azul)
    canvas.drawRect(Rect.fromLTWH(startBandX + bandSpacing, bodyRect.top, bandWidth, 11), Paint()..color = const Color(0xFF64748B)); // 8 (Cinza)
    canvas.drawRect(Rect.fromLTWH(startBandX + 2 * bandSpacing, bodyRect.top, bandWidth, 11), Paint()..color = const Color(0xFF78350F)); // ×10 (Marrom)
    canvas.drawRect(Rect.fromLTWH(startBandX + 3 * bandSpacing, bodyRect.top, bandWidth * 0.8, 11), Paint()..color = const Color(0xFFEAB308)); // ±5% (Ouro)

    // Badge com o valor nominal
    _drawText(canvas, '680Ω', Offset(bodyCenter.dx - 8, y + 7), const Color(0xFF64748B), 7.5);
  }

  /// LED 5mm de Alta Fidelidade com Ânodo e Cátodo nos furos
  void _drawLedOnBreadboard(Canvas canvas, Offset anodePos, Offset cathodePos) {
    final ledOn = isCircuitEnergized;
    final center = Offset((anodePos.dx + cathodePos.dx) / 2, (anodePos.dy + cathodePos.dy) / 2 - 12);

    // 1. Pernas metálicas entrando nos furos
    final leadPaint = Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 2.0..style = PaintingStyle.stroke;
    canvas.drawLine(anodePos, Offset(center.dx - 3, center.dy + 7), leadPaint);
    canvas.drawLine(cathodePos, Offset(center.dx + 3, center.dy + 7), leadPaint);

    canvas.drawCircle(anodePos, 2.2, Paint()..color = const Color(0xFFCBD5E1));
    canvas.drawCircle(cathodePos, 2.2, Paint()..color = const Color(0xFFCBD5E1));

    // 2. Halo Volumétrico de Iluminação (quando aceso)
    const ledRadius = 9.5;
    if (ledOn) {
      canvas.drawCircle(
        center,
        24,
        Paint()
          ..color = const Color(0xFF10B981).withValues(alpha: 0.42)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
    }

    // 3. Flange da Base do LED (com chanfro reto no cátodo)
    final flangeRect = Rect.fromCenter(center: Offset(center.dx, center.dy + 6), width: 17, height: 4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(flangeRect, const Radius.circular(1.5)),
      Paint()..color = ledOn ? const Color(0xFF059669) : const Color(0xFF064E3B),
    );

    // 4. Cúpula de Resina Epóxi Difusa
    final effColor = ledOn ? const Color(0xFF10B981) : const Color(0xFF047857);
    final domePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.35),
        colors: [
          Colors.white.withValues(alpha: ledOn ? 0.95 : 0.40),
          effColor,
          const Color(0xFF064E3B),
        ],
        stops: const [0.0, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: ledRadius));

    canvas.drawCircle(center, ledRadius, domePaint);
    canvas.drawCircle(center, ledRadius, Paint()..color = const Color(0xFF064E3B)..style = PaintingStyle.stroke..strokeWidth = 1.0);

    // Reflexo especular na lente
    canvas.drawCircle(center.translate(-3, -3), 2.2, Paint()..color = Colors.white.withValues(alpha: ledOn ? 0.85 : 0.30));

    _drawText(canvas, 'LED', Offset(center.dx - 6, center.dy + 10), const Color(0xFF64748B), 7);
  }

  /// Buzzer Piezoelétrico com orifício de som e ondas acústicas
  void _drawBuzzerOnBreadboard(Canvas canvas, Offset pos) {
    // Sombra
    canvas.drawCircle(pos.translate(2, 4), 13, Paint()..color = Colors.black26..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));

    // Corpo Cilíndrico
    final bodyPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.3),
        colors: [Color(0xFF334155), Color(0xFF1E293B), Color(0xFF0F172A)],
      ).createShader(Rect.fromCircle(center: pos, radius: 13));
    canvas.drawCircle(pos, 13, bodyPaint);
    canvas.drawCircle(pos, 13, Paint()..color = const Color(0xFF475569)..style = PaintingStyle.stroke..strokeWidth = 1.2);

    // Orifício acústico central
    canvas.drawCircle(pos, 4.5, Paint()..color = const Color(0xFF020617));

    // Símbolo polar (+)
    _drawText(canvas, '+', pos.translate(6, -11), const Color(0xFF94A3B8), 8.5);

    // Ondas sonoras se o circuito estiver energizado
    if (isCircuitEnergized) {
      final waveRadius = 15 + 7 * (animValue % 1.0);
      final wavePaint = Paint()
        ..color = const Color(0xFF38BDF8).withValues(alpha: (1.0 - (animValue % 1.0)) * 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8;
      canvas.drawArc(Rect.fromCircle(center: pos, radius: waveRadius), -0.7, 1.4, false, wavePaint);
    }
  }

  /// Conector Dupont injetado (inserção no furo da protoboard)
  void _drawDupontTip(Canvas canvas, Offset pos, Color wireColor, {bool isPointingDown = true}) {
    final tipRect = Rect.fromCenter(
      center: Offset(pos.dx, isPointingDown ? pos.dy - 6 : pos.dy + 6),
      width: 6,
      height: 10,
    );

    // Corpo plástico preto do Dupont
    canvas.drawRRect(RRect.fromRectAndRadius(tipRect, const Radius.circular(1.5)), Paint()..color = const Color(0xFF1E293B));
    canvas.drawRRect(RRect.fromRectAndRadius(tipRect, const Radius.circular(1.5)), Paint()..color = const Color(0xFF475569)..style = PaintingStyle.stroke..strokeWidth = 0.8);

    // Colar de alívio com a cor do fio
    final collarY = isPointingDown ? tipRect.top : tipRect.bottom;
    canvas.drawCircle(Offset(pos.dx, collarY), 2.0, Paint()..color = wireColor);

    // Pino metálico niquelado inserido
    canvas.drawCircle(pos, 1.8, Paint()..color = const Color(0xFFCBD5E1));
  }

  /// Fio de Curto Jumper com faíscas pedagógicas
  void _drawShortCircuitJumper(Canvas canvas, double x1, double y1, double x2, double y2) {
    final path = Path()
      ..moveTo(x1, y1)
      ..cubicTo(x1 + 10, y1 + 35, x2 - 15, y2 - 25, x2, y2);

    canvas.drawPath(path.shift(const Offset(2, 3)), Paint()..color = Colors.black26..strokeWidth = 5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFF59E0B)
        ..strokeWidth = 4.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    _drawDupontTip(canvas, Offset(x1, y1), const Color(0xFFF59E0B), isPointingDown: false);
    _drawDupontTip(canvas, Offset(x2, y2), const Color(0xFFF59E0B), isPointingDown: true);

    // Faíscas elétricas pedagógicas
    for (int i = 0; i < 5; i++) {
      final angle = (animValue * math.pi * 2) + (i * math.pi / 2.5);
      final r = 7 + 5 * math.sin(animValue * math.pi * 4 + i);
      final px = x1 + r * math.cos(angle);
      final py = y1 + r * math.sin(angle);
      canvas.drawCircle(Offset(px, py), 2.0, Paint()..color = const Color(0xFFFDE047));
    }
  }

  /// Pontas de Prova do Multímetro para Teste de Continuidade (M2)
  void _drawContinuityProbesOnBreadboard(Canvas canvas, double redX, double redY, double blackX, double blackY) {
    final redProbeTop = Offset(redX + 16, redY - 32);
    final blackProbeTop = Offset(blackX - 16, blackY - 32);

    // Haste vermelha (+)
    canvas.drawLine(redProbeTop, Offset(redX, redY), Paint()..color = const Color(0xFFEF4444)..strokeWidth = 4.0..strokeCap = StrokeCap.round);
    canvas.drawCircle(Offset(redX, redY), 2.5, Paint()..color = const Color(0xFFCBD5E1)); // Ponta de agulha metálica

    // Haste preta (-)
    canvas.drawLine(blackProbeTop, Offset(blackX, blackY), Paint()..color = const Color(0xFF1E293B)..strokeWidth = 4.0..strokeCap = StrokeCap.round);
    canvas.drawCircle(Offset(blackX, blackY), 2.5, Paint()..color = const Color(0xFFCBD5E1));

    // Status do teste
    final testOk = isContinuityOk;
    final testColor = testOk ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    _drawText(canvas, testOk ? 'CONTINUIDADE OK (BIP)' : 'SEM SINAL (CABO ROMPIDO)', Offset((redX + blackX) / 2 - 50, redY - 42), testColor, 9.0);
  }

  /// Fios Jumpers que interligam a Bateria, a Protoboard e todos os blocos do circuito
  void _drawJumpersAndWires(Canvas canvas, Rect bb, Rect bat) {
    const cols = 24;
    final startX = bb.left + 36.0;
    final stepX = (bb.width - 72.0) / (cols - 1);

    final rowStepTop = (bb.height * 0.24) / 4;
    final rowStartYTop = bb.top + bb.height * 0.22;

    final rowStepBot = (bb.height * 0.24) / 4;
    final rowStartYBot = bb.top + bb.height * 0.55;

    final topPowerPlusY = bb.top + bb.height * 0.08;
    final botPowerMinusY = bb.top + bb.height * 0.85;
    final trenchY = bb.top + bb.height * 0.50;

    final col4X = startX + 3 * stepX;
    final col7X = startX + 6 * stepX;
    final col11X = startX + 10 * stepX;
    final col13X = startX + 12 * stepX;
    final col17X = startX + 16 * stepX;
    final col19X = startX + 18 * stepX;

    final rowAY = rowStartYTop;
    final rowCY = rowStartYTop + 2 * rowStepTop;
    final rowEY = rowStartYTop + 4 * rowStepTop;
    final rowFY = rowStartYBot;
    final rowIY = rowStartYBot + 3 * rowStepBot;

    final wireRed = const Color(0xFFDC2626);
    final wireBlack = const Color(0xFF1E293B);
    final wireOrange = const Color(0xFFF97316);
    final wireBlue = const Color(0xFF2563EB);

    // 1. Cabo Vermelho (+) da Bateria -> Barramento Superior (+) da Protoboard
    final batPosTerm = Offset(bat.left - 8, bat.top + bat.height * 0.28);
    final bbPowerTopPlus = Offset(bb.right - 28, topPowerPlusY);
    _drawCatenaryWire(
      canvas,
      batPosTerm,
      Offset(bat.left - 25, bat.top - 12),
      Offset(bbPowerTopPlus.dx + 18, topPowerPlusY - 10),
      bbPowerTopPlus,
      wireRed,
      thickness: 4.2,
    );
    _drawDupontTip(canvas, bbPowerTopPlus, wireRed, isPointingDown: true);

    // 2. Cabo Preto (–) da Bateria -> Barramento Inferior (-) da Protoboard
    final batNegTerm = Offset(bat.left - 8, bat.top + bat.height * 0.72);
    final bbPowerBotMinus = Offset(bb.right - 28, botPowerMinusY);
    _drawCatenaryWire(
      canvas,
      batNegTerm,
      Offset(bat.left - 25, bat.bottom + 12),
      Offset(bbPowerBotMinus.dx + 18, botPowerMinusY + 10),
      bbPowerBotMinus,
      wireBlack,
      thickness: 4.2,
    );
    _drawDupontTip(canvas, bbPowerBotMinus, wireBlack, isPointingDown: false);

    // 3. Jumper Barramento Topo (+) -> Entrada da Chave de Segurança (Coluna 4, Linha A)
    final pPowerToSwStart = Offset(startX + 2 * stepX, topPowerPlusY);
    final pPowerToSwEnd = Offset(col4X, rowAY);
    _drawCatenaryWire(
      canvas,
      pPowerToSwStart,
      Offset(col4X - 12, topPowerPlusY + 15),
      Offset(col4X - 8, rowAY - 10),
      pPowerToSwEnd,
      wireRed,
      thickness: 3.6,
    );
    _drawDupontTip(canvas, pPowerToSwStart, wireRed, isPointingDown: true);
    _drawDupontTip(canvas, pPowerToSwEnd, wireRed, isPointingDown: true);

    // 4. Jumper Saída da Chave -> Entrada do Porta-Fusível (Coluna 4 para Coluna 7)
    final pSwOut = Offset(col4X, trenchY - 14);
    final pFuseIn = Offset(col7X, rowCY);

    if (isWireBroken && !isWireRepaired) {
      // M2: Fio rompido com pontas de cobre expostas
      final midBreak = Offset((pSwOut.dx + pFuseIn.dx) / 2, (pSwOut.dy + pFuseIn.dy) / 2 - 8);

      final pPart1 = Path()..moveTo(pSwOut.dx, pSwOut.dy)..quadraticBezierTo(pSwOut.dx + 6, pSwOut.dy - 12, midBreak.dx - 5, midBreak.dy);
      final pPart2 = Path()..moveTo(midBreak.dx + 5, midBreak.dy)..quadraticBezierTo(pFuseIn.dx - 6, pFuseIn.dy - 12, pFuseIn.dx, pFuseIn.dy);

      canvas.drawPath(pPart1, Paint()..color = wireOrange..strokeWidth = 3.4..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
      canvas.drawPath(pPart2, Paint()..color = wireOrange..strokeWidth = 3.4..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);

      // Cobre exposto desfiado nas pontas
      canvas.drawCircle(Offset(midBreak.dx - 5, midBreak.dy), 2.2, Paint()..color = const Color(0xFFF59E0B));
      canvas.drawCircle(Offset(midBreak.dx + 5, midBreak.dy), 2.2, Paint()..color = const Color(0xFFF59E0B));

      _drawDupontTip(canvas, pSwOut, wireOrange, isPointingDown: false);
      _drawDupontTip(canvas, pFuseIn, wireOrange, isPointingDown: true);
    } else {
      // Fio íntegro ou reparado com luva termorretrátil
      _drawCatenaryWire(
        canvas,
        pSwOut,
        Offset(col4X + 8, pSwOut.dy - 14),
        Offset(col7X - 8, rowCY - 14),
        pFuseIn,
        wireOrange,
        thickness: 3.6,
      );
      _drawDupontTip(canvas, pSwOut, wireOrange, isPointingDown: false);
      _drawDupontTip(canvas, pFuseIn, wireOrange, isPointingDown: true);

      if (isWireBroken && isWireRepaired) {
        // Luva Termorretrátil Azul cobrindo a emenda
        final midFix = Offset((pSwOut.dx + pFuseIn.dx) / 2, (pSwOut.dy + pFuseIn.dy) / 2 - 12);
        final fixRect = Rect.fromCenter(center: midFix, width: 14, height: 7);
        canvas.drawRRect(RRect.fromRectAndRadius(fixRect, const Radius.circular(2)), Paint()..color = const Color(0xFF1D4ED8));
        canvas.drawLine(Offset(fixRect.left + 3, fixRect.top), Offset(fixRect.left + 3, fixRect.bottom), Paint()..color = const Color(0xFF93C5FD)..strokeWidth = 1.0);
        canvas.drawLine(Offset(fixRect.right - 3, fixRect.top), Offset(fixRect.right - 3, fixRect.bottom), Paint()..color = const Color(0xFF93C5FD)..strokeWidth = 1.0);
      }
    }

    // 5. Jumper Saída do Fusível -> Entrada do Resistor (Coluna 11 para Coluna 13)
    final pFuseOut = Offset(col11X, rowCY);
    final pResIn = Offset(col13X, rowCY);
    final bridgePath = Path()
      ..moveTo(pFuseOut.dx, pFuseOut.dy)
      ..cubicTo(pFuseOut.dx + 4, rowCY - 10, pResIn.dx - 4, rowCY - 10, pResIn.dx, pResIn.dy);
    canvas.drawPath(bridgePath, Paint()..color = wireOrange..strokeWidth = 3.2..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    _drawDupontTip(canvas, pFuseOut, wireOrange, isPointingDown: true);
    _drawDupontTip(canvas, pResIn, wireOrange, isPointingDown: true);

    // 6. Jumper de Travessia da Vala Central (Coluna 17: Linha E -> Linha F)
    final pTrenchTop = Offset(col17X, rowEY);
    final pTrenchBot = Offset(col17X, rowFY);
    final trenchJumper = Path()
      ..moveTo(pTrenchTop.dx, pTrenchTop.dy)
      ..cubicTo(col17X + 10, pTrenchTop.dy + 10, col17X + 10, pTrenchBot.dy - 10, pTrenchBot.dx, pTrenchBot.dy);
    canvas.drawPath(trenchJumper, Paint()..color = wireBlue..strokeWidth = 3.4..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    _drawDupontTip(canvas, pTrenchTop, wireBlue, isPointingDown: true);
    _drawDupontTip(canvas, pTrenchBot, wireBlue, isPointingDown: false);

    // 7. Jumper Retorno do LED -> Barramento Inferior (-) (Coluna 19 -> Barramento -)
    final pLedOut = Offset(col19X, rowIY);
    final pGndEnd = Offset(col19X + 6, botPowerMinusY);
    _drawCatenaryWire(
      canvas,
      pLedOut,
      Offset(col19X, pLedOut.dy + 12),
      Offset(pGndEnd.dx, botPowerMinusY - 12),
      pGndEnd,
      wireBlack,
      thickness: 3.4,
    );
    _drawDupontTip(canvas, pLedOut, wireBlack, isPointingDown: false);
    _drawDupontTip(canvas, pGndEnd, wireBlack, isPointingDown: false);

    // 8. Animação de Fluxo de Elétrons
    if (isCircuitEnergized || isShortCircuitActive) {
      _drawAnimatedElectrons(canvas, bb, bat, col4X, col7X, col17X, topPowerPlusY, botPowerMinusY, trenchY);
    }
  }

  void _drawCatenaryWire(Canvas canvas, Offset start, Offset ctrl1, Offset ctrl2, Offset end, Color color, {double thickness = 3.6}) {
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(ctrl1.dx, ctrl1.dy, ctrl2.dx, ctrl2.dy, end.dx, end.dy);

    // Sombra do fio
    canvas.drawPath(
      path.shift(const Offset(2, 3)),
      Paint()..color = Colors.black26..strokeWidth = thickness + 1.2..style = PaintingStyle.stroke..strokeCap = StrokeCap.round,
    );

    // Fio encapado com brilho
    canvas.drawPath(
      path,
      Paint()..color = color..strokeWidth = thickness..style = PaintingStyle.stroke..strokeCap = StrokeCap.round,
    );
  }

  void _drawAnimatedElectrons(
    Canvas canvas,
    Rect bb,
    Rect bat,
    double col4X,
    double col7X,
    double col17X,
    double topPlusY,
    double botMinusY,
    double trenchY,
  ) {
    final electronColor = isShortCircuitActive ? const Color(0xFFEF4444) : const Color(0xFF38BDF8);
    final electronPaint = Paint()..color = electronColor..style = PaintingStyle.fill;

    for (double t = 0; t < 1.0; t += 0.12) {
      final curT = (t + animValue) % 1.0;
      Offset pt;
      if (curT < 0.30) {
        final subT = curT / 0.30;
        pt = Offset(
          bat.left - 8 + subT * (col4X - (bat.left - 8)),
          bat.top + bat.height * 0.28 + subT * (trenchY - (bat.top + bat.height * 0.28)),
        );
      } else if (curT < 0.65) {
        final subT = (curT - 0.30) / 0.35;
        if (isShortCircuitActive) {
          pt = Offset(col4X + subT * 10, trenchY + subT * (botMinusY - trenchY));
        } else {
          pt = Offset(col7X + subT * (col17X - col7X), bb.top + bb.height * 0.32);
        }
      } else {
        final subT = (curT - 0.65) / 0.35;
        pt = Offset(
          col17X + subT * (bat.left - 8 - col17X),
          botMinusY + subT * (bat.top + bat.height * 0.72 - botMinusY),
        );
      }
      canvas.drawCircle(pt, 2.6, electronPaint);
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
