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

/// Missão 4 do Estande 07 — Dimensionamento de Resistor de Proteção do LED.
class MedeTestaExplicaM4 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const MedeTestaExplicaM4({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<MedeTestaExplicaM4> createState() => _MedeTestaExplicaM4State();
}

class _MedeTestaExplicaM4State extends State<MedeTestaExplicaM4> {
  final StandMission _mission = StandMission.medeTestaExplicaMissions[3];
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  bool _usePhysicalStyle = true;
  bool _isSimulating = false;

  bool _m4BatteryInserted = true;
  double _m4BatteryRotation = 0.0;
  bool _m4ResistorInserted = true;
  double _m4ResistorRotation = 0.0;
  bool _m4LedInserted = true;
  double _m4LedRotation = 0.0;
  int? _m4SelectedResistor;

  bool get _isClosed =>
      _m4BatteryInserted &&
      _m4ResistorInserted &&
      _m4LedInserted &&
      _m4SelectedResistor != null;

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
      _m4BatteryInserted = true;
      _m4ResistorInserted = true;
      _m4LedInserted = true;
      _m4SelectedResistor = null;
    });
  }

  Future<void> _validateMission() async {
    if (_isSimulating) return;
    setState(() => _isSimulating = true);

    try {
      bool isSuccess = false;
      String feedback = _mission.failureFeedback;

      if (_m4SelectedResistor != null) {
        final result = await MissionCircuitBuilder()
            .addBattery(id: 'bat1', voltage: 9.0)
            .addResistor(id: 'r1', resistance: _m4SelectedResistor!.toDouble())
            .addLed(id: 'led1')
            .connect('bat1', 'B', 'r1', 'A')
            .connect('r1', 'B', 'led1', 'A')
            .connect('led1', 'B', 'bat1', 'A')
            .simulate();
        if (result.hasClosedLoop && result.errorMessage == null) {
          final currentMa = result.current * 1000;
          if (currentMa >= 10 && currentMa <= 15) {
            feedback =
                'Resistor ideal! Corrente: ${currentMa.toStringAsFixed(1)}mA (faixa segura 10-15mA).';
            isSuccess = true;
          } else if (currentMa > 15) {
            feedback =
                'Corrente excessiva: ${currentMa.toStringAsFixed(1)}mA! O LED pode queimar.';
          } else {
            feedback =
                'Corrente insuficiente: ${currentMa.toStringAsFixed(1)}mA. LED ficará apagado.';
          }
        } else if (result.isShortCircuit) {
          feedback = 'Curto-circuito! Resistor muito baixo!';
        } else {
          feedback = result.errorMessage ?? 'Erro na simulação.';
        }
      } else {
        feedback =
            'Escolha um resistor na gaveta lateral para limitar a corrente.';
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
          'Excelente escolha! O resistor de 680 Ω limitou a corrente em ~13.2 mA, garantindo brilho ideal do LED sem risco de sobrecorrente.',
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
              'Atenção na Escolha',
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
    final hasResistor = _m4SelectedResistor != null;
    final voltage = hasResistor ? 9.0 : 0.0;
    final currentMa =
        hasResistor ? (9.0 / _m4SelectedResistor!) * 1000 : 0.0;

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
              Text(
                'Selecione o Resistor de Proteção:',
                style: GoogleFonts.rajdhani(
                  color: const Color(0xFF0284C7),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              MedeTestaResistorOptionTile(
                value: 68,
                label: '68 Ω (Baixa Resistência — Perigo!)',
                color: Colors.redAccent,
                isSelected: _m4SelectedResistor == 68,
                onSelect: (val) => setState(() => _m4SelectedResistor = val),
              ),
              const SizedBox(height: 6),
              MedeTestaResistorOptionTile(
                value: 680,
                label: '680 Ω (Resistência Ideal — ~13mA)',
                color: const Color(0xFF00E5FF),
                isSelected: _m4SelectedResistor == 680,
                onSelect: (val) => setState(() => _m4SelectedResistor = val),
              ),
              const SizedBox(height: 6),
              MedeTestaResistorOptionTile(
                value: 6800,
                label: '6.8 kΩ (Alta Resistência — LED fraco)',
                color: Colors.amber,
                isSelected: _m4SelectedResistor == 6800,
                onSelect: (val) => setState(() => _m4SelectedResistor = val),
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
    final hasResistor = _m4SelectedResistor != null;
    final isSafe = _m4SelectedResistor == 680;
    final isBurned = _m4SelectedResistor == 68;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          hasResistor
              ? 'Resistor Selecionado: $_m4SelectedResistor Ω'
              : 'Selecione um resistor na gaveta lateral',
          style: GoogleFonts.rajdhani(
            color: isSafe
                ? const Color(0xFF10B981)
                : (isBurned ? Colors.redAccent : Colors.amberAccent),
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
                final batteryX = w * 0.15;
                final batteryY = h * 0.5;
                final resistorCenterX = w * 0.5;
                final r1Y = h * 0.22;
                final r2Y = h * 0.5;
                final r3Y = h * 0.78;
                final ledX = w * 0.85;
                final ledY = h * 0.5;
                final sock = 95.0;
                final comp = 55.0;

                final batteryPlacement = ComponentPlacement(
                  position: Offset(batteryX, batteryY),
                  rotation: _m4BatteryRotation,
                  type: ComponentType.battery,
                );
                final resistorPlacement = ComponentPlacement(
                  position: Offset(resistorCenterX, r2Y),
                  rotation: _m4ResistorRotation,
                  type: ComponentType.resistor,
                );
                final ledPlacement = ComponentPlacement(
                  position: Offset(ledX, ledY),
                  rotation: _m4LedRotation,
                  type: ComponentType.led,
                );

                final wires = <WirePath>[];
                if (_m4BatteryInserted && _m4ResistorInserted) {
                  wires.add(DynamicWirePath.fromComponents(
                    compA: batteryPlacement,
                    terminalIndexA: 1,
                    compB: resistorPlacement,
                    terminalIndexB: 0,
                    color: const Color(0xFFEF4444),
                    isActive: hasResistor,
                  ).toWirePath());
                }
                if (_m4ResistorInserted && _m4LedInserted) {
                  wires.add(DynamicWirePath.fromComponents(
                    compA: resistorPlacement,
                    terminalIndexA: 1,
                    compB: ledPlacement,
                    terminalIndexB: 0,
                    color: const Color(0xFFF97316),
                    isActive: hasResistor,
                  ).toWirePath());
                }
                if (_m4LedInserted && _m4BatteryInserted) {
                  wires.add(DynamicWirePath.fromComponents(
                    compA: ledPlacement,
                    terminalIndexA: 1,
                    compB: batteryPlacement,
                    terminalIndexB: 0,
                    color: const Color(0xFF1E293B),
                    isActive: hasResistor,
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
                        isFilled: _m4BatteryInserted,
                        rotation: _m4BatteryRotation,
                        width: sock,
                        height: sock,
                        showLabel: true,
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
                          size: Size(comp, comp),
                          painter: ComponentPhysicalPainter(
                            type: ComponentType.battery,
                            isDarkMode: false,
                          ),
                        ),
                      ),
                    ),
                    for (final entry in [
                      MapEntry(0, r1Y),
                      MapEntry(1, r2Y),
                      MapEntry(2, r3Y),
                    ])
                      Positioned(
                        left: resistorCenterX - sock / 2,
                        top: entry.value - sock / 2,
                        child: PhysicalBlueprintSocket<String>(
                          expectedData: 'resistor',
                          isFilled: _m4ResistorInserted,
                          rotation: _m4ResistorRotation,
                          width: sock,
                          height: sock,
                          showLabel: true,
                          onAccept: (_) => _insertComponent(
                            name: 'Resistor',
                            getInserted: () => _m4ResistorInserted,
                            setInserted: (v) => _m4ResistorInserted = v,
                            getRotation: () => _m4ResistorRotation,
                            setRotation: (v) => _m4ResistorRotation = v,
                          ),
                          onRotate: () => _rotateComponent(
                            name: 'Resistor',
                            getRotation: () => _m4ResistorRotation,
                            setRotation: (v) => _m4ResistorRotation = v,
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
                        isFilled: _m4LedInserted,
                        rotation: _m4LedRotation,
                        width: sock,
                        height: sock,
                        showLabel: true,
                        onAccept: (_) => _insertComponent(
                          name: 'LED',
                          getInserted: () => _m4LedInserted,
                          setInserted: (v) => _m4LedInserted = v,
                          getRotation: () => _m4LedRotation,
                          setRotation: (v) => _m4LedRotation = v,
                        ),
                        onRotate: () => _rotateComponent(
                          name: 'LED',
                          getRotation: () => _m4LedRotation,
                          setRotation: (v) => _m4LedRotation = v,
                        ),
                        onTap: () {},
                        symbolWidget: CustomPaint(
                          size: Size(comp, comp),
                          painter: ComponentPhysicalPainter(
                            type: ComponentType.led,
                            isActive: hasResistor && !isBurned,
                            isBurned: isBurned,
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
    final hasResistor = _m4SelectedResistor != null;
    final isBurned = _m4SelectedResistor == 68;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          hasResistor
              ? 'Resistor Selecionado: $_m4SelectedResistor Ω'
              : 'Selecione um resistor na gaveta lateral',
          style: GoogleFonts.rajdhani(
            color: const Color(0xFF0F172A),
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
                final batteryX = w * 0.15;
                final batteryY = h * 0.5;
                final resistorCenterX = w * 0.5;
                final r2Y = h * 0.5;
                final ledX = w * 0.85;
                final ledY = h * 0.5;

                final batteryPlacement = ComponentPlacement(
                  position: Offset(batteryX, batteryY),
                  rotation: _m4BatteryRotation,
                  type: ComponentType.battery,
                );
                final resistorPlacement = ComponentPlacement(
                  position: Offset(resistorCenterX, r2Y),
                  rotation: _m4ResistorRotation,
                  type: ComponentType.resistor,
                );
                final ledPlacement = ComponentPlacement(
                  position: Offset(ledX, ledY),
                  rotation: _m4LedRotation,
                  type: ComponentType.led,
                );

                final wires = <WirePath>[];
                if (_m4BatteryInserted && _m4ResistorInserted) {
                  wires.add(DynamicWirePath.fromComponents(
                    compA: batteryPlacement,
                    terminalIndexA: 1,
                    compB: resistorPlacement,
                    terminalIndexB: 0,
                    color: const Color(0xFFEF4444),
                    isActive: hasResistor,
                  ).toWirePath());
                }
                if (_m4ResistorInserted && _m4LedInserted) {
                  wires.add(DynamicWirePath.fromComponents(
                    compA: resistorPlacement,
                    terminalIndexA: 1,
                    compB: ledPlacement,
                    terminalIndexB: 0,
                    color: const Color(0xFFF97316),
                    isActive: hasResistor,
                  ).toWirePath());
                }
                if (_m4LedInserted && _m4BatteryInserted) {
                  wires.add(DynamicWirePath.fromComponents(
                    compA: ledPlacement,
                    terminalIndexA: 1,
                    compB: batteryPlacement,
                    terminalIndexB: 0,
                    color: const Color(0xFF1E293B),
                    isActive: hasResistor,
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
                      left: resistorCenterX - 47.5,
                      top: r2Y - 47.5,
                      child: SchematicBlueprintSocket<String>(
                        expectedData: 'resistor',
                        isFilled: _m4ResistorInserted,
                        showLabel: false,
                        rotation: _m4ResistorRotation,
                        onAccept: (_) => _insertComponent(
                          name: 'Resistor',
                          getInserted: () => _m4ResistorInserted,
                          setInserted: (v) => _m4ResistorInserted = v,
                          getRotation: () => _m4ResistorRotation,
                          setRotation: (v) => _m4ResistorRotation = v,
                        ),
                        onRotate: () => _rotateComponent(
                          name: 'Resistor',
                          getRotation: () => _m4ResistorRotation,
                          setRotation: (v) => _m4ResistorRotation = v,
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
                        isFilled: _m4LedInserted,
                        showLabel: false,
                        rotation: _m4LedRotation,
                        onAccept: (_) => _insertComponent(
                          name: 'LED',
                          getInserted: () => _m4LedInserted,
                          setInserted: (v) => _m4LedInserted = v,
                          getRotation: () => _m4LedRotation,
                          setRotation: (v) => _m4LedRotation = v,
                        ),
                        onRotate: () => _rotateComponent(
                          name: 'LED',
                          getRotation: () => _m4LedRotation,
                          setRotation: (v) => _m4LedRotation = v,
                        ),
                        onTap: () {},
                        symbolWidget: CustomPaint(
                          size: const Size(55, 55),
                          painter: CircuitSymbolPainter(
                            type: ComponentType.led,
                            isActive: hasResistor && !isBurned,
                            isBurned: isBurned,
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
