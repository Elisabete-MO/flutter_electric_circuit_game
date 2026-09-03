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
import '../../widgets/component_physical_painter.dart';
import '../../widgets/circuit_symbol_painter.dart';
import '../../widgets/tech_grid_background.dart';
import '../../widgets/workbench_components.dart';
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

  // Estados da Missão 1 (Polaridade do LED)
  bool _m1LedDirectPolarity = true;
  bool _m1LedInserted = false;
  double _m1LedRotation = 0.0;

  // Estados da Missão 2 (Diagnóstico de LED Invertido)
  bool _m2LedInvertedFixed = false;

  // Estados da Missão 3 (Resistor Limitador de Corrente)
  String? _m3SelectedResistor; // '0', '220', '680', '10000'

  // Estados da Missão 4 (Painel de Sinalização Dupla)
  bool _m4Branch1ResistorPlaced = false;
  bool _m4Branch2ResistorPlaced = false;

  // Estados da Missão 5 (Revisão do Letreiro Defeituoso)
  bool _m5GreenLedPolarityFixed = false;
  bool _m5RedResistorFixed = false;

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
          _m3SelectedResistor = null;
          break;
        case 3:
          _m4Branch1ResistorPlaced = false;
          _m4Branch2ResistorPlaced = false;
          break;
        case 4:
          _m5GreenLedPolarityFixed = false;
          _m5RedResistorFixed = false;
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
      case 0: // M1: Polaridade do LED
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
            feedbackMessage = 'LED com polaridade correta! Corrente: ${currentMa.toStringAsFixed(1)}mA.';
            isSuccess = true;
          } else {
            feedbackMessage = result.errorMessage ?? 'Verifique a polaridade do LED.';
          }
        } else if (!_m1LedInserted) {
          feedbackMessage = 'Insira o LED no soquete do circuito!';
        } else {
          feedbackMessage = 'Verifique a polaridade do LED: a corrente so passa no sentido anodo (+) para catodo (-).';
        }
        break;

      case 1: // M2: LED Invertido
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
            feedbackMessage = 'LED invertido corrigido! A corrente flui e o LED emite luz.';
            isSuccess = true;
          } else {
            feedbackMessage = result.errorMessage ?? 'Corrija a polaridade do LED.';
          }
        } else {
          feedbackMessage = 'O LED invertido bloqueia a corrente. Inverta os terminais!';
        }
        break;

      case 2: // M3: Resistor Limitador
        if (_m3SelectedResistor != null) {
          final resistance = double.parse(_m3SelectedResistor!);
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
            if (currentMa >= 10 && currentMa <= 15) {
              feedbackMessage = 'Resistor ideal! Corrente: ${currentMa.toStringAsFixed(1)}mA (faixa segura 10-15mA).';
              isSuccess = true;
            } else if (currentMa > 15) {
              feedbackMessage = 'Corrente excessiva: ${currentMa.toStringAsFixed(1)}mA! O LED pode queimar.';
            } else {
              feedbackMessage = 'Corrente insuficiente: ${currentMa.toStringAsFixed(1)}mA. LED ficara fraco.';
            }
          } else if (result.isShortCircuit) {
            feedbackMessage = 'Curto-circuito! Resistor de 0 ohm causou sobrecorrente!';
          } else {
            feedbackMessage = result.errorMessage ?? 'Circuito com problema.';
          }
        } else {
          feedbackMessage = 'Selecione um resistor para colocar em serie com o LED!';
        }
        break;

      case 3: // M4: Sinalizacao Dupla
        if (_m4Branch1ResistorPlaced && _m4Branch2ResistorPlaced) {
          final result = await MissionCircuitBuilder()
              .addBattery(id: 'bat1', voltage: 9.0)
              .addResistor(id: 'r1', resistance: 680.0)
              .addLed(id: 'led1')
              .connect('bat1', 'B', 'r1', 'A')
              .connect('r1', 'B', 'led1', 'A')
              .connect('led1', 'B', 'bat1', 'A')
              .addResistor(id: 'r2', resistance: 680.0)
              .addLed(id: 'led2')
              .connect('bat1', 'B', 'r2', 'A')
              .connect('r2', 'B', 'led2', 'A')
              .connect('led2', 'B', 'bat1', 'A')
              .simulate();
          if (result.hasClosedLoop && result.errorMessage == null) {
            final i1 = (result.componentCurrents['led1'] ?? 0) * 1000;
            final i2 = (result.componentCurrents['led2'] ?? 0) * 1000;
            feedbackMessage = 'Dois ramos paralelos validados! LED1: ${i1.toStringAsFixed(1)}mA, LED2: ${i2.toStringAsFixed(1)}mA.';
            isSuccess = true;
          } else {
            feedbackMessage = result.errorMessage ?? 'Cada LED precisa de resistor protetor no seu ramo!';
          }
        } else {
          feedbackMessage = 'Cada LED precisa de seu proprio resistor protetor de 680 ohm!';
        }
        break;

      case 4: // M5: Revisao do Letreiro
        if (_m5GreenLedPolarityFixed && _m5RedResistorFixed) {
          final result = await MissionCircuitBuilder()
              .addBattery(id: 'bat1', voltage: 9.0)
              .addResistor(id: 'r1', resistance: 680.0)
              .addLed(id: 'led1', reversed: false)
              .connect('bat1', 'B', 'r1', 'A')
              .connect('r1', 'B', 'led1', 'A')
              .connect('led1', 'B', 'bat1', 'A')
              .addResistor(id: 'r2', resistance: 680.0)
              .addLed(id: 'led2', reversed: false)
              .connect('bat1', 'B', 'r2', 'A')
              .connect('r2', 'B', 'led2', 'A')
              .connect('led2', 'B', 'bat1', 'A')
              .simulate();
          if (result.hasClosedLoop && result.errorMessage == null) {
            feedbackMessage = 'Placa corrigida! Polaridade e resistencia validadas pelo solver.';
            isSuccess = true;
          } else {
            feedbackMessage = result.errorMessage ?? 'Ainda ha erros na placa.';
          }
        } else if (!_m5GreenLedPolarityFixed) {
          feedbackMessage = 'Corrija a polaridade invertida do LED Verde.';
        } else {
          feedbackMessage = 'Substitua o resistor de 0 ohm por 680 ohm no LED Vermelho.';
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
                // Coluna Principal da Bancada (60%)
                Expanded(
                  flex: 3,
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
                      const SizedBox(height: 8),
                      _buildVisualModeSelector(),
                      const SizedBox(height: 12),
                      Expanded(
                        child: _buildLedWorkbench(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Painel Lateral (40%)
                Expanded(
                  flex: 2,
                  child: WorkbenchSidePanel(
                    teamTitle: 'Componentes — Sinalização',
                    toolboxItems: [
                      _buildSidePanelContent(),
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

  /// Visualizador da Missão 1: Polaridade do LED (Placa ATENÇÃO)
  Widget _buildM1SignDisplay() {
    final isLit = _m1LedInserted && _m1LedDirectPolarity;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLedSignBoard(
          title: 'ATENÇÃO',
          color: Colors.redAccent,
          isLit: isLit,
        ),

        // Socket Esquemático do LED Semicondutor
        SchematicBlueprintSocket<String>(
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
          symbolWidget: _usePhysicalStyle
              ? CustomPaint(
                  size: const Size(60, 60),
                  painter: ComponentPhysicalPainter(
                    type: ComponentType.led,
                    isActive: isLit,
                    isDarkMode: false,
                  ),
                )
              : CustomPaint(
                  size: const Size(55, 55),
                  painter: CircuitSymbolPainter(
                    type: ComponentType.led,
                    isActive: isLit,
                    color: const Color(0xFF0F172A),
                    strokeWidth: 2.5,
                  ),
                ),
          placeholderWidget: _usePhysicalStyle
              ? CustomPaint(
                  size: const Size(45, 45),
                  painter: ComponentPhysicalPainter(
                    type: ComponentType.led,
                    isActive: false,
                    isDarkMode: false,
                  ),
                )
              : CustomPaint(
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

  /// Visualizador da Missão 3: Resistor Limitador de Corrente
  Widget _buildM3SignDisplay() {
    final isIdeal = _m3SelectedResistor == '680';
    final isBurnt = _m3SelectedResistor == '0';
    final isTooWeak = _m3SelectedResistor == '10000';
    final isOverheated = _m3SelectedResistor == '220';

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLedSignBoard(
          title: isBurnt ? 'QUEIMADO!' : 'ENTRADA',
          color: isBurnt ? Colors.grey : const Color(0xFF10B981),
          isLit: isIdeal || isOverheated,
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
                'Resistor em Série Selecionado: ${_m3SelectedResistor ?? 'Nenhum'} ${_m3SelectedResistor != null ? 'Ω' : ''}',
                style: GoogleFonts.rajdhani(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildResistorChip('0 Ω (Jumper)', '0'),
                  _buildResistorChip('220 Ω', '220'),
                  _buildResistorChip('680 Ω (Ideal)', '680'),
                  _buildResistorChip('10 kΩ', '10000'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResistorChip(String label, String value) {
    final isSelected = _m3SelectedResistor == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        final prev = _m3SelectedResistor;
        final next = val ? value : null;
        _undoRedoController.execute(SelectOptionAction(
          description: 'Selecionar Resistor $value Ω',
          onApply: () => setState(() => _m3SelectedResistor = next),
          onUndo: () => setState(() => _m3SelectedResistor = prev),
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

  /// Visualizador da Missão 4: Painel de Sinalização Dupla
  Widget _buildM4SignDisplay() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildLedSignBoard(
              title: 'ENTRADA',
              color: const Color(0xFF10B981),
              isLit: _m4Branch1ResistorPlaced,
            ),
            _buildLedSignBoard(
              title: 'SAÍDA',
              color: Colors.redAccent,
              isLit: _m4Branch2ResistorPlaced,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _m4Branch1ResistorPlaced ? const Color(0xFF10B981) : const Color(0xFF1E293B),
                side: const BorderSide(color: Color(0xFF10B981)),
              ),
              icon: Icon(_m4Branch1ResistorPlaced ? Icons.check : Icons.security_rounded),
              label: Text(
                _m4Branch1ResistorPlaced ? 'Resistor 680Ω (Ramo Entrada)' : 'Proteger Ramo 1 (Resistor 680Ω)',
                style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                final prev = _m4Branch1ResistorPlaced;
                _undoRedoController.execute(ToggleBoolAction(
                  description: 'Toggle Resistor Ramo 1',
                  onApply: () => setState(() => _m4Branch1ResistorPlaced = !prev),
                  onUndo: () => setState(() => _m4Branch1ResistorPlaced = prev),
                ));
              },
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _m4Branch2ResistorPlaced ? const Color(0xFF10B981) : const Color(0xFF1E293B),
                side: const BorderSide(color: Color(0xFF10B981)),
              ),
              icon: Icon(_m4Branch2ResistorPlaced ? Icons.check : Icons.security_rounded),
              label: Text(
                _m4Branch2ResistorPlaced ? 'Resistor 680Ω (Ramo Saída)' : 'Proteger Ramo 2 (Resistor 680Ω)',
                style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                final prev = _m4Branch2ResistorPlaced;
                _undoRedoController.execute(ToggleBoolAction(
                  description: 'Toggle Resistor Ramo 2',
                  onApply: () => setState(() => _m4Branch2ResistorPlaced = !prev),
                  onUndo: () => setState(() => _m4Branch2ResistorPlaced = prev),
                ));
              },
            ),
          ],
        ),
      ],
    );
  }

  /// Visualizador da Missão 5: Revisão do Letreiro Defeituoso
  Widget _buildM5SignDisplay() {
    final allFixed = _m5GreenLedPolarityFixed && _m5RedResistorFixed;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildLedSignBoard(
              title: 'ENTRADA',
              color: const Color(0xFF10B981),
              isLit: _m5GreenLedPolarityFixed,
            ),
            _buildLedSignBoard(
              title: 'SAÍDA',
              color: Colors.redAccent,
              isLit: _m5RedResistorFixed,
            ),
          ],
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _m5GreenLedPolarityFixed ? const Color(0xFF10B981) : const Color(0xFF1E293B),
                  side: const BorderSide(color: Color(0xFF10B981)),
                ),
                icon: Icon(_m5GreenLedPolarityFixed ? Icons.check : Icons.flip_camera_android_rounded),
                label: Text(
                  _m5GreenLedPolarityFixed ? 'Polaridade LED Verde Ok' : 'Corrigir Polaridade (LED Verde)',
                  style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  final prev = _m5GreenLedPolarityFixed;
                  _undoRedoController.execute(ToggleBoolAction(
                    description: 'Toggle Polaridade LED Verde',
                    onApply: () => setState(() => _m5GreenLedPolarityFixed = !prev),
                    onUndo: () => setState(() => _m5GreenLedPolarityFixed = prev),
                  ));
                },
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _m5RedResistorFixed ? const Color(0xFF10B981) : const Color(0xFF1E293B),
                  side: const BorderSide(color: Color(0xFF10B981)),
                ),
                icon: Icon(_m5RedResistorFixed ? Icons.check : Icons.build_rounded),
                label: Text(
                  _m5RedResistorFixed ? 'Resistor 680Ω Ok' : 'Substituir 0Ω por 680Ω (LED Vermelho)',
                  style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  final prev = _m5RedResistorFixed;
                  _undoRedoController.execute(ToggleBoolAction(
                    description: 'Toggle Resistor LED Vermelho',
                    onApply: () => setState(() => _m5RedResistorFixed = !prev),
                    onUndo: () => setState(() => _m5RedResistorFixed = prev),
                  ));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }



  Widget _buildSidePanelContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        _buildUndoRedoButtons(),
        const SizedBox(height: 8),
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

  Widget _buildUndoRedoButtons() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
                size: 22,
              ),
              onPressed: _undoRedoController.canUndo
                  ? () => setState(() => _undoRedoController.undo())
                  : null,
              style: IconButton.styleFrom(
                backgroundColor: _undoRedoController.canUndo
                    ? const Color(0xFF0284C7).withValues(alpha: 0.1)
                    : Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${_undoRedoController.undoCount}',
              style: GoogleFonts.rajdhani(
                color: const Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
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
                size: 22,
              ),
              onPressed: _undoRedoController.canRedo
                  ? () => setState(() => _undoRedoController.redo())
                  : null,
              style: IconButton.styleFrom(
                backgroundColor: _undoRedoController.canRedo
                    ? const Color(0xFF0284C7).withValues(alpha: 0.1)
                    : Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
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
