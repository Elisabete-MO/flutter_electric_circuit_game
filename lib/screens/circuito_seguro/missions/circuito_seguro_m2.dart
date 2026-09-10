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

/// Missão 02 — Continuidade & Fio Rompido: Testar continuidade e reparar o circuito aberto
class CircuitoSeguroM2 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const CircuitoSeguroM2({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<CircuitoSeguroM2> createState() => _CircuitoSeguroM2State();
}

class _CircuitoSeguroM2State extends State<CircuitoSeguroM2>
    with SingleTickerProviderStateMixin {
  late final AnimationController _electronAnimController;
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  bool _usePhysicalStyle = true;
  bool _isWireRepaired = false;
  bool _isTestingProbes = false;

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

  bool get _isCircuitClosed => _isWireRepaired;

  void _toggleProbeTest() {
    setState(() => _isTestingProbes = !_isTestingProbes);
  }

  void _toggleRepairWire() {
    final prev = _isWireRepaired;
    _undoRedoController.execute(
      ToggleBoolAction(
        description: prev ? 'Desconectar Emenda' : 'Reparar Cabo Rompido',
        onApply: () => setState(() => _isWireRepaired = !prev),
        onUndo: () => setState(() => _isWireRepaired = prev),
      ),
    );
  }

  void _validate() {
    final isSuccess = _isCircuitClosed;
    final message = isSuccess
        ? 'Perfeito! A continuidade foi restabelecida com sucesso e o percurso dos elétrons está 100% completo!'
        : 'Circuito Aberto! O fio ainda está partido entre a chave e o fusível, impedindo a passagem de corrente.';

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
    final statusState = _isCircuitClosed
        ? CircuitoSeguroState.safe
        : CircuitoSeguroState.openCircuit;

    final voltage = _isCircuitClosed ? 9.0 : 0.0;
    final current = _isCircuitClosed ? 13.0 : 0.0;

    return Row(
      children: [
        // 1. Bancada Principal
        Expanded(
          flex: 7,
          child: WorkbenchTableFrame(
            usePhysicalStyle: _usePhysicalStyle,
            onStyleChanged: (val) => setState(() => _usePhysicalStyle = val),
            leftHeaderWidget: CircuitoSeguroStatusCard(state: statusState),
            rightHeaderWidget: CircuitoSeguroTelemetryCard(
              voltage: voltage,
              currentMa: current,
              isSafe: _isCircuitClosed,
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
                    missionIndex: 1,
                    animValue: _electronAnimController.value,
                    usePhysicalStyle: _usePhysicalStyle,
                    isArmingSwitchClosed: true,
                    isShortCircuitActive: false,
                    isWireBroken: true,
                    isWireRepaired: _isWireRepaired,
                    isFuseInserted: true,
                    isFuseBlown: false,
                    isFuseCorrectRating: true,
                    isLedInserted: true,
                    isResistorInserted: true,
                    isTestingContinuity: _isTestingProbes,
                    isContinuityOk: _isWireRepaired,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        // 2. Painel Lateral
        Expanded(
          flex: 3,
          child: WorkbenchSidePanel(
            teamTitle: 'Equipe Segurança',
            showTeamHeader: false,
            buttonColor: const Color(0xFFF59E0B),
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
            'Missão 2 · Continuidade & Fio Rompido',
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Use as pontas de teste para detectar onde o caminho está interrompido e repare o cabo para fechar o circuito.',
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
          _buildStepRow(1, 'Aplicar pontas de teste de continuidade', _isTestingProbes),
          _buildStepRow(2, 'Identificar cabo partido no ramo positivo', _isTestingProbes),
          _buildStepRow(3, 'Substituir cabo e confirmar passagem de corrente', _isWireRepaired),
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
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: _isTestingProbes ? const Color(0xFF38BDF8) : const Color(0xFF64748B),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: _toggleProbeTest,
          icon: Icon(
            Icons.speed_rounded,
            color: _isTestingProbes ? const Color(0xFF38BDF8) : Colors.white,
          ),
          label: Text(
            _isTestingProbes ? 'Ocultar Pontas de Teste' : 'Testar com Pontas de Prova',
            style: GoogleFonts.rajdhani(
              fontWeight: FontWeight.bold,
              color: _isTestingProbes ? const Color(0xFF38BDF8) : Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: _isWireRepaired
                ? const Color(0xFF10B981)
                : const Color(0xFF0284C7),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: _toggleRepairWire,
          icon: Icon(_isWireRepaired ? Icons.check_rounded : Icons.build_rounded),
          label: Text(
            _isWireRepaired ? 'Cabo Reparado (Contínuo)' : 'Reparar Cabo Rompido',
            style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
