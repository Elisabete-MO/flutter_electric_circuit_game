import 'dart:async';
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

/// Missão 04 — Energia por Instantes: Armazenamento e descarga temporária com capacitor
class HortaMonitoradaM4 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const HortaMonitoradaM4({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<HortaMonitoradaM4> createState() => _HortaMonitoradaM4State();
}

class _HortaMonitoradaM4State extends State<HortaMonitoradaM4>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  bool _usePhysicalStyle = true;
  double _chargeLevel = 0.0; // 0.0 a 1.0
  bool _isMainPowerOn = true;
  bool _hasDischargedObserved = false;
  Timer? _dischargeTimer;

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
    _dischargeTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  bool get _isLedGlowing => _isMainPowerOn || _chargeLevel > 0.05;

  void _chargeCapacitor() {
    _dischargeTimer?.cancel();
    final prev = _chargeLevel;
    _undoRedoController.execute(
      UpdateValueAction(
        description: 'Carregar Capacitor (100%)',
        onApply: () => setState(() {
          _chargeLevel = 1.0;
          _isMainPowerOn = true;
        }),
        onUndo: () => setState(() => _chargeLevel = prev),
      ),
    );
  }

  void _simulatePowerCut() {
    setState(() {
      _isMainPowerOn = false;
    });

    _dischargeTimer?.cancel();
    // Simula descarga exponencial com timer a cada 50ms por 2 segundos
    _dischargeTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _chargeLevel -= 0.035;
        if (_chargeLevel <= 0.0) {
          _chargeLevel = 0.0;
          _hasDischargedObserved = true;
          timer.cancel();
        }
      });
    });
  }

  void _validate() {
    final isSuccess = _hasDischargedObserved || (_chargeLevel > 0.8 && !_isMainPowerOn);
    final message = isSuccess
        ? 'Brilhante! O capacitor de 470µF funcionou como uma pequena represa de elétrons: mesmo sem a fonte, ele sustentou o LED durante a transição!'
        : 'Carregue o capacitor a 100% e depois clique em "Simular Queda de Energia" para observar a descarga sustentando o LED!';

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
    final status = _isMainPowerOn
        ? (_chargeLevel > 0.8 ? HortaState.charging : HortaState.standby)
        : (_chargeLevel > 0.05 ? HortaState.discharging : HortaState.standby);

    final ledBrightness = _isMainPowerOn ? 0.7 : _chargeLevel * 0.7;

    return WorkbenchResponsiveLayout(
      workbench: WorkbenchTableFrame(
        usePhysicalStyle: _usePhysicalStyle,
        onStyleChanged: (val) => setState(() => _usePhysicalStyle = val),
        leftHeaderWidget: HortaStatusCard(state: status),
        rightHeaderWidget: HortaTelemetryCard(
          isCapacitorCharged: _chargeLevel > 0.1,
          voltage: _isMainPowerOn ? 5.0 : _chargeLevel * 5.0,
          ledBrightnessPercent: ledBrightness * 100.0,
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
                missionIndex: 3,
                animValue: _animController.value,
                usePhysicalStyle: _usePhysicalStyle,
                potPercent: 70.0,
                luxPercent: 100.0,
                isLedOn: _isLedGlowing,
                ledBrightness: ledBrightness,
                isCapacitorCharging: _isMainPowerOn && _chargeLevel > 0.8,
                isCapacitorDischarging: !_isMainPowerOn && _chargeLevel > 0.05,
                capacitorChargeLevel: _chargeLevel,
                isCircuitEnergized: _isLedGlowing,
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
            'Missão 4 · Energia por Instantes',
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Carregue o capacitor e corte a fonte principal para comprovar que capacitores armazenam carga por instantes, sustentando a estufa sem apagão abrupto.',
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
            'Checklist do Capacitor:',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF38BDF8),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildStepRow(1, 'Carregar capacitor a 100%', _chargeLevel >= 0.9),
          _buildStepRow(2, 'Simular corte da alimentação 5V', !_isMainPowerOn),
          _buildStepRow(3, 'Observar brilho residual decair suavemente', _hasDischargedObserved),
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
              backgroundColor: const Color(0xFF0284C7),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _chargeCapacitor,
            icon: const Icon(Icons.bolt_rounded),
            label: Text(
              'Carregar Capacitor (5V)',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _chargeLevel > 0.05 ? _simulatePowerCut : null,
            icon: const Icon(Icons.power_off_rounded),
            label: Text(
              'Simular Queda de Energia',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Nível de Carga do Capacitor:',
                      style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  Text(
                    '${(_chargeLevel * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.rajdhani(
                      color: const Color(0xFF38BDF8),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _chargeLevel,
                  backgroundColor: const Color(0xFF334155),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF38BDF8)),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
