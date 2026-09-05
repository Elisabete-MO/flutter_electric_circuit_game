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

/// Missão 5 do Estande 06 — Diagnóstico do Mini Carrinho.
class MovimentoMiniaturaM5 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const MovimentoMiniaturaM5({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<MovimentoMiniaturaM5> createState() => _MovimentoMiniaturaM5State();
}

class _MovimentoMiniaturaM5State extends State<MovimentoMiniaturaM5>
    with SingleTickerProviderStateMixin {
  final StandMission _mission = StandMission.movimentoMiniaturaMissions[4];
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  late final AnimationController _currentFlowController;

  bool _usePhysicalStyle = true;
  bool _isSimulating = false;

  bool _m5WireRepaired = false;
  bool _m5CarTested = false;
  bool _m5BatteryInserted = false;
  double _m5BatteryRotation = 0.0;
  bool _m5MotorInserted = false;
  double _m5MotorRotation = 0.0;
  String? _m5Prediction;

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

  bool get _isWorking =>
      _m5WireRepaired &&
      _m5CarTested &&
      _m5BatteryInserted &&
      _m5MotorInserted;

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
    if (_m5Prediction == null) {
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
        question: 'O motor não gira. Qual a causa mais provável?',
        options: const [
          'Circuito aberto',
          'Curto-circuito',
          'Resistor queimado',
          'Não sei'
        ],
        onPredict: (prediction) {
          Navigator.of(context).pop();
          setState(() => _m5Prediction = prediction);
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
            'Qual evidência mostrou onde estava a falha no circuito do motor?',
        options: const [
          'Medição de continuidade / inspeção visual',
          'Teste de tensão nos terminais',
          'Substituição de componente',
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

      if (_m5WireRepaired && _m5CarTested) {
        final result = await MissionCircuitBuilder()
            .addBattery(id: 'bat1', voltage: 6.0)
            .addMotor(id: 'motor1')
            .connect('bat1', 'B', 'motor1', 'A')
            .connect('motor1', 'B', 'bat1', 'A')
            .simulate();
        if (result.hasClosedLoop && result.errorMessage == null) {
          feedbackMessage =
              'Mau contato reparado! Carrinho funcional com corrente circulando.';
          isSuccess = true;
        } else {
          feedbackMessage =
              result.errorMessage ?? 'Ainda há problema na fiação.';
        }
      } else if (!_m5WireRepaired) {
        feedbackMessage =
            'Inspecione os terminais do motor para encontrar e reparar a fiação solta.';
      } else {
        feedbackMessage =
            'Teste o acionamento do mini carrinho após o reparo!';
      }

      final fullMessage = isSuccess
          ? 'Missão "${_mission.title}" concluída! ${_mission.victoryCriteria}.\n\nSua previsão: "$_m5Prediction"\n\nProf. Volts: "${_mission.voltsMediation}"'
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
    final double currentMa = _isWorking ? 120.0 : 0.0;

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
                  leftHeaderWidget: MovimentoStatusCard(isClosed: _isWorking),
                  rightHeaderWidget: MovimentoTelemetryCard(
                    voltage: voltage,
                    currentMa: currentMa,
                    isClosed: _isWorking,
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
              MovimentoPredictionBadge(prediction: _m5Prediction),
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
                    wires.add(DynamicWirePath.fromComponents(
                      compA: batteryPlacement,
                      terminalIndexA: 1,
                      compB: motorPlacement,
                      terminalIndexB: 0,
                      color: _m5WireRepaired
                          ? const Color(0xFF10B981)
                          : const Color(0xFFD97706),
                      isActive: _m5WireRepaired,
                    ).toWirePath());
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
                      if (wires.isNotEmpty)
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _currentFlowController,
                            builder: (context, _) => RealisticWireWidget(
                              wires: wires,
                              animationValue: _isWorking
                                  ? _currentFlowController.value
                                  : 0,
                              showElectrons: _isWorking,
                            ),
                          ),
                        ),
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
                          onAccept: (_) => _insertComponent(
                            name: 'Bateria',
                            getInserted: () => _m5BatteryInserted,
                            setInserted: (v) => _m5BatteryInserted = v,
                            getRotation: () => _m5BatteryRotation,
                            setRotation: (v) => _m5BatteryRotation = v,
                          ),
                          onRotate: () => _rotateComponent(
                            name: 'Bateria',
                            getRotation: () => _m5BatteryRotation,
                            setRotation: (v) => _m5BatteryRotation = v,
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
                          isFilled: _m5MotorInserted,
                          rotation: _m5MotorRotation,
                          width: 95,
                          height: 95,
                          showLabel: false,
                          onAccept: (_) => _insertComponent(
                            name: 'Motor CC',
                            getInserted: () => _m5MotorInserted,
                            setInserted: (v) => _m5MotorInserted = v,
                            getRotation: () => _m5MotorRotation,
                            setRotation: (v) => _m5MotorRotation = v,
                          ),
                          onRotate: () => _rotateComponent(
                            name: 'Motor CC',
                            getRotation: () => _m5MotorRotation,
                            setRotation: (v) => _m5MotorRotation = v,
                          ),
                          onTap: () {},
                          symbolWidget: CustomPaint(
                            size: const Size(55, 55),
                            painter: ComponentPhysicalPainter(
                              type: ComponentType.motor,
                              isActive: _isWorking,
                              isDarkMode: false,
                            ),
                          ),
                        ),
                      ),
                      if (_m5BatteryInserted &&
                          _m5MotorInserted &&
                          !_m5WireRepaired)
                        Positioned(
                          left: (batteryX + motorX) / 2 - 20,
                          top: centerY - 40,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD97706)
                                  .withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.warning_amber_rounded,
                                color: Colors.white, size: 24),
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
              border: Border.all(
                color: _m5WireRepaired
                    ? const Color(0xFF0284C7)
                    : const Color(0xFFD97706),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _m5WireRepaired
                      ? Icons.build_circle_rounded
                      : Icons.warning_amber_rounded,
                  color: _m5WireRepaired
                      ? const Color(0xFF0284C7)
                      : const Color(0xFFD97706),
                ),
                const SizedBox(width: 10),
                Text(
                  _m5WireRepaired
                      ? 'Fiação Reparada: Mau contato corrigido!'
                      : 'Diagnóstico: Fio solto no terminal positivo',
                  style: GoogleFonts.rajdhani(
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
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
                  side: BorderSide(
                    color: _m5WireRepaired
                        ? const Color(0xFF0284C7)
                        : const Color(0xFFD97706),
                  ),
                ),
                icon: const Icon(Icons.handyman_rounded,
                    color: Color(0xFFD97706)),
                label: Text(
                  _m5WireRepaired ? 'Reparado (Soldado)' : 'Reparar Mau Contato',
                  style: GoogleFonts.rajdhani(
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () =>
                    setState(() => _m5WireRepaired = !_m5WireRepaired),
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
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
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
                    wires.add(DynamicWirePath.fromComponents(
                      compA: batteryPlacement,
                      terminalIndexA: 1,
                      compB: motorPlacement,
                      terminalIndexB: 0,
                      color: _m5WireRepaired
                          ? const Color(0xFF10B981)
                          : const Color(0xFFD97706),
                      isActive: _m5WireRepaired,
                    ).toWirePath());
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
                      if (wires.isNotEmpty)
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _currentFlowController,
                            builder: (context, _) => RealisticWireWidget(
                              wires: wires,
                              animationValue: _isWorking
                                  ? _currentFlowController.value
                                  : 0,
                              showElectrons: _isWorking,
                            ),
                          ),
                        ),
                      Positioned(
                        left: batteryX - 47.5,
                        top: centerY - 47.5,
                        child: SchematicBlueprintSocket<String>(
                          expectedData: 'battery',
                          isFilled: _m5BatteryInserted,
                          showLabel: false,
                          rotation: _m5BatteryRotation,
                          onAccept: (_) => _insertComponent(
                            name: 'Bateria',
                            getInserted: () => _m5BatteryInserted,
                            setInserted: (v) => _m5BatteryInserted = v,
                            getRotation: () => _m5BatteryRotation,
                            setRotation: (v) => _m5BatteryRotation = v,
                          ),
                          onRotate: () => _rotateComponent(
                            name: 'Bateria',
                            getRotation: () => _m5BatteryRotation,
                            setRotation: (v) => _m5BatteryRotation = v,
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
                          isFilled: _m5MotorInserted,
                          showLabel: false,
                          rotation: _m5MotorRotation,
                          onAccept: (_) => _insertComponent(
                            name: 'Motor CC',
                            getInserted: () => _m5MotorInserted,
                            setInserted: (v) => _m5MotorInserted = v,
                            getRotation: () => _m5MotorRotation,
                            setRotation: (v) => _m5MotorRotation = v,
                          ),
                          onRotate: () => _rotateComponent(
                            name: 'Motor CC',
                            getRotation: () => _m5MotorRotation,
                            setRotation: (v) => _m5MotorRotation = v,
                          ),
                          onTap: () {},
                          symbolWidget: CustomPaint(
                            size: const Size(55, 55),
                            painter: CircuitSymbolPainter(
                              type: ComponentType.motor,
                              isActive: _isWorking,
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
                      if (_m5BatteryInserted &&
                          _m5MotorInserted &&
                          !_m5WireRepaired)
                        Positioned(
                          left: (batteryX + motorX) / 2 - 20,
                          top: centerY - 40,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD97706)
                                  .withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.warning_amber_rounded,
                                color: Colors.white, size: 24),
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
              border: Border.all(
                color: _m5WireRepaired
                    ? const Color(0xFF0284C7)
                    : const Color(0xFFD97706),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _m5WireRepaired
                      ? Icons.build_circle_rounded
                      : Icons.warning_amber_rounded,
                  color: _m5WireRepaired
                      ? const Color(0xFF0284C7)
                      : const Color(0xFFD97706),
                ),
                const SizedBox(width: 10),
                Text(
                  _m5WireRepaired
                      ? 'Fiação Reparada: Mau contato corrigido!'
                      : 'Diagnóstico: Fio solto no terminal positivo',
                  style: GoogleFonts.rajdhani(
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
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
                  side: BorderSide(
                    color: _m5WireRepaired
                        ? const Color(0xFF0284C7)
                        : const Color(0xFFD97706),
                  ),
                ),
                icon: const Icon(Icons.handyman_rounded,
                    color: Color(0xFFD97706)),
                label: Text(
                  _m5WireRepaired ? 'Reparado (Soldado)' : 'Reparar Mau Contato',
                  style: GoogleFonts.rajdhani(
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () =>
                    setState(() => _m5WireRepaired = !_m5WireRepaired),
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
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
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
}
