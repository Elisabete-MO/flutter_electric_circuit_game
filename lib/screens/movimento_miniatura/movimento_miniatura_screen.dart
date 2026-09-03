import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/stand_mission.dart';
import '../../models/first_step_component.dart';
import '../../state/circuit_undo_redo_controller.dart';
import '../../state/progress_controller.dart';
import '../../services/circuit_solver/mission_circuit_builder.dart';
import '../../widgets/prof_volts_feedback_dialog.dart';
import '../../widgets/schematic_blueprint_socket.dart';
import '../../widgets/physical_blueprint_socket.dart';
import '../../widgets/realistic_wire_painter.dart';
import '../../widgets/schematic_symbol_painters.dart';
import '../../widgets/component_physical_painter.dart';
import '../../widgets/component_vector_painters.dart';
import '../../widgets/circuit_symbol_painter.dart';
import '../../widgets/tech_grid_background.dart';
import '../../widgets/workbench_components.dart';
import '../../widgets/success_confetti_overlay.dart';

/// Estande 06 — "Movimento em Miniatura" (Equipe Mecânica)
class MovimentoMiniaturaScreen extends ConsumerStatefulWidget {
  const MovimentoMiniaturaScreen({super.key});

  @override
  ConsumerState<MovimentoMiniaturaScreen> createState() => _MovimentoMiniaturaScreenState();
}

