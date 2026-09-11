import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../state/circuit_undo_redo_controller.dart';

enum HortaState {
  standby,
  adjusting,
  ideal,
  tooDim,
  tooBright,
  nightActive,
  dayInactive,
  charging,
  discharging,
  systemOk,
}

/// Card de Status da Horta Monitorada (compacto e estilizado)
class HortaStatusCard extends StatelessWidget {
  final HortaState state;

  const HortaStatusCard({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    switch (state) {
      case HortaState.standby:
        statusColor = const Color(0xFF64748B);
        statusText = 'ESTUFA EM ESPERA';
        break;
      case HortaState.adjusting:
        statusColor = const Color(0xFFF59E0B);
        statusText = 'AJUSTANDO CALIBRAÇÃO';
        break;
      case HortaState.ideal:
        statusColor = const Color(0xFF10B981);
        statusText = 'ILUMINAÇÃO IDEAL (OK)';
        break;
      case HortaState.tooDim:
        statusColor = const Color(0xFF38BDF8);
        statusText = 'LUZ BAIXA (SUBILUMINADO)';
        break;
      case HortaState.tooBright:
        statusColor = const Color(0xFFEF4444);
        statusText = 'LUZ EXCESSIVA (SOBREAQUECIMENTO)';
        break;
      case HortaState.nightActive:
        statusColor = const Color(0xFF8B5CF6);
        statusText = 'NOITE: LUZ AUTOMÁTICA ATIVA';
        break;
      case HortaState.dayInactive:
        statusColor = const Color(0xFFF59E0B);
        statusText = 'DIA: LUZ EM STANDBY';
        break;
      case HortaState.charging:
        statusColor = const Color(0xFF06B6D4);
        statusText = 'CARREGANDO CAPACITOR';
        break;
      case HortaState.discharging:
        statusColor = const Color(0xFF10B981);
        statusText = 'RESERVA EM DESCARGA';
        break;
      case HortaState.systemOk:
        statusColor = const Color(0xFF10B981);
        statusText = 'SISTEMA INTEGRADO OPERANTE';
        break;
    }

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
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
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

/// Telemetria da Horta: Iluminação, Tensão, Brilho do LED e Estado
class HortaTelemetryCard extends StatelessWidget {
  final double potPercent;
  final double luxPercent;
  final double voltage;
  final double ledBrightnessPercent;
  final bool isCapacitorCharged;

  const HortaTelemetryCard({
    super.key,
    this.potPercent = 0.0,
    this.luxPercent = 100.0,
    this.voltage = 5.0,
    this.ledBrightnessPercent = 0.0,
    this.isCapacitorCharged = false,
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
          const Icon(Icons.eco_rounded, size: 14, color: Color(0xFF16A34A)),
          const SizedBox(width: 4),
          Text(
            'LED: ${ledBrightnessPercent.toStringAsFixed(0)}%  |  LDR: ${luxPercent.toStringAsFixed(0)}%  |  ${voltage.toStringAsFixed(1)}V',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
          if (isCapacitorCharged) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFF0284C7).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'CAP OK',
                style: GoogleFonts.rajdhani(
                  color: const Color(0xFF0284C7),
                  fontWeight: FontWeight.bold,
                  fontSize: 9,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Controles de Desfazer / Refazer
class HortaUndoRedoButtons extends StatelessWidget {
  final CircuitUndoRedoController controller;
  final VoidCallback onUndo;
  final VoidCallback onRedo;

  const HortaUndoRedoButtons({
    super.key,
    required this.controller,
    required this.onUndo,
    required this.onRedo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.undo_rounded, size: 18),
            onPressed: controller.canUndo ? onUndo : null,
            tooltip: 'Desfazer',
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
          IconButton(
            icon: const Icon(Icons.redo_rounded, size: 18),
            onPressed: controller.canRedo ? onRedo : null,
            tooltip: 'Refazer',
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
