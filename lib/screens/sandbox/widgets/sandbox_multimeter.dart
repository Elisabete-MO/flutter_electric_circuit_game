import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/first_step_component.dart';
import '../../../models/sandbox_state.dart';

enum MultimeterMode {
  off,
  voltageDC,  // Tensão Contínua (V)
  currentDC,  // Corrente Contínua (mA / A)
  resistance, // Resistência (Ω)
}

class MultimeterProbeConnection {
  const MultimeterProbeConnection({
    this.componentId,
    this.terminal,
    this.customPosition,
  });

  final String? componentId;
  final String? terminal; // 'A' ou 'B'
  final Offset? customPosition; // Posição em pixels no canvas

  bool get isConnected => componentId != null && terminal != null;
}

class SandboxMultimeterWidget extends StatelessWidget {
  const SandboxMultimeterWidget({
    super.key,
    required this.mode,
    required this.sandboxState,
    required this.redProbe,
    required this.blackProbe,
    required this.isDark,
    required this.isEn,
    required this.onModeChanged,
    required this.onResetProbes,
    required this.onToggleHold,
    this.isHold = false,
  });

  final MultimeterMode mode;
  final SandboxState sandboxState;
  final MultimeterProbeConnection redProbe;
  final MultimeterProbeConnection blackProbe;
  final bool isDark;
  final bool isEn;
  final ValueChanged<MultimeterMode> onModeChanged;
  final VoidCallback onResetProbes;
  final VoidCallback onToggleHold;
  final bool isHold;

  double? _getTerminalPotential(String? compId, String? term) {
    if (compId == null || term == null) return null;
    final key = 'node_voltage_${compId}_$term';
    return sandboxState.simulationValues[key];
  }

  double? _calculateVoltageReading() {
    if (!sandboxState.isSimulating) return 0.0;
    
    final vRed = _getTerminalPotential(redProbe.componentId, redProbe.terminal);
    final vBlack = _getTerminalPotential(blackProbe.componentId, blackProbe.terminal);

    if (vRed != null && vBlack != null) {
      return vRed - vBlack;
    } else if (vRed != null) {
      return vRed; // Referência para terra (0V)
    } else if (vBlack != null) {
      return -vBlack;
    }
    return 0.0;
  }

  double? _calculateCurrentReading() {
    if (!sandboxState.isSimulating) return 0.0;
    
    // Medição de corrente através do componente conectado à ponta vermelha ou preta
    final compId = redProbe.componentId ?? blackProbe.componentId;
    if (compId == null) return 0.0;
    return sandboxState.simulationValues['current_$compId'] ?? 0.0;
  }

  double? _calculateResistanceReading() {
    final compId = redProbe.componentId ?? blackProbe.componentId;
    if (compId == null) return null;
    
    final comp = sandboxState.components.where((c) => c.id == compId).firstOrNull;
    if (comp == null) return null;
    
    if (comp.type == ComponentType.battery) return 0.0;
    return comp.value;
  }

