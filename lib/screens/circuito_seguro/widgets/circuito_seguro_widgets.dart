import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../state/circuit_undo_redo_controller.dart';

enum CircuitoSeguroState {
  safe,
  shortCircuit,
  openCircuit,
  fuseBlown,
  inactive,
}

/// Status do circuito de segurança (compacto e estilizado)
class CircuitoSeguroStatusCard extends StatelessWidget {
  final CircuitoSeguroState state;

  const CircuitoSeguroStatusCard({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    switch (state) {
      case CircuitoSeguroState.safe:
        statusColor = const Color(0xFF10B981);
        statusText = 'SEGURO (OK)';
        break;
      case CircuitoSeguroState.shortCircuit:
        statusColor = const Color(0xFFEF4444);
        statusText = 'CURTO-CIRCUITO';
        break;
      case CircuitoSeguroState.openCircuit:
        statusColor = const Color(0xFFF59E0B);
        statusText = 'ABERTO (OFF)';
        break;
      case CircuitoSeguroState.fuseBlown:
        statusColor = const Color(0xFFEC4899);
        statusText = 'FUSÍVEL ROMPIDO';
        break;
      case CircuitoSeguroState.inactive:
        statusColor = const Color(0xFF64748B);
        statusText = 'DESARMADO';
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

/// Telemetria de tensão e corrente do circuito de segurança
class CircuitoSeguroTelemetryCard extends StatelessWidget {
  final double voltage;
  final double currentMa;
  final bool isSafe;

  const CircuitoSeguroTelemetryCard({
    super.key,
    required this.voltage,
    required this.currentMa,
    required this.isSafe,
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
              color: isSafe ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

/// Botões de Desfazer / Refazer Padronizados
class CircuitoSeguroUndoRedoButtons extends StatelessWidget {
  final CircuitUndoRedoController controller;
  final VoidCallback onUndo;
  final VoidCallback onRedo;

  const CircuitoSeguroUndoRedoButtons({
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
