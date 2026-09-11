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

/// Missão 05 — Botão do Visitante: Botoeira industrial completa com abertura e parada de emergência
class PortaoEscolaM5 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const PortaoEscolaM5({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<PortaoEscolaM5> createState() => _PortaoEscolaM5State();
}

class _PortaoEscolaM5State extends State<PortaoEscolaM5>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  bool _usePhysicalStyle = true;
  bool _isOpenCommandActive = false;
  bool _isEmergencyStopActive = false;
  bool _hasTestedOpen = false;
  bool _hasTestedEmergency = false;

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

  bool get _isCoilEnergized => _isOpenCommandActive && !_isEmergencyStopActive;
  bool get _isBothTested => _hasTestedOpen && _hasTestedEmergency;

  void _pressOpenButton() {
    final prev = _isOpenCommandActive;
    _undoRedoController.execute(
      ToggleBoolAction(
        description: 'Pressionar Botão Abrir (Verde)',
        onApply: () => setState(() {
          _isOpenCommandActive = true;
          _hasTestedOpen = true;
        }),
        onUndo: () => setState(() => _isOpenCommandActive = prev),
      ),
    );
  }

  void _pressEmergencyStop() {
    final prev = _isEmergencyStopActive;
    _undoRedoController.execute(
      ToggleBoolAction(
        description: 'Acionar Parada de Emergência (Vermelho)',
        onApply: () => setState(() {
          _isEmergencyStopActive = true;
          _isOpenCommandActive = false;
          _hasTestedEmergency = true;
        }),
        onUndo: () => setState(() => _isEmergencyStopActive = prev),
      ),
    );
  }

  void _resetEmergencyStop() {
    setState(() {
      _isEmergencyStopActive = false;
    });
  }

  void _validate() {
    final isSuccess = _isBothTested && !_isEmergencyStopActive && _isOpenCommandActive;
    final message = isSuccess
        ? 'Excelente auditoria da Equipe Automação! O sistema de controle de acesso do Portão da Escola atende a todos os requisitos de segurança: acionamento por relé e intertravamento de emergência aprovados!'
        : 'Teste a rotina completa de segurança: experimente acionar a abertura, testar a parada de emergência e restaurar a operação.';

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
    final status = _isEmergencyStopActive
        ? PortaoState.emergencyStop
        : (_isCoilEnergized ? PortaoState.motorRunning : PortaoState.idle);

    return WorkbenchResponsiveLayout(
      workbench: WorkbenchTableFrame(
        usePhysicalStyle: _usePhysicalStyle,
        onStyleChanged: (val) => setState(() => _usePhysicalStyle = val),
        leftHeaderWidget: PortaoStatusCard(state: status),
        rightHeaderWidget: PortaoTelemetryCard(
          isCoilEnergized: _isCoilEnergized,
          isContactClosed: _isCoilEnergized,
          isMotorRunning: _isCoilEnergized,
          gatePositionPercent: _isCoilEnergized ? 75.0 : 0.0,
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
                missionIndex: 4,
                animValue: _animController.value,
                usePhysicalStyle: _usePhysicalStyle,
                isCommandPressed: _isOpenCommandActive,
                isCoilEnergized: _isCoilEnergized,
                isContactClosed: _isCoilEnergized,
                isMotorRunning: _isCoilEnergized,
                gatePositionPercent: _isCoilEnergized ? 75.0 : 0.0,
                isLightSignalOn: _isCoilEnergized,
                isEmergencyStopActive: _isEmergencyStopActive,
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
            'Missão 5 · Botão do Visitante',
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Comissionamento Final: valide a botoeira industrial com botão verde de abertura e botão cogumelo vermelho de parada de emergência (NF).',
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
            'Auditoria de Segurança:',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF38BDF8),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildStepRow(1, 'Testar comando de abertura (Verde)', _hasTestedOpen),
          _buildStepRow(2, 'Testar parada de emergência (Vermelho)', _hasTestedEmergency),
          _buildStepRow(3, 'Comissionar sistema em operação normal', _isCoilEnergized),
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
              backgroundColor: const Color(0xFF10B981),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _isEmergencyStopActive ? null : _pressOpenButton,
            icon: const Icon(Icons.meeting_room_rounded),
            label: Text(
              'Botoeira de Abertura (Verde)',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _pressEmergencyStop,
            icon: const Icon(Icons.front_hand_rounded),
            label: Text(
              'Parada de Emergência (Vermelho)',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          if (_isEmergencyStopActive) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF38BDF8),
                side: const BorderSide(color: Color(0xFF38BDF8)),
              ),
              onPressed: _resetEmergencyStop,
              icon: const Icon(Icons.lock_open_rounded, size: 16),
              label: Text('Destravar Botão de Emergência', style: GoogleFonts.rajdhani(fontSize: 12)),
            ),
          ],
        ],
      ),
    );
  }
}
