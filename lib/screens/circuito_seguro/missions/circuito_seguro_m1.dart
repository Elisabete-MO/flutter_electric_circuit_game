import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/circuit_action.dart';
import '../../../state/circuit_undo_redo_controller.dart';
import '../../../widgets/prof_volts_feedback_dialog.dart';
import '../../../widgets/success_confetti_overlay.dart';
import '../../../widgets/workbench_components.dart';
import '../../../widgets/workbench_table_frame.dart';
import '../widgets/circuito_seguro_painter.dart';
import '../widgets/circuito_seguro_widgets.dart';

/// Missão 01 — Alerta de Curto: Identificar e sanar o atalho de curto-circuito
class CircuitoSeguroM1 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const CircuitoSeguroM1({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<CircuitoSeguroM1> createState() => _CircuitoSeguroM1State();
}

class _CircuitoSeguroM1State extends State<CircuitoSeguroM1>
    with SingleTickerProviderStateMixin {
  late final AnimationController _electronAnimController;
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  bool _usePhysicalStyle = true;
  bool _shortCircuitPresent = true; // Inicia com o fio de curto
  bool _isSwitchArmed = true;

  @override
  void initState() {
    super.initState();
    _electronAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _electronAnimController.dispose();
    super.dispose();
  }

  bool get _isCircuitSafe => !_shortCircuitPresent && _isSwitchArmed;

  void _toggleShortCircuit() {
    final prev = _shortCircuitPresent;
    _undoRedoController.execute(
      ToggleBoolAction(
        description: prev ? 'Remover Fio de Curto' : 'Inserir Fio de Curto',
        onApply: () => setState(() => _shortCircuitPresent = !prev),
        onUndo: () => setState(() => _shortCircuitPresent = prev),
      ),
    );
  }

  void _validate() {
    final isSuccess = _isCircuitSafe;
    final message = isSuccess
        ? 'Excelente! Ao remover o caminho de curto, toda a corrente voltou a passar pelo resistor e LED de segurança, protegendo a fonte!'
        : 'Perigo! O fio de curto ainda está conectado, desviando os elétrons e causando sobrecarga na bateria!';

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
    final statusState = _shortCircuitPresent
        ? CircuitoSeguroState.shortCircuit
        : (_isSwitchArmed ? CircuitoSeguroState.safe : CircuitoSeguroState.inactive);

    final voltage = _shortCircuitPresent ? 1.2 : 9.0;
    final current = _shortCircuitPresent ? 450.0 : 13.0;

    return Row(
      children: [
        // 1. Bancada Principal EletroLab
        Expanded(
          flex: 7,
          child: WorkbenchTableFrame(
            usePhysicalStyle: _usePhysicalStyle,
            onStyleChanged: (val) => setState(() => _usePhysicalStyle = val),
            leftHeaderWidget: CircuitoSeguroStatusCard(state: statusState),
            rightHeaderWidget: CircuitoSeguroTelemetryCard(
              voltage: voltage,
              currentMa: current,
              isSafe: _isCircuitSafe,
            ),
            bottomWidget: CircuitoSeguroUndoRedoButtons(
              controller: _undoRedoController,
              onUndo: () => setState(() => _undoRedoController.undo()),
              onRedo: () => setState(() => _undoRedoController.redo()),
            ),
            child: AnimatedBuilder(
              animation: _electronAnimController,
              builder: (context, child) {
                return CustomPaint(
                  painter: CircuitoSeguroPainter(
                    missionIndex: 0,
                    animValue: _electronAnimController.value,
                    usePhysicalStyle: _usePhysicalStyle,
                    isArmingSwitchClosed: _isSwitchArmed,
                    isShortCircuitActive: _shortCircuitPresent,
                    isWireBroken: false,
                    isWireRepaired: true,
                    isFuseInserted: true,
                    isFuseBlown: false,
                    isFuseCorrectRating: true,
                    isLedInserted: true,
                    isResistorInserted: true,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        // 2. Painel Lateral da Equipe Segurança
        Expanded(
          flex: 3,
          child: WorkbenchSidePanel(
            teamTitle: 'Equipe Segurança',
            showTeamHeader: false,
            buttonColor: const Color(0xFFEF4444),
            toolboxItems: [
              _buildObjectiveCard(),
              const SizedBox(height: 12),
              _buildInvestigationStepper(),
              const SizedBox(height: 12),
              _buildToolboxControls(),
            ],
            onEnergizePressed: _validate,
          ),
        ),
      ],
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
            'Missão 1 · Alerta de Curto',
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Identifique o fio em curto que desvia a corrente da carga e remova-o para que o LED de segurança acenda normalmente.',
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
            'Checklist de Investigação:',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF38BDF8),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildStepRow(1, 'Inspecionar atalho sem carga', true),
          _buildStepRow(2, 'Desconectar fio de curto', !_shortCircuitPresent),
          _buildStepRow(3, 'Confirmar LED aceso e corrente segura', _isCircuitSafe),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: _shortCircuitPresent
                ? const Color(0xFFEF4444)
                : const Color(0xFF10B981),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: _toggleShortCircuit,
          icon: Icon(_shortCircuitPresent ? Icons.delete_outline_rounded : Icons.add_link_rounded),
          label: Text(
            _shortCircuitPresent
                ? 'Remover Fio de Curto'
                : 'Fio de Curto Removido',
            style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
