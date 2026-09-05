import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/circuit_action.dart';
import '../../../models/first_step_component.dart';
import '../../../models/stand_mission.dart';
import '../../../services/circuit_solver/mission_circuit_builder.dart';
import '../../../state/circuit_undo_redo_controller.dart';
import '../../../widgets/circuit_symbol_painter.dart';
import '../../../widgets/component_physical_painter.dart';
import '../../../widgets/physical_blueprint_socket.dart';
import '../../../widgets/prof_volts_explanation_dialog.dart';
import '../../../widgets/prof_volts_feedback_dialog.dart';
import '../../../widgets/prof_volts_prediction_dialog.dart';
import '../../../widgets/realistic_wire_painter.dart';
import '../../../widgets/schematic_blueprint_socket.dart';
import '../../../widgets/success_confetti_overlay.dart';
import '../../../widgets/workbench_components.dart';
import '../../../widgets/workbench_table_frame.dart';
import '../widgets/movimento_miniatura_widgets.dart';

/// Missão 4 do Estande 06 — Painel com LED Indicador em Paralelo.
class MovimentoMiniaturaM4 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const MovimentoMiniaturaM4({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<MovimentoMiniaturaM4> createState() => _MovimentoMiniaturaM4State();
}

class _MovimentoMiniaturaM4State extends State<MovimentoMiniaturaM4>
    with SingleTickerProviderStateMixin {
  final StandMission _mission = StandMission.movimentoMiniaturaMissions[3];
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  late final AnimationController _currentFlowController;

  bool _usePhysicalStyle = true;
  bool _isSimulating = false;

  bool _m4LedInserted = false;
  bool _m4ResistorInserted = false;
  bool _m4BatteryInserted = false;
  double _m4BatteryRotation = 0.0;
  bool _m4MotorInserted = false;
  double _m4MotorRotation = 0.0;
  String? _m4Prediction;

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

  bool get _isSystemReady =>
      _m4BatteryInserted &&
      _m4MotorInserted &&
      _m4LedInserted &&
      _m4ResistorInserted;

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
    if (_m4Prediction == null) {
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
        question: 'O LED em paralelo com o motor acende junto? Por que?',
        options: const [
          'LED acende junto com motor',
          'LED não acende',
          'Motor não liga',
          'Não sei'
        ],
        onPredict: (prediction) {
          Navigator.of(context).pop();
          setState(() => _m4Prediction = prediction);
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
            'Por que o LED precisa de resistor mesmo em paralelo com o motor?',
        options: const [
          'LED precisa limitar corrente com resistor próprio',
          'Resistor protege a bateria',
          'Motor já limita a corrente',
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
          final motorCurrent =
              (result.componentCurrents['motor1'] ?? 0) * 1000;
          final ledCurrent =
              (result.componentCurrents['led1'] ?? 0) * 1000;
          feedbackMessage =
              'LED indicador em paralelo validado! Motor: ${motorCurrent.toStringAsFixed(1)}mA, LED: ${ledCurrent.toStringAsFixed(1)}mA.';
          isSuccess = true;
        } else {
          feedbackMessage = result.errorMessage ??
              'O LED indicador precisa de resistor de proteção!';
        }
      } else if (!_m4LedInserted) {
        feedbackMessage =
            'Conecte o LED indicador no ramo em paralelo!';
      } else {
        feedbackMessage =
            'O LED indicador também necessita de resistor de proteção!';
      }

      final fullMessage = isSuccess
          ? 'Missão "${_mission.title}" concluída! ${_mission.victoryCriteria}.\n\nSua previsão: "$_m4Prediction"\n\nProf. Volts: "${_mission.voltsMediation}"'
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
    final double currentMa = _isSystemReady ? 135.0 : 0.0;

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
                      MovimentoStatusCard(isClosed: _isSystemReady),
                  rightHeaderWidget: MovimentoTelemetryCard(
                    voltage: voltage,
                    currentMa: currentMa,
                    isClosed: _isSystemReady,
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
              MovimentoPredictionBadge(prediction: _m4Prediction),
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
                      if (wires.isNotEmpty)
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _currentFlowController,
                            builder: (context, _) => RealisticWireWidget(
                              wires: wires,
                              animationValue: isSystemReady
                                  ? _currentFlowController.value
                                  : 0,
                              showElectrons: isSystemReady,
                            ),
                          ),
                        ),
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
                          onAccept: (_) => _insertComponent(
                            name: 'Bateria',
                            getInserted: () => _m4BatteryInserted,
                            setInserted: (v) => _m4BatteryInserted = v,
                            getRotation: () => _m4BatteryRotation,
                            setRotation: (v) => _m4BatteryRotation = v,
                          ),
                          onRotate: () => _rotateComponent(
                            name: 'Bateria',
                            getRotation: () => _m4BatteryRotation,
                            setRotation: (v) => _m4BatteryRotation = v,
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
                        left: motorX - 47.5,
                        top: topY - 47.5,
                        child: PhysicalBlueprintSocket<String>(
                          expectedData: 'motor_cc',
                          isFilled: _m4MotorInserted,
                          rotation: _m4MotorRotation,
                          width: 95,
                          height: 95,
                          showLabel: false,
                          onAccept: (_) => _insertComponent(
                            name: 'Motor CC',
                            getInserted: () => _m4MotorInserted,
                            setInserted: (v) => _m4MotorInserted = v,
                            getRotation: () => _m4MotorRotation,
                            setRotation: (v) => _m4MotorRotation = v,
                          ),
                          onRotate: () => _rotateComponent(
                            name: 'Motor CC',
                            getRotation: () => _m4MotorRotation,
                            setRotation: (v) => _m4MotorRotation = v,
                          ),
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
                          onAccept: (_) => _insertComponent(
                            name: 'Resistor',
                            getInserted: () => _m4ResistorInserted,
                            setInserted: (v) => _m4ResistorInserted = v,
                            getRotation: () => 0,
                            setRotation: (v) {},
                          ),
                          onRotate: () {},
                          onTap: () => setState(() =>
                              _m4ResistorInserted = !_m4ResistorInserted),
                          symbolWidget: CustomPaint(
                            size: const Size(55, 55),
                            painter: ComponentPhysicalPainter(
                              type: ComponentType.resistor,
                              isDarkMode: false,
                            ),
                          ),
                        ),
                      ),
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
                          onAccept: (_) => _insertComponent(
                            name: 'LED',
                            getInserted: () => _m4LedInserted,
                            setInserted: (v) => _m4LedInserted = v,
                            getRotation: () => 0,
                            setRotation: (v) {},
                          ),
                          onRotate: () {},
                          onTap: () => setState(
                              () => _m4LedInserted = !_m4LedInserted),
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
                color: isSystemReady
                    ? const Color(0xFF10B981)
                    : const Color(0xFF64748B),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isSystemReady
                    ? 'Circuito Paralelo Completo: Motor + LED'
                    : 'Insira Resistor e LED no ramo paralelo',
                style: GoogleFonts.rajdhani(
                  color: isSystemReady
                      ? const Color(0xFF10B981)
                      : const Color(0xFF64748B),
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

  Widget _buildSchematicCanvas() {
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
                      if (wires.isNotEmpty)
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _currentFlowController,
                            builder: (context, _) => RealisticWireWidget(
                              wires: wires,
                              animationValue: isSystemReady
                                  ? _currentFlowController.value
                                  : 0,
                              showElectrons: isSystemReady,
                            ),
                          ),
                        ),
                      Positioned(
                        left: batteryX - 47.5,
                        top: topY - 47.5,
                        child: SchematicBlueprintSocket<String>(
                          expectedData: 'battery',
                          isFilled: _m4BatteryInserted,
                          showLabel: false,
                          rotation: _m4BatteryRotation,
                          onAccept: (_) => _insertComponent(
                            name: 'Bateria',
                            getInserted: () => _m4BatteryInserted,
                            setInserted: (v) => _m4BatteryInserted = v,
                            getRotation: () => _m4BatteryRotation,
                            setRotation: (v) => _m4BatteryRotation = v,
                          ),
                          onRotate: () => _rotateComponent(
                            name: 'Bateria',
                            getRotation: () => _m4BatteryRotation,
                            setRotation: (v) => _m4BatteryRotation = v,
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
                        top: topY - 47.5,
                        child: SchematicBlueprintSocket<String>(
                          expectedData: 'motor_cc',
                          isFilled: _m4MotorInserted,
                          showLabel: false,
                          rotation: _m4MotorRotation,
                          onAccept: (_) => _insertComponent(
                            name: 'Motor CC',
                            getInserted: () => _m4MotorInserted,
                            setInserted: (v) => _m4MotorInserted = v,
                            getRotation: () => _m4MotorRotation,
                            setRotation: (v) => _m4MotorRotation = v,
                          ),
                          onRotate: () => _rotateComponent(
                            name: 'Motor CC',
                            getRotation: () => _m4MotorRotation,
                            setRotation: (v) => _m4MotorRotation = v,
                          ),
                          onTap: () {},
                          symbolWidget: CustomPaint(
                            size: const Size(55, 55),
                            painter: CircuitSymbolPainter(
                              type: ComponentType.motor,
                              isActive: isSystemReady,
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
                        left: resistorX - 47.5,
                        top: bottomY - 47.5,
                        child: SchematicBlueprintSocket<String>(
                          expectedData: 'resistor_680',
                          isFilled: _m4ResistorInserted,
                          showLabel: false,
                          rotation: 0,
                          onAccept: (_) => _insertComponent(
                            name: 'Resistor',
                            getInserted: () => _m4ResistorInserted,
                            setInserted: (v) => _m4ResistorInserted = v,
                            getRotation: () => 0,
                            setRotation: (v) {},
                          ),
                          onRotate: () {},
                          onTap: () => setState(() =>
                              _m4ResistorInserted = !_m4ResistorInserted),
                          symbolWidget: CustomPaint(
                            size: const Size(55, 55),
                            painter: CircuitSymbolPainter(
                              type: ComponentType.resistor,
                              color: const Color(0xFF0F172A),
                              strokeWidth: 2.5,
                            ),
                          ),
                          placeholderWidget: CustomPaint(
                            size: const Size(48, 38),
                            painter: CircuitSymbolPainter(
                              type: ComponentType.resistor,
                              isActive: false,
                              color: const Color(0xFF94A3B8),
                              strokeWidth: 2.0,
                            ),
                          ),
                          label: '',
                        ),
                      ),
                      Positioned(
                        left: ledX - 47.5,
                        top: bottomY - 47.5,
                        child: SchematicBlueprintSocket<String>(
                          expectedData: 'led_indicator',
                          isFilled: _m4LedInserted,
                          showLabel: false,
                          rotation: 0,
                          onAccept: (_) => _insertComponent(
                            name: 'LED',
                            getInserted: () => _m4LedInserted,
                            setInserted: (v) => _m4LedInserted = v,
                            getRotation: () => 0,
                            setRotation: (v) {},
                          ),
                          onRotate: () {},
                          onTap: () => setState(
                              () => _m4LedInserted = !_m4LedInserted),
                          symbolWidget: CustomPaint(
                            size: const Size(55, 55),
                            painter: CircuitSymbolPainter(
                              type: ComponentType.led,
                              isActive: isSystemReady,
                              color: const Color(0xFF0F172A),
                              strokeWidth: 2.5,
                            ),
                          ),
                          placeholderWidget: CustomPaint(
                            size: const Size(48, 38),
                            painter: CircuitSymbolPainter(
                              type: ComponentType.led,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSystemReady ? Icons.check_circle : Icons.info_outline,
                color: isSystemReady
                    ? const Color(0xFF10B981)
                    : const Color(0xFF64748B),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isSystemReady
                    ? 'Circuito Paralelo Completo: Motor + LED'
                    : 'Insira Resistor e LED no ramo paralelo',
                style: GoogleFonts.rajdhani(
                  color: isSystemReady
                      ? const Color(0xFF10B981)
                      : const Color(0xFF64748B),
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
}
