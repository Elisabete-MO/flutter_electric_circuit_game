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
import '../../../widgets/schematic_blueprint_socket.dart';
import '../../../widgets/success_confetti_overlay.dart';
import '../../../widgets/workbench_components.dart';
import '../../../widgets/workbench_sidebar_cards.dart';
import '../../../widgets/workbench_table_frame.dart';
import '../widgets/mede_testa_explica_widgets.dart';

/// Missão 1 do Estande 07 — Medição Direta da Bateria 9V com Voltímetro e Amperímetro lado a lado.
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

  int get _currentStepperIndex {
    if (!_m1BatteryInserted) return 0;
    if (!_m1VoltmeterInserted || !(_redProbeConnected && _blackProbeConnected)) {
      return 1;
    }
    return 2;
  }

  bool _isStepCompleted(int index) {
    if (index == 0) return _m1BatteryInserted;
    if (index == 1) {
      return _m1VoltmeterInserted && _redProbeConnected && _blackProbeConnected;
    }
    if (index == 2) return _isClosed && _m1VoltmeterInserted;
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
            'Tensão da bateria: 9.0V DC. Voltímetro conectado em paralelo com a fonte!';
        isSuccess = true;
      } else if (!_m1VoltmeterInserted) {
        feedback = 'Arraste o Voltímetro da gaveta para a bancada de teste.';
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
          'Excelente! Você mediu a diferença de potencial elétrico (tensão = 9.0V DC) diretamente nos terminais da bateria usando as pontas de prova do voltímetro em paralelo.',
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
                missionNumber: 1,
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
                  'Inserir bateria no centro da bancada',
                  'Posicionar Voltímetro e conectar fios de prova',
                  'Validar leitura de tensão (9.0V DC)',
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
    final showReading =
        _m1BatteryInserted && _redProbeConnected && _blackProbeConnected;
    final voltageReading = showReading && _m1VoltmeterInserted ? 9.0 : 0.0;
    final currentReading = 0.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Medição Direta de Fonte DC — Instrumentos em Paralelo',
          style: GoogleFonts.rajdhani(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: scale.font(17, min: 14, max: 20),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;
                final centerY = h * 0.48;

                // Lado a lado: Voltímetro (esquerda) | Bateria 9V (centro) | Amperímetro (direita)
                final voltmeterX = w * 0.20;
                final batteryX = w * 0.50;
                final amperimeterX = w * 0.80;

                final sock = scale.size(115.0, min: 95.0, max: 140.0);
                final comp = sock * 0.65;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Fios de ponta de prova do Voltímetro para a Bateria
                    if (_m1BatteryInserted)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: MedeTestaDualProbeWirePainter(
                            fromCenter: Offset(voltmeterX, centerY),
                            toCenter: Offset(batteryX, centerY),
                            isConnected: _m1VoltmeterInserted &&
                                _redProbeConnected &&
                                _blackProbeConnected,
                          ),
                        ),
                      ),

                    // Fios de ponta de prova do Amperímetro para a Bateria (se inserido)
                    if (_m1BatteryInserted && _m1AmperimeterInserted)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: MedeTestaDualProbeWirePainter(
                            fromCenter: Offset(amperimeterX, centerY),
                            toCenter: Offset(batteryX, centerY),
                            isConnected: _m1AmperimeterInserted,
                          ),
                        ),
                      ),

                    // Socket 1: Voltímetro (Esquerda)
                    Positioned(
                      left: voltmeterX - sock / 2,
                      top: centerY - sock / 2,
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

                    // Leitura Digital Voltímetro
                    if (_m1VoltmeterInserted)
                      Positioned(
                        left: voltmeterX - 45,
                        top: centerY + sock / 2 + 10,
                        child: MedeTestaMeterReading(
                          value: voltageReading.toStringAsFixed(1),
                          unit: 'V DC',
                          color: const Color(0xFF0284C7),
                        ),
                      ),

                    // Socket 2: Bateria 9V (Centro)
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

                    // Controles de pontas de prova na Bateria
                    if (_m1BatteryInserted)
                      Positioned(
                        left: batteryX - 50,
                        top: centerY - sock / 2 - 38,
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
                        left: batteryX + 10,
                        top: centerY - sock / 2 - 38,
                        child: MedeTestaProbeSlot(
                          isRed: false,
                          isConnected: _blackProbeConnected,
                          onTap: () => setState(() =>
                              _blackProbeConnected = !_blackProbeConnected),
                          label: 'Polo (-)',
                        ),
                      ),

                    // Socket 3: Amperímetro (Direita - Opcional para comparação)
                    Positioned(
                      left: amperimeterX - sock / 2,
                      top: centerY - sock / 2,
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

                    // Leitura Digital Amperímetro
                    if (_m1AmperimeterInserted)
                      Positioned(
                        left: amperimeterX - 45,
                        top: centerY + sock / 2 + 10,
                        child: MedeTestaMeterReading(
                          value: currentReading.toStringAsFixed(1),
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
      ],
    );
  }

  Widget _buildSchematicCanvas() {
    final scale = UiScale.of(context);
    final showReading =
        _m1BatteryInserted && _redProbeConnected && _blackProbeConnected;
    final voltageReading = showReading && _m1VoltmeterInserted ? 9.0 : 0.0;
    final currentReading = 0.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Diagrama Esquemático — Medição com Voltímetro em Paralelo',
          style: GoogleFonts.rajdhani(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: scale.font(17, min: 14, max: 20),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;
                final centerY = h * 0.48;

                final voltmeterX = w * 0.20;
                final batteryX = w * 0.50;
                final amperimeterX = w * 0.80;

                final sock = scale.size(105.0, min: 85.0, max: 130.0);
                final comp = sock * 0.65;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Fios de ponta de prova esquemáticos
                    if (_m1BatteryInserted)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: MedeTestaDualProbeWirePainter(
                            fromCenter: Offset(voltmeterX, centerY),
                            toCenter: Offset(batteryX, centerY),
                            isConnected: _m1VoltmeterInserted &&
                                _redProbeConnected &&
                                _blackProbeConnected,
                          ),
                        ),
                      ),
                    if (_m1BatteryInserted && _m1AmperimeterInserted)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: MedeTestaDualProbeWirePainter(
                            fromCenter: Offset(amperimeterX, centerY),
                            toCenter: Offset(batteryX, centerY),
                            isConnected: _m1AmperimeterInserted,
                          ),
                        ),
                      ),

                    // Socket 1: Voltímetro Esquemático
                    Positioned(
                      left: voltmeterX - sock / 2,
                      top: centerY - sock / 2,
                      child: SchematicBlueprintSocket<String>(
                        expectedData: 'multimeter_v',
                        isFilled: _m1VoltmeterInserted,
                        showLabel: false,
                        rotation: _m1VoltmeterRotation,
                        width: sock,
                        height: sock,
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
                        placeholderWidget: MeterVectorWidget(
                          size: comp * 0.85,
                          meterType: 'V',
                          accentColor: const Color(0xFF94A3B8),
                        ),
                        label: '',
                      ),
                    ),

                    // Leitura Digital Voltímetro
                    if (_m1VoltmeterInserted)
                      Positioned(
                        left: voltmeterX - 45,
                        top: centerY + sock / 2 + 10,
                        child: MedeTestaMeterReading(
                          value: voltageReading.toStringAsFixed(1),
                          unit: 'V DC',
                          color: const Color(0xFF0284C7),
                        ),
                      ),

                    // Socket 2: Bateria Esquemática
                    Positioned(
                      left: batteryX - sock / 2,
                      top: centerY - sock / 2,
                      child: SchematicBlueprintSocket<String>(
                        expectedData: 'battery',
                        isFilled: _m1BatteryInserted,
                        showLabel: false,
                        rotation: _m1BatteryRotation,
                        width: sock,
                        height: sock,
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

                    // Pontas de prova esquemáticas
                    if (_m1BatteryInserted)
                      Positioned(
                        left: batteryX - 50,
                        top: centerY - sock / 2 - 38,
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
                        left: batteryX + 10,
                        top: centerY - sock / 2 - 38,
                        child: MedeTestaProbeSlot(
                          isRed: false,
                          isConnected: _blackProbeConnected,
                          onTap: () => setState(() =>
                              _blackProbeConnected = !_blackProbeConnected),
                          label: 'Polo (-)',
                        ),
                      ),

                    // Socket 3: Amperímetro Esquemático
                    Positioned(
                      left: amperimeterX - sock / 2,
                      top: centerY - sock / 2,
                      child: SchematicBlueprintSocket<String>(
                        expectedData: 'multimeter_a',
                        isFilled: _m1AmperimeterInserted,
                        showLabel: false,
                        rotation: _m1AmperimeterRotation,
                        width: sock,
                        height: sock,
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
                        placeholderWidget: MeterVectorWidget(
                          size: comp * 0.85,
                          meterType: 'A',
                          accentColor: const Color(0xFF94A3B8),
                        ),
                        label: '',
                      ),
                    ),

                    // Leitura Digital Amperímetro
                    if (_m1AmperimeterInserted)
                      Positioned(
                        left: amperimeterX - 45,
                        top: centerY + sock / 2 + 10,
                        child: MedeTestaMeterReading(
                          value: currentReading.toStringAsFixed(1),
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
      ],
    );
  }
}
