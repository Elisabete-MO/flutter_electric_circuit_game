import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/circuit_validator.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/prof_volts_speech.dart';
import '../../widgets/prof_volts_feedback_dialog.dart';

enum InspectionScenario {
  correct,
  reversedLed,
  missingResistor,
  incorrectResistor,
  openCircuit,
}

class InspectionScenarioData {
  final InspectionScenario scenario;
  final String title;
  final String description;
  final CircuitGraph graph;
  final InspectionScenario expectedDiagnosis;
  final String successExplanation;

  const InspectionScenarioData({
    required this.scenario,
    required this.title,
    required this.description,
    required this.graph,
    required this.expectedDiagnosis,
    required this.successExplanation,
  });
}

/// Tela da Fase 2: Inspecione o circuito pré-montado.
class FirstBenchPhase2 extends StatefulWidget {
  final VoidCallback onPhaseComplete;
  final List<InspectionScenarioData>? injectedScenarios;

  const FirstBenchPhase2({
    super.key,
    required this.onPhaseComplete,
    this.injectedScenarios,
  });

  @override
  State<FirstBenchPhase2> createState() => _FirstBenchPhase2State();
}

class _FirstBenchPhase2State extends State<FirstBenchPhase2> {
  late List<InspectionScenarioData> _scenarios;
  int _currentScenarioIndex = 0;
  InspectionScenario? _selectedDiagnosis;
  final Set<String> _inspectedChecklist = {};

  @override
  void initState() {
    super.initState();
    _scenarios = widget.injectedScenarios ?? _getDefaultScenarios();
  }

  static List<InspectionScenarioData> _getDefaultScenarios() {
    const battery = CircuitComponentInstance(id: 'bat', kind: CircuitComponentKind.battery);
    const swClosed = CircuitComponentInstance(id: 'sw', kind: CircuitComponentKind.switchComponent, isSwitchClosed: true);
    const res680 = CircuitComponentInstance(id: 'res', kind: CircuitComponentKind.resistor, resistanceOhms: 680);
    const res68 = CircuitComponentInstance(id: 'res', kind: CircuitComponentKind.resistor, resistanceOhms: 68);
    const led = CircuitComponentInstance(id: 'led', kind: CircuitComponentKind.led);

    return [
      InspectionScenarioData(
        scenario: InspectionScenario.correct,
        title: 'Cenário 1 — Inspeção de Circuito Perfeito',
        description: 'Examine o circuito abaixo: Bateria 9V, interruptor fechado, resistor 680 Ω e LED vermelho.',
        graph: CircuitGraph(
          components: [battery, swClosed, res680, led],
          connections: [
            CircuitConnection(battery.terminalA, swClosed.terminalA),
            CircuitConnection(swClosed.terminalB, res680.terminalA),
            CircuitConnection(res680.terminalB, led.terminalA),
            CircuitConnection(led.terminalB, battery.terminalB),
          ],
        ),
        expectedDiagnosis: InspectionScenario.correct,
        successExplanation: 'Exato! O circuito tem resistor apropriado (680 Ω) e a corrente fluirá no sentido correto do LED.',
      ),
      InspectionScenarioData(
        scenario: InspectionScenario.reversedLed,
        title: 'Cenário 2 — Problema de Polaridade',
        description: 'Observe as conexões do LED com atenção nos pólos (+ e -).',
        graph: CircuitGraph(
          components: [battery, swClosed, res680, led],
          connections: [
            CircuitConnection(battery.terminalA, swClosed.terminalA),
            CircuitConnection(swClosed.terminalB, res680.terminalA),
            CircuitConnection(res680.terminalB, led.terminalB), // Conectado no cátodo!
            CircuitConnection(led.terminalA, battery.terminalB),
          ],
        ),
        expectedDiagnosis: InspectionScenario.reversedLed,
        successExplanation: 'Correto! O LED foi ligado invertido (cátodo conectado ao lado positivo). O LED não acenderá.',
      ),
      InspectionScenarioData(
        scenario: InspectionScenario.incorrectResistor,
        title: 'Cenário 3 — Proteção de Corrente',
        description: 'Verifique o valor do resistor selecionado nesta bancada.',
        graph: CircuitGraph(
          components: [battery, swClosed, res68, led],
          connections: [
            CircuitConnection(battery.terminalA, swClosed.terminalA),
            CircuitConnection(swClosed.terminalB, res68.terminalA),
            CircuitConnection(res68.terminalB, led.terminalA),
            CircuitConnection(led.terminalB, battery.terminalB),
          ],
        ),
        expectedDiagnosis: InspectionScenario.incorrectResistor,
        successExplanation: 'Perfeito! Um resistor de 68 Ω é muito baixo para 9V e causará corrente excessiva (>100 mA).',
      ),
    ];
  }

  InspectionScenarioData get _current => _scenarios[_currentScenarioIndex];

  bool get _canSubmit => _inspectedChecklist.length >= 3 && _selectedDiagnosis != null;

  void _onCheckItem(String itemKey) {
    setState(() {
      if (_inspectedChecklist.contains(itemKey)) {
        _inspectedChecklist.remove(itemKey);
      } else {
        _inspectedChecklist.add(itemKey);
      }
    });
  }

