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

/// Missão 02 — Sensor de Ambiente: Calibrar e observar o comportamento resistivo do LDR
class HortaMonitoradaM2 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const HortaMonitoradaM2({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<HortaMonitoradaM2> createState() => _HortaMonitoradaM2State();
}

class _HortaMonitoradaM2State extends State<HortaMonitoradaM2>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  bool _usePhysicalStyle = true;
  double _luxPercent = 100.0; // 100% = pleno dia, 10% = noite escura
  bool _testedDay = false;
  bool _testedNight = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _testedDay = true;
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  bool get _isNight => _luxPercent <= 30.0;
  bool get _bothTested => _testedDay && _testedNight;

  // Resistência estimada do LDR: baixa na claridade, alta no escuro
  double get _ldrResistanceKOhms => _isNight ? 85.0 : 1.5;

  void _onLuxChanged(double value) {
    final prev = _luxPercent;
    _undoRedoController.execute(
      UpdateValueAction(
        description: 'Luz Ambiente: ${value.toStringAsFixed(0)}%',
        onApply: () {
          setState(() {
            _luxPercent = value;
            if (value >= 70.0) _testedDay = true;
            if (value <= 30.0) _testedNight = true;
          });
        },
        onUndo: () => setState(() => _luxPercent = prev),
      ),
    );
  }

  void _toggleDayNight() {
    final target = _isNight ? 100.0 : 15.0;
    _onLuxChanged(target);
  }

  void _validate() {
    final isSuccess = _bothTested;
    final message = isSuccess
        ? 'Excelente observação! Você confirmou que no escuro o LDR tem resistência altíssima (85 kΩ), e sob luz plena sua resistência cai para 1.5 kΩ. Esse princípio nos permite criar sensores automáticos!'
        : 'Ainda falta testar as duas condições! Experimente alternar entre Dia e Noite para comprovar como a resistência do LDR varia.';

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
    final status = _isNight ? HortaState.nightActive : HortaState.dayInactive;

    return WorkbenchResponsiveLayout(
      workbench: WorkbenchTableFrame(
        usePhysicalStyle: _usePhysicalStyle,
        onStyleChanged: (val) => setState(() => _usePhysicalStyle = val),
        leftHeaderWidget: HortaStatusCard(state: status),
        rightHeaderWidget: HortaTelemetryCard(
          luxPercent: _luxPercent,
          ledBrightnessPercent: _isNight ? 80.0 : 10.0,
          voltage: _isNight ? 4.2 : 0.8,
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
                missionIndex: 1,
                animValue: _animController.value,
                usePhysicalStyle: _usePhysicalStyle,
                potPercent: 60.0,
                luxPercent: _luxPercent,
                isLedOn: true,
                ledBrightness: _isNight ? 0.8 : 0.15,
                isNightMode: _isNight,
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
            'Missão 2 · Sensor de Ambiente',
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Comprove o efeito foto-resistivo: alterne entre luminosidade solar plena (Dia) e escuridão (Noite) para registrar a resposta do sensor LDR.',
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
            'Checklist do Sensor:',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF38BDF8),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildStepRow(1, 'Inspecionar LDR com luz do dia (R ≈ 1.5 kΩ)', _testedDay),
          _buildStepRow(2, 'Simular noite/sombra na estufa (R ≈ 85 kΩ)', _testedNight),
          _buildStepRow(3, 'Comprovar variação de resistência fotossensível', _bothTested),
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
                  'Luminosidade Natural:',
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
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFFFBBF24),
              inactiveTrackColor: const Color(0xFF334155),
              thumbColor: const Color(0xFFFDE047),
              overlayColor: const Color(0xFFFBBF24).withValues(alpha: 0.2),
            ),
            child: Slider(
              value: _luxPercent,
              min: 5.0,
              max: 100.0,
              divisions: 19,
              onChanged: _onLuxChanged,
            ),
          ),
          const SizedBox(height: 6),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: _isNight ? const Color(0xFFFBBF24) : const Color(0xFF8B5CF6),
              foregroundColor: _isNight ? const Color(0xFF0F172A) : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _toggleDayNight,
            icon: Icon(_isNight ? Icons.wb_sunny_rounded : Icons.nightlight_round),
            label: Text(
              _isNight ? 'Alternar para Dia Pleno' : 'Alternar para Noite Escura',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Resistência do LDR Medida: ${_ldrResistanceKOhms.toStringAsFixed(1)} kΩ',
              style: GoogleFonts.rajdhani(
                color: const Color(0xFF38BDF8),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
