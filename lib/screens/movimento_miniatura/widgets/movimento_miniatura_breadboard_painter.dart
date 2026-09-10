import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Painter de bancada para o Estande 06 (Movimento em Miniatura — Motor CC).
/// Renderiza:
/// - Motor CC 130 realista na VERTICAL (à esquerda) com hélice aerodinâmica de 3 pás com acabamento
///   premium e efeito de rotação realista / fluxo de ar, carcaça metálica com chanfros e ventilação,
///   tampa traseira amarela inferior com terminais de cobre
/// - Bateria 9V na HORIZONTAL (à direita) com acabamento em cobre, terminais e snap clip
/// - Protoboard central com proporções harmonizadas, linhas a-j, colunas 1-20 e barramentos (+/-)
/// - Componentes montados: Transistores NPN TO-92, Resistores, Pushbutton e LEDs de sentido (D0/D1)
/// - Fiação flexível em curvas catenárias suaves com elétrons em fluxo animado
/// - Modo Esquemático (IEEE / IEC) com símbolo clássico de Motor CC (M) e transistores
class MovimentoMiniaturaBreadboardPainter extends CustomPainter {
  final double animationValue;
  final bool usePhysicalStyle;
  final bool isClosed;
  final bool isReversed;
  final bool hasMotor;
  final bool showPushButton;
  final bool isPushButtonPressed;
  final bool showTransistor;
  final bool isTransistorTriggered;
  final bool showHBridge;
  final int hBridgeDirection; // 0 = off, 1 = forward (D0 / verde), 2 = reverse (D1 / vermelho)
  final bool hasIndicatorLed;
  final bool isFaulty;
  final String? faultType;

