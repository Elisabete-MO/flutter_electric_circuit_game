import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/first_step_component.dart';

/// Renderizador CustomPainter dos componentes em seu aspecto físico/realista
/// inspirado nos itens da bancada de laboratório das imagens 1 e 2.
class ComponentPhysicalPainter extends CustomPainter {
  ComponentPhysicalPainter({
    required this.type,
    this.isActive = false,
    this.isBurned = false,
    required this.isDarkMode,
  });

  final ComponentType type;
  final bool isActive;
  final bool isBurned;
  final bool isDarkMode;

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
      canvas.drawCircle(
        Offset(cx, cy),
        size.width * 0.38,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.65)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );

      final textPainter = TextPainter(
        text: const TextSpan(
          text: '💥',
          style: TextStyle(fontSize: 18),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(cx - 9, cy - 11));
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

    // Bornes de conexão vermelhos e pretos
    canvas.drawCircle(pPivot, 6, Paint()..color = Colors.red);
    canvas.drawCircle(Offset(cx + 25, cy + 6), 6, Paint()..color = Colors.black87);

    // Alavanca do interruptor (conectada diretamente ao centro da bolinha vermelha)
    final leverPaint = Paint()
      ..color = Colors.grey[800]!
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final handlePaint = Paint()..color = Colors.red;

    canvas.drawLine(pPivot, pLeverEnd, leverPaint);
    canvas.drawCircle(pLeverEnd, 5, handlePaint);
  }

  void _drawPhysicalBulb(Canvas canvas, Size size, double cx, double cy) {
    _drawBaseBlock(canvas, size, cx, cy);

    // Bornes nas pontas da base
    canvas.drawCircle(Offset(cx - 30, cy + 4), 5, Paint()..color = Colors.red);
    canvas.drawCircle(Offset(cx + 30, cy + 4), 5, Paint()..color = Colors.black87);

    // Soquete da lâmpada (metal cilíndrico)
    final socketRect = Rect.fromCenter(center: Offset(cx, cy - 2), width: 18, height: 16);
    canvas.drawRect(socketRect, Paint()..color = Colors.grey[400]!);

    // Bulbo de vidro
    final bulbCenter = Offset(cx, cy - 18);
    final bulbRadius = 14.0;

    if (isActive) {
      // Glow externo do bulbo aceso
      canvas.drawCircle(
        bulbCenter,
        bulbRadius + 10,
        Paint()
          ..color = const Color(0xFFFFD54F).withValues(alpha: 0.35)
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

  void _drawPhysicalResistor(Canvas canvas, Size size, double cx, double cy) {
    _drawBaseBlock(canvas, size, cx, cy);

    // Bornes laterais
    canvas.drawCircle(Offset(cx - 32, cy + 4), 5, Paint()..color = Colors.red);
    canvas.drawCircle(Offset(cx + 32, cy + 4), 5, Paint()..color = Colors.black87);

    // Corpo cerâmico do resistor (bege/bege-claro)
    final resRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy - 4), width: 36, height: 12),
      const Radius.circular(4),
    );
    canvas.drawRRect(resRect, Paint()..color = const Color(0xFFE8D8B8));

    // Fios de chumbo que saem das pontas
    final leadPaint = Paint()
      ..color = Colors.grey[600]!
      ..strokeWidth = 2;
    canvas.drawLine(Offset(cx - 32, cy + 4), Offset(cx - 18, cy - 4), leadPaint);
    canvas.drawLine(Offset(cx + 32, cy + 4), Offset(cx + 18, cy - 4), leadPaint);

    // Faixas de cores do código de resistores (ex: Amarelo, Violeta, Vermelho, Dourado)
    final colors = [
      const Color(0xFFFFD54F), // Amarelo
      const Color(0xFF7E57C2), // Violeta
      const Color(0xFFE53935), // Vermelho
      const Color(0xFFD4AF37), // Dourado
    ];
    final bandPositions = [-10.0, -4.0, 2.0, 10.0];
    for (var i = 0; i < colors.length; i++) {
      canvas.drawRect(
        Rect.fromLTWH(cx + bandPositions[i], cy - 10, 3, 12),
        Paint()..color = colors[i],
      );
    }
  }

  void _drawPhysicalDiode(Canvas canvas, Size size, double cx, double cy) {
    _drawBaseBlock(canvas, size, cx, cy);

    // Bornes
    canvas.drawCircle(Offset(cx - 32, cy + 4), 5, Paint()..color = Colors.red);
    canvas.drawCircle(Offset(cx + 32, cy + 4), 5, Paint()..color = Colors.black87);

    // Corpo do Diodo (cilindro preto)
    final diodeRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy - 4), width: 38, height: 14),
      const Radius.circular(3),
    );
    canvas.drawRRect(diodeRect, Paint()..color = const Color(0xFF212121));

    // Anel prateado no catodo (marcação de polaridade)
    canvas.drawRect(
      Rect.fromLTWH(cx + 8, cy - 11, 4, 14),
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

    // Bornes
    canvas.drawCircle(Offset(cx - 30, cy + 4), 5, Paint()..color = Colors.red);
    canvas.drawCircle(Offset(cx + 30, cy + 4), 5, Paint()..color = Colors.black87);

    // Cúpula do LED (Epóxi verde)
    final domeCenter = Offset(cx, cy - 12);
    final ledRadius = 11.0;

    if (isActive) {
      // Brilho intenso de LED aceso
      canvas.drawCircle(
        domeCenter,
        ledRadius + 10,
        Paint()..color = const Color(0xFF4CAF50).withValues(alpha: 0.6),
      );
    }

    final ledColor = isActive ? const Color(0xFF66BB6A) : const Color(0xFF2E7D32);
    final domePaint = Paint()..color = ledColor;

    canvas.drawCircle(domeCenter, ledRadius, domePaint);

    // Base do LED (borda metálica/plástica)
    canvas.drawRect(
      Rect.fromLTWH(cx - ledRadius, domeCenter.dy + 4, ledRadius * 2, 5),
      Paint()..color = Colors.grey[800]!,
    );

    // Brilho no topo do domo
    canvas.drawCircle(
      Offset(cx - 3, domeCenter.dy - 3),
      3,
      Paint()..color = Colors.white.withValues(alpha: 0.6),
    );
  }

  void _drawPhysicalMotor(Canvas canvas, Size size, double cx, double cy) {
    _drawBaseBlock(canvas, size, cx, cy);

    final leftTerminal = Offset(cx - 30, cy + 6);
    final rightTerminal = Offset(cx + 30, cy + 6);

    // Bornes de conexão vermelhos e pretos
    canvas.drawCircle(leftTerminal, 5.5, Paint()..color = Colors.red);
    canvas.drawCircle(rightTerminal, 5.5, Paint()..color = Colors.black87);

    // Fios de conexão dos bornes para o motor
    final leadPaintRed = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0;
    final leadPaintBlack = Paint()
      ..color = isDarkMode ? Colors.grey[400]! : Colors.black87
      ..strokeWidth = 2.0;

    final motorBackX = cx - 16;
    canvas.drawLine(leftTerminal, Offset(motorBackX, cy - 6), leadPaintRed);
    canvas.drawLine(rightTerminal, Offset(motorBackX, cy - 2), leadPaintBlack);

    // Corpo metálico cilíndrico do motor
    final motorRect = Rect.fromCenter(center: Offset(cx - 2, cy - 6), width: 30, height: 22);

    // Sombra projetada do motor
    canvas.drawRRect(
      RRect.fromRectAndRadius(motorRect.translate(2, 3), const Radius.circular(6)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Gradiente metálico do corpo do motor
    final motorGradient = Paint()
      ..shader = LinearGradient(
        colors: isActive
            ? [const Color(0xFFCFD8DC), const Color(0xFF90A4AE), const Color(0xFF37474F)]
            : [const Color(0xFFB0BEC5), const Color(0xFF78909C), const Color(0xFF37474F)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(motorRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(motorRect, const Radius.circular(6)),
      motorGradient,
    );

    // Linha de reflexo superior
    canvas.drawLine(
      Offset(motorRect.left + 4, motorRect.top + 3),
      Offset(motorRect.right - 4, motorRect.top + 3),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );

    // Borda do corpo
    canvas.drawRRect(
      RRect.fromRectAndRadius(motorRect, const Radius.circular(6)),
      Paint()
        ..color = const Color(0xFF263238)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke,
    );

    // Eixo rotativo metálico
    final shaftPaint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx + 13, cy - 6), Offset(cx + 20, cy - 6), shaftPaint);

    // Hélice / Rotor montado no eixo
    final discCenter = Offset(cx + 20, cy - 6);
    final fanRadius = 8.5;

    // Disco de fundo da hélice
    canvas.drawCircle(
      discCenter,
      fanRadius,
      Paint()..color = isDarkMode ? const Color(0xFF1E293B) : Colors.grey[300]!,
    );
    canvas.drawCircle(
      discCenter,
      fanRadius,
      Paint()
        ..color = isDarkMode ? Colors.white30 : Colors.black26
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Pás da hélice (3 pás rotativas)
    final angle = isActive ? (DateTime.now().millisecondsSinceEpoch / 50) % (2 * math.pi) : 0.0;
    final bladePaint = Paint()
      ..color = isActive ? const Color(0xFF00F5D4) : (isDarkMode ? Colors.white70 : const Color(0xFF37474F))
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 3; i++) {
      final bladeAngle = angle + (i * 2 * math.pi / 3);
      final pEnd = Offset(
        discCenter.dx + (fanRadius - 1.5) * math.cos(bladeAngle),
        discCenter.dy + (fanRadius - 1.5) * math.sin(bladeAngle),
      );
      canvas.drawLine(discCenter, pEnd, bladePaint);
    }

    // Miolo central da hélice
    canvas.drawCircle(discCenter, 2.5, Paint()..color = Colors.black87);

    // Efeito de vento néon quando o motor está girando
    if (isActive) {
      canvas.drawCircle(
        discCenter,
        fanRadius + 2,
        Paint()
          ..color = const Color(0xFF00F5D4).withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
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

    // Sombra projetada
    canvas.drawRRect(
      RRect.fromRectAndRadius(blockRect.translate(2, 4), const Radius.circular(5)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Corpo com gradiente de iluminação (luz de cima)
    final baseGrad = Paint()
      ..shader = LinearGradient(
        colors: isDarkMode
            ? [const Color(0xFF4A5568), const Color(0xFF2D3748), const Color(0xFF1A202C)]
            : [const Color(0xFFF1F5F9), const Color(0xFFE2E8F0), const Color(0xFFCBD5E0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(blockRect);
    canvas.drawRRect(rr, baseGrad);

    // Highlight especular superior (borda de luz)
    final topHighlight = Paint()
      ..color = Colors.white.withValues(alpha: isDarkMode ? 0.12 : 0.7)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(blockRect.left + 5, blockRect.top + 0.6),
      Offset(blockRect.right - 5, blockRect.top + 0.6),
      topHighlight,
    );

    // Borda de sombra inferior
    final bottomShadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(blockRect.left + 5, blockRect.bottom - 0.6),
      Offset(blockRect.right - 5, blockRect.bottom - 0.6),
      bottomShadow,
    );

    // Borda externa
    canvas.drawRRect(
      rr,
      Paint()
        ..color = isDarkMode ? const Color(0xFF4A5568) : const Color(0xFFADB5BD)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawPhysicalPotentiometer(Canvas canvas, Size size, double cx, double cy) {
    _drawBaseBlock(canvas, size, cx, cy);

    // Bornes
    canvas.drawCircle(Offset(cx - 32, cy + 4), 5, Paint()..color = Colors.red);
    canvas.drawCircle(Offset(cx + 32, cy + 4), 5, Paint()..color = Colors.black87);

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

    // Bornes de Saída DC (+ e -)
    canvas.drawCircle(Offset(cx - 18, cy + 12), 6, Paint()..color = Colors.red);
    canvas.drawCircle(Offset(cx + 18, cy + 12), 6, Paint()..color = Colors.black87);
  }

  void _drawPhysicalFuse(Canvas canvas, Size size, double cx, double cy) {
    _drawBaseBlock(canvas, size, cx, cy);

    // Bornes
    canvas.drawCircle(Offset(cx - 32, cy + 4), 5, Paint()..color = Colors.red);
    canvas.drawCircle(Offset(cx + 32, cy + 4), 5, Paint()..color = Colors.black87);

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

    // Bornes
    canvas.drawCircle(Offset(cx - 30, cy + 4), 5, Paint()..color = Colors.red);
    canvas.drawCircle(Offset(cx + 30, cy + 4), 5, Paint()..color = Colors.black87);

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

    // Bornes
    canvas.drawCircle(Offset(cx - 30, cy + 4), 5, Paint()..color = Colors.red);
    canvas.drawCircle(Offset(cx + 30, cy + 4), 5, Paint()..color = Colors.black87);

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
        oldDelegate.isDarkMode != isDarkMode;
  }
}
