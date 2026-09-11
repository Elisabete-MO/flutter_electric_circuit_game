import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/circuit_action.dart';
import '../../../state/circuit_undo_redo_controller.dart';
import '../../../widgets/prof_volts_feedback_dialog.dart';
import '../../../widgets/success_confetti_overlay.dart';
import '../../../widgets/workbench_components.dart';
import '../../../widgets/workbench_table_frame.dart';
import '../widgets/praca_maquete_painter.dart';
import '../widgets/praca_maquete_widgets.dart';

/// Missão 02 — Rua em Funcionamento: Testar a resiliência e independência da rede de iluminação pública
class PracaMaqueteM2 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const PracaMaqueteM2({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<PracaMaqueteM2> createState() => _PracaMaqueteM2State();
}

class _PracaMaqueteM2State extends State<PracaMaqueteM2>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  bool _usePhysicalStyle = true;
  bool _isStreetPowerOn = true;
  bool _isFaultSimulated = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggleStreetPower() {
    setState(() => _isStreetPowerOn = !_isStreetPowerOn);
  }

  void _simulateFaultyPole() {
    final prev = _isFaultSimulated;
    _undoRedoController.execute(
      ToggleBoolAction(
        description: prev ? 'Restaurar Poste 2' : 'Simular Lâmpada Queimada no Poste 2',
        onApply: () => setState(() => _isFaultSimulated = !prev),
        onUndo: () => setState(() => _isFaultSimulated = prev),
      ),
    );
  }

  void _validate() {
    final isSuccess = _isStreetPowerOn && _isFaultSimulated;
    final message = isSuccess
        ? 'Fantástico! Você comprovou a regra de ouro das redes urbanas em paralelo: mesmo com o poste 2 em manutenção, os outros 3 postes continuam iluminando a via pública normalmente!'
        : 'Ligue a rede da avenida e clique em "Simular Queima do Poste 2" para verificar se os demais postes permanecem acesos.';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProfVoltsFeedbackDialog(
        isCorrect: isSuccess,
        message: message,
        onAction: () {
          Navigator.of(context).pop();
          if (isSuccess) {
            showSuccessConfetti(context);
            widget.onMissionComplete();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = _isStreetPowerOn
        ? (_isFaultSimulated ? PracaState.streetLit : PracaState.streetLit)
        : PracaState.standby;

    final activePoles = _isStreetPowerOn ? (_isFaultSimulated ? 3 : 4) : 0;

    return WorkbenchResponsiveLayout(
      workbench: WorkbenchTableFrame(
        usePhysicalStyle: _usePhysicalStyle,
        onStyleChanged: (val) => setState(() => _usePhysicalStyle = val),
        leftHeaderWidget: PracaStatusCard(state: status),
        rightHeaderWidget: PracaTelemetryCard(
          streetlightsOn: _isStreetPowerOn,
          totalPowerWatts: activePoles * 15.0,
        ),
        bottomWidget: PracaUndoRedoButtons(
          controller: _undoRedoController,
          onUndo: () => setState(() => _undoRedoController.undo()),
          onRedo: () => setState(() => _undoRedoController.redo()),
        ),
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return CustomPaint(
              painter: PracaMaquetePainter(
                missionIndex: 1,
                animValue: _animController.value,
                usePhysicalStyle: _usePhysicalStyle,
                housesOn: true,
                streetlightsOn: _isStreetPowerOn,
                faultyStreetlightIsolated: _isFaultSimulated,
                greenhouseOn: false,
                gateOn: false,
                isMainGridEnergized: true,
              ),
            );
          },
        ),
      ),
      sidePanel: WorkbenchSidePanel(
        teamTitle: 'Equipe Urbana',
        showTeamHeader: false,
        buttonColor: const Color(0xFF8B5CF6),
        toolboxItems: [
          _buildObjectiveCard(),
          const SizedBox(height: 12),
          _buildInvestigationStepper(),
          const SizedBox(height: 12),
          _buildToolboxControls(),
        ],
        onEnergizePressed: _validate,
      ),
    );
  }

  Widget _buildObjectiveCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Missão 2 · Rua em Funcionamento',
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Demonstre a tolerância a falhas na iluminação pública: simule a queima de uma lâmpada e comprove que os outros 3 postes permanecem acesos.',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF94A3B8),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestigationStepper() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Checklist de Tolerância a Falhas:',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF38BDF8),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildStepRow(1, 'Energizar rede da avenida (4 postes)', _isStreetPowerOn),
          _buildStepRow(2, 'Simular defeito seletivo no Poste 2', _isFaultSimulated),
          _buildStepRow(3, 'Comprovar 3 postes mantendo a via iluminada', _isStreetPowerOn && _isFaultSimulated),
        ],
      ),
    );
  }

  Widget _buildStepRow(int step, String label, bool isDone) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: isDone ? const Color(0xFF10B981) : const Color(0xFF64748B),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.rajdhani(
                color: isDone ? Colors.white : const Color(0xFF64748B),
                fontSize: 12,
                fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolboxControls() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: _isFaultSimulated ? const Color(0xFFEF4444) : const Color(0xFFFBBF24),
              foregroundColor: _isFaultSimulated ? Colors.white : const Color(0xFF0F172A),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _simulateFaultyPole,
            icon: Icon(_isFaultSimulated ? Icons.build_rounded : Icons.warning_amber_rounded),
            label: Text(
              _isFaultSimulated ? 'Poste 2 em Manutenção (3/4 Acesos)' : 'Simular Queima do Poste 2',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: const BorderSide(color: Color(0xFF475569)),
            ),
            onPressed: _toggleStreetPower,
            icon: Icon(_isStreetPowerOn ? Icons.power_rounded : Icons.power_off_rounded, size: 16),
            label: Text(
              _isStreetPowerOn ? 'Rede da Avenida Ligada' : 'Ligar Rede da Avenida',
              style: GoogleFonts.rajdhani(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
