import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/circuit_action.dart';
import '../../../models/first_step_component.dart';
import '../../../models/stand_mission.dart';
import '../../../services/circuit_solver/mission_circuit_builder.dart';
import '../../../state/circuit_undo_redo_controller.dart';
import '../../../widgets/circuit_symbol_painter.dart';
import '../../../widgets/component_physical_painter.dart';
import '../../../widgets/component_vector_painters.dart';
import '../../../widgets/physical_blueprint_socket.dart';
import '../../../widgets/prof_volts_explanation_dialog.dart';
import '../../../widgets/prof_volts_feedback_dialog.dart';
import '../../../widgets/prof_volts_prediction_dialog.dart';
import '../../../widgets/realistic_wire_painter.dart';
import '../../../widgets/schematic_blueprint_socket.dart';
import '../../../widgets/schematic_symbol_painters.dart';
import '../../../widgets/success_confetti_overlay.dart';
import '../../../widgets/workbench_components.dart';
import '../../../widgets/workbench_table_frame.dart';
import '../widgets/movimento_miniatura_widgets.dart';

/// Missão 3 do Estande 06 — Partida com Push-button.
class MovimentoMiniaturaM3 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const MovimentoMiniaturaM3({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<MovimentoMiniaturaM3> createState() => _MovimentoMiniaturaM3State();
}

class _MovimentoMiniaturaM3State extends State<MovimentoMiniaturaM3>
    with SingleTickerProviderStateMixin {
  final StandMission _mission = StandMission.movimentoMiniaturaMissions[2];
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  late final AnimationController _currentFlowController;

  bool _usePhysicalStyle = true;
  bool _isSimulating = false;

  bool _m3PushButtonInserted = false;
  bool _m3PushButtonPressed = false;
  bool _m3BatteryInserted = false;
  double _m3BatteryRotation = 0.0;
  bool _m3MotorInserted = false;
  double _m3MotorRotation = 0.0;
  String? _m3Prediction;

  @override
  void initState() {
    super.initState();
    _currentFlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _currentFlowController.dispose();
    super.dispose();
  }

  bool get _isMotorSpinning =>
      _m3BatteryInserted &&
      _m3PushButtonInserted &&
      _m3MotorInserted &&
      _m3PushButtonPressed;

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
      description: 'Girar $name (${newRotation.toInt()}°)',
      onApply: () => setState(() => setRotation(newRotation)),
      onUndo: () => setState(() => setRotation(prevRotation)),
    ));
  }

  void _onEnergizePressed() {
    if (_m3Prediction == null) {
      _showPredictionDialog();
    } else {
      _validateMission();
    }
  }

  void _showPredictionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProfVoltsPredictionDialog(
        question: 'Com o push-button em série, quando o motor gira?',
        options: const [
          'Motor gira só pressionando',
          'Motor gira sempre',
          'Motor não gira nunca',
          'Não sei'
        ],
        onPredict: (prediction) {
          Navigator.of(context).pop();
          setState(() => _m3Prediction = prediction);
          _validateMission();
        },
      ),
    );
  }

  void _showExplanationDialog(bool isSuccess) {
    if (!isSuccess || !mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProfVoltsExplanationDialog(
        question:
            'Por que o motor só gira enquanto o botão está pressionado?',
        options: const [
          'Push-button é momentâneo, só fecha ao pressionar',
          'Motor precisa de impulso constante',
          'Bateria descarrega rápido',
          'Não sei explicar'
        ],
        onExplain: (_) {
          Navigator.of(context).pop();
          showSuccessConfetti(context);
          widget.onMissionComplete();
        },
      ),
    );
  }

  Future<void> _validateMission() async {
    if (_isSimulating) return;
    setState(() => _isSimulating = true);

    try {
      bool isSuccess = false;
      String feedbackMessage = _mission.failureFeedback;

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
          feedbackMessage =
              'Push-button acionado! Motor CC em operação via interruptor de pressão.';
          isSuccess = true;
        } else {
          feedbackMessage = result.errorMessage ??
              'O interruptor deve interromper a corrente quando solto.';
        }
      } else if (!_m3PushButtonInserted) {
        feedbackMessage =
            'Instale o interruptor tipo push-button na linha de corrente!';
      } else {
        feedbackMessage =
            'Pressione e segure o botão de partida para acionar o motor CC.';
      }

      final fullMessage = isSuccess
          ? 'Missão "${_mission.title}" concluída! ${_mission.victoryCriteria}.\n\nSua previsão: "$_m3Prediction"\n\nProf. Volts: "${_mission.voltsMediation}"'
          : '$feedbackMessage\n\nProf. Volts: "${_mission.voltsMediation}"';

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
                _showExplanationDialog(true);
              }
            },
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSimulating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double voltage = 6.0;
    final double currentMa = _isMotorSpinning ? 120.0 : 0.0;

    return Row(
      children: [
        Expanded(
          flex: 7,
          child: Column(
            children: [
              Expanded(
                child: WorkbenchTableFrame(
                  usePhysicalStyle: _usePhysicalStyle,
                  onStyleChanged: (val) =>
                      setState(() => _usePhysicalStyle = val),
                  leftHeaderWidget:
                      MovimentoStatusCard(isClosed: _isMotorSpinning),
                  rightHeaderWidget: MovimentoTelemetryCard(
                    voltage: voltage,
                    currentMa: currentMa,
                    isClosed: _isMotorSpinning,
                  ),
                  child: _usePhysicalStyle
                      ? _buildPhysicalCanvas()
                      : _buildSchematicCanvas(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: WorkbenchSidePanel(
            teamTitle: 'Painel da Equipe Mecânica',
            toolboxItems: [
              MovimentoPredictionBadge(prediction: _m3Prediction),
              MovimentoUndoRedoButtons(
                controller: _undoRedoController,
                onUndo: () => setState(() => _undoRedoController.undo()),
                onRedo: () => setState(() => _undoRedoController.redo()),
              ),
              MovimentoSideToolbox(usePhysicalStyle: _usePhysicalStyle),
            ],
            onEnergizePressed: _onEnergizePressed,
            isLoading: _isSimulating,
          ),
        ),
      ],
    );
  }

  Widget _buildPhysicalCanvas() {
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
                      isActive: _isMotorSpinning,
                    ).toWirePath());
                  }
                  if (_m3PushButtonInserted && _m3MotorInserted) {
                    wires.add(DynamicWirePath.fromComponents(
                      compA: switchPlacement,
                      terminalIndexA: 1,
                      compB: motorPlacement,
                      terminalIndexB: 0,
                      color: const Color(0xFF0284C7),
                      isActive: _isMotorSpinning,
                    ).toWirePath());
                  }
                  if (_m3MotorInserted && _m3BatteryInserted) {
                    wires.add(DynamicWirePath.fromComponents(
                      compA: motorPlacement,
                      terminalIndexA: 1,
                      compB: batteryPlacement,
                      terminalIndexB: 0,
                      color: const Color(0xFF64748B),
                      isActive: _isMotorSpinning,
                    ).toWirePath());
                  }

                  return Stack(
                    children: [
                      if (wires.isNotEmpty)
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _currentFlowController,
                            builder: (context, _) => RealisticWireWidget(
                              wires: wires,
                              animationValue: _isMotorSpinning
                                  ? _currentFlowController.value
                                  : 0,
                              showElectrons: _isMotorSpinning,
                            ),
                          ),
                        ),
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
                          onAccept: (_) => _insertComponent(
                            name: 'Bateria',
                            getInserted: () => _m3BatteryInserted,
                            setInserted: (v) => _m3BatteryInserted = v,
                            getRotation: () => _m3BatteryRotation,
                            setRotation: (v) => _m3BatteryRotation = v,
                          ),
                          onRotate: () => _rotateComponent(
                            name: 'Bateria',
                            getRotation: () => _m3BatteryRotation,
                            setRotation: (v) => _m3BatteryRotation = v,
                          ),
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
                          onAccept: (_) => _insertComponent(
                            name: 'Botão',
                            getInserted: () => _m3PushButtonInserted,
                            setInserted: (v) => _m3PushButtonInserted = v,
                            getRotation: () => 0,
                            setRotation: (v) {},
                          ),
                          onRotate: () {},
                          onTap: () {
                            if (_m3PushButtonInserted) {
                              setState(() =>
                                  _m3PushButtonPressed = !_m3PushButtonPressed);
                            }
                          },
                          symbolWidget: _usePhysicalStyle
                              ? const PushButtonVectorWidget(size: 55)
                              : const SchematicSwitchWidget(
                                  size: 55,
                                  isPushButton: true,
                                  color: Color(0xFFEF4444),
                                ),
                        ),
                      ),
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
                          onAccept: (_) => _insertComponent(
                            name: 'Motor CC',
                            getInserted: () => _m3MotorInserted,
                            setInserted: (v) => _m3MotorInserted = v,
                            getRotation: () => _m3MotorRotation,
                            setRotation: (v) => _m3MotorRotation = v,
                          ),
                          onRotate: () => _rotateComponent(
                            name: 'Motor CC',
                            getRotation: () => _m3MotorRotation,
                            setRotation: (v) => _m3MotorRotation = v,
                          ),
                          onTap: () {},
                          symbolWidget: CustomPaint(
                            size: const Size(55, 55),
                            painter: ComponentPhysicalPainter(
                              type: ComponentType.motor,
                              isActive: _isMotorSpinning,
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
              onTapDown: (_) =>
                  setState(() => _m3PushButtonPressed = true),
              onTapUp: (_) =>
                  setState(() => _m3PushButtonPressed = false),
              onTapCancel: () =>
                  setState(() => _m3PushButtonPressed = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: _m3PushButtonPressed
                      ? const Color(0xFF0284C7)
                      : const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (_m3PushButtonPressed
                              ? const Color(0xFF0284C7)
                              : const Color(0xFF0F172A))
                          .withValues(alpha: 0.2),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _m3PushButtonPressed
                          ? Icons.play_arrow_rounded
                          : Icons.radio_button_checked_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _m3PushButtonPressed
                          ? 'MOTOR EM PARTIDA!'
                          : 'SEGURE PARA ACIONAR',
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
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

  Widget _buildSchematicCanvas() {
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
                      isActive: _isMotorSpinning,
                    ).toWirePath());
                  }
                  if (_m3PushButtonInserted && _m3MotorInserted) {
                    wires.add(DynamicWirePath.fromComponents(
                      compA: switchPlacement,
                      terminalIndexA: 1,
                      compB: motorPlacement,
                      terminalIndexB: 0,
                      color: const Color(0xFF0284C7),
                      isActive: _isMotorSpinning,
                    ).toWirePath());
                  }
                  if (_m3MotorInserted && _m3BatteryInserted) {
                    wires.add(DynamicWirePath.fromComponents(
                      compA: motorPlacement,
                      terminalIndexA: 1,
                      compB: batteryPlacement,
                      terminalIndexB: 0,
                      color: const Color(0xFF64748B),
                      isActive: _isMotorSpinning,
                    ).toWirePath());
                  }

                  return Stack(
                    children: [
                      if (wires.isNotEmpty)
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _currentFlowController,
                            builder: (context, _) => RealisticWireWidget(
                              wires: wires,
                              animationValue: _isMotorSpinning
                                  ? _currentFlowController.value
                                  : 0,
                              showElectrons: _isMotorSpinning,
                            ),
                          ),
                        ),
                      Positioned(
                        left: batteryX - 47.5,
                        top: centerY - 47.5,
                        child: SchematicBlueprintSocket<String>(
                          expectedData: 'battery',
                          isFilled: _m3BatteryInserted,
                          showLabel: false,
                          rotation: _m3BatteryRotation,
                          onAccept: (_) => _insertComponent(
                            name: 'Bateria',
                            getInserted: () => _m3BatteryInserted,
                            setInserted: (v) => _m3BatteryInserted = v,
                            getRotation: () => _m3BatteryRotation,
                            setRotation: (v) => _m3BatteryRotation = v,
                          ),
                          onRotate: () => _rotateComponent(
                            name: 'Bateria',
                            getRotation: () => _m3BatteryRotation,
                            setRotation: (v) => _m3BatteryRotation = v,
                          ),
                          onTap: () {},
                          symbolWidget: CustomPaint(
                            size: const Size(55, 55),
                            painter: CircuitSymbolPainter(
                              type: ComponentType.battery,
                              color: const Color(0xFF0F172A),
                              strokeWidth: 2.5,
                            ),
                          ),
                          placeholderWidget: CustomPaint(
                            size: const Size(48, 38),
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
                      Positioned(
                        left: switchX - 47.5,
                        top: centerY - 47.5,
                        child: SchematicBlueprintSocket<String>(
                          expectedData: 'push_button',
                          isFilled: _m3PushButtonInserted,
                          showLabel: false,
                          rotation: 0,
                          onAccept: (_) => _insertComponent(
                            name: 'Push-Button',
                            getInserted: () => _m3PushButtonInserted,
                            setInserted: (v) => _m3PushButtonInserted = v,
                            getRotation: () => 0,
                            setRotation: (v) {},
                          ),
                          onRotate: () {},
                          onTap: () => setState(() =>
                              _m3PushButtonPressed = !_m3PushButtonPressed),
                          symbolWidget: const SchematicSwitchWidget(
                            size: 55,
                            isPushButton: true,
                            color: Color(0xFFEF4444),
                          ),
                          placeholderWidget: const SchematicSwitchWidget(
                            size: 48,
                            isPushButton: true,
                            color: Color(0xFF94A3B8),
                          ),
                          label: '',
                        ),
                      ),
                      Positioned(
                        left: motorX - 47.5,
                        top: centerY - 47.5,
                        child: SchematicBlueprintSocket<String>(
                          expectedData: 'motor_cc',
                          isFilled: _m3MotorInserted,
                          showLabel: false,
                          rotation: _m3MotorRotation,
                          onAccept: (_) => _insertComponent(
                            name: 'Motor CC',
                            getInserted: () => _m3MotorInserted,
                            setInserted: (v) => _m3MotorInserted = v,
                            getRotation: () => _m3MotorRotation,
                            setRotation: (v) => _m3MotorRotation = v,
                          ),
                          onRotate: () => _rotateComponent(
                            name: 'Motor CC',
                            getRotation: () => _m3MotorRotation,
                            setRotation: (v) => _m3MotorRotation = v,
                          ),
                          onTap: () {},
                          symbolWidget: CustomPaint(
                            size: const Size(55, 55),
                            painter: CircuitSymbolPainter(
                              type: ComponentType.motor,
                              isActive: _isMotorSpinning,
                              color: const Color(0xFF0F172A),
                              strokeWidth: 2.5,
                            ),
                          ),
                          placeholderWidget: CustomPaint(
                            size: const Size(48, 38),
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
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (_m3PushButtonInserted)
            GestureDetector(
              onTapDown: (_) =>
                  setState(() => _m3PushButtonPressed = true),
              onTapUp: (_) =>
                  setState(() => _m3PushButtonPressed = false),
              onTapCancel: () =>
                  setState(() => _m3PushButtonPressed = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: _m3PushButtonPressed
                      ? const Color(0xFF0284C7)
                      : const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (_m3PushButtonPressed
                              ? const Color(0xFF0284C7)
                              : const Color(0xFF0F172A))
                          .withValues(alpha: 0.2),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _m3PushButtonPressed
                          ? Icons.play_arrow_rounded
                          : Icons.radio_button_checked_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _m3PushButtonPressed
                          ? 'MOTOR EM PARTIDA!'
                          : 'SEGURE PARA ACIONAR',
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
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
}
