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

/// Missão 01 — Casas Iluminadas: Energizar e balancear a rede residencial em paralelo da maquete
class PracaMaqueteM1 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const PracaMaqueteM1({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<PracaMaqueteM1> createState() => _PracaMaqueteM1State();
}

class _PracaMaqueteM1State extends State<PracaMaqueteM1>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  bool _usePhysicalStyle = true;
  bool _isResidentialBreakerClosed = false;

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

  void _toggleBreaker() {
    final prev = _isResidentialBreakerClosed;
    _undoRedoController.execute(
      ToggleBoolAction(
        description: prev ? 'Abrir Disjuntor Residencial' : 'Fechar Disjuntor Residencial',
        onApply: () => setState(() => _isResidentialBreakerClosed = !prev),
        onUndo: () => setState(() => _isResidentialBreakerClosed = prev),
      ),
    );
  }

  void _validate() {
    final isSuccess = _isResidentialBreakerClosed;
    final message = isSuccess
        ? 'Excelente! Todas as casas da vila residencial receberam 12V simultâneos graças à topologia em paralelo. Cada residência opera com iluminação independente!'
        : 'Feche o disjuntor do setor residencial para energizar as casas da maquete!';

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
    final status = _isResidentialBreakerClosed
        ? PracaState.residentialLit
        : PracaState.standby;

    return WorkbenchResponsiveLayout(
      workbench: WorkbenchTableFrame(
        usePhysicalStyle: _usePhysicalStyle,
        onStyleChanged: (val) => setState(() => _usePhysicalStyle = val),
        leftHeaderWidget: PracaStatusCard(state: status),
        rightHeaderWidget: PracaTelemetryCard(
          housesOn: _isResidentialBreakerClosed,
          streetlightsOn: false,
          totalPowerWatts: _isResidentialBreakerClosed ? 48.0 : 0.0,
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
                missionIndex: 0,
                animValue: _animController.value,
                usePhysicalStyle: _usePhysicalStyle,
                housesOn: _isResidentialBreakerClosed,
                streetlightsOn: false,
                greenhouseOn: false,
                gateOn: false,
                isMainGridEnergized: _isResidentialBreakerClosed,
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
            'Missão 1 · Casas Iluminadas',
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Energize o ramal residencial da maquete. Comprove que a distribuição em paralelo garante a mesma tensão plena a todas as casas da comunidade.',
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
            'Checklist de Rede Residencial:',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF38BDF8),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildStepRow(1, 'Verificar fiação de distribuição paralela', true),
          _buildStepRow(2, 'Fechar disjuntor da vila residencial', _isResidentialBreakerClosed),
          _buildStepRow(3, 'Comprovar iluminação simultânea das 3 casas', _isResidentialBreakerClosed),
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
              backgroundColor: _isResidentialBreakerClosed ? const Color(0xFF10B981) : const Color(0xFF8B5CF6),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _toggleBreaker,
            icon: Icon(_isResidentialBreakerClosed ? Icons.lightbulb_rounded : Icons.power_settings_new_rounded),
            label: Text(
              _isResidentialBreakerClosed ? 'Disjuntor Residencial Fechado (ON)' : 'Fechar Disjuntor Residencial',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              _isResidentialBreakerClosed ? '✓ 3 CASAS ENERGIZADAS EM PARALELO' : 'Circuito Residencial Desligado',
              style: GoogleFonts.rajdhani(
                color: _isResidentialBreakerClosed ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
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
