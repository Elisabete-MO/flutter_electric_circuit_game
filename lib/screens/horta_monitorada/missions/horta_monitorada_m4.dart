import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../widgets/prof_volts_feedback_dialog.dart';
import '../../../widgets/success_confetti_overlay.dart';
import '../../../widgets/workbench_components.dart';
import '../../../widgets/workbench_table_frame.dart';
import '../widgets/horta_monitorada_widgets.dart';
import '../widgets/horta_split_view.dart';

/// Missão 04 — Bomba de Irrigação: Disparar o ciclo de rega por gotejamento quando o solo estiver seco.
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

  bool _usePhysicalStyle = true;
  bool _isPumpActive = false;
  double _soilMoisture = 0.20; // Solo seco
  bool _irrigationCycleCompleted = false;

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

  void _triggerIrrigationPump() {
    setState(() {
      _isPumpActive = true;
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _soilMoisture = 0.80; // Solo umedecido
          _isPumpActive = false;
          _irrigationCycleCompleted = true;
        });
      }
    });
  }

  bool get _isSoilHydrated => _soilMoisture >= 0.70 && _irrigationCycleCompleted;

  void _validate() {
    final isSuccess = _isSoilHydrated;
    final message = isSuccess
        ? 'Excelente trabalho! A bomba de irrigação foi acionada com sucesso, a água percorreu a tubulação e gotejou sobre as raízes, reidratando o solo para 80% e normalizando os sensores!'
        : 'O solo ainda está ressecado! Pressione o botão da bomba para acionar a irrigação e hidratar o canteiro.';

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
    final isDryAlert = _soilMoisture < 0.35;

    return WorkbenchResponsiveLayout(
      workbench: WorkbenchTableFrame(
        usePhysicalStyle: _usePhysicalStyle,
        onStyleChanged: (val) => setState(() => _usePhysicalStyle = val),
        leftHeaderWidget: HortaStatusCard(
          statusText: _isPumpActive
              ? 'REGANDO CANTEIRO...'
              : (_isSoilHydrated ? 'SOLO REIDRATADO' : 'ALERTA: SOLO SECO'),
          isHealthy: _isSoilHydrated || _isPumpActive,
          icon: _isPumpActive ? Icons.water_rounded : (isDryAlert ? Icons.warning_amber_rounded : Icons.water_drop_rounded),
        ),
        rightHeaderWidget: HortaTelemetryCard(
          voltage: _isPumpActive ? 9.0 : 0.0,
          currentMa: _isPumpActive ? 180.0 : 15.0,
          lightPercent: 85.0,
          moisturePercent: _soilMoisture * 100,
          temperatureC: 24.0,
        ),
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return HortaSplitView(
              missionIndex: 3,
              animValue: _animController.value,
              usePhysicalStyle: _usePhysicalStyle,
              isSwitchClosed: true,
              potentiometerValue: 0.85,
              soilMoisture: _soilMoisture,
              isIrrigating: _isPumpActive,
            );
          },
        ),
      ),
      sidePanel: WorkbenchSidePanel(
        teamTitle: 'Equipe Bio-Tech',
        showTeamHeader: false,
        buttonColor: const Color(0xFF10B981),
        toolboxItems: [
          _buildObjectiveCard(),
          const SizedBox(height: 12),
          _buildControlsCard(),
          const SizedBox(height: 12),
          _buildChecklistCard(),
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
            'Missão 4 · Bomba de Irrigação',
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'O canteiro está com apenas 20% de umidade. Acione a mini-bomba hidráulica para enviar água pelos tubos de gotejamento.',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF94A3B8),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Comando da Bomba DC:',
            style: GoogleFonts.rajdhani(color: const Color(0xFF38BDF8), fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: _isPumpActive ? const Color(0xFF0284C7) : const Color(0xFF06B6D4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _isPumpActive ? null : _triggerIrrigationPump,
            icon: Icon(_isPumpActive ? Icons.hourglass_top_rounded : Icons.water_drop_rounded),
            label: Text(
              _isPumpActive ? 'IRRIGANDO...' : 'ACIONAR REGADOR',
              style: GoogleFonts.rajdhani(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistCard() {
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
            'Checklist de Irrigação:',
            style: GoogleFonts.rajdhani(color: const Color(0xFF38BDF8), fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          _buildCheckItem('Detectar solo seco', _soilMoisture < 0.35 || _irrigationCycleCompleted),
          _buildCheckItem('Disparar ciclo da bomba hidráulica', _irrigationCycleCompleted),
          _buildCheckItem('Umidade final adequada (>= 70%)', _soilMoisture >= 0.70),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String label, bool isDone) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: isDone ? const Color(0xFF10B981) : const Color(0xFF64748B),
            size: 15,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.rajdhani(
                color: isDone ? Colors.white : const Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
