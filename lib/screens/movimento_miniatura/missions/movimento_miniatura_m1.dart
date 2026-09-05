import 'package:flutter/material.dart';

import '../../../models/circuit_action.dart';
import '../../../models/first_step_component.dart';
import '../../../models/stand_mission.dart';
import '../../../services/circuit_solver/mission_circuit_builder.dart';
import '../../../state/circuit_undo_redo_controller.dart';
import '../../../widgets/circuit_symbol_painter.dart';
import '../../../widgets/component_physical_painter.dart';
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

/// Missão 1 do Estande 06 — Primeiro Giro do Motor CC.
class MovimentoMiniaturaM1 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const MovimentoMiniaturaM1({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<MovimentoMiniaturaM1> createState() => _MovimentoMiniaturaM1State();
}

class _MovimentoMiniaturaM1State extends State<MovimentoMiniaturaM1>
    with SingleTickerProviderStateMixin {
  final StandMission _mission = StandMission.movimentoMiniaturaMissions[0];
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  late final AnimationController _currentFlowController;

  bool _usePhysicalStyle = true;
  bool _isSimulating = false;

  bool _m1MotorInserted = false;
  bool _m1BatteryInserted = false;
  double _m1BatteryRotation = 0.0;
  double _m1MotorRotation = 0.0;
  String? _m1Prediction;

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

  bool get _isClosed => _m1BatteryInserted && _m1MotorInserted;

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
    if (_m1Prediction == null) {
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
        question:
            'O que acontecerá ao fechar o circuito com o motor CC conectado?',
        options: const [
          'Motor gira',
          'Motor não gira',
          'Motor queima',
          'Não sei'
        ],
        onPredict: (prediction) {
          Navigator.of(context).pop();
          setState(() => _m1Prediction = prediction);
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
        question: 'Por que o motor só gira com o circuito fechado?',
        options: const [
          'Corrente precisa de caminho completo',
          'Motor armazena energia',
          'Bateria precisa de retorno',
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

      if (_m1MotorInserted) {
        final result = await MissionCircuitBuilder()
            .addBattery(id: 'bat1', voltage: 6.0)
            .addMotor(id: 'motor1')
            .connect('bat1', 'B', 'motor1', 'A')
            .connect('motor1', 'B', 'bat1', 'A')
            .simulate();
        if (result.hasClosedLoop && result.errorMessage == null) {
          final currentMa = result.current * 1000;
          feedbackMessage =
              'Motor CC validado! Corrente: ${currentMa.toStringAsFixed(1)}mA. O eixo gera torque rotacional.';
          isSuccess = true;
        } else {
          feedbackMessage = result.errorMessage ??
              'Confira se ambos os terminais do motor estão conectados!';
        }
      } else {
        feedbackMessage =
            'Confira se ambos os terminais do motor estão conectados à fonte didática!';
      }

      final fullMessage = isSuccess
          ? 'Missão "${_mission.title}" concluída! ${_mission.victoryCriteria}.\n\nSua previsão: "$_m1Prediction"\n\nProf. Volts: "${_mission.voltsMediation}"'
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
    final double currentMa = _isClosed ? 120.0 : 0.0;

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
                  leftHeaderWidget: MovimentoStatusCard(isClosed: _isClosed),
                  rightHeaderWidget: MovimentoTelemetryCard(
                    voltage: voltage,
                    currentMa: currentMa,
                    isClosed: _isClosed,
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
              MovimentoPredictionBadge(prediction: _m1Prediction),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double batteryX = 60.0;
        final double motorX = width - 60.0;

        return SizedBox(
          height: 270,
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _currentFlowController,
                  builder: (context, _) => CustomPaint(
                    painter: SchematicCircuitWirePainterMotor(
                      isClosed: _isClosed,
                      animationValue: _currentFlowController.value,
                      wireColor: const Color(0xFF1E293B),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: batteryX - 47.5,
                top: 70,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'battery',
                  isFilled: _m1BatteryInserted,
                  showLabel: false,
                  rotation: _m1BatteryRotation,
                  onAccept: (_) => _insertComponent(
                    name: 'Bateria',
                    getInserted: () => _m1BatteryInserted,
                    setInserted: (v) => _m1BatteryInserted = v,
                    getRotation: () => _m1BatteryRotation,
                    setRotation: (v) => _m1BatteryRotation = v,
                  ),
                  onRotate: () => _rotateComponent(
                    name: 'Bateria',
                    getRotation: () => _m1BatteryRotation,
                    setRotation: (v) => _m1BatteryRotation = v,
                  ),
                  onTap: () {},
                  symbolWidget: CustomPaint(
                    size: const Size(54, 38),
                    painter: ComponentPhysicalPainter(
                      type: ComponentType.battery,
                      isDarkMode: false,
                    ),
                  ),
                  placeholderWidget: CustomPaint(
                    size: const Size(48, 34),
                    painter: ComponentPhysicalPainter(
                      type: ComponentType.battery,
                      isActive: false,
                      isDarkMode: false,
                    ),
                  ),
                  label: '',
                ),
              ),
              Positioned(
                left: motorX - 47.5,
                top: 70,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'motor_cc',
                  isFilled: _m1MotorInserted,
                  showLabel: false,
                  rotation: _m1MotorRotation,
                  onAccept: (_) => _insertComponent(
                    name: 'Motor CC',
                    getInserted: () => _m1MotorInserted,
                    setInserted: (v) => _m1MotorInserted = v,
                    getRotation: () => _m1MotorRotation,
                    setRotation: (v) => _m1MotorRotation = v,
                  ),
                  onRotate: () => _rotateComponent(
                    name: 'Motor CC',
                    getRotation: () => _m1MotorRotation,
                    setRotation: (v) => _m1MotorRotation = v,
                  ),
                  onTap: () {},
                  symbolWidget: CustomPaint(
                    size: const Size(54, 38),
                    painter: ComponentPhysicalPainter(
                      type: ComponentType.motor,
                      isActive: _m1MotorInserted,
                      isDarkMode: false,
                    ),
                  ),
                  placeholderWidget: CustomPaint(
                    size: const Size(48, 34),
                    painter: ComponentPhysicalPainter(
                      type: ComponentType.motor,
                      isActive: false,
                      isDarkMode: false,
                    ),
                  ),
                  label: '',
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 5,
                child: Center(
                  child: MovimentoAnimatedMotorWidget(
                    isRunning: _isClosed,
                    isReversed: false,
                    usePhysicalStyle: _usePhysicalStyle,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSchematicCanvas() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double batteryX = 60.0;
        final double motorX = width - 60.0;

        final batteryPlacement = ComponentPlacement(
          position: Offset(batteryX, 117.5),
          rotation: _m1BatteryRotation,
          type: ComponentType.battery,
        );
        final motorPlacement = ComponentPlacement(
          position: Offset(motorX, 117.5),
          rotation: _m1MotorRotation,
          type: ComponentType.motor,
        );

        final wires = <WirePath>[];
        if (_isClosed) {
          wires.add(DynamicWirePath.fromComponents(
            compA: batteryPlacement,
            terminalIndexA: 1,
            compB: motorPlacement,
            terminalIndexB: 0,
            color: const Color(0xFFD97706),
            isActive: true,
          ).toWirePath());
          wires.add(DynamicWirePath.fromComponents(
            compA: motorPlacement,
            terminalIndexA: 1,
            compB: batteryPlacement,
            terminalIndexB: 0,
            color: const Color(0xFF64748B),
            isActive: true,
          ).toWirePath());
        }

        return SizedBox(
          height: 270,
          child: Stack(
            children: [
              if (wires.isNotEmpty)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _currentFlowController,
                    builder: (context, _) => RealisticWireWidget(
                      wires: wires,
                      animationValue: _currentFlowController.value,
                      showElectrons: true,
                    ),
                  ),
                ),
              Positioned(
                left: batteryX - 47.5,
                top: 70,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'battery',
                  isFilled: _m1BatteryInserted,
                  showLabel: false,
                  rotation: _m1BatteryRotation,
                  onAccept: (_) => _insertComponent(
                    name: 'Bateria',
                    getInserted: () => _m1BatteryInserted,
                    setInserted: (v) => _m1BatteryInserted = v,
                    getRotation: () => _m1BatteryRotation,
                    setRotation: (v) => _m1BatteryRotation = v,
                  ),
                  onRotate: () => _rotateComponent(
                    name: 'Bateria',
                    getRotation: () => _m1BatteryRotation,
                    setRotation: (v) => _m1BatteryRotation = v,
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
                left: motorX - 47.5,
                top: 70,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'motor_cc',
                  isFilled: _m1MotorInserted,
                  showLabel: false,
                  rotation: _m1MotorRotation,
                  onAccept: (_) => _insertComponent(
                    name: 'Motor CC',
                    getInserted: () => _m1MotorInserted,
                    setInserted: (v) => _m1MotorInserted = v,
                    getRotation: () => _m1MotorRotation,
                    setRotation: (v) => _m1MotorRotation = v,
                  ),
                  onRotate: () => _rotateComponent(
                    name: 'Motor CC',
                    getRotation: () => _m1MotorRotation,
                    setRotation: (v) => _m1MotorRotation = v,
                  ),
                  onTap: () {},
                  symbolWidget: CustomPaint(
                    size: const Size(55, 55),
                    painter: CircuitSymbolPainter(
                      type: ComponentType.motor,
                      isActive: _m1MotorInserted,
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
              Positioned(
                left: 0,
                right: 0,
                top: 5,
                child: Center(
                  child: MovimentoAnimatedMotorWidget(
                    isRunning: _isClosed,
                    isReversed: false,
                    usePhysicalStyle: _usePhysicalStyle,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