class _MovimentoMiniaturaScreenState extends ConsumerState<MovimentoMiniaturaScreen>
    with TickerProviderStateMixin {
  late final List<StandMission> _missions;
  int _currentMissionIndex = 0;
  bool _usePhysicalStyle = true;
  final CircuitUndoRedoController _undoRedoController = CircuitUndoRedoController();

  // Controller para rotação da hélice do motor CC
  late final AnimationController _fanController;

  // Controller para animação de elétrons nos fios esquemáticos
  late final AnimationController _currentFlowController;

  // Estátos das Missões:
  // M1: Primeiro Giro do Motor
  bool _m1MotorInserted = false;
  bool _m1BatteryInserted = false;
  double _m1BatteryRotation = 0.0;
  double _m1MotorRotation = 0.0;

  // M2: Inversão de Sentido de Rotação
  bool _m2ReversedPolarity = false;
  bool _m2BatteryInserted = false;
  double _m2BatteryRotation = 0.0;
  bool _m2MotorInserted = false;
  double _m2MotorRotation = 0.0;

  // M3: Botão de Partida do Motor (Push-button)
  bool _m3PushButtonInserted = false;
  bool _m3PushButtonPressed = false;
  bool _m3BatteryInserted = false;
  double _m3BatteryRotation = 0.0;
  bool _m3MotorInserted = false;
  double _m3MotorRotation = 0.0;

  // M4: Painel com LED Indicador em Paralelo
  bool _m4LedInserted = false;
  bool _m4ResistorInserted = false;
  bool _m4BatteryInserted = false;
  double _m4BatteryRotation = 0.0;
  bool _m4MotorInserted = false;
  double _m4MotorRotation = 0.0;

  // M5: Diagnóstico do Mini Carrinho
  bool _m5WireRepaired = false;
  bool _m5CarTested = false;
  bool _m5BatteryInserted = false;
  double _m5BatteryRotation = 0.0;
  bool _m5MotorInserted = false;
  double _m5MotorRotation = 0.0;

  bool _isSimulating = false;

  StandMission get _currentMission => _missions[_currentMissionIndex];

  @override
  void initState() {
    super.initState();
    _missions = StandMission.movimentoMiniaturaMissions;
    _fanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();
    _currentFlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _fanController.dispose();
    _currentFlowController.dispose();
    super.dispose();
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

  void _previousMission() {
    if (_currentMissionIndex > 0) {
      setState(() {
        _currentMissionIndex--;
        _resetCurrentMission();
      });
    }
  }

  void _resetCurrentMission() {
    switch (_currentMissionIndex) {
      case 0:
        _m1MotorInserted = false;
        break;
      case 1:
        _m2ReversedPolarity = false;
        break;
      case 2:
        _m3PushButtonInserted = false;
        _m3PushButtonPressed = false;
        break;
      case 3:
        _m4LedInserted = false;
        _m4ResistorInserted = false;
        break;
      case 4:
        _m5WireRepaired = false;
        _m5CarTested = false;
        break;
    }
  }

  Future<void> _validateCurrentMission() async {
    if (_isSimulating) return;
    setState(() => _isSimulating = true);

    try {
    bool isSuccess = false;
    String feedbackMessage = _currentMission.failureFeedback;

    switch (_currentMissionIndex) {
      case 0: // M1: Primeiro Giro do Motor
        if (_m1MotorInserted) {
          final result = await MissionCircuitBuilder()
              .addBattery(id: 'bat1', voltage: 6.0)
              .addMotor(id: 'motor1')
              .connect('bat1', 'B', 'motor1', 'A')
              .connect('motor1', 'B', 'bat1', 'A')
              .simulate();
          if (result.hasClosedLoop && result.errorMessage == null) {
            final currentMa = result.current * 1000;
            feedbackMessage = 'Motor CC validado! Corrente: ${currentMa.toStringAsFixed(1)}mA. O eixo gera torque rotacional.';
            isSuccess = true;
          } else {
            feedbackMessage = result.errorMessage ?? 'Confira se ambos os terminais do motor estao conectados!';
          }
        } else {
          feedbackMessage = 'Confira se ambos os terminais do motor estao conectados a fonte didatica!';
        }
        break;

      case 1: // M2: Inversao de Sentido
        if (_m2ReversedPolarity) {
          final result = await MissionCircuitBuilder()
              .addBattery(id: 'bat1', voltage: 6.0)
              .addMotor(id: 'motor1')
              .connect('bat1', 'B', 'motor1', 'A')
              .connect('motor1', 'B', 'bat1', 'A')
              .simulate();
          if (result.hasClosedLoop && result.errorMessage == null) {
            feedbackMessage = 'Polaridade invertida! Campo magnetico reverso giro anti-horario.';
            isSuccess = true;
          } else {
            feedbackMessage = result.errorMessage ?? 'Inverta a polaridade da fonte.';
          }
        } else {
          feedbackMessage = 'Inverta a polaridade da fonte para alterar o sentido do campo magnetico.';
        }
        break;

      case 2: // M3: Botao de Partida
        if (_m3PushButtonInserted && _m3PushButtonPressed) {
          final result = await MissionCircuitBuilder()
              .addBattery(id: 'bat1', voltage: 6.0)
              .addSwitch(id: 'sw1', closed: true)
              .addMotor(id: 'motor1')
              .connect('bat1', 'B', 'sw1', 'A')
              .connect('sw1', 'B', 'motor1', 'A')
              .connect('motor1', 'B', 'bat1', 'A')
              .simulate();
          if (result.hasClosedLoop && result.errorMessage == null) {
            feedbackMessage = 'Push-button acionado! Motor CC em operacao via interruptor de pressao.';
            isSuccess = true;
          } else {
            feedbackMessage = result.errorMessage ?? 'O interruptor deve interromper a corrente quando solto.';
          }
        } else if (!_m3PushButtonInserted) {
          feedbackMessage = 'Instale o interruptor tipo push-button na linha de corrente!';
        } else {
          feedbackMessage = 'Pressione e segure o botao de partida para acionar o motor CC.';
        }
        break;

      case 3: // M4: LED Indicador em Paralelo
        if (_m4LedInserted && _m4ResistorInserted) {
          final result = await MissionCircuitBuilder()
              .addBattery(id: 'bat1', voltage: 6.0)
              .addMotor(id: 'motor1')
              .connect('bat1', 'B', 'motor1', 'A')
              .connect('motor1', 'B', 'bat1', 'A')
              .addResistor(id: 'r1', resistance: 680.0)
              .addLed(id: 'led1')
              .connect('bat1', 'B', 'r1', 'A')
              .connect('r1', 'B', 'led1', 'A')
              .connect('led1', 'B', 'bat1', 'A')
              .simulate();
          if (result.hasClosedLoop && result.errorMessage == null) {
            final motorCurrent = (result.componentCurrents['motor1'] ?? 0) * 1000;
            final ledCurrent = (result.componentCurrents['led1'] ?? 0) * 1000;
            feedbackMessage = 'LED indicador em paralelo validado! Motor: ${motorCurrent.toStringAsFixed(1)}mA, LED: ${ledCurrent.toStringAsFixed(1)}mA.';
            isSuccess = true;
          } else {
            feedbackMessage = result.errorMessage ?? 'O LED indicador precisa de resistor de protecao!';
          }
        } else if (!_m4LedInserted) {
          feedbackMessage = 'Conecte o LED indicador no ramo em paralelo!';
        } else {
          feedbackMessage = 'O LED indicador tambem necessita de resistor de protecao!';
        }
        break;

      case 4: // M5: Diagnostico do Mini Carrinho
        if (_m5WireRepaired && _m5CarTested) {
          final result = await MissionCircuitBuilder()
              .addBattery(id: 'bat1', voltage: 6.0)
              .addMotor(id: 'motor1')
              .connect('bat1', 'B', 'motor1', 'A')
              .connect('motor1', 'B', 'bat1', 'A')
              .simulate();
          if (result.hasClosedLoop && result.errorMessage == null) {
            feedbackMessage = 'Mau contato reparado! Carrinho funcional com corrente circulando.';
            isSuccess = true;
          } else {
            feedbackMessage = result.errorMessage ?? 'Ainda ha problema na fiação.';
          }
        } else if (!_m5WireRepaired) {
          feedbackMessage = 'Inspecione os terminais do motor para encontrar e reparar a fiação solta.';
        } else {
          feedbackMessage = 'Teste o acionamento do mini carrinho apos o reparo!';
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
    ref.read(progressControllerProvider.notifier).markAsCompleted('movimento_miniatura', stars: 3);

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
                style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
          ],
        ),
        content: Text(
          'Parabéns! Você completou todas as missões do Estande "Movimento em Miniatura". A equipe da Mecânica agora domina a conversão de energia elétrica em torque rotacional!',
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
              'ESTANDE 06 — MOVIMENTO EM MINIATURA',
              style: GoogleFonts.rajdhani(
                color: const Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'Equipe Mecânica — Conservação e Transmutação de Energia',
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
                // Área Principal do Laboratório / Bancada
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildStepperHeader(),
                      const SizedBox(height: 8),
                      _buildVisualModeSelector(),
                      const SizedBox(height: 12),
                      Expanded(
                        child: _buildCurrentMissionUI(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Painel Lateral (Gaveta de Componentes & Instruções)
                Expanded(
                  flex: 2,
                  child: _buildSideControlPanel(),
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

  Widget _buildStepperHeader() {
    return WorkbenchHeaderStepper(
      totalMissions: _missions.length,
      currentMissionIndex: _currentMissionIndex,
      missionTitle: _currentMission.title,
      missionObjective: _currentMission.objective,
      onPrevious: _currentMissionIndex > 0 ? _previousMission : null,
      onNext: _currentMissionIndex < _missions.length - 1 ? _nextMission : null,
    );
  }

  Widget _buildCurrentMissionUI() {
    switch (_currentMissionIndex) {
      case 0:
        return _buildM1UI();
      case 1:
        return _buildM2UI();
      case 2:
        return _buildM3UI();
      case 3:
        return _buildM4UI();
      case 4:
        return _buildM5UI();
      default:
        return const SizedBox.shrink();
    }
  }

  // ==========================================
  // MISSÃO 1: Primeiro Giro do Motor
  // ==========================================
  Widget _buildM1UI() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double batteryX = 60.0;
        final double motorX = width - 60.0;

        return SizedBox(
          height: 270,
          child: Stack(
            children: [
              // Fios esquemáticos Bateria-Motor
              Positioned.fill(
                child: CustomPaint(
                  painter: SchematicCircuitWirePainterMotor(
                    isClosed: _m1BatteryInserted && _m1MotorInserted,
                    animationValue: _currentFlowController.value,
                    wireColor: const Color(0xFF1E293B),
                  ),
                ),
              ),

              // Socket da Bateria (Esquerda)
              Positioned(
                left: batteryX - 47.5,
                top: 70,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'battery',
                  isFilled: _m1BatteryInserted,
                  showLabel: false,
                  rotation: _m1BatteryRotation,
                  onAccept: (_) => setState(() => _m1BatteryInserted = true),
                  onRotate: () => setState(() => _m1BatteryRotation = (_m1BatteryRotation + 90) % 360),
                  onTap: () {},
                  symbolWidget: _usePhysicalStyle
                      ? CustomPaint(
                          size: const Size(54, 38),
                          painter: ComponentPhysicalPainter(
                            type: ComponentType.battery,
                            isDarkMode: false,
                          ),
                        )
                      : CustomPaint(
                          size: const Size(54, 38),
                          painter: CircuitSymbolPainter(
                            type: ComponentType.battery,
                            color: const Color(0xFF0F172A),
                            strokeWidth: 2.2,
                          ),
                        ),
                  placeholderWidget: _usePhysicalStyle
                      ? CustomPaint(
                          size: const Size(48, 34),
                          painter: ComponentPhysicalPainter(
                            type: ComponentType.battery,
                            isActive: false,
                            isDarkMode: false,
                          ),
                        )
                      : CustomPaint(
                          size: const Size(48, 34),
                          painter: CircuitSymbolPainter(
                            type: ComponentType.battery,
                            isActive: false,
                            color: const Color(0xFF94A3B8),
                            strokeWidth: 2.0,
                          ),
                        ),
                  label: '',
                ),
              ),

              // Socket Esquemático para o Motor CC (Direita)
              Positioned(
                left: motorX - 47.5,
                top: 70,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'motor_cc',
                  isFilled: _m1MotorInserted,
                  showLabel: false,
                  rotation: _m1MotorRotation,
                  onAccept: (_) => setState(() => _m1MotorInserted = true),
                  onRotate: () => setState(() => _m1MotorRotation = (_m1MotorRotation + 90) % 360),
                  onTap: () {},
                  symbolWidget: _usePhysicalStyle
                      ? CustomPaint(
                          size: const Size(54, 38),
                          painter: ComponentPhysicalPainter(
                            type: ComponentType.motor,
                            isActive: _m1MotorInserted,
                            isDarkMode: false,
                          ),
                        )
                      : CustomPaint(
                          size: const Size(54, 38),
                          painter: CircuitSymbolPainter(
                            type: ComponentType.motor,
                            isActive: _m1MotorInserted,
                            color: const Color(0xFF0F172A),
                            strokeWidth: 2.2,
                          ),
                        ),
                  placeholderWidget: _usePhysicalStyle
                      ? CustomPaint(
                          size: const Size(48, 34),
                          painter: ComponentPhysicalPainter(
                            type: ComponentType.motor,
                            isActive: false,
                            isDarkMode: false,
                          ),
                        )
                      : CustomPaint(
                          size: const Size(48, 34),
                          painter: CircuitSymbolPainter(
                            type: ComponentType.motor,
                            isActive: false,
                            color: const Color(0xFF94A3B8),
                            strokeWidth: 2.0,
                          ),
                        ),
                  label: '',
                ),
              ),

              // Motor CC com Hélice Animada (Centro Topo Visual)
              Positioned(
                left: 0,
                right: 0,
                top: 5,
                child: Center(
                  child: _buildAnimatedMotorWidget(
                    isRunning: _m1BatteryInserted && _m1MotorInserted,
                    isReversed: false,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // MISSÃO 2: Inversão de Sentido de Rotação
  // ==========================================
  Widget _buildM2UI() {
    final isReversed = _m2ReversedPolarity;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final h = constraints.maxHeight;
                  final batteryX = w * 0.15;
                  final motorX = w * 0.85;
                  final centerY = h * 0.5;

                  final batteryPlacement = ComponentPlacement(
                    position: Offset(batteryX, centerY),
                    rotation: _m2BatteryRotation,
                    type: ComponentType.battery,
                  );
                  final motorPlacement = ComponentPlacement(
                    position: Offset(motorX, centerY),
                    rotation: _m2MotorRotation,
                    type: ComponentType.motor,
                  );

                  final wires = <WirePath>[];
                  if (_m2BatteryInserted && _m2MotorInserted) {
                    wires.add(DynamicWirePath.fromComponents(
                      compA: isReversed ? motorPlacement : batteryPlacement,
                      terminalIndexA: isReversed ? 0 : 1,
                      compB: isReversed ? batteryPlacement : motorPlacement,
                      terminalIndexB: isReversed ? 1 : 0,
                      color: isReversed ? const Color(0xFF0284C7) : const Color(0xFFD97706),
                      isActive: true,
                    ).toWirePath());
                    wires.add(DynamicWirePath.fromComponents(
                      compA: isReversed ? batteryPlacement : motorPlacement,
                      terminalIndexA: isReversed ? 1 : 0,
                      compB: isReversed ? motorPlacement : batteryPlacement,
                      terminalIndexB: isReversed ? 0 : 1,
                      color: const Color(0xFF64748B),
                      isActive: true,
                    ).toWirePath());
                  }

                  return Stack(
                    children: [
                      // Wire paths
                      if (wires.isNotEmpty)
                        Positioned.fill(
                          child: RealisticWireWidget(
                            wires: wires,
                            animationValue: _currentFlowController.value,
                            showElectrons: true,
                          ),
                        ),
                      // Battery socket
                      Positioned(
                        left: batteryX - 47.5,
                        top: centerY - 47.5,
                        child: PhysicalBlueprintSocket<String>(
                          expectedData: 'battery',
                          isFilled: _m2BatteryInserted,
                          rotation: _m2BatteryRotation,
                          width: 95,
                          height: 95,
                          showLabel: false,
                          onAccept: (_) => setState(() => _m2BatteryInserted = true),
                          onRotate: () => setState(() => _m2BatteryRotation = (_m2BatteryRotation + 90) % 360),
                          onTap: () {},
                          symbolWidget: CustomPaint(
                            size: const Size(55, 55),
                            painter: ComponentPhysicalPainter(
                              type: ComponentType.battery,
                              isDarkMode: false,
                            ),
                          ),
                        ),
                      ),
                      // Motor socket
                      Positioned(
                        left: motorX - 47.5,
                        top: centerY - 47.5,
                        child: PhysicalBlueprintSocket<String>(
                          expectedData: 'motor_cc',
                          isFilled: _m2MotorInserted,
                          rotation: _m2MotorRotation,
                          width: 95,
                          height: 95,
                          showLabel: false,
                          onAccept: (_) => setState(() => _m2MotorInserted = true),
                          onRotate: () => setState(() => _m2MotorRotation = (_m2MotorRotation + 90) % 360),
                          onTap: () {},
                          symbolWidget: CustomPaint(
                            size: const Size(55, 55),
                            painter: ComponentPhysicalPainter(
                              type: ComponentType.motor,
                              isActive: _m2BatteryInserted && _m2MotorInserted,
                              isDarkMode: false,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isReversed
                ? 'Sentido: ANTI-HORÁRIO ↺ (Polaridade Invertida -/+)'
                : 'Sentido: HORÁRIO ↻ (Polaridade Padrão +/-)',
            style: GoogleFonts.rajdhani(
              color: isReversed ? const Color(0xFF0284C7) : const Color(0xFFD97706),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0F172A),
              side: BorderSide(
                color: isReversed ? const Color(0xFF0284C7) : const Color(0xFFD97706),
                width: 2,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            icon: const Icon(Icons.sync_alt_rounded, color: Color(0xFF0284C7)),
            label: Text(
              isReversed
                ? 'Polaridade: Polo (-) → Polo (+)'
                : 'Inverter Polaridade (+/- ➔ -/+)',
              style: GoogleFonts.rajdhani(color: const Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 15),
            ),
            onPressed: () => setState(() => _m2ReversedPolarity = !_m2ReversedPolarity),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ==========================================
  // MISSÃO 3: Botão de Partida do Motor
  // ==========================================
  Widget _buildM3UI() {
    final isMotorSpinning = _m3PushButtonInserted && _m3PushButtonPressed;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final h = constraints.maxHeight;
                  final batteryX = w * 0.12;
                  final switchX = w * 0.42;
                  final motorX = w * 0.78;
                  final centerY = h * 0.5;

                  final batteryPlacement = ComponentPlacement(
                    position: Offset(batteryX, centerY),
                    rotation: _m3BatteryRotation,
                    type: ComponentType.battery,
                  );
                  final switchPlacement = ComponentPlacement(
                    position: Offset(switchX, centerY),
                    rotation: 0,
                    type: ComponentType.switchComponent,
                  );
                  final motorPlacement = ComponentPlacement(
                    position: Offset(motorX, centerY),
                    rotation: _m3MotorRotation,
                    type: ComponentType.motor,
                  );

                  final wires = <WirePath>[];
                  if (_m3BatteryInserted && _m3PushButtonInserted) {
                    wires.add(DynamicWirePath.fromComponents(
                      compA: batteryPlacement,
                      terminalIndexA: 1,
                      compB: switchPlacement,
                      terminalIndexB: 0,
                      color: const Color(0xFFD97706),
                      isActive: isMotorSpinning,
                    ).toWirePath());
                  }
                  if (_m3PushButtonInserted && _m3MotorInserted) {
                    wires.add(DynamicWirePath.fromComponents(
                      compA: switchPlacement,
                      terminalIndexA: 1,
                      compB: motorPlacement,
                      terminalIndexB: 0,
                      color: const Color(0xFF0284C7),
                      isActive: isMotorSpinning,
                    ).toWirePath());
                  }
                  if (_m3MotorInserted && _m3BatteryInserted) {
                    wires.add(DynamicWirePath.fromComponents(
                      compA: motorPlacement,
                      terminalIndexA: 1,
                      compB: batteryPlacement,
                      terminalIndexB: 0,
                      color: const Color(0xFF64748B),
                      isActive: isMotorSpinning,
                    ).toWirePath());
                  }

                  return Stack(
                    children: [
                      // Wire paths
                      if (wires.isNotEmpty)
                        Positioned.fill(
                          child: RealisticWireWidget(
                            wires: wires,
                            animationValue: isMotorSpinning ? _currentFlowController.value : 0,
                            showElectrons: isMotorSpinning,
                          ),
                        ),
                      // Battery socket
                      Positioned(
                        left: batteryX - 47.5,
                        top: centerY - 47.5,
                        child: PhysicalBlueprintSocket<String>(
                          expectedData: 'battery',
                          isFilled: _m3BatteryInserted,
                          rotation: _m3BatteryRotation,
                          width: 95,
                          height: 95,
                          showLabel: false,
                          onAccept: (_) => setState(() => _m3BatteryInserted = true),
                          onRotate: () => setState(() => _m3BatteryRotation = (_m3BatteryRotation + 90) % 360),
                          onTap: () {},
                          symbolWidget: CustomPaint(
                            size: const Size(55, 55),
                            painter: ComponentPhysicalPainter(
                              type: ComponentType.battery,
                              isDarkMode: false,
                            ),
                          ),
                        ),
                      ),
                      // Push-button socket (switch)
                      Positioned(
                        left: switchX - 47.5,
                        top: centerY - 47.5,
                        child: PhysicalBlueprintSocket<String>(
                          expectedData: 'push_button',
                          isFilled: _m3PushButtonInserted,
                          rotation: 0,
                          width: 95,
                          height: 95,
                          showLabel: false,
                          onAccept: (_) => setState(() => _m3PushButtonInserted = true),
                          onRotate: () {},
                          onTap: () => setState(() => _m3PushButtonInserted = !_m3PushButtonInserted),
                          symbolWidget: _usePhysicalStyle
                              ? const PushButtonVectorWidget(size: 55)
                              : const SchematicSwitchWidget(size: 55, isPushButton: true, color: Color(0xFFEF4444)),
                        ),
                      ),
                      // Motor socket
                      Positioned(
                        left: motorX - 47.5,
                        top: centerY - 47.5,
                        child: PhysicalBlueprintSocket<String>(
                          expectedData: 'motor_cc',
                          isFilled: _m3MotorInserted,
                          rotation: _m3MotorRotation,
                          width: 95,
                          height: 95,
                          showLabel: false,
                          onAccept: (_) => setState(() => _m3MotorInserted = true),
                          onRotate: () => setState(() => _m3MotorRotation = (_m3MotorRotation + 90) % 360),
                          onTap: () {},
                          symbolWidget: CustomPaint(
                            size: const Size(55, 55),
                            painter: ComponentPhysicalPainter(
                              type: ComponentType.motor,
                              isActive: isMotorSpinning,
                              isDarkMode: false,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (_m3PushButtonInserted)
            GestureDetector(
              onTapDown: (_) => setState(() => _m3PushButtonPressed = true),
              onTapUp: (_) => setState(() => _m3PushButtonPressed = false),
              onTapCancel: () => setState(() => _m3PushButtonPressed = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: _m3PushButtonPressed ? const Color(0xFF0284C7) : const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (_m3PushButtonPressed ? const Color(0xFF0284C7) : const Color(0xFF0F172A)).withValues(alpha: 0.2),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_m3PushButtonPressed ? Icons.play_arrow_rounded : Icons.radio_button_checked_rounded, color: Colors.white, size: 28),
                    const SizedBox(width: 10),
                    Text(
                      _m3PushButtonPressed ? 'MOTOR EM PARTIDA!' : 'SEGURE PARA ACIONAR',
                      style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ==========================================
  // MISSÃO 4: Painel com LED Indicador em Paralelo
  // ==========================================
  Widget _buildM4UI() {
    final isSystemReady = _m4LedInserted && _m4ResistorInserted;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final h = constraints.maxHeight;
                  final batteryX = w * 0.1;
                  final motorX = w * 0.45;
                  final resistorX = w * 0.7;
                  final ledX = w * 0.88;
                  final topY = h * 0.3;
                  final bottomY = h * 0.7;

                  final batteryPlacement = ComponentPlacement(
                    position: Offset(batteryX, topY),
                    rotation: _m4BatteryRotation,
                    type: ComponentType.battery,
                  );
                  final motorPlacement = ComponentPlacement(
                    position: Offset(motorX, topY),
                    rotation: _m4MotorRotation,
                    type: ComponentType.motor,
                  );
                  final resistorPlacement = ComponentPlacement(
                    position: Offset(resistorX, bottomY),
                    rotation: 0,
                    type: ComponentType.resistor,
                  );
                  final ledPlacement = ComponentPlacement(
                    position: Offset(ledX, bottomY),
                    rotation: 0,
                    type: ComponentType.led,
                  );

                  final wires = <WirePath>[];
                  if (_m4BatteryInserted && _m4MotorInserted) {
                    wires.add(DynamicWirePath.fromComponents(
                      compA: batteryPlacement,
                      terminalIndexA: 1,
                      compB: motorPlacement,
                      terminalIndexB: 0,
                      color: const Color(0xFFD97706),
                      isActive: isSystemReady,
                    ).toWirePath());
                    wires.add(DynamicWirePath.fromComponents(
                      compA: motorPlacement,
                      terminalIndexA: 1,
                      compB: batteryPlacement,
                      terminalIndexB: 0,
                      color: const Color(0xFF64748B),
                      isActive: isSystemReady,
                    ).toWirePath());
                  }
                  if (_m4BatteryInserted && _m4ResistorInserted) {
                    wires.add(DynamicWirePath.fromComponents(
                      compA: batteryPlacement,
                      terminalIndexA: 1,
                      compB: resistorPlacement,
                      terminalIndexB: 0,
                      color: const Color(0xFF10B981),
                      isActive: isSystemReady,
                    ).toWirePath());
                  }
                  if (_m4ResistorInserted && _m4LedInserted) {
                    wires.add(DynamicWirePath.fromComponents(
                      compA: resistorPlacement,
                      terminalIndexA: 1,
                      compB: ledPlacement,
                      terminalIndexB: 0,
                      color: const Color(0xFF10B981),
                      isActive: isSystemReady,
                    ).toWirePath());
                  }
                  if (_m4LedInserted && _m4BatteryInserted) {
                    wires.add(DynamicWirePath.fromComponents(
                      compA: ledPlacement,
                      terminalIndexA: 1,
                      compB: batteryPlacement,
                      terminalIndexB: 0,
                      color: const Color(0xFF64748B),
                      isActive: isSystemReady,
                    ).toWirePath());
                  }

                  return Stack(
                    children: [
                      // Wire paths
                      if (wires.isNotEmpty)
                        Positioned.fill(
                          child: RealisticWireWidget(
                            wires: wires,
                            animationValue: isSystemReady ? _currentFlowController.value : 0,
                            showElectrons: isSystemReady,
                          ),
                        ),
                      // Battery socket
                      Positioned(
                        left: batteryX - 47.5,
                        top: topY - 47.5,
                        child: PhysicalBlueprintSocket<String>(
                          expectedData: 'battery',
                          isFilled: _m4BatteryInserted,
                          rotation: _m4BatteryRotation,
                          width: 95,
                          height: 95,
                          showLabel: false,
                          onAccept: (_) => setState(() => _m4BatteryInserted = true),
                          onRotate: () => setState(() => _m4BatteryRotation = (_m4BatteryRotation + 90) % 360),
                          onTap: () {},
                          symbolWidget: CustomPaint(
                            size: const Size(55, 55),
                            painter: ComponentPhysicalPainter(
                              type: ComponentType.battery,
                              isDarkMode: false,
                            ),
                          ),
                        ),
                      ),
                      // Motor socket
                      Positioned(
                        left: motorX - 47.5,
                        top: topY - 47.5,
                        child: PhysicalBlueprintSocket<String>(
                          expectedData: 'motor_cc',
                          isFilled: _m4MotorInserted,
                          rotation: _m4MotorRotation,
                          width: 95,
                          height: 95,
                          showLabel: false,
                          onAccept: (_) => setState(() => _m4MotorInserted = true),
                          onRotate: () => setState(() => _m4MotorRotation = (_m4MotorRotation + 90) % 360),
                          onTap: () {},
                          symbolWidget: CustomPaint(
                            size: const Size(55, 55),
                            painter: ComponentPhysicalPainter(
                              type: ComponentType.motor,
                              isActive: isSystemReady,
                              isDarkMode: false,
                            ),
                          ),
                        ),
                      ),
                      // Resistor socket
                      Positioned(
                        left: resistorX - 47.5,
                        top: bottomY - 47.5,
                        child: PhysicalBlueprintSocket<String>(
                          expectedData: 'resistor_680',
                          isFilled: _m4ResistorInserted,
                          rotation: 0,
                          width: 95,
                          height: 95,
                          showLabel: false,
                          onAccept: (_) => setState(() => _m4ResistorInserted = true),
                          onRotate: () {},
                          onTap: () => setState(() => _m4ResistorInserted = !_m4ResistorInserted),
                          symbolWidget: CustomPaint(
                            size: const Size(55, 55),
                            painter: ComponentPhysicalPainter(
                              type: ComponentType.resistor,
                              isDarkMode: false,
                            ),
                          ),
                        ),
                      ),
                      // LED socket
                      Positioned(
                        left: ledX - 47.5,
                        top: bottomY - 47.5,
                        child: PhysicalBlueprintSocket<String>(
                          expectedData: 'led_indicator',
                          isFilled: _m4LedInserted,
                          rotation: 0,
                          width: 95,
                          height: 95,
                          showLabel: false,
                          onAccept: (_) => setState(() => _m4LedInserted = true),
                          onRotate: () {},
                          onTap: () => setState(() => _m4LedInserted = !_m4LedInserted),
                          symbolWidget: CustomPaint(
                            size: const Size(55, 55),
                            painter: ComponentPhysicalPainter(
                              type: ComponentType.led,
                              isActive: isSystemReady,
                              isDarkMode: false,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSystemReady ? Icons.check_circle : Icons.info_outline,
                color: isSystemReady ? const Color(0xFF10B981) : const Color(0xFF64748B),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isSystemReady
                    ? 'Circuito Paralelo Completo: Motor + LED'
                    : 'Insira Resistor e LED no ramo paralelo',
                style: GoogleFonts.rajdhani(
                  color: isSystemReady ? const Color(0xFF10B981) : const Color(0xFF64748B),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ==========================================
  // MISSÃO 5: Diagnóstico do Mini Carrinho
  // ==========================================
  Widget _buildM5UI() {
    final isWorking = _m5WireRepaired && _m5CarTested && _m5BatteryInserted && _m5MotorInserted;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final h = constraints.maxHeight;
                  final batteryX = w * 0.2;
                  final motorX = w * 0.75;
                  final centerY = h * 0.5;

                  final batteryPlacement = ComponentPlacement(
                    position: Offset(batteryX, centerY),
                    rotation: _m5BatteryRotation,
                    type: ComponentType.battery,
                  );
                  final motorPlacement = ComponentPlacement(
                    position: Offset(motorX, centerY),
                    rotation: _m5MotorRotation,
                    type: ComponentType.motor,
                  );

                  final wires = <WirePath>[];
                  if (_m5BatteryInserted && _m5MotorInserted) {
                    // Top wire: battery(+) -> motor(+)
                    wires.add(DynamicWirePath.fromComponents(
                      compA: batteryPlacement,
                      terminalIndexA: 1,
                      compB: motorPlacement,
                      terminalIndexB: 0,
                      color: _m5WireRepaired ? const Color(0xFF10B981) : const Color(0xFFD97706),
                      isActive: _m5WireRepaired,
                    ).toWirePath());
                    // Bottom wire: motor(-) -> battery(-)
                    wires.add(DynamicWirePath.fromComponents(
                      compA: motorPlacement,
                      terminalIndexA: 1,
                      compB: batteryPlacement,
                      terminalIndexB: 0,
                      color: const Color(0xFF64748B),
                      isActive: _m5WireRepaired,
                    ).toWirePath());
                  }

                  return Stack(
                    children: [
                      // Wire paths
                      if (wires.isNotEmpty)
                        Positioned.fill(
                          child: RealisticWireWidget(
                            wires: wires,
                            animationValue: isWorking ? _currentFlowController.value : 0,
                            showElectrons: isWorking,
                          ),
                        ),
                      // Battery socket
                      Positioned(
                        left: batteryX - 47.5,
                        top: centerY - 47.5,
                        child: PhysicalBlueprintSocket<String>(
                          expectedData: 'battery',
                          isFilled: _m5BatteryInserted,
                          rotation: _m5BatteryRotation,
                          width: 95,
                          height: 95,
                          showLabel: false,
                          onAccept: (_) => setState(() => _m5BatteryInserted = true),
                          onRotate: () => setState(() => _m5BatteryRotation = (_m5BatteryRotation + 90) % 360),
                          onTap: () {},
                          symbolWidget: CustomPaint(
                            size: const Size(55, 55),
                            painter: ComponentPhysicalPainter(
                              type: ComponentType.battery,
                              isDarkMode: false,
                            ),
                          ),
                        ),
                      ),
                      // Motor socket
                      Positioned(
                        left: motorX - 47.5,
                        top: centerY - 47.5,
                        child: PhysicalBlueprintSocket<String>(
                          expectedData: 'motor_cc',
                          isFilled: _m5MotorInserted,
                          rotation: _m5MotorRotation,
                          width: 95,
                          height: 95,
                          showLabel: false,
                          onAccept: (_) => setState(() => _m5MotorInserted = true),
                          onRotate: () => setState(() => _m5MotorRotation = (_m5MotorRotation + 90) % 360),
                          onTap: () {},
                          symbolWidget: CustomPaint(
                            size: const Size(55, 55),
                            painter: ComponentPhysicalPainter(
                              type: ComponentType.motor,
                              isActive: isWorking,
                              isDarkMode: false,
                            ),
                          ),
                        ),
                      ),
                      // Broken wire icon overlay
                      if (_m5BatteryInserted && _m5MotorInserted && !_m5WireRepaired)
                        Positioned(
                          left: (batteryX + motorX) / 2 - 20,
                          top: centerY - 40,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD97706).withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _m5WireRepaired ? const Color(0xFF0284C7) : const Color(0xFFD97706)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _m5WireRepaired ? Icons.build_circle_rounded : Icons.warning_amber_rounded,
                  color: _m5WireRepaired ? const Color(0xFF0284C7) : const Color(0xFFD97706),
                ),
                const SizedBox(width: 10),
                Text(
                  _m5WireRepaired
                      ? 'Fiação Reparada: Mau contato corrigido!'
                      : 'Diagnóstico: Fio solto no terminal positivo',
                  style: GoogleFonts.rajdhani(color: const Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0F172A),
                  side: BorderSide(color: _m5WireRepaired ? const Color(0xFF0284C7) : const Color(0xFFD97706)),
                ),
                icon: const Icon(Icons.handyman_rounded, color: Color(0xFFD97706)),
                label: Text(
                  _m5WireRepaired ? 'Reparado (Soldado)' : 'Reparar Mau Contato',
                  style: GoogleFonts.rajdhani(color: const Color(0xFF0F172A), fontWeight: FontWeight.bold),
                ),
                onPressed: () => setState(() => _m5WireRepaired = !_m5WireRepaired),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                label: Text(
                  'Testar Carrinho',
                  style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onPressed: () => setState(() => _m5CarTested = true),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // --- Widget Animado do Motor CC ---
  Widget _buildAnimatedMotorWidget({required bool isRunning, required bool isReversed}) {
    return Column(
      children: [
        if (_usePhysicalStyle)
          CustomPaint(
            size: const Size(100, 100),
            painter: ComponentPhysicalPainter(
              type: ComponentType.motor,
              isActive: isRunning,
              isDarkMode: false,
            ),
          )
        else
          CustomPaint(
            size: const Size(90, 90),
            painter: CircuitSymbolPainter(
              type: ComponentType.motor,
              isActive: isRunning,
              color: const Color(0xFF0F172A),
              strokeWidth: 2.5,
            ),
          ),
        const SizedBox(height: 8),
        Text(
          isRunning ? 'MOTOR CC EM OPERAÇÃO ⚡' : 'MOTOR CC DESLIGADO ⚪',
          style: GoogleFonts.rajdhani(
            color: isRunning ? const Color(0xFF0284C7) : const Color(0xFF64748B),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildSideControlPanel() {
    return WorkbenchSidePanel(
      teamTitle: 'Painel da Equipe Mecânica',
      toolboxItems: [
        _buildUndoRedoButtons(),
        _buildSideToolboxDrawer(),
      ],
      onEnergizePressed: _validateCurrentMission,
      isLoading: _isSimulating,
    );
  }

  Widget _buildUndoRedoButtons() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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

  Widget _buildSideToolboxDrawer() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        WorkbenchSymbolToolboxTile<String>(
          data: 'motor_cc',
          label: 'Motor CC',
          tooltip: 'Motor CC',
          symbolWidget: _usePhysicalStyle
              ? CustomPaint(
                  size: const Size(34, 34),
                  painter: ComponentPhysicalPainter(
                    type: ComponentType.motor,
                    isActive: false,
                    isDarkMode: false,
                  ),
                )
              : CustomPaint(
                  size: const Size(34, 34),
                  painter: CircuitSymbolPainter(
                    type: ComponentType.motor,
                    isActive: false,
                    color: const Color(0xFF0F172A),
                    strokeWidth: 2.0,
                  ),
                ),
          color: const Color(0xFF0284C7),
        ),
        WorkbenchSymbolToolboxTile<String>(
          data: 'push_button',
          label: 'Push-Button',
          tooltip: 'Botão de Pressão (Momentâneo)',
          symbolWidget: _usePhysicalStyle
              ? const PushButtonVectorWidget(size: 34)
              : const SchematicSwitchWidget(
                  size: 34,
                  isPushButton: true,
                  color: Color(0xFFEF4444),
                ),
          color: const Color(0xFFEF4444),
        ),
        WorkbenchSymbolToolboxTile<String>(
          data: 'led_indicator',
          label: 'LED',
          tooltip: 'LED Indicador',
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
        WorkbenchSymbolToolboxTile<String>(
          data: 'resistor_680',
          label: 'Resistor',
          tooltip: 'Resistor (680Ω)',
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
                    color: const Color(0xFF0F172A),
                    strokeWidth: 2.0,
                  ),
                ),
          color: const Color(0xFFD97706),
        ),
      ],
    );
  }
}
