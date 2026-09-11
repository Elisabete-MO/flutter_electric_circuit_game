import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../state/circuit_undo_redo_controller.dart';

enum PortaoState {
  idle,
  coilEnergized,
  contactClosed,
  motorRunning,
  gateOpen,
  emergencyStop,
}

/// Card de Status do Portão da Escola e do Relé
class PortaoStatusCard extends StatelessWidget {
  final PortaoState state;

  const PortaoStatusCard({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    switch (state) {
      case PortaoState.idle:
        statusColor = const Color(0xFF64748B);
        statusText = 'PORTÃO FECHADO (STANDBY)';
        break;
      case PortaoState.coilEnergized:
        statusColor = const Color(0xFFF59E0B);
        statusText = 'BOBINA ENERGIZADA (MAGNETISMO)';
        break;
      case PortaoState.contactClosed:
        statusColor = const Color(0xFF38BDF8);
        statusText = 'CONTATO NA FECHADO';
        break;
      case PortaoState.motorRunning:
        statusColor = const Color(0xFF10B981);
        statusText = 'MOTOR EM MOVIMENTO (ABRINDO)';
        break;
      case PortaoState.gateOpen:
        statusColor = const Color(0xFF10B981);
        statusText = 'PORTÃO TOTALMENTE ABERTO';
        break;
      case PortaoState.emergencyStop:
        statusColor = const Color(0xFFEF4444);
        statusText = 'PARADA DE EMERGÊNCIA (NF ABERTO)';
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

/// Telemetria de Comando (5V) vs Carga (12V) do Relé
class PortaoTelemetryCard extends StatelessWidget {
  final bool isCoilEnergized;
  final bool isContactClosed;
  final bool isMotorRunning;
  final double gatePositionPercent; // 0 a 100%

  const PortaoTelemetryCard({
    super.key,
    required this.isCoilEnergized,
    required this.isContactClosed,
    required this.isMotorRunning,
    this.gatePositionPercent = 0.0,
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
          const Icon(Icons.sensors_rounded, size: 14, color: Color(0xFFF59E0B)),
          const SizedBox(width: 4),
          Text(
            'CMD: ${isCoilEnergized ? "5V (ON)" : "0V (OFF)"}  |  CARGA: ${isContactClosed ? "12V (FECHADO)" : "ABERTO"}  |  PORTÃO: ${gatePositionPercent.toStringAsFixed(0)}%',
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
class PortaoUndoRedoButtons extends StatelessWidget {
  final CircuitUndoRedoController controller;
  final VoidCallback onUndo;
  final VoidCallback onRedo;

  const PortaoUndoRedoButtons({
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
