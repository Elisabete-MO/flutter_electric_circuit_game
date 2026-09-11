import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../widgets/prof_volts_feedback_dialog.dart';
import '../../../widgets/success_confetti_overlay.dart';
import '../../../widgets/workbench_components.dart';
import '../../../widgets/workbench_table_frame.dart';
import '../widgets/horta_monitorada_widgets.dart';
import '../widgets/horta_split_view.dart';

/// Missão 05 — Painel Integrado: Automação completa de todos os subsistemas da estufa com simulação de ciclo ambiental.
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

  bool _usePhysicalStyle = true;
  bool _masterSwitch = true;
  double _growLightPotentiometer = 0.85;
  double _soilMoisture = 0.75;
  bool _fanActive = true;
  bool _pumpActive = false;
  int _environmentCycleStep = 0; // 0: Normal, 1: Sol Escaldante, 2: Solo Seco, 3: Noite Fria
  bool _allCyclesTested = false;

  final Set<int> _testedCycleSteps = {};

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _testedCycleSteps.add(0);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _changeEnvironmentScenario(int step) {
    setState(() {
      _environmentCycleStep = step;
      _testedCycleSteps.add(step);

      if (step == 1) {
        // Sol Escaldante
        _fanActive = true;
      } else if (step == 2) {
        // Solo Seco
        _soilMoisture = 0.25;
      } else if (step == 3) {
        // Noite
        _growLightPotentiometer = 0.90;
      } else {
        // Normal
        _soilMoisture = 0.75;
        _growLightPotentiometer = 0.85;
      }

      if (_testedCycleSteps.length >= 4) {
        _allCyclesTested = true;
      }
    });
  }

  void _triggerPump() {
    setState(() => _pumpActive = true);
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _soilMoisture = 0.80;
          _pumpActive = false;
        });
      }
    });
  }

  bool get _isMasterSystemReady => _masterSwitch && _allCyclesTested;

  void _validate() {
    final isSuccess = _isMasterSystemReady;
    final message = isSuccess
        ? 'PROJETO CONCLUÍDO COM LOUVOR! O Painel Integrado da Horta Monitorada está 100% calibrado e autônomo. A Equipe Bio-Tech construiu uma estufa inteligente de ponta que responde perfeitamente a todas as variações ambientais da Feira de Ciências!'
        : (!_masterSwitch
            ? 'A chave geral de alimentação do barramento está aberta!'
            : 'Teste todos os 4 cenários ambientais (Normal, Sol Forte, Solo Seco e Noite) para certificar a automação da estufa!');

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
    final currentMa = _masterSwitch
        ? (35.0 * _growLightPotentiometer + (_fanActive ? 120.0 : 0.0) + (_pumpActive ? 180.0 : 0.0) + 15.0)
        : 0.0;

    return WorkbenchResponsiveLayout(
      workbench: WorkbenchTableFrame(
        usePhysicalStyle: _usePhysicalStyle,
        onStyleChanged: (val) => setState(() => _usePhysicalStyle = val),
        leftHeaderWidget: HortaStatusCard(
          statusText: _masterSwitch ? 'ESTUFA INTELIGENTE 100%' : 'SISTEMA DESLIGADO',
          isHealthy: _masterSwitch,
          icon: Icons.verified_rounded,
        ),
        rightHeaderWidget: HortaTelemetryCard(
          voltage: _masterSwitch ? 9.0 : 0.0,
          currentMa: currentMa,
          lightPercent: _masterSwitch ? (_growLightPotentiometer * 100) : 0.0,
          moisturePercent: _soilMoisture * 100,
          temperatureC: _fanActive ? 23.5 : 31.0,
        ),
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return HortaSplitView(
              missionIndex: 4,
              animValue: _animController.value,
              usePhysicalStyle: _usePhysicalStyle,
              isSwitchClosed: _masterSwitch,
              potentiometerValue: _growLightPotentiometer,
              soilMoisture: _soilMoisture,
              isFanActive: _fanActive,
              isIrrigating: _pumpActive,
              isMasterActive: _masterSwitch,
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
          _buildScenariosCard(),
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
            'Missão 5 · Painel Integrado',
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Todos os 4 subsistemas (Luz, Sonda, Exaustor e Bomba) foram interligados em paralelo na fonte de 9V. Teste os ciclos ambientais para certificar o projeto.',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF94A3B8),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScenariosCard() {
    final scenarios = [
      {'label': '1. Ideal', 'icon': Icons.wb_sunny_rounded},
      {'label': '2. Sol Forte', 'icon': Icons.local_fire_department_rounded},
      {'label': '3. Solo Seco', 'icon': Icons.water_drop_rounded},
      {'label': '4. Noite', 'icon': Icons.nightlight_round},
    ];

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Barramento Geral 9V:',
                  style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
              Switch(
                value: _masterSwitch,
                activeThumbColor: const Color(0xFF10B981),
                onChanged: (val) => setState(() => _masterSwitch = val),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Simulação de Ciclo Climático:',
            style: GoogleFonts.rajdhani(color: const Color(0xFF38BDF8), fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(scenarios.length, (idx) {
              final isSelected = _environmentCycleStep == idx;
              return ChoiceChip(
                label: Text(
                  scenarios[idx]['label'] as String,
                  style: GoogleFonts.rajdhani(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.black : Colors.white70,
                  ),
                ),
                selected: isSelected,
                selectedColor: const Color(0xFF10B981),
                backgroundColor: const Color(0xFF1E293B),
                onSelected: (val) {
                  if (val) _changeEnvironmentScenario(idx);
                },
              );
            }),
          ),
          if (_environmentCycleStep == 2) ...[
            const SizedBox(height: 10),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF06B6D4),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onPressed: _triggerPump,
              icon: const Icon(Icons.water_drop_rounded, size: 16),
              label: Text('Regar Canteiro', style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold)),
            ),
          ],
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
            'Auditoria Final do Estande:',
            style: GoogleFonts.rajdhani(color: const Color(0xFF38BDF8), fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          _buildCheckItem('Barramento 9V em paralelo ativo', _masterSwitch),
          _buildCheckItem('Sub-sistema de Luz calibrado', true),
          _buildCheckItem('Sub-sistema de Sonda e Bomba ativo', true),
          _buildCheckItem('Sub-sistema de Exaustores ativo', true),
          _buildCheckItem('Ciclos ambientais testados (${_testedCycleSteps.length}/4)', _allCyclesTested),
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
