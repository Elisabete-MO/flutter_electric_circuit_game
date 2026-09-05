import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/first_step_component.dart';
import '../../../state/circuit_undo_redo_controller.dart';
import '../../../widgets/circuit_symbol_painter.dart';
import '../../../widgets/component_physical_painter.dart';
import '../../../widgets/component_vector_painters.dart';
import '../../../widgets/workbench_components.dart';

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

/// Telemetria de tensão e corrente do circuito
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

/// Painter para os fios das pontas de prova do multímetro
class ProbeWirePainter extends CustomPainter {
  final Offset batteryCenter;
  final Offset redProbeCenter;
  final Offset blackProbeCenter;

  ProbeWirePainter({
    required this.batteryCenter,
    required this.redProbeCenter,
    required this.blackProbeCenter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final battRight = batteryCenter + const Offset(30, 0);

    // Fio vermelho: terminal positivo (+) à ponta vermelha
    final redWirePaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final redPath = Path()
      ..moveTo(battRight.dx, battRight.dy - 10)
      ..quadraticBezierTo(
        (battRight.dx + redProbeCenter.dx) / 2,
        battRight.dy - 10,
        redProbeCenter.dx,
        redProbeCenter.dy,
      );
    canvas.drawPath(redPath, redWirePaint);

    // Fio preto: terminal negativo (-) à ponta preta
    final blackWirePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final blackPath = Path()
      ..moveTo(battRight.dx, battRight.dy + 10)
      ..quadraticBezierTo(
        (battRight.dx + blackProbeCenter.dx) / 2,
        blackProbeCenter.dy,
        blackProbeCenter.dx,
        blackProbeCenter.dy,
      );
    canvas.drawPath(blackPath, blackWirePaint);
  }

  @override
  bool shouldRepaint(covariant ProbeWirePainter oldDelegate) => false;
}

/// Slot da ponta de prova (Vermelha / Preta)
class MedeTestaProbeSlot extends StatelessWidget {
  final bool isRed;
  final bool isConnected;
  final VoidCallback onTap;
  final String label;

  const MedeTestaProbeSlot({
    super.key,
    required this.isRed,
    required this.isConnected,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final color = isRed ? Colors.redAccent : Colors.blueAccent;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isConnected
              ? color.withValues(alpha: 0.3)
              : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: isConnected ? 2.5 : 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isConnected
                  ? Icons.check_circle_rounded
                  : Icons.sensors_rounded,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              isConnected ? 'PROVA CONECTADA' : 'CONECTAR PROVA $label',
              style: GoogleFonts.rajdhani(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Leitor digital do multímetro (display V / mA)
class MedeTestaMeterReading extends StatelessWidget {
  final String value;
  final String unit;
  final Color color;

  const MedeTestaMeterReading({
    super.key,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF00E676),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          Text(
            unit,
            style: GoogleFonts.rajdhani(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.bold,
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Tooltip(
            message: controller.canUndo
                ? 'Desfazer: ${controller.lastUndoDescription}'
                : 'Nada para desfazer',
            child: IconButton(
              icon: Icon(
                Icons.undo_rounded,
                color: controller.canUndo
                    ? const Color(0xFF0284C7)
                    : const Color(0xFFCBD5E1),
                size: 22,
              ),
              onPressed: controller.canUndo ? onUndo : null,
              style: IconButton.styleFrom(
                backgroundColor: controller.canUndo
                    ? const Color(0xFF0284C7).withValues(alpha: 0.1)
                    : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${controller.undoCount}',
              style: GoogleFonts.rajdhani(
                color: const Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Tooltip(
            message: controller.canRedo
                ? 'Refazer: ${controller.lastRedoDescription}'
                : 'Nada para refazer',
            child: IconButton(
              icon: Icon(
                Icons.redo_rounded,
                color: controller.canRedo
                    ? const Color(0xFF0284C7)
                    : const Color(0xFFCBD5E1),
                size: 22,
              ),
              onPressed: controller.canRedo ? onRedo : null,
              style: IconButton.styleFrom(
                backgroundColor: controller.canRedo
                    ? const Color(0xFF0284C7).withValues(alpha: 0.1)
                    : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Gaveta de ferramentas para Stand 07
class MedeTestaSideToolbox extends StatelessWidget {
  final bool usePhysicalStyle;
  final VoidCallback onReset;

  const MedeTestaSideToolbox({
    super.key,
    required this.usePhysicalStyle,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
          child: Text(
            'Componentes Básicos:',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            WorkbenchSymbolToolboxTile<String>(
              data: 'multimeter_v',
              label: 'Voltímetro',
              tooltip: 'Voltímetro (Medidor de Tensão)',
              symbolWidget: MeterVectorWidget(
                size: 34,
                meterType: 'V',
                accentColor: const Color(0xFF0284C7),
              ),
              color: const Color(0xFF0284C7),
            ),
            WorkbenchSymbolToolboxTile<String>(
              data: 'multimeter_a',
              label: 'Amperímetro',
              tooltip: 'Amperímetro (Medidor de Corrente)',
              symbolWidget: MeterVectorWidget(
                size: 34,
                meterType: 'A',
                accentColor: const Color(0xFFD97706),
              ),
              color: const Color(0xFFD97706),
            ),
            WorkbenchSymbolToolboxTile<String>(
              data: 'bateria_9v',
              label: 'Fonte 9V',
              tooltip: 'Fonte DC 9V',
              symbolWidget: usePhysicalStyle
                  ? CustomPaint(
                      size: const Size(34, 34),
                      painter: ComponentPhysicalPainter(
                        type: ComponentType.battery,
                        isDarkMode: false,
                      ),
                    )
                  : CustomPaint(
                      size: const Size(34, 34),
                      painter: CircuitSymbolPainter(
                        type: ComponentType.battery,
                        color: const Color(0xFF0F172A),
                        strokeWidth: 2.0,
                      ),
                    ),
              color: const Color(0xFF0284C7),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.refresh_rounded,
                size: 16, color: Color(0xFF64748B)),
            onPressed: onReset,
            label: Text(
              'Reiniciar Montagem',
              style: GoogleFonts.rajdhani(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Item de seleção de resistor para M4
class MedeTestaResistorOptionTile extends StatelessWidget {
  final int value;
  final String label;
  final Color color;
  final bool isSelected;
  final ValueChanged<int> onSelect;

  const MedeTestaResistorOptionTile({
    super.key,
    required this.value,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onSelect(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.2)
              : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: color,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.rajdhani(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Item de relatório de investigação para M5
class MedeTestaReportOptionTile extends StatelessWidget {
  final int index;
  final String label;
  final bool isSelected;
  final ValueChanged<int> onSelect;

  const MedeTestaReportOptionTile({
    super.key,
    required this.index,
    required this.label,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onSelect(index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF10B981).withValues(alpha: 0.2)
              : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF10B981) : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.check_box
                  : Icons.check_box_outline_blank,
              color: const Color(0xFF10B981),
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
