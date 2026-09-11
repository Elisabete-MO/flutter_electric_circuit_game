import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Painter customizado do Estande 10 (Portão da Escola — Equipe Automação).
/// Renderiza:
/// - Circuito de Comando (5V DC, botoeira de pulso, enrolamento da bobina magnética)
/// - Relé eletromecânico transparente (núcleo de ferro, armadura móvel, contatos COM, NA e NF)
/// - Circuito de Potência (12V DC, contato de carga, motor DC com engrenagem giratória)
/// - Portão deslizante animado com gradil metálico e giroflex de alerta
/// - Fluxo de elétrons animados nas duas malhas independentes
/// - Modo esquemático técnico padronizado
class PortaoEscolaPainter extends CustomPainter {
  final int missionIndex;
  final double animValue;
  final bool usePhysicalStyle;

  // Estados dos componentes
  final bool isCommandPressed;
  final bool isCoilEnergized;
  final bool isContactClosed;
  final bool isMotorRunning;
  final double gatePositionPercent; // 0.0 (fechado) a 100.0 (aberto)
  final bool isLightSignalOn;
  final bool isEmergencyStopActive;

  PortaoEscolaPainter({
    required this.missionIndex,
    required this.animValue,
    required this.usePhysicalStyle,
    this.isCommandPressed = false,
    this.isCoilEnergized = false,
    this.isContactClosed = false,
    this.isMotorRunning = false,
    this.gatePositionPercent = 0.0,
    this.isLightSignalOn = false,
    this.isEmergencyStopActive = false,
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

    // 1. Painel de Comando (Lado Esquerdo)
    final cmdRect = Rect.fromLTWH(w * 0.04, h * 0.20, w * 0.28, h * 0.68);
    _drawCommandPanel(canvas, cmdRect);

    // 2. Relé Central Transparente
    final relayRect = Rect.fromLTWH(w * 0.36, h * 0.24, w * 0.26, h * 0.60);
    _drawRelayComponent(canvas, relayRect);

    // 3. Portão da Escola & Motor (Lado Direito)
    final gateRect = Rect.fromLTWH(w * 0.66, h * 0.20, w * 0.30, h * 0.68);
    _drawGateAndMotor(canvas, gateRect);

    // 4. Cabos e Fiação
    _drawWiringAndJumpers(canvas, cmdRect, relayRect, gateRect);
  }

  void _drawCommandPanel(Canvas canvas, Rect rect) {
    final bgPaint = Paint()..color = const Color(0xFF1E293B);
    final borderPaint = Paint()
      ..color = const Color(0xFF475569)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(16));
    canvas.drawRRect(rrect, bgPaint);
    canvas.drawRRect(rrect, borderPaint);

    // Título
    final tp = TextPainter(
      text: TextSpan(
        text: 'COMANDO (5V DC)',
        style: GoogleFonts.rajdhani(
          color: const Color(0xFFF59E0B),
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(rect.left + 14, rect.top + 12));

    // Fonte 5V DC
    final psuRect = Rect.fromLTWH(rect.left + 16, rect.top + 40, rect.width - 32, 44);
    canvas.drawRRect(
      RRect.fromRectAndRadius(psuRect, const Radius.circular(8)),
      Paint()..color = const Color(0xFF0F172A),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(psuRect, const Radius.circular(8)),
      Paint()
        ..color = const Color(0xFFF59E0B)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );
    final tpPsu = TextPainter(
      text: TextSpan(
        text: 'FONTE LÓGICA 5V',
        style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tpPsu.paint(canvas, Offset(psuRect.left + 12, psuRect.top + 14));

    // Botoeira Industrial (Verde - Abrir)
    final btnCenter = Offset(rect.center.dx, rect.top + rect.height * 0.52);
    final btnBgPaint = Paint()
      ..color = isCommandPressed ? const Color(0xFF15803D) : const Color(0xFF22C55E);
    canvas.drawCircle(btnCenter, 24, btnBgPaint);
    canvas.drawCircle(
      btnCenter,
      28,
      Paint()
        ..color = Colors.white24
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    final tpBtn = TextPainter(
      text: TextSpan(
        text: isCommandPressed ? 'ACIONADO' : 'BOTÃO NA',
        style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tpBtn.paint(canvas, Offset(btnCenter.dx - tpBtn.width / 2, btnCenter.dy + 34));

    // Botão de Emergência (Vermelho - NF)
    final emCenter = Offset(rect.center.dx, rect.top + rect.height * 0.82);
    canvas.drawCircle(
      emCenter,
      18,
      Paint()..color = isEmergencyStopActive ? const Color(0xFFB91C1C) : const Color(0xFFEF4444),
    );
    final tpEm = TextPainter(
      text: TextSpan(
        text: 'EMERGÊNCIA (NF)',
        style: GoogleFonts.rajdhani(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tpEm.paint(canvas, Offset(emCenter.dx - tpEm.width / 2, emCenter.dy + 22));
  }

  void _drawRelayComponent(Canvas canvas, Rect rect) {
    // Caixa transparente do relé
    final boxPaint = Paint()
      ..color = const Color(0xFF0F172A).withValues(alpha: 0.90)
      ..style = PaintingStyle.fill;
    final framePaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(14));
    canvas.drawRRect(rrect, boxPaint);
    canvas.drawRRect(rrect, framePaint);

    // Rótulo do Relé
    final tp = TextPainter(
      text: TextSpan(
        text: 'RELÉ DE COMANDO',
        style: GoogleFonts.rajdhani(
          color: const Color(0xFF38BDF8),
          fontWeight: FontWeight.bold,
          fontSize: 11,
          letterSpacing: 1.1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(rect.left + 12, rect.top + 10));

    // Núcleo e Bobina de Cobre (Lado Esquerdo do Relé)
    final coilX = rect.left + rect.width * 0.32;
    final coilY = rect.top + rect.height * 0.45;
    final coreRect = Rect.fromCenter(center: Offset(coilX, coilY), width: 18, height: 44);

    // Núcleo de Ferro
    canvas.drawRect(coreRect, Paint()..color = const Color(0xFF64748B));

    // Enrolamento de cobre
    final wirePaint = Paint()
      ..color = const Color(0xFFD97706)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    for (int i = -3; i <= 3; i++) {
      final y = coilY + i * 5.5;
      canvas.drawLine(Offset(coilX - 12, y), Offset(coilX + 12, y), wirePaint);
    }

    // Linhas de Campo Magnético (quando bobina energizada)
    if (isCoilEnergized) {
      final magPaint = Paint()
        ..color = const Color(0xFF38BDF8).withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      for (int i = 1; i <= 3; i++) {
        final oval = Rect.fromCenter(center: Offset(coilX, coilY), width: 32.0 + i * 14, height: 54.0 + i * 12);
        canvas.drawOval(oval, magPaint);
      }
    }

    // Armadura Móvel e Contatos Elétricos (Lado Direito do Relé)
    final contactX = rect.left + rect.width * 0.72;
    final armaturePivot = Offset(contactX, rect.bottom - 40);

    // Terminal COM
    canvas.drawCircle(armaturePivot, 5, Paint()..color = const Color(0xFFF59E0B));

    // Posição da armadura (atraída magneticamente para a esquerda ou em repouso)
    final armatureTarget = isContactClosed
        ? Offset(contactX - 14, rect.top + rect.height * 0.38) // Contato NA fechado
        : Offset(contactX + 6, rect.top + rect.height * 0.38); // Em repouso (NF)

    final armPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(armaturePivot, armatureTarget, armPaint);

    // Terminal NA (Normalmente Aberto)
    final naPos = Offset(contactX - 14, rect.top + rect.height * 0.36);
    canvas.drawCircle(
      naPos,
      4.5,
      Paint()..color = isContactClosed ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
    );

    // Rótulos dos Terminais
    final tpNA = TextPainter(
      text: TextSpan(
        text: 'NA',
        style: GoogleFonts.rajdhani(
          color: isContactClosed ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tpNA.paint(canvas, Offset(naPos.dx - 18, naPos.dy - 6));

    final tpCOM = TextPainter(
      text: TextSpan(
        text: 'COM',
        style: GoogleFonts.rajdhani(color: const Color(0xFFF59E0B), fontSize: 10, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tpCOM.paint(canvas, Offset(armaturePivot.dx - 12, armaturePivot.dy + 8));
  }

  void _drawGateAndMotor(Canvas canvas, Rect rect) {
    // Moldura do Estande / Portão da Escola
    final bgPaint = Paint()..color = const Color(0xFF1E293B);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(16));
    canvas.drawRRect(rrect, bgPaint);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0xFF475569)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke,
    );

    // Giroflex / Sinalizador Amarelo no topo
    final beaconX = rect.center.dx;
    final beaconY = rect.top + 28;
    final beaconPaint = Paint()
      ..color = (isLightSignalOn || isMotorRunning)
          ? const Color(0xFFFBBF24)
          : const Color(0xFF475569);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(beaconX, beaconY), width: 22, height: 16), const Radius.circular(6)),
      beaconPaint,
    );

    // Feixe luminoso piscante do giroflex
    if (isLightSignalOn || isMotorRunning) {
      final glowPaint = Paint()
        ..color = const Color(0xFFFBBF24).withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(Offset(beaconX, beaconY), 24, glowPaint);
    }

    // Motor DC Redutor com Engrenagem
    final motorY = rect.top + rect.height * 0.40;
    final motorRect = Rect.fromCenter(center: Offset(rect.left + 40, motorY), width: 44, height: 38);
    canvas.drawRRect(
      RRect.fromRectAndRadius(motorRect, const Radius.circular(8)),
      Paint()..color = const Color(0xFF0F172A),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(motorRect, const Radius.circular(8)),
      Paint()
        ..color = const Color(0xFF10B981)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );

    // Engrenagem giratória do motor
    final gearCenter = Offset(rect.left + 72, motorY);
    _drawRotatingGear(canvas, gearCenter, isMotorRunning ? animValue * 2 * math.pi : 0.0);

    // Portão Deslizante da Escola
    final trackY = motorY + 12;
    final gateWidth = rect.width * 0.48;
    final gateHeight = rect.height * 0.42;

    // Deslocamento horizontal baseado em gatePositionPercent
    final slideOffset = (gatePositionPercent / 100.0) * (rect.width * 0.32);
    final gateLeft = (rect.left + 74 + slideOffset).clamp(rect.left, rect.right - 20);

    final gateRect = Rect.fromLTWH(gateLeft, trackY - gateHeight + 20, gateWidth, gateHeight);

    // Trilho inferior
    canvas.drawLine(
      Offset(rect.left + 60, trackY + 22),
      Offset(rect.right - 10, trackY + 22),
      Paint()
        ..color = const Color(0xFF94A3B8)
        ..strokeWidth = 3.5,
    );

    // Estrutura do Portão (Gradil Cinza Metálico)
    final framePaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    canvas.drawRect(gateRect, framePaint);

    // Barras verticais do gradil
    final barCount = 5;
    for (int i = 1; i <= barCount; i++) {
      final x = gateRect.left + i * (gateRect.width / (barCount + 1));
      canvas.drawLine(Offset(x, gateRect.top), Offset(x, gateRect.bottom), framePaint..strokeWidth = 2.0);
    }

    // Texto de status do portão
    final tpGate = TextPainter(
      text: TextSpan(
        text: 'PORTÃO: ${gatePositionPercent.toStringAsFixed(0)}% ABERTO',
        style: GoogleFonts.rajdhani(
          color: isMotorRunning ? const Color(0xFF10B981) : Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tpGate.paint(canvas, Offset(rect.left + 16, rect.bottom - 24));
  }

  void _drawRotatingGear(Canvas canvas, Offset center, double angle) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final gearPaint = Paint()..color = const Color(0xFF94A3B8);
    canvas.drawCircle(Offset.zero, 12, gearPaint);

    final toothPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.square;
    for (int i = 0; i < 6; i++) {
      final a = i * (math.pi / 3);
      canvas.drawLine(Offset(math.cos(a) * 10, math.sin(a) * 10), Offset(math.cos(a) * 16, math.sin(a) * 16), toothPaint);
    }

    canvas.drawCircle(Offset.zero, 4, Paint()..color = const Color(0xFF0F172A));
    canvas.restore();
  }

  void _drawWiringAndJumpers(Canvas canvas, Rect cmd, Rect relay, Rect gate) {
    final wirePaint = Paint()
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final electronPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;

    // Fio de Comando Positivo (Laranja/Amarelo): Comando -> Bobina
    final pCmd1 = Offset(cmd.right - 10, cmd.top + 60);
    final pRelayBobine = Offset(relay.left + 20, relay.top + 50);

    final pathCmd = Path()
      ..moveTo(pCmd1.dx, pCmd1.dy)
      ..quadraticBezierTo((pCmd1.dx + pRelayBobine.dx) / 2, pCmd1.dy - 15, pRelayBobine.dx, pRelayBobine.dy);

    wirePaint.color = const Color(0xFFF59E0B);
    canvas.drawPath(pathCmd, wirePaint);

    // Fio de Retorno de Comando: Bobina -> Comando
    final pRelayRet = Offset(relay.left + 20, relay.top + 70);
    final pCmd2 = Offset(cmd.right - 10, cmd.bottom - 60);
    final pathCmdRet = Path()
      ..moveTo(pRelayRet.dx, pRelayRet.dy)
      ..quadraticBezierTo((pRelayRet.dx + pCmd2.dx) / 2, pCmd2.dy + 15, pCmd2.dx, pCmd2.dy);
    wirePaint.color = const Color(0xFF334155);
    canvas.drawPath(pathCmdRet, wirePaint);

    // Elétrons de Comando
    if (isCoilEnergized) {
      final metrics = pathCmd.computeMetrics().toList();
      if (metrics.isNotEmpty) {
        final metric = metrics.first;
        for (int i = 0; i < 3; i++) {
          final t = (animValue + i * 0.33) % 1.0;
          final tangent = metric.getTangentForOffset(metric.length * t);
          if (tangent != null) {
            canvas.drawCircle(tangent.position, 3.5, electronPaint);
          }
        }
      }
    }

    // Fio de Potência: Contato NA -> Motor/Giroflex
    final pRelayNA = Offset(relay.right - 10, relay.top + 50);
    final pMotor = Offset(gate.left + 20, gate.top + 60);
    final pathLoad = Path()
      ..moveTo(pRelayNA.dx, pRelayNA.dy)
      ..quadraticBezierTo((pRelayNA.dx + pMotor.dx) / 2, pRelayNA.dy - 10, pMotor.dx, pMotor.dy);

    wirePaint.color = isContactClosed ? const Color(0xFF10B981) : const Color(0xFF64748B);
    canvas.drawPath(pathLoad, wirePaint);

    // Elétrons de Carga
    if (isContactClosed && isMotorRunning) {
      final metrics = pathLoad.computeMetrics().toList();
      if (metrics.isNotEmpty) {
        final metric = metrics.first;
        for (int i = 0; i < 3; i++) {
          final t = (animValue + i * 0.33) % 1.0;
          final tangent = metric.getTangentForOffset(metric.length * t);
          if (tangent != null) {
            canvas.drawCircle(tangent.position, 4.0, Paint()..color = const Color(0xFF10B981));
          }
        }
      }
    }
  }

  // =========================================================================
  // MODO ESQUEMÁTICO TÉCNICO
  // =========================================================================

  void _paintSchematic(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final wirePaint = Paint()
      ..color = const Color(0xFF475569)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    // Malha 1: Comando (Esquerda)
    final cmdRect = Rect.fromLTWH(w * 0.12, h * 0.25, w * 0.32, h * 0.50);
    canvas.drawRect(cmdRect, wirePaint);

    // Malha 2: Carga (Direita)
    final loadRect = Rect.fromLTWH(w * 0.56, h * 0.25, w * 0.32, h * 0.50);
    canvas.drawRect(loadRect, wirePaint);

    // Linha tracejada de isolamento galvânico entre comando e carga
    final isoPaint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.5)
      ..strokeWidth = 2.0;
    for (double y = h * 0.20; y <= h * 0.80; y += 12) {
      canvas.drawLine(Offset(w * 0.49, y), Offset(w * 0.49, y + 6), isoPaint);
    }

    // Símbolo da Bobina (Malha 1, Lado Direito da Malha)
    _drawSchematicCoil(canvas, Offset(cmdRect.right, cmdRect.center.dy));

    // Símbolo da Bateria 5V (Malha 1, Lado Esquerdo)
    _drawSchematicSource(canvas, Offset(cmdRect.left, cmdRect.center.dy), '5V DC');

    // Símbolo do Contato NA (Malha 2, Lado Esquerdo da Malha)
    _drawSchematicSwitch(canvas, Offset(loadRect.left, loadRect.center.dy), isContactClosed);

    // Símbolo do Motor DC (Malha 2, Lado Direito)
    _drawSchematicMotor(canvas, Offset(loadRect.right, loadRect.center.dy));

    // Rótulos das seções
    final tp1 = TextPainter(
      text: TextSpan(
        text: 'CIRCUITO DE COMANDO (BAIXA TENSÃO)',
        style: GoogleFonts.rajdhani(color: const Color(0xFFF59E0B), fontSize: 11, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp1.paint(canvas, Offset(cmdRect.left, cmdRect.top - 20));

    final tp2 = TextPainter(
      text: TextSpan(
        text: 'CIRCUITO DE CARGA / ATUAÇÃO (POTÊNCIA)',
        style: GoogleFonts.rajdhani(color: const Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp2.paint(canvas, Offset(loadRect.left, loadRect.top - 20));
  }

  void _drawSchematicCoil(Canvas canvas, Offset center) {
    final bg = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(Rect.fromCenter(center: center, width: 26, height: 44), bg);

    final coilPaint = Paint()
      ..color = isCoilEnergized ? const Color(0xFFF59E0B) : Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = -2; i <= 2; i++) {
      canvas.drawArc(
        Rect.fromCenter(center: Offset(center.dx, center.dy + i * 8), width: 14, height: 10),
        -math.pi / 2,
        math.pi,
        false,
        coilPaint,
      );
    }
  }

  void _drawSchematicSwitch(Canvas canvas, Offset center, bool isClosed) {
    final bg = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(Rect.fromCenter(center: center, width: 26, height: 44), bg);

    final dotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(center.dx, center.dy - 12), 3, dotPaint);
    canvas.drawCircle(Offset(center.dx, center.dy + 12), 3, dotPaint);

    final armEnd = isClosed ? Offset(center.dx, center.dy - 12) : Offset(center.dx + 12, center.dy - 10);
    canvas.drawLine(
      Offset(center.dx, center.dy + 12),
      armEnd,
      Paint()
        ..color = isClosed ? const Color(0xFF10B981) : Colors.white
        ..strokeWidth = 2.5,
    );
  }

  void _drawSchematicMotor(Canvas canvas, Offset center) {
    final bg = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(Rect.fromCenter(center: center, width: 34, height: 44), bg);

    final mPaint = Paint()
      ..color = isMotorRunning ? const Color(0xFF10B981) : Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, 14, mPaint);

    final tp = TextPainter(
      text: TextSpan(
        text: 'M',
        style: GoogleFonts.rajdhani(
          color: isMotorRunning ? const Color(0xFF10B981) : Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  void _drawSchematicSource(Canvas canvas, Offset center, String label) {
    final bg = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(Rect.fromCenter(center: center, width: 24, height: 40), bg);

    final p = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5;
    canvas.drawLine(Offset(center.dx - 12, center.dy - 6), Offset(center.dx + 12, center.dy - 6), p);
    canvas.drawLine(Offset(center.dx - 6, center.dy + 6), Offset(center.dx + 6, center.dy + 6), p..strokeWidth = 4.0);

    final tp = TextPainter(
      text: TextSpan(text: label, style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width - 16, center.dy - 6));
  }

  @override
  bool shouldRepaint(covariant PortaoEscolaPainter oldDelegate) {
    return oldDelegate.animValue != animValue ||
        oldDelegate.usePhysicalStyle != usePhysicalStyle ||
        oldDelegate.isCommandPressed != isCommandPressed ||
        oldDelegate.isCoilEnergized != isCoilEnergized ||
        oldDelegate.isContactClosed != isContactClosed ||
        oldDelegate.isMotorRunning != isMotorRunning ||
        oldDelegate.gatePositionPercent != gatePositionPercent ||
        oldDelegate.isLightSignalOn != isLightSignalOn ||
        oldDelegate.isEmergencyStopActive != isEmergencyStopActive;
  }
}
