import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/first_step_component.dart';
import 'burned_effects_painter.dart';

/// Renderizador CustomPainter dos componentes em seu aspecto hiper-realista (3D Vetorial)
/// ajustados proporcionalmente para preencher a célula do grid.
class ComponentPhysicalPainter extends CustomPainter {
  ComponentPhysicalPainter({
    required this.type,
    this.isActive = false,
    this.isBurned = false,
    required this.isDarkMode,
    this.value = 10.0,
    this.animationValue = 0.0,
  });

  final ComponentType type;
  final bool isActive;
  final bool isBurned;
  final bool isDarkMode;
  final double value;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    switch (type) {
      case ComponentType.battery:
        _drawPhysicalBattery(canvas, size, cx, cy);
        break;
      case ComponentType.connectingWire:
        _drawPhysicalWire(canvas, size, cx, cy);
        break;
      case ComponentType.switchComponent:
        _drawPhysicalSwitch(canvas, size, cx, cy);
        break;
      case ComponentType.bulb:
        _drawPhysicalBulb(canvas, size, cx, cy);
        break;
      case ComponentType.resistor:
        _drawPhysicalResistor(canvas, size, cx, cy);
        break;
      case ComponentType.diode:
        _drawPhysicalDiode(canvas, size, cx, cy);
        break;
      case ComponentType.led:
        _drawPhysicalLED(canvas, size, cx, cy);
        break;
      case ComponentType.motor:
        _drawPhysicalMotor(canvas, size, cx, cy);
        break;
      case ComponentType.potentiometer:
        _drawPhysicalPotentiometer(canvas, size, cx, cy);
        break;
      case ComponentType.powerSupply:
        _drawPhysicalPowerSupply(canvas, size, cx, cy);
        break;
      case ComponentType.fuse:
        _drawPhysicalFuse(canvas, size, cx, cy);
        break;
      case ComponentType.capacitor:
        _drawPhysicalCapacitor(canvas, size, cx, cy);
        break;
      case ComponentType.buzzer:
        _drawPhysicalBuzzer(canvas, size, cx, cy);
        break;
    }