  void _submitDiagnosis() {
    final isCorrect = _selectedDiagnosis == _current.expectedDiagnosis;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProfVoltsFeedbackDialog(
        isCorrect: isCorrect,
        message: isCorrect
            ? _current.successExplanation
            : 'Diagnóstico incorreto. Observe novamente a polaridade e os componentes inspecionados!',
        onAction: () {
          Navigator.of(context).pop();
          if (isCorrect) {
            if (_currentScenarioIndex < _scenarios.length - 1) {
              setState(() {
                _currentScenarioIndex++;
                _selectedDiagnosis = null;
                _inspectedChecklist.clear();
              });
            } else {
              widget.onPhaseComplete();
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Balão do Prof. Volts
              const ProfVoltsSpeech(
                text: 'FASE 2: Inspecione o circuito pronto! Clique nos pontos de verificação e diagnostique a bancada.',
              ),
              const SizedBox(height: 16),

              // Card Principal da Inspeção
              GlassContainer(
                borderRadius: 20,
                accentColor: const Color(0xFF00F0FF),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título do Cenário
                    Row(
                      children: [
                        const Icon(Icons.search_rounded, color: Color(0xFF00F0FF), size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _current.title,
                            style: TextStyle(
                              fontFamily: GoogleFonts.rajdhani().fontFamily,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF00F0FF),
                            ),
                          ),
                        ),
                        Text(
                          '${_currentScenarioIndex + 1} / ${_scenarios.length}',
                          style: TextStyle(
                            fontFamily: GoogleFonts.rajdhani().fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _current.description,
                      style: TextStyle(
                        fontFamily: GoogleFonts.outfit().fontFamily,
                        fontSize: 15,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Eschema Didático do Circuito
                    Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: const Color(0xFF091322),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF1E293B)),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildComponentDisplay(
                                  'Bateria (9V)',
                                  Icons.battery_charging_full_rounded,
                                  Colors.amber,
                                ),
                                const Icon(Icons.arrow_forward_rounded, color: Colors.cyan),
                                _buildComponentDisplay(
                                  'Interruptor',
                                  Icons.toggle_on_rounded,
                                  Colors.green,
                                ),
                                const Icon(Icons.arrow_forward_rounded, color: Colors.cyan),
                                _buildComponentDisplay(
                                  _current.scenario == InspectionScenario.incorrectResistor
                                      ? 'Resistor (68 Ω)'
                                      : 'Resistor (680 Ω)',
                                  Icons.align_horizontal_center_rounded,
                                  _current.scenario == InspectionScenario.incorrectResistor
                                      ? Colors.redAccent
                                      : Colors.blueAccent,
                                ),
                                const Icon(Icons.arrow_forward_rounded, color: Colors.cyan),
                                _buildComponentDisplay(
                                  _current.scenario == InspectionScenario.reversedLed
                                      ? 'LED (- Invertido +)'
                                      : 'LED (+ Normal -)',
                                  Icons.lightbulb_outline_rounded,
                                  _current.scenario == InspectionScenario.reversedLed
                                      ? Colors.orange
                                      : Colors.amberAccent,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Lista de Inspeção Obrigatória (Checklist)
                    Text(
                      'Passo 1: Selecione os 3 itens inspecionados',
                      style: TextStyle(
                        fontFamily: GoogleFonts.rajdhani().fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildCheckChip('Bateria e Tensão 9V', 'battery'),
                        _buildCheckChip('Valor do Resistor em Ohms', 'resistor'),
                        _buildCheckChip('Polaridade do LED (Ânodo/Cátodo)', 'led_polarity'),
                        _buildCheckChip('Estado do Interruptor', 'switch'),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Escolha do Diagnóstico
                    Text(
                      'Passo 2: Escolha o diagnóstico final do circuito',
                      style: TextStyle(
                        fontFamily: GoogleFonts.rajdhani().fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildOptionRadio(
                      InspectionScenario.correct,
                      'Circuito correto e seguro (Pronto para energizar)',
                    ),
                    _buildOptionRadio(
                      InspectionScenario.reversedLed,
                      'LED invertido (Corrente bloqueada pelo cátodo)',
                    ),
                    _buildOptionRadio(
                      InspectionScenario.incorrectResistor,
                      'Resistor incorreto (Resistência muito baixa causa sobrecorrente)',
                    ),
                    const SizedBox(height: 24),

                    // Botão Validar Diagnóstico
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _canSubmit ? _submitDiagnosis : null,
                        icon: const Icon(Icons.check_circle_outline_rounded),
                        label: Text(
                          'CONFIRMAR DIAGNÓSTICO',
                          style: TextStyle(
                            fontFamily: GoogleFonts.rajdhani().fontFamily,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF00F0FF),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComponentDisplay(String label, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 36),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontFamily: GoogleFonts.rajdhani().fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckChip(String label, String key) {
    final isChecked = _inspectedChecklist.contains(key);
    return FilterChip(
      selected: isChecked,
      label: Text(label),
      labelStyle: TextStyle(
        fontFamily: GoogleFonts.outfit().fontFamily,
        color: isChecked ? Colors.black : Colors.white,
        fontWeight: isChecked ? FontWeight.bold : FontWeight.normal,
      ),
      selectedColor: const Color(0xFF00F0FF),
      backgroundColor: const Color(0xFF1E293B),
      checkmarkColor: Colors.black,
      onSelected: (_) => _onCheckItem(key),
    );
  }

  Widget _buildOptionRadio(InspectionScenario value, String label) {
    final isSelected = _selectedDiagnosis == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedDiagnosis = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF00F0FF).withValues(alpha: 0.15)
              : const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF00F0FF) : const Color(0xFF1E293B),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: const Color(0xFF00F0FF),
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: GoogleFonts.outfit().fontFamily,
                  fontSize: 14,
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
