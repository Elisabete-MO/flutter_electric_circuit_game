import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../widgets/prof_volts_feedback_dialog.dart';
import '../../../widgets/success_confetti_overlay.dart';
import '../../../widgets/workbench_components.dart';
import '../../../widgets/workbench_table_frame.dart';
import '../widgets/horta_monitorada_widgets.dart';
import '../widgets/horta_split_view.dart';

/// Missão 03 — Ventilação Térmica: Acionar os exaustores axiais para controle de temperatura.
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

  bool _usePhysicalStyle = true;
  bool _isSwitchClosed = false; // Inicia desligado para o jogador ligar
  double _temperatureC = 32.0; // Temperatura alta precisando de resfriamento

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

  void _toggleSwitch(bool val) {
    setState(() {
      _isSwitchClosed = val;
      if (val) {
        _temperatureC = 23.5; // Resfria com os ventiladores ativos
      } else {
        _temperatureC = 32.0; // Esquenta
      }
    });
  }

  bool get _isCoolingActive => _isSwitchClosed && _temperatureC < 26.0;

  void _validate() {
    final isSuccess = _isCoolingActive;
    final message = isSuccess
        ? 'Perfeito! Os motores dos exaustores foram energizados e as pás estão circulando o ar, reduzindo a temperatura da estufa para confortáveis 23.5°C!'
        : 'Os exaustores ainda estão desligados! Feche a chave do circuito para acionar os motores da ventilação.';

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
    return WorkbenchResponsiveLayout(
      workbench: WorkbenchTableFrame(
        usePhysicalStyle: _usePhysicalStyle,
        onStyleChanged: (val) => setState(() => _usePhysicalStyle = val),
        leftHeaderWidget: HortaStatusCard(
          statusText: _isSwitchClosed ? 'VENTILAÇÃO ATIVA' : 'TEMPERATURA ELEVADA',
          isHealthy: _isSwitchClosed,
          icon: _isSwitchClosed ? Icons.air_rounded : Icons.thermostat_rounded,
        ),
        rightHeaderWidget: HortaTelemetryCard(
          voltage: _isSwitchClosed ? 9.0 : 0.0,
          currentMa: _isSwitchClosed ? 120.0 : 0.0,
          lightPercent: 85.0,
          moisturePercent: 70.0,
          temperatureC: _temperatureC,
        ),
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return HortaSplitView(
              missionIndex: 2,
              animValue: _animController.value,
              usePhysicalStyle: _usePhysicalStyle,
              isSwitchClosed: _isSwitchClosed,
              potentiometerValue: 0.85,
              soilMoisture: 0.70,
              isFanActive: _isSwitchClosed,
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
            'Missão 3 · Ventilação Térmica',
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'A estufa atingiu 32°C. Feche a chave de comando dos motores para ativar os exaustores axiais e renovar o ar.',
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
                  'Chave dos Exaustores:',
                  style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
              Switch(
                value: _isSwitchClosed,
                activeThumbColor: const Color(0xFF0284C7),
                onChanged: _toggleSwitch,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.thermostat_rounded,
                  color: _temperatureC > 28 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Temp. Estufa: ${_temperatureC.toStringAsFixed(1)}°C',
                    style: GoogleFonts.rajdhani(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
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
            'Checklist de Climatização:',
            style: GoogleFonts.rajdhani(color: const Color(0xFF38BDF8), fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          _buildCheckItem('Chave do motor acionada (ON)', _isSwitchClosed),
          _buildCheckItem('Ventoinhas girando na maquete', _isSwitchClosed),
          _buildCheckItem('Temperatura normalizada (< 26°C)', _temperatureC < 26.0),
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
