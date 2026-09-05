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
import '../../../widgets/schematic_blueprint_socket.dart';
import '../../../widgets/success_confetti_overlay.dart';
import '../../../widgets/workbench_components.dart';
import '../../../widgets/workbench_table_frame.dart';
import '../widgets/mede_testa_explica_widgets.dart';

/// Missão 1 do Estande 07 — Medição Direta da Bateria 9V com Voltímetro.
class MedeTestaExplicaM1 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const MedeTestaExplicaM1({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<MedeTestaExplicaM1> createState() => _MedeTestaExplicaM1State();
}

class _MedeTestaExplicaM1State extends State<MedeTestaExplicaM1> {
  final StandMission _mission = StandMission.medeTestaExplicaMissions[0];
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  bool _usePhysicalStyle = true;
  bool _isSimulating = false;

  bool _redProbeConnected = true;
  bool _blackProbeConnected = true;

  bool _m1BatteryInserted = true;
  double _m1BatteryRotation = 0.0;
  bool _m1VoltmeterInserted = false;
  double _m1VoltmeterRotation = 0.0;
  bool _m1AmperimeterInserted = false;
  double _m1AmperimeterRotation = 0.0;

  bool get _isClosed =>
      _m1BatteryInserted && _redProbeConnected && _blackProbeConnected;

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
      _m1BatteryInserted = true;
      _m1VoltmeterInserted = false;
      _m1AmperimeterInserted = false;
    });
  }

  Future<void> _validateMission() async {
    if (_isSimulating) return;
    setState(() => _isSimulating = true);

    try {
      bool isSuccess = false;
      String feedback = _mission.failureFeedback;

      if (_redProbeConnected && _blackProbeConnected && _m1VoltmeterInserted) {
        await MissionCircuitBuilder()
            .addBattery(id: 'bat1', voltage: 9.0)
            .connect('bat1', 'B', 'bat1', 'A')
            .simulate();
        feedback =
            'Tensão da bateria: 9.0V DC. Voltímetro em paralelo com a fonte.';
        isSuccess = true;
      } else if (!_m1VoltmeterInserted) {
        feedback = 'Arraste o Voltímetro da gaveta para o circuito.';
      } else {
        feedback =
            'Posicione ambas as pontas de prova nos terminais da bateria.';
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
          'Excelente! Você mediu a diferença de potencial elétrico (tensão) diretamente nos terminais da bateria usando o voltímetro em paralelo.',
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
    final showReading =
        _m1BatteryInserted && _redProbeConnected && _blackProbeConnected;
    final voltage = showReading && _m1VoltmeterInserted ? 9.0 : 0.0;
    final currentMa = 0.0;

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
    final showReading =
        _m1BatteryInserted && _redProbeConnected && _blackProbeConnected;
    final voltageReading = showReading ? 9.0 : 0.0;
    final currentReading = 0.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Medição Direta da Bateria 9V',
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
                final batteryX = w * 0.35;
                final centerY = h * 0.5;
                final voltmeterX = w * 0.35;
                final voltmeterY = h * 0.12;
                final amperimeterX = w * 0.35;
                final amperimeterY = h * 0.88;
                final sock = 95.0;
                final comp = 55.0;

                return Stack(
                  children: [
                    if (_m1BatteryInserted)
                      Positioned(
                        left: 0,
                        top: 0,
                        right: 0,
                        bottom: 0,
                        child: CustomPaint(
                          painter: ProbeWirePainter(
                            batteryCenter: Offset(batteryX, centerY),
                            redProbeCenter: Offset(w * 0.72, centerY - 30),
                            blackProbeCenter: Offset(w * 0.72, centerY + 30),
                          ),
                        ),
                      ),
                    Positioned(
                      left: batteryX - sock / 2,
                      top: centerY - sock / 2,
                      child: PhysicalBlueprintSocket<String>(
                        expectedData: 'battery',
                        isFilled: _m1BatteryInserted,
                        rotation: _m1BatteryRotation,
                        width: sock,
                        height: sock,
                        showLabel: true,
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
                          size: Size(comp, comp),
                          painter: ComponentPhysicalPainter(
                            type: ComponentType.battery,
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
                        isFilled: _m1VoltmeterInserted,
                        rotation: _m1VoltmeterRotation,
                        width: sock,
                        height: sock,
                        showLabel: true,
                        onAccept: (_) => _insertComponent(
                          name: 'Voltímetro',
                          getInserted: () => _m1VoltmeterInserted,
                          setInserted: (v) => _m1VoltmeterInserted = v,
                          getRotation: () => _m1VoltmeterRotation,
                          setRotation: (v) => _m1VoltmeterRotation = v,
                        ),
                        onRotate: () => _rotateComponent(
                          name: 'Voltímetro',
                          getRotation: () => _m1VoltmeterRotation,
                          setRotation: (v) => _m1VoltmeterRotation = v,
                        ),
                        onTap: () {},
                        symbolWidget: MeterVectorWidget(
                          size: comp,
                          meterType: 'V',
                          accentColor: const Color(0xFF0284C7),
                        ),
                      ),
                    ),
                    if (_m1VoltmeterInserted)
                      Positioned(
                        left: voltmeterX - 40,
                        top: voltmeterY + sock / 2 + 4,
                        child: MedeTestaMeterReading(
                          value: voltageReading.toStringAsFixed(1),
                          unit: 'V DC',
                          color: const Color(0xFF0284C7),
                        ),
                      ),
                    Positioned(
                      left: amperimeterX - sock / 2,
                      top: amperimeterY - sock / 2,
                      child: PhysicalBlueprintSocket<String>(
                        expectedData: 'multimeter_a',
                        isFilled: _m1AmperimeterInserted,
                        rotation: _m1AmperimeterRotation,
                        width: sock,
                        height: sock,
                        showLabel: true,
                        onAccept: (_) => _insertComponent(
                          name: 'Amperímetro',
                          getInserted: () => _m1AmperimeterInserted,
                          setInserted: (v) => _m1AmperimeterInserted = v,
                          getRotation: () => _m1AmperimeterRotation,
                          setRotation: (v) => _m1AmperimeterRotation = v,
                        ),
                        onRotate: () => _rotateComponent(
                          name: 'Amperímetro',
                          getRotation: () => _m1AmperimeterRotation,
                          setRotation: (v) => _m1AmperimeterRotation = v,
                        ),
                        onTap: () {},
                        symbolWidget: MeterVectorWidget(
                          size: comp,
                          meterType: 'A',
                          accentColor: const Color(0xFFD97706),
                        ),
                      ),
                    ),
                    if (_m1AmperimeterInserted)
                      Positioned(
                        left: amperimeterX - 40,
                        top: amperimeterY - sock / 2 - 30,
                        child: MedeTestaMeterReading(
                          value: currentReading.toStringAsFixed(1),
                          unit: 'mA',
                          color: const Color(0xFFD97706),
                        ),
                      ),
                    if (_m1BatteryInserted)
                      Positioned(
                        left: w * 0.72 - 30,
                        top: centerY - 30 - 20,
                        child: MedeTestaProbeSlot(
                          isRed: true,
                          isConnected: _redProbeConnected,
                          onTap: () => setState(
                              () => _redProbeConnected = !_redProbeConnected),
                          label: 'Polo (+)',
                        ),
                      ),
                    if (_m1BatteryInserted)
                      Positioned(
                        left: w * 0.72 - 30,
                        top: centerY + 30 - 20,
                        child: MedeTestaProbeSlot(
                          isRed: false,
                          isConnected: _blackProbeConnected,
                          onTap: () => setState(() =>
                              _blackProbeConnected = !_blackProbeConnected),
                          label: 'Polo (-)',
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Medição Direta da Bateria 9V',
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
                final batteryX = w * 0.5;
                final centerY = h * 0.5;

                return Stack(
                  children: [
                    Positioned(
                      left: batteryX - 47.5,
                      top: centerY - 47.5,
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
                    if (_m1BatteryInserted)
                      Positioned(
                        left: batteryX + 60,
                        top: centerY - 30,
                        child: MedeTestaProbeSlot(
                          isRed: true,
                          isConnected: _redProbeConnected,
                          onTap: () => setState(
                              () => _redProbeConnected = !_redProbeConnected),
                          label: 'Polo (+)',
                        ),
                      ),
                    if (_m1BatteryInserted)
                      Positioned(
                        left: batteryX + 60,
                        top: centerY + 10,
                        child: MedeTestaProbeSlot(
                          isRed: false,
                          isConnected: _blackProbeConnected,
                          onTap: () => setState(() =>
                              _blackProbeConnected = !_blackProbeConnected),
                          label: 'Polo (-)',
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
