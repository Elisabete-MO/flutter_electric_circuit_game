import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/first_step_component.dart';
import '../../../state/circuit_undo_redo_controller.dart';
import '../../../widgets/circuit_symbol_painter.dart';
import '../../../widgets/component_physical_painter.dart';
import '../../../widgets/component_vector_painters.dart';
import '../../../widgets/schematic_symbol_painters.dart';
import '../../../widgets/workbench_components.dart';

/// Status do circuito (aberto / fechado) para o Estande 06
class MovimentoStatusCard extends StatelessWidget {
  final bool isClosed;

  const MovimentoStatusCard({super.key, required this.isClosed});

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
class MovimentoTelemetryCard extends StatelessWidget {
  final double voltage;
  final double currentMa;
  final bool isClosed;

  const MovimentoTelemetryCard({
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
            '${currentMa.toStringAsFixed(0)}mA',
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

/// Widget animado do Motor CC com indicação de estado
class MovimentoAnimatedMotorWidget extends StatelessWidget {
  final bool isRunning;
  final bool isReversed;
  final bool usePhysicalStyle;

  const MovimentoAnimatedMotorWidget({
    super.key,
    required this.isRunning,
    this.isReversed = false,
    required this.usePhysicalStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (usePhysicalStyle)
          CustomPaint(
            size: const Size(100, 100),
            painter: ComponentPhysicalPainter(
              type: ComponentType.motor,
              isActive: isRunning,
              isDarkMode: false,
            ),
          )
        else
          CustomPaint(
            size: const Size(90, 90),
            painter: CircuitSymbolPainter(
              type: ComponentType.motor,
              isActive: isRunning,
              color: const Color(0xFF0F172A),
              strokeWidth: 2.5,
            ),
          ),
        const SizedBox(height: 8),
        Text(
          isRunning ? 'MOTOR CC EM OPERAÇÃO ⚡' : 'MOTOR CC DESLIGADO ⚪',
          style: GoogleFonts.rajdhani(
            color: isRunning
                ? const Color(0xFF0284C7)
                : const Color(0xFF64748B),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

/// Badge de previsão do Professor Volts
class MovimentoPredictionBadge extends StatelessWidget {
  final String? prediction;

  const MovimentoPredictionBadge({super.key, required this.prediction});

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color borderColor;
    final IconData icon;
    final String text;

    if (prediction == null) {
      bgColor = const Color(0xFFFEF3C7);
      borderColor = const Color(0xFFF59E0B);
      icon = Icons.psychology_rounded;
      text = 'Previsão: Pendente';
    } else {
      bgColor = const Color(0xFFDBEAFE);
      borderColor = const Color(0xFF3B82F6);
      icon = Icons.check_circle_outline_rounded;
      text = 'Previsão: $prediction';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: borderColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.rajdhani(
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Botões de Desfazer / Refazer
class MovimentoUndoRedoButtons extends StatelessWidget {
  final CircuitUndoRedoController controller;
  final VoidCallback onUndo;
  final VoidCallback onRedo;

  const MovimentoUndoRedoButtons({
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

/// Gaveta de ferramentas com componentes da bancada mecânica
class MovimentoSideToolbox extends StatelessWidget {
  final bool usePhysicalStyle;

  const MovimentoSideToolbox({super.key, required this.usePhysicalStyle});

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
              data: 'motor_cc',
              label: 'Motor CC',
              tooltip: 'Motor CC',
              symbolWidget: usePhysicalStyle
                  ? CustomPaint(
                      size: const Size(34, 34),
                      painter: ComponentPhysicalPainter(
                        type: ComponentType.motor,
                        isActive: false,
                        isDarkMode: false,
                      ),
                    )
                  : CustomPaint(
                      size: const Size(34, 34),
                      painter: CircuitSymbolPainter(
                        type: ComponentType.motor,
                        isActive: false,
                        color: const Color(0xFF0F172A),
                        strokeWidth: 2.0,
                      ),
                    ),
              color: const Color(0xFF0284C7),
            ),
            WorkbenchSymbolToolboxTile<String>(
              data: 'push_button',
              label: 'Push-Button',
              tooltip: 'Botão de Pressão (Momentâneo)',
              symbolWidget: usePhysicalStyle
                  ? const PushButtonVectorWidget(size: 34)
                  : const SchematicSwitchWidget(
                      size: 34,
                      isPushButton: true,
                      color: Color(0xFFEF4444),
                    ),
              color: const Color(0xFFEF4444),
            ),
            WorkbenchSymbolToolboxTile<String>(
              data: 'led_indicator',
              label: 'LED',
              tooltip: 'LED Indicador',
              symbolWidget: usePhysicalStyle
                  ? CustomPaint(
                      size: const Size(34, 34),
                      painter: ComponentPhysicalPainter(
                        type: ComponentType.led,
                        isActive: false,
                        isDarkMode: false,
                      ),
                    )
                  : CustomPaint(
                      size: const Size(34, 34),
                      painter: CircuitSymbolPainter(
                        type: ComponentType.led,
                        isActive: false,
                        color: const Color(0xFF0F172A),
                        strokeWidth: 2.0,
                      ),
                    ),
              color: Colors.redAccent,
            ),
            WorkbenchSymbolToolboxTile<String>(
              data: 'resistor_680',
              label: 'Resistor',
              tooltip: 'Resistor (680Ω)',
              symbolWidget: usePhysicalStyle
                  ? CustomPaint(
                      size: const Size(34, 34),
                      painter: ComponentPhysicalPainter(
                        type: ComponentType.resistor,
                        isDarkMode: false,
                      ),
                    )
                  : CustomPaint(
                      size: const Size(34, 34),
                      painter: CircuitSymbolPainter(
                        type: ComponentType.resistor,
                        color: const Color(0xFF0F172A),
                        strokeWidth: 2.0,
                      ),
                    ),
              color: const Color(0xFFD97706),
            ),
          ],
        ),
      ],
    );
  }
}
