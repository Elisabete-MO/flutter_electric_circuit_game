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

/// Missão 03 — Horta e Portão: Integrar os subsistemas inteligentes da estufa e do portão na maquete
class PracaMaqueteM3 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const PracaMaqueteM3({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<PracaMaqueteM3> createState() => _PracaMaqueteM3State();
}

class _PracaMaqueteM3State extends State<PracaMaqueteM3>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  bool _usePhysicalStyle = true;
  bool _isGreenhouseConnected = false;
  bool _isGateConnected = false;

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

  bool get _areBothIntegrated => _isGreenhouseConnected && _isGateConnected;

  void _toggleGreenhouse() {
    final prev = _isGreenhouseConnected;
    _undoRedoController.execute(
      ToggleBoolAction(
        description: prev ? 'Desconectar Estufa Bio-Tech' : 'Integrar Estufa Bio-Tech',
        onApply: () => setState(() => _isGreenhouseConnected = !prev),
        onUndo: () => setState(() => _isGreenhouseConnected = prev),
      ),
    );
  }

  void _toggleGate() {
    final prev = _isGateConnected;
    _undoRedoController.execute(
      ToggleBoolAction(
        description: prev ? 'Desconectar Portão da Escola' : 'Integrar Portão da Escola',
        onApply: () => setState(() => _isGateConnected = !prev),
        onUndo: () => setState(() => _isGateConnected = prev),
      ),
    );
  }

  void _validate() {
    final isSuccess = _areBothIntegrated;
    final message = isSuccess
        ? 'Incrível! Os subsistemas dos Estandes 09 (Bio-Tech) e 10 (Automação) estão perfeitamente acoplados à rede da Maquete Coletiva! A estufa monitora as plantas e o portão controla os acessos!'
        : 'Conecte tanto o ramal da Estufa Comunitária quanto o do Portão Automatizado para concluir a integração.';

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
    final status = _areBothIntegrated
        ? PracaState.subsystemsIntegrated
        : PracaState.residentialLit;

    return WorkbenchResponsiveLayout(
      workbench: WorkbenchTableFrame(
        usePhysicalStyle: _usePhysicalStyle,
        onStyleChanged: (val) => setState(() => _usePhysicalStyle = val),
        leftHeaderWidget: PracaStatusCard(state: status),
        rightHeaderWidget: PracaTelemetryCard(
          housesOn: true,
          streetlightsOn: true,
          greenhouseOn: _isGreenhouseConnected,
          gateOn: _isGateConnected,
          totalPowerWatts: (_isGreenhouseConnected ? 25.0 : 0.0) + (_isGateConnected ? 40.0 : 0.0) + 70.0,
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
                missionIndex: 2,
                animValue: _animController.value,
                usePhysicalStyle: _usePhysicalStyle,
                housesOn: true,
                streetlightsOn: true,
                greenhouseOn: _isGreenhouseConnected,
                gateOn: _isGateConnected,
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
            'Missão 3 · Horta e Portão',
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Integre os projetos desenvolvidos pelos outros estandes: conecte a estufa automatizada e o portão eletromecânico à praça da cidade.',
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
            'Checklist de Integração Urbana:',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF38BDF8),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildStepRow(1, 'Conectar ramal Estufa Bio-Tech', _isGreenhouseConnected),
          _buildStepRow(2, 'Conectar ramal Portão da Escola', _isGateConnected),
          _buildStepRow(3, 'Comprovar operação simultânea de ambos', _areBothIntegrated),
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
              backgroundColor: _isGreenhouseConnected ? const Color(0xFF10B981) : const Color(0xFF16A34A),
              padding: const EdgeInsets.symmetric(vertical: 11),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _toggleGreenhouse,
            icon: Icon(_isGreenhouseConnected ? Icons.eco_rounded : Icons.add_circle_outline_rounded),
            label: Text(
              _isGreenhouseConnected ? 'Estufa Bio-Tech Conectada' : 'Integrar Estufa Bio-Tech',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: _isGateConnected ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
              padding: const EdgeInsets.symmetric(vertical: 11),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _toggleGate,
            icon: Icon(_isGateConnected ? Icons.sensors_rounded : Icons.add_circle_outline_rounded),
            label: Text(
              _isGateConnected ? 'Portão da Escola Conectado' : 'Integrar Portão da Escola',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
