import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/stand_mission.dart';
import '../../models/first_step_component.dart';
import '../../state/progress_controller.dart';
import '../../services/circuit_solver/mission_circuit_builder.dart';
import '../../widgets/component_vector_painters.dart';
import '../../widgets/component_physical_painter.dart';
import '../../widgets/prof_volts_speech.dart';
import '../../widgets/tech_grid_background.dart';
import '../../widgets/workbench_components.dart';
import '../../widgets/success_confetti_overlay.dart';

/// Estande 07 — "Mede, Testa e Explica" (Equipe Investigação).
/// Foco pedagógico: Medição de Tensão (V), Corrente (mA), Lei de Ohm (I = V / R) e Diagnóstico com Multímetro Didático.
class MedeTestaExplicaScreen extends ConsumerStatefulWidget {
  const MedeTestaExplicaScreen({super.key});

  @override
  ConsumerState<MedeTestaExplicaScreen> createState() => _MedeTestaExplicaScreenState();
}

class _MedeTestaExplicaScreenState extends ConsumerState<MedeTestaExplicaScreen> {
  late final List<StandMission> _missions;
  int _currentMissionIndex = 0;
  bool _usePhysicalStyle = true;

  StandMission get _currentMission => _missions[_currentMissionIndex];

  // Estados do Multímetro Didático e Provas de Medição
  String _multimeterMode = 'V_DC'; // 'V_DC', 'mA'
  bool _redProbeConnected = false;
  bool _blackProbeConnected = false;
  
  // Estado Missão 3 (Resistência e Corrente)
  double _m3ResistanceValue = 300.0; // ohms

  // Estado Missão 4 (Dimensionamento Seguro)
  int? _m4SelectedResistor; // 68, 680, 6800

  // Estado Missão 5 (Diário de Investigação)
  int? _m5SelectedReportIndex;

  bool _isSimulating = false;

  @override
  void initState() {
    super.initState();
    _missions = StandMission.medeTestaExplicaMissions;
  }

  void _onSelectMission(int index) {
    setState(() {
      _currentMissionIndex = index;
      _resetCurrentMission();
    });
  }

  void _nextMission() {
    if (_currentMissionIndex < _missions.length - 1) {
      setState(() {
        _currentMissionIndex++;
        _resetCurrentMission();
      });
    } else {
      _showStandCompletionDialog();
    }
  }

  void _resetCurrentMission() {
    setState(() {
      _redProbeConnected = false;
      _blackProbeConnected = false;
      switch (_currentMissionIndex) {
        case 0:
          _multimeterMode = 'V_DC';
          break;
        case 1:
          _multimeterMode = 'V_DC';
          break;
        case 2:
          _multimeterMode = 'mA';
          _m3ResistanceValue = 300.0;
          break;
        case 3:
          _multimeterMode = 'mA';
          _m4SelectedResistor = null;
          break;
        case 4:
          _multimeterMode = 'V_DC';
          _m5SelectedReportIndex = null;
          break;
      }
    });
  }

