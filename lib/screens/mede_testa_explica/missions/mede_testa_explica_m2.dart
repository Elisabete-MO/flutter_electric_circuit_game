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

/// Missão 2 do Estande 07 — Queda de Tensão na Carga (Lâmpada).
class MedeTestaExplicaM2 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const MedeTestaExplicaM2({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<MedeTestaExplicaM2> createState() => _MedeTestaExplicaM2State();
}

class _MedeTestaExplicaM2State extends State<MedeTestaExplicaM2> {
  final StandMission _mission = StandMission.medeTestaExplicaMissions[1];
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  bool _usePhysicalStyle = true;
  bool _isSimulating = false;

  bool _redProbeConnected = true;
  bool _blackProbeConnected = true;

  bool _m2BatteryInserted = true;
  double _m2BatteryRotation = 0.0;
  bool _m2BulbInserted = true;
  double _m2BulbRotation = 0.0;
  bool _m2VoltmeterInserted = false;
  double _m2VoltmeterRotation = 0.0;

  bool get _isClosed =>
      _m2BatteryInserted &&
      _m2BulbInserted &&
      _redProbeConnected &&
      _blackProbeConnected;

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
      _redProbeConnected = true;
      _blackProbeConnected = true;
      _m2BatteryInserted = true;
      _m2BulbInserted = true;
      _m2VoltmeterInserted = false;
    });
  }

  Future<void> _validateMission() async {
    if (_isSimulating) return;
    setState(() => _isSimulating = true);

    try {
      bool isSuccess = false;
      String feedback = _mission.failureFeedback;

      if (_redProbeConnected && _blackProbeConnected && _m2VoltmeterInserted) {
        final result = await MissionCircuitBuilder()
            .addBattery(id: 'bat1', voltage: 9.0)
            .addBulb(id: 'bulb1', resistance: 5.0)
            .connect('bat1', 'B', 'bulb1', 'A')
            .connect('bulb1', 'B', 'bat1', 'A')
            .simulate();
        if (result.hasClosedLoop) {
          final vDrop = result.componentVoltages['bulb1'] ?? 0;
          feedback =
              'Queda de tensão na lâmpada: ${vDrop.toStringAsFixed(2)}V. '
              'A carga consome tensão do circuito.';
          isSuccess = true;
        } else {
          feedback = 'Circuito aberto. Verifique as conexões.';
        }
      } else if (!_m2VoltmeterInserted) {
        feedback = 'Arraste o Voltímetro da gaveta para o circuito.';
      } else {
        feedback = 'Conecte as pontas de prova nos dois lados da lâmpada.';
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
          'Fantástico! Você comprovou que a lâmpada consome a tensão fornecida pela fonte (queda de tensão na carga).',
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
    final showReading = _m2BatteryInserted &&
        _m2BulbInserted &&
        _m2VoltmeterInserted &&
        _redProbeConnected &&
        _blackProbeConnected;
    final voltage = showReading ? 9.0 : 0.0;
    final currentMa = _m2BatteryInserted && _m2BulbInserted ? 1800.0 : 0.0;

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
    final showReading = _m2BatteryInserted &&
        _m2BulbInserted &&
        _m2VoltmeterInserted &&
        _redProbeConnected &&
        _blackProbeConnected;
    final voltageReading = showReading ? 9.0 : 0.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Circuito Energizado com Lâmpada em Carga',
          style: GoogleFonts.rajdhani(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;
                final batteryX = w * 0.2;
                final bulbX = w * 0.75;
                final centerY = h * 0.5;
                final voltmeterX = (batteryX + bulbX) / 2;
                final voltmeterY = h * 0.12;
                final sock = 95.0;
                final comp = 55.0;

                final batteryPlacement = ComponentPlacement(
                  position: Offset(batteryX, centerY),
                  rotation: _m2BatteryRotation,
                  type: ComponentType.battery,
                );
                final bulbPlacement = ComponentPlacement(
                  position: Offset(bulbX, centerY),
                  rotation: _m2BulbRotation,
                  type: ComponentType.bulb,
                );

                final wires = <WirePath>[];
                if (_m2BatteryInserted && _m2BulbInserted) {
                  wires.add(DynamicWirePath.fromComponents(
                    compA: batteryPlacement,
                    terminalIndexA: 1,
                    compB: bulbPlacement,
                    terminalIndexB: 0,
                    color: const Color(0xFFEF4444),
                    isActive: true,
                  ).toWirePath());
                  wires.add(DynamicWirePath.fromComponents(
                    compA: bulbPlacement,
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
                      top: centerY - sock / 2,
                      child: PhysicalBlueprintSocket<String>(
                        expectedData: 'battery',
                        isFilled: _m2BatteryInserted,
                        rotation: _m2BatteryRotation,
                        width: sock,
                        height: sock,
                        showLabel: true,
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
                          size: Size(comp, comp),
                          painter: ComponentPhysicalPainter(
                            type: ComponentType.battery,
                            isDarkMode: false,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: bulbX - sock / 2,
                      top: centerY - sock / 2,
                      child: PhysicalBlueprintSocket<String>(
                        expectedData: 'bulb',
                        isFilled: _m2BulbInserted,
                        rotation: _m2BulbRotation,
                        width: sock,
                        height: sock,
                        showLabel: true,
                        onAccept: (_) => _insertComponent(
                          name: 'Lâmpada',
                          getInserted: () => _m2BulbInserted,
                          setInserted: (v) => _m2BulbInserted = v,
                          getRotation: () => _m2BulbRotation,
                          setRotation: (v) => _m2BulbRotation = v,
                        ),
                        onRotate: () => _rotateComponent(
                          name: 'Lâmpada',
                          getRotation: () => _m2BulbRotation,
                          setRotation: (v) => _m2BulbRotation = v,
                        ),
                        onTap: () {},
                        symbolWidget: CustomPaint(
                          size: Size(comp, comp),
                          painter: ComponentPhysicalPainter(
                            type: ComponentType.bulb,
                            isActive: _m2BatteryInserted && _m2BulbInserted,
                            isDarkMode: false,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: voltmeterX - sock / 2,
                      top: voltmeterY - sock / 2,
                      child: PhysicalBlueprintSocket<String>(
                        expectedData: 'multimeter_v',
                        isFilled: _m2VoltmeterInserted,
                        rotation: _m2VoltmeterRotation,
                        width: sock,
                        height: sock,
                        showLabel: true,
                        onAccept: (_) => _insertComponent(
                          name: 'Voltímetro',
                          getInserted: () => _m2VoltmeterInserted,
                          setInserted: (v) => _m2VoltmeterInserted = v,
                          getRotation: () => _m2VoltmeterRotation,
                          setRotation: (v) => _m2VoltmeterRotation = v,
                        ),
                        onRotate: () => _rotateComponent(
                          name: 'Voltímetro',
                          getRotation: () => _m2VoltmeterRotation,
                          setRotation: (v) => _m2VoltmeterRotation = v,
                        ),
                        onTap: () {},
                        symbolWidget: MeterVectorWidget(
                          size: comp,
                          meterType: 'V',
                          accentColor: const Color(0xFF0284C7),
                        ),
                      ),
                    ),
                    if (_m2VoltmeterInserted)
                      Positioned(
                        left: voltmeterX - 40,
                        top: voltmeterY + sock / 2 + 4,
                        child: MedeTestaMeterReading(
                          value: voltageReading.toStringAsFixed(1),
                          unit: 'V DC',
                          color: const Color(0xFF0284C7),
                        ),
                      ),
                    if (_m2BatteryInserted && _m2BulbInserted)
                      Positioned(
                        left: (batteryX + bulbX) / 2 - 10,
                        top: centerY - 50,
                        child: MedeTestaProbeSlot(
                          isRed: true,
                          isConnected: _redProbeConnected,
                          onTap: () => setState(
                              () => _redProbeConnected = !_redProbeConnected),
                          label: 'A',
                        ),
                      ),
                    if (_m2BatteryInserted && _m2BulbInserted)
                      Positioned(
                        left: (batteryX + bulbX) / 2 - 10,
                        top: centerY + 30,
                        child: MedeTestaProbeSlot(
                          isRed: false,
                          isConnected: _blackProbeConnected,
                          onTap: () => setState(() =>
                              _blackProbeConnected = !_blackProbeConnected),
                          label: 'B',
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSchematicCanvas() {
    final showReading = _m2BatteryInserted &&
        _m2BulbInserted &&
        _m2VoltmeterInserted &&
        _redProbeConnected &&
        _blackProbeConnected;
    final voltageReading = showReading ? 9.0 : 0.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Circuito Energizado com Lâmpada em Carga',
          style: GoogleFonts.rajdhani(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;
                final batteryX = w * 0.2;
                final bulbX = w * 0.75;
                final centerY = h * 0.5;
                final voltmeterX = (batteryX + bulbX) / 2;
                final voltmeterY = h * 0.12;

                final batteryPlacement = ComponentPlacement(
                  position: Offset(batteryX, centerY),
                  rotation: _m2BatteryRotation,
                  type: ComponentType.battery,
                );
                final bulbPlacement = ComponentPlacement(
                  position: Offset(bulbX, centerY),
                  rotation: _m2BulbRotation,
                  type: ComponentType.bulb,
                );

                final wires = <WirePath>[];
                if (_m2BatteryInserted && _m2BulbInserted) {
                  wires.add(DynamicWirePath.fromComponents(
                    compA: batteryPlacement,
                    terminalIndexA: 1,
                    compB: bulbPlacement,
                    terminalIndexB: 0,
                    color: const Color(0xFFEF4444),
                    isActive: true,
                  ).toWirePath());
                  wires.add(DynamicWirePath.fromComponents(
                    compA: bulbPlacement,
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
                      left: bulbX - 47.5,
                      top: centerY - 47.5,
                      child: SchematicBlueprintSocket<String>(
                        expectedData: 'bulb',
                        isFilled: _m2BulbInserted,
                        showLabel: false,
                        rotation: _m2BulbRotation,
                        onAccept: (_) => _insertComponent(
                          name: 'Lâmpada',
                          getInserted: () => _m2BulbInserted,
                          setInserted: (v) => _m2BulbInserted = v,
                          getRotation: () => _m2BulbRotation,
                          setRotation: (v) => _m2BulbRotation = v,
                        ),
                        onRotate: () => _rotateComponent(
                          name: 'Lâmpada',
                          getRotation: () => _m2BulbRotation,
                          setRotation: (v) => _m2BulbRotation = v,
                        ),
                        onTap: () {},
                        symbolWidget: CustomPaint(
                          size: const Size(55, 55),
                          painter: CircuitSymbolPainter(
                            type: ComponentType.bulb,
                            isActive: _m2BatteryInserted && _m2BulbInserted,
                            color: const Color(0xFF0F172A),
                            strokeWidth: 2.5,
                          ),
                        ),
                        placeholderWidget: CustomPaint(
                          size: const Size(48, 38),
                          painter: CircuitSymbolPainter(
                            type: ComponentType.bulb,
                            isActive: false,
                            color: const Color(0xFF94A3B8),
                            strokeWidth: 2.0,
                          ),
                        ),
                        label: '',
                      ),
                    ),
                    Positioned(
                      left: voltmeterX - 47.5,
                      top: voltmeterY - 47.5,
                      child: SchematicBlueprintSocket<String>(
                        expectedData: 'multimeter_v',
                        isFilled: _m2VoltmeterInserted,
                        showLabel: false,
                        rotation: _m2VoltmeterRotation,
                        onAccept: (_) => _insertComponent(
                          name: 'Voltímetro',
                          getInserted: () => _m2VoltmeterInserted,
                          setInserted: (v) => _m2VoltmeterInserted = v,
                          getRotation: () => _m2VoltmeterRotation,
                          setRotation: (v) => _m2VoltmeterRotation = v,
                        ),
                        onRotate: () => _rotateComponent(
                          name: 'Voltímetro',
                          getRotation: () => _m2VoltmeterRotation,
                          setRotation: (v) => _m2VoltmeterRotation = v,
                        ),
                        onTap: () {},
                        symbolWidget: MeterVectorWidget(
                          size: 55,
                          meterType: 'V',
                          accentColor: const Color(0xFF0284C7),
                        ),
                        placeholderWidget: MeterVectorWidget(
                          size: 48,
                          meterType: 'V',
                          accentColor: const Color(0xFF94A3B8),
                        ),
                        label: '',
                      ),
                    ),
                    if (_m2VoltmeterInserted)
                      Positioned(
                        left: voltmeterX - 40,
                        top: voltmeterY + 50,
                        child: MedeTestaMeterReading(
                          value: voltageReading.toStringAsFixed(1),
                          unit: 'V DC',
                          color: const Color(0xFF0284C7),
                        ),
                      ),
                    if (_m2BatteryInserted && _m2BulbInserted)
                      Positioned(
                        left: (batteryX + bulbX) / 2 - 10,
                        top: centerY - 50,
                        child: MedeTestaProbeSlot(
                          isRed: true,
                          isConnected: _redProbeConnected,
                          onTap: () => setState(
                              () => _redProbeConnected = !_redProbeConnected),
                          label: 'A',
                        ),
                      ),
                    if (_m2BatteryInserted && _m2BulbInserted)
                      Positioned(
                        left: (batteryX + bulbX) / 2 - 10,
                        top: centerY + 30,
                        child: MedeTestaProbeSlot(
                          isRed: false,
                          isConnected: _blackProbeConnected,
                          onTap: () => setState(() =>
                              _blackProbeConnected = !_blackProbeConnected),
                          label: 'B',
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
