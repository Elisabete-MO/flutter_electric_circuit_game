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

/// Missão 2 do Estande 06 — Inversão de Polaridade e Sentido de Rotação.
class MovimentoMiniaturaM2 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const MovimentoMiniaturaM2({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<MovimentoMiniaturaM2> createState() => _MovimentoMiniaturaM2State();
}

class _MovimentoMiniaturaM2State extends State<MovimentoMiniaturaM2>
    with SingleTickerProviderStateMixin {
  final StandMission _mission = StandMission.movimentoMiniaturaMissions[1];
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  late final AnimationController _currentFlowController;

  bool _usePhysicalStyle = true;
  bool _isSimulating = false;

  bool _m2ReversedPolarity = false;
  bool _m2BatteryInserted = false;
  double _m2BatteryRotation = 0.0;
  bool _m2MotorInserted = false;
  double _m2MotorRotation = 0.0;
  String? _m2Prediction;

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

  bool get _isClosed => _m2BatteryInserted && _m2MotorInserted;

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
    if (_m2Prediction == null) {
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
            'Se inverter a polaridade da bateria, o que acontece com o motor?',
        options: const [
          'Gira no mesmo sentido',
          'Gira no sentido inverso',
          'Para de girar',
          'Não sei'
        ],
        onPredict: (prediction) {
          Navigator.of(context).pop();
          setState(() => _m2Prediction = prediction);
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
        question: 'Por que inverter a polaridade muda o sentido do motor?',
        options: const [
          'Polaridade inverte o campo magnético',
          'Corrente muda de intensidade',
          'Resistor inverte a queda',
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

      if (_m2ReversedPolarity) {
        final result = await MissionCircuitBuilder()
            .addBattery(id: 'bat1', voltage: 6.0)
            .addMotor(id: 'motor1')
            .connect('bat1', 'B', 'motor1', 'A')
            .connect('motor1', 'B', 'bat1', 'A')
            .simulate();
        if (result.hasClosedLoop && result.errorMessage == null) {
          feedbackMessage =
              'Polaridade invertida! Campo magnético reverso: giro anti-horário.';
          isSuccess = true;
        } else {
          feedbackMessage =
              result.errorMessage ?? 'Inverta a polaridade da fonte.';
        }
      } else {
        feedbackMessage =
            'Inverta a polaridade da fonte para alterar o sentido do campo magnético.';
      }

      final fullMessage = isSuccess
          ? 'Missão "${_mission.title}" concluída! ${_mission.victoryCriteria}.\n\nSua previsão: "$_m2Prediction"\n\nProf. Volts: "${_mission.voltsMediation}"'
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
              MovimentoPredictionBadge(prediction: _m2Prediction),
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
                      color: isReversed
                          ? const Color(0xFF0284C7)
                          : const Color(0xFFD97706),
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
                        top: centerY - 47.5,
                        child: PhysicalBlueprintSocket<String>(
                          expectedData: 'battery',
                          isFilled: _m2BatteryInserted,
                          rotation: _m2BatteryRotation,
                          width: 95,
                          height: 95,
                          showLabel: false,
                          onAccept: (_) => _insertComponent(
                            name: 'Bateria',
                            getInserted: () => _m2BatteryInserted,
                            setInserted: (v) => _m2BatteryInserted = v,
                            getRotation: () => _m2BatteryRotation,
                            setRotation: (v) => _m2BatteryRotation = v,
                          ),
                          onRotate: () => _rotateComponent(
                            name: 'Bateria',
                            getRotation: () => _m2BatteryRotation,
                            setRotation: (v) => _m2BatteryRotation = v,
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
                        top: centerY - 47.5,
                        child: PhysicalBlueprintSocket<String>(
                          expectedData: 'motor_cc',
                          isFilled: _m2MotorInserted,
                          rotation: _m2MotorRotation,
                          width: 95,
                          height: 95,
                          showLabel: false,
                          onAccept: (_) => _insertComponent(
                            name: 'Motor CC',
                            getInserted: () => _m2MotorInserted,
                            setInserted: (v) => _m2MotorInserted = v,
                            getRotation: () => _m2MotorRotation,
                            setRotation: (v) => _m2MotorRotation = v,
                          ),
                          onRotate: () => _rotateComponent(
                            name: 'Motor CC',
                            getRotation: () => _m2MotorRotation,
                            setRotation: (v) => _m2MotorRotation = v,
                          ),
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
              color: isReversed
                  ? const Color(0xFF0284C7)
                  : const Color(0xFFD97706),
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
                color: isReversed
                    ? const Color(0xFF0284C7)
                    : const Color(0xFFD97706),
                width: 2,
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            icon:
                const Icon(Icons.sync_alt_rounded, color: Color(0xFF0284C7)),
            label: Text(
              isReversed
                  ? 'Polaridade: Polo (-) → Polo (+)'
                  : 'Inverter Polaridade (+/- ➔ -/+)',
              style: GoogleFonts.rajdhani(
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            onPressed: () =>
                setState(() => _m2ReversedPolarity = !_m2ReversedPolarity),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSchematicCanvas() {
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
                      color: isReversed
                          ? const Color(0xFF0284C7)
                          : const Color(0xFFD97706),
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
                        top: centerY - 47.5,
                        child: SchematicBlueprintSocket<String>(
                          expectedData: 'battery',
                          isFilled: _m2BatteryInserted,
                          showLabel: false,
                          rotation: _m2BatteryRotation,
                          onAccept: (_) => _insertComponent(
                            name: 'Bateria',
                            getInserted: () => _m2BatteryInserted,
                            setInserted: (v) => _m2BatteryInserted = v,
                            getRotation: () => _m2BatteryRotation,
                            setRotation: (v) => _m2BatteryRotation = v,
                          ),
                          onRotate: () => _rotateComponent(
                            name: 'Bateria',
                            getRotation: () => _m2BatteryRotation,
                            setRotation: (v) => _m2BatteryRotation = v,
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
                        top: centerY - 47.5,
                        child: SchematicBlueprintSocket<String>(
                          expectedData: 'motor_cc',
                          isFilled: _m2MotorInserted,
                          showLabel: false,
                          rotation: _m2MotorRotation,
                          onAccept: (_) => _insertComponent(
                            name: 'Motor CC',
                            getInserted: () => _m2MotorInserted,
                            setInserted: (v) => _m2MotorInserted = v,
                            getRotation: () => _m2MotorRotation,
                            setRotation: (v) => _m2MotorRotation = v,
                          ),
                          onRotate: () => _rotateComponent(
                            name: 'Motor CC',
                            getRotation: () => _m2MotorRotation,
                            setRotation: (v) => _m2MotorRotation = v,
                          ),
                          onTap: () {},
                          symbolWidget: CustomPaint(
                            size: const Size(55, 55),
                            painter: CircuitSymbolPainter(
                              type: ComponentType.motor,
                              isActive: _m2MotorInserted,
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
          Text(
            isReversed
                ? 'Sentido: ANTI-HORÁRIO ↺ (Polaridade Invertida -/+)'
                : 'Sentido: HORÁRIO ↻ (Polaridade Padrão +/-)',
            style: GoogleFonts.rajdhani(
              color: isReversed
                  ? const Color(0xFF0284C7)
                  : const Color(0xFFD97706),
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
                color: isReversed
                    ? const Color(0xFF0284C7)
                    : const Color(0xFFD97706),
                width: 2,
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            icon:
                const Icon(Icons.sync_alt_rounded, color: Color(0xFF0284C7)),
            label: Text(
              isReversed
                  ? 'Polaridade: Polo (-) → Polo (+)'
                  : 'Inverter Polaridade (+/- ➔ -/+)',
              style: GoogleFonts.rajdhani(
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            onPressed: () =>
                setState(() => _m2ReversedPolarity = !_m2ReversedPolarity),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