  MovimentoMiniaturaBreadboardPainter({
    required this.animationValue,
    this.usePhysicalStyle = true,
    required this.isClosed,
    this.isReversed = false,
    this.hasMotor = true,
    this.showPushButton = false,
    this.isPushButtonPressed = false,
    this.showTransistor = false,
    this.isTransistorTriggered = false,
    this.showHBridge = false,
    this.hBridgeDirection = 1,
    this.hasIndicatorLed = false,
    this.isFaulty = false,
    this.faultType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (usePhysicalStyle) {
      _paintPhysicalWorkbench(canvas, size);
    } else {
      _paintSchematicWorkbench(canvas, size);
    }
  }

  // =========================================================================
  // MODO FÍSICO REALISTA (Motor vertical com hélices, Protoboard e Bateria horizontal)
  // =========================================================================

  void _paintPhysicalWorkbench(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Proporções da Protoboard Central
    final bbLeft = (w * 0.31).clamp(180.0, 290.0);
    final bbWidth = (w * 0.42).clamp(240.0, 380.0);
    final bbTop = (h * 0.22).clamp(65.0, 105.0);
    final bbHeight = (h * 0.54).clamp(165.0, 235.0);
    final breadboardRect = Rect.fromLTWH(bbLeft, bbTop, bbWidth, bbHeight);

    // 2. Motor CC 130 na VERTICAL (à esquerda da Protoboard, com hélices no topo)
    final motorWidth = (w * 0.15).clamp(72.0, 96.0);
    final motorHeight = (motorWidth * 1.45).clamp(105.0, 138.0);
    final motorLeft = (w * 0.08).clamp(20.0, 52.0);
    final motorTop = bbTop + (bbHeight - motorHeight) * 0.52 + 10.0;
    final motorRect = Rect.fromLTWH(motorLeft, motorTop, motorWidth, motorHeight);

    // 3. Bateria 9V na HORIZONTAL (à direita da Protoboard)
    final batWidth = (w * 0.19).clamp(95.0, 145.0);
    final batHeight = (batWidth * 0.60).clamp(58.0, 88.0);
    final batLeft = (bbLeft + bbWidth + (w * 0.04)).clamp(w * 0.77, w * 0.83);
    final batTop = bbTop + (bbHeight - batHeight) * 0.46;
    final batteryRect = Rect.fromLTWH(batLeft, batTop, batWidth, batHeight);

    // Renderizar Elementos
    _drawHorizontal9VBattery(canvas, batteryRect);
    _drawBreadboard(canvas, breadboardRect);
    _drawVerticalDCMotor(canvas, motorRect);
    _drawCircuitConnections(canvas, size, motorRect, breadboardRect, batteryRect);
  }

  /// Desenha a Bateria 9V deitada horizontalmente (terminais virados para a protoboard)
  void _drawHorizontal9VBattery(Canvas canvas, Rect rect) {
    // Sombra suave
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.shift(const Offset(3, 5)), const Radius.circular(8)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.32)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    const bodyRadius = Radius.circular(8);

    // Lado direito: Corpo preto (~72% da largura)
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

    // Lado esquerdo (voltado para a protoboard): Faixa vertical de cobre (~28% da largura)
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

    // Linha de divisão vertical
    canvas.drawLine(
      Offset(blackRect.left, rect.top),
      Offset(blackRect.left, rect.bottom),
      Paint()..color = Colors.black.withValues(alpha: 0.8)..strokeWidth = 1.4,
    );

    // Borda do corpo
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, bodyRadius),
      Paint()..color = const Color(0xFF334155).withValues(alpha: 0.5)..style = PaintingStyle.stroke..strokeWidth = 1.2,
    );

    // Rótulo "9V" no corpo preto
    final textPainter = TextPainter(
      text: TextSpan(
        text: '9V',
        style: GoogleFonts.rajdhani(
          color: Colors.white.withValues(alpha: 0.90),
          fontWeight: FontWeight.bold,
          fontSize: (rect.height * 0.42).clamp(16.0, 26.0),
          letterSpacing: 2.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(blackRect.center.dx - textPainter.width / 2, blackRect.center.dy - textPainter.height / 2),
    );

    // Marcações "+" e "-" na faixa de cobre
    final posTerminalY = rect.top + rect.height * 0.28;
    final negTerminalY = rect.top + rect.height * 0.72;

    final posSign = TextPainter(text: TextSpan(text: '+', style: GoogleFonts.rajdhani(color: const Color(0xFFFEF08A), fontWeight: FontWeight.bold, fontSize: 13)), textDirection: TextDirection.ltr)..layout();
    final negSign = TextPainter(text: TextSpan(text: '–', style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)), textDirection: TextDirection.ltr)..layout();
    posSign.paint(canvas, Offset(copperRect.center.dx - posSign.width / 2, posTerminalY - posSign.height / 2));
    negSign.paint(canvas, Offset(copperRect.center.dx - negSign.width / 2, negTerminalY - negSign.height / 2));

    // Terminais metálicos à esquerda da bateria
    final termLeftX = rect.left;
    final termPosCenter = Offset(termLeftX - 4, posTerminalY);
    final termNegCenter = Offset(termLeftX - 4, negTerminalY);

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: termPosCenter, width: 7, height: rect.height * 0.22), const Radius.circular(2)), Paint()..color = const Color(0xFF94A3B8));
    canvas.drawCircle(termPosCenter, 3.0, Paint()..color = const Color(0xFFE2E8F0));

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: termNegCenter, width: 7, height: rect.height * 0.24), const Radius.circular(2)), Paint()..color = const Color(0xFF64748B));
    canvas.drawCircle(termNegCenter, 2.6, Paint()..color = const Color(0xFF1E293B));

    // Snap Clip Bar escuro
    final clipBarRect = Rect.fromLTWH(termLeftX - 12, rect.top + rect.height * 0.12, 7, rect.height * 0.76);
    canvas.drawRRect(RRect.fromRectAndRadius(clipBarRect, const Radius.circular(3)), Paint()..color = const Color(0xFF0F172A));
    canvas.drawCircle(Offset(clipBarRect.center.dx, posTerminalY), 2.2, Paint()..color = const Color(0xFFCBD5E1));
    canvas.drawCircle(Offset(clipBarRect.center.dx, negTerminalY), 2.2, Paint()..color = const Color(0xFFCBD5E1));
  }

  /// Desenha o Motor CC 130 na VERTICAL com Hélice Aerodinâmica de Alta Performance no Topo
  void _drawVerticalDCMotor(Canvas canvas, Rect rect) {
    // Sombra suave do motor
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.shift(const Offset(3, 5)), const Radius.circular(10)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );

    // Divisão das partes do Motor 130 Vertical:
    // [Hélice & Bucha no Eixo] (topo) | [Carcaça Metálica] (centro) | [Tampa Traseira Amarela] (base inferior)
    final rearCapHeight = rect.height * 0.18;
    final metalBodyHeight = rect.height * 0.82;

    // 1. Tampa Traseira Plástica na Base (amarela/dourada clássica)
    final rearRect = Rect.fromLTWH(rect.left, rect.bottom - rearCapHeight, rect.width, rearCapHeight);
    final rearPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Color(0xFFCA8A04), Color(0xFFFACC15), Color(0xFFEAB308), Color(0xFFCA8A04)],
      ).createShader(rearRect);

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        rearRect,
        bottomLeft: const Radius.circular(8),
        bottomRight: const Radius.circular(8),
      ),
      rearPaint,
    );

    // 2. Terminais de Cobre na Base Inferior (lâminas de contato com olhais de solda)
    final term1X = rect.left + rect.width * 0.28;
    final term2X = rect.left + rect.width * 0.72;
    final copperLeadPaint = Paint()..color = const Color(0xFFD97706)..strokeWidth = 3.5..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(term1X, rect.bottom - 2), Offset(term1X, rect.bottom + 8), copperLeadPaint);
    canvas.drawLine(Offset(term2X, rect.bottom - 2), Offset(term2X, rect.bottom + 8), copperLeadPaint);

    // Olhais de solda
    canvas.drawCircle(Offset(term1X, rect.bottom + 8), 2.2, Paint()..color = const Color(0xFF1E293B));
    canvas.drawCircle(Offset(term2X, rect.bottom + 8), 2.2, Paint()..color = const Color(0xFF1E293B));

    // 3. Carcaça Metálica Cilíndrica Central com Chanfros Verticais
    final metalRect = Rect.fromLTWH(rect.left, rect.top, rect.width, metalBodyHeight);
    final metalPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Color(0xFF334155), Color(0xFF64748B), Color(0xFFE2E8F0), Color(0xFF94A3B8), Color(0xFF475569)],
        stops: [0.0, 0.22, 0.50, 0.78, 1.0],
      ).createShader(metalRect);

    // Formato com chanfros laterais (característica do motor 130)
    final motorBodyPath = Path()
      ..moveTo(metalRect.left + 6, metalRect.top)
      ..lineTo(metalRect.right - 6, metalRect.top)
      ..lineTo(metalRect.right, metalRect.top + 8)
      ..lineTo(metalRect.right, metalRect.bottom - 6)
      ..lineTo(metalRect.right - 6, metalRect.bottom)
      ..lineTo(metalRect.left + 6, metalRect.bottom)
      ..lineTo(metalRect.left, metalRect.bottom - 6)
      ..lineTo(metalRect.left, metalRect.top + 8)
      ..close();
    canvas.drawPath(motorBodyPath, metalPaint);

    // Borda metálica sutil
    canvas.drawPath(motorBodyPath, Paint()..color = const Color(0xFF1E293B).withValues(alpha: 0.6)..style = PaintingStyle.stroke..strokeWidth = 1.4);

    // Ranhuras de ventilação estampadas na carcaça metálica (horizontais)
    final ventPaint = Paint()..color = const Color(0xFF1E293B)..strokeWidth = 2.2..strokeCap = StrokeCap.round;
    final ventY1 = metalRect.top + metalBodyHeight * 0.26;
    final ventY2 = metalRect.top + metalBodyHeight * 0.68;
    canvas.drawLine(Offset(metalRect.left + 12, ventY1), Offset(metalRect.left + 24, ventY1), ventPaint);
    canvas.drawLine(Offset(metalRect.right - 24, ventY1), Offset(metalRect.right - 12, ventY1), ventPaint);
    canvas.drawLine(Offset(metalRect.left + 12, ventY2), Offset(metalRect.left + 24, ventY2), ventPaint);
    canvas.drawLine(Offset(metalRect.right - 24, ventY2), Offset(metalRect.right - 12, ventY2), ventPaint);

    // Rebites de fixação central
    canvas.drawCircle(Offset(metalRect.center.dx - 14, metalRect.center.dy), 2.2, Paint()..color = const Color(0xFFCBD5E1));
    canvas.drawCircle(Offset(metalRect.center.dx + 14, metalRect.center.dy), 2.2, Paint()..color = const Color(0xFFCBD5E1));

    // Rótulo na carcaça
    final tp = TextPainter(
      text: TextSpan(
        text: 'MOTOR CC 6V',
        style: GoogleFonts.rajdhani(
          color: const Color(0xFF0F172A).withValues(alpha: 0.88),
          fontWeight: FontWeight.bold,
          fontSize: (rect.width * 0.16).clamp(10.0, 13.0),
          letterSpacing: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(metalRect.center.dx - tp.width / 2, metalRect.center.dy - tp.height / 2));

    // 4. Mancal / Bucha de Bronze e Eixo Superior
    final shaftCenterX = rect.center.dx;
    final shaftTopY = rect.top - 20;

    // Colar da bucha de bronze
    final bushingRect = Rect.fromCenter(center: Offset(shaftCenterX, rect.top - 2), width: 14, height: 6);
    canvas.drawRRect(RRect.fromRectAndRadius(bushingRect, const Radius.circular(2)), Paint()..color = const Color(0xFFD97706));

    // Eixo de aço polido
    canvas.drawLine(
      Offset(shaftCenterX, rect.top),
      Offset(shaftCenterX, shaftTopY),
      Paint()..color = const Color(0xFFE2E8F0)..strokeWidth = 3.8..strokeCap = StrokeCap.round,
    );

    // 5. Hélice Aerodinâmica Realista (Fan Propeller) no Topo do Eixo
    final propellerCenter = Offset(shaftCenterX, shaftTopY);
    _drawAerodynamicPropeller(canvas, propellerCenter);

    // 6. Badge de Status do Motor (abaixo da base)
    final isMotorActive = isClosed && hasMotor && (!isFaulty);
    final rotationText = isMotorActive
        ? (isReversed ? 'ANTI-HORÁRIO ↺' : 'HORÁRIO ↻')
        : 'MOTOR PARADO ⏸';
    final rotationColor = isMotorActive
        ? (isReversed ? const Color(0xFFF97316) : const Color(0xFF10B981))
        : const Color(0xFF64748B);

    final badgePainter = TextPainter(
      text: TextSpan(
        text: rotationText,
        style: GoogleFonts.rajdhani(color: rotationColor, fontWeight: FontWeight.bold, fontSize: 9.5),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final badgeRect = Rect.fromCenter(center: Offset(rect.center.dx, rect.bottom + 22), width: badgePainter.width + 12, height: 18);
    canvas.drawRRect(RRect.fromRectAndRadius(badgeRect, const Radius.circular(6)), Paint()..color = const Color(0xFF0F172A).withValues(alpha: 0.92));
    canvas.drawRRect(RRect.fromRectAndRadius(badgeRect, const Radius.circular(6)), Paint()..color = rotationColor.withValues(alpha: 0.5)..style = PaintingStyle.stroke..strokeWidth = 1.0);
    badgePainter.paint(canvas, Offset(rect.center.dx - badgePainter.width / 2, rect.bottom + 22 - badgePainter.height / 2));
  }

  /// Desenha a Hélice Aerodinâmica de 3 Pás Realista com Spinner Central e Efeito de Vento
  void _drawAerodynamicPropeller(Canvas canvas, Offset center) {
    final isMotorActive = isClosed && hasMotor && (!isFaulty);
    final angle = isMotorActive
        ? (isReversed ? -animationValue * 2 * math.pi * 5 : animationValue * 2 * math.pi * 5)
        : 0.0;

    const bladeRadius = 32.0;
    const bladeCount = 3;

    // Sombra suave sob a hélice
    canvas.drawCircle(
      center.translate(2, 4),
      bladeRadius * 0.9,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Se o motor estiver girando rápido, renderiza o disco translúcido de motion blur
    if (isMotorActive) {
      final blurPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            (isReversed ? const Color(0xFFF97316) : const Color(0xFF38BDF8)).withValues(alpha: 0.35),
            (isReversed ? const Color(0xFFEA580C) : const Color(0xFF0284C7)).withValues(alpha: 0.15),
            Colors.transparent,
          ],
          stops: const [0.2, 0.75, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: bladeRadius + 4));
      canvas.drawCircle(center, bladeRadius + 4, blurPaint);

      // Linhas dinâmicas de vórtice / fluxo de vento
      final windPaint = Paint()
        ..color = (isReversed ? const Color(0xFFFDBA74) : const Color(0xFF7DD3FC)).withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;

      final windSpin = (animationValue * 2 * math.pi * 2) % (2 * math.pi);
      canvas.drawArc(Rect.fromCircle(center: center, radius: bladeRadius + 8), windSpin, math.pi * 0.7, false, windPaint);
      canvas.drawArc(Rect.fromCircle(center: center, radius: bladeRadius + 14), -windSpin + 1.2, math.pi * 0.5, false, windPaint);
    }

    // Desenho das 3 Pás da Hélice com rotação
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    for (int i = 0; i < bladeCount; i++) {
      final bladeAngle = i * (2 * math.pi / bladeCount);
      canvas.save();
      canvas.rotate(bladeAngle);

      final bladePath = Path();
      // Perfil aerodinâmico (Airfoil) suave com raiz e ponta arredondada
      bladePath.moveTo(0, -4);
      bladePath.cubicTo(8, -8, 14, -bladeRadius * 0.55, 6, -bladeRadius + 3);
      bladePath.quadraticBezierTo(2, -bladeRadius - 2, -2, -bladeRadius + 2);
      bladePath.cubicTo(-8, -bladeRadius * 0.65, -6, -8, 0, -4);
      bladePath.close();

      // Gradiente aerodinâmico elegante na pá (Azul elétrico / Ciano ou Laranja)
      final bladeGrad = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isReversed
            ? [const Color(0xFFFED7AA), const Color(0xFFF97316), const Color(0xFFC2410C)]
            : [const Color(0xFFE0F2FE), const Color(0xFF38BDF8), const Color(0xFF0369A1)],
      ).createShader(Rect.fromCircle(center: Offset(0, -bladeRadius / 2), radius: bladeRadius / 2));

      canvas.drawPath(bladePath, Paint()..shader = bladeGrad);

      // Friso de reflexo especular na borda de ataque da pá
      final highlightPath = Path()
        ..moveTo(2, -6)
        ..quadraticBezierTo(7, -bladeRadius * 0.5, 4, -bladeRadius + 4);
      canvas.drawPath(
        highlightPath,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.75)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round,
      );

      // Borda sutil de contorno
      canvas.drawPath(
        bladePath,
        Paint()
          ..color = (isReversed ? const Color(0xFF7C2D12) : const Color(0xFF0C4A6E)).withValues(alpha: 0.65)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9,
      );

      canvas.restore();
    }

    // Cubo Central / Ogiva (Spinner) da Hélice
    const hubRadius = 7.5;
    final spinnerGrad = RadialGradient(
      center: const Alignment(-0.35, -0.35),
      colors: [Colors.white, const Color(0xFF94A3B8), const Color(0xFF1E293B)],
      stops: const [0.0, 0.55, 1.0],
    ).createShader(Rect.fromCircle(center: Offset.zero, radius: hubRadius));

    canvas.drawCircle(Offset.zero, hubRadius, Paint()..shader = spinnerGrad);
    canvas.drawCircle(Offset.zero, hubRadius, Paint()..color = const Color(0xFF0F172A)..style = PaintingStyle.stroke..strokeWidth = 1.2);

    // Parafuso / Eixo central cromado
    canvas.drawCircle(Offset.zero, 2.5, Paint()..color = const Color(0xFFCBD5E1));
    canvas.drawCircle(Offset.zero, 1.2, Paint()..color = const Color(0xFF0F172A));

    canvas.restore();
  }

  /// Desenha a Protoboard central
  void _drawBreadboard(Canvas canvas, Rect rect) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.shift(const Offset(3, 5)), const Radius.circular(12)),
      Paint()..color = Colors.black.withValues(alpha: 0.25)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );

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
    canvas.drawLine(Offset(trenchRect.left + 4, trenchY), Offset(trenchRect.right - 4, trenchY), Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 1.2);

    // Barramentos de Alimentação (+ Vermelho e - Azul)
    final topPowerYMinus = rect.top + rect.height * 0.08;
    final topPowerYPlus = rect.top + rect.height * 0.16;
    final botPowerYMinus = rect.top + rect.height * 0.84;
    final botPowerYPlus = rect.top + rect.height * 0.92;

    final busLeft = rect.left + 20.0;
    final busRight = rect.right - 20.0;

    _drawPowerRailLine(canvas, Offset(busLeft, topPowerYMinus), Offset(busRight, topPowerYMinus), const Color(0xFF3B82F6), '-');
    _drawPowerRailLine(canvas, Offset(busLeft, topPowerYPlus), Offset(busRight, topPowerYPlus), const Color(0xFFEF4444), '+');
    _drawPowerRailLine(canvas, Offset(busLeft, botPowerYMinus), Offset(busRight, botPowerYMinus), const Color(0xFF3B82F6), '-');
    _drawPowerRailLine(canvas, Offset(busLeft, botPowerYPlus), Offset(busRight, botPowerYPlus), const Color(0xFFEF4444), '+');

    _drawBreadboardTiePoints(canvas, rect);
  }

  void _drawPowerRailLine(Canvas canvas, Offset start, Offset end, Color color, String sign) {
    canvas.drawLine(start, end, Paint()..color = color.withValues(alpha: 0.80)..strokeWidth = 1.4);
    final signPainter = TextPainter(
      text: TextSpan(text: sign, style: GoogleFonts.rajdhani(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
      textDirection: TextDirection.ltr,
    )..layout();
    signPainter.paint(canvas, Offset(start.dx - 10, start.dy - signPainter.height / 2));
    signPainter.paint(canvas, Offset(end.dx + 4, end.dy - signPainter.height / 2));
  }

  void _drawBreadboardTiePoints(Canvas canvas, Rect rect) {
    const cols = 20;
    final startX = rect.left + 30.0;
    final stepX = (rect.width - 60.0) / (cols - 1);

    final holeBgPaint = Paint()..color = const Color(0xFF64748B);
    final holeCorePaint = Paint()..color = const Color(0xFF0F172A);

    final topPowerYMinus = rect.top + rect.height * 0.08;
    final topPowerYPlus = rect.top + rect.height * 0.16;

    final rowStepTop = (rect.height * 0.22) / 4;
    final rowStartYTop = rect.top + rect.height * 0.24;

    final rowStepBot = (rect.height * 0.22) / 4;
    final rowStartYBot = rect.top + rect.height * 0.54;

    final botPowerYMinus = rect.top + rect.height * 0.84;
    final botPowerYPlus = rect.top + rect.height * 0.92;

    for (int col = 0; col < cols; col++) {
      final cx = startX + col * stepX;

      // Alimentação topo
      _drawSingleHole(canvas, Offset(cx, topPowerYMinus), holeBgPaint, holeCorePaint);
      _drawSingleHole(canvas, Offset(cx, topPowerYPlus), holeBgPaint, holeCorePaint);

      // Banco superior (5 furos)
      for (int r = 0; r < 5; r++) {
        _drawSingleHole(canvas, Offset(cx, rowStartYTop + r * rowStepTop), holeBgPaint, holeCorePaint);
      }

      // Banco inferior (5 furos)
      for (int r = 0; r < 5; r++) {
        _drawSingleHole(canvas, Offset(cx, rowStartYBot + r * rowStepBot), holeBgPaint, holeCorePaint);
      }

      // Alimentação baixo
      _drawSingleHole(canvas, Offset(cx, botPowerYMinus), holeBgPaint, holeCorePaint);
      _drawSingleHole(canvas, Offset(cx, botPowerYPlus), holeBgPaint, holeCorePaint);

      // Números de colunas
      if (col % 5 == 0 || col == cols - 1) {
        final colNum = (col + 1).toString();
        final numPainter = TextPainter(
          text: TextSpan(text: colNum, style: GoogleFonts.rajdhani(color: const Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 8.0)),
          textDirection: TextDirection.ltr,
        )..layout();
        numPainter.paint(canvas, Offset(cx - numPainter.width / 2, rect.top + 1));
      }
    }
  }

  void _drawSingleHole(Canvas canvas, Offset center, Paint bg, Paint core) {
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCircle(center: center, radius: 2.0), const Radius.circular(0.5)), bg);
    canvas.drawCircle(center, 1.0, core);
  }

  /// Desenha a fiação da bateria 9V horizontal, fiação do motor CC vertical e componentes
  void _drawCircuitConnections(Canvas canvas, Size size, Rect motorRect, Rect bbRect, Rect batRect) {
    // 1. Fiação da Bateria 9V Horizontal para a Protoboard
    final clipX = batRect.left - 8;
    final batPosTerm = Offset(clipX, batRect.top + batRect.height * 0.28);
    final batNegTerm = Offset(clipX, batRect.top + batRect.height * 0.72);

    final topPowerYPlus = bbRect.top + bbRect.height * 0.16;
    final botPowerYMinus = bbRect.top + bbRect.height * 0.84;

    final bbPowerTopPlus = Offset(bbRect.right - 24, topPowerYPlus);
    final bbPowerBotMinus = Offset(bbRect.right - 24, botPowerYMinus);

    // Cabo Vermelho (+) da Bateria
    final wirePosCtrl1 = Offset(clipX - 25, batPosTerm.dy - 20);
    final wirePosCtrl2 = Offset(bbPowerTopPlus.dx + 20, topPowerYPlus - 15);
    _drawCurvedWire(canvas, batPosTerm, wirePosCtrl1, wirePosCtrl2, bbPowerTopPlus, const Color(0xFFEF4444), isActive: true, thickness: 3.6);

    // Cabo Preto (–) da Bateria
    final wireNegCtrl1 = Offset(clipX - 25, batNegTerm.dy + 20);
    final wireNegCtrl2 = Offset(bbPowerBotMinus.dx + 20, botPowerYMinus + 15);
    _drawCurvedWire(canvas, batNegTerm, wireNegCtrl1, wireNegCtrl2, bbPowerBotMinus, const Color(0xFF1E293B), isActive: true, thickness: 3.6);

    // Coordenadas das colunas na protoboard
    const cols = 20;
    final startX = bbRect.left + 30.0;
    final stepX = (bbRect.width - 60.0) / (cols - 1);

    // 2. Fiação dos Terminais da Base do Motor CC Vertical para a Protoboard
    final motorTerm1 = Offset(motorRect.left + motorRect.width * 0.28, motorRect.bottom + 8);
    final motorTerm2 = Offset(motorRect.left + motorRect.width * 0.72, motorRect.bottom + 8);

    final col2X = startX + 2 * stepX;
    final col5X = startX + 5 * stepX;
    final rowStepTop = (bbRect.height * 0.22) / 4;
    final rowFY = bbRect.top + bbRect.height * 0.24 + 4 * rowStepTop;

    final bbMotorHole1 = Offset(col2X, rowFY);
    final bbMotorHole2 = Offset(col5X, rowFY);

    if (hasMotor) {
      // Cabo 1 do Motor (Verde ou Amarelo invertido)
      final wireM1Ctrl1 = Offset(motorTerm1.dx - 15, motorTerm1.dy + 30);
      final wireM1Ctrl2 = Offset(bbMotorHole1.dx - 25, bbMotorHole1.dy - 10);
      _drawCurvedWire(
        canvas,
        motorTerm1,
        wireM1Ctrl1,
        wireM1Ctrl2,
        bbMotorHole1,
        isReversed ? const Color(0xFFEAB308) : const Color(0xFF10B981),
        isActive: isClosed && !isFaulty,
        thickness: 3.2,
      );

      // Cabo 2 do Motor (Amarelo ou Verde invertido)
      final wireM2Ctrl1 = Offset(motorTerm2.dx + 15, motorTerm2.dy + 30);
      final wireM2Ctrl2 = Offset(bbMotorHole2.dx - 15, bbMotorHole2.dy + 15);
      _drawCurvedWire(
        canvas,
        motorTerm2,
        wireM2Ctrl1,
        wireM2Ctrl2,
        bbMotorHole2,
        isReversed ? const Color(0xFF10B981) : const Color(0xFFEAB308),
        isActive: isClosed && !isFaulty,
        thickness: 3.2,
      );
    }

    // 3. Montagem na Protoboard
    final holePlusCol2 = Offset(col2X, topPowerYPlus);
    final holeTrackTopCol2 = Offset(col2X, bbRect.top + bbRect.height * 0.24);

    if (showPushButton) {
      // Missão 3: Chave táctil em série na Coluna 2
      final trenchY = bbRect.top + bbRect.height * 0.50;
      _drawTactilePushButton(canvas, Offset(col2X, trenchY), isPressed: isClosed);
      _drawJumperWire(canvas, holePlusCol2, holeTrackTopCol2, const Color(0xFFEF4444), isActive: isClosed);
    } else if (showTransistor) {
      // Missão 4: Transistor NPN na Protoboard (Coluna 5)
      _drawTO92Transistor(canvas, Offset(col5X, rowFY), label: 'NPN');

      // Resistor de Base (1 kΩ)
      final col8X = startX + 8 * stepX;
      _drawPhysicalResistor(canvas, Offset(col5X, rowFY), Offset(col8X, rowFY), '1 kΩ');

      // LED Indicador de Motor Ativo (Verde)
      if (hasIndicatorLed) {
        final col12X = startX + 12 * stepX;
        final col15X = startX + 15 * stepX;
        _drawPhysical5mmLed(
          canvas,
          anodePos: Offset(col12X, rowFY),
          cathodePos: Offset(col15X, rowFY),
          color: const Color(0xFF10B981),
          isLit: isClosed,
        );
      }
    } else if (showHBridge) {
      // Missão 5: 4 Transistores da Ponte H na Protoboard
      final col8X = startX + 8 * stepX;
      final col12X = startX + 12 * stepX;
      final col16X = startX + 16 * stepX;

      _drawTO92Transistor(canvas, Offset(col2X, rowFY - 15), label: 'Q1');
      _drawTO92Transistor(canvas, Offset(col8X, rowFY - 15), label: 'Q2');
      _drawTO92Transistor(canvas, Offset(col12X, rowFY + 15), label: 'Q3');
      _drawTO92Transistor(canvas, Offset(col16X, rowFY + 15), label: 'Q4');

      // LEDs Indicadores de Sentido (D0 Verde / D1 Vermelho)
      final col18X = startX + 18 * stepX;
      final col20X = startX + 19 * stepX;
      _drawPhysical5mmLed(canvas, anodePos: Offset(col18X, rowFY), cathodePos: Offset(col20X, rowFY), color: const Color(0xFF10B981), isLit: hBridgeDirection == 1);
      _drawPhysical5mmLed(canvas, anodePos: Offset(col18X, rowFY + 20), cathodePos: Offset(col20X, rowFY + 20), color: const Color(0xFFEF4444), isLit: hBridgeDirection == 2);
    } else {
      // Missões 1 e 2: Jumpers diretos
      if (isFaulty) {
        _drawDisconnectedJumper(canvas, holePlusCol2, Offset(col2X + 14, holePlusCol2.dy + 12), const Color(0xFFEF4444));
      } else {
        _drawJumperWire(canvas, holePlusCol2, holeTrackTopCol2, const Color(0xFFEF4444), isActive: isClosed);
      }
    }

    // Jumper de Retorno GND (–) da Coluna 5
    final rowStepBot = (bbRect.height * 0.22) / 4;
    final rowAY = bbRect.top + bbRect.height * 0.54 + 4 * rowStepBot;
    final holeTrackBotCol5 = Offset(col5X, rowAY);
    final holeMinusCol5 = Offset(col5X, botPowerYMinus);
    _drawJumperWire(canvas, holeTrackBotCol5, holeMinusCol5, const Color(0xFF1E293B), isActive: isClosed && !isFaulty);
  }

  void _drawTO92Transistor(Canvas canvas, Offset pos, {String label = 'NPN'}) {
    const tWidth = 14.0;
    const tHeight = 12.0;
    final rect = Rect.fromCenter(center: pos.translate(0, -6), width: tWidth, height: tHeight);

    final legPaint = Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 1.6..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(pos.dx - 4, pos.dy), Offset(pos.dx - 4, rect.bottom), legPaint);
    canvas.drawLine(Offset(pos.dx, pos.dy), Offset(pos.dx, rect.bottom), legPaint);
    canvas.drawLine(Offset(pos.dx + 4, pos.dy), Offset(pos.dx + 4, rect.bottom), legPaint);

    final bodyPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRRect(RRect.fromRectAndCorners(rect, topLeft: const Radius.circular(5), topRight: const Radius.circular(5)), bodyPaint);

    final tp = TextPainter(
      text: TextSpan(text: label, style: GoogleFonts.rajdhani(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 7)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(rect.center.dx - tp.width / 2, rect.center.dy - tp.height / 2));
  }

  void _drawPhysicalResistor(Canvas canvas, Offset start, Offset end, String value) {
    final center = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
    final width = (end.dx - start.dx).abs().clamp(24.0, 44.0);
    const height = 9.0;

    final leadPaint = Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 1.6..style = PaintingStyle.stroke;
    canvas.drawLine(start, Offset(center.dx - width / 2, center.dy), leadPaint);
    canvas.drawLine(Offset(center.dx + width / 2, center.dy), end, leadPaint);

    final bodyRect = Rect.fromCenter(center: center, width: width, height: height);
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFDE68A), Color(0xFFD4B996), Color(0xFFB49B7A)],
      ).createShader(bodyRect);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(4)), bodyPaint);

    final tp = TextPainter(
      text: TextSpan(text: value, style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 8)),
      textDirection: TextDirection.ltr,
    )..layout();

    final badgeRect = Rect.fromCenter(center: Offset(center.dx, center.dy - 8), width: tp.width + 6, height: 12);
    canvas.drawRRect(RRect.fromRectAndRadius(badgeRect, const Radius.circular(3)), Paint()..color = const Color(0xFF0F172A).withValues(alpha: 0.90));
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - 8 - tp.height / 2));
  }

  void _drawPhysical5mmLed(Canvas canvas, {required Offset anodePos, required Offset cathodePos, required Color color, required bool isLit}) {
    final center = Offset((anodePos.dx + cathodePos.dx) / 2, (anodePos.dy + cathodePos.dy) / 2 - 14);
    final leadPaint = Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 1.6..style = PaintingStyle.stroke;

    canvas.drawLine(anodePos, Offset(center.dx - 3, center.dy + 6), leadPaint);
    canvas.drawLine(cathodePos, Offset(center.dx + 3, center.dy + 6), leadPaint);

    const ledRadius = 9.0;
    if (isLit) {
      canvas.drawCircle(center, 22.0, Paint()..color = color.withValues(alpha: 0.30)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
    }

    final effColor = isLit ? color : color.withValues(alpha: 0.35);
    final domePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.35),
        colors: [Colors.white.withValues(alpha: isLit ? 0.95 : 0.40), effColor, const Color(0xFF0F172A).withValues(alpha: 0.35)],
      ).createShader(Rect.fromCircle(center: center, radius: ledRadius));
    canvas.drawCircle(center, ledRadius, domePaint);
  }

  void _drawTactilePushButton(Canvas canvas, Offset center, {bool isPressed = false}) {
    const btnSize = 15.0;
    final btnRect = Rect.fromCenter(center: center, width: btnSize, height: btnSize);

    final pinPaint = Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 1.6..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(center.dx - 5, center.dy - 10), Offset(center.dx - 5, center.dy - btnSize / 2), pinPaint);
    canvas.drawLine(Offset(center.dx + 5, center.dy - 10), Offset(center.dx + 5, center.dy - btnSize / 2), pinPaint);
    canvas.drawLine(Offset(center.dx - 5, center.dy + btnSize / 2), Offset(center.dx - 5, center.dy + 10), pinPaint);
    canvas.drawLine(Offset(center.dx + 5, center.dy + btnSize / 2), Offset(center.dx + 5, center.dy + 10), pinPaint);

    canvas.drawRRect(RRect.fromRectAndRadius(btnRect, const Radius.circular(3)), Paint()..color = const Color(0xFF1E293B));
    canvas.drawCircle(center, btnSize * 0.38, Paint()..color = const Color(0xFFCBD5E1));
    canvas.drawCircle(center, isPressed ? btnSize * 0.22 : btnSize * 0.26, Paint()..color = isPressed ? const Color(0xFF10B981) : const Color(0xFFDC2626));
  }

  void _drawCurvedWire(Canvas canvas, Offset start, Offset ctrl1, Offset ctrl2, Offset end, Color color, {bool isActive = true, double thickness = 3.6}) {
    final path = Path()..moveTo(start.dx, start.dy)..cubicTo(ctrl1.dx, ctrl1.dy, ctrl2.dx, ctrl2.dy, end.dx, end.dy);
    canvas.drawPath(path.shift(const Offset(2, 3)), Paint()..color = Colors.black.withValues(alpha: 0.25)..strokeWidth = thickness + 1.2..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    canvas.drawPath(path, Paint()..color = isActive ? color : color.withValues(alpha: 0.5)..strokeWidth = thickness..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    canvas.drawCircle(end, 2.4, Paint()..color = const Color(0xFF94A3B8));
    if (isActive && isClosed && !isFaulty) {
      _drawFlowingElectrons(canvas, path);
    }
  }

  void _drawJumperWire(Canvas canvas, Offset start, Offset end, Color color, {bool isActive = true}) {
    final midY = (start.dy + end.dy) / 2;
    final path = Path()..moveTo(start.dx, start.dy)..lineTo(start.dx, midY)..lineTo(end.dx, midY)..lineTo(end.dx, end.dy);
    canvas.drawPath(path, Paint()..color = isActive ? color : color.withValues(alpha: 0.5)..strokeWidth = 3.0..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    canvas.drawCircle(start, 2.2, Paint()..color = const Color(0xFF94A3B8));
    canvas.drawCircle(end, 2.2, Paint()..color = const Color(0xFF94A3B8));
    if (isActive && isClosed && !isFaulty) {
      _drawFlowingElectrons(canvas, path);
    }
  }

  void _drawDisconnectedJumper(Canvas canvas, Offset start, Offset brokenEnd, Color color) {
    final path = Path()..moveTo(start.dx, start.dy)..quadraticBezierTo(start.dx + 10, start.dy + 2, brokenEnd.dx, brokenEnd.dy);
    canvas.drawPath(path, Paint()..color = color.withValues(alpha: 0.7)..strokeWidth = 2.8..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    canvas.drawCircle(brokenEnd, 3.0, Paint()..color = Colors.amberAccent);
  }

  void _drawFlowingElectrons(Canvas canvas, Path path) {
    const electronCount = 6;
    final glowPaint = Paint()..color = const Color(0xFFFDE047)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
    final corePaint = Paint()..color = const Color(0xFFFEF08A);

    for (final metric in path.computeMetrics()) {
      final length = metric.length;
      for (int i = 0; i < electronCount; i++) {
        final distance = ((animationValue + (i / electronCount)) % 1.0) * length;
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          canvas.drawCircle(tangent.position, 3.2, glowPaint);
          canvas.drawCircle(tangent.position, 1.6, corePaint);
        }
      }
    }
  }

  // =========================================================================
  // MODO ESQUEMÁTICO (SÍMBOLOS IEEE / IEC)
  // =========================================================================

  void _paintSchematicWorkbench(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final activeLinePaint = Paint()
      ..color = (isClosed && !isFaulty) ? const Color(0xFF10B981) : const Color(0xFF0F172A)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final cx = w * 0.50;
    final cy = h * 0.50;
    final loopW = w * 0.55;
    final loopH = h * 0.50;

    final leftX = cx - loopW / 2;
    final rightX = cx + loopW / 2;
    final topY = cy - loopH / 2;
    final botY = cy + loopH / 2;

    // Ramo da Bateria 9V (Esquerda)
    canvas.drawLine(Offset(leftX, topY), Offset(leftX, cy - 20), activeLinePaint);
    canvas.drawLine(Offset(leftX, cy + 20), Offset(leftX, botY), activeLinePaint);
    _drawSchematicBattery(canvas, Offset(leftX, cy), '9V');

    // Ramo Superior com Chave / Controle
    canvas.drawLine(Offset(leftX, topY), Offset(cx - 30, topY), activeLinePaint);
    canvas.drawLine(Offset(cx + 30, topY), Offset(rightX, topY), activeLinePaint);
    _drawSchematicSwitch(canvas, Offset(cx, topY), isOpen: !isClosed);

    // Ramo Direito com Motor CC (M)
    canvas.drawLine(Offset(rightX, topY), Offset(rightX, cy - 25), activeLinePaint);
    canvas.drawLine(Offset(rightX, cy + 25), Offset(rightX, botY), activeLinePaint);
    _drawSchematicMotor(canvas, Offset(rightX, cy));

    // Ramo Inferior de Retorno (GND)
    canvas.drawLine(Offset(rightX, botY), Offset(leftX, botY), activeLinePaint);

    // Título do Diagrama
    final tp = TextPainter(
      text: TextSpan(
        text: 'DIAGRAMA ESQUEMÁTICO — CONTROLE DE MOTOR CC (M)',
        style: GoogleFonts.rajdhani(color: const Color(0xFF334155), fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 2.0),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - 10));
  }

  void _drawSchematicBattery(Canvas canvas, Offset pos, String label) {
    final p = Paint()..color = const Color(0xFF0F172A)..strokeWidth = 3.0;
    canvas.drawLine(Offset(pos.dx - 16, pos.dy - 6), Offset(pos.dx + 16, pos.dy - 6), p);
    canvas.drawLine(Offset(pos.dx - 9, pos.dy + 6), Offset(pos.dx + 9, pos.dy + 6), p);

    final tp = TextPainter(
      text: TextSpan(text: label, style: GoogleFonts.rajdhani(color: const Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 12)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - 26 - tp.width, pos.dy - tp.height / 2));
  }

  void _drawSchematicSwitch(Canvas canvas, Offset pos, {required bool isOpen}) {
    final p = Paint()..color = const Color(0xFF0F172A)..strokeWidth = 2.5;
    canvas.drawCircle(Offset(pos.dx - 18, pos.dy), 3.0, p);
    canvas.drawCircle(Offset(pos.dx + 18, pos.dy), 3.0, p);
    final leverEnd = isOpen ? Offset(pos.dx + 12, pos.dy - 14) : Offset(pos.dx + 18, pos.dy);
    canvas.drawLine(Offset(pos.dx - 18, pos.dy), leverEnd, p..strokeCap = StrokeCap.round);
  }

  void _drawSchematicMotor(Canvas canvas, Offset pos) {
    final p = Paint()..color = (isClosed && !isFaulty) ? const Color(0xFF10B981) : const Color(0xFF0F172A)..strokeWidth = 2.5..style = PaintingStyle.stroke;
    canvas.drawCircle(pos, 22.0, p);

    final tp = TextPainter(
      text: TextSpan(text: 'M', style: GoogleFonts.rajdhani(color: (isClosed && !isFaulty) ? const Color(0xFF10B981) : const Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));

    // Seta de Sentido
    final arrowPaint = Paint()..color = const Color(0xFF0284C7)..strokeWidth = 1.8..style = PaintingStyle.stroke;
    canvas.drawArc(Rect.fromCircle(center: pos, radius: 28), isReversed ? math.pi * 0.8 : -math.pi * 0.2, math.pi * 0.7, false, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant MovimentoMiniaturaBreadboardPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.usePhysicalStyle != usePhysicalStyle ||
        oldDelegate.isClosed != isClosed ||
        oldDelegate.isReversed != isReversed ||
        oldDelegate.hasMotor != hasMotor ||
        oldDelegate.showPushButton != showPushButton ||
        oldDelegate.isPushButtonPressed != isPushButtonPressed ||
        oldDelegate.showTransistor != showTransistor ||
        oldDelegate.isTransistorTriggered != isTransistorTriggered ||
        oldDelegate.showHBridge != showHBridge ||
        oldDelegate.hBridgeDirection != hBridgeDirection ||
        oldDelegate.hasIndicatorLed != hasIndicatorLed ||
        oldDelegate.isFaulty != isFaulty ||
        oldDelegate.faultType != faultType;
  }
}
