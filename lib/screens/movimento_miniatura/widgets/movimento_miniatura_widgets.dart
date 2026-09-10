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
    final statusText = isClosed ? 'FECHADO (ON)' : 'ABERTO (OFF)';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            statusText,
            style: GoogleFonts.rajdhani(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 11,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${voltage.toStringAsFixed(1)}V',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF0284C7),
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 4),
          const Text('|', style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 10)),
          const SizedBox(width: 4),
          Text(
            '${currentMa.toStringAsFixed(0)}mA',
            style: GoogleFonts.rajdhani(
              color: isClosed
                  ? const Color(0xFF10B981)
                  : const Color(0xFF94A3B8),
              fontWeight: FontWeight.bold,
              fontSize: 11,
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
              data: 'battery',
              label: 'Bateria',
              tooltip: 'Fonte DC (6V)',
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
              color: const Color(0xFFD97706),
            ),
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
