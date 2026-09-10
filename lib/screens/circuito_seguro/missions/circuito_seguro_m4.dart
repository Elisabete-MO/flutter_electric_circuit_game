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

/// Missão 04 — Proteção & Sinalização Dupla: Chave com trava, fusível e cargas combinadas
class CircuitoSeguroM4 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const CircuitoSeguroM4({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<CircuitoSeguroM4> createState() => _CircuitoSeguroM4State();
}

class _CircuitoSeguroM4State extends State<CircuitoSeguroM4>
    with SingleTickerProviderStateMixin {
  late final AnimationController _electronAnimController;
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  bool _usePhysicalStyle = true;
  bool _isSwitchArmed = false;
  bool _isFuseInserted = true;
  bool _isBuzzerConnected = false;

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

  bool get _isSystemArmedAndSafe =>
      _isSwitchArmed && _isFuseInserted && _isBuzzerConnected;

  void _toggleSwitch() {
    final prev = _isSwitchArmed;
    _undoRedoController.execute(
      ToggleBoolAction(
        description: prev ? 'Desarmar Chave de Segurança' : 'Armar Chave de Segurança',
        onApply: () => setState(() => _isSwitchArmed = !prev),
        onUndo: () => setState(() => _isSwitchArmed = prev),
      ),
    );
  }

  void _toggleBuzzer() {
    final prev = _isBuzzerConnected;
    _undoRedoController.execute(
      ToggleBoolAction(
        description: prev ? 'Desconectar Buzzer' : 'Conectar Buzzer de Alarme',
        onApply: () => setState(() => _isBuzzerConnected = !prev),
        onUndo: () => setState(() => _isBuzzerConnected = prev),
      ),
    );
  }

  void _validate() {
    final isSuccess = _isSystemArmedAndSafe;
    String message;
    if (!_isSwitchArmed) {
      message = 'A chave seccionadora ainda está travada (OFF). Levante a trava e acione a chave!';
    } else if (!_isBuzzerConnected) {
      message = 'O buzzer de alarme não está conectado. Conecte o sinalizador sonoro para completar a sinalização dupla!';
    } else {
      message = 'Sensacional! O painel está totalmente armado com chave de segurança, fusível e sinalização visual (LED) e sonora (Buzzer)!';
    }

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
    final statusState = _isSystemArmedAndSafe
        ? CircuitoSeguroState.safe
        : (_isSwitchArmed ? CircuitoSeguroState.openCircuit : CircuitoSeguroState.inactive);

    final voltage = _isSwitchArmed ? 9.0 : 0.0;
    final current = _isSystemArmedAndSafe ? 28.0 : (_isSwitchArmed ? 13.0 : 0.0);

    return WorkbenchResponsiveLayout(
      workbench: WorkbenchTableFrame(
        usePhysicalStyle: _usePhysicalStyle,
        onStyleChanged: (val) => setState(() => _usePhysicalStyle = val),
        leftHeaderWidget: CircuitoSeguroStatusCard(state: statusState),
        rightHeaderWidget: CircuitoSeguroTelemetryCard(
          voltage: voltage,
          currentMa: current,
          isSafe: _isSystemArmedAndSafe,
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
                missionIndex: 3,
                animValue: _electronAnimController.value,
                usePhysicalStyle: _usePhysicalStyle,
                isArmingSwitchClosed: _isSwitchArmed,
                isShortCircuitActive: false,
                isWireBroken: false,
                isWireRepaired: true,
                isFuseInserted: _isFuseInserted,
                isFuseBlown: false,
                isFuseCorrectRating: true,
                isLedInserted: true,
                isResistorInserted: true,
                isBuzzerActive: _isBuzzerConnected && _isSwitchArmed,
              ),
            );
          },
        ),
      ),
      sidePanel: WorkbenchSidePanel(
        teamTitle: 'Equipe Segurança',
        showTeamHeader: false,
        buttonColor: const Color(0xFF0284C7),
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
            'Missão 4 · Proteção & Sinalização Dupla',
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Conecte o sinalizador sonoro (Buzzer) e arme a chave seccionadora de segurança protegida por fusível.',
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
          _buildStepRow(1, 'Conectar buzzer piezoelétrico', _isBuzzerConnected),
          _buildStepRow(2, 'Armar chave seccionadora protegida', _isSwitchArmed),
          _buildStepRow(3, 'Validar sinalização visual e sonora', _isSystemArmedAndSafe),
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
            backgroundColor: _isBuzzerConnected
                ? const Color(0xFF10B981)
                : const Color(0xFF0284C7),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: _toggleBuzzer,
          icon: Icon(_isBuzzerConnected ? Icons.volume_up_rounded : Icons.volume_off_rounded),
          label: Text(
            _isBuzzerConnected ? 'Buzzer Conectado' : 'Conectar Buzzer de Alarme',
            style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: _isSwitchArmed
                ? const Color(0xFF10B981)
                : const Color(0xFFDC2626),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: _toggleSwitch,
          icon: Icon(_isSwitchArmed ? Icons.lock_open_rounded : Icons.lock_rounded),
          label: Text(
            _isSwitchArmed ? 'Chave de Segurança: ARMADA' : 'Armar Chave de Segurança',
            style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
