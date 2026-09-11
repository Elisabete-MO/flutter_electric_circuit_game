import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../state/circuit_undo_redo_controller.dart';

enum PracaState {
  standby,
  residentialLit,
  streetLit,
  subsystemsIntegrated,
  faultDetected,
  fullyEnergized,
}

/// Card de Status da Praça da Maquete Coletiva
class PracaStatusCard extends StatelessWidget {
  final PracaState state;

  const PracaStatusCard({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    switch (state) {
      case PracaState.standby:
        statusColor = const Color(0xFF64748B);
        statusText = 'MAQUETE EM ESPERA';
        break;
      case PracaState.residentialLit:
        statusColor = const Color(0xFF38BDF8);
        statusText = 'REDE RESIDENCIAL ATIVA';
        break;
      case PracaState.streetLit:
        statusColor = const Color(0xFFFBBF24);
        statusText = 'ILUMINAÇÃO PÚBLICA OPERANTE';
        break;
      case PracaState.subsystemsIntegrated:
        statusColor = const Color(0xFF10B981);
        statusText = 'SUBSISTEMAS URBANOS CONECTADOS';
        break;
      case PracaState.faultDetected:
        statusColor = const Color(0xFFEF4444);
        statusText = 'FALHA DE REDE DETECTADA';
        break;
      case PracaState.fullyEnergized:
        statusColor = const Color(0xFF8B5CF6);
        statusText = 'CIDADE 100% ENERGIZADA!';
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

/// Telemetria da Maquete: Carga Total e Subsistemas Ativos
class PracaTelemetryCard extends StatelessWidget {
  final bool housesOn;
  final bool streetlightsOn;
  final bool greenhouseOn;
  final bool gateOn;
  final double totalPowerWatts;

  const PracaTelemetryCard({
    super.key,
    this.housesOn = false,
    this.streetlightsOn = false,
    this.greenhouseOn = false,
    this.gateOn = false,
    this.totalPowerWatts = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    int activeCount = 0;
    if (housesOn) activeCount++;
    if (streetlightsOn) activeCount++;
    if (greenhouseOn) activeCount++;
    if (gateOn) activeCount++;

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
          const Icon(Icons.location_city_rounded, size: 14, color: Color(0xFF8B5CF6)),
          const SizedBox(width: 4),
          Text(
            'REDES: $activeCount/4 ATIVAS  |  POTÊNCIA: ${totalPowerWatts.toStringAsFixed(0)}W  |  BARRAMENTO 12V',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

/// Controles de Desfazer / Refazer
class PracaUndoRedoButtons extends StatelessWidget {
  final CircuitUndoRedoController controller;
  final VoidCallback onUndo;
  final VoidCallback onRedo;

  const PracaUndoRedoButtons({
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
