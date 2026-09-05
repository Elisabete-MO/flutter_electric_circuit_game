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
import '../../../widgets/realistic_wire_painter.dart';
import '../../../widgets/schematic_blueprint_socket.dart';
import '../../../widgets/success_confetti_overlay.dart';
import '../../../widgets/workbench_components.dart';
import '../../../widgets/workbench_table_frame.dart';
import '../widgets/mede_testa_explica_widgets.dart';

/// Missão 3 do Estande 07 — Lei de Ohm (Reostato e Amperímetro).
class MedeTestaExplicaM3 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const MedeTestaExplicaM3({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<MedeTestaExplicaM3> createState() => _MedeTestaExplicaM3State();
}

class _MedeTestaExplicaM3State extends State<MedeTestaExplicaM3> {
  final StandMission _mission = StandMission.medeTestaExplicaMissions[2];
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  bool _usePhysicalStyle = true;
  bool _isSimulating = false;

  bool _m3BatteryInserted = true;
  double _m3BatteryRotation = 0.0;
  bool _m3ResistorInserted = true;
  double _m3ResistorRotation = 0.0;
  bool _m3LedInserted = true;
  double _m3LedRotation = 0.0;
  double _m3ResistanceValue = 300.0;
  bool _m3AmperimeterInserted = false;
  double _m3AmperimeterRotation = 0.0;

  bool get _isClosed =>
      _m3BatteryInserted && _m3ResistorInserted && _m3LedInserted;

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

  void _reset() {
    setState(() {
      _m3BatteryInserted = true;
      _m3ResistorInserted = true;
      _m3LedInserted = true;
      _m3ResistanceValue = 300.0;
      _m3AmperimeterInserted = false;
    });
  }

  Future<void> _validateMission() async {
    if (_isSimulating) return;
    setState(() => _isSimulating = true);

    try {
      bool isSuccess = false;
      String feedback = _mission.failureFeedback;

      if (_m3AmperimeterInserted) {
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
          feedback =
              'Lei de Ohm: I = ${currentMa.toStringAsFixed(1)}mA com R = ${_m3ResistanceValue.round()} Ω. '
              'Maior resistência = menor corrente.';
          isSuccess = true;
        } else {
          feedback = result.errorMessage ??
              'Ajuste o reostato para variar a corrente.';
        }
      } else {
        feedback = 'Arraste o Amperímetro da gaveta para medir a corrente.';
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
            const Icon(Icons.verified_rounded,
                color: Color(0xFF10B981), size: 32),
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
        content: Text(
          'Perfeito! Você validou experimentalmente a Lei de Ohm (I = V / R). Ao aumentar a resistência do reostato, a corrente que circula diminui proporcionalmente.',
          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              showSuccessConfetti(context);
              widget.onMissionComplete();
            },
            child: Text(
              'AVANÇAR',
              style: GoogleFonts.rajdhani(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFailureDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        title: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.redAccent, size: 28),
            const SizedBox(width: 10),
            Text(
              'Atenção na Medição',
              style: GoogleFonts.rajdhani(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'REVISAR',
              style: GoogleFonts.rajdhani(
                color: const Color(0xFF00E5FF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentMa = (9.0 / _m3ResistanceValue) * 1000.0;
    final voltage = _isClosed ? 9.0 : 0.0;

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
                  leftHeaderWidget: MedeTestaStatusCard(isClosed: _isClosed),
                  rightHeaderWidget: MedeTestaTelemetryCard(
                    voltage: voltage,
                    currentMa: _m3AmperimeterInserted ? currentMa : 0.0,
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
            teamTitle: 'Painel da Investigação',
            toolboxItems: [
              MedeTestaUndoRedoButtons(
                controller: _undoRedoController,
                onUndo: () => setState(() => _undoRedoController.undo()),
                onRedo: () => setState(() => _undoRedoController.redo()),
              ),
              MedeTestaSideToolbox(
                usePhysicalStyle: _usePhysicalStyle,
                onReset: _reset,
              ),
            ],
            onEnergizePressed: _validateMission,
            isLoading: _isSimulating,
          ),
        ),
      ],
    );
  }

  Widget _buildPhysicalCanvas() {
    final currentMa = (9.0 / _m3ResistanceValue) * 1000.0;
    final allInserted =
        _m3BatteryInserted && _m3ResistorInserted && _m3LedInserted;
    final ledActive = allInserted && _m3ResistanceValue < 900.0;
    final showReading = allInserted && _m3AmperimeterInserted;
    final ammeterReading = showReading ? currentMa : 0.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Lei de Ohm: I = V / R (${currentMa.toStringAsFixed(1)} mA)',
          style: GoogleFonts.rajdhani(
            color: const Color(0xFF10B981),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;
                final batteryX = w * 0.2;
                final batteryY = h * 0.72;
                final resistorX = w * 0.5;
                final resistorY = h * 0.25;
                final ledX = w * 0.8;
                final ledY = h * 0.25;
                final ammeterX = w * 0.2;
                final ammeterY = h * 0.12;
                final sock = 95.0;
                final comp = 55.0;

                final batteryPlacement = ComponentPlacement(
                  position: Offset(batteryX, batteryY),
                  rotation: _m3BatteryRotation,
                  type: ComponentType.battery,
                );
                final resistorPlacement = ComponentPlacement(
                  position: Offset(resistorX, resistorY),
                  rotation: _m3ResistorRotation,
                  type: ComponentType.resistor,
                );
                final ledPlacement = ComponentPlacement(
                  position: Offset(ledX, ledY),
                  rotation: _m3LedRotation,
                  type: ComponentType.led,
                );

                final wires = <WirePath>[];
                if (_m3BatteryInserted && _m3ResistorInserted) {
                  wires.add(DynamicWirePath.fromComponents(
                    compA: batteryPlacement,
                    terminalIndexA: 1,
                    compB: resistorPlacement,
                    terminalIndexB: 0,
                    color: const Color(0xFFEF4444),
                    isActive: true,
                  ).toWirePath());
                }
                if (_m3ResistorInserted && _m3LedInserted) {
                  wires.add(DynamicWirePath.fromComponents(
                    compA: resistorPlacement,
                    terminalIndexA: 1,
                    compB: ledPlacement,
                    terminalIndexB: 0,
                    color: const Color(0xFFF97316),
                    isActive: true,
                  ).toWirePath());
                }
                if (_m3LedInserted && _m3BatteryInserted) {
                  wires.add(DynamicWirePath.fromComponents(
                    compA: ledPlacement,
                    terminalIndexA: 1,
                    compB: batteryPlacement,
                    terminalIndexB: 0,
                    color: const Color(0xFF1E293B),
                    isActive: true,
                  ).toWirePath());
                }

                return Stack(
                  children: [
                    if (wires.isNotEmpty)
                      Positioned.fill(
                        child: RealisticWireWidget(
                          wires: wires,
                          animationValue: 0,
                          showElectrons: false,
                        ),
                      ),
                    Positioned(
                      left: batteryX - sock / 2,
                      top: batteryY - sock / 2,
                      child: PhysicalBlueprintSocket<String>(
                        expectedData: 'battery',
                        isFilled: _m3BatteryInserted,
                        rotation: _m3BatteryRotation,
                        width: sock,
                        height: sock,
                        showLabel: true,
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
                          size: Size(comp, comp),
                          painter: ComponentPhysicalPainter(
                            type: ComponentType.battery,
                            isDarkMode: false,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: resistorX - sock / 2,
                      top: resistorY - sock / 2,
                      child: PhysicalBlueprintSocket<String>(
                        expectedData: 'resistor',
                        isFilled: _m3ResistorInserted,
                        rotation: _m3ResistorRotation,
                        width: sock,
                        height: sock,
                        showLabel: true,
                        onAccept: (_) => _insertComponent(
                          name: 'Resistor',
                          getInserted: () => _m3ResistorInserted,
                          setInserted: (v) => _m3ResistorInserted = v,
                          getRotation: () => _m3ResistorRotation,
                          setRotation: (v) => _m3ResistorRotation = v,
                        ),
                        onRotate: () => _rotateComponent(
                          name: 'Resistor',
                          getRotation: () => _m3ResistorRotation,
                          setRotation: (v) => _m3ResistorRotation = v,
                        ),
                        onTap: () {},
                        symbolWidget: CustomPaint(
                          size: Size(comp, comp),
                          painter: ComponentPhysicalPainter(
                            type: ComponentType.resistor,
                            isDarkMode: false,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: ledX - sock / 2,
                      top: ledY - sock / 2,
                      child: PhysicalBlueprintSocket<String>(
                        expectedData: 'led',
                        isFilled: _m3LedInserted,
                        rotation: _m3LedRotation,
                        width: sock,
                        height: sock,
                        showLabel: true,
                        onAccept: (_) => _insertComponent(
                          name: 'LED',
                          getInserted: () => _m3LedInserted,
                          setInserted: (v) => _m3LedInserted = v,
                          getRotation: () => _m3LedRotation,
                          setRotation: (v) => _m3LedRotation = v,
                        ),
                        onRotate: () => _rotateComponent(
                          name: 'LED',
                          getRotation: () => _m3LedRotation,
                          setRotation: (v) => _m3LedRotation = v,
                        ),
                        onTap: () {},
                        symbolWidget: CustomPaint(
                          size: Size(comp, comp),
                          painter: ComponentPhysicalPainter(
                            type: ComponentType.led,
                            isActive: ledActive,
                            isDarkMode: false,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: ammeterX - sock / 2,
                      top: ammeterY - sock / 2,
                      child: PhysicalBlueprintSocket<String>(
                        expectedData: 'multimeter_a',
                        isFilled: _m3AmperimeterInserted,
                        rotation: _m3AmperimeterRotation,
                        width: sock,
                        height: sock,
                        showLabel: true,
                        onAccept: (_) => _insertComponent(
                          name: 'Amperímetro',
                          getInserted: () => _m3AmperimeterInserted,
                          setInserted: (v) => _m3AmperimeterInserted = v,
                          getRotation: () => _m3AmperimeterRotation,
                          setRotation: (v) => _m3AmperimeterRotation = v,
                        ),
                        onRotate: () => _rotateComponent(
                          name: 'Amperímetro',
                          getRotation: () => _m3AmperimeterRotation,
                          setRotation: (v) => _m3AmperimeterRotation = v,
                        ),
                        onTap: () {},
                        symbolWidget: MeterVectorWidget(
                          size: comp,
                          meterType: 'A',
                          accentColor: const Color(0xFFD97706),
                        ),
                      ),
                    ),
                    if (_m3AmperimeterInserted)
                      Positioned(
                        left: ammeterX - 40,
                        top: ammeterY + sock / 2 + 4,
                        child: MedeTestaMeterReading(
                          value: ammeterReading.toStringAsFixed(1),
                          unit: 'mA',
                          color: const Color(0xFFD97706),
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
          'Ajuste o Reostato:',
          style: GoogleFonts.rajdhani(
            color: const Color(0xFF0F172A),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Slider(
          value: _m3ResistanceValue,
          min: 100.0,
          max: 1000.0,
          divisions: 18,
          activeColor: const Color(0xFF10B981),
          label: '${_m3ResistanceValue.round()} Ω',
          onChanged: (val) => setState(() => _m3ResistanceValue = val),
        ),
      ],
    );
  }

  Widget _buildSchematicCanvas() {
    final currentMa = (9.0 / _m3ResistanceValue) * 1000.0;
    final allInserted =
        _m3BatteryInserted && _m3ResistorInserted && _m3LedInserted;
    final ledActive = allInserted && _m3ResistanceValue < 900.0;
    final showReading = allInserted && _m3AmperimeterInserted;
    final ammeterReading = showReading ? currentMa : 0.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Lei de Ohm: I = V / R (${currentMa.toStringAsFixed(1)} mA)',
          style: GoogleFonts.rajdhani(
            color: const Color(0xFF10B981),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;
                final batteryX = w * 0.2;
                final batteryY = h * 0.72;
                final resistorX = w * 0.5;
                final resistorY = h * 0.25;
                final ledX = w * 0.8;
                final ledY = h * 0.25;
                final ammeterX = w * 0.2;
                final ammeterY = h * 0.12;

                final batteryPlacement = ComponentPlacement(
                  position: Offset(batteryX, batteryY),
                  rotation: _m3BatteryRotation,
                  type: ComponentType.battery,
                );
                final resistorPlacement = ComponentPlacement(
                  position: Offset(resistorX, resistorY),
                  rotation: _m3ResistorRotation,
                  type: ComponentType.resistor,
                );
                final ledPlacement = ComponentPlacement(
                  position: Offset(ledX, ledY),
                  rotation: _m3LedRotation,
                  type: ComponentType.led,
                );

                final wires = <WirePath>[];
                if (_m3BatteryInserted && _m3ResistorInserted) {
                  wires.add(DynamicWirePath.fromComponents(
                    compA: batteryPlacement,
                    terminalIndexA: 1,
                    compB: resistorPlacement,
                    terminalIndexB: 0,
                    color: const Color(0xFFEF4444),
                    isActive: true,
                  ).toWirePath());
                }
                if (_m3ResistorInserted && _m3LedInserted) {
                  wires.add(DynamicWirePath.fromComponents(
                    compA: resistorPlacement,
                    terminalIndexA: 1,
                    compB: ledPlacement,
                    terminalIndexB: 0,
                    color: const Color(0xFFF97316),
                    isActive: true,
                  ).toWirePath());
                }
                if (_m3LedInserted && _m3BatteryInserted) {
                  wires.add(DynamicWirePath.fromComponents(
                    compA: ledPlacement,
                    terminalIndexA: 1,
                    compB: batteryPlacement,
                    terminalIndexB: 0,
                    color: const Color(0xFF1E293B),
                    isActive: true,
                  ).toWirePath());
                }

                return Stack(
                  children: [
                    if (wires.isNotEmpty)
                      Positioned.fill(
                        child: RealisticWireWidget(
                          wires: wires,
                          animationValue: 0,
                          showElectrons: false,
                        ),
                      ),
                    Positioned(
                      left: batteryX - 47.5,
                      top: batteryY - 47.5,
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
                      left: resistorX - 47.5,
                      top: resistorY - 47.5,
                      child: SchematicBlueprintSocket<String>(
                        expectedData: 'resistor',
                        isFilled: _m3ResistorInserted,
                        showLabel: false,
                        rotation: _m3ResistorRotation,
                        onAccept: (_) => _insertComponent(
                          name: 'Resistor',
                          getInserted: () => _m3ResistorInserted,
                          setInserted: (v) => _m3ResistorInserted = v,
                          getRotation: () => _m3ResistorRotation,
                          setRotation: (v) => _m3ResistorRotation = v,
                        ),
                        onRotate: () => _rotateComponent(
                          name: 'Resistor',
                          getRotation: () => _m3ResistorRotation,
                          setRotation: (v) => _m3ResistorRotation = v,
                        ),
                        onTap: () {},
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
                      top: ledY - 47.5,
                      child: SchematicBlueprintSocket<String>(
                        expectedData: 'led',
                        isFilled: _m3LedInserted,
                        showLabel: false,
                        rotation: _m3LedRotation,
                        onAccept: (_) => _insertComponent(
                          name: 'LED',
                          getInserted: () => _m3LedInserted,
                          setInserted: (v) => _m3LedInserted = v,
                          getRotation: () => _m3LedRotation,
                          setRotation: (v) => _m3LedRotation = v,
                        ),
                        onRotate: () => _rotateComponent(
                          name: 'LED',
                          getRotation: () => _m3LedRotation,
                          setRotation: (v) => _m3LedRotation = v,
                        ),
                        onTap: () {},
                        symbolWidget: CustomPaint(
                          size: const Size(55, 55),
                          painter: CircuitSymbolPainter(
                            type: ComponentType.led,
                            isActive: ledActive,
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
                    Positioned(
                      left: ammeterX - 47.5,
                      top: ammeterY - 47.5,
                      child: SchematicBlueprintSocket<String>(
                        expectedData: 'multimeter_a',
                        isFilled: _m3AmperimeterInserted,
                        showLabel: false,
                        rotation: _m3AmperimeterRotation,
                        onAccept: (_) => _insertComponent(
                          name: 'Amperímetro',
                          getInserted: () => _m3AmperimeterInserted,
                          setInserted: (v) => _m3AmperimeterInserted = v,
                          getRotation: () => _m3AmperimeterRotation,
                          setRotation: (v) => _m3AmperimeterRotation = v,
                        ),
                        onRotate: () => _rotateComponent(
                          name: 'Amperímetro',
                          getRotation: () => _m3AmperimeterRotation,
                          setRotation: (v) => _m3AmperimeterRotation = v,
                        ),
                        onTap: () {},
                        symbolWidget: MeterVectorWidget(
                          size: 55,
                          meterType: 'A',
                          accentColor: const Color(0xFFD97706),
                        ),
                        placeholderWidget: MeterVectorWidget(
                          size: 48,
                          meterType: 'A',
                          accentColor: const Color(0xFF94A3B8),
                        ),
                        label: '',
                      ),
                    ),
                    if (_m3AmperimeterInserted)
                      Positioned(
                        left: ammeterX - 40,
                        top: ammeterY + 50,
                        child: MedeTestaMeterReading(
                          value: ammeterReading.toStringAsFixed(1),
                          unit: 'mA',
                          color: const Color(0xFFD97706),
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
          'Ajuste o Reostato:',
          style: GoogleFonts.rajdhani(
            color: const Color(0xFF0F172A),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Slider(
          value: _m3ResistanceValue,
          min: 100.0,
          max: 1000.0,
          divisions: 18,
          activeColor: const Color(0xFF10B981),
          label: '${_m3ResistanceValue.round()} Ω',
          onChanged: (val) => setState(() => _m3ResistanceValue = val),
        ),
      ],
    );
  }
}
