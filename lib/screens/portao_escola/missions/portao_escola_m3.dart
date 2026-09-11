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

/// Missão 03 — Luz de Sinalização: Acionar o giroflex de alerta com o contato NA do relé
class PortaoEscolaM3 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const PortaoEscolaM3({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<PortaoEscolaM3> createState() => _PortaoEscolaM3State();
}

class _PortaoEscolaM3State extends State<PortaoEscolaM3>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  bool _usePhysicalStyle = true;
  bool _isBeaconWired = false;
  bool _isCommandArmed = false;

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

  bool get _isBeaconActive => _isBeaconWired && _isCommandArmed;

  void _toggleBeaconWiring() {
    final prev = _isBeaconWired;
    _undoRedoController.execute(
      ToggleBoolAction(
        description: prev ? 'Desconectar Giroflex' : 'Ligar Giroflex no Contato NA',
        onApply: () => setState(() => _isBeaconWired = !prev),
        onUndo: () => setState(() => _isBeaconWired = prev),
      ),
    );
  }

  void _toggleCommand() {
    setState(() => _isCommandArmed = !_isCommandArmed);
  }

  void _validate() {
    final isSuccess = _isBeaconWired && _isCommandArmed && _isBeaconActive;
    final message = isSuccess
        ? 'Excelente! Ao ligar o giroflex de segurança ao contato NA do relé, a sinalização luminosa amarela alerta imediatamente pedestres e veículos durante o acionamento!'
        : (!_isBeaconWired
            ? 'Conecte o giroflex amarelo ao contato Normalmente Aberto (NA) do relé!'
            : 'Acione a chave de comando para fechar o contato e acender a luz de alerta!');

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
    final status = _isBeaconActive
        ? PortaoState.contactClosed
        : (_isCommandArmed ? PortaoState.coilEnergized : PortaoState.idle);

    return WorkbenchResponsiveLayout(
      workbench: WorkbenchTableFrame(
        usePhysicalStyle: _usePhysicalStyle,
        onStyleChanged: (val) => setState(() => _usePhysicalStyle = val),
        leftHeaderWidget: PortaoStatusCard(state: status),
        rightHeaderWidget: PortaoTelemetryCard(
          isCoilEnergized: _isCommandArmed,
          isContactClosed: _isCommandArmed,
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
                missionIndex: 2,
                animValue: _animController.value,
                usePhysicalStyle: _usePhysicalStyle,
                isCommandPressed: _isCommandArmed,
                isCoilEnergized: _isCommandArmed,
                isContactClosed: _isCommandArmed,
                isMotorRunning: false,
                gatePositionPercent: 0.0,
                isLightSignalOn: _isBeaconActive,
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
            'Missão 3 · Luz de Sinalização',
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ligue o sinalizador luminoso (giroflex de aviso) através do contato Normalmente Aberto (NA) do relé para alertar sobre o portão em movimento.',
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
            'Checklist de Sinalização:',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF38BDF8),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildStepRow(1, 'Conectar giroflex ao terminal NA', _isBeaconWired),
          _buildStepRow(2, 'Energizar comando da bobina', _isCommandArmed),
          _buildStepRow(3, 'Comprovar sinalizador luminoso ativo', _isBeaconActive),
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
              backgroundColor: _isBeaconWired ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _toggleBeaconWiring,
            icon: Icon(_isBeaconWired ? Icons.check_circle_rounded : Icons.cable_rounded),
            label: Text(
              _isBeaconWired ? 'Giroflex Conectado ao NA' : 'Conectar Giroflex ao Contato NA',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: _isCommandArmed ? const Color(0xFF22C55E) : const Color(0xFF334155),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _toggleCommand,
            icon: const Icon(Icons.flash_on_rounded),
            label: Text(
              _isCommandArmed ? 'Comando da Bobina Ativo' : 'Pressionar Botão da Bobina',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
