import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/circuit_action.dart';
import '../../../state/circuit_undo_redo_controller.dart';
import '../../../widgets/prof_volts_feedback_dialog.dart';
import '../../../widgets/success_confetti_overlay.dart';
import '../../../widgets/workbench_components.dart';
import '../../../widgets/workbench_table_frame.dart';
import '../widgets/portao_escola_painter.dart';
import '../widgets/portao_escola_widgets.dart';

/// Missão 02 — Dois Circuitos Isolados: Compreender o isolamento galvânico entre comando e potência
class PortaoEscolaM2 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const PortaoEscolaM2({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<PortaoEscolaM2> createState() => _PortaoEscolaM2State();
}

class _PortaoEscolaM2State extends State<PortaoEscolaM2>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  bool _usePhysicalStyle = true;
  bool _isIsolationBarrierVerified = false;
  bool _isCommandActive = false;

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

  void _toggleBarrierVerification() {
    final prev = _isIsolationBarrierVerified;
    _undoRedoController.execute(
      ToggleBoolAction(
        description: prev ? 'Remover Inspeção de Barreira' : 'Verificar Barreira de Isolamento',
        onApply: () => setState(() => _isIsolationBarrierVerified = !prev),
        onUndo: () => setState(() => _isIsolationBarrierVerified = prev),
      ),
    );
  }

  void _toggleCommand() {
    setState(() => _isCommandActive = !_isCommandActive);
  }

  void _validate() {
    final isSuccess = _isIsolationBarrierVerified && _isCommandActive;
    final message = isSuccess
        ? 'Perfeito! O relé opera como uma chave mecânica acionada à distância: nenhum elétron do circuito de comando (5V) passa para a carga (12V). Essa barreira galvânica protege o operador e a eletrônica!'
        : 'Verifique a barreira de isolamento galvânico e acione o comando para comprovar o funcionamento independente das duas malhas.';

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
    final status = _isCommandActive ? PortaoState.coilEnergized : PortaoState.idle;

    return WorkbenchResponsiveLayout(
      workbench: WorkbenchTableFrame(
        usePhysicalStyle: _usePhysicalStyle,
        onStyleChanged: (val) => setState(() => _usePhysicalStyle = val),
        leftHeaderWidget: PortaoStatusCard(state: status),
        rightHeaderWidget: PortaoTelemetryCard(
          isCoilEnergized: _isCommandActive,
          isContactClosed: _isCommandActive,
          isMotorRunning: false,
          gatePositionPercent: 0.0,
        ),
        bottomWidget: PortaoUndoRedoButtons(
          controller: _undoRedoController,
          onUndo: () => setState(() => _undoRedoController.undo()),
          onRedo: () => setState(() => _undoRedoController.redo()),
        ),
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return CustomPaint(
              painter: PortaoEscolaPainter(
                missionIndex: 1,
                animValue: _animController.value,
                usePhysicalStyle: _usePhysicalStyle,
                isCommandPressed: _isCommandActive,
                isCoilEnergized: _isCommandActive,
                isContactClosed: _isCommandActive,
                isMotorRunning: false,
                gatePositionPercent: 0.0,
              ),
            );
          },
        ),
      ),
      sidePanel: WorkbenchSidePanel(
        teamTitle: 'Equipe Automação',
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
            'Missão 2 · Dois Circuitos Isolados',
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Comprove que o circuito de comando (5V) e o circuito de potência (12V) não têm conexão elétrica direta — apenas acoplamento magnético.',
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
            'Checklist de Isolamento:',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF38BDF8),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildStepRow(1, 'Confirmar ausência de fios cruzados', true),
          _buildStepRow(2, 'Validar barreira galvânica no relé', _isIsolationBarrierVerified),
          _buildStepRow(3, 'Testar comando com carga segura', _isCommandActive),
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
              backgroundColor: _isIsolationBarrierVerified ? const Color(0xFF10B981) : const Color(0xFF38BDF8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _toggleBarrierVerification,
            icon: Icon(_isIsolationBarrierVerified ? Icons.verified_user_rounded : Icons.shield_outlined),
            label: Text(
              _isIsolationBarrierVerified ? 'Isolamento Galvânico Atestado' : 'Atestar Isolamento do Relé',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: _isCommandActive ? const Color(0xFFF59E0B) : const Color(0xFF334155),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _toggleCommand,
            icon: Icon(_isCommandActive ? Icons.electric_bolt_rounded : Icons.power_settings_new_rounded),
            label: Text(
              _isCommandActive ? 'Comando 5V Ativo' : 'Ativar Pulso de Comando',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
