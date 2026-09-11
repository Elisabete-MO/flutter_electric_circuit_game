import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/first_step_component.dart';
import '../../../state/circuit_undo_redo_controller.dart';
import '../../../widgets/circuit_symbol_painter.dart';
import '../../../widgets/component_physical_painter.dart';
import '../../../widgets/component_vector_painters.dart';
import '../../../widgets/workbench_components.dart';

/// Modos de operação da chave seletora do Multímetro Digital
enum MultimeterMode {
  off('OFF', 'Desligado', ''),
  voltageDc('V⎓', 'Tensão Contínua (DC)', 'V'),
  currentMa('mA⎓', 'Corrente (mA DC)', 'mA'),
  resistance('Ω', 'Resistência (Ohm)', 'Ω'),
  continuity('🔊', 'Continuidade (Buzzer)', 'BEEP');

  final String shortLabel;
  final String label;
  final String unit;

  const MultimeterMode(this.shortLabel, this.label, this.unit);
}

/// Status do circuito (aberto / fechado) para o Estande 07
class MedeTestaStatusCard extends StatelessWidget {
  final bool isClosed;

  const MedeTestaStatusCard({super.key, required this.isClosed});

  @override
  Widget build(BuildContext context) {
    final statusColor =
        isClosed ? const Color(0xFF10B981) : const Color(0xFF64748B);
    final statusText =
        isClosed ? 'CIRCUITO FECHADO (ON)' : 'CIRCUITO ABERTO (OFF)';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              boxShadow: [
                if (isClosed)
                  BoxShadow(
                    color: statusColor.withValues(alpha: 0.6),
                    blurRadius: 6,
                    spreadRadius: 1.5,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: GoogleFonts.rajdhani(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Telemetria de bancada
class MedeTestaTelemetryCard extends StatelessWidget {
  final double voltage;
  final double currentMa;
  final bool isClosed;

  const MedeTestaTelemetryCard({
    super.key,
    required this.voltage,
    required this.currentMa,
    required this.isClosed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'TENSÃO: ',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
          Text(
            '${voltage.toStringAsFixed(1)}V',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF0284C7),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '| CORRENTE: ',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
          Text(
            '${currentMa.toStringAsFixed(1)}mA',
            style: GoogleFonts.rajdhani(
              color: isClosed
                  ? const Color(0xFF10B981)
                  : const Color(0xFF94A3B8),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Botões de Desfazer / Refazer
class MedeTestaUndoRedoButtons extends StatelessWidget {
  final CircuitUndoRedoController controller;
  final VoidCallback onUndo;
  final VoidCallback onRedo;

  const MedeTestaUndoRedoButtons({
    super.key,
    required this.controller,
    required this.onUndo,
    required this.onRedo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.undo_rounded, size: 20),
            tooltip: 'Desfazer ação',
            color: controller.canUndo
                ? const Color(0xFF0F172A)
                : const Color(0xFFCBD5E1),
            onPressed: controller.canUndo ? onUndo : null,
          ),
          IconButton(
            icon: const Icon(Icons.redo_rounded, size: 20),
            tooltip: 'Refazer ação',
            color: controller.canRedo
                ? const Color(0xFF0F172A)
                : const Color(0xFFCBD5E1),
            onPressed: controller.canRedo ? onRedo : null,
          ),
        ],
      ),
    );
  }
}

/// ----------------------------------------------------------------------------
/// BATERIA DE 9V ULTRA-REALISTA DE BANCADA
/// ----------------------------------------------------------------------------
class Realistic9VBatteryWidget extends StatelessWidget {
  final double width;
  final double height;
  final bool isRedProbeHoveringPos;
  final bool isBlackProbeHoveringPos;
  final bool isRedProbeHoveringNeg;
  final bool isBlackProbeHoveringNeg;
  final bool hasRedProbeConnectedPos;
  final bool hasBlackProbeConnectedPos;
  final bool hasRedProbeConnectedNeg;
  final bool hasBlackProbeConnectedNeg;
  final VoidCallback? onTapPositive;
  final VoidCallback? onTapNegative;

  const Realistic9VBatteryWidget({
    super.key,
    this.width = 110.0,
    this.height = 160.0,
    this.isRedProbeHoveringPos = false,
    this.isBlackProbeHoveringPos = false,
    this.isRedProbeHoveringNeg = false,
    this.isBlackProbeHoveringNeg = false,
    this.hasRedProbeConnectedPos = false,
    this.hasBlackProbeConnectedPos = false,
    this.hasRedProbeConnectedNeg = false,
    this.hasBlackProbeConnectedNeg = false,
    this.onTapPositive,
    this.onTapNegative,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _Realistic9VBatteryPainter(
          hasRedPos: hasRedProbeConnectedPos || isRedProbeHoveringPos,
          hasBlackPos: hasBlackProbeConnectedPos || isBlackProbeHoveringPos,
          hasRedNeg: hasRedProbeConnectedNeg || isRedProbeHoveringNeg,
          hasBlackNeg: hasBlackProbeConnectedNeg || isBlackProbeHoveringNeg,
        ),
      ),
    );
  }
}

class _Realistic9VBatteryPainter extends CustomPainter {
  final bool hasRedPos;
  final bool hasBlackPos;
  final bool hasRedNeg;
  final bool hasBlackNeg;

  _Realistic9VBatteryPainter({
    required this.hasRedPos,
    required this.hasBlackPos,
    required this.hasRedNeg,
    required this.hasBlackNeg,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sombra projetada da bateria na bancada
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.32)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(6, 26, w - 12, h - 28),
        const Radius.circular(10),
      ),
      shadowPaint,
    );

    // 1. Corpo principal da bateria (retângulo 9V clássico)
    final bodyRect = Rect.fromLTWH(4, 22, w - 8, h - 24);
    final bodyRRect = RRect.fromRectAndRadius(bodyRect, const Radius.circular(8.0));

    // Degradê do corpo (grafite/aço escovado)
    final bodyShader = const LinearGradient(
      colors: [Color(0xFF334155), Color(0xFF1E293B), Color(0xFF0F172A), Color(0xFF020617)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(bodyRect);
    canvas.drawRRect(bodyRRect, Paint()..shader = bodyShader);

    // 2. Faixa de cobre/ouro superior (estilo Duracell/Industrial)
    final topBandRect = Rect.fromLTWH(4, 22, w - 8, 36);
    final topBandShader = const LinearGradient(
      colors: [
        Color(0xFFF59E0B),
        Color(0xFFD97706),
        Color(0xFFB45309),
        Color(0xFF92400E),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(topBandRect);

    canvas.save();
    canvas.clipRRect(bodyRRect);
    canvas.drawRect(topBandRect, Paint()..shader = topBandShader);

    // Linha de brilho metálico na faixa de cobre
    final highlightPaint = Paint()
      ..color = const Color(0xFFFDE68A).withValues(alpha: 0.7)
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(topBandRect.left, topBandRect.top + 2),
      Offset(topBandRect.right, topBandRect.top + 2),
      highlightPaint,
    );
    canvas.restore();

    // 3. Moldura chanfrada de contorno
    canvas.drawRRect(
      bodyRRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.18)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke,
    );

    // 4. Inscrições tipográficas da Bateria 9V
    final voltStrPainter = TextPainter(
      text: const TextSpan(
        text: '9V',
        style: TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
          fontFamily: 'sans-serif',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    voltStrPainter.paint(canvas, Offset(w / 2 - voltStrPainter.width / 2, 70));

    final brandPainter = TextPainter(
      text: const TextSpan(
        text: 'ALKALINE HEAVY DUTY\n6LR61 • 9 VOLTS DC',
        style: TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 8,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          height: 1.4,
          fontFamily: 'sans-serif',
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    brandPainter.paint(canvas, Offset(w / 2 - brandPainter.width / 2, 105));

    // Logo EletroLab discreto na base
    final bottomLogo = TextPainter(
      text: const TextSpan(
        text: '⚡ ELETRO-LAB',
        style: TextStyle(
          color: Color(0xFFF59E0B),
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
          fontFamily: 'sans-serif',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    bottomLogo.paint(canvas, Offset(w / 2 - bottomLogo.width / 2, 138));

    // 5. Terminais Metálicos Snap em Perfil 3D no Topo 
    final cxLeft = w * 0.31;
    final cxRight = w * 0.69;
    const baseTop = 22.0;

    // Terminal Esquerdo (+): Bloco inferior largo + pescoço superior estreito
    _drawProfileTerminalLeft(canvas, cxLeft, baseTop, hasRedPos || hasBlackPos);

    // Terminal Direito (-): Pescoço inferior estreito + cabeça superior larga
    _drawProfileTerminalRight(canvas, cxRight, baseTop, hasRedNeg || hasBlackNeg);

    // Barra/Conector horizontal superior escuro no topo dos terminais
    final topBarRect = Rect.fromLTWH(cxLeft - 15, 3.2, (cxRight + 15) - (cxLeft - 15), 3.0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(topBarRect, const Radius.circular(1.5)),
      Paint()..color = const Color(0xFF0F172A),
    );
    canvas.drawLine(
      Offset(topBarRect.left, topBarRect.top),
      Offset(topBarRect.right, topBarRect.top),
      Paint()
        ..color = const Color(0xFF475569)
        ..strokeWidth = 0.8,
    );

    // Rótulos "+" e "-" no topo da bateria
    final plusPainter = TextPainter(
      text: const TextSpan(
        text: '+',
        style: TextStyle(
          color: Color(0xFFEF4444),
          fontSize: 14,
          fontWeight: FontWeight.w900,
          fontFamily: 'sans-serif',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    plusPainter.paint(canvas, Offset(cxLeft - plusPainter.width / 2, 28));

    final minusPainter = TextPainter(
      text: const TextSpan(
        text: '—',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          fontFamily: 'sans-serif',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    minusPainter.paint(canvas, Offset(cxRight - minusPainter.width / 2, 28));
  }

  void _drawProfileTerminalLeft(Canvas canvas, double cx, double baseTop, bool isConnected) {
    // Terminal Esquerdo: Bloco inferior largo (w=26, h=10) + Pescoço superior estreito (w=18, h=6)
    const topY = 6.2;
    const midY = 12.2;

    if (isConnected) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, (topY + baseTop) / 2), width: 34, height: 22),
          const Radius.circular(4),
        ),
        Paint()
          ..color = const Color(0xFFEF4444).withValues(alpha: 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }

    // 1. Bloco inferior largo (Light silver)
    final bottomRect = Rect.fromLTWH(cx - 13, midY, 26, baseTop - midY);
    final bottomShader = const LinearGradient(
      colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0), Color(0xFFCBD5E1), Color(0xFF94A3B8)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(bottomRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bottomRect, const Radius.circular(1.5)),
      Paint()..shader = bottomShader,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bottomRect, const Radius.circular(1.5)),
      Paint()
        ..color = const Color(0xFF64748B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // 2. Pescoço superior mais estreito (Medium silver)
    final topRect = Rect.fromLTWH(cx - 9, topY, 18, midY - topY);
    final topShader = const LinearGradient(
      colors: [Color(0xFFE2E8F0), Color(0xFF94A3B8), Color(0xFF64748B)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(topRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(topRect, const Radius.circular(1.5)),
      Paint()..shader = topShader,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(topRect, const Radius.circular(1.5)),
      Paint()
        ..color = const Color(0xFF475569)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // 3. Brilho metálico no topo
    canvas.drawLine(
      Offset(cx - 9, topY),
      Offset(cx + 9, topY),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 1.0,
    );
  }

  void _drawProfileTerminalRight(Canvas canvas, double cx, double baseTop, bool isConnected) {
    // Terminal Direito: Pescoço inferior estreito (w=16, h=5) + Cabeça superior larga (w=26, h=11)
    const topY = 6.2;
    const midY = 17.2;

    if (isConnected) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, (topY + baseTop) / 2), width: 34, height: 22),
          const Radius.circular(4),
        ),
        Paint()
          ..color = const Color(0xFF38BDF8).withValues(alpha: 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }

    // 1. Pescoço inferior estreito (Light silver)
    final neckRect = Rect.fromLTWH(cx - 8, midY, 16, baseTop - midY);
    final neckShader = const LinearGradient(
      colors: [Color(0xFFF8FAFC), Color(0xFFCBD5E1), Color(0xFF94A3B8)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(neckRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(neckRect, const Radius.circular(1)),
      Paint()..shader = neckShader,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(neckRect, const Radius.circular(1)),
      Paint()
        ..color = const Color(0xFF64748B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // 2. Cabeça superior larga (Medium/Dark steel)
    final capRect = Rect.fromLTWH(cx - 13, topY, 26, midY - topY);
    final capShader = const LinearGradient(
      colors: [Color(0xFFCBD5E1), Color(0xFF94A3B8), Color(0xFF64748B), Color(0xFF475569)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(capRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(capRect, const Radius.circular(1.5)),
      Paint()..shader = capShader,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(capRect, const Radius.circular(1.5)),
      Paint()
        ..color = const Color(0xFF334155)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // 3. Brilho metálico no topo
    canvas.drawLine(
      Offset(cx - 13, topY),
      Offset(cx + 13, topY),
      Paint()
        ..color = const Color(0xFFE2E8F0)
        ..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(covariant _Realistic9VBatteryPainter oldDelegate) =>
      oldDelegate.hasRedPos != hasRedPos ||
      oldDelegate.hasBlackPos != hasBlackPos ||
      oldDelegate.hasRedNeg != hasRedNeg ||
      oldDelegate.hasBlackNeg != hasBlackNeg;
}

/// ----------------------------------------------------------------------------
/// CANETA DE PONTA DE PROVA REALISTA E ARRASTÁVEL (PROBE PEN)
/// ----------------------------------------------------------------------------
class ProbePenWidget extends StatelessWidget {
  final bool isRed;
  final bool isConnected;
  final bool isDragging;
  final bool pointingDown;

  const ProbePenWidget({
    super.key,
    required this.isRed,
    this.isConnected = false,
    this.isDragging = false,
    this.pointingDown = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 96,
      child: CustomPaint(
        painter: _ProbePenPainter(
          isRed: isRed,
          isConnected: isConnected,
          isDragging: isDragging,
          pointingDown: pointingDown,
        ),
      ),
    );
  }
}

class _ProbePenPainter extends CustomPainter {
  final bool isRed;
  final bool isConnected;
  final bool isDragging;
  final bool pointingDown;

  _ProbePenPainter({
    required this.isRed,
    required this.isConnected,
    required this.isDragging,
    this.pointingDown = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (pointingDown) {
      canvas.save();
      canvas.translate(0, size.height);
      canvas.scale(1, -1);
    }

    final cx = size.width / 2;
    final primaryColor = isRed ? const Color(0xFFDC2626) : const Color(0xFF0F172A);
    final darkAccent = isRed ? const Color(0xFF991B1B) : const Color(0xFF020617);
    final lightAccent = isRed ? const Color(0xFFEF4444) : const Color(0xFF334155);

    // Sombra projetada sob a caneta
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: isDragging ? 0.45 : 0.25)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, isDragging ? 8 : 4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 5 + (isDragging ? 6 : 2), 18 + (isDragging ? 8 : 3), 10, 72),
        const Radius.circular(4),
      ),
      shadowPaint,
    );

    // 1. Agulha Metálica Condutora (Ponta de Aço Inoxidável no topo)
    // A ponta de contato é exatamente no ponto (cx, 0)!
    final needlePath = Path()
      ..moveTo(cx, 0)
      ..lineTo(cx - 1.6, 18)
      ..lineTo(cx + 1.6, 18)
      ..close();

    final needleShader = const LinearGradient(
      colors: [Color(0xFFFFFFFF), Color(0xFFE2E8F0), Color(0xFF94A3B8)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(Rect.fromLTWH(cx - 2, 0, 4, 18));
    canvas.drawPath(needlePath, Paint()..shader = needleShader);

    // Brilho na ponta metálica
    if (isConnected) {
      canvas.drawCircle(
        Offset(cx, 0),
        5.0,
        Paint()
          ..color = (isRed ? const Color(0xFFFDE047) : const Color(0xFF38BDF8))
              .withValues(alpha: 0.8)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }

    // 2. Colar de Proteção para os Dedos (Finger Guard)
    final collarRect = Rect.fromLTWH(cx - 11, 18, 22, 6);
    final collarRRect = RRect.fromRectAndRadius(collarRect, const Radius.circular(3));
    canvas.drawRRect(collarRRect, Paint()..color = darkAccent);

    // 3. Corpo Anatômico da Caneta de Prova
    final bodyRect = Rect.fromLTWH(cx - 6.5, 24, 13, 52);
    final bodyRRect = RRect.fromRectAndRadius(bodyRect, const Radius.circular(3));

    final bodyShader = LinearGradient(
      colors: [lightAccent, primaryColor, darkAccent],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(bodyRect);
    canvas.drawRRect(bodyRRect, Paint()..shader = bodyShader);

    // Ranhuras horizontais de pegada de borracha (Traction Ribs)
    final ribPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.28)
      ..strokeWidth = 1.6;
    for (double y = 30; y <= 62; y += 4.5) {
      canvas.drawLine(Offset(cx - 5.5, y), Offset(cx + 5.5, y), ribPaint);
    }

    // 4. Luva Cônica de Alívio de Tensão no final (onde o cabo entra)
    final bootPath = Path()
      ..moveTo(cx - 5.0, 76)
      ..lineTo(cx + 5.0, 76)
      ..lineTo(cx + 3.0, 92)
      ..lineTo(cx - 3.0, 92)
      ..close();
    canvas.drawPath(bootPath, Paint()..color = darkAccent);

    // Anel de acabamento onde o cabo elástico emerge
    canvas.drawCircle(Offset(cx, 93), 3.2, Paint()..color = darkAccent);

    if (pointingDown) {
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ProbePenPainter oldDelegate) =>
      oldDelegate.isRed != isRed ||
      oldDelegate.isConnected != isConnected ||
      oldDelegate.isDragging != isDragging ||
      oldDelegate.pointingDown != pointingDown;
}

/// ----------------------------------------------------------------------------
/// MULTÍMETRO DIGITAL DE ALTA FIDELIDADE (INSPIRADO NA ILUSTRAÇÃO)
/// ----------------------------------------------------------------------------
class DigitalMultimeterWidget extends StatelessWidget {
  final MultimeterMode currentMode;
  final ValueChanged<MultimeterMode> onModeChanged;
  final String displayValue;
  final String displayUnit;
  final bool isBeeping;
  final bool isRedConnected;
  final bool isBlackConnected;

  const DigitalMultimeterWidget({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
    required this.displayValue,
    required this.displayUnit,
    this.isBeeping = false,
    this.isRedConnected = false,
    this.isBlackConnected = false,
  });

  @override
  Widget build(BuildContext context) {
    final isOff = currentMode == MultimeterMode.off;

    return Container(
      width: 195,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        // Holster emborrachado laranja industrial vibrante
        color: const Color(0xFFEA580C),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFC2410C), width: 3.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFFFB923C).withValues(alpha: 0.45),
            blurRadius: 4,
            spreadRadius: -1,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Gabinete Interno Grafite Escuro
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF0F172A), width: 2),
            ),
            child: Column(
              children: [
                // Display LCD Azul Digital Clássico (Fiel à Imagem de Referência)
                Container(
                  height: 72,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isOff ? const Color(0xFF334155) : const Color(0xFF818CF8).withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isOff ? const Color(0xFF475569) : const Color(0xFF312E81),
                      width: 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Status Superior do LCD
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              isOff ? 'OFF' : 'AUTO DC',
                              style: GoogleFonts.shareTechMono(
                                color: isOff
                                    ? const Color(0xFF64748B)
                                    : const Color(0xFF0F172A),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isBeeping)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.volume_up_rounded,
                                    size: 11, color: Color(0xFF0F172A)),
                                const SizedBox(width: 2),
                                Text(
                                  'BEEP',
                                  style: GoogleFonts.shareTechMono(
                                    color: const Color(0xFF0F172A),
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      // Dígitos Grandes de 7 Segmentos (Escuros de Alto Contraste)
                      Center(
                        child: Text(
                          isOff ? '---' : displayValue,
                          style: GoogleFonts.shareTechMono(
                            color: isOff
                                ? const Color(0xFF64748B)
                                : const Color(0xFF0F172A),
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                      // Unidade no canto inferior direito
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Text(
                          isOff ? '' : displayUnit,
                          style: GoogleFonts.shareTechMono(
                            color: const Color(0xFF0F172A),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // 4 Botões de Função em Linha (Fiel à Imagem)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: ['RANGE', 'HOLD', 'REL', 'Hz'].map((bLabel) {
                    return Container(
                      width: 32,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF475569),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 1, offset: Offset(0, 1)),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          bLabel,
                          style: const TextStyle(color: Colors.white, fontSize: 6, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),

                // Seletor Rotativo Funcional com Mostrador Circular Estriado
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF334155), width: 1.5),
                  ),
                  child: Column(
                    children: [
                      // Dial rotativo visual com ranhuras e ponteiro
                      _buildRotaryDialGraphic(),
                      const SizedBox(height: 6),
                      // Opções clicáveis para seleção rápida
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        alignment: WrapAlignment.center,
                        children: MultimeterMode.values.map((mode) {
                          final isSelected = mode == currentMode;
                          return InkWell(
                            onTap: () => onModeChanged(mode),
                            borderRadius: BorderRadius.circular(6),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFEA580C) : const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFFFB923C) : const Color(0xFF475569),
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Text(
                                mode.shortLabel,
                                style: GoogleFonts.rajdhani(
                                  color: isSelected ? Colors.white : Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // 4 Bornes com Conectores Banana Inseridos (Fiel à Ilustração)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPortJack('10A', false, null),
                    _buildPortJack('mA', false, null),
                    _buildPortJack('COM', true, const Color(0xFF020617)), // Plug Preto Conectado
                    _buildPortJack('VΩ', true, const Color(0xFFDC2626)),  // Plug Vermelho Conectado
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRotaryDialGraphic() {
    double angle = 0;
    switch (currentMode) {
      case MultimeterMode.off:
        angle = -math.pi * 0.6;
        break;
      case MultimeterMode.voltageDc:
        angle = -math.pi * 0.25;
        break;
      case MultimeterMode.currentMa:
        angle = 0.0;
        break;
      case MultimeterMode.resistance:
        angle = math.pi * 0.25;
        break;
      case MultimeterMode.continuity:
        angle = math.pi * 0.6;
        break;
    }

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1E293B),
        border: Border.all(color: const Color(0xFF475569), width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pontos de marcação radial
          for (int i = 0; i < 8; i++)
            Transform.rotate(
              angle: i * (math.pi * 2 / 8),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 2.5,
                  height: 2.5,
                  margin: const EdgeInsets.only(top: 3),
                  decoration: const BoxDecoration(
                    color: Color(0xFF94A3B8),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          // Botão rotativo elevado com ponteiro laranja
          Transform.rotate(
            angle: angle,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0xFF334155), Color(0xFF0F172A)],
                ),
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 4,
                  height: 14,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF97316),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortJack(String label, bool hasPlug, Color? plugColor) {
    return Column(
      children: [
        if (hasPlug && plugColor != null)
          // Plug Banana 3D inserido no borne
          Container(
            width: 18,
            height: 22,
            decoration: BoxDecoration(
              color: plugColor,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.white24, width: 1),
              boxShadow: const [
                BoxShadow(color: Colors.black45, blurRadius: 3, offset: Offset(0, 2)),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 8,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          )
        else
          // Borne vazio (porta fêmea)
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF020617),
              border: Border.all(color: const Color(0xFFEA580C), width: 1.8),
            ),
          ),
        const SizedBox(height: 3),
        Text(
          label,
          style: GoogleFonts.rajdhani(
            color: const Color(0xFF94A3B8),
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// ----------------------------------------------------------------------------
/// CABOS FLEXÍVEIS ELÁSTICOS DAS PONTAS DE PROVA DO MULTÍMETRO
/// ----------------------------------------------------------------------------
class ProbeCablesPainter extends CustomPainter {
  final Offset? meterRedJack;
  final Offset? meterBlackJack;
  final Offset? probeRedTail;
  final Offset? probeBlackTail;
  final Offset? targetRed;
  final Offset? targetBlack;

  ProbeCablesPainter({
    this.meterRedJack,
    this.meterBlackJack,
    this.probeRedTail,
    this.probeBlackTail,
    this.targetRed,
    this.targetBlack,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final effectiveRed = probeRedTail ?? targetRed;
    final effectiveBlack = probeBlackTail ?? targetBlack;

    // Cabo Vermelho (+)
    if (meterRedJack != null && effectiveRed != null) {
      _drawFlexibleCable(
        canvas: canvas,
        start: meterRedJack!,
        end: effectiveRed,
        wireColor: const Color(0xFFDC2626),
        shadowColor: Colors.black.withValues(alpha: 0.22),
        sagFactor: 60,
      );
    }

    // Cabo Preto (COM)
    if (meterBlackJack != null && effectiveBlack != null) {
      _drawFlexibleCable(
        canvas: canvas,
        start: meterBlackJack!,
        end: effectiveBlack,
        wireColor: const Color(0xFF0F172A),
        shadowColor: Colors.black.withValues(alpha: 0.22),
        sagFactor: 45,
      );
    }
  }

  void _drawFlexibleCable({
    required Canvas canvas,
    required Offset start,
    required Offset end,
    required Color wireColor,
    required Color shadowColor,
    required double sagFactor,
  }) {
    final wirePaint = Paint()
      ..color = wireColor
      ..strokeWidth = 4.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final shadowPaint = Paint()
      ..color = shadowColor
      ..strokeWidth = 4.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    // Curva cúbica suave com peso elástico
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = math.sqrt(dx * dx + dy * dy);

    // Caimento elástico natural
    // Se o ponto final está acima do multímetro (como nas canetas conectadas no topo da bateria):
    // o cabo sai para baixo do plug banana e faz uma curva elegante pelo espaço livre da bancada,
    // subindo diretamente até o topo da caneta de prova sem passar por trás da bateria.
    final bool isEndAbove = end.dy < start.dy;
    final sag = math.min(sagFactor, distance * 0.20);

    final cp1 = Offset(start.dx, start.dy + 40);
    final cp2 = isEndAbove
        ? Offset(end.dx - dx * 0.35, (start.dy + end.dy) / 2 + sag * 0.4)
        : Offset(end.dx - dx * 0.2, end.dy + (math.max(start.dy, end.dy) + sag - end.dy) * 0.7);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, end.dx, end.dy);

    final shadowPath = Path()
      ..moveTo(start.dx, start.dy + 4)
      ..cubicTo(cp1.dx, cp1.dy + 4, cp2.dx, cp2.dy + 4, end.dx, end.dy + 4);

    canvas.drawPath(shadowPath, shadowPaint);
    canvas.drawPath(path, wirePaint);

    // Linha de brilho no topo da borracha do fio
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant ProbeCablesPainter oldDelegate) =>
      oldDelegate.meterRedJack != meterRedJack ||
      oldDelegate.meterBlackJack != meterBlackJack ||
      oldDelegate.probeRedTail != probeRedTail ||
      oldDelegate.probeBlackTail != probeBlackTail;
}

/// Potenciômetro / Reostato Rotativo Interativo de Bancada
class InteractivePotentiometerKnob extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const InteractivePotentiometerKnob({
    super.key,
    required this.value,
    this.min = 100.0,
    this.max = 1000.0,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final progress = ((value - min) / (max - min)).clamp(0.0, 1.0);
    final angle = -math.pi * 0.75 + progress * (math.pi * 1.5);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.tune_rounded,
                  size: 16, color: Color(0xFFD97706)),
              const SizedBox(width: 6),
              Text(
                'POTENCIÔMETRO (R)',
                style: GoogleFonts.rajdhani(
                  color: const Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Knob circular com ponteiro indicador
          GestureDetector(
            onPanUpdate: (details) {
              final delta = -details.delta.dy * 2.5;
              final nextVal = (value + delta).clamp(min, max);
              onChanged(nextVal);
            },
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFF475569), Color(0xFF0F172A)],
                ),
                border: Border.all(color: const Color(0xFFCBD5E1), width: 3),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  for (int i = 0; i <= 6; i++)
                    Transform.rotate(
                      angle: -math.pi * 0.75 + i * (math.pi * 1.5 / 6),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: 2,
                          height: 6,
                          margin: const EdgeInsets.only(top: 2),
                          color: Colors.white30,
                        ),
                      ),
                    ),
                  Transform.rotate(
                    angle: angle,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: 4,
                        height: 22,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${value.round()} Ω',
              style: GoogleFonts.rajdhani(
                color: const Color(0xFFF59E0B),
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 4),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline_rounded,
                    size: 20, color: Color(0xFF64748B)),
                tooltip: '-50 Ω',
                onPressed: () {
                  final next = (value - 50).clamp(min, max);
                  onChanged(next);
                },
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded,
                    size: 20, color: Color(0xFF0284C7)),
                tooltip: '+50 Ω',
                onPressed: () {
                  final next = (value + 50).clamp(min, max);
                  onChanged(next);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Ponto de Teste Metálico de Bancada (Test Point Node)
class TestPointNode extends StatelessWidget {
  final String id;
  final String label;
  final String? subtitle;
  final bool hasRedProbe;
  final bool hasBlackProbe;
  final VoidCallback? onConnectRed;
  final VoidCallback? onConnectBlack;
  final VoidCallback? onDisconnect;

  const TestPointNode({
    super.key,
    required this.id,
    required this.label,
    this.subtitle,
    this.hasRedProbe = false,
    this.hasBlackProbe = false,
    this.onConnectRed,
    this.onConnectBlack,
    this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    final hasAnyProbe = hasRedProbe || hasBlackProbe;

    return PopupMenuButton<String>(
      tooltip: 'Ponto de Teste $id ($label)',
      onSelected: (action) {
        if (action == 'red') onConnectRed?.call();
        if (action == 'black') onConnectBlack?.call();
        if (action == 'disconnect') onDisconnect?.call();
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'red',
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Ligar Ponta Vermelha (+)',
                style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'black',
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Ligar Ponta Preta (COM)',
                style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        if (hasAnyProbe)
          PopupMenuItem(
            value: 'disconnect',
            child: Row(
              children: [
                const Icon(Icons.close_rounded, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Desconectar Pontas deste nó',
                  style: GoogleFonts.rajdhani(color: Colors.red),
                ),
              ],
            ),
          ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: hasAnyProbe
                    ? [const Color(0xFFFDE047), const Color(0xFFCA8A04)]
                    : [const Color(0xFFE2E8F0), const Color(0xFF94A3B8)],
              ),
              border: Border.all(
                color: hasRedProbe
                    ? const Color(0xFFEF4444)
                    : (hasBlackProbe
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFCBD5E1)),
                width: hasAnyProbe ? 3.0 : 1.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: hasAnyProbe
                      ? const Color(0xFFCA8A04).withValues(alpha: 0.5)
                      : Colors.black12,
                  blurRadius: hasAnyProbe ? 8 : 4,
                  spreadRadius: hasAnyProbe ? 2 : 0,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hasRedProbe
                      ? const Color(0xFFEF4444)
                      : (hasBlackProbe
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF475569)),
                ),
                child: Center(
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF475569)),
            ),
            child: Text(
              id,
              style: GoogleFonts.rajdhani(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