  Future<void> _validateCurrentMission() async {
    if (_isSimulating) return;
    setState(() => _isSimulating = true);

    try {
    bool isSuccess = false;
    String feedback = _currentMission.failureFeedback;

    switch (_currentMissionIndex) {
      case 0:
        // M1: Medir tensao da bateria
        if (_redProbeConnected && _blackProbeConnected && _multimeterMode == 'V_DC') {
          await MissionCircuitBuilder()
              .addBattery(id: 'bat1', voltage: 9.0)
              .connect('bat1', 'B', 'bat1', 'A')
              .simulate();
          feedback = 'Tensao da bateria: 9.0V DC. Voltimetro em paralelo com a fonte.';
          isSuccess = true;
        } else if (_multimeterMode != 'V_DC') {
          feedback = 'Gire a chave do multimetro para o modo Tensao Continua (V DC).';
        } else {
          feedback = 'Posicione ambas as pontas de prova nos terminais da bateria.';
        }
        break;

      case 1:
        // M2: Queda de tensao na lampada
        if (_redProbeConnected && _blackProbeConnected && _multimeterMode == 'V_DC') {
          final result = await MissionCircuitBuilder()
              .addBattery(id: 'bat1', voltage: 9.0)
              .addBulb(id: 'bulb1', resistance: 5.0)
              .connect('bat1', 'B', 'bulb1', 'A')
              .connect('bulb1', 'B', 'bat1', 'A')
              .simulate();
          if (result.hasClosedLoop) {
            final vDrop = result.componentVoltages['bulb1'] ?? 0;
            feedback = 'Queda de tensao na lampada: ${vDrop.toStringAsFixed(2)}V. '
                'A carga consome tensao do circuito.';
            isSuccess = true;
          } else {
            feedback = 'Circuito aberto. Verifique as conexoes.';
          }
        } else if (_multimeterMode != 'V_DC') {
          feedback = 'Selecione o modo Tensao (V DC) para medir a queda de potencial na lampada.';
        } else {
          feedback = 'Conecte as pontas de prova nos dois lados da lampada.';
        }
        break;

      case 2:
        // M3: Resistencia e Corrente (Ohm: I = V/R)
        if (_multimeterMode == 'mA') {
          final result = await MissionCircuitBuilder()
              .addBattery(id: 'bat1', voltage: 9.0)
              .addResistor(id: 'r1', resistance: _m3ResistanceValue)
              .addLed(id: 'led1')
              .connect('bat1', 'B', 'r1', 'A')
              .connect('r1', 'B', 'led1', 'A')
              .connect('led1', 'B', 'bat1', 'A')
              .simulate();
          if (result.hasClosedLoop && result.errorMessage == null) {
            final currentMa = result.current * 1000;
            feedback = 'Lei de Ohm: I = ${currentMa.toStringAsFixed(1)}mA com R = ${_m3ResistanceValue.round()} ohm. '
                'Maior resistencia = menor corrente.';
            isSuccess = true;
          } else {
            feedback = result.errorMessage ?? 'Ajuste o reostato para variar a corrente.';
          }
        } else {
          feedback = 'Alterne o multimetro para o modo Amperimetro (mA) para medir o fluxo de corrente!';
        }
        break;

      case 3:
        // M4: Dimensionamento Seguro (resistor ideal = 680 ohm -> ~10-15mA)
        if (_m4SelectedResistor != null) {
          final result = await MissionCircuitBuilder()
              .addBattery(id: 'bat1', voltage: 9.0)
              .addResistor(id: 'r1', resistance: _m4SelectedResistor!.toDouble())
              .addLed(id: 'led1')
              .connect('bat1', 'B', 'r1', 'A')
              .connect('r1', 'B', 'led1', 'A')
              .connect('led1', 'B', 'bat1', 'A')
              .simulate();
          if (result.hasClosedLoop && result.errorMessage == null) {
            final currentMa = result.current * 1000;
            if (currentMa >= 10 && currentMa <= 15) {
              feedback = 'Resistor ideal! Corrente: ${currentMa.toStringAsFixed(1)}mA (faixa segura 10-15mA).';
              isSuccess = true;
            } else if (currentMa > 15) {
              feedback = 'Corrente excessiva: ${currentMa.toStringAsFixed(1)}mA! O LED pode queimar.';
            } else {
              feedback = 'Corrente insuficiente: ${currentMa.toStringAsFixed(1)}mA. LED ficara apagado.';
            }
          } else if (result.isShortCircuit) {
            feedback = 'Curto-circuito! Resistor muito baixo!';
          } else {
            feedback = result.errorMessage ?? 'Erro na simulacao.';
          }
        } else {
          feedback = 'Escolha um resistor na gaveta lateral para limitar a corrente.';
        }
        break;

      case 4:
        // M5: Diario de Investigacao (resposta correta = index 1: resistor 10k alto demais)
        if (_m5SelectedReportIndex == 1) {
          final result = await MissionCircuitBuilder()
              .addBattery(id: 'bat1', voltage: 9.0)
              .addResistor(id: 'r1', resistance: 10000.0)
              .addLed(id: 'led1')
              .connect('bat1', 'B', 'r1', 'A')
              .connect('r1', 'B', 'led1', 'A')
              .connect('led1', 'B', 'bat1', 'A')
              .simulate();
          if (result.hasClosedLoop) {
            final currentMa = result.current * 1000;
            feedback = 'Diagnostico confirmado! Com 10k ohm, a corrente e apenas ${currentMa.toStringAsFixed(2)}mA. '
                'O resistor limita demais a corrente.';
            isSuccess = true;
          } else {
            feedback = 'O resistor de 10k ohm e muito alto para este circuito.';
          }
        } else if (_m5SelectedReportIndex == null) {
          feedback = 'Facas as medicoes e selecione o diagnostico no relatorio final.';
        } else {
          feedback = 'Revise a medicao: o resistor subdimensionado causa corrente excessiva.';
        }
        break;
    }

    if (isSuccess) {
      _showSuccessDialog();
    } else {
      _showFailureDialog(feedback);
    }
    } finally {
      if (mounted) setState(() => _isSimulating = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF06231E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF10B981), width: 2),
        ),
        title: Row(
          children: [
            const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 32),
            const SizedBox(width: 12),
            Text(
              'Missão Concluída!',
              style: GoogleFonts.rajdhani(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentMission.victoryCriteria,
              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
              ),
              child: Text(
                'Prof. Volts: "${_currentMission.voltsMediation}"',
                style: GoogleFonts.outfit(
                  color: Colors.amberAccent,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              showSuccessConfetti(context);
              _nextMission();
            },
            child: Text(
              _currentMissionIndex == _missions.length - 1 ? 'FINALIZAR ESTANDE' : 'PRÓXIMA MISSÃO',
              style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showFailureDialog(String feedbackMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F1010),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 32),
            const SizedBox(width: 12),
            Text(
              'Ajuste Necessário',
              style: GoogleFonts.rajdhani(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Text(
          feedbackMessage,
          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'REVISAR MEDIÇÃO',
              style: GoogleFonts.rajdhani(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showStandCompletionDialog() {
    ref.read(progressControllerProvider.notifier).markAsCompleted('mede_testa_explica', stars: 3);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF041C16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF10B981), width: 3),
        ),
        title: Row(
          children: [
            const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Estande Concluído!',
                style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
          ],
        ),
        content: Text(
          'Parabéns! Você completou todas as missões do Estande "Mede, Testa e Explica". A Equipe de Investigação agora domina a medição de tensão, corrente e a Lei de Ohm com precisão laboratorial!',
          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('VOLTAR AO MAPA', style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildVisualModeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Opção 1: Esquemático
          GestureDetector(
            onTap: () => setState(() => _usePhysicalStyle = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: !_usePhysicalStyle
                    ? const Color(0xFF0284C7)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: !_usePhysicalStyle
                    ? [
                        BoxShadow(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.architecture_rounded,
                    size: 16,
                    color: !_usePhysicalStyle
                        ? Colors.white
                        : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Esquemático',
                    style: GoogleFonts.rajdhani(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: !_usePhysicalStyle
                          ? Colors.white
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Opção 2: Físico 3D
          GestureDetector(
            onTap: () => setState(() => _usePhysicalStyle = true),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: _usePhysicalStyle
                    ? const Color(0xFF0284C7)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: _usePhysicalStyle
                    ? [
                        BoxShadow(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.electrical_services_rounded,
                    size: 16,
                    color: _usePhysicalStyle
                        ? Colors.white
                        : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Físico 3D',
                    style: GoogleFonts.rajdhani(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: _usePhysicalStyle
                          ? Colors.white
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ESTANDE 07 — MEDE, TESTA E EXPLICA',
              style: GoogleFonts.rajdhani(
                color: const Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'Equipe Investigação — Medição Elétrica & Diagnóstico',
              style: GoogleFonts.outfit(color: const Color(0xFF64748B), fontSize: 12),
            ),
          ],
        ),
      ),
      body: TechGridBackground(
        child: Column(
          children: [
            // Top Stepper de Missões
            WorkbenchHeaderStepper(
              totalMissions: _missions.length,
              currentMissionIndex: _currentMissionIndex,
              missionTitle: _currentMission.title,
              missionObjective: _currentMission.objective,
              onPrevious: _currentMissionIndex > 0
                  ? () => _onSelectMission(_currentMissionIndex - 1)
                  : null,
              onNext: _currentMissionIndex < _missions.length - 1
                  ? () => _onSelectMission(_currentMissionIndex + 1)
                  : null,
            ),
            const SizedBox(height: 6),
            _buildVisualModeSelector(),
            const SizedBox(height: 6),

            // Balão de Mediação Didática do Prof. Volts
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: ProfVoltsSpeech(
                text: _currentMission.voltsMediation,
              ),
            ),

            // Área Principal de Trabalho (Dividida 60/40)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Bancada Principal de Simulação (60%)
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _buildSimulationBench(),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Painel Lateral da Equipe (40%)
                    Expanded(
                      flex: 2,
                      child: WorkbenchSidePanel(
                        teamTitle: 'Gaveta de Símbolos — Medição',
                        onEnergizePressed: _validateCurrentMission,
                        isLoading: _isSimulating,
                        toolboxItems: [
                          _buildSidePanelContent(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói a bancada didática principal com o Multímetro e o Circuito de Teste (Solto na Malha)
  Widget _buildSimulationBench() {
    return Column(
      children: [
        // Display LCD do Multímetro Didático
        _buildDigitalMultimeterWidget(),
        const SizedBox(height: 16),

        // Área Central do Circuito Sob Medição (Solto na Malha)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: _buildCircuitBenchForCurrentMission(),
          ),
        ),
      ],
    );
  }

  /// Widget Gráfico de Multímetro Digital Didático
  Widget _buildDigitalMultimeterWidget() {
    double readingValue = 0.0;
    String unit = 'V';

    if (_redProbeConnected && _blackProbeConnected) {
      if (_multimeterMode == 'V_DC') {
        if (_currentMissionIndex == 0 || _currentMissionIndex == 1) {
          readingValue = 9.0;
        } else if (_currentMissionIndex == 4) {
          readingValue = 4.2; // Queda no resistor incorreto
        }
        unit = 'V DC';
      } else if (_multimeterMode == 'mA') {
        if (_currentMissionIndex == 2) {
          readingValue = (9.0 / _m3ResistanceValue) * 1000.0; // I = V / R em mA
        } else if (_currentMissionIndex == 3) {
          final r = _m4SelectedResistor ?? 680;
          readingValue = (9.0 / r) * 1000.0;
        }
        unit = 'mA';
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          // Display LCD Digital
          Container(
            width: 180,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF061E14),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _multimeterMode == 'V_DC' ? 'VOLTÍMETRO' : 'AMPERÍMETRO',
                  style: GoogleFonts.rajdhani(color: Colors.amberAccent, fontSize: 10, fontWeight: FontWeight.bold),
                ),
                Text(
                  readingValue.toStringAsFixed(1),
                  style: GoogleFonts.rajdhani(
                    color: const Color(0xFF00E676),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  unit,
                  style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Seletor de Modo (Knob / Botões Didáticos)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Escala da Chave Seletora:',
                  style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    ChoiceChip(
                      label: Text('V DC (Tensão)', style: GoogleFonts.rajdhani(fontSize: 12, fontWeight: FontWeight.bold)),
                      selected: _multimeterMode == 'V_DC',
                      selectedColor: const Color(0xFF10B981),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _multimeterMode = 'V_DC');
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text('mA (Corrente)', style: GoogleFonts.rajdhani(fontSize: 12, fontWeight: FontWeight.bold)),
                      selected: _multimeterMode == 'mA',
                      selectedColor: const Color(0xFF10B981),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _multimeterMode = 'mA');
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Circuito Específico de acordo com a missão atual
  Widget _buildCircuitBenchForCurrentMission() {
    switch (_currentMissionIndex) {
      case 0:
        return _buildM1Circuit();
      case 1:
        return _buildM2Circuit();
      case 2:
        return _buildM3Circuit();
      case 3:
        return _buildM4Circuit();
      case 4:
        return _buildM5Circuit();
      default:
        return const SizedBox.shrink();
    }
  }

  /// M1: Medir Tensão da Bateria 9V
  Widget _buildM1Circuit() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Medição Direta da Bateria 9V',
          style: GoogleFonts.rajdhani(color: const Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ponta Vermelha (+)
            _buildProbeSlot(
              isRed: true,
              isConnected: _redProbeConnected,
              onTap: () => setState(() => _redProbeConnected = !_redProbeConnected),
              label: 'Polo (+)',
            ),
            const SizedBox(width: 30),
            // Bateria 9V
            if (_usePhysicalStyle)
              CustomPaint(
                size: const Size(80, 80),
                painter: ComponentPhysicalPainter(
                  type: ComponentType.battery,
                  isDarkMode: false,
                ),
              )
            else
              const BatteryVectorWidget(size: 80),
            const SizedBox(width: 30),
            // Ponta Preta (-)
            _buildProbeSlot(
              isRed: false,
              isConnected: _blackProbeConnected,
              onTap: () => setState(() => _blackProbeConnected = !_blackProbeConnected),
              label: 'Polo (-)',
            ),
          ],
        ),
      ],
    );
  }

  /// M2: Queda de Tensão na Lâmpada
  Widget _buildM2Circuit() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Circuito Energizado com Lâmpada em Carga',
          style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const BatteryVectorWidget(size: 60),
            const SizedBox(width: 20),
            _buildProbeSlot(
              isRed: true,
              isConnected: _redProbeConnected,
              onTap: () => setState(() => _redProbeConnected = !_redProbeConnected),
              label: 'Terminal A',
            ),
            const SizedBox(width: 10),
            const BulbVectorWidget(size: 50, isOn: true),
            const SizedBox(width: 10),
            _buildProbeSlot(
              isRed: false,
              isConnected: _blackProbeConnected,
              onTap: () => setState(() => _blackProbeConnected = !_blackProbeConnected),
              label: 'Terminal B',
            ),
          ],
        ),
      ],
    );
  }

  /// M3: Resistência e Corrente (Reostato Didático)
  Widget _buildM3Circuit() {
    final currentMa = (9.0 / _m3ResistanceValue) * 1000.0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Lei de Ohm: I = V / R (${currentMa.toStringAsFixed(1)} mA)',
          style: GoogleFonts.rajdhani(color: const Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const BatteryVectorWidget(size: 50),
            const SizedBox(width: 20),
            ResistorVectorWidget(size: 40, resistanceValue: '${_m3ResistanceValue.round()}'),
            const SizedBox(width: 20),
            const LedVectorWidget(size: 36, isOn: true, ledColor: Colors.greenAccent),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Ajuste o Reostato de Resistência:',
          style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 14),
        ),
        Slider(
          value: _m3ResistanceValue,
          min: 100.0,
          max: 1000.0,
          divisions: 18,
          activeColor: const Color(0xFF10B981),
          label: '${_m3ResistanceValue.round()} Ω',
          onChanged: (val) => setState(() {
            _m3ResistanceValue = val;
            _redProbeConnected = true;
            _blackProbeConnected = true;
          }),
        ),
      ],
    );
  }

  /// M4: Dimensionamento Seguro de Resistor
  Widget _buildM4Circuit() {
    final hasResistor = _m4SelectedResistor != null;
    final isSafe = _m4SelectedResistor == 680;
    final isBurned = _m4SelectedResistor == 68;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          hasResistor
              ? 'Resistor Selecionado: $_m4SelectedResistor Ω'
              : 'Selecione um resistor na gaveta lateral',
          style: GoogleFonts.rajdhani(
            color: isSafe ? const Color(0xFF10B981) : (isBurned ? Colors.redAccent : Colors.amberAccent),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const BatteryVectorWidget(size: 60),
            const SizedBox(width: 16),
            if (hasResistor)
              ResistorVectorWidget(size: 40, resistanceValue: '$_m4SelectedResistor')
            else
              Container(
                width: 60,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.amber, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text('?', style: GoogleFonts.rajdhani(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 20)),
                ),
              ),
            const SizedBox(width: 16),
            LedVectorWidget(
              size: 44,
              isOn: hasResistor && !isBurned,
              ledColor: isBurned ? Colors.red : Colors.greenAccent,
            ),
          ],
        ),
      ],
    );
  }

  /// M5: Diário de Investigação (Diagnóstico de Falha)
  Widget _buildM5Circuit() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Diagnóstico: Por que o LED está fraco neste circuito?',
          style: GoogleFonts.rajdhani(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 16),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BatteryVectorWidget(size: 50),
            SizedBox(width: 16),
            ResistorVectorWidget(size: 36, resistanceValue: '10k'),
            SizedBox(width: 16),
            LedVectorWidget(size: 36, isOn: true, ledColor: Colors.orangeAccent),
          ],
        ),
      ],
    );
  }

  Widget _buildProbeSlot({
    required bool isRed,
    required bool isConnected,
    required VoidCallback onTap,
    required String label,
  }) {
    final color = isRed ? Colors.redAccent : Colors.blueAccent;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isConnected ? color.withValues(alpha: 0.3) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: isConnected ? 2.5 : 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isConnected ? Icons.check_circle_rounded : Icons.sensors_rounded,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              isConnected ? 'PROVA CONECTADA' : 'CONECTAR PROVA $label',
              style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  /// Conteúdo do Painel Lateral
  Widget _buildSidePanelContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            WorkbenchSymbolToolboxTile<String>(
              data: 'multimeter_v',
              label: 'Voltímetro',
              tooltip: 'Voltímetro (Medidor de Tensão)',
              symbolWidget: MeterVectorWidget(size: 34, meterType: 'V', accentColor: Color(0xFF0284C7)),
              color: Color(0xFF0284C7),
            ),
            WorkbenchSymbolToolboxTile<String>(
              data: 'multimeter_a',
              label: 'Amperímetro',
              tooltip: 'Amperímetro (Medidor de Corrente)',
              symbolWidget: MeterVectorWidget(size: 34, meterType: 'A', accentColor: Color(0xFFD97706)),
              color: Color(0xFFD97706),
            ),
            WorkbenchSymbolToolboxTile<String>(
              data: 'bateria_9v',
              label: 'Fonte 9V',
              tooltip: 'Fonte DC 9V',
              symbolWidget: BatteryVectorWidget(size: 34),
              color: Color(0xFF0284C7),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_currentMissionIndex == 3) ...[
          Text(
            'Selecione o Resistor de Proteção:',
            style: GoogleFonts.rajdhani(color: const Color(0xFF00E5FF), fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _buildResistorOptionTile(68, '68 Ω (Baixa Resistência — Perigo!)', Colors.redAccent),
          const SizedBox(height: 6),
          _buildResistorOptionTile(680, '680 Ω (Resistência Ideal — ~13mA)', const Color(0xFF00E5FF)),
          const SizedBox(height: 6),
          _buildResistorOptionTile(6800, '6.8 kΩ (Alta Resistência — LED fraco)', Colors.amber),
        ] else if (_currentMissionIndex == 4) ...[
          Text(
            'Conclusão do Diário de Investigação:',
            style: GoogleFonts.rajdhani(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _buildReportOptionTile(0, 'A bateria de 9V está descarregada.'),
          const SizedBox(height: 6),
          _buildReportOptionTile(1, 'O resistor de 10kΩ é muito alto para o LED, limitando excessivamente a corrente.'),
          const SizedBox(height: 6),
          _buildReportOptionTile(2, 'O LED foi montado com polaridade invertida.'),
        ] else ...[
          Text(
            'Instruções de Medição:',
            style: GoogleFonts.rajdhani(color: const Color(0xFF00E5FF), fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.25)),
            ),
            child: Text(
              '1. Conecte as pontas de prova (+ Vermelha e - Preta) nos terminais do circuito.\n2. Escolha a escala correta no Multímetro (V DC para Tensão ou mA para Corrente).\n3. Clique em ENERGIZAR E VALIDAR.',
              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, height: 1.4),
            ),
          ),
        ],
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.white70),
            onPressed: _resetCurrentMission,
            label: Text(
              'Reiniciar Montagem',
              style: GoogleFonts.rajdhani(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResistorOptionTile(int value, String label, Color color) {
    final isSelected = _m4SelectedResistor == value;
    return InkWell(
      onTap: () => setState(() {
        _m4SelectedResistor = value;
        _redProbeConnected = true;
        _blackProbeConnected = true;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? color : Colors.white24, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: color, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportOptionTile(int index, String label) {
    final isSelected = _m5SelectedReportIndex == index;
    return InkWell(
      onTap: () => setState(() {
        _m5SelectedReportIndex = index;
        _redProbeConnected = true;
        _blackProbeConnected = true;
      }),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981).withValues(alpha: 0.2) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? const Color(0xFF10B981) : Colors.white24, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(isSelected ? Icons.check_box : Icons.check_box_outline_blank, color: const Color(0xFF10B981), size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
