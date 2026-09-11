import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/circuit_action.dart';
import '../../../state/circuit_undo_redo_controller.dart';
import '../../../widgets/prof_volts_feedback_dialog.dart';
import '../../../widgets/success_confetti_overlay.dart';
import '../../../widgets/workbench_components.dart';
import '../../../widgets/workbench_table_frame.dart';
import '../widgets/horta_monitorada_painter.dart';
import '../widgets/horta_monitorada_widgets.dart';

/// Missão 01 — Brilho Ajustável: Regular o potenciômetro para iluminação ideal da estufa
class HortaMonitoradaM1 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const HortaMonitoradaM1({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<HortaMonitoradaM1> createState() => _HortaMonitoradaM1State();
}

class _HortaMonitoradaM1State extends State<HortaMonitoradaM1>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  bool _usePhysicalStyle = true;
  double _potPercent = 20.0; // Inicia baixo (subiluminado)

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

  bool get _isIdealRange => _potPercent >= 40.0 && _potPercent <= 80.0;

  void _onPotChanged(double value) {
    final prev = _potPercent;
    _undoRedoController.execute(
      UpdateValueAction(
        description: 'Ajustar Potenciômetro para ${value.toStringAsFixed(0)}%',
        onApply: () => setState(() => _potPercent = value),
        onUndo: () => setState(() => _potPercent = prev),
      ),
    );
  }

  void _validate() {
    final isSuccess = _isIdealRange;
    final message = isSuccess
        ? 'Perfeito! Com o potenciômetro entre 40% e 80%, as mudas recebem fótons suficientes para fotossíntese sem risco de estresse térmico!'
        : (_potPercent < 40.0
            ? 'Atenção! A iluminação está muito fraca (< 40%). As plantas não farão fotossíntese adequada.'
            : 'Cuidado! A intensidade do LED está muito alta (> 80%), consumindo energia em excesso e aquecendo a estufa!');

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
    final status = _potPercent < 40.0
        ? HortaState.tooDim
        : (_potPercent > 80.0 ? HortaState.tooBright : HortaState.ideal);

    final brightness = (_potPercent / 100.0).clamp(0.0, 1.0);

    return WorkbenchResponsiveLayout(
      workbench: WorkbenchTableFrame(
        usePhysicalStyle: _usePhysicalStyle,
        onStyleChanged: (val) => setState(() => _usePhysicalStyle = val),
        leftHeaderWidget: HortaStatusCard(state: status),
        rightHeaderWidget: HortaTelemetryCard(
          potPercent: _potPercent,
          ledBrightnessPercent: _potPercent,
          luxPercent: 100.0,
          voltage: 5.0,
        ),
        bottomWidget: HortaUndoRedoButtons(
          controller: _undoRedoController,
          onUndo: () => setState(() => _undoRedoController.undo()),
          onRedo: () => setState(() => _undoRedoController.redo()),
        ),
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return CustomPaint(
              painter: HortaMonitoradaPainter(
                missionIndex: 0,
                animValue: _animController.value,
                usePhysicalStyle: _usePhysicalStyle,
                potPercent: _potPercent,
                luxPercent: 100.0,
                isLedOn: true,
                ledBrightness: brightness,
                isCircuitEnergized: true,
              ),
            );
          },
        ),
      ),
      sidePanel: WorkbenchSidePanel(
        teamTitle: 'Equipe Bio-Tech',
        showTeamHeader: false,
        buttonColor: const Color(0xFF16A34A),
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
            'Missão 1 · Brilho Ajustável',
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Use o potenciômetro como divisor de tensão para regular a intensidade do LED de cultivo na faixa ideal das plantas (40% a 80%).',
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
            'Checklist de Cultivo:',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF38BDF8),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildStepRow(1, 'Girar dial do potenciômetro', _potPercent != 20.0),
          _buildStepRow(2, 'Observar feixe de luz sobre as mudas', true),
          _buildStepRow(3, 'Atingir zona ideal (40% - 80%)', _isIdealRange),
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
          Row(
            children: [
              Expanded(
                child: Text(
                  'Ajuste do Potenciômetro:',
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                '${_potPercent.toStringAsFixed(0)}%',
                style: GoogleFonts.rajdhani(
                  color: _isIdealRange ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF10B981),
              inactiveTrackColor: const Color(0xFF334155),
              thumbColor: const Color(0xFF22C55E),
              overlayColor: const Color(0xFF10B981).withValues(alpha: 0.2),
            ),
            child: Slider(
              value: _potPercent,
              min: 0.0,
              max: 100.0,
              divisions: 20,
              onChanged: _onPotChanged,
            ),
          ),
          Center(
            child: Text(
              _isIdealRange ? '✓ FAIXA IDEAL BIO-TECH' : 'Faixa recomendada: 40% a 80%',
              style: GoogleFonts.rajdhani(
                color: _isIdealRange ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
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
