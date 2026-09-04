import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/stand_mission.dart';
import '../../models/first_step_component.dart';
import '../../state/progress_controller.dart';
import '../../models/circuit_action.dart';
import '../../services/circuit_solver/mission_circuit_builder.dart';
import '../../state/circuit_undo_redo_controller.dart';
import '../../widgets/prof_volts_feedback_dialog.dart';
import '../../widgets/schematic_blueprint_socket.dart';
import '../../widgets/physical_blueprint_socket.dart';
import '../../widgets/component_physical_painter.dart';
import '../../widgets/circuit_symbol_painter.dart';
import '../../widgets/tech_grid_background.dart';
import '../../widgets/workbench_components.dart';
import '../../widgets/workbench_table_frame.dart';
import '../../widgets/success_confetti_overlay.dart';

/// Tela Interativa do Estande 05 / Estande "Letreiros de LED" (Equipe Sinalização).
class LetrerosLedScreen extends ConsumerStatefulWidget {
  const LetrerosLedScreen({super.key});

  @override
  ConsumerState<LetrerosLedScreen> createState() => _LetrerosLedScreenState();
}

class _LetrerosLedScreenState extends ConsumerState<LetrerosLedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseAnimController;
  final CircuitUndoRedoController _undoRedoController = CircuitUndoRedoController();
  final List<StandMission> _missions = StandMission.letrerosLedMissions;
  int _currentMissionIndex = 0;
  bool _usePhysicalStyle = true;

  // Estados da Missão 1 (Placa de Saída: Ânodo/Cátodo + Resistor 680 Ω em série com 9V)
  bool _m1LedDirectPolarity = true;
  bool _m1LedInserted = false;
  double _m1LedRotation = 0.0;

  // Estados da Missão 2 (E se o LED estiver invertido?)
  bool _m2LedInvertedFixed = false;

  // Estados da Missão 3 (Por que a placa não acende? - Investigação de 3 Hipóteses)
  bool _m3LedRotated = false;
  bool _m3WireConnected = false;
  bool _m3ResistorInBranch = false;

  // Estados da Missão 4 (Brilho com responsabilidade: 68Ω, 680Ω, 6,8 kΩ)
  String? _m4SelectedResistor; // '68', '680', '6800'

  // Estados da Missão 5 (Entrada e Saída - Ramos Independentes + Remoção)
  bool _m5BranchEntradaActive = false;
  bool _m5BranchSaidaActive = false;
  bool _m5OneBranchDisconnected = false;

  bool _isSimulating = false;

  @override
  void initState() {
    super.initState();
    _pulseAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseAnimController.dispose();
    super.dispose();
  }

  void _insertComponent({
    required String name,
    required bool Function() getInserted,
    required void Function(bool) setInserted,
    required double Function() getRotation,
    required void Function(double) setRotation,
  }) {
    final prevInserted = getInserted();
    final prevRotation = getRotation();
    final nextInserted = !prevInserted;
    _undoRedoController.execute(InsertComponentAction(
      description: nextInserted ? 'Inserir $name' : 'Remover $name',
      onApply: () => setState(() {
        setInserted(nextInserted);
        if (nextInserted) setRotation(0);
      }),
      onUndo: () => setState(() {
        setInserted(prevInserted);
        setRotation(prevRotation);
      }),
    ));
  }

  void _rotateComponent({
    required String name,
    required double Function() getRotation,
    required void Function(double) setRotation,
  }) {
    final prevRotation = getRotation();
    final newRotation = (prevRotation + 90) % 360;
    _undoRedoController.execute(RotateComponentAction(
      description: 'Girar $name',
      onApply: () => setState(() => setRotation(newRotation)),
      onUndo: () => setState(() => setRotation(prevRotation)),
    ));
  }

  StandMission get _currentMission => _missions[_currentMissionIndex];

  void _nextMission() {
    if (_currentMissionIndex < _missions.length - 1) {
      setState(() {
        _currentMissionIndex++;
      });
    } else {
      _showStandCompletionDialog();
    }
  }

  void _resetCurrentMission() {
    _undoRedoController.clear();
    setState(() {
      switch (_currentMissionIndex) {
        case 0:
          _m1LedDirectPolarity = true;
          _m1LedInserted = false;
          break;
        case 1:
          _m2LedInvertedFixed = false;
          break;
        case 2:
          _m3LedRotated = false;
          _m3WireConnected = false;
          _m3ResistorInBranch = false;
          break;
        case 3:
          _m4SelectedResistor = null;
          break;
        case 4:
          _m5BranchEntradaActive = false;
          _m5BranchSaidaActive = false;
          _m5OneBranchDisconnected = false;
          break;
      }
    });
  }

  Future<void> _validateCurrentMission() async {
    if (_isSimulating) return;
    setState(() => _isSimulating = true);

    try {
      bool isSuccess = false;
      String feedbackMessage = _currentMission.failureFeedback;

      switch (_currentMissionIndex) {
        case 0: // M1: Placa de Saída
          if (_m1LedInserted && _m1LedDirectPolarity) {
            final result = await MissionCircuitBuilder()
                .addBattery(id: 'bat1', voltage: 9.0)
                .addResistor(id: 'r1', resistance: 680.0)
                .addLed(id: 'led1', reversed: false)
                .connect('bat1', 'B', 'r1', 'A')
                .connect('r1', 'B', 'led1', 'A')
                .connect('led1', 'B', 'bat1', 'A')
                .simulate();
            if (result.hasClosedLoop && result.errorMessage == null) {
              final currentMa = result.current * 1000;
              feedbackMessage = 'LED aceso em corrente segura (${currentMa.toStringAsFixed(1)}mA)! Ânodo (+) e Cátodo (-) ligados com resistor de 680 Ω.';
              isSuccess = true;
            } else {
              feedbackMessage = result.errorMessage ?? 'Verifique a montagem da Placa de Saída.';
            }
          } else if (!_m1LedInserted) {
            feedbackMessage = 'Insira o LED no soquete do circuito!';
          } else {
            feedbackMessage = 'Verifique a polaridade do LED: a corrente contínua só passa no sentido ânodo (+) para cátodo (-).';
          }
          break;

        case 1: // M2: E se o LED estiver invertido?
          if (_m2LedInvertedFixed) {
            final result = await MissionCircuitBuilder()
                .addBattery(id: 'bat1', voltage: 9.0)
                .addResistor(id: 'r1', resistance: 680.0)
                .addLed(id: 'led1', reversed: false)
                .connect('bat1', 'B', 'r1', 'A')
                .connect('r1', 'B', 'led1', 'A')
                .connect('led1', 'B', 'bat1', 'A')
                .simulate();
            if (result.hasClosedLoop && result.errorMessage == null) {
              feedbackMessage = 'Polaridade corrigida! Ao girar o LED em 180°, a corrente flui e a luz acende.';
              isSuccess = true;
            } else {
              feedbackMessage = result.errorMessage ?? 'Gira o LED para a polaridade correta.';
            }
          } else {
            feedbackMessage = 'O LED invertido bloqueia a corrente. Gire o LED para permitir a passagem de corrente!';
          }
          break;

        case 2: // M3: Por que a placa não acende? (Investigação de 3 Hipóteses)
          if (_m3LedRotated && _m3WireConnected && _m3ResistorInBranch) {
            final result = await MissionCircuitBuilder()
                .addBattery(id: 'bat1', voltage: 9.0)
                .addResistor(id: 'r1', resistance: 680.0)
                .addLed(id: 'led1', reversed: false)
                .connect('bat1', 'B', 'r1', 'A')
                .connect('r1', 'B', 'led1', 'A')
                .connect('led1', 'B', 'bat1', 'A')
                .simulate();
            if (result.hasClosedLoop && result.errorMessage == null) {
              feedbackMessage = 'Excelente investigação! Todas as 3 causas (LED invertido, fio aberto e resistor fora do ramo) foram diagnosticadas e corrigidas.';
              isSuccess = true;
            } else {
              feedbackMessage = result.errorMessage ?? 'Ainda há um problema na placa.';
            }
          } else {
            final missing = <String>[];
            if (!_m3LedRotated) missing.add('LED invertido');
            if (!_m3WireConnected) missing.add('Fio aberto');
            if (!_m3ResistorInBranch) missing.add('Resistor fora do ramo');
            feedbackMessage = 'Verifique e corrija as falhas encontradas: ${missing.join(", ")}.';
          }
          break;

        case 3: // M4: Brilho com responsabilidade (Escolha do Resistor)
          if (_m4SelectedResistor != null) {
            final resistance = double.parse(_m4SelectedResistor!);
            final result = await MissionCircuitBuilder()
                .addBattery(id: 'bat1', voltage: 9.0)
                .addResistor(id: 'r1', resistance: resistance)
                .addLed(id: 'led1')
                .connect('bat1', 'B', 'r1', 'A')
                .connect('r1', 'B', 'led1', 'A')
                .connect('led1', 'B', 'bat1', 'A')
                .simulate();
            if (result.hasClosedLoop && result.errorMessage == null) {
              final currentMa = result.current * 1000;
              if (resistance == 680.0) {
                feedbackMessage = 'Resistor de 680 Ω escolhido! Corrente de ${currentMa.toStringAsFixed(1)}mA garante excelente brilho com segurança total.';
                isSuccess = true;
              } else if (resistance == 68.0) {
                feedbackMessage = 'Corrente excessiva (${currentMa.toStringAsFixed(1)}mA)! Resistor de 68 Ω é baixo demais e pode queimar o LED.';
              } else {
                feedbackMessage = 'Corrente muito baixa (${currentMa.toStringAsFixed(1)}mA)! Resistor de 6,8 kΩ deixa a iluminação fraca demais.';
              }
            } else {
              feedbackMessage = result.errorMessage ?? 'Erro na montagem do resistor.';
            }
          } else {
            feedbackMessage = 'Compare 68 Ω, 680 Ω e 6,8 kΩ na montagem e selecione o resistor ideal.';
          }
          break;

        case 4: // M5: Entrada e Saída (Ramos Independentes)
          if (_m5BranchEntradaActive && _m5BranchSaidaActive) {
            final result = await MissionCircuitBuilder()
                .addBattery(id: 'bat1', voltage: 9.0)
                .addResistor(id: 'r1', resistance: 680.0)
                .addLed(id: 'led_entrada', reversed: false)
                .connect('bat1', 'B', 'r1', 'A')
                .connect('r1', 'B', 'led_entrada', 'A')
                .connect('led_entrada', 'B', 'bat1', 'A')
                .addResistor(id: 'r2', resistance: 680.0)
                .addLed(id: 'led_saida', reversed: false)
                .connect('bat1', 'B', 'r2', 'A')
                .connect('r2', 'B', 'led_saida', 'A')
                .connect('led_saida', 'B', 'bat1', 'A')
                .simulate();
            if (result.hasClosedLoop && result.errorMessage == null) {
              feedbackMessage = 'Letreiros de Entrada e Saída montados em ramos independentes! Ao desligar ou remover um ramo, o outro continua aceso.';
              isSuccess = true;
            } else {
              feedbackMessage = result.errorMessage ?? 'Construa os dois ramos com seus próprios resistores.';
            }
          } else {
            feedbackMessage = 'Construa letreiros de Entrada e Saída independentes, cada um com seu LED e resistor próprios de 680 Ω.';
          }
          break;
      }

    final fullMessage = isSuccess
        ? 'Missao "${_currentMission.title}" concluida! ${_currentMission.victoryCriteria}.\n\nProf. Volts: "${_currentMission.voltsMediation}"'
        : '$feedbackMessage\n\nProf. Volts: "${_currentMission.voltsMediation}"';

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ProfVoltsFeedbackDialog(
          isCorrect: isSuccess,
          message: fullMessage,
          onAction: () {
            Navigator.of(context).pop();
            if (isSuccess) {
              showSuccessConfetti(context);
              _nextMission();
            }
          },
        ),
      );
    }
    } finally {
      if (mounted) setState(() => _isSimulating = false);
    }
  }

  void _showStandCompletionDialog() {
    ref.read(progressControllerProvider.notifier).markAsCompleted('letreros_led', stars: 3);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF10B981), width: 2),
        ),
        title: Row(
          children: [
            const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Estande Concluído!',
                style: GoogleFonts.rajdhani(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Parabéns! A Equipe Sinalização garantiu o correto funcionamento e proteção de todos os letreiros da Feira de Ciências!',
              style: GoogleFonts.rajdhani(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_rounded, color: Color(0xFF10B981)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Selo "Semicondutores & Proteção" conquistado!',
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              'Voltar ao Mapa da Feira',
              style: GoogleFonts.rajdhani(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
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
              'ESTANDE 05 — LETREIROS DE LED',
              style: GoogleFonts.rajdhani(
                color: const Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'Equipe Sinalização — Semicondutores e Proteção',
              style: GoogleFonts.outfit(color: const Color(0xFF64748B), fontSize: 12),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0284C7)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: TechGridBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Coluna Principal da Bancada (70%)
                Expanded(
                  flex: 7,
                  child: Column(
                    children: [
                      WorkbenchHeaderStepper(
                        totalMissions: _missions.length,
                        currentMissionIndex: _currentMissionIndex,
                        missionTitle: _missions[_currentMissionIndex].title,
                        missionObjective: _missions[_currentMissionIndex].objective,
                        onPrevious: _currentMissionIndex > 0
                            ? () => setState(() => _currentMissionIndex--)
                            : null,
                        onNext: _currentMissionIndex < _missions.length - 1
                            ? () => setState(() => _currentMissionIndex++)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: WorkbenchTableFrame(
                          usePhysicalStyle: _usePhysicalStyle,
                          onStyleChanged: (val) => setState(() => _usePhysicalStyle = val),
                          leftHeaderWidget: _buildStatusCard(_isCurrentCircuitClosed),
                          rightHeaderWidget: _buildTelemetryCard(
                            _currentCircuitVoltage,
                            _currentCircuitCurrentMa,
                            _isCurrentCircuitClosed,
                          ),
                          bottomWidget: _buildUndoRedoButtons(),
                          child: _buildLedWorkbench(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Painel Lateral (30%)
                Expanded(
                  flex: 3,
                  child: WorkbenchSidePanel(
                    teamTitle: 'Painel da Equipe Sinalização',
                    toolboxItems: [
                      _buildMissionBriefingCard(),
                      _buildSideToolboxDrawer(),
                    ],
                    onEnergizePressed: _validateCurrentMission,
                    isLoading: _isSimulating,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool get _isCurrentCircuitClosed {
    switch (_currentMissionIndex) {
      case 0:
        return _m1LedInserted && _m1LedDirectPolarity;
      case 1:
        return _m2LedInvertedFixed;
      case 2:
        return _m3LedRotated && _m3WireConnected && _m3ResistorInBranch;
      case 3:
        return _m4SelectedResistor == '680';
      case 4:
        return _m5BranchEntradaActive || _m5BranchSaidaActive;
      default:
        return false;
    }
  }

  double get _currentCircuitVoltage => 9.0;

  double get _currentCircuitCurrentMa {
    if (!_isCurrentCircuitClosed) return 0.0;
    if (_currentMissionIndex == 3) {
      if (_m4SelectedResistor == '68') return 103.0;
      if (_m4SelectedResistor == '6800') return 1.0;
      return 10.3;
    }
    return 10.3;
  }

  Widget _buildStatusCard(bool isClosed) {
    final statusColor = isClosed ? const Color(0xFF10B981) : const Color(0xFF64748B);
    final statusText = isClosed ? 'CIRCUITO FECHADO (ON)' : 'CIRCUITO ABERTO (OFF)';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              boxShadow: [
                if (isClosed)
                  BoxShadow(
                    color: statusColor.withValues(alpha: 0.6),
                    blurRadius: 6,
                    spreadRadius: 1.5,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: GoogleFonts.rajdhani(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryCard(double voltage, double currentMa, bool isClosed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'TENSÃO: ',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
          Text(
            '${voltage.toStringAsFixed(1)}V',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF0284C7),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '| CORRENTE: ',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
          Text(
            '${currentMa.toStringAsFixed(0)}mA',
            style: GoogleFonts.rajdhani(
              color: isClosed ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildLedWorkbench() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: _buildMissionSignDisplay(),
    );
  }

  Widget _buildMissionSignDisplay() {
    switch (_currentMissionIndex) {
      case 0:
        return _buildM1SignDisplay();
      case 1:
        return _buildM2SignDisplay();
      case 2:
        return _buildM3SignDisplay();
      case 3:
        return _buildM4SignDisplay();
      case 4:
        return _buildM5SignDisplay();
      default:
        return const SizedBox.shrink();
    }
  }

  /// Visualizador da Missão 1: Polaridade do LED (Placa SAÍDA)
  Widget _buildM1SignDisplay() {
    final isLit = _m1LedInserted && _m1LedDirectPolarity;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLedSignBoard(
          title: 'SAÍDA',
          color: Colors.redAccent,
          isLit: isLit,
        ),

        // Socket Interativo do LED (Alterna entre Físico 3D e Esquemático)
        _usePhysicalStyle
            ? PhysicalBlueprintSocket<String>(
                expectedData: 'led_red',
                isFilled: _m1LedInserted,
                showLabel: false,
                rotation: _m1LedRotation,
                onAccept: (_) => _insertComponent(
                  name: 'LED Vermelho',
                  getInserted: () => _m1LedInserted,
                  setInserted: (v) => _m1LedInserted = v,
                  getRotation: () => _m1LedRotation,
                  setRotation: (v) => _m1LedRotation = v,
                ),
                onRotate: () => _rotateComponent(
                  name: 'LED Vermelho',
                  getRotation: () => _m1LedRotation,
                  setRotation: (v) => _m1LedRotation = v,
                ),
                onTap: () => _insertComponent(
                  name: 'LED Vermelho',
                  getInserted: () => _m1LedInserted,
                  setInserted: (v) => _m1LedInserted = v,
                  getRotation: () => _m1LedRotation,
                  setRotation: (v) => _m1LedRotation = v,
                ),
                symbolWidget: CustomPaint(
                  size: const Size(60, 60),
                  painter: ComponentPhysicalPainter(
                    type: ComponentType.led,
                    isActive: isLit,
                    isDarkMode: false,
                  ),
                ),
                placeholderWidget: CustomPaint(
                  size: const Size(45, 45),
                  painter: ComponentPhysicalPainter(
                    type: ComponentType.led,
                    isActive: false,
                    isDarkMode: false,
                  ),
                ),
                label: '',
              )
            : SchematicBlueprintSocket<String>(
                expectedData: 'led_red',
                isFilled: _m1LedInserted,
                showLabel: false,
                rotation: _m1LedRotation,
                onAccept: (_) => _insertComponent(
                  name: 'LED Vermelho',
                  getInserted: () => _m1LedInserted,
                  setInserted: (v) => _m1LedInserted = v,
                  getRotation: () => _m1LedRotation,
                  setRotation: (v) => _m1LedRotation = v,
                ),
                onRotate: () => _rotateComponent(
                  name: 'LED Vermelho',
                  getRotation: () => _m1LedRotation,
                  setRotation: (v) => _m1LedRotation = v,
                ),
                onTap: () => _insertComponent(
                  name: 'LED Vermelho',
                  getInserted: () => _m1LedInserted,
                  setInserted: (v) => _m1LedInserted = v,
                  getRotation: () => _m1LedRotation,
                  setRotation: (v) => _m1LedRotation = v,
                ),
                symbolWidget: CustomPaint(
                  size: const Size(55, 55),
                  painter: CircuitSymbolPainter(
                    type: ComponentType.led,
                    isActive: isLit,
                    color: const Color(0xFF0F172A),
                    strokeWidth: 2.5,
                  ),
                ),
                placeholderWidget: CustomPaint(
                  size: const Size(45, 45),
                  painter: CircuitSymbolPainter(
                    type: ComponentType.led,
                    isActive: false,
                    color: const Color(0xFF94A3B8),
                    strokeWidth: 2.0,
                  ),
                ),
                label: '',
              ),

        // Controle Clean de Polaridade (Ânodo / Cátodo)
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            backgroundColor: const Color(0xFF0F172A),
            side: const BorderSide(color: Color(0xFF00E5FF)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          icon: const Icon(Icons.flip_camera_android_rounded, color: Color(0xFF00E5FF)),
          label: Text(
            _m1LedDirectPolarity
                ? 'Polaridade: Direta [Ânodo (+) → Cátodo (-)]'
                : 'Polaridade: Inversa [Cátodo (-) → Ânodo (+)]',
            style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          onPressed: () {
            final prev = _m1LedDirectPolarity;
            _undoRedoController.execute(ToggleBoolAction(
              description: 'Toggle Polaridade LED',
              onApply: () => setState(() => _m1LedDirectPolarity = !prev),
              onUndo: () => setState(() => _m1LedDirectPolarity = prev),
            ));
          },
        ),
      ],
    );
  }

  /// Visualizador da Missão 2: Diagnóstico de LED Invertido (Placa SAÍDA)
  Widget _buildM2SignDisplay() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLedSignBoard(
          title: 'SAÍDA',
          color: const Color(0xFF10B981),
          isLit: _m2LedInvertedFixed,
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _m2LedInvertedFixed ? const Color(0xFF10B981) : Colors.amberAccent,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _m2LedInvertedFixed ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                color: _m2LedInvertedFixed ? const Color(0xFF10B981) : Colors.amberAccent,
                size: 28,
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _m2LedInvertedFixed ? const Color(0xFF10B981) : const Color(0xFF1E293B),
                  side: const BorderSide(color: Color(0xFF10B981)),
                ),
                icon: const Icon(Icons.rotate_right_rounded, color: Colors.white),
                label: Text(
                  _m2LedInvertedFixed ? 'Terminais Invertidos (Conduzindo!)' : 'Inverter Terminais do LED (180°)',
                  style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                onPressed: () {
                  final prev = _m2LedInvertedFixed;
                  _undoRedoController.execute(ToggleBoolAction(
                    description: 'Toggle LED Invertido',
                    onApply: () => setState(() => _m2LedInvertedFixed = !prev),
                    onUndo: () => setState(() => _m2LedInvertedFixed = prev),
                  ));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Visualizador da Missão 3: Por que a placa não acende? (Investigação de 3 Hipóteses)
  Widget _buildM3SignDisplay() {
    final allFixed = _m3LedRotated && _m3WireConnected && _m3ResistorInBranch;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLedSignBoard(
          title: allFixed ? 'SAÍDA (OK!)' : 'APAGADO',
          color: allFixed ? const Color(0xFF10B981) : Colors.redAccent,
          isLit: allFixed,
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: allFixed ? const Color(0xFF10B981) : Colors.amberAccent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(
                'Painel de Investigação de Falhas (Testar Hipóteses):',
                style: GoogleFonts.rajdhani(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _m3LedRotated ? const Color(0xFF10B981) : const Color(0xFF1E293B),
                      side: const BorderSide(color: Color(0xFF10B981)),
                    ),
                    icon: Icon(_m3LedRotated ? Icons.check : Icons.rotate_right_rounded),
                    label: Text(
                      _m3LedRotated ? 'H1: LED Girado (Ok)' : 'H1: Girar LED Invertido',
                      style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      final prev = _m3LedRotated;
                      _undoRedoController.execute(ToggleBoolAction(
                        description: 'Girar LED',
                        onApply: () => setState(() => _m3LedRotated = !prev),
                        onUndo: () => setState(() => _m3LedRotated = prev),
                      ));
                    },
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _m3WireConnected ? const Color(0xFF10B981) : const Color(0xFF1E293B),
                      side: const BorderSide(color: Color(0xFF10B981)),
                    ),
                    icon: Icon(_m3WireConnected ? Icons.check : Icons.cable_rounded),
                    label: Text(
                      _m3WireConnected ? 'H2: Fio Conectado (Ok)' : 'H2: Fechar Fio Aberto',
                      style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      final prev = _m3WireConnected;
                      _undoRedoController.execute(ToggleBoolAction(
                        description: 'Conectar Fio',
                        onApply: () => setState(() => _m3WireConnected = !prev),
                        onUndo: () => setState(() => _m3WireConnected = prev),
                      ));
                    },
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _m3ResistorInBranch ? const Color(0xFF10B981) : const Color(0xFF1E293B),
                      side: const BorderSide(color: Color(0xFF10B981)),
                    ),
                    icon: Icon(_m3ResistorInBranch ? Icons.check : Icons.security_rounded),
                    label: Text(
                      _m3ResistorInBranch ? 'H3: Resistor no Ramo (Ok)' : 'H3: Inserir Resistor no Ramo',
                      style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      final prev = _m3ResistorInBranch;
                      _undoRedoController.execute(ToggleBoolAction(
                        description: 'Inserir Resistor',
                        onApply: () => setState(() => _m3ResistorInBranch = !prev),
                        onUndo: () => setState(() => _m3ResistorInBranch = prev),
                      ));
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Visualizador da Missão 4: Brilho com responsabilidade (Escolha entre 68Ω, 680Ω, 6,8 kΩ)
  Widget _buildM4SignDisplay() {
    final isIdeal = _m4SelectedResistor == '680';
    final isBurnt = _m4SelectedResistor == '68';
    final isTooWeak = _m4SelectedResistor == '6800';

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLedSignBoard(
          title: isBurnt ? 'SOBRECORRENTE!' : 'ENTRADA',
          color: isBurnt
              ? Colors.redAccent
              : isIdeal
                  ? const Color(0xFF10B981)
                  : Colors.amber,
          isLit: isIdeal || isBurnt,
          isBurnt: isBurnt,
          isDim: isTooWeak,
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isIdeal ? const Color(0xFF10B981) : Colors.white24,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(
                'Resistor em Série Selecionado: ${_m4SelectedResistor == '6800' ? '6,8 k' : (_m4SelectedResistor ?? 'Nenhum')} ${_m4SelectedResistor != null ? 'Ω' : ''}',
                style: GoogleFonts.rajdhani(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildResistorChip('68 Ω (Baixo)', '68'),
                  _buildResistorChip('680 Ω (Ideal)', '680'),
                  _buildResistorChip('6,8 kΩ (Alto)', '6800'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResistorChip(String label, String value) {
    final isSelected = _m4SelectedResistor == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        final prev = _m4SelectedResistor;
        final next = val ? value : null;
        _undoRedoController.execute(SelectOptionAction(
          description: 'Selecionar Resistor $value Ω',
          onApply: () => setState(() => _m4SelectedResistor = next),
          onUndo: () => setState(() => _m4SelectedResistor = prev),
        ));
      },
      selectedColor: const Color(0xFF10B981),
      backgroundColor: const Color(0xFF1E293B),
      labelStyle: GoogleFonts.rajdhani(
        color: isSelected ? Colors.white : Colors.white70,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Visualizador da Missão 5: Entrada e Saída (Ramos Independentes)
  Widget _buildM5SignDisplay() {
    final entradaLit = _m5BranchEntradaActive;
    final saidaLit = _m5BranchSaidaActive && !_m5OneBranchDisconnected;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildLedSignBoard(
              title: 'ENTRADA',
              color: const Color(0xFF10B981),
              isLit: entradaLit,
            ),
            _buildLedSignBoard(
              title: _m5OneBranchDisconnected ? 'SAÍDA (REMOVIDO)' : 'SAÍDA',
              color: _m5OneBranchDisconnected ? Colors.grey : Colors.redAccent,
              isLit: saidaLit,
              isBurnt: _m5OneBranchDisconnected,
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: (entradaLit && _m5BranchSaidaActive) ? const Color(0xFF10B981) : Colors.amberAccent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _m5BranchEntradaActive ? const Color(0xFF10B981) : const Color(0xFF1E293B),
                      side: const BorderSide(color: Color(0xFF10B981)),
                    ),
                    icon: Icon(_m5BranchEntradaActive ? Icons.check : Icons.add_circle_outline_rounded),
                    label: Text(
                      _m5BranchEntradaActive ? 'Ramo Entrada Montado (680Ω)' : 'Montar Ramo Entrada (680Ω)',
                      style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      final prev = _m5BranchEntradaActive;
                      _undoRedoController.execute(ToggleBoolAction(
                        description: 'Toggle Ramo Entrada',
                        onApply: () => setState(() => _m5BranchEntradaActive = !prev),
                        onUndo: () => setState(() => _m5BranchEntradaActive = prev),
                      ));
                    },
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _m5BranchSaidaActive ? const Color(0xFF10B981) : const Color(0xFF1E293B),
                      side: const BorderSide(color: Color(0xFF10B981)),
                    ),
                    icon: Icon(_m5BranchSaidaActive ? Icons.check : Icons.add_circle_outline_rounded),
                    label: Text(
                      _m5BranchSaidaActive ? 'Ramo Saída Montado (680Ω)' : 'Montar Ramo Saída (680Ω)',
                      style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      final prev = _m5BranchSaidaActive;
                      _undoRedoController.execute(ToggleBoolAction(
                        description: 'Toggle Ramo Saída',
                        onApply: () => setState(() => _m5BranchSaidaActive = !prev),
                        onUndo: () => setState(() => _m5BranchSaidaActive = prev),
                      ));
                    },
                  ),
                ],
              ),
              if (_m5BranchEntradaActive && _m5BranchSaidaActive) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF38BDF8)),
                    backgroundColor: const Color(0xFF1E293B),
                  ),
                  icon: Icon(
                    _m5OneBranchDisconnected ? Icons.power_off_rounded : Icons.power_rounded,
                    color: const Color(0xFF38BDF8),
                  ),
                  label: Text(
                    _m5OneBranchDisconnected
                        ? 'Demonstrativo: Ramo Saída Desconectado (Entrada Continua Aceso!)'
                        : 'Simular Remoção do Ramo Saída pela Banca',
                    style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    final prev = _m5OneBranchDisconnected;
                    _undoRedoController.execute(ToggleBoolAction(
                      description: 'Remover Ramo para Teste',
                      onApply: () => setState(() => _m5OneBranchDisconnected = !prev),
                      onUndo: () => setState(() => _m5OneBranchDisconnected = prev),
                    ));
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }



  Widget _buildMissionBriefingCard() {
    final mission = _missions[_currentMissionIndex];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF0284C7).withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'MISSÃO 0${_currentMissionIndex + 1}',
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  mission.title,
                  style: GoogleFonts.rajdhani(
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            mission.objective,
            style: GoogleFonts.outfit(
              color: const Color(0xFF334155),
              fontSize: 12.5,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.tips_and_updates_rounded,
                  color: Color(0xFFD97706),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Prof. Volts: "${mission.voltsMediation}"',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF475569),
                      fontSize: 11.5,
                      fontStyle: FontStyle.italic,
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

  Widget _buildSideToolboxDrawer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
          child: Text(
            'Gaveta de Componentes:',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            // Bateria
            WorkbenchSymbolToolboxTile<String>(
              data: 'battery',
              label: 'Bateria',
              tooltip: 'Fonte 9V',
              symbolWidget: _usePhysicalStyle
                  ? CustomPaint(
                      size: const Size(34, 34),
                      painter: ComponentPhysicalPainter(
                        type: ComponentType.battery,
                        isDarkMode: false,
                      ),
                    )
                  : CustomPaint(
                      size: const Size(34, 34),
                      painter: CircuitSymbolPainter(
                        type: ComponentType.battery,
                        color: const Color(0xFFD97706),
                        strokeWidth: 2.0,
                      ),
                    ),
              color: const Color(0xFFD97706),
            ),
            // LED
            WorkbenchSymbolToolboxTile<String>(
              data: 'led_red',
              label: 'LED',
              tooltip: 'LED Vermelho (Semicondutor)',
              symbolWidget: _usePhysicalStyle
                  ? CustomPaint(
                      size: const Size(34, 34),
                      painter: ComponentPhysicalPainter(
                        type: ComponentType.led,
                        isActive: false,
                        isDarkMode: false,
                      ),
                    )
                  : CustomPaint(
                      size: const Size(34, 34),
                      painter: CircuitSymbolPainter(
                        type: ComponentType.led,
                        isActive: false,
                        color: const Color(0xFF0F172A),
                        strokeWidth: 2.0,
                      ),
                    ),
              color: Colors.redAccent,
            ),
            // Resistor
            WorkbenchSymbolToolboxTile<String>(
              data: 'resistor',
              label: 'Resistor',
              tooltip: 'Resistor 680Ω',
              symbolWidget: _usePhysicalStyle
                  ? CustomPaint(
                      size: const Size(34, 34),
                      painter: ComponentPhysicalPainter(
                        type: ComponentType.resistor,
                        isDarkMode: false,
                      ),
                    )
                  : CustomPaint(
                      size: const Size(34, 34),
                      painter: CircuitSymbolPainter(
                        type: ComponentType.resistor,
                        color: const Color(0xFF10B981),
                        strokeWidth: 2.0,
                      ),
                    ),
              color: const Color(0xFF10B981),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Simbologia e Regras:',
          style: GoogleFonts.rajdhani(color: const Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• Ânodo (+): Terminal maior do LED (polo positivo).',
                style: GoogleFonts.rajdhani(color: const Color(0xFF334155), fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                '• Cátodo (-): Terminal menor (polo negativo).',
                style: GoogleFonts.rajdhani(color: const Color(0xFF334155), fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                '• Resistor: Limita a corrente para evitar a queima do diodo.',
                style: GoogleFonts.rajdhani(color: const Color(0xFF334155), fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              backgroundColor: Colors.white,
            ),
            icon: const Icon(Icons.refresh_rounded, size: 16, color: Color(0xFF64748B)),
            onPressed: _resetCurrentMission,
            label: Text(
              'Reiniciar Bancada',
              style: GoogleFonts.rajdhani(color: const Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUndoRedoButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFCBD5E1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Botão Undo
          Tooltip(
            message: _undoRedoController.canUndo
                ? 'Desfazer: ${_undoRedoController.lastUndoDescription}'
                : 'Nada para desfazer',
            child: IconButton(
              icon: Icon(
                Icons.undo_rounded,
                color: _undoRedoController.canUndo
                    ? const Color(0xFF0284C7)
                    : const Color(0xFFCBD5E1),
                size: 18,
              ),
              onPressed: _undoRedoController.canUndo
                  ? () => setState(() => _undoRedoController.undo())
                  : null,
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ),
          // Contador
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '${_undoRedoController.undoCount}',
              style: GoogleFonts.rajdhani(
                color: const Color(0xFF475569),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Botão Redo
          Tooltip(
            message: _undoRedoController.canRedo
                ? 'Refazer: ${_undoRedoController.lastRedoDescription}'
                : 'Nada para refazer',
            child: IconButton(
              icon: Icon(
                Icons.redo_rounded,
                color: _undoRedoController.canRedo
                    ? const Color(0xFF0284C7)
                    : const Color(0xFFCBD5E1),
                size: 18,
              ),
              onPressed: _undoRedoController.canRedo
                  ? () => setState(() => _undoRedoController.redo())
                  : null,
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ),
        ],
      ),
    );
  }





  /// Componente gráfico de placa de letreiro luminoso de LED estilo Neon/Glassmorphism
  Widget _buildLedSignBoard({
    required String title,
    required Color color,
    required bool isLit,
    bool isBurnt = false,
    bool isDim = false,
  }) {
    final activeColor = isBurnt
        ? Colors.grey
        : isLit
            ? color
            : Colors.white10;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F1D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: activeColor,
          width: 3,
        ),
        boxShadow: isLit && !isBurnt
            ? [
                BoxShadow(
                  color: color.withValues(alpha: isDim ? 0.2 : 0.6),
                  blurRadius: isDim ? 12 : 30,
                  spreadRadius: isDim ? 2 : 6,
                ),
              ]
            : [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isBurnt
                ? Icons.flash_off_rounded
                : isLit
                    ? Icons.lightbulb_rounded
                    : Icons.lightbulb_outline_rounded,
            color: activeColor,
            size: 32,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.rajdhani(
              color: activeColor,
              fontWeight: FontWeight.bold,
              fontSize: 24,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }
}
