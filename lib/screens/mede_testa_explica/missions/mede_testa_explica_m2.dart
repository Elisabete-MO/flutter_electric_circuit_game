import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/ui_scale.dart';
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
import '../../../widgets/workbench_sidebar_cards.dart';
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

  int get _currentStepperIndex {
    if (!(_m2BatteryInserted && _m2BulbInserted)) return 0;
    if (!_m2VoltmeterInserted || !(_redProbeConnected && _blackProbeConnected)) {
      return 1;
    }
    return 2;
  }

  bool _isStepCompleted(int index) {
    if (index == 0) return _m2BatteryInserted && _m2BulbInserted;
    if (index == 1) {
      return _m2VoltmeterInserted && _redProbeConnected && _blackProbeConnected;
    }
    if (index == 2) return _isClosed && _m2VoltmeterInserted;
    return false;
  }

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
          final vDrop = result.componentVoltages['bulb1'] ?? 9.0;
          feedback =
              'Queda de tensão na lâmpada: ${vDrop.toStringAsFixed(2)}V. '
              'A carga converte a diferença de potencial em luz e calor.';
          isSuccess = true;
        } else {
          feedback = 'Circuito aberto. Verifique as conexões da bancada.';
        }
      } else if (!_m2VoltmeterInserted) {
        feedback = 'Arraste o Voltímetro da gaveta para medir a carga.';
      } else {
        feedback =
            'Conecte as pontas de prova vermelha e preta nos terminais da lâmpada.';
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
          'Fantástico! Você comprovou que a carga (lâmpada incandescente) recebe e consome a totalidade dos 9.0V da fonte, medindo com o voltímetro em paralelo nos terminais A e B.',
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

  Widget _buildUndoRedoButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _usePhysicalStyle ? Colors.white : const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _usePhysicalStyle
              ? const Color(0xFFCBD5E1)
              : const Color(0xFF334155),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.undo_rounded),
            tooltip: 'Desfazer',
            color: _undoRedoController.canUndo
                ? const Color(0xFF059669)
                : Colors.grey,
            onPressed: _undoRedoController.canUndo
                ? () => setState(() => _undoRedoController.undo())
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.redo_rounded),
            tooltip: 'Refazer',
            color: _undoRedoController.canRedo
                ? const Color(0xFF059669)
                : Colors.grey,
            onPressed: _undoRedoController.canRedo
                ? () => setState(() => _undoRedoController.redo())
                : null,
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
                  bottomWidget: _buildUndoRedoButtons(),
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
            showTeamHeader: false,
            buttonColor: const Color(0xFF059669),
            toolboxItems: [
              WorkbenchMissionObjectiveCard(
                missionNumber: 2,
                title: _mission.title,
                description: _mission.objective,
                voltsTip: _mission.voltsMediation,
              ),
              const SizedBox(height: 12),
              WorkbenchInvestigationStepperCard(
                title: 'Roteiro de investigação',
                currentStepIndex: _currentStepperIndex,
                isStepCompleted: _isStepCompleted,
                steps: const [
                  'Inserir bateria e lâmpada no circuito',
                  'Posicionar Voltímetro e conectar na lâmpada',
                  'Medir a queda de tensão e energizar',
                ],
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
    final scale = UiScale.of(context);
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
          'Medição de Queda de Potencial (Queda de Tensão na Carga)',
          style: GoogleFonts.rajdhani(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: scale.font(17, min: 14, max: 20),
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
                final batteryX = w * 0.22;
                final bulbX = w * 0.78;
                final centerY = h * 0.60;
                final voltmeterX = w * 0.50;
                final voltmeterY = h * 0.18;

                final sock = scale.size(110.0, min: 90.0, max: 135.0);
                final comp = sock * 0.62;

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
                  clipBehavior: Clip.none,
                  children: [
                    // Fios de alimentação principais da fonte para a lâmpada
                    if (wires.isNotEmpty)
                      Positioned.fill(
                        child: RealisticWireWidget(
                          wires: wires,
                          animationValue: 0,
                          showElectrons: _m2BatteryInserted && _m2BulbInserted,
                        ),
                      ),

                    // Fios de ponta de prova do Voltímetro para a Lâmpada
                    if (_m2BulbInserted)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: MedeTestaDualProbeWirePainter(
                            fromCenter: Offset(voltmeterX, voltmeterY),
                            toCenter: Offset(bulbX, centerY),
                            isConnected: _m2VoltmeterInserted &&
                                _redProbeConnected &&
                                _blackProbeConnected,
                          ),
                        ),
                      ),

                    // Socket 1: Bateria 9V
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

                    // Socket 2: Lâmpada (Carga)
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

                    // Pontas de prova nos terminais da lâmpada
                    if (_m2BulbInserted)
                      Positioned(
                        left: bulbX - 55,
                        top: centerY - sock / 2 - 38,
                        child: MedeTestaProbeSlot(
                          isRed: true,
                          isConnected: _redProbeConnected,
                          onTap: () => setState(
                              () => _redProbeConnected = !_redProbeConnected),
                          label: 'Nó (+)',
                        ),
                      ),
                    if (_m2BulbInserted)
                      Positioned(
                        left: bulbX + 5,
                        top: centerY - sock / 2 - 38,
                        child: MedeTestaProbeSlot(
                          isRed: false,
                          isConnected: _blackProbeConnected,
                          onTap: () => setState(() =>
                              _blackProbeConnected = !_blackProbeConnected),
                          label: 'Nó (-)',
                        ),
                      ),

                    // Socket 3: Voltímetro (Topo Central)
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

                    // Leitura Digital Voltímetro
                    if (_m2VoltmeterInserted)
                      Positioned(
                        left: voltmeterX - 45,
                        top: voltmeterY + sock / 2 + 10,
                        child: MedeTestaMeterReading(
                          value: voltageReading.toStringAsFixed(1),
                          unit: 'V DC',
                          color: const Color(0xFF0284C7),
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
    final scale = UiScale.of(context);
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
          'Diagrama Esquemático — Queda de Tensão na Lâmpada',
          style: GoogleFonts.rajdhani(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: scale.font(17, min: 14, max: 20),
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
                final batteryX = w * 0.22;
                final bulbX = w * 0.78;
                final centerY = h * 0.60;
                final voltmeterX = w * 0.50;
                final voltmeterY = h * 0.18;

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

                final sock = scale.size(105.0, min: 85.0, max: 130.0);
                final comp = sock * 0.65;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    if (wires.isNotEmpty)
                      Positioned.fill(
                        child: RealisticWireWidget(
                          wires: wires,
                          animationValue: 0,
                          showElectrons: _m2BatteryInserted && _m2BulbInserted,
                        ),
                      ),

                    // Fios de ponta de prova esquemáticos
                    if (_m2BulbInserted)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: MedeTestaDualProbeWirePainter(
                            fromCenter: Offset(voltmeterX, voltmeterY),
                            toCenter: Offset(bulbX, centerY),
                            isConnected: _m2VoltmeterInserted &&
                                _redProbeConnected &&
                                _blackProbeConnected,
                          ),
                        ),
                      ),

                    Positioned(
                      left: batteryX - sock / 2,
                      top: centerY - sock / 2,
                      child: SchematicBlueprintSocket<String>(
                        expectedData: 'battery',
                        isFilled: _m2BatteryInserted,
                        showLabel: false,
                        rotation: _m2BatteryRotation,
                        width: sock,
                        height: sock,
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
                          size: Size(comp, comp * 0.7),
                          painter: CircuitSymbolPainter(
                            type: ComponentType.battery,
                            color: const Color(0xFF0F172A),
                            strokeWidth: 2.5,
                          ),
                        ),
                        placeholderWidget: CustomPaint(
                          size: Size(comp * 0.85, comp * 0.6),
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
                      left: bulbX - sock / 2,
                      top: centerY - sock / 2,
                      child: SchematicBlueprintSocket<String>(
                        expectedData: 'bulb',
                        isFilled: _m2BulbInserted,
                        showLabel: false,
                        rotation: _m2BulbRotation,
                        width: sock,
                        height: sock,
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
                          size: Size(comp, comp * 0.7),
                          painter: CircuitSymbolPainter(
                            type: ComponentType.bulb,
                            isActive: _m2BatteryInserted && _m2BulbInserted,
                            color: const Color(0xFF0F172A),
                            strokeWidth: 2.5,
                          ),
                        ),
                        placeholderWidget: CustomPaint(
                          size: Size(comp * 0.85, comp * 0.6),
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
                      left: voltmeterX - sock / 2,
                      top: voltmeterY - sock / 2,
                      child: SchematicBlueprintSocket<String>(
                        expectedData: 'multimeter_v',
                        isFilled: _m2VoltmeterInserted,
                        showLabel: false,
                        rotation: _m2VoltmeterRotation,
                        width: sock,
                        height: sock,
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
                        placeholderWidget: MeterVectorWidget(
                          size: comp * 0.85,
                          meterType: 'V',
                          accentColor: const Color(0xFF94A3B8),
                        ),
                        label: '',
                      ),
                    ),
                    if (_m2VoltmeterInserted)
                      Positioned(
                        left: voltmeterX - 45,
                        top: voltmeterY + sock / 2 + 10,
                        child: MedeTestaMeterReading(
                          value: voltageReading.toStringAsFixed(1),
                          unit: 'V DC',
                          color: const Color(0xFF0284C7),
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
