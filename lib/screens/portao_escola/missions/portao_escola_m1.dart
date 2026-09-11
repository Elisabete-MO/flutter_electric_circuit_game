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

/// Missão 01 — O Relé Responde: Energizar a bobina eletromagnética e observar o fechamento do contato NA
class PortaoEscolaM1 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const PortaoEscolaM1({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<PortaoEscolaM1> createState() => _PortaoEscolaM1State();
}

class _PortaoEscolaM1State extends State<PortaoEscolaM1>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  bool _usePhysicalStyle = true;
  bool _isButtonPressed = false;

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

  bool get _isCoilActive => _isButtonPressed;
  bool get _isContactClosed => _isCoilActive;

  void _toggleButton() {
    final prev = _isButtonPressed;
    _undoRedoController.execute(
      ToggleBoolAction(
        description: prev ? 'Liberar Botão de Comando' : 'Pressionar Botão de Comando',
        onApply: () => setState(() => _isButtonPressed = !prev),
        onUndo: () => setState(() => _isButtonPressed = prev),
      ),
    );
  }

  void _validate() {
    final isSuccess = _isButtonPressed && _isContactClosed;
    final message = isSuccess
        ? 'Excelente! Ao energizar a bobina com o pulso de 5V, o eletroímã atraiu a armadura móvel com um "clique" metálico, fechando o contato NA! Esse é o segredo do relé.'
        : 'Pressione o Botão de Comando (Verde) para enviar 5V à bobina do relé e observe o contato NA fechar!';

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
    final status = _isContactClosed
        ? PortaoState.contactClosed
        : (_isCoilActive ? PortaoState.coilEnergized : PortaoState.idle);

    return WorkbenchResponsiveLayout(
      workbench: WorkbenchTableFrame(
        usePhysicalStyle: _usePhysicalStyle,
        onStyleChanged: (val) => setState(() => _usePhysicalStyle = val),
        leftHeaderWidget: PortaoStatusCard(state: status),
        rightHeaderWidget: PortaoTelemetryCard(
          isCoilEnergized: _isCoilActive,
          isContactClosed: _isContactClosed,
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
                missionIndex: 0,
                animValue: _animController.value,
                usePhysicalStyle: _usePhysicalStyle,
                isCommandPressed: _isButtonPressed,
                isCoilEnergized: _isCoilActive,
                isContactClosed: _isContactClosed,
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
            'Missão 1 · O Relé Responde',
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Acione o botão de comando para alimentar a bobina de 5V. Observe como o campo magnético atrai a lâmina metálica e fecha o contato Normalmente Aberto (NA).',
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
            'Checklist de Acionamento:',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF38BDF8),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildStepRow(1, 'Inspecionar terminais da bobina', true),
          _buildStepRow(2, 'Pressionar botoeira de pulso (5V)', _isButtonPressed),
          _buildStepRow(3, 'Comprovar atração magnética e contato NA fechado', _isContactClosed),
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
              backgroundColor: _isButtonPressed ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _toggleButton,
            icon: Icon(_isButtonPressed ? Icons.touch_app_rounded : Icons.fingerprint_rounded),
            label: Text(
              _isButtonPressed ? 'Botão Pressionado (Bobina ON)' : 'Pressionar Botão de Comando',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              _isContactClosed ? '✓ CONTATO NA FECHADO (CONDUZ)' : 'Contato NA Aberto (Em repouso)',
              style: GoogleFonts.rajdhani(
                color: _isContactClosed ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
