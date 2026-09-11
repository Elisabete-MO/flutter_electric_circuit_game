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

/// Missão 03 — Luz da Estufa: Integrar sensor LDR ao LED para automação noturna
class HortaMonitoradaM3 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const HortaMonitoradaM3({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<HortaMonitoradaM3> createState() => _HortaMonitoradaM3State();
}

class _HortaMonitoradaM3State extends State<HortaMonitoradaM3>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  bool _usePhysicalStyle = true;
  bool _isAutoModeEnabled = false;
  double _luxPercent = 20.0; // Inicia em período noturno

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

  bool get _isNight => _luxPercent <= 30.0;
  bool get _isLedActive => _isAutoModeEnabled && _isNight;

  void _toggleAutoMode() {
    final prev = _isAutoModeEnabled;
    _undoRedoController.execute(
      ToggleBoolAction(
        description: prev ? 'Desativar Automação' : 'Armar Automação Noturna',
        onApply: () => setState(() => _isAutoModeEnabled = !prev),
        onUndo: () => setState(() => _isAutoModeEnabled = prev),
      ),
    );
  }

  void _onLuxChanged(double value) {
    setState(() => _luxPercent = value);
  }

  void _validate() {
    final isSuccess = _isAutoModeEnabled && _isNight && _isLedActive;
    final message = isSuccess
        ? 'Fantástico! Com o circuito de automação armado, ao cair da noite o LDR dispara o driver do LED Grow Light, garantindo ciclo contínuo de suplementação luminosa!'
        : (!_isAutoModeEnabled
            ? 'O circuito de automação ainda está desligado! Ative a chave de automação noturna.'
            : 'Simule o anoitecer reduzindo a luz ambiente para comprovar o acendimento automático do LED.');

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
    final status = _isLedActive
        ? HortaState.nightActive
        : (_isAutoModeEnabled ? HortaState.dayInactive : HortaState.standby);

    final ledBrightness = _isLedActive ? 0.85 : 0.0;

    return WorkbenchResponsiveLayout(
      workbench: WorkbenchTableFrame(
        usePhysicalStyle: _usePhysicalStyle,
        onStyleChanged: (val) => setState(() => _usePhysicalStyle = val),
        leftHeaderWidget: HortaStatusCard(state: status),
        rightHeaderWidget: HortaTelemetryCard(
          luxPercent: _luxPercent,
          ledBrightnessPercent: _isLedActive ? 85.0 : 0.0,
          voltage: _isLedActive ? 5.0 : 0.0,
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
                missionIndex: 2,
                animValue: _animController.value,
                usePhysicalStyle: _usePhysicalStyle,
                potPercent: 70.0,
                luxPercent: _luxPercent,
                isLedOn: _isLedActive,
                ledBrightness: ledBrightness,
                isNightMode: _isNight,
                isCircuitEnergized: _isLedActive,
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
            'Missão 3 · Luz da Estufa',
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ligue o circuito comparador automático: ao anoitecer (lux < 30%), o sensor deve ligar automaticamente o LED de suplementação vegetal.',
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
            'Checklist de Automação:',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF38BDF8),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildStepRow(1, 'Habilitar modo automático', _isAutoModeEnabled),
          _buildStepRow(2, 'Testar período noturno (< 30% lux)', _isNight),
          _buildStepRow(3, 'Confirmar LED aceso e feixe na estufa', _isLedActive),
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
              backgroundColor: _isAutoModeEnabled
                  ? const Color(0xFF10B981)
                  : const Color(0xFF64748B),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _toggleAutoMode,
            icon: Icon(_isAutoModeEnabled ? Icons.toggle_on_rounded : Icons.toggle_off_rounded),
            label: Text(
              _isAutoModeEnabled ? 'Automação Armada (ON)' : 'Armar Automação (OFF)',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Simulação Solar:',
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                _isNight ? 'NOITE (${_luxPercent.toStringAsFixed(0)}%)' : 'DIA (${_luxPercent.toStringAsFixed(0)}%)',
                style: GoogleFonts.rajdhani(
                  color: _isNight ? const Color(0xFF8B5CF6) : const Color(0xFFFBBF24),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFFFBBF24),
              inactiveTrackColor: const Color(0xFF334155),
              thumbColor: const Color(0xFFFDE047),
            ),
            child: Slider(
              value: _luxPercent,
              min: 0.0,
              max: 100.0,
              divisions: 20,
              onChanged: _onLuxChanged,
            ),
          ),
        ],
      ),
    );
  }
}
