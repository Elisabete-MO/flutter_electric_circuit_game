import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../widgets/prof_volts_feedback_dialog.dart';
import '../../../widgets/success_confetti_overlay.dart';
import '../../../widgets/workbench_components.dart';
import '../../../widgets/workbench_table_frame.dart';
import '../widgets/horta_monitorada_widgets.dart';
import '../widgets/horta_split_view.dart';

/// Missão 01 — Luz de Cultivo: Ajustar a intensidade luminosa ideal com o potenciômetro.
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

  bool _usePhysicalStyle = true;
  bool _isSwitchClosed = true;
  double _potentiometer = 0.35; // Começa subalimentado

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

  bool get _isIntensityOptimal => _isSwitchClosed && _potentiometer >= 0.70 && _potentiometer <= 0.95;

  void _validate() {
    final isSuccess = _isIntensityOptimal;
    final message = isSuccess
        ? 'Excelente calibração! O LED Grow está na faixa perfeita de 70% a 95% de luminosidade, proporcionando a energia ideal para a fotossíntese sem sobreaquecimento!'
        : (!_isSwitchClosed
            ? 'A chave de alimentação está aberta! Feche o circuito para energizar a calha de LED.'
            : (_potentiometer < 0.70
                ? 'Luz insuficiente para as mudas! Aumente o potenciômetro para elevar a corrente do LED.'
                : 'Intensidade muito alta! Reduza um pouco o potenciômetro para proteger o LED e não queimar as folhas.'));

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
    final lightPercent = _isSwitchClosed ? (_potentiometer * 100) : 0.0;
    final currentMa = _isSwitchClosed ? (_potentiometer * 35.0) : 0.0;

    return WorkbenchResponsiveLayout(
      workbench: WorkbenchTableFrame(
        usePhysicalStyle: _usePhysicalStyle,
        onStyleChanged: (val) => setState(() => _usePhysicalStyle = val),
        leftHeaderWidget: HortaStatusCard(
          statusText: _isIntensityOptimal
              ? 'LUMINOSIDADE ÓTIMA'
              : (_potentiometer < 0.70 ? 'LUZ FRACA' : 'LUZ EXCESSIVA'),
          isHealthy: _isIntensityOptimal,
          icon: Icons.light_mode_rounded,
        ),
        rightHeaderWidget: HortaTelemetryCard(
          voltage: _isSwitchClosed ? 9.0 : 0.0,
          currentMa: currentMa,
          lightPercent: lightPercent,
          moisturePercent: 70.0,
          temperatureC: 23.5,
        ),
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return HortaSplitView(
              missionIndex: 0,
              animValue: _animController.value,
              usePhysicalStyle: _usePhysicalStyle,
              isSwitchClosed: _isSwitchClosed,
              potentiometerValue: _potentiometer,
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
            'Missão 1 · Luz de Cultivo',
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ligue a chave de alimentação e ajuste o potenciômetro entre 70% e 95% para atingir a luminosidade ideal da estufa.',
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Alimentação 9V:',
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
            'Potenciômetro (${(_potentiometer * 100).toInt()}%):',
            style: GoogleFonts.rajdhani(color: const Color(0xFF38BDF8), fontSize: 13, fontWeight: FontWeight.bold),
          ),
          Slider(
            value: _potentiometer,
            min: 0.0,
            max: 1.0,
            activeColor: const Color(0xFF38BDF8),
            onChanged: (val) => setState(() => _potentiometer = val),
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
            'Checklist de Validação:',
            style: GoogleFonts.rajdhani(color: const Color(0xFF38BDF8), fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          _buildCheckItem('Chave geral fechada (ON)', _isSwitchClosed),
          _buildCheckItem('Intensidade no alvo (70% - 95%)', _isIntensityOptimal),
          _buildCheckItem('Calha LED iluminando o canteiro', _isSwitchClosed && _potentiometer > 0.1),
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
