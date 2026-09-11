import 'dart:async';
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

/// Missão 04 — Portão em Movimento: Controlar o motor redutor do portão deslizante através do relé
class PortaoEscolaM4 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const PortaoEscolaM4({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<PortaoEscolaM4> createState() => _PortaoEscolaM4State();
}

class _PortaoEscolaM4State extends State<PortaoEscolaM4>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  bool _usePhysicalStyle = true;
  bool _isMotorArmed = false;
  double _gatePosition = 0.0; // 0 a 100%
  Timer? _moveTimer;

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
    _moveTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  bool get _isGateFullyOpen => _gatePosition >= 95.0;

  void _toggleMotor() {
    final prev = _isMotorArmed;
    _undoRedoController.execute(
      ToggleBoolAction(
        description: prev ? 'Parar Motor' : 'Ligar Motor do Portão',
        onApply: () {
          setState(() => _isMotorArmed = !prev);
          _startOrStopGateMotion(!prev);
        },
        onUndo: () {
          setState(() => _isMotorArmed = prev);
          _startOrStopGateMotion(prev);
        },
      ),
    );
  }

  void _startOrStopGateMotion(bool run) {
    _moveTimer?.cancel();
    if (run) {
      _moveTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
        setState(() {
          _gatePosition += 2.5;
          if (_gatePosition >= 100.0) {
            _gatePosition = 100.0;
            _isMotorArmed = false;
            timer.cancel();
          }
        });
      });
    }
  }

  void _resetGate() {
    _moveTimer?.cancel();
    setState(() {
      _gatePosition = 0.0;
      _isMotorArmed = false;
    });
  }

  void _validate() {
    final isSuccess = _isGateFullyOpen;
    final message = isSuccess
        ? 'Perfeito! O motor DC recebeu alimentação segura através dos contatos do relé e deslizou o portão suavemente até a abertura completa!'
        : 'Acione o motor através do relé e aguarde o portão abrir completamente até 100%!';

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
    final status = _isGateFullyOpen
        ? PortaoState.gateOpen
        : (_isMotorArmed ? PortaoState.motorRunning : PortaoState.idle);

    return WorkbenchResponsiveLayout(
      workbench: WorkbenchTableFrame(
        usePhysicalStyle: _usePhysicalStyle,
        onStyleChanged: (val) => setState(() => _usePhysicalStyle = val),
        leftHeaderWidget: PortaoStatusCard(state: status),
        rightHeaderWidget: PortaoTelemetryCard(
          isCoilEnergized: _isMotorArmed,
          isContactClosed: _isMotorArmed,
          isMotorRunning: _isMotorArmed,
          gatePositionPercent: _gatePosition,
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
                missionIndex: 3,
                animValue: _animController.value,
                usePhysicalStyle: _usePhysicalStyle,
                isCommandPressed: _isMotorArmed,
                isCoilEnergized: _isMotorArmed,
                isContactClosed: _isMotorArmed,
                isMotorRunning: _isMotorArmed,
                gatePositionPercent: _gatePosition,
                isLightSignalOn: _isMotorArmed,
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
            'Missão 4 · Portão em Movimento',
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Conecte o atuador eletromecânico (motor DC redutor) para deslocar o portão até 100% de abertura sem expor o comando à corrente do motor.',
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
            'Checklist Mecatrônico:',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF38BDF8),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildStepRow(1, 'Ligar motor DC no contato de carga', true),
          _buildStepRow(2, 'Acionar rotação da engrenagem', _isMotorArmed || _gatePosition > 0),
          _buildStepRow(3, 'Completar abertura do portão (100%)', _isGateFullyOpen),
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
              backgroundColor: _isMotorArmed ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _toggleMotor,
            icon: Icon(_isMotorArmed ? Icons.sync_rounded : Icons.play_arrow_rounded),
            label: Text(
              _isMotorArmed ? 'Motor em Rotação...' : 'Acionar Motor do Portão',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: const BorderSide(color: Color(0xFF475569)),
            ),
            onPressed: _resetGate,
            icon: const Icon(Icons.restart_alt_rounded, size: 18),
            label: Text('Reiniciar Portão (Fechar)', style: GoogleFonts.rajdhani(fontSize: 12)),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _gatePosition / 100.0,
            backgroundColor: const Color(0xFF334155),
            valueColor: const AlwaysStoppedAnimation(Color(0xFF10B981)),
            minHeight: 6,
          ),
        ],
      ),
    );
  }
}
