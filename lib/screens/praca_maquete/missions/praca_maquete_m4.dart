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

/// Missão 04 — Inspeção Final: Diagnosticar e solucionar 3 pendências elétricas antes da feira
class PracaMaqueteM4 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const PracaMaqueteM4({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<PracaMaqueteM4> createState() => _PracaMaqueteM4State();
}

class _PracaMaqueteM4State extends State<PracaMaqueteM4>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  bool _usePhysicalStyle = true;
  bool _faultJumperFixed = false;
  bool _faultFuseReplaced = false;
  bool _faultBreakerCalibrated = false;

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

  bool get _isAllAudited =>
      _faultJumperFixed && _faultFuseReplaced && _faultBreakerCalibrated;

  void _toggleJumper() {
    final prev = _faultJumperFixed;
    _undoRedoController.execute(
      ToggleBoolAction(
        description: prev ? 'Soltar Jumper Principal' : 'Encaixar Jumper do Barramento',
        onApply: () => setState(() => _faultJumperFixed = !prev),
        onUndo: () => setState(() => _faultJumperFixed = prev),
      ),
    );
  }

  void _toggleFuse() {
    final prev = _faultFuseReplaced;
    _undoRedoController.execute(
      ToggleBoolAction(
        description: prev ? 'Remover Fusível Novo' : 'Substituir Fusível Rompido',
        onApply: () => setState(() => _faultFuseReplaced = !prev),
        onUndo: () => setState(() => _faultFuseReplaced = prev),
      ),
    );
  }

  void _toggleBreaker() {
    final prev = _faultBreakerCalibrated;
    _undoRedoController.execute(
      ToggleBoolAction(
        description: prev ? 'Desarmar Chave Geral' : 'Rearmar Chave Geral da Praça',
        onApply: () => setState(() => _faultBreakerCalibrated = !prev),
        onUndo: () => setState(() => _faultBreakerCalibrated = prev),
      ),
    );
  }

  void _validate() {
    final isSuccess = _isAllAudited;
    final message = isSuccess
        ? 'Inspeção concluída com louvor! O jumper foi reconectado, o fusível de proteção substituído e a chave geral rearmada. A maquete coletiva está livre de falhas!'
        : 'Ainda há pendências na maquete! Verifique o checklist de inspeção e resolva todas as 3 falhas antes de aprovar.';

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
    final status = _isAllAudited
        ? PracaState.fullyEnergized
        : PracaState.faultDetected;

    return WorkbenchResponsiveLayout(
      workbench: WorkbenchTableFrame(
        usePhysicalStyle: _usePhysicalStyle,
        onStyleChanged: (val) => setState(() => _usePhysicalStyle = val),
        leftHeaderWidget: PracaStatusCard(state: status),
        rightHeaderWidget: PracaTelemetryCard(
          housesOn: _faultJumperFixed,
          streetlightsOn: _faultFuseReplaced,
          greenhouseOn: _faultBreakerCalibrated,
          gateOn: _faultBreakerCalibrated,
          totalPowerWatts: _isAllAudited ? 120.0 : 40.0,
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
                missionIndex: 3,
                animValue: _animController.value,
                usePhysicalStyle: _usePhysicalStyle,
                housesOn: _faultJumperFixed,
                streetlightsOn: _faultFuseReplaced,
                greenhouseOn: _faultBreakerCalibrated,
                gateOn: _faultBreakerCalibrated,
                alphaMonumentOn: _isAllAudited,
                isMainGridEnergized: _isAllAudited,
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
            'Missão 4 · Inspeção Final',
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Auditoria Técnica Pré-Feira: localize e solucione as 3 não-conformidades encontradas na infraestrutura elétrica da maquete.',
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
            'Checklist de Auditoria:',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF38BDF8),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildStepRow(1, 'Encaixar jumper do barramento principal', _faultJumperFixed),
          _buildStepRow(2, 'Substituir fusível de iluminação', _faultFuseReplaced),
          _buildStepRow(3, 'Rearmar chave geral da praça', _faultBreakerCalibrated),
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
              backgroundColor: _faultJumperFixed ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _toggleJumper,
            icon: Icon(_faultJumperFixed ? Icons.check_rounded : Icons.link_off_rounded),
            label: Text(
              _faultJumperFixed ? 'Jumper do Barramento OK' : 'Reconectar Jumper Principal',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: _faultFuseReplaced ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _toggleFuse,
            icon: Icon(_faultFuseReplaced ? Icons.check_rounded : Icons.healing_rounded),
            label: Text(
              _faultFuseReplaced ? 'Fusível Íntegro Instalado' : 'Substituir Fusível Rompido',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: _faultBreakerCalibrated ? const Color(0xFF10B981) : const Color(0xFF38BDF8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _toggleBreaker,
            icon: Icon(_faultBreakerCalibrated ? Icons.check_rounded : Icons.toggle_off_rounded),
            label: Text(
              _faultBreakerCalibrated ? 'Chave Geral Rearmada' : 'Rearmar Chave Geral da Praça',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
