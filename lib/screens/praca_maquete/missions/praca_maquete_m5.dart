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

/// Missão 05 — Visita da Comunidade: A grande inauguração e energização da Maquete Coletiva da Feira
class PracaMaqueteM5 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const PracaMaqueteM5({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<PracaMaqueteM5> createState() => _PracaMaqueteM5State();
}

class _PracaMaqueteM5State extends State<PracaMaqueteM5>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  bool _usePhysicalStyle = true;
  bool _isMasterInaugurationSwitched = false;
  bool _isAlphaMonumentLit = false;

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

  void _toggleMasterInauguration() {
    final prev = _isMasterInaugurationSwitched;
    _undoRedoController.execute(
      ToggleBoolAction(
        description: prev ? 'Desligar Cerimônia' : 'Ligar Chave Mestra da Comunidade',
        onApply: () => setState(() {
          _isMasterInaugurationSwitched = !prev;
          _isAlphaMonumentLit = !prev;
        }),
        onUndo: () => setState(() {
          _isMasterInaugurationSwitched = prev;
          _isAlphaMonumentLit = prev;
        }),
      ),
    );
  }

  void _validate() {
    final isSuccess = _isMasterInaugurationSwitched && _isAlphaMonumentLit;
    final message = isSuccess
        ? 'PARABÉNS A TODAS AS EQUIPES! A Maquete Coletiva Alpha Lumen está oficialmente inaugurada e 100% energizada! Toda a comunidade da escola e o Prof. Volts celebram a união da física, automação, sustentabilidade e eletrônica!'
        : 'Acione a grande Chave Mestra de Inauguração para iluminar toda a maquete e o Monumento Alpha Lumen!';

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
    final status = _isMasterInaugurationSwitched
        ? PracaState.fullyEnergized
        : PracaState.standby;

    return WorkbenchResponsiveLayout(
      workbench: WorkbenchTableFrame(
        usePhysicalStyle: _usePhysicalStyle,
        onStyleChanged: (val) => setState(() => _usePhysicalStyle = val),
        leftHeaderWidget: PracaStatusCard(state: status),
        rightHeaderWidget: PracaTelemetryCard(
          housesOn: _isMasterInaugurationSwitched,
          streetlightsOn: _isMasterInaugurationSwitched,
          greenhouseOn: _isMasterInaugurationSwitched,
          gateOn: _isMasterInaugurationSwitched,
          totalPowerWatts: _isMasterInaugurationSwitched ? 180.0 : 0.0,
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
                missionIndex: 4,
                animValue: _animController.value,
                usePhysicalStyle: _usePhysicalStyle,
                housesOn: _isMasterInaugurationSwitched,
                streetlightsOn: _isMasterInaugurationSwitched,
                greenhouseOn: _isMasterInaugurationSwitched,
                gateOn: _isMasterInaugurationSwitched,
                alphaMonumentOn: _isAlphaMonumentLit,
                isMainGridEnergized: _isMasterInaugurationSwitched,
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
            'Missão 5 · Visita da Comunidade',
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'A Grande Cerimônia: acione a Chave Mestra da Praça para inaugurar a maquete com todos os setores iluminados e o Monumento Alpha Lumen brilhando!',
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
            'Cerimônia de Inauguração:',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF38BDF8),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildStepRow(1, 'Confirmar presença dos visitantes da comunidade', true),
          _buildStepRow(2, 'Acionar Chave Mestra de Distribuição', _isMasterInaugurationSwitched),
          _buildStepRow(3, 'Comprovar cidade iluminada e Monumento Alpha ativo', _isMasterInaugurationSwitched && _isAlphaMonumentLit),
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
              backgroundColor: _isMasterInaugurationSwitched ? const Color(0xFF10B981) : const Color(0xFF8B5CF6),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _toggleMasterInauguration,
            icon: Icon(_isMasterInaugurationSwitched ? Icons.celebration_rounded : Icons.offline_bolt_rounded),
            label: Text(
              _isMasterInaugurationSwitched ? 'CIDADE ALPHA ENERGIZADA (100%)' : 'ENERGIZAR MAQUETE COLETIVA',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              _isMasterInaugurationSwitched ? '✨ TODAS AS EQUIPES INTEGRADAS COM SUCESSO ✨' : 'Aguardando chave mestra da cerimônia...',
              style: GoogleFonts.rajdhani(
                color: _isMasterInaugurationSwitched ? const Color(0xFFA78BFA) : const Color(0xFF94A3B8),
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
