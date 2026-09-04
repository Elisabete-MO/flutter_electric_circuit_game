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
    final cx = size.width / 2;
    final cy = size.height / 2;
    final baseColor = ledColor == Colors.redAccent ? const Color(0xFFEF4444) : ledColor;

    // 1. Pernas Metálicas Verticais (Ânodo longo +, Cátodo curto -)
    final legPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    // Anodo (Esquerda - mais longo)
    canvas.drawLine(Offset(cx - 5, cy + 8), Offset(cx - 5, size.height * 0.95), legPaint);
    // Catodo (Direita - mais curto)
    canvas.drawLine(Offset(cx + 5, cy + 8), Offset(cx + 5, size.height * 0.82), legPaint);

    // 2. Glow Efeito se Energizado
    final domeCenter = Offset(cx, cy - 6);
    final domeRadius = size.width * 0.28;

    if (isOn) {
      canvas.drawCircle(
        domeCenter,
        domeRadius + 14,
        Paint()
          ..color = baseColor.withValues(alpha: 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }

    // 3. Armação Metálica Interna (Lead Frame - Anvil & Post)
    final internalPaint = Paint()
      ..color = const Color(0xFFE2E8F0).withValues(alpha: 0.8)
      ..strokeWidth = 1.6;
    canvas.drawLine(Offset(cx - 4, cy + 4), Offset(cx - 2, cy - 4), internalPaint);
    canvas.drawLine(Offset(cx + 4, cy + 4), Offset(cx + 1, cy - 7), internalPaint);

    // 4. Domo Cilindro de Resina Epóxi
    final domePath = Path();
    domePath.moveTo(cx - domeRadius, cy + 6);
    domePath.lineTo(cx - domeRadius, cy - 6);
    domePath.arcToPoint(
      Offset(cx + domeRadius, cy - 6),
      radius: Radius.circular(domeRadius),
      clockwise: true,
    );
    domePath.lineTo(cx + domeRadius, cy + 6);
    domePath.close();

    final glassPaint = Paint()
      ..shader = RadialGradient(
        colors: isOn
            ? [const Color(0xFFFEF2F2), baseColor, const Color(0xFF991B1B)]
            : [baseColor.withValues(alpha: 0.9), baseColor, const Color(0xFF7F1D1D)],
        center: const Alignment(-0.35, -0.45),
        radius: 0.85,
      ).createShader(domePath.getBounds());

    canvas.drawPath(domePath, glassPaint);

    // 5. Anel Flange de Base
    final flangePath = Path();
    flangePath.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - (domeRadius * 1.2), cy + 5, domeRadius * 2.4, 4),
      const Radius.circular(2),
    ));
    canvas.drawPath(flangePath, Paint()..color = baseColor.withValues(alpha: 0.95));

    // 6. Reflexo Especular Glossy Curvo
    final streakPath = Path()
      ..moveTo(cx - (domeRadius * 0.5), cy - (domeRadius * 1.1))
      ..cubicTo(
        cx - (domeRadius * 0.8), cy - (domeRadius * 0.4),
        cx - (domeRadius * 0.8), cy + (domeRadius * 0.1),
        cx - (domeRadius * 0.6), cy + (domeRadius * 0.3),
      );

    canvas.drawPath(
      streakPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );
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
    final cx = w / 2;
    final cy = h / 2;

    // 1. Sombra projetada da base do componente no workbench
    final shadowPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.10, h * 0.10, w * 0.80, h * 0.80),
        Radius.circular(w * 0.14),
      ));
    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0),
    );

    // 2. Terminais metálicos prateados estanhados (4 pinos laterais de bancada)
    final terminalPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE2E8F0), Color(0xFF94A3B8), Color(0xFF475569)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    // Pinos esquerdas / direitos
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.02, h * 0.24, w * 0.14, h * 0.12), const Radius.circular(2)), terminalPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.02, h * 0.64, w * 0.14, h * 0.12), const Radius.circular(2)), terminalPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.84, h * 0.24, w * 0.14, h * 0.12), const Radius.circular(2)), terminalPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.84, h * 0.64, w * 0.14, h * 0.12), const Radius.circular(2)), terminalPaint);

    // 3. Placa/Corpo de Metal Escovado (Chave Tactile Industrial)
    final baseRect = Rect.fromCenter(center: Offset(cx, cy), width: w * 0.74, height: h * 0.74);
    final baseRRect = RRect.fromRectAndRadius(baseRect, Radius.circular(w * 0.12));

    final baseShader = const LinearGradient(
      colors: [Color(0xFF475569), Color(0xFF334155), Color(0xFF1E293B), Color(0xFF0F172A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(baseRect);
    canvas.drawRRect(baseRRect, Paint()..shader = baseShader);

    // Moldura chanfrada de contorno
    canvas.drawRRect(
      baseRRect,
      Paint()
        ..color = const Color(0xFF94A3B8).withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Parafusos de fixação nos 4 cantos da placa
    final screwPaint = Paint()..color = const Color(0xFF94A3B8);
    canvas.drawCircle(Offset(baseRect.left + 4.5, baseRect.top + 4.5), 1.5, screwPaint);
    canvas.drawCircle(Offset(baseRect.right - 4.5, baseRect.top + 4.5), 1.5, screwPaint);
    canvas.drawCircle(Offset(baseRect.left + 4.5, baseRect.bottom - 4.5), 1.5, screwPaint);
    canvas.drawCircle(Offset(baseRect.right - 4.5, baseRect.bottom - 4.5), 1.5, screwPaint);

    // 4. LED Indicador de Estado (Canto Superior Direito da Placa)
    final ledPos = Offset(baseRect.right - 9.0, baseRect.top + 9.0);
    if (isPressed) {
      // Glow Neon Verde do LED quando o botão está PRESSIONADO (Circuito Fechado)
      canvas.drawCircle(
        ledPos,
        5.5,
        Paint()
          ..color = const Color(0xFF10B981).withValues(alpha: 0.65)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0),
      );
      canvas.drawCircle(ledPos, 2.5, Paint()..color = const Color(0xFF34D399));
      canvas.drawCircle(ledPos, 1.0, Paint()..color = Colors.white);
    } else {
      // LED Apagado quando o botão está SOLTO
      canvas.drawCircle(ledPos, 2.2, Paint()..color = const Color(0xFF1E293B));
      canvas.drawCircle(ledPos, 2.2, Paint()..color = const Color(0xFF475569)..style = PaintingStyle.stroke..strokeWidth = 0.8);
    }

    // 5. Bezel Cilíndrico Metálico (Colarinho / Guarnição do Botão)
    final collarCenter = Offset(cx, cy);
    final collarOuterRadius = w * 0.33;
    final collarInnerRadius = w * 0.28;

    // Glow verde no colarinho metálico quando pressionado
    if (isPressed) {
      canvas.drawCircle(
        collarCenter,
        collarOuterRadius + 4,
        Paint()
          ..color = const Color(0xFF10B981).withValues(alpha: 0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0),
      );
    }

    // Anel de metal cromado do colarinho
    final collarShader = const LinearGradient(
      colors: [Color(0xFFE2E8F0), Color(0xFFCBD5E1), Color(0xFF64748B), Color(0xFF334155)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromCircle(center: collarCenter, radius: collarOuterRadius));
    canvas.drawCircle(collarCenter, collarOuterRadius, Paint()..shader = collarShader);

    // Poço / Cavidade profunda e escura do soquete do botão
    final pitShader = const RadialGradient(
      colors: [Color(0xFF020617), Color(0xFF0F172A), Color(0xFF1E293B)],
      center: Alignment.center,
    ).createShader(Rect.fromCircle(center: collarCenter, radius: collarInnerRadius));
    canvas.drawCircle(collarCenter, collarInnerRadius, Paint()..shader = pitShader);

    // 6. Botão Atuador Cogumelo Vermelho (Actuator Cap)
    if (!isPressed) {
      // ======================================================
      // ESTADO SOLTO (UNPRESSED): Botão Proeminente e Elevado 3D
      // ======================================================
      final double capRadius = w * 0.31; // Domo grande e sobressalente!
      final capCenter = Offset(cx, cy - 3.5);

      // Parede cilíndrica lateral 3D do botão projetada para fora
      final sidePath = Path()
        ..addRect(Rect.fromLTRB(
          cx - capRadius,
          cy - 3.5,
          cx + capRadius,
          cy + 2.5,
        ));
      final sidePaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF991B1B), Color(0xFF7F1D1D), Color(0xFF450A0A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTRB(cx - capRadius, cy - 3.5, cx + capRadius, cy + 2.5));
      canvas.drawPath(sidePath, sidePaint);

      // Sombra projetada sob o domo elevado
      canvas.drawCircle(
        Offset(cx, cy + 2.0),
        capRadius,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
      );

      // Domo Vermelho vibrante superior
      final capShader = const RadialGradient(
        colors: [Color(0xFFF87171), Color(0xFFEF4444), Color(0xFFDC2626), Color(0xFF991B1B)],
        center: Alignment(-0.35, -0.35),
        radius: 0.85,
      ).createShader(Rect.fromCircle(center: capCenter, radius: capRadius));

      canvas.drawCircle(capCenter, capRadius, Paint()..shader = capShader);
      canvas.drawCircle(
        capCenter,
        capRadius,
        Paint()
          ..color = const Color(0xFF7F1D1D)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );

      // Brilho especular curvo em tom branco glossy
      final highlightPath = Path()
        ..addArc(
          Rect.fromCircle(center: capCenter.translate(-1.5, -1.5), radius: capRadius * 0.72),
          3.6,
          1.8,
        );
      canvas.drawPath(
        highlightPath,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.75)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round,
      );
    } else {
      // ======================================================
      // ESTADO PRESSIONADO (PRESSED): Botão Afundado e Recuado 3D
      // ======================================================
      final double capRadius = w * 0.20; // Reduzido drasticamente para 20% (visivelmente menor!)
      final capCenter = Offset(cx, cy + 3.0); // Deslocado para baixo dentro da cavidade

      // Sombra interna superior castada pela borda do colarinho sobre o botão afundado
      canvas.drawCircle(
        capCenter,
        capRadius + 2.0,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.8)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0),
      );

      // Botão Vermelho Afundado (Cor mais escura e plana de depressão)
      final capShader = const RadialGradient(
        colors: [Color(0xFFEF4444), Color(0xFFDC2626), Color(0xFF7F1D1D)],
        center: Alignment(0.0, 0.0),
        radius: 0.9,
      ).createShader(Rect.fromCircle(center: capCenter, radius: capRadius));

      canvas.drawCircle(capCenter, capRadius, Paint()..shader = capShader);
      canvas.drawCircle(
        capCenter,
        capRadius,
        Paint()
          ..color = const Color(0xFF450A0A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );

      // Anel tátil concêntrico indicando estado de pressão travada/ativa
      canvas.drawCircle(
        capCenter,
        capRadius * 0.5,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );

      // Ponto de luz no centro do botão pressionado
      canvas.drawCircle(
        capCenter,
        2.5,
        Paint()..color = const Color(0xFFFEF2F2),
      );
    }
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

    // Corpo da Bateria (Horizontal 9V)
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.24, h * 0.25, w * 0.66, h * 0.50),
      const Radius.circular(4),
    );

    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF3F3F46), Color(0xFF18181B)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(bodyRect.outerRect);

    canvas.drawRRect(bodyRect, bodyPaint);

    // Faixa Cobre Alcalina (Esquerda)
    final copperRect = Rect.fromLTWH(w * 0.24, h * 0.25, w * 0.20, h * 0.50);
    canvas.save();
    canvas.clipRRect(bodyRect);
    canvas.drawRect(
      copperRect,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFEA9E54), Color(0xFFB85F18)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(copperRect),
    );
    canvas.restore();

    canvas.drawRRect(bodyRect, Paint()..color = Colors.white24..style = PaintingStyle.stroke..strokeWidth = 1.0);

    // Terminais Prata + Conector Snap na Esquerda
    canvas.drawRect(Rect.fromLTWH(w * 0.16, h * 0.32, w * 0.08, h * 0.12), Paint()..color = const Color(0xFFCBD5E1));
    canvas.drawRect(Rect.fromLTWH(w * 0.16, h * 0.56, w * 0.08, h * 0.12), Paint()..color = const Color(0xFFCBD5E1));
    canvas.drawRect(Rect.fromLTWH(w * 0.12, h * 0.28, w * 0.04, h * 0.44), Paint()..color = const Color(0xFF18181B));

    // Rótulo 9V
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '9V',
        style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(w * 0.54, h * 0.38));
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