    if (isBurned) {
      drawBurnedSmokeAndEmbers(
        canvas,
        size,
        cx,
        cy,
        animationValue,
        isDark: isDarkMode,
      );
    }
  }

  /// Desenha as hastes metálicas estanhadas de bancada com textura 3D e ponto de solda
  void _drawCleanLeads(Canvas canvas, Size size, double cx, double cy, double leftEdgeX, double rightEdgeX) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

    final leadBasePaint = Paint()
      ..shader = LinearGradient(
        colors: isDarkMode
            ? const [Color(0xFFCBD5E1), Color(0xFF64748B), Color(0xFF1E293B)]
            : const [Color(0xFFFFFFFF), Color(0xFFB0BEC5), Color(0xFF455A64)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, cy - 2, size.width, 4))
      ..strokeWidth = 3.6
      ..strokeCap = StrokeCap.round;

    final leadHighlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    if (leftEdgeX > 0) {
      canvas.drawLine(Offset(0, cy + 2.0), Offset(leftEdgeX, cy + 2.0), shadowPaint);
      canvas.drawLine(Offset(0, cy), Offset(leftEdgeX, cy), leadBasePaint);
      canvas.drawLine(Offset(0, cy - 1.0), Offset(leftEdgeX, cy - 1.0), leadHighlightPaint);

      // Ponto de solda na junção
      _drawSolderBlob(canvas, Offset(leftEdgeX, cy));
    }

    if (rightEdgeX < size.width) {
      canvas.drawLine(Offset(rightEdgeX, cy + 2.0), Offset(size.width, cy + 2.0), shadowPaint);
      canvas.drawLine(Offset(rightEdgeX, cy), Offset(size.width, cy), leadBasePaint);
      canvas.drawLine(Offset(rightEdgeX, cy - 1.0), Offset(size.width, cy - 1.0), leadHighlightPaint);

      // Ponto de solda na junção
      _drawSolderBlob(canvas, Offset(rightEdgeX, cy));
    }
  }

  /// Desenha uma gota de solda estaño-chumbo 3D
  void _drawSolderBlob(Canvas canvas, Offset pos) {
    final blobPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.4, -0.4),
        colors: const [Color(0xFFFFFFFF), Color(0xFFCFD8DC), Color(0xFF546E7A)],
      ).createShader(Rect.fromCircle(center: pos, radius: 3.5));
    canvas.drawCircle(pos, 3.2, blobPaint);
  }

  /// --------------------------------------------------------------------------
  /// BATERIA ALCALINA INDUSTRIAL 9V (Hiper-realista 3D - Expandida)
  /// --------------------------------------------------------------------------
  void _drawPhysicalBattery(Canvas canvas, Size size, double cx, double cy) {
    const batWidth = 60.0;
    const batHeight = 52.0;
    final batRect = Rect.fromCenter(center: Offset(cx, cy), width: batWidth, height: batHeight);
    final batRRect = RRect.fromRectAndRadius(batRect, const Radius.circular(8.0));

    _drawCleanLeads(canvas, size, cx, cy, batRect.left - 4, batRect.right + 4);

    // Sombra projetada sob o corpo 3D
    canvas.drawRRect(
      RRect.fromRectAndRadius(batRect.translate(3.0, 5.0), const Radius.circular(8.0)),
      Paint()..color = Colors.black.withValues(alpha: 0.45)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // 1. Corpo principal metálico escuro (Navy/Black)
    final bodyShader = const LinearGradient(
      colors: [Color(0xFF334155), Color(0xFF1E293B), Color(0xFF0F172A)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(batRect);
    canvas.drawRRect(batRRect, Paint()..shader = bodyShader);

    // 2. Tarja metálica de Cobre/Dourado estilo Duracell/Industrial no topo
    final copperRect = Rect.fromLTWH(batRect.left, batRect.top, batWidth, 20);
    final copperShader = const LinearGradient(
      colors: [Color(0xFFFFB74D), Color(0xFFF57C00), Color(0xFFE65100), Color(0xFFBF360C)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(copperRect);
    
    canvas.save();
    canvas.clipRRect(batRRect);
    canvas.drawRect(copperRect, Paint()..shader = copperShader);

    // Destaque especular na tarja de cobre
    canvas.drawLine(
      Offset(copperRect.left, copperRect.top + 1.5),
      Offset(copperRect.right, copperRect.top + 1.5),
      Paint()..color = Colors.white.withValues(alpha: 0.75)..strokeWidth = 1.4,
    );

    // Linha de vinco/rebarba de dobra de alumínio
    canvas.drawLine(
      Offset(copperRect.left, copperRect.bottom),
      Offset(copperRect.right, copperRect.bottom),
      Paint()..color = const Color(0xFF263238)..strokeWidth = 1.5,
    );
    canvas.restore();

    // 3. Moldura de borda chanfrada
    canvas.drawRRect(
      batRRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.15)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke,
    );

    // 4. Micro-tipografia de tensão "9V ALKALINE"
    final voltStr = value > 0 ? '${value.toStringAsFixed(value % 1 == 0 ? 0 : 1)}V' : '9V';
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$voltStr ALKALINE',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(cx - textPainter.width / 2, copperRect.top + 4.5));

    // 5. Terminais Snap metálicos 3D no topo (+ e -)
    final snapLeft = Offset(cx - 15.0, batRect.top - 4.0);
    final snapRight = Offset(cx + 15.0, batRect.top - 5.0);

    // Polo Negativo (-) - Soquete Sextavado prateado
    canvas.drawCircle(snapLeft, 5.5, Paint()..color = const Color(0xFF78909C));
    canvas.drawCircle(snapLeft, 3.2, Paint()..color = const Color(0xFF1E293B));

    // Polo Positivo (+) - Conector Coroa de Latão Dourado 3D
    canvas.drawCircle(snapRight, 6.5, Paint()..color = const Color(0xFFFFD54F));
    canvas.drawCircle(snapRight, 6.5, Paint()..color = const Color(0xFFFFB300)..style = PaintingStyle.stroke..strokeWidth = 1.2);
    canvas.drawCircle(snapRight, 3.6, Paint()..color = const Color(0xFFE65100));

    // 6. Fios de saída isolados conectando o topo das snap ao circuito
    final wireNegPath = Path()
      ..moveTo(snapLeft.dx, snapLeft.dy)
      ..cubicTo(snapLeft.dx - 10, snapLeft.dy - 4, batRect.left - 2, cy - 8, batRect.left - 4, cy);
    final wirePosPath = Path()
      ..moveTo(snapRight.dx, snapRight.dy)
      ..cubicTo(snapRight.dx + 10, snapRight.dy - 4, batRect.right + 2, cy - 8, batRect.right + 4, cy);

    canvas.drawPath(
      wireNegPath,
      Paint()
        ..color = isDarkMode ? const Color(0xFF64748B) : const Color(0xFF1E293B)
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawPath(
      wirePosPath,
      Paint()
        ..color = const Color(0xFFD32F2F)
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Marcação - e +
    TextPainter(text: const TextSpan(text: '-', style: TextStyle(color: Color(0xFF90A4AE), fontSize: 11, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr)
      ..layout()
      ..paint(canvas, Offset(batRect.left + 5, batRect.top + 22));

    TextPainter(text: const TextSpan(text: '+', style: TextStyle(color: Color(0xFFFF7043), fontSize: 11, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr)
      ..layout()
      ..paint(canvas, Offset(batRect.right - 12, batRect.top + 22));
  }

  void _drawPhysicalWire(Canvas canvas, Size size, double cx, double cy) {
    _drawCleanLeads(canvas, size, cx, cy, 0, size.width);
  }

  /// --------------------------------------------------------------------------
  /// CHAVE FACA DIDÁTICA DE LABORATÓRIO (Knife Switch 3D - Expandida)
  /// --------------------------------------------------------------------------
  void _drawPhysicalSwitch(Canvas canvas, Size size, double cx, double cy) {
    final pPivot = Offset(cx - 30, cy);
    final pContact = Offset(cx + 30, cy);
    final pLeverEnd = isActive
        ? pContact
        : Offset(cx + 4, cy - 34);

    _drawCleanLeads(canvas, size, cx, cy, pPivot.dx, pContact.dx);

    // Placa isolante de baquelite preta com bevel
    final basePlate = Rect.fromCenter(center: Offset(cx, cy + 3), width: 74, height: 16);
    canvas.drawRRect(
      RRect.fromRectAndRadius(basePlate.translate(2, 3), const Radius.circular(4)),
      Paint()..color = Colors.black.withValues(alpha: 0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    final baseShader = LinearGradient(
      colors: isDarkMode ? const [Color(0xFF334155), Color(0xFF1E293B)] : const [Color(0xFF475569), Color(0xFF1E293B)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(basePlate);
    canvas.drawRRect(RRect.fromRectAndRadius(basePlate, const Radius.circular(4)), Paint()..shader = baseShader);

    // Parafusos e Bornes de latão 3D nos polos
    _drawBrassTerminalPost(canvas, pPivot);
    _drawBrassTerminalPost(canvas, pContact);

    // Garra de encaixe em U no terminal de contato
    final jawPath = Path()
      ..moveTo(pContact.dx - 4, pContact.dy - 8)
      ..lineTo(pContact.dx - 4, pContact.dy + 4)
      ..lineTo(pContact.dx + 4, pContact.dy + 4)
      ..lineTo(pContact.dx + 4, pContact.dy - 8);
    canvas.drawPath(
      jawPath,
      Paint()
        ..color = const Color(0xFFFFD54F)
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke,
    );

    // Faísca / Glow no contato quando fechado
    if (isActive) {
      canvas.drawCircle(
        pContact,
        9.0,
        Paint()
          ..color = const Color(0xFF00FF9D).withValues(alpha: 0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      canvas.drawCircle(pContact, 3.5, Paint()..color = Colors.white);
    }

    // Sombra projetada sob a lâmina metálica
    canvas.drawLine(
      pPivot.translate(2.5, 4.5),
      pLeverEnd.translate(2.5, 4.5),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.45)
        ..strokeWidth = 6.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)
        ..strokeCap = StrokeCap.round,
    );

    // Lâmina articulada de Cobre/Latão polido
    final leverPaint = Paint()
      ..shader = LinearGradient(
        colors: const [Color(0xFFFFD54F), Color(0xFFFFB300), Color(0xFFE65100), Color(0xFFBF360C)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromPoints(pPivot, pLeverEnd))
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(pPivot, pLeverEnd, leverPaint);

    // Brilho especular na lâmina metálica
    canvas.drawLine(
      pPivot.translate(0, -1.2),
      pLeverEnd.translate(0, -1.2),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.8)
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round,
    );

    // Manopla isolante cilíndrica na ponta
    final handleColor = isActive ? const Color(0xFF00E676) : const Color(0xFFD32F2F);
    canvas.drawCircle(pLeverEnd, 8.5, Paint()..color = handleColor);
    canvas.drawCircle(
      Offset(pLeverEnd.dx - 2.5, pLeverEnd.dy - 2.5),
      2.8,
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );
  }

  /// Desenha um borne de parafuso de latão 3D
  void _drawBrassTerminalPost(Canvas canvas, Offset center) {
    canvas.drawCircle(center, 5.8, Paint()..color = const Color(0xFFFFD54F));
    canvas.drawCircle(center, 5.8, Paint()..color = const Color(0xFFB45309)..style = PaintingStyle.stroke..strokeWidth = 1.0);
    // Ranhura do parafuso de fenda
    canvas.drawLine(Offset(center.dx - 3.0, center.dy), Offset(center.dx + 3.0, center.dy), Paint()..color = const Color(0xFF78350F)..strokeWidth = 1.4);
  }

  /// --------------------------------------------------------------------------
  /// LÂMPADA INCANDESCENTE E10 DE LABORATÓRIO (Bulb 3D - Expandida)
  /// --------------------------------------------------------------------------
  void _drawPhysicalBulb(Canvas canvas, Size size, double cx, double cy) {
    final socketCenter = Offset(cx, cy + 6);
    final socketRect = Rect.fromCenter(center: socketCenter, width: 32, height: 22);
    final bulbCenter = Offset(cx, cy - 20);
    const bulbRadius = 22.0;

    _drawCleanLeads(canvas, size, cx, cy, socketRect.left, socketRect.right);

    // 1. Soquete roscado de latão/alumínio E10
    canvas.drawRRect(
      RRect.fromRectAndRadius(socketRect.translate(2, 3), const Radius.circular(4)),
      Paint()..color = Colors.black.withValues(alpha: 0.35)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );

    final socketShader = const LinearGradient(
      colors: [Color(0xFFFFD54F), Color(0xFFFFB300), Color(0xFFB45309), Color(0xFF78350F)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(socketRect);
    canvas.drawRRect(RRect.fromRectAndRadius(socketRect, const Radius.circular(4)), Paint()..shader = socketShader);

    // Roscas espirais de contato metálico
    final threadPaint = Paint()
      ..color = const Color(0xFF78350F)
      ..strokeWidth = 1.6;
    canvas.drawLine(Offset(socketRect.left + 3, socketRect.top + 6), Offset(socketRect.right - 3, socketRect.top + 6), threadPaint);
    canvas.drawLine(Offset(socketRect.left + 3, socketRect.top + 13), Offset(socketRect.right - 3, socketRect.top + 13), threadPaint);

    // Ponto de solda metálico na base inferior do soquete
    canvas.drawCircle(Offset(cx, socketRect.bottom + 1.5), 3.5, Paint()..color = const Color(0xFF90A4AE));

    // 2. Glow estendido fotorrealista quando aceso
    if (isActive) {
      canvas.drawCircle(
        bulbCenter,
        bulbRadius + 42,
        Paint()
          ..color = const Color(0xFFFFD54F).withValues(alpha: 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
      );
      canvas.drawCircle(
        bulbCenter,
        bulbRadius + 22,
        Paint()
          ..color = const Color(0xFFFF9100).withValues(alpha: 0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
    }

    // Sombra sob o domo de vidro
    canvas.drawCircle(
      bulbCenter.translate(3, 4),
      bulbRadius,
      Paint()..color = Colors.black.withValues(alpha: 0.25)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // 3. Bulbo de vidro soprados com iluminação esférica 3D
    final glassPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.4, -0.45),
        radius: 0.85,
        colors: isActive
            ? const [Color(0xFFFFFFFF), Color(0xFFFFF59D), Color(0xFFFFB300)]
            : (isDarkMode
                ? const [Color(0x40FFFFFF), Color(0x1AFFFFFF), Color(0x00FFFFFF)]
                : const [Color(0xFFFFFFFF), Color(0xFFECEFF1), Color(0xFFB0BEC5)]),
      ).createShader(Rect.fromCircle(center: bulbCenter, radius: bulbRadius));
    canvas.drawCircle(bulbCenter, bulbRadius, glassPaint);

    // Borda reflexiva do vidro
    final glassBorder = Paint()
      ..color = isActive ? Colors.amber.withValues(alpha: 0.8) : Colors.blueGrey.shade200
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(bulbCenter, bulbRadius, glassBorder);

    // Brilhos especulares duplos no vidro
    canvas.drawCircle(
      Offset(bulbCenter.dx - 7.0, bulbCenter.dy - 7.5),
      5.5,
      Paint()..color = Colors.white.withValues(alpha: isActive ? 0.95 : 0.7),
    );
    canvas.drawCircle(
      Offset(bulbCenter.dx + 8.0, bulbCenter.dy + 8.0),
      2.5,
      Paint()..color = Colors.white.withValues(alpha: 0.4),
    );

    // 4. Hastes internas de suporte de níquel e Filamento de Tungstênio em V
    final supportPaint = Paint()
      ..color = isActive ? const Color(0xFFFF3D00) : const Color(0xFF546E7A)
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(cx - 6, cy - 6), Offset(cx - 4, cy - 20), supportPaint);
    canvas.drawLine(Offset(cx + 6, cy - 6), Offset(cx + 4, cy - 20), supportPaint);

    final filPath = Path()
      ..moveTo(cx - 4, cy - 20)
      ..lineTo(cx - 2, cy - 26)
      ..lineTo(cx, cy - 23)
      ..lineTo(cx + 2, cy - 26)
      ..lineTo(cx + 4, cy - 20);

    canvas.drawPath(
      filPath,
      Paint()
        ..color = isActive ? Colors.white : const Color(0xFF37474F)
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  /// --------------------------------------------------------------------------
  /// RESISTOR DE FILME DE CARBONO 1/4W (Dumbbell Ceramic Shape 3D - Expandido)
  /// --------------------------------------------------------------------------
  List<Color> _getResistorColors(double val) {
    if (val <= 0) val = 10.0;
    final int valInt = val.round();
    final String str = valInt.toString();
    int d1 = int.parse(str[0]);
    int d2 = str.length > 1 ? int.parse(str[1]) : 0;
    int zeros = str.length - 2;
    if (zeros < 0) zeros = 0;

    final colorMap = [
      const Color(0xFF212121), // 0 Preto
      const Color(0xFF6D4C41), // 1 Marrom
      const Color(0xFFE53935), // 2 Vermelho
      const Color(0xFFFB8C00), // 3 Laranja
      const Color(0xFFFFD600), // 4 Amarelo
      const Color(0xFF43A047), // 5 Verde
      const Color(0xFF1E88E5), // 6 Azul
      const Color(0xFF8E24AA), // 7 Violeta
      const Color(0xFF757575), // 8 Cinza
      const Color(0xFFFFFFFF), // 9 Branco
    ];

    final c1 = colorMap[d1.clamp(0, 9)];
    final c2 = colorMap[d2.clamp(0, 9)];
    final c3 = colorMap[zeros.clamp(0, 9)];
    const c4 = Color(0xFFFFD54F);

    return [c1, c2, c3, c4];
  }

  void _drawPhysicalResistor(Canvas canvas, Size size, double cx, double cy) {
    const resWidth = 64.0;
    const centerHeight = 19.0;
    const bulbHeight = 24.0;

    final resRect = Rect.fromCenter(center: Offset(cx, cy), width: resWidth, height: bulbHeight);

    _drawCleanLeads(canvas, size, cx, cy, resRect.left - 2, resRect.right + 2);

    // Sombra 3D
    canvas.drawRRect(
      RRect.fromRectAndRadius(resRect.translate(2.5, 4.5), const Radius.circular(8)),
      Paint()..color = Colors.black.withValues(alpha: 0.35)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // 1. Corpo Cerâmico abuloado em haltere
    final bodyPath = Path()
      ..moveTo(resRect.left, cy - bulbHeight / 2)
      ..arcToPoint(Offset(resRect.left + 9, cy - centerHeight / 2), radius: const Radius.circular(6))
      ..lineTo(resRect.right - 9, cy - centerHeight / 2)
      ..arcToPoint(Offset(resRect.right, cy - bulbHeight / 2), radius: const Radius.circular(6))
      ..lineTo(resRect.right, cy + bulbHeight / 2)
      ..arcToPoint(Offset(resRect.right - 9, cy + centerHeight / 2), radius: const Radius.circular(6))
      ..lineTo(resRect.left + 9, cy + centerHeight / 2)
      ..arcToPoint(Offset(resRect.left, cy + bulbHeight / 2), radius: const Radius.circular(6))
      ..close();

    final ceramicShader = const LinearGradient(
      colors: [Color(0xFFFFF8E1), Color(0xFFFFE0B2), Color(0xFFFFCC80), Color(0xFFD7CCC8)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(resRect);

    canvas.drawPath(bodyPath, Paint()..shader = ceramicShader);

    // 2. Faixas de cores dinâmicas
    final colors = _getResistorColors(value);
    final bandPositions = [-19.0, -7.5, 4.0, 17.5];
    for (var i = 0; i < colors.length; i++) {
      final h = (i == 0 || i == 3) ? bulbHeight : centerHeight;
      canvas.drawRect(
        Rect.fromLTWH(cx + bandPositions[i], cy - h / 2, 5.5, h),
        Paint()..color = colors[i],
      );
      if (i == 3) {
        canvas.drawRect(
          Rect.fromLTWH(cx + bandPositions[i] + 1.5, cy - h / 2, 1.5, h),
          Paint()..color = Colors.white.withValues(alpha: 0.7),
        );
      }
    }

    // 3. Brilho especular longitudinal
    canvas.drawLine(
      Offset(resRect.left + 4, cy - centerHeight / 2 + 1.8),
      Offset(resRect.right - 4, cy - centerHeight / 2 + 1.8),
      Paint()..color = Colors.white.withValues(alpha: 0.75)..strokeWidth = 1.8,
    );
  }

  /// --------------------------------------------------------------------------
  /// DIODO RETIFICADOR 1N4007 (Epoxy Package DO-41 - Expandido)
  /// --------------------------------------------------------------------------
  void _drawPhysicalDiode(Canvas canvas, Size size, double cx, double cy) {
    final diodeRect = Rect.fromCenter(center: Offset(cx, cy), width: 62, height: 22);
    final diodeRRect = RRect.fromRectAndRadius(diodeRect, const Radius.circular(6.0));

    _drawCleanLeads(canvas, size, cx, cy, diodeRect.left - 2, diodeRect.right + 2);

    canvas.drawRRect(
      RRect.fromRectAndRadius(diodeRect.translate(2.5, 4.0), const Radius.circular(6.0)),
      Paint()..color = Colors.black.withValues(alpha: 0.35)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Corpo de Epóxi Preto fosco usinado
    final bodyShader = const LinearGradient(
      colors: [Color(0xFF424242), Color(0xFF212121), Color(0xFF000000)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(diodeRect);
    canvas.drawRRect(diodeRRect, Paint()..shader = bodyShader);

    // Anel prateado de Cátodo
    canvas.drawRect(
      Rect.fromLTWH(diodeRect.left + 9, diodeRect.top, 7.5, 22),
      Paint()..color = const Color(0xFFCFD8DC),
    );

    // Micro-gravação do código "1N4007"
    TextPainter(
      text: const TextSpan(
        text: '1N4007',
        style: TextStyle(color: Color(0xFF90A4AE), fontSize: 8.5, fontWeight: FontWeight.bold, letterSpacing: 0.8),
      ),
      textDirection: TextDirection.ltr,
    )
      ..layout()
      ..paint(canvas, Offset(cx - 3, cy - 4.5));

    // Highlight especular
    canvas.drawLine(
      Offset(diodeRect.left + 3, diodeRect.top + 1.8),
      Offset(diodeRect.right - 3, diodeRect.top + 1.8),
      Paint()..color = Colors.white.withValues(alpha: 0.45)..strokeWidth = 1.4,
    );
  }

  /// --------------------------------------------------------------------------
  /// DIODO EMISSOR DE LUZ - LED 5mm 3D (Expandido)
  /// --------------------------------------------------------------------------
  void _drawPhysicalLED(Canvas canvas, Size size, double cx, double cy) {
    final domeCenter = Offset(cx, cy - 6);
    const ledRadius = 22.0;

    _drawCleanLeads(canvas, size, cx, cy, domeCenter.dx - ledRadius - 2, domeCenter.dx + ledRadius + 2);

    // Glow fotônico neon expandido quando energizado
    if (isActive) {
      canvas.drawCircle(
        domeCenter,
        ledRadius + 36,
        Paint()
          ..color = const Color(0xFF00FF9D).withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
      );
      canvas.drawCircle(
        domeCenter,
        ledRadius + 18,
        Paint()
          ..color = const Color(0xFF00E676).withValues(alpha: 0.75)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );

      final rayPaint = Paint()
        ..color = const Color(0xFF00FF9D).withValues(alpha: 0.9)
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(cx - 22, domeCenter.dy - 18), Offset(cx - 32, domeCenter.dy - 28), rayPaint);
      canvas.drawLine(Offset(cx + 22, domeCenter.dy - 18), Offset(cx + 32, domeCenter.dy - 28), rayPaint);
      canvas.drawLine(Offset(cx, domeCenter.dy - 26), Offset(cx, domeCenter.dy - 38), rayPaint);
    }

    // Armação metálica interna visível
    final leadFramePaint = Paint()
      ..color = Colors.blueGrey.shade300.withValues(alpha: 0.9)
      ..strokeWidth = 2.8;
    canvas.drawLine(Offset(cx - 6.0, domeCenter.dy + 10), Offset(cx - 6.0, domeCenter.dy - 3), leadFramePaint);
    canvas.drawLine(Offset(cx + 6.0, domeCenter.dy + 10), Offset(cx + 6.0, domeCenter.dy - 6), leadFramePaint);

    // Taça metálica do Cátodo
    final anvilPath = Path()
      ..moveTo(cx - 10.0, domeCenter.dy - 3)
      ..lineTo(cx - 2.0, domeCenter.dy - 3)
      ..lineTo(cx - 4.0, domeCenter.dy - 9)
      ..close();
    canvas.drawPath(anvilPath, Paint()..color = Colors.blueGrey.shade100);

    // Domo esférico de resina epóxi
    final domeShader = RadialGradient(
      center: const Alignment(-0.35, -0.4),
      radius: 0.85,
      colors: isActive
          ? const [Color(0xFFE8F5E9), Color(0xFF00E676), Color(0xFF00C853), Color(0xFF1B5E20)]
          : const [Color(0xFFA5D6A7), Color(0xFF4CAF50), Color(0xFF1B5E20)],
    ).createShader(Rect.fromCircle(center: domeCenter, radius: ledRadius));

    canvas.drawCircle(domeCenter, ledRadius, Paint()..shader = domeShader);

    // Colarinho/Anel de retenção de resina na base
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - ledRadius - 1.5, domeCenter.dy + 9, (ledRadius + 1.5) * 2, 5),
        const Radius.circular(2.0),
      ),
      Paint()..color = isActive ? const Color(0xFF2E7D32) : const Color(0xFF1B5E20),
    );

    // Brilho especular curvo de lente de resina epóxi
    final glassHighlightPath = Path()
      ..addArc(
        Rect.fromCircle(center: Offset(cx - 5.0, domeCenter.dy - 5.0), radius: ledRadius * 0.65),
        -math.pi * 0.8,
        math.pi * 0.5,
      );
    canvas.drawPath(
      glassHighlightPath,
      Paint()
        ..color = Colors.white.withValues(alpha: isActive ? 0.95 : 0.75)
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  /// --------------------------------------------------------------------------
  /// MOTOR CC CILÍNDRICO 130 DE LABORATÓRIO (Expandido)
  /// --------------------------------------------------------------------------
  void _drawPhysicalMotor(Canvas canvas, Size size, double cx, double cy) {
    final motorCenter = Offset(cx - 8, cy);
    final motorRect = Rect.fromCenter(center: motorCenter, width: 54, height: 34);

    _drawCleanLeads(canvas, size, cx, cy, motorRect.left - 8, cx + 36);

    // Sombra do corpo cilíndrico
    canvas.drawRRect(
      RRect.fromRectAndRadius(motorRect.translate(3, 5), const Radius.circular(7.0)),
      Paint()..color = Colors.black.withValues(alpha: 0.35)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Tampa traseira de plástico preta
    final capBackRect = Rect.fromLTWH(motorRect.left - 7, cy - 13, 8, 26);
    canvas.drawRRect(RRect.fromRectAndRadius(capBackRect, const Radius.circular(3)), Paint()..color = const Color(0xFF1E293B));

    // Corpo metálico cilíndrico de aço escovado
    final motorGradient = Paint()
      ..shader = LinearGradient(
        colors: isActive
            ? const [Color(0xFFFFFFFF), Color(0xFFCBD5E1), Color(0xFF64748B), Color(0xFF334155)]
            : const [Color(0xFFE2E8F0), Color(0xFF94A3B8), Color(0xFF475569)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(motorRect);

    canvas.drawRRect(RRect.fromRectAndRadius(motorRect, const Radius.circular(7.0)), motorGradient);

    // Fresta de ventilação lateral
    final ventSlot = Rect.fromLTWH(cx - 12, cy - 8, 14, 11);
    canvas.drawRRect(RRect.fromRectAndRadius(ventSlot, const Radius.circular(2.0)), Paint()..color = const Color(0xFF0F172A));
    canvas.drawRect(Rect.fromLTWH(cx - 9, cy - 6, 8, 7), Paint()..color = const Color(0xFFD97706));

    // Eixo rotativo de Aço Inox
    final shaftPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.white, Color(0xFFCBD5E1), Color(0xFF64748B)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(motorRect.right, cy - 3, 12, 6))
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(motorRect.right, cy), Offset(motorRect.right + 11, cy), shaftPaint);

    // Hélice / Rotor 3D
    final discCenter = Offset(motorRect.right + 11, cy);
    const fanRadius = 19.0;

    canvas.drawCircle(discCenter, fanRadius, Paint()..color = isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9));
    canvas.drawCircle(
      discCenter,
      fanRadius,
      Paint()
        ..color = const Color(0xFF00F5D4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    final angle = isActive ? (DateTime.now().millisecondsSinceEpoch / 20) % (2 * math.pi) : 0.0;

    for (int i = 0; i < 4; i++) {
      final bladeAngle = angle + (i * math.pi / 2);
      final pEnd = Offset(
        discCenter.dx + (fanRadius - 1.5) * math.cos(bladeAngle),
        discCenter.dy + (fanRadius - 1.5) * math.sin(bladeAngle),
      );

      final bladePath = Path()
        ..moveTo(discCenter.dx, discCenter.dy)
        ..quadraticBezierTo(
          discCenter.dx + (fanRadius * 0.6) * math.cos(bladeAngle + 0.3),
          discCenter.dy + (fanRadius * 0.6) * math.sin(bladeAngle + 0.3),
          pEnd.dx,
          pEnd.dy,
        );

      canvas.drawPath(
        bladePath,
        Paint()
          ..color = isActive ? const Color(0xFF00F5D4) : (isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF334155))
          ..strokeWidth = 4.8
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.drawCircle(discCenter, 4.5, Paint()..color = const Color(0xFFD97706));
    canvas.drawCircle(discCenter, 1.8, Paint()..color = Colors.black);
  }

  /// --------------------------------------------------------------------------
  /// POTENCIÔMETRO ROTATIVO 10k 3D (Expandido)
  /// --------------------------------------------------------------------------
  void _drawPhysicalPotentiometer(Canvas canvas, Size size, double cx, double cy) {
    final knobCenter = Offset(cx, cy);
    const knobRadius = 25.0;

    _drawCleanLeads(canvas, size, cx, cy, cx - knobRadius - 2, cx + knobRadius + 2);

    canvas.drawCircle(
      knobCenter.translate(3, 4),
      knobRadius,
      Paint()..color = Colors.black.withValues(alpha: 0.35)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Corpo metálico de Zinco
    canvas.drawCircle(
      knobCenter,
      knobRadius,
      Paint()
        ..shader = RadialGradient(
          colors: const [Color(0xFFF5F5F5), Color(0xFFBDBDBD), Color(0xFF616161), Color(0xFF212121)],
        ).createShader(Rect.fromCircle(center: knobCenter, radius: knobRadius)),
    );

    // Eixo rotativo de alumínio com entalhe indicador
    const angle = -math.pi / 4;
    final indX = knobCenter.dx + (knobRadius - 5.0) * math.cos(angle);
    final indY = knobCenter.dy + (knobRadius - 5.0) * math.sin(angle);
    canvas.drawLine(
      knobCenter,
      Offset(indX, indY),
      Paint()..color = const Color(0xFF00F5D4)..strokeWidth = 3.8..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(knobCenter, 5.0, Paint()..color = const Color(0xFF212121));
  }

  /// --------------------------------------------------------------------------
  /// FONTE DE ALIMENTAÇÃO DE BANCADA (Power Supply 3D - Expandida)
  /// --------------------------------------------------------------------------
  void _drawPhysicalPowerSupply(Canvas canvas, Size size, double cx, double cy) {
    final bodyRect = Rect.fromCenter(center: Offset(cx, cy), width: size.width * 0.90, height: size.height * 0.82);
    final rr = RRect.fromRectAndRadius(bodyRect, const Radius.circular(10));

    _drawCleanLeads(canvas, size, cx, cy, bodyRect.left, bodyRect.right);

    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect.translate(3, 5), const Radius.circular(10)),
      Paint()..color = Colors.black.withValues(alpha: 0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    canvas.drawRRect(
      rr,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF334155), Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(bodyRect),
    );

    canvas.drawRRect(rr, Paint()..color = const Color(0xFF00F5D4).withValues(alpha: 0.7)..strokeWidth = 1.8..style = PaintingStyle.stroke);

    // Display LCD Digital
    final lcdRect = Rect.fromCenter(center: Offset(cx, cy - 8), width: 68, height: 28);
    canvas.drawRRect(RRect.fromRectAndRadius(lcdRect, const Radius.circular(5)), Paint()..color = const Color(0xFF022C22));
    
    final voltStr = value > 0 ? '${value.toStringAsFixed(1)}V' : '12.0V';
    final textPainter = TextPainter(
      text: TextSpan(
        text: voltStr,
        style: const TextStyle(
          color: Color(0xFF00FF9D),
          fontSize: 15,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(cx - textPainter.width / 2, cy - 17));
  }

  /// --------------------------------------------------------------------------
  /// FUSÍVEL DE VIDRO 5x20mm (Cartridge Fuse 3D - Expandido)
  /// --------------------------------------------------------------------------
  void _drawPhysicalFuse(Canvas canvas, Size size, double cx, double cy) {
    final tubeRect = Rect.fromCenter(center: Offset(cx, cy), width: 62, height: 20);

    _drawCleanLeads(canvas, size, cx, cy, tubeRect.left - 2, tubeRect.right + 2);

    // Corpo de Vidro Transparente
    canvas.drawRRect(
      RRect.fromRectAndRadius(tubeRect, const Radius.circular(5)),
      Paint()..color = isDarkMode ? Colors.white24 : const Color(0x66E0F7FA),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tubeRect, const Radius.circular(5)),
      Paint()..color = Colors.cyan.withValues(alpha: 0.6)..strokeWidth = 1.5..style = PaintingStyle.stroke,
    );

    // Terminais metálicos niquelados
    final capLeft = Rect.fromLTWH(tubeRect.left, tubeRect.top, 13, 20);
    final capRight = Rect.fromLTWH(tubeRect.right - 13, tubeRect.top, 13, 20);
    final metalPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.white, Color(0xFFB0BEC5), Color(0xFF546E7A)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(capLeft);

    canvas.drawRect(capLeft, metalPaint);
    canvas.drawRect(capRight, metalPaint);

    // Elemento fusível interno
    if (!isBurned) {
      canvas.drawLine(
        Offset(tubeRect.left + 13, cy),
        Offset(tubeRect.right - 13, cy),
        Paint()..color = Colors.amber.shade400..strokeWidth = 2.2,
      );
    } else {
      canvas.drawLine(Offset(tubeRect.left + 13, cy), Offset(cx - 6, cy + 3.5), Paint()..color = Colors.black87..strokeWidth = 2.2);
      canvas.drawLine(Offset(cx + 6, cy - 3.5), Offset(tubeRect.right - 13, cy), Paint()..color = Colors.black87..strokeWidth = 2.2);
    }
  }

  /// --------------------------------------------------------------------------
  /// CAPACITOR ELETROLÍTICO DE ALUMÍNIO (Expandido)
  /// --------------------------------------------------------------------------
  void _drawPhysicalCapacitor(Canvas canvas, Size size, double cx, double cy) {
    final capRect = Rect.fromCenter(center: Offset(cx, cy), width: 36, height: 42);
    final rr = RRect.fromRectAndRadius(capRect, const Radius.circular(7.5));

    _drawCleanLeads(canvas, size, cx, cy, capRect.left - 2, capRect.right + 2);

    canvas.drawRRect(
      RRect.fromRectAndRadius(capRect.translate(2.5, 4.0), const Radius.circular(7.5)),
      Paint()..color = Colors.black.withValues(alpha: 0.35)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Casing cilíndrico com manga de PVC azul
    canvas.drawRRect(
      rr,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF1565C0), Color(0xFF0D47A1)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(capRect),
    );

    // Faixa branca de polaridade negativa (-)
    canvas.drawRect(
      Rect.fromLTWH(capRect.left + 3, capRect.top, 8.0, capRect.height),
      Paint()..color = const Color(0xFFECEFF1),
    );
    TextPainter(text: const TextSpan(text: '-', style: TextStyle(color: Color(0xFF0D47A1), fontSize: 13, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr)
      ..layout()
      ..paint(canvas, Offset(capRect.left + 4.5, capRect.top + 12));

    // Topo de alumínio com estamparia de ranhura de segurança
    canvas.drawRect(Rect.fromLTWH(capRect.left, capRect.top, capRect.width, 4.5), Paint()..color = const Color(0xFFCFD8DC));
  }

  /// --------------------------------------------------------------------------
  /// BUZZER PIEZOELÉTRICO ATIVO (Expandido)
  /// --------------------------------------------------------------------------
  void _drawPhysicalBuzzer(Canvas canvas, Size size, double cx, double cy) {
    final buzzCenter = Offset(cx, cy);
    const buzzRadius = 24.0;

    _drawCleanLeads(canvas, size, cx, cy, buzzCenter.dx - buzzRadius - 2, buzzCenter.dx + buzzRadius + 2);

    canvas.drawCircle(
      buzzCenter.translate(3, 4),
      buzzRadius,
      Paint()..color = Colors.black.withValues(alpha: 0.35)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Corpo de plástico Noryl preto
    canvas.drawCircle(
      buzzCenter,
      buzzRadius,
      Paint()
        ..shader = RadialGradient(
          colors: const [Color(0xFF37474F), Color(0xFF263238), Color(0xFF102A43)],
        ).createShader(Rect.fromCircle(center: buzzCenter, radius: buzzRadius)),
    );

    // Anel de borda de vedação
    canvas.drawCircle(buzzCenter, buzzRadius, Paint()..color = const Color(0xFF00F5D4).withValues(alpha: 0.5)..strokeWidth = 1.6..style = PaintingStyle.stroke);
    
    // Orifício de ressonância acústica central
    canvas.drawCircle(buzzCenter, 6.5, Paint()..color = Colors.black);

    // Ondas sonoras animadas quando ativo
    if (isActive) {
      final wavePaint = Paint()
        ..color = const Color(0xFF00F5D4).withValues(alpha: 0.85)
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke;
      canvas.drawArc(Rect.fromCircle(center: buzzCenter, radius: 31), -math.pi / 3, 2 * math.pi / 3, false, wavePaint);
      canvas.drawArc(Rect.fromCircle(center: buzzCenter, radius: 38), -math.pi / 3, 2 * math.pi / 3, false, wavePaint..color = const Color(0xFF00F5D4).withValues(alpha: 0.4));
    }
  }

  @override
  bool shouldRepaint(covariant ComponentPhysicalPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.isActive != isActive ||
        oldDelegate.isBurned != isBurned ||
        oldDelegate.isDarkMode != isDarkMode ||
        oldDelegate.value != value ||
        oldDelegate.animationValue != animationValue;
  }
}
