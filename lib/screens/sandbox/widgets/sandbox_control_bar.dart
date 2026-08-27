import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/sandbox_state.dart';
import '../../../widgets/challenge_layout_components.dart';
import '../models/connection_source.dart';

class SandboxControlBarWidget extends StatelessWidget {
  final SandboxState state;
  final ConnectionSource? connSource;
  final bool isEn;
  final bool isDark;
  final bool canUndo;
  final bool canRedo;
  final VoidCallback onCancelWiring;
  final VoidCallback onClearCanvas;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onToggleSimulation;

  final bool showMultimeter;
  final bool showOscilloscope;
  final VoidCallback onToggleMultimeter;
  final VoidCallback onToggleOscilloscope;
  final VoidCallback onOpenInspector;
  final VoidCallback onOpenChallenges;

  const SandboxControlBarWidget({
    super.key,
    required this.state,
    required this.connSource,
    required this.isEn,
    required this.isDark,
    required this.canUndo,
    required this.canRedo,
    required this.onCancelWiring,
    required this.onClearCanvas,
    required this.onUndo,
    required this.onRedo,
    required this.onToggleSimulation,
    required this.showMultimeter,
    required this.showOscilloscope,
    required this.onToggleMultimeter,
    required this.onToggleOscilloscope,
    required this.onOpenInspector,
    required this.onOpenChallenges,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionDock(
      children: [
        if (connSource != null)
          TextButton.icon(
            onPressed: onCancelWiring,
            icon: const Icon(Icons.cancel_outlined, size: 18),
            label: Text(isEn ? 'Cancel Wiring' : 'Cancelar Conexão'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF3B7F),
            ),
          )
        else
          TextButton.icon(
            onPressed: onClearCanvas,
            icon: const Icon(Icons.delete_sweep_outlined, size: 18),
            label: Text(isEn ? 'Clear Grid' : 'Limpar Bancada'),
            style: TextButton.styleFrom(
              foregroundColor: isDark ? Colors.white70 : Colors.black87,
            ),
          ),

        IconButton(
          icon: const Icon(Icons.undo_rounded, size: 20),
          tooltip: isEn ? "Undo (Ctrl+Z)" : "Desfazer (Ctrl+Z)",
          onPressed: canUndo ? onUndo : null,
        ),
        IconButton(
          icon: const Icon(Icons.redo_rounded, size: 20),
          tooltip: isEn ? "Redo (Ctrl+Y)" : "Refazer (Ctrl+Y)",
          onPressed: canRedo ? onRedo : null,
        ),

        // Instrumentos Virtuais (Pilar 1)
        IconButton(
          icon: Icon(
            Icons.speed_rounded,
            size: 20,
            color: showMultimeter ? const Color(0xFF00F5D4) : (isDark ? Colors.white70 : Colors.black54),
          ),
          tooltip: isEn ? "Toggle Multimeter" : "Multímetro Digital",
          onPressed: onToggleMultimeter,
        ),
        IconButton(
          icon: Icon(
            Icons.show_chart_rounded,
            size: 20,
            color: showOscilloscope ? const Color(0xFF00FF9D) : (isDark ? Colors.white70 : Colors.black54),
          ),
          tooltip: isEn ? "Toggle Oscilloscope" : "Osciloscópio HUD",
          onPressed: onToggleOscilloscope,
        ),

        // Diagnóstico Inteligente & UGC (Pilar 3)
        IconButton(
          icon: const Icon(
            Icons.saved_search_rounded,
            size: 20,
            color: Color(0xFF00F5D4),
          ),
          tooltip: isEn ? "Smart Inspector (Prof. Volts)" : "Inspetor Inteligente (Prof. Volts)",
          onPressed: onOpenInspector,
        ),
        IconButton(
          icon: const Icon(
            Icons.psychology_rounded,
            size: 20,
            color: Color(0xFFFFB300),
          ),
          tooltip: isEn ? "Troubleshooting & UGC" : "Desafios & Importar/Exportar",
          onPressed: onOpenChallenges,
        ),

        FilledButton(
          onPressed: onToggleSimulation,
          style: FilledButton.styleFrom(
            backgroundColor: state.isSimulating
                ? const Color(0xFFFF3B7F)
                : const Color(0xFF00FF9D),
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 4,
            shadowColor: (state.isSimulating
                ? const Color(0xFFFF3B7F)
                : const Color(0xFF00FF9D)).withValues(alpha: 0.4),
            textStyle: GoogleFonts.rajdhani(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 1.0,
            ),
          ),
          child: Text(
            state.isSimulating
                ? (isEn ? 'Stop Simulation' : 'Parar Simulação')
                : (isEn ? 'Start Simulation' : 'Iniciar Simulação'),
          ),
        ),
      ],
    );
  }
}
