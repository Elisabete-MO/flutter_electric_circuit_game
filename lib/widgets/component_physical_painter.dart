import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/first_step_component.dart';
import 'burned_effects_painter.dart';

/// Renderizador CustomPainter dos componentes em seu aspecto físico/realista
/// inspirado nos itens da bancada de laboratório das imagens 1 e 2.
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

  void _drawPhysicalBattery(Canvas canvas, Size size, double cx, double cy) {
    // Corpo da bateria de 4.5V (estilo caixa retangular bege/preta clássica)
    final bodyWidth = size.width * 0.45;
    final bodyHeight = size.height * 0.55;
    final bodyRect = Rect.fromCenter(
      center: Offset(cx, cy + 6),
      width: bodyWidth,
      height: bodyHeight,
    );

    // Sombra projetada
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect.translate(3, 5), const Radius.circular(6)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Bloco principal com gradiente lateral (luz da esquerda)
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF3C3C3C), Color(0xFF222222), Color(0xFF141414)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bodyRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(6)),
      bodyPaint,
    );

    // Reflexo especular lateral esquerdo (borda de luz)
    canvas.drawLine(
      Offset(bodyRect.left + 1.5, bodyRect.top + 6),
      Offset(bodyRect.left + 1.5, bodyRect.bottom - 6),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.15)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Tarja dourada/laranja (pilha 4.5V plus)
    final stripeRect = Rect.fromLTWH(
      bodyRect.left,
      bodyRect.top + bodyHeight * 0.35,
      bodyWidth,
      bodyHeight * 0.3,
    );
    final stripePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
      ).createShader(stripeRect);
    canvas.drawRect(stripeRect, stripePaint);

    // Texto "4.5 V"
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '4.5V',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(cx - textPainter.width / 2, stripeRect.top + 4));

    // Lâminas de terminal metálicas no topo (polos - e +)
    final termLeft = Rect.fromLTWH(cx - bodyWidth * 0.3, bodyRect.top - 12, 10, 14);
    final termRight = Rect.fromLTWH(cx + bodyWidth * 0.15, bodyRect.top - 16, 12, 18);

    final metalPaint = Paint()..color = const Color(0xFFD4AF37); // Latão
    canvas.drawRect(termLeft, metalPaint);
    canvas.drawRect(termRight, metalPaint);

    // Condutores de latão estendendo para as extremidades dos terminais da célula A e B
    final wireLeadPaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(termLeft.center.dx, termLeft.top + 4), Offset(0, cy), wireLeadPaint);
    canvas.drawLine(Offset(termRight.center.dx, termRight.top + 4), Offset(size.width, cy), wireLeadPaint);

    // Símbolos - e + nas lâminas
    final signStyle = const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold);
    TextPainter(text: TextSpan(text: '-', style: signStyle), textDirection: TextDirection.ltr)
      ..layout()
      ..paint(canvas, Offset(termLeft.left + 2, termLeft.top - 10));
    TextPainter(text: TextSpan(text: '+', style: signStyle), textDirection: TextDirection.ltr)
      ..layout()
      ..paint(canvas, Offset(termRight.left + 2, termRight.top - 10));
  }

  void _drawPhysicalWire(Canvas canvas, Size size, double cx, double cy) {
    final pathRed = Path();
    pathRed.moveTo(size.width * 0.15, cy + 15);
    pathRed.cubicTo(
      size.width * 0.35, cy - 25,
      size.width * 0.65, cy + 35,
      size.width * 0.85, cy - 10,
    );

    final pathBlack = Path();
    pathBlack.moveTo(size.width * 0.2, cy - 15);
    pathBlack.cubicTo(
      size.width * 0.4, cy + 25,
      size.width * 0.7, cy - 35,
      size.width * 0.8, cy + 15,
    );

    // Fio preto
    canvas.drawPath(
      pathBlack,
      Paint()
        ..color = isDarkMode ? Colors.grey[400]! : const Color(0xFF222222)
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Fio vermelho
    canvas.drawPath(
      pathRed,
      Paint()
        ..color = const Color(0xFFE53935)
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Garras jacaré nas pontas
    final clipPaint = Paint()..color = Colors.grey[700]!;
    canvas.drawCircle(Offset(size.width * 0.85, cy - 10), 5, clipPaint);
    canvas.drawCircle(Offset(size.width * 0.15, cy + 15), 5, clipPaint);
  }

  void _drawPhysicalSwitch(Canvas canvas, Size size, double cx, double cy) {
    _drawBaseBlock(canvas, size, cx, cy);

    final pPivot = Offset(cx - 25, cy + 6);
    final pLeverEnd = isActive
        ? Offset(cx + 25, cy + 6) // Fechado (encostando no terminal preto)
        : Offset(cx + 5, cy - 26); // Aberto (alavanca erguida)

    // LED de status de estado (Verde quando ligado / Amarelo quando desligado)
    final statusLedPos = Offset(cx, cy + 12);
    final statusColor = isActive ? const Color(0xFF00FF9D) : const Color(0xFFFFB300);

    // Glow do LED de status
    canvas.drawCircle(
      statusLedPos,
      5.0,
      Paint()
        ..color = statusColor.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(statusLedPos, 2.5, Paint()..color = statusColor);

    // Bornes de conexão 3D banana jack
    _drawTerminalJack(canvas, pPivot, true);
    _drawTerminalJack(canvas, Offset(cx + 25, cy + 6), false);

    // Ponto de contato de latão no terminal de chegada (Terminal B)
    canvas.drawCircle(Offset(cx + 25, cy + 6), 2.5, Paint()..color = const Color(0xFFD4AF37));

    // Sombra projetada sob a alavanca
    canvas.drawLine(
      pPivot.translate(1, 3),
      pLeverEnd.translate(1, 3),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..strokeWidth = 4.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2)
        ..strokeCap = StrokeCap.round,
    );

    // Alavanca do interruptor (Corpo metálico com revestimento cromado)
    final leverPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE2E8F0), Color(0xFF64748B), Color(0xFF334155)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromPoints(pPivot, pLeverEnd))
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(pPivot, pLeverEnd, leverPaint);

    // Manopla isolante vermelha na ponta da alavanca
    final handleColor = isActive ? const Color(0xFFFF3B7F) : const Color(0xFFE53935);
    canvas.drawCircle(pLeverEnd, 5.5, Paint()..color = handleColor);
    canvas.drawCircle(
      Offset(pLeverEnd.dx - 1.5, pLeverEnd.dy - 1.5),
      1.8,
      Paint()..color = Colors.white.withValues(alpha: 0.7),
    );
  }

  void _drawPhysicalBulb(Canvas canvas, Size size, double cx, double cy) {
    _drawBaseBlock(canvas, size, cx, cy);

    // Bornes nas pontas da base (3D banana jack)
    _drawTerminalJack(canvas, Offset(cx - 30, cy + 4), true);
    _drawTerminalJack(canvas, Offset(cx + 30, cy + 4), false);

    // Soquete da lâmpada (metal cilíndrico)
    final socketRect = Rect.fromCenter(center: Offset(cx, cy - 2), width: 18, height: 16);
    canvas.drawRect(socketRect, Paint()..color = Colors.grey[400]!);

    // Bulbo de vidro
    final bulbCenter = Offset(cx, cy - 18);
    final bulbRadius = 14.0;

    if (isActive) {
      // Glow radiante estendido de luz nos grid cells ao redor
      canvas.drawCircle(
        bulbCenter,
        bulbRadius + 28,
        Paint()
          ..color = const Color(0xFFFFD54F).withValues(alpha: 0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
      );
      // Glow médio brilhante do bulbo aceso
      canvas.drawCircle(
        bulbCenter,
        bulbRadius + 12,
        Paint()
          ..color = const Color(0xFFFFB300).withValues(alpha: 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }

    // Sombra de volume sob o bulbo
    canvas.drawCircle(
      bulbCenter.translate(2, 3),
      bulbRadius,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Corpo do bulbo com gradiente esférico
    final glassPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.4),
        radius: 0.85,
        colors: isActive
            ? [const Color(0xFFFFF9C4), const Color(0xFFFFF176), const Color(0xFFFFB300)]
            : (isDarkMode
                ? [Colors.white24, Colors.white10, Colors.transparent]
                : [const Color(0xFFE0ECEF), const Color(0xFFB0BEC5), const Color(0xFF78909C)]),
      ).createShader(Rect.fromCircle(center: bulbCenter, radius: bulbRadius));
    canvas.drawCircle(bulbCenter, bulbRadius, glassPaint);

    // Borda do vidro
    final glassBorder = Paint()
      ..color = isActive ? Colors.amber.withValues(alpha: 0.6) : Colors.grey[400]!
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(bulbCenter, bulbRadius, glassBorder);

    // Brilho especular (ponto de luz no vidro)
    canvas.drawCircle(
      Offset(bulbCenter.dx - 4, bulbCenter.dy - 5),
      3.5,
      Paint()..color = Colors.white.withValues(alpha: isActive ? 0.9 : 0.6),
    );

    // Filamento no centro
    final filamentPaint = Paint()
      ..color = isActive ? Colors.deepOrange : Colors.grey[700]!
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy - 16), radius: 5),
      math.pi,
      math.pi,
      false,
      filamentPaint,
    );
  }

  List<Color> _getResistorColors(double val) {
    if (val <= 0) val = 10.0;
    final int valInt = val.round();
    final String str = valInt.toString();
    int d1 = int.parse(str[0]);
    int d2 = str.length > 1 ? int.parse(str[1]) : 0;
    int zeros = str.length - 2;
    if (zeros < 0) zeros = 0;

    final colorMap = [
      const Color(0xFF212121), // 0 Black
      const Color(0xFF795548), // 1 Brown
      const Color(0xFFE53935), // 2 Red
      const Color(0xFFFF9800), // 3 Orange
      const Color(0xFFFFD54F), // 4 Yellow
      const Color(0xFF4CAF50), // 5 Green
      const Color(0xFF1E88E5), // 6 Blue
      const Color(0xFF7E57C2), // 7 Violet
      const Color(0xFF9E9E9E), // 8 Grey
      const Color(0xFFFFFFFF), // 9 White
    ];

    final c1 = colorMap[d1.clamp(0, 9)];
    final c2 = colorMap[d2.clamp(0, 9)];
    final c3 = colorMap[zeros.clamp(0, 9)];
    final c4 = const Color(0xFFD4AF37); // Gold tolerance 5%

    return [c1, c2, c3, c4];
  }

  void _drawPhysicalResistor(Canvas canvas, Size size, double cx, double cy) {
    _drawBaseBlock(canvas, size, cx, cy);

    // Bornes laterais (3D banana jack)
    _drawTerminalJack(canvas, Offset(cx - 32, cy + 4), true);
    _drawTerminalJack(canvas, Offset(cx + 32, cy + 4), false);

    // Corpo cerâmico abuloado do resistor (Bege/bege-marfim)
    final resRect = Rect.fromCenter(center: Offset(cx, cy - 4), width: 36, height: 13);
    final resRRect = RRect.fromRectAndRadius(resRect, const Radius.circular(5));

    // Sombra do resistor
    canvas.drawRRect(
      RRect.fromRectAndRadius(resRect.translate(1, 2), const Radius.circular(5)),
      Paint()..color = Colors.black.withValues(alpha: 0.25)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    // Gradiente de iluminação do corpo cerâmico
    final ceramicShader = const LinearGradient(
      colors: [Color(0xFFFAF3E0), Color(0xFFE8D8B8), Color(0xFFD7C49E)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(resRect);
    canvas.drawRRect(resRRect, Paint()..shader = ceramicShader);

    // Fios de chumbo estanhados
    final leadPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.white, Color(0xFFB0BEC5), Color(0xFF546E7A)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(cx - 32, cy - 4, 64, 8))
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - 32, cy + 4), Offset(cx - 18, cy - 4), leadPaint);
    canvas.drawLine(Offset(cx + 32, cy + 4), Offset(cx + 18, cy - 4), leadPaint);

    // Faixas de cores dinâmicas calculadas a partir do valor em Ohms!
    final colors = _getResistorColors(value);
    final bandPositions = [-10.0, -4.0, 2.0, 10.0];
    for (var i = 0; i < colors.length; i++) {
      canvas.drawRect(
        Rect.fromLTWH(cx + bandPositions[i], cy - 10.5, 3.2, 13),
        Paint()..color = colors[i],
      );
    }

    // Brilho especular longitudinal
    canvas.drawLine(
      Offset(resRect.left + 2, resRect.top + 1.5),
      Offset(resRect.right - 2, resRect.top + 1.5),
      Paint()..color = Colors.white.withValues(alpha: 0.6)..strokeWidth = 1.2,
    );
  }

  void _drawPhysicalDiode(Canvas canvas, Size size, double cx, double cy) {
    _drawBaseBlock(canvas, size, cx, cy);

    // Bornes (Terminal A à esquerda = Cátodo [-], Terminal B à direita = Ânodo [+])
    _drawTerminalJack(canvas, Offset(cx - 32, cy + 4), false);
    _drawTerminalJack(canvas, Offset(cx + 32, cy + 4), true);

    // Corpo do Diodo (cilindro preto)
    final diodeRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy - 4), width: 38, height: 14),
      const Radius.circular(3),
    );
    canvas.drawRRect(diodeRect, Paint()..color = const Color(0xFF212121));

    // Anel prateado no cátodo (marcação de polaridade no Terminal A - à esquerda)
    canvas.drawRect(
      Rect.fromLTWH(cx - 12, cy - 11, 4, 14),
      Paint()..color = Colors.grey[300]!,
    );

    // Terminadores
    final leadPaint = Paint()
      ..color = Colors.grey[600]!
      ..strokeWidth = 2;
    canvas.drawLine(Offset(cx - 32, cy + 4), Offset(cx - 19, cy - 4), leadPaint);
    canvas.drawLine(Offset(cx + 32, cy + 4), Offset(cx + 19, cy - 4), leadPaint);
  }

  void _drawPhysicalLED(Canvas canvas, Size size, double cx, double cy) {
    _drawBaseBlock(canvas, size, cx, cy);

    // Bornes (Terminal A à esquerda = Cátodo [-], Terminal B à direita = Ânodo [+])
    _drawTerminalJack(canvas, Offset(cx - 30, cy + 4), false);
    _drawTerminalJack(canvas, Offset(cx + 30, cy + 4), true);

    final domeCenter = Offset(cx, cy - 12);
    final ledRadius = 12.0;

    // Glow néon expandido de alta fidelidade do LED quando energizado
    if (isActive) {
      canvas.drawCircle(
        domeCenter,
        ledRadius + 26,
        Paint()
          ..color = const Color(0xFF00FF9D).withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
      );
      canvas.drawCircle(
        domeCenter,
        ledRadius + 14,
        Paint()
          ..color = const Color(0xFF00E676).withValues(alpha: 0.7)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );

      // Rayos de fotões pulsantes do LED
      final rayPaint = Paint()
        ..color = const Color(0xFF00FF9D).withValues(alpha: 0.8)
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(cx - 14, cy - 24), Offset(cx - 20, cy - 30), rayPaint);
      canvas.drawLine(Offset(cx + 14, cy - 24), Offset(cx + 20, cy - 30), rayPaint);
      canvas.drawLine(Offset(cx, cy - 28), Offset(cx, cy - 36), rayPaint);
    }

    // Pinos de chumbo metálicos internos (Anvil e Post visíveis no interior da resina)
    final leadFramePaint = Paint()
      ..color = Colors.blueGrey.shade300.withValues(alpha: 0.85)
      ..strokeWidth = 1.8;
    canvas.drawLine(Offset(cx - 3.5, domeCenter.dy + 4), Offset(cx - 3.5, domeCenter.dy - 2), leadFramePaint);
    canvas.drawLine(Offset(cx + 3.5, domeCenter.dy + 4), Offset(cx + 3.5, domeCenter.dy - 4), leadFramePaint);

    // Cabeça do ânodo (Anvil em formato de taça)
    final anvilPath = Path()
      ..moveTo(cx - 5.5, domeCenter.dy - 2)
      ..lineTo(cx - 1.5, domeCenter.dy - 2)
      ..lineTo(cx - 2.5, domeCenter.dy - 6)
      ..close();
    canvas.drawPath(anvilPath, Paint()..color = Colors.blueGrey.shade200);

    // Cúpula esférica de resina epóxi transparente com gradiente de lente 3D
    final domeShader = RadialGradient(
      center: const Alignment(-0.35, -0.4),
      radius: 0.85,
      colors: isActive
          ? [const Color(0xFFB9F6CA), const Color(0xFF00E676), const Color(0xFF00C853), const Color(0xFF1B5E20)]
          : [const Color(0xFF81C784).withValues(alpha: 0.8), const Color(0xFF388E3C), const Color(0xFF1B5E20)],
    ).createShader(Rect.fromCircle(center: domeCenter, radius: ledRadius));

    canvas.drawCircle(domeCenter, ledRadius, Paint()..shader = domeShader);

    // Colarinho/Anel de resina na base
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - ledRadius - 1, domeCenter.dy + 4, (ledRadius + 1) * 2, 4),
        const Radius.circular(1.5),
      ),
      Paint()..color = isActive ? const Color(0xFF2E7D32) : const Color(0xFF1B5E20),
    );

    // Brilho especular curvo de lente de vidro no domo
    final glassHighlightPath = Path()
      ..addArc(
        Rect.fromCircle(center: Offset(cx - 3, domeCenter.dy - 3), radius: ledRadius * 0.6),
        -math.pi * 0.8,
        math.pi * 0.5,
      );
    canvas.drawPath(
      glassHighlightPath,
      Paint()
        ..color = Colors.white.withValues(alpha: isActive ? 0.9 : 0.65)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawPhysicalMotor(Canvas canvas, Size size, double cx, double cy) {
    _drawBaseBlock(canvas, size, cx, cy);

    final leftTerminal = Offset(cx - 30, cy + 6);
    final rightTerminal = Offset(cx + 30, cy + 6);

    // Bornes de conexão 3D banana jack na base da bancada
    _drawTerminalJack(canvas, leftTerminal, true);
    _drawTerminalJack(canvas, rightTerminal, false);

    // Tampa traseira de plástico (Plastic End-cap) do motor DC (tipo 130)
    final capBackRect = Rect.fromLTWH(cx - 20, cy - 14, 6, 16);
    final capBackRRect = RRect.fromRectAndRadius(capBackRect, const Radius.circular(2));
    canvas.drawRRect(capBackRRect, Paint()..color = const Color(0xFF1E293B));

    // Abas/Terminais de solda de latão na tampa traseira
    final solderLug1 = Rect.fromLTWH(cx - 22, cy - 12, 3, 4);
    final solderLug2 = Rect.fromLTWH(cx - 22, cy - 2, 3, 4);
    final lugPaint = Paint()..color = const Color(0xFFD4AF37);
    canvas.drawRect(solderLug1, lugPaint);
    canvas.drawRect(solderLug2, lugPaint);

    // Fios de conexão trançados flexíveis dos bornes até os terminais de solda do motor
    final leadPathRed = Path()
      ..moveTo(leftTerminal.dx, leftTerminal.dy)
      ..cubicTo(cx - 28, cy, cx - 24, cy - 10, cx - 22, cy - 10);
    final leadPathBlack = Path()
      ..moveTo(rightTerminal.dx, rightTerminal.dy)
      ..cubicTo(cx - 26, cy + 2, cx - 24, cy, cx - 22, cy);

    canvas.drawPath(
      leadPathRed,
      Paint()
        ..color = const Color(0xFFE53935)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      leadPathBlack,
      Paint()
        ..color = isDarkMode ? Colors.grey[400]! : const Color(0xFF1E293B)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Corpo metálico cilíndrico escovado do motor DC (formato clássico Can-shape)
    final motorRect = Rect.fromCenter(center: Offset(cx - 2, cy - 6), width: 32, height: 20);

    // Sombra projetada sob o corpo metálico
    canvas.drawRRect(
      RRect.fromRectAndRadius(motorRect.translate(2, 4), const Radius.circular(5)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Gradiente metálico de aço/alumínio escovado
    final motorGradient = Paint()
      ..shader = LinearGradient(
        colors: isActive
            ? [const Color(0xFFE2E8F0), const Color(0xFF94A3B8), const Color(0xFF475569), const Color(0xFF334155)]
            : [const Color(0xFFCBD5E1), const Color(0xFF64748B), const Color(0xFF334155)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(motorRect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(motorRect, const Radius.circular(5)),
      motorGradient,
    );

    // Fresta/Ranhura de ventilação lateral mostrando a bobina de cobre no interior (Vent Slot & Copper Coil)
    final ventSlot = Rect.fromLTWH(cx - 8, cy - 10, 10, 8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(ventSlot, const Radius.circular(2)),
      Paint()..color = const Color(0xFF0F172A),
    );
    // Enrolamento de cobre brilhante visível na ranhura
    canvas.drawRect(
      Rect.fromLTWH(cx - 6, cy - 8, 6, 4),
      Paint()..color = const Color(0xFFD97706),
    );

    // Linha de reflexo especular metálico no topo do cilindro
    canvas.drawLine(
      Offset(motorRect.left + 4, motorRect.top + 2),
      Offset(motorRect.right - 4, motorRect.top + 2),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.6)
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round,
    );

    // Borda metálica usinada
    canvas.drawRRect(
      RRect.fromRectAndRadius(motorRect, const Radius.circular(5)),
      Paint()
        ..color = const Color(0xFF334155)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke,
    );

    // Bucha frontal metálica de bronze (Front Bearing Collar)
    final bearingRect = Rect.fromLTWH(cx + 14, cy - 9, 4, 6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bearingRect, const Radius.circular(1)),
      Paint()..color = const Color(0xFFB45309), // Bronze
    );

    // Eixo rotativo cilíndrico de Aço Inox (Steel Shaft)
    final shaftPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.white, Color(0xFFCBD5E1), Color(0xFF64748B)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(cx + 18, cy - 8, 8, 4))
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx + 18, cy - 6), Offset(cx + 25, cy - 6), shaftPaint);

    // Hélice / Rotor de Ventoinha 3D (Fan Blade Propeller)
    final discCenter = Offset(cx + 25, cy - 6);
    final fanRadius = 11.0;

    // Sombra do rotor
    canvas.drawCircle(
      discCenter.translate(1, 2),
      fanRadius,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    // Disco metálico/plástico central de suporte das pás
    canvas.drawCircle(
      discCenter,
      fanRadius,
      Paint()..color = isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
    );
    canvas.drawCircle(
      discCenter,
      fanRadius,
      Paint()
        ..color = isDarkMode ? const Color(0xFF00F5D4).withValues(alpha: 0.4) : const Color(0xFF475569)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // 4 Pás da Hélice Rotativa estilo aeronáutico/industrial
    final angle = isActive ? (DateTime.now().millisecondsSinceEpoch / 30) % (2 * math.pi) : 0.0;

    for (int i = 0; i < 4; i++) {
      final bladeAngle = angle + (i * math.pi / 2);
      final pEnd = Offset(
        discCenter.dx + (fanRadius - 1.0) * math.cos(bladeAngle),
        discCenter.dy + (fanRadius - 1.0) * math.sin(bladeAngle),
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
          ..strokeWidth = 3.2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }

    // Miolo central metálico de fixação
    canvas.drawCircle(discCenter, 3.0, Paint()..color = const Color(0xFFD97706));
    canvas.drawCircle(discCenter, 1.2, Paint()..color = Colors.black);

    // Efeito de Rotação de Vento Néon (Motion Blur & Airflow Glow)
    if (isActive) {
      canvas.drawCircle(
        discCenter,
        fanRadius + 3,
        Paint()
          ..color = const Color(0xFF00F5D4).withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
      canvas.drawCircle(
        discCenter,
        fanRadius + 6,
        Paint()
          ..color = const Color(0xFF00FF9D).withValues(alpha: 0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }
  }

  /// Desenha conectores tipo Borne Banana 3D (Vermelho = Positivo/VCC, Preto = Negativo/GND)
  void _drawTerminalJack(Canvas canvas, Offset center, bool isPositive) {
    const radius = 5.5;

    // 1. Sombra de profundidade projetada sob o conector
    canvas.drawCircle(
      center.translate(1.0, 1.8),
      radius + 0.8,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );

    // 2. Anel metálico cromado de fixação (Bisel de metal do conector banana 3D)
    final metalBevelPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.4, -0.4),
        colors: const [Color(0xFFFFFFFF), Color(0xFF94A3B8), Color(0xFF334155)],
      ).createShader(Rect.fromCircle(center: center, radius: radius + 1.4));
    canvas.drawCircle(center, radius + 1.4, metalBevelPaint);

    // 3. Corpo isolante de plástico moldado 3D (Vermelho / Preto)
    final jackShader = RadialGradient(
      center: const Alignment(-0.35, -0.4),
      radius: 0.85,
      colors: isPositive
          ? const [Color(0xFFFF5252), Color(0xFFD32F2F), Color(0xFF7F0000)]
          : const [Color(0xFF475569), Color(0xFF1E293B), Color(0xFF0F172A)],
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, Paint()..shader = jackShader);

    // 4. Orifício interno recessed (Conector fêmea 3D com profundidade de inserção)
    canvas.drawCircle(
      center,
      2.3,
      Paint()..color = const Color(0xFF0A0E17),
    );

    // 5. Pino interno de latão/cobre banhado a ouro
    canvas.drawCircle(
      center,
      1.1,
      Paint()..color = const Color(0xFFFFD700),
    );

    // 6. Brilho especular curvado de plástico
    canvas.drawCircle(
      Offset(center.dx - 1.5, center.dy - 1.5),
      1.2,
      Paint()..color = Colors.white.withValues(alpha: 0.8),
    );
  }

  /// Desenha a bancada/base retangular cinza dos componentes físicos (como nas fotos)
  void _drawBaseBlock(Canvas canvas, Size size, double cx, double cy) {
    final blockWidth = size.width * 0.72;
    final blockHeight = 22.0;
    final blockRect = Rect.fromCenter(
      center: Offset(cx, cy + 12),
      width: blockWidth,
      height: blockHeight,
    );
    final rr = RRect.fromRectAndRadius(blockRect, const Radius.circular(5));

    // Hastes metálicas estendendo o circuito até as bordas das células (Terminais A e B)
    final leadPaint = Paint()
      ..color = isDarkMode ? const Color(0xFF90A4AE) : const Color(0xFF78909C)
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, cy + 12), Offset(blockRect.left + 4, cy + 12), leadPaint);
    canvas.drawLine(Offset(blockRect.right - 4, cy + 12), Offset(size.width, cy + 12), leadPaint);

    // Sombra projetada estendida (Layer 1: Sombra suave de ambiente)
    canvas.drawRRect(
      RRect.fromRectAndRadius(blockRect.translate(3, 6), const Radius.circular(5)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Sombra projetada de contato (Layer 2: Sombra densa de oclusão)
    canvas.drawRRect(
      RRect.fromRectAndRadius(blockRect.translate(1, 2), const Radius.circular(5)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    // Corpo com gradiente de iluminação 3D chamfrado
    final baseGrad = Paint()
      ..shader = LinearGradient(
        colors: isDarkMode
            ? [const Color(0xFF334155), const Color(0xFF1E293B), const Color(0xFF0F172A)]
            : [const Color(0xFFFFFFFF), const Color(0xFFE2E8F0), const Color(0xFFCBD5E1)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(blockRect);
    canvas.drawRRect(rr, baseGrad);

    // Highlight especular superior (borda de luz bevel)
    final topHighlight = Paint()
      ..color = Colors.white.withValues(alpha: isDarkMode ? 0.35 : 0.9)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(blockRect.left + 5, blockRect.top + 0.6),
      Offset(blockRect.right - 5, blockRect.top + 0.6),
      topHighlight,
    );

    // Friso néon sutil de acabamento no modo escuro Cyberpunk
    if (isDarkMode) {
      canvas.drawLine(
        Offset(blockRect.left + 8, blockRect.bottom - 2),
        Offset(blockRect.right - 8, blockRect.bottom - 2),
        Paint()
          ..color = const Color(0xFF00F5D4).withValues(alpha: 0.45)
          ..strokeWidth = 1.0,
      );
    }

    // Borda de sombra inferior
    final bottomShadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(blockRect.left + 5, blockRect.bottom - 0.6),
      Offset(blockRect.right - 5, blockRect.bottom - 0.6),
      bottomShadow,
    );

    // Borda externa chamfrada
    canvas.drawRRect(
      rr,
      Paint()
        ..color = isDarkMode ? const Color(0xFF475569) : const Color(0xFF94A3B8)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke,
    );

    // Rebites/Parafusos metálicos de fixação industrial nos 4 cantos da base 3D
    final rivetPositions = [
      Offset(blockRect.left + 5, blockRect.top + 5),
      Offset(blockRect.right - 5, blockRect.top + 5),
      Offset(blockRect.left + 5, blockRect.bottom - 5),
      Offset(blockRect.right - 5, blockRect.bottom - 5),
    ];
    for (final pos in rivetPositions) {
      canvas.drawCircle(pos, 1.4, Paint()..color = isDarkMode ? const Color(0xFF64748B) : const Color(0xFF94A3B8));
      canvas.drawCircle(pos, 0.7, Paint()..color = isDarkMode ? const Color(0xFF0F172A) : const Color(0xFF334155));
    }
  }

  void _drawPhysicalPotentiometer(Canvas canvas, Size size, double cx, double cy) {
    _drawBaseBlock(canvas, size, cx, cy);

    // Bornes (3D banana jack)
    _drawTerminalJack(canvas, Offset(cx - 32, cy + 4), true);
    _drawTerminalJack(canvas, Offset(cx + 32, cy + 4), false);

    // Corpo metálico cilíndrico do potenciômetro
    final knobCenter = Offset(cx, cy - 8);
    final knobRadius = 14.0;
    
    canvas.drawCircle(
      knobCenter.translate(2, 3),
      knobRadius,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    canvas.drawCircle(
      knobCenter,
      knobRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [const Color(0xFFE0E0E0), const Color(0xFF9E9E9E), const Color(0xFF424242)],
        ).createShader(Rect.fromCircle(center: knobCenter, radius: knobRadius)),
    );

    // Traço indicador de posição no knob
    final angle = -math.pi / 4;
    final indX = knobCenter.dx + (knobRadius - 3) * math.cos(angle);
    final indY = knobCenter.dy + (knobRadius - 3) * math.sin(angle);
    canvas.drawLine(
      knobCenter,
      Offset(indX, indY),
      Paint()
        ..color = const Color(0xFF00F5D4)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // Marcação graduada ao redor
    for (int i = 0; i <= 6; i++) {
      final a = -3 * math.pi / 4 + (i * math.pi / 4);
      final p1 = Offset(knobCenter.dx + (knobRadius + 3) * math.cos(a), knobCenter.dy + (knobRadius + 3) * math.sin(a));
      final p2 = Offset(knobCenter.dx + (knobRadius + 6) * math.cos(a), knobCenter.dy + (knobRadius + 6) * math.sin(a));
      canvas.drawLine(p1, p2, Paint()..color = const Color(0xFF00F5D4)..strokeWidth = 1.2);
    }
  }

  void _drawPhysicalPowerSupply(Canvas canvas, Size size, double cx, double cy) {
    // Gabinete principal da fonte studio
    final bodyRect = Rect.fromCenter(center: Offset(cx, cy - 2), width: size.width * 0.76, height: size.height * 0.65);
    final rr = RRect.fromRectAndRadius(bodyRect, const Radius.circular(8));

    // Sombra
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect.translate(2, 4), const Radius.circular(8)),
      Paint()..color = Colors.black.withValues(alpha: 0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Corpo metálico escuro Cyberpunk
    canvas.drawRRect(
      rr,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(bodyRect),
    );

    canvas.drawRRect(rr, Paint()..color = const Color(0xFF00F5D4).withValues(alpha: 0.6)..strokeWidth = 1.5..style = PaintingStyle.stroke);

    // Display LED 7 Segmentos com Tensão
    final lcdRect = Rect.fromCenter(center: Offset(cx, cy - 12), width: 48, height: 20);
    canvas.drawRRect(RRect.fromRectAndRadius(lcdRect, const Radius.circular(4)), Paint()..color = const Color(0xFF022C22));
    
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '12.0V',
        style: TextStyle(
          color: Color(0xFF00FF9D),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(cx - textPainter.width / 2, cy - 18));

    // Bornes de Saída DC (+ e -) 3D banana jack
    _drawTerminalJack(canvas, Offset(cx - 18, cy + 12), true);
    _drawTerminalJack(canvas, Offset(cx + 18, cy + 12), false);
  }

  void _drawPhysicalFuse(Canvas canvas, Size size, double cx, double cy) {
    _drawBaseBlock(canvas, size, cx, cy);

    // Bornes (3D banana jack)
    _drawTerminalJack(canvas, Offset(cx - 32, cy + 4), true);
    _drawTerminalJack(canvas, Offset(cx + 32, cy + 4), false);

    // Tubo de Vidro do Fusível
    final tubeRect = Rect.fromCenter(center: Offset(cx, cy - 4), width: 38, height: 12);
    canvas.drawRRect(
      RRect.fromRectAndRadius(tubeRect, const Radius.circular(4)),
      Paint()..color = isDarkMode ? Colors.white24 : const Color(0x66E0F7FA),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tubeRect, const Radius.circular(4)),
      Paint()..color = Colors.cyan.withValues(alpha: 0.5)..strokeWidth = 1.2..style = PaintingStyle.stroke,
    );

    // Tampas Metálicas Cromadas nas pontas
    final capLeft = Rect.fromLTWH(tubeRect.left, tubeRect.top, 8, 12);
    final capRight = Rect.fromLTWH(tubeRect.right - 8, tubeRect.top, 8, 12);
    final metalPaint = Paint()..color = Colors.grey[400]!;
    canvas.drawRect(capLeft, metalPaint);
    canvas.drawRect(capRight, metalPaint);

    // Filamento interno do Fusível
    if (!isBurned) {
      canvas.drawLine(
        Offset(tubeRect.left + 8, cy - 4),
        Offset(tubeRect.right - 8, cy - 4),
        Paint()..color = Colors.amber.shade300..strokeWidth = 1.5,
      );
    } else {
      // Filamento rompidos por sobrecorrente
      canvas.drawLine(Offset(tubeRect.left + 8, cy - 4), Offset(cx - 4, cy - 2), Paint()..color = Colors.black87..strokeWidth = 1.5);
      canvas.drawLine(Offset(cx + 4, cy - 6), Offset(tubeRect.right - 8, cy - 4), Paint()..color = Colors.black87..strokeWidth = 1.5);
    }
  }

  void _drawPhysicalCapacitor(Canvas canvas, Size size, double cx, double cy) {
    _drawBaseBlock(canvas, size, cx, cy);

    // Bornes (3D banana jack)
    _drawTerminalJack(canvas, Offset(cx - 30, cy + 4), true);
    _drawTerminalJack(canvas, Offset(cx + 30, cy + 4), false);

    // Corpo do Capacitor Eletrolítico (Cilindro Azul)
    final capRect = Rect.fromCenter(center: Offset(cx, cy - 10), width: 22, height: 26);
    final rr = RRect.fromRectAndRadius(capRect, const Radius.circular(5));

    canvas.drawRRect(
      rr,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF1565C0), Color(0xFF0D47A1)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(capRect),
    );

    // Faixa cinza de polaridade negativa (-)
    canvas.drawRect(
      Rect.fromLTWH(capRect.left, capRect.top, 6, capRect.height),
      Paint()..color = Colors.grey[300]!,
    );
  }

  void _drawPhysicalBuzzer(Canvas canvas, Size size, double cx, double cy) {
    _drawBaseBlock(canvas, size, cx, cy);

    // Bornes (3D banana jack)
    _drawTerminalJack(canvas, Offset(cx - 30, cy + 4), true);
    _drawTerminalJack(canvas, Offset(cx + 30, cy + 4), false);

    // Cápsula Piezoelétrica Preta
    final buzzCenter = Offset(cx, cy - 8);
    final buzzRadius = 15.0;

    canvas.drawCircle(buzzCenter, buzzRadius, Paint()..color = const Color(0xFF1F2937));
    canvas.drawCircle(buzzCenter, buzzRadius, Paint()..color = const Color(0xFF00F5D4).withValues(alpha: 0.5)..strokeWidth = 1.2..style = PaintingStyle.stroke);
    
    // Furo central de som
    canvas.drawCircle(buzzCenter, 4, Paint()..color = Colors.black87);

    // Ondas sonoras piscantes quando ativo
    if (isActive) {
      final wavePaint = Paint()
        ..color = const Color(0xFF00F5D4).withValues(alpha: 0.8)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      canvas.drawArc(Rect.fromCircle(center: buzzCenter, radius: 20), -math.pi / 3, 2 * math.pi / 3, false, wavePaint);
      canvas.drawArc(Rect.fromCircle(center: buzzCenter, radius: 25), -math.pi / 3, 2 * math.pi / 3, false, wavePaint..color = const Color(0xFF00F5D4).withValues(alpha: 0.4));
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