  @override
  Widget build(BuildContext context) {
    final isOff = mode == MultimeterMode.off;

    String displayValueStr = "---";
    String unitStr = "";

    if (!isOff) {
      switch (mode) {
        case MultimeterMode.voltageDC:
          final v = _calculateVoltageReading() ?? 0.0;
          displayValueStr = (v >= 0 ? "+" : "") + v.toStringAsFixed(2);
          unitStr = "V DC";
          break;
        case MultimeterMode.currentDC:
          final i = _calculateCurrentReading() ?? 0.0;
          if (i.abs() < 1.0) {
            displayValueStr = (i * 1000).toStringAsFixed(1);
            unitStr = "mA";
          } else {
            displayValueStr = i.toStringAsFixed(2);
            unitStr = "A";
          }
          break;
        case MultimeterMode.resistance:
          final r = _calculateResistanceReading();
          if (r == null) {
            displayValueStr = "O.L"; // Open Loop / sem conexão
          } else if (r >= 1000) {
            displayValueStr = (r / 1000).toStringAsFixed(2);
            unitStr = "kΩ";
          } else {
            displayValueStr = r.toStringAsFixed(1);
            unitStr = "Ω";
          }
          break;
        case MultimeterMode.off:
          break;
      }
    }

    final redComp = sandboxState.components.where((c) => c.id == redProbe.componentId).firstOrNull;
    final blackComp = sandboxState.components.where((c) => c.id == blackProbe.componentId).firstOrNull;

    return Container(
      width: 280,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.95) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOff ? Colors.grey.withValues(alpha: 0.3) : const Color(0xFF00F5D4),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: (isOff ? Colors.black : const Color(0xFF00F5D4)).withValues(alpha: 0.2),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cabeçalho Multímetro CyberHUD
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00F5D4).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.speed_rounded, size: 16, color: Color(0xFF00F5D4)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'CYBER-MULTIMETER 9000',
                    style: TextStyle(
                      fontFamily: GoogleFonts.rajdhani().fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                icon: Icon(Icons.refresh_rounded, size: 16, color: isDark ? Colors.white60 : Colors.black54),
                tooltip: isEn ? "Reset Probes" : "Resetar Pontas de Prova",
                onPressed: onResetProbes,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // VISOR LCD DIGITAL
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isOff ? Colors.black54 : const Color(0xFF06201B),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isOff ? Colors.white12 : const Color(0xFF00F5D4).withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Stack(
              children: [
                // Indicadores de status topo do LCD
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isOff ? "POWER OFF" : (isHold ? "HOLD" : "AUTO RANGE"),
                      style: TextStyle(
                        fontFamily: GoogleFonts.shareTechMono().fontFamily,
                        fontSize: 9,
                        color: isOff ? Colors.grey : (isHold ? Colors.amber : const Color(0xFF00F5D4)),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      unitStr,
                      style: TextStyle(
                        fontFamily: GoogleFonts.shareTechMono().fontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00FF9D),
                      ),
                    ),
                  ],
                ),
                // Valor LCD Gigante
                Center(
                  child: Text(
                    displayValueStr,
                    style: TextStyle(
                      fontFamily: GoogleFonts.orbitron().fontFamily,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: isOff
                          ? Colors.grey.shade700
                          : (isHold ? Colors.amber : const Color(0xFF00FF9D)),
                      shadows: isOff
                          ? null
                          : [
                              const Shadow(
                                color: Color(0xFF00FF9D),
                                blurRadius: 10,
                              )
                            ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // SELETOR DE MODO ROTATIVO / BOTOES
          Row(
            children: [
              Expanded(
                child: _buildModeButton(
                  label: 'OFF',
                  targetMode: MultimeterMode.off,
                  activeColor: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildModeButton(
                  label: 'V DC',
                  targetMode: MultimeterMode.voltageDC,
                  activeColor: const Color(0xFF00F5D4),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildModeButton(
                  label: 'mA / A',
                  targetMode: MultimeterMode.currentDC,
                  activeColor: const Color(0xFFFF9F1C),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildModeButton(
                  label: 'Ω OHM',
                  targetMode: MultimeterMode.resistance,
                  activeColor: const Color(0xFFFF3B7F),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // CONEXÕES DAS PONTAS DE PROVA (PROBES)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.black26 : Colors.white60,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
            ),
            child: Row(
              children: [
                // Ponta Vermelha (+)
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF3B7F),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Color(0xFFFF3B7F), blurRadius: 6)],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          redProbe.isConnected
                              ? '${redComp?.type.name.toUpperCase() ?? "COMP"} (${redProbe.terminal})'
                              : (isEn ? 'Red (+): Free' : 'Vermelho (+): Livre'),
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: GoogleFonts.rajdhani().fontFamily,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFF3B7F),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Ponta Preta (-)
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.cyanAccent,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.cyanAccent, blurRadius: 6)],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          blackProbe.isConnected
                              ? '${blackComp?.type.name.toUpperCase() ?? "COMP"} (${blackProbe.terminal})'
                              : (isEn ? 'Black (-): Free' : 'Preto (-): Livre'),
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: GoogleFonts.rajdhani().fontFamily,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.cyanAccent : Colors.blueGrey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required String label,
    required MultimeterMode targetMode,
    required Color activeColor,
  }) {
    final isSelected = mode == targetMode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onModeChanged(targetMode),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withValues(alpha: 0.2) : (isDark ? Colors.white12 : Colors.black12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? activeColor : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: GoogleFonts.rajdhani().fontFamily,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? activeColor : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Painter para desenhar os fios físicos conectando o multímetro às ponteiras no grid
class MultimeterProbeWiresPainter extends CustomPainter {
  MultimeterProbeWiresPainter({
    required this.multimeterPos,
    required this.redProbePos,
    required this.blackProbePos,
    required this.isDark,
  });

  final Offset multimeterPos;
  final Offset? redProbePos;
  final Offset? blackProbePos;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final redPaint = Paint()
      ..color = const Color(0xFFFF3B7F)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final blackPaint = Paint()
      ..color = isDark ? const Color(0xFF00F5D4) : Colors.black87
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Fio da Ponta Vermelha (+)
    if (redProbePos != null) {
      final startRed = multimeterPos + const Offset(40, 20);
      final controlRed = Offset(
        (startRed.dx + redProbePos!.dx) / 2,
        math.max(startRed.dy, redProbePos!.dy) + 40,
      );
      final pathRed = Path()
        ..moveTo(startRed.dx, startRed.dy)
        ..quadraticBezierTo(controlRed.dx, controlRed.dy, redProbePos!.dx, redProbePos!.dy);

      canvas.drawPath(pathRed, redPaint);

      // Glow effect no fio vermelho
      final glowPaintRed = Paint()
        ..color = const Color(0xFFFF3B7F).withValues(alpha: 0.4)
        ..strokeWidth = 6.0
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawPath(pathRed, glowPaintRed);
    }

    // Fio da Ponta Preta (-)
    if (blackProbePos != null) {
      final startBlack = multimeterPos + const Offset(120, 20);
      final controlBlack = Offset(
        (startBlack.dx + blackProbePos!.dx) / 2,
        math.max(startBlack.dy, blackProbePos!.dy) + 60,
      );
      final pathBlack = Path()
        ..moveTo(startBlack.dx, startBlack.dy)
        ..quadraticBezierTo(controlBlack.dx, controlBlack.dy, blackProbePos!.dx, blackProbePos!.dy);

      canvas.drawPath(pathBlack, blackPaint);

      final glowPaintBlack = Paint()
        ..color = (isDark ? const Color(0xFF00F5D4) : Colors.black38).withValues(alpha: 0.4)
        ..strokeWidth = 6.0
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawPath(pathBlack, glowPaintBlack);
    }
  }

  @override
  bool shouldRepaint(covariant MultimeterProbeWiresPainter oldDelegate) {
    return oldDelegate.multimeterPos != multimeterPos ||
        oldDelegate.redProbePos != redProbePos ||
        oldDelegate.blackProbePos != blackProbePos ||
        oldDelegate.isDark != isDark;
  }
}
