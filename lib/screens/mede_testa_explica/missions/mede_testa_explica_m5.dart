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
import '../../../widgets/realistic_wire_painter.dart';
import '../../../widgets/schematic_blueprint_socket.dart';
import '../../../widgets/success_confetti_overlay.dart';
import '../../../widgets/workbench_components.dart';
import '../../../widgets/workbench_table_frame.dart';
import '../widgets/mede_testa_explica_widgets.dart';

/// Missão 5 do Estande 07 — Diário de Investigação (Diagnóstico de Falha).
class MedeTestaExplicaM5 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const MedeTestaExplicaM5({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<MedeTestaExplicaM5> createState() => _MedeTestaExplicaM5State();
}

class _MedeTestaExplicaM5State extends State<MedeTestaExplicaM5> {
  final StandMission _mission = StandMission.medeTestaExplicaMissions[4];
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  bool _usePhysicalStyle = true;
  bool _isSimulating = false;

  bool _m5BatteryInserted = true;
  double _m5BatteryRotation = 0.0;
  bool _m5ResistorInserted = true;
  double _m5ResistorRotation = 0.0;
  bool _m5LedInserted = true;
  double _m5LedRotation = 0.0;
  int? _m5SelectedReportIndex;

  bool get _isClosed =>
      _m5BatteryInserted &&
      _m5ResistorInserted &&
      _m5LedInserted &&
      _m5SelectedReportIndex != null;

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
      _m5BatteryInserted = true;
      _m5ResistorInserted = true;
      _m5LedInserted = true;
      _m5SelectedReportIndex = null;
    });
  }

  Future<void> _validateMission() async {
    if (_isSimulating) return;
    setState(() => _isSimulating = true);

    try {
      bool isSuccess = false;
      String feedback = _mission.failureFeedback;

      if (_m5SelectedReportIndex == 1) {
        final result = await MissionCircuitBuilder()
            .addBattery(id: 'bat1', voltage: 9.0)
            .addResistor(id: 'r1', resistance: 10000.0)
            .addLed(id: 'led1')
            .connect('bat1', 'B', 'r1', 'A')
            .connect('r1', 'B', 'led1', 'A')
            .connect('led1', 'B', 'bat1', 'A')
            .simulate();
        if (result.hasClosedLoop) {
          final currentMa = result.current * 1000;
          feedback =
              'Diagnóstico confirmado! Com 10kΩ, a corrente é apenas ${currentMa.toStringAsFixed(2)}mA. '
              'O resistor limita excessivamente a corrente.';
          isSuccess = true;
        } else {
          feedback = 'O resistor de 10kΩ é muito alto para este circuito.';
        }
      } else if (_m5SelectedReportIndex == null) {
        feedback =
            'Faça as medições e selecione o diagnóstico no relatório final.';
      } else {
        feedback =
            'Revise a medição: a bateria fornece 9V normal e o LED está com polaridade correta.';
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
          'Diagnóstico investigativo impecável! Você identificou que o valor da resistência (10 kΩ) era elevado demais para acender o LED com brilho visível.',
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
              'CONCLUIR ESTANDE',
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
              'Diagnóstico Incorreto',
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
    const voltage = 9.0;
    const currentMa = 0.9;

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
                  rightHeaderWidget: const MedeTestaTelemetryCard(
                    voltage: voltage,
                    currentMa: currentMa,
                    isClosed: true,
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
              Text(
                'Conclusão do Diário de Investigação:',
                style: GoogleFonts.rajdhani(
                  color: Colors.amberAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              MedeTestaReportOptionTile(
                index: 0,
                label: 'A bateria de 9V está descarregada.',
                isSelected: _m5SelectedReportIndex == 0,
                onSelect: (idx) =>
                    setState(() => _m5SelectedReportIndex = idx),
              ),
              const SizedBox(height: 6),
              MedeTestaReportOptionTile(
                index: 1,
                label:
                    'O resistor de 10kΩ é muito alto para o LED, limitando excessivamente a corrente.',
                isSelected: _m5SelectedReportIndex == 1,
                onSelect: (idx) =>
                    setState(() => _m5SelectedReportIndex = idx),
              ),
              const SizedBox(height: 6),
              MedeTestaReportOptionTile(
                index: 2,
                label: 'O LED foi montado com polaridade invertida.',
                isSelected: _m5SelectedReportIndex == 2,
                onSelect: (idx) =>
                    setState(() => _m5SelectedReportIndex = idx),
              ),
              const SizedBox(height: 12),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Diagnóstico: Por que o LED está fraco?',
          style: GoogleFonts.rajdhani(
            color: const Color(0xFFD97706),
            fontWeight: FontWeight.bold,
            fontSize: 16,
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
                final centerX = w * 0.5;
                final batteryY = h * 0.15;
                final resistorY = h * 0.5;
                final ledY = h * 0.85;
                final sock = 95.0;
                final comp = 55.0;

                final batteryPlacement = ComponentPlacement(
                  position: Offset(centerX, batteryY),
                  rotation: _m5BatteryRotation,
                  type: ComponentType.battery,
                );
                final resistorPlacement = ComponentPlacement(
                  position: Offset(centerX, resistorY),
                  rotation: _m5ResistorRotation,
                  type: ComponentType.resistor,
                );
                final ledPlacement = ComponentPlacement(
                  position: Offset(centerX, ledY),
                  rotation: _m5LedRotation,
                  type: ComponentType.led,
                );

                final wires = <WirePath>[];
                if (_m5BatteryInserted && _m5ResistorInserted) {
                  wires.add(DynamicWirePath.fromComponents(
                    compA: batteryPlacement,
                    terminalIndexA: 1,
                    compB: resistorPlacement,
                    terminalIndexB: 0,
                    color: const Color(0xFFEF4444),
                    isActive: true,
                  ).toWirePath());
                }
                if (_m5ResistorInserted && _m5LedInserted) {
                  wires.add(DynamicWirePath.fromComponents(
                    compA: resistorPlacement,
                    terminalIndexA: 1,
                    compB: ledPlacement,
                    terminalIndexB: 0,
                    color: const Color(0xFFF97316),
                    isActive: true,
                  ).toWirePath());
                }
                if (_m5LedInserted && _m5BatteryInserted) {
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
                      left: centerX - sock / 2,
                      top: batteryY - sock / 2,
                      child: PhysicalBlueprintSocket<String>(
                        expectedData: 'battery',
                        isFilled: _m5BatteryInserted,
                        rotation: _m5BatteryRotation,
                        width: sock,
                        height: sock,
                        showLabel: true,
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
                          size: Size(comp, comp),
                          painter: ComponentPhysicalPainter(
                            type: ComponentType.battery,
                            isDarkMode: false,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: centerX - sock / 2,
                      top: resistorY - sock / 2,
                      child: PhysicalBlueprintSocket<String>(
                        expectedData: 'resistor',
                        isFilled: _m5ResistorInserted,
                        rotation: _m5ResistorRotation,
                        width: sock,
                        height: sock,
                        showLabel: true,
                        onAccept: (_) => _insertComponent(
                          name: 'Resistor 10k',
                          getInserted: () => _m5ResistorInserted,
                          setInserted: (v) => _m5ResistorInserted = v,
                          getRotation: () => _m5ResistorRotation,
                          setRotation: (v) => _m5ResistorRotation = v,
                        ),
                        onRotate: () => _rotateComponent(
                          name: 'Resistor 10k',
                          getRotation: () => _m5ResistorRotation,
                          setRotation: (v) => _m5ResistorRotation = v,
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
                      left: centerX - sock / 2,
                      top: ledY - sock / 2,
                      child: PhysicalBlueprintSocket<String>(
                        expectedData: 'led',
                        isFilled: _m5LedInserted,
                        rotation: _m5LedRotation,
                        width: sock,
                        height: sock,
                        showLabel: true,
                        onAccept: (_) => _insertComponent(
                          name: 'LED',
                          getInserted: () => _m5LedInserted,
                          setInserted: (v) => _m5LedInserted = v,
                          getRotation: () => _m5LedRotation,
                          setRotation: (v) => _m5LedRotation = v,
                        ),
                        onRotate: () => _rotateComponent(
                          name: 'LED',
                          getRotation: () => _m5LedRotation,
                          setRotation: (v) => _m5LedRotation = v,
                        ),
                        onTap: () {},
                        symbolWidget: CustomPaint(
                          size: Size(comp, comp),
                          painter: ComponentPhysicalPainter(
                            type: ComponentType.led,
                            isActive: true,
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
      ],
    );
  }

  Widget _buildSchematicCanvas() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Diagnóstico: Por que o LED está fraco?',
          style: GoogleFonts.rajdhani(
            color: const Color(0xFFD97706),
            fontWeight: FontWeight.bold,
            fontSize: 16,
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
                final centerX = w * 0.5;
                final batteryY = h * 0.15;
                final resistorY = h * 0.5;
                final ledY = h * 0.85;

                final batteryPlacement = ComponentPlacement(
                  position: Offset(centerX, batteryY),
                  rotation: _m5BatteryRotation,
                  type: ComponentType.battery,
                );
                final resistorPlacement = ComponentPlacement(
                  position: Offset(centerX, resistorY),
                  rotation: _m5ResistorRotation,
                  type: ComponentType.resistor,
                );
                final ledPlacement = ComponentPlacement(
                  position: Offset(centerX, ledY),
                  rotation: _m5LedRotation,
                  type: ComponentType.led,
                );

                final wires = <WirePath>[];
                if (_m5BatteryInserted && _m5ResistorInserted) {
                  wires.add(DynamicWirePath.fromComponents(
                    compA: batteryPlacement,
                    terminalIndexA: 1,
                    compB: resistorPlacement,
                    terminalIndexB: 0,
                    color: const Color(0xFFEF4444),
                    isActive: true,
                  ).toWirePath());
                }
                if (_m5ResistorInserted && _m5LedInserted) {
                  wires.add(DynamicWirePath.fromComponents(
                    compA: resistorPlacement,
                    terminalIndexA: 1,
                    compB: ledPlacement,
                    terminalIndexB: 0,
                    color: const Color(0xFFF97316),
                    isActive: true,
                  ).toWirePath());
                }
                if (_m5LedInserted && _m5BatteryInserted) {
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
                      left: centerX - 47.5,
                      top: batteryY - 47.5,
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
                      left: centerX - 47.5,
                      top: resistorY - 47.5,
                      child: SchematicBlueprintSocket<String>(
                        expectedData: 'resistor',
                        isFilled: _m5ResistorInserted,
                        showLabel: false,
                        rotation: _m5ResistorRotation,
                        onAccept: (_) => _insertComponent(
                          name: 'Resistor 10k',
                          getInserted: () => _m5ResistorInserted,
                          setInserted: (v) => _m5ResistorInserted = v,
                          getRotation: () => _m5ResistorRotation,
                          setRotation: (v) => _m5ResistorRotation = v,
                        ),
                        onRotate: () => _rotateComponent(
                          name: 'Resistor 10k',
                          getRotation: () => _m5ResistorRotation,
                          setRotation: (v) => _m5ResistorRotation = v,
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
                      left: centerX - 47.5,
                      top: ledY - 47.5,
                      child: SchematicBlueprintSocket<String>(
                        expectedData: 'led',
                        isFilled: _m5LedInserted,
                        showLabel: false,
                        rotation: _m5LedRotation,
                        onAccept: (_) => _insertComponent(
                          name: 'LED',
                          getInserted: () => _m5LedInserted,
                          setInserted: (v) => _m5LedInserted = v,
                          getRotation: () => _m5LedRotation,
                          setRotation: (v) => _m5LedRotation = v,
                        ),
                        onRotate: () => _rotateComponent(
                          name: 'LED',
                          getRotation: () => _m5LedRotation,
                          setRotation: (v) => _m5LedRotation = v,
                        ),
                        onTap: () {},
                        symbolWidget: CustomPaint(
                          size: const Size(55, 55),
                          painter: CircuitSymbolPainter(
                            type: ComponentType.led,
                            isActive: true,
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
      ],
    );
  }
}
