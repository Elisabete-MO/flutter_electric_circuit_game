import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../widgets/prof_volts_feedback_dialog.dart';
import '../../../widgets/success_confetti_overlay.dart';
import '../../../widgets/workbench_components.dart';
import '../../../widgets/workbench_table_frame.dart';
import '../widgets/horta_monitorada_widgets.dart';
import '../widgets/horta_split_view.dart';

/// Missão 02 — Sonda de Solo: Testar o sensor resistivo e calibrar o alerta de seca.
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

  bool _usePhysicalStyle = true;
  bool _isSwitchClosed = true;
  double _soilMoisture = 0.20; // Começa seco para disparar alerta
  bool _testedDry = false;
  bool _testedWet = false;

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

  void _onMoistureChanged(double val) {
    setState(() {
      _soilMoisture = val;
      if (val < 0.35) _testedDry = true;
      if (val > 0.65) _testedWet = true;
    });
  }

  bool get _isSensorValidated => _isSwitchClosed && _testedDry && _testedWet;

  void _validate() {
    final isSuccess = _isSensorValidated;
    final message = isSuccess
        ? 'Fantástico! Você comprovou que a condutividade da terra varia com a umidade: solo seco oferece alta resistência (disparando o LED vermelho) e solo úmido fecha o caminho de sinal com segurança!'
        : (!_isSwitchClosed
            ? 'A chave do circuito está desligada!'
            : 'Teste ambas as condições com o slider de umidade: solo seco (< 35%) e solo úmido (> 65%) para validar a resposta do sensor!');

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
          statusText: isDryAlert ? 'ALERTA: SOLO SECO' : 'SOLO HIDRATADO',
          isHealthy: !isDryAlert,
          icon: isDryAlert ? Icons.warning_amber_rounded : Icons.water_drop_rounded,
        ),
        rightHeaderWidget: HortaTelemetryCard(
          voltage: _isSwitchClosed ? 9.0 : 0.0,
          currentMa: _isSwitchClosed ? (isDryAlert ? 12.0 : 38.0) : 0.0,
          lightPercent: 85.0,
          moisturePercent: _soilMoisture * 100,
          temperatureC: 24.0,
        ),
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return HortaSplitView(
              missionIndex: 1,
              animValue: _animController.value,
              usePhysicalStyle: _usePhysicalStyle,
              isSwitchClosed: _isSwitchClosed,
              potentiometerValue: 0.85,
              soilMoisture: _soilMoisture,
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
          _buildEnvironmentCard(),
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
            'Missão 2 · Sonda de Umidade',
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Teste o comportamento da sonda resistiva simulando solo seco e solo regado.',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF94A3B8),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentCard() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Alimentação do Sensor:',
                  style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
              Switch(
                value: _isSwitchClosed,
                activeThumbColor: const Color(0xFF10B981),
                onChanged: (val) => setState(() => _isSwitchClosed = val),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Simulação de Umidade (${(_soilMoisture * 100).toInt()}%):',
            style: GoogleFonts.rajdhani(color: const Color(0xFF06B6D4), fontSize: 13, fontWeight: FontWeight.bold),
          ),
          Slider(
            value: _soilMoisture,
            min: 0.05,
            max: 0.95,
            activeColor: const Color(0xFF06B6D4),
            onChanged: _onMoistureChanged,
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
            'Checklist de Teste:',
            style: GoogleFonts.rajdhani(color: const Color(0xFF38BDF8), fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          _buildCheckItem('Alimentação ativa', _isSwitchClosed),
          _buildCheckItem('Testar solo seco (LED Alerta ON)', _testedDry),
          _buildCheckItem('Testar solo regado (LED Alerta OFF)', _testedWet),
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
