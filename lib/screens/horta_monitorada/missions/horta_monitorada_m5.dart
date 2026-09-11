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

/// Missão 05 — Painel da Horta: Comissionamento do sistema integrado da estufa inteligente
class HortaMonitoradaM5 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const HortaMonitoradaM5({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<HortaMonitoradaM5> createState() => _HortaMonitoradaM5State();
}

class _HortaMonitoradaM5State extends State<HortaMonitoradaM5>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  bool _usePhysicalStyle = true;
  double _potPercent = 60.0;
  final double _luxPercent = 25.0; // Noite
  bool _isAutoModeArmed = true;
  bool _isCapacitorReady = true;

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

  bool get _isPotCalibrated => _potPercent >= 40.0 && _potPercent <= 80.0;
  bool get _isNight => _luxPercent <= 30.0;
  bool get _isLedActive => _isAutoModeArmed && _isNight;
  bool get _isAllCalibrated => _isPotCalibrated && _isAutoModeArmed && _isCapacitorReady;

  void _onPotChanged(double val) {
    setState(() => _potPercent = val);
  }

  void _toggleAutoMode() {
    final prev = _isAutoModeArmed;
    _undoRedoController.execute(
      ToggleBoolAction(
        description: prev ? 'Desarmar Automação' : 'Armar Automação',
        onApply: () => setState(() => _isAutoModeArmed = !prev),
        onUndo: () => setState(() => _isAutoModeArmed = prev),
      ),
    );
  }

  void _toggleCapacitor() {
    setState(() => _isCapacitorReady = !_isCapacitorReady);
  }

  void _validate() {
    final isSuccess = _isAllCalibrated;
    final message = isSuccess
        ? 'Parabéns Equipe Bio-Tech! O painel da Horta Monitorada está 100% aprovado para a Feira de Ciências! Sensores, potenciômetro, LED de cultivo e capacitor de reserva operando em perfeita harmonia!'
        : 'Verifique o checklist de comissionamento: certifique-se de que o potenciômetro está entre 40-80%, a automação noturna está armada e a reserva do capacitor está habilitada.';

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
    final status = _isAllCalibrated
        ? HortaState.systemOk
        : (_isLedActive ? HortaState.nightActive : HortaState.adjusting);

    final ledBrightness = (_potPercent / 100.0) * (_isLedActive ? 1.0 : 0.2);

    return WorkbenchResponsiveLayout(
      workbench: WorkbenchTableFrame(
        usePhysicalStyle: _usePhysicalStyle,
        onStyleChanged: (val) => setState(() => _usePhysicalStyle = val),
        leftHeaderWidget: HortaStatusCard(state: status),
        rightHeaderWidget: HortaTelemetryCard(
          potPercent: _potPercent,
          luxPercent: _luxPercent,
          voltage: 5.0,
          ledBrightnessPercent: ledBrightness * 100.0,
          isCapacitorCharged: _isCapacitorReady,
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
                missionIndex: 4,
                animValue: _animController.value,
                usePhysicalStyle: _usePhysicalStyle,
                potPercent: _potPercent,
                luxPercent: _luxPercent,
                isLedOn: true,
                ledBrightness: ledBrightness,
                capacitorChargeLevel: _isCapacitorReady ? 1.0 : 0.0,
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
            'Missão 5 · Painel da Horta',
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Comissionamento Final: calibração integrada de todos os blocos (Potenciômetro + LDR noturno + Capacitor + LED) para validação oficial do Estande!',
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
            'Auditoria da Estufa Bio-Tech:',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF38BDF8),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildStepRow(1, 'Potenciômetro calibrado (40% - 80%)', _isPotCalibrated),
          _buildStepRow(2, 'Automação noturna habilitada', _isAutoModeArmed),
          _buildStepRow(3, 'Banco capacitivo de reserva OK', _isCapacitorReady),
          _buildStepRow(4, 'Inspeção geral do painel aprovada', _isAllCalibrated),
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
                  'Potenciômetro:',
                  style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              Text(
                '${_potPercent.toStringAsFixed(0)}%',
                style: GoogleFonts.rajdhani(
                  color: _isPotCalibrated ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF10B981),
              inactiveTrackColor: const Color(0xFF334155),
              thumbColor: const Color(0xFF22C55E),
            ),
            child: Slider(
              value: _potPercent,
              min: 0.0,
              max: 100.0,
              divisions: 20,
              onChanged: _onPotChanged,
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: _isAutoModeArmed ? const Color(0xFF10B981) : const Color(0xFF64748B),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _toggleAutoMode,
            icon: Icon(_isAutoModeArmed ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded),
            label: Text(
              _isAutoModeArmed ? 'Automação Armada' : 'Armar Automação',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: _isCapacitorReady ? const Color(0xFF0284C7) : const Color(0xFF64748B),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _toggleCapacitor,
            icon: const Icon(Icons.bolt_rounded),
            label: Text(
              _isCapacitorReady ? 'Capacitor em Standby (100%)' : 'Habilitar Capacitor',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
