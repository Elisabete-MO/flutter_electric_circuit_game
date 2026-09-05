import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/circuit_action.dart';
import '../../../models/first_step_component.dart';
import '../../../models/stand_mission.dart';
import '../../../state/circuit_undo_redo_controller.dart';
import '../../../widgets/circuit_symbol_painter.dart';
import '../../../widgets/component_physical_painter.dart';
import '../../../widgets/physical_blueprint_socket.dart';
import '../../../widgets/prof_volts_feedback_dialog.dart';
import '../../../widgets/realistic_wire_painter.dart';
import '../../../widgets/schematic_blueprint_socket.dart';
import '../../../widgets/schematic_symbol_painters.dart';
import '../../../widgets/workbench_components.dart';
import '../../../widgets/workbench_table_frame.dart';
import '../widgets/liga_desliga_widgets.dart';

/// Missão 3 do Estande 3 — Quem controla qual luz? (Duas chaves sem etiqueta).
class LigaDesligaM3 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const LigaDesligaM3({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<LigaDesligaM3> createState() => _LigaDesligaM3State();
}

class _LigaDesligaM3State extends State<LigaDesligaM3>
    with SingleTickerProviderStateMixin {
  final StandMission _mission = StandMission.estande3Missions[2];
  final CircuitUndoRedoController _undoRedoController = CircuitUndoRedoController();

  bool _usePhysicalStyle = true;
  bool _switch1Closed = false;
  bool _switch2Closed = false;
  bool _testedSwitch1 = false;
  bool _testedSwitch2 = false;
  static const bool _batteryInserted = true;
  static const bool _lampAInserted = true;
  static const bool _lampBInserted = true;
  static const bool _switch1Inserted = true;
  static const bool _switch2Inserted = true;
  static const double _batteryRotation = 270.0;
  static const double _lampARotation = 0.0;
  static const double _lampBRotation = 0.0;
  static const double _switch1Rotation = 0.0;
  static const double _switch2Rotation = 0.0;
  String? _mapSwitch1;
  String? _mapSwitch2;

  late AnimationController _currentFlowController;

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

  bool get _isClosed =>
      _batteryInserted &&
      ((_switch1Inserted && _switch1Closed && _lampAInserted) ||
          (_switch2Inserted && _switch2Closed && _lampBInserted));


  void _validate() {
    if (!_testedSwitch1 || !_testedSwitch2) {
      _showFeedback(false, _mission.failureFeedback);
      return;
    }
    if (_mapSwitch1 == 'lampA' && _mapSwitch2 == 'lampB') {
      _showFeedback(
        true,
        'Muito bem! Você testou cada controle individualmente e mapeou corretamente Chave 1 -> Luminária A e Chave 2 -> Luminária B.',
      );
    } else {
      _showFeedback(
        false,
        'Mapeamento incorreto. Teste alternar uma chave por vez e observe qual luz responde.',
      );
    }
  }

  void _showFeedback(bool isCorrect, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProfVoltsFeedbackDialog(
        isCorrect: isCorrect,
        message: message,
        onAction: () {
          Navigator.of(context).pop();
          if (isCorrect) {
            widget.onMissionComplete();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Área Principal da Bancada
        Expanded(
          flex: 7,
          child: WorkbenchTableFrame(
            usePhysicalStyle: _usePhysicalStyle,
            onStyleChanged: (val) => setState(() => _usePhysicalStyle = val),
            leftHeaderWidget: buildLigaDesligaStatusCard(_isClosed),
            rightHeaderWidget: buildLigaDesligaTelemetryCard(
              9.0,
              _isClosed ? 180.0 : 0.0,
              _isClosed,
            ),
            bottomWidget: _buildUndoRedoButtons(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    'Teste acionar um interruptor por vez para descobrir qual luz responde a cada controle:',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      shadows: const [
                        Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 1)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _usePhysicalStyle
                      ? _buildPhysicalCanvas()
                      : _buildSchematicCanvas(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildMappingSelector(
                        title: 'Chave 1 controla:',
                        currentSelection: _mapSwitch1,
                        onSelect: (val) => setState(() => _mapSwitch1 = val),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMappingSelector(
                        title: 'Chave 2 controla:',
                        currentSelection: _mapSwitch2,
                        onSelect: (val) => setState(() => _mapSwitch2 = val),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Painel Lateral (Briefing & Validação)
        Expanded(
          flex: 3,
          child: WorkbenchSidePanel(
            teamTitle: 'Painel da Equipe Controle',
            toolboxItems: [
              _buildMissionBriefingCard(),
            ],
            onEnergizePressed: _validate,
          ),
        ),
      ],
    );
  }

  Widget _buildMappingSelector({
    required String title,
    required String? currentSelection,
    required ValueChanged<String> onSelect,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: currentSelection != null
              ? const Color(0xFF0284C7)
              : const Color(0xFFCBD5E1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            initialValue: currentSelection,
            dropdownColor: Colors.white,
            style: GoogleFonts.outfit(
              color: const Color(0xFF0F172A),
              fontSize: 12.5,
            ),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'lampA', child: Text('Luminária A')),
              DropdownMenuItem(value: 'lampB', child: Text('Luminária B')),
            ],
            onChanged: (val) {
              if (val != null) onSelect(val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUndoRedoButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.undo_rounded, size: 20),
            tooltip: 'Desfazer ação',
            color: _undoRedoController.canUndo
                ? const Color(0xFF0F172A)
                : const Color(0xFFCBD5E1),
            onPressed: _undoRedoController.canUndo
                ? () => _undoRedoController.undo()
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.redo_rounded, size: 20),
            tooltip: 'Refazer ação',
            color: _undoRedoController.canRedo
                ? const Color(0xFF0F172A)
                : const Color(0xFFCBD5E1),
            onPressed: _undoRedoController.canRedo
                ? () => _undoRedoController.redo()
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildMissionBriefingCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.task_alt_rounded, color: Color(0xFF0284C7), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Missão 3: ${_mission.title}',
                  style: GoogleFonts.rajdhani(
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _mission.objective,
            style: GoogleFonts.outfit(
              color: const Color(0xFF334155),
              fontSize: 12.5,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.tips_and_updates_rounded,
                  color: Color(0xFFD97706),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Prof. Volts: "${_mission.voltsMediation}"',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF475569),
                      fontSize: 11.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhysicalCanvas() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double centerY = 110.0;

        final batteryPos = Offset(width * 0.18, centerY);
        final switch1Pos = Offset(width * 0.50, 45.0);
        final switch2Pos = Offset(width * 0.50, 175.0);
        final lamp1Pos = Offset(width * 0.82, 45.0);
        final lamp2Pos = Offset(width * 0.82, 175.0);

        final wires = <WirePath>[];

        final batTermA = ComponentPlacement(
                position: batteryPos,
                rotation: _batteryRotation,
                type: ComponentType.battery)
            .getTerminalPosition(0);
        final batTermB = ComponentPlacement(
                position: batteryPos,
                rotation: _batteryRotation,
                type: ComponentType.battery)
            .getTerminalPosition(1);

        if (_batteryInserted && _switch1Inserted) {
          final sw1TermA = ComponentPlacement(
                  position: switch1Pos,
                  rotation: _switch1Rotation,
                  type: ComponentType.switchComponent)
              .getTerminalPosition(0);
          final leftX = batteryPos.dx - 65.0;
          final leftOfSw1 = switch1Pos.dx - 65.0;

          wires.add(DynamicWirePath.fromComponents(
            compA: ComponentPlacement(
                position: batteryPos,
                rotation: _batteryRotation,
                type: ComponentType.battery),
            terminalIndexA: 0,
            compB: ComponentPlacement(
                position: switch1Pos,
                rotation: _switch1Rotation,
                type: ComponentType.switchComponent),
            terminalIndexB: 0,
            color: const Color(0xFFEF4444),
            isActive: _switch1Closed,
            thickness: 4.0,
          ).toWirePath(intermediatePoints: [
            Offset(leftX, batTermA.dy),
            Offset(leftX, 45.0),
            Offset(leftOfSw1, 45.0),
            Offset(leftOfSw1, sw1TermA.dy),
          ]));
        }

        if (_batteryInserted && _switch2Inserted) {
          final sw2TermA = ComponentPlacement(
                  position: switch2Pos,
                  rotation: _switch2Rotation,
                  type: ComponentType.switchComponent)
              .getTerminalPosition(0);
          final leftX = batteryPos.dx - 65.0;
          final leftOfSw2 = switch2Pos.dx - 65.0;

          wires.add(DynamicWirePath.fromComponents(
            compA: ComponentPlacement(
                position: batteryPos,
                rotation: _batteryRotation,
                type: ComponentType.battery),
            terminalIndexA: 0,
            compB: ComponentPlacement(
                position: switch2Pos,
                rotation: _switch2Rotation,
                type: ComponentType.switchComponent),
            terminalIndexB: 0,
            color: const Color(0xFFEAB308),
            isActive: _switch2Closed,
            thickness: 4.0,
          ).toWirePath(intermediatePoints: [
            Offset(leftX, batTermA.dy),
            Offset(leftX, 175.0),
            Offset(leftOfSw2, 175.0),
            Offset(leftOfSw2, sw2TermA.dy),
          ]));
        }

        if (_switch1Inserted && _lampAInserted) {
          wires.add(DynamicWirePath.fromComponents(
            compA: ComponentPlacement(
                position: switch1Pos,
                rotation: _switch1Rotation,
                type: ComponentType.switchComponent),
            terminalIndexA: 1,
            compB: ComponentPlacement(
                position: lamp1Pos,
                rotation: _lampARotation,
                type: ComponentType.bulb),
            terminalIndexB: 0,
            color: const Color(0xFFF97316),
            isActive: _switch1Closed,
            thickness: 4.0,
          ).toWirePath());
        }

        if (_switch2Inserted && _lampBInserted) {
          wires.add(DynamicWirePath.fromComponents(
            compA: ComponentPlacement(
                position: switch2Pos,
                rotation: _switch2Rotation,
                type: ComponentType.switchComponent),
            terminalIndexA: 1,
            compB: ComponentPlacement(
                position: lamp2Pos,
                rotation: _lampBRotation,
                type: ComponentType.bulb),
            terminalIndexB: 0,
            color: const Color(0xFF10B981),
            isActive: _switch2Closed,
            thickness: 4.0,
          ).toWirePath());
        }

        if (_lampAInserted && _lampBInserted && _batteryInserted) {
          final bulb1TermB = ComponentPlacement(
                  position: lamp1Pos,
                  rotation: _lampARotation,
                  type: ComponentType.bulb)
              .getTerminalPosition(1);
          final rightX = lamp1Pos.dx + 65.0;
          final leftX = batteryPos.dx - 65.0;
          const bottomY = 220.0;

          wires.add(DynamicWirePath.fromComponents(
            compA: ComponentPlacement(
                position: lamp1Pos,
                rotation: _lampARotation,
                type: ComponentType.bulb),
            terminalIndexA: 1,
            compB: ComponentPlacement(
                position: batteryPos,
                rotation: _batteryRotation,
                type: ComponentType.battery),
            terminalIndexB: 1,
            color: const Color(0xFF2563EB),
            isActive: _switch1Closed || _switch2Closed,
            thickness: 4.0,
          ).toWirePath(intermediatePoints: [
            Offset(rightX, bulb1TermB.dy),
            Offset(rightX, bottomY),
            Offset(leftX, bottomY),
            Offset(leftX, batTermB.dy),
          ]));
        }

        return Container(
          decoration: const BoxDecoration(color: Colors.transparent),
          child: Stack(
            children: [
              Positioned.fill(
                child: RealisticWireWidget(
                  wires: wires,
                  animationValue: _currentFlowController.value,
                  showElectrons: _switch1Closed || _switch2Closed,
                ),
              ),

              // Bateria
              Positioned(
                left: batteryPos.dx - 45,
                top: batteryPos.dy - 45,
                child: PhysicalBlueprintSocket<String>(
                  expectedData: 'battery',
                  isFilled: _batteryInserted,
                  showLabel: false,
                  rotation: _batteryRotation,
                  onAccept: (_) {},
                  onRotate: () {},
                  onTap: () {},
                  symbolWidget: CustomPaint(
                    size: const Size(75, 75),
                    painter: ComponentPhysicalPainter(
                      type: ComponentType.battery,
                      isActive: true,
                      isDarkMode: false,
                      value: 9.0,
                    ),
                  ),
                ),
              ),

              // Chave 1
              Positioned(
                left: switch1Pos.dx - 45,
                top: switch1Pos.dy - 45,
                child: PhysicalBlueprintSocket<String>(
                  expectedData: 'switch1',
                  isFilled: _switch1Inserted,
                  showLabel: false,
                  rotation: _switch1Rotation,
                  onAccept: (_) {},
                  onRotate: () {},
                  onTap: () {
                    final prev = _switch1Closed;
                    _undoRedoController.execute(ToggleBoolAction(
                      description: 'Toggle Chave 1',
                      onApply: () => setState(() {
                        _switch1Closed = !prev;
                        _testedSwitch1 = true;
                      }),
                      onUndo: () => setState(() {
                        _switch1Closed = prev;
                        _testedSwitch1 = false;
                      }),
                    ));
                  },
                  symbolWidget: CustomPaint(
                    size: const Size(75, 75),
                    painter: ComponentPhysicalPainter(
                      type: ComponentType.switchComponent,
                      isActive: _switch1Closed,
                      isDarkMode: false,
                    ),
                  ),
                ),
              ),

              // Chave 2
              Positioned(
                left: switch2Pos.dx - 45,
                top: switch2Pos.dy - 45,
                child: PhysicalBlueprintSocket<String>(
                  expectedData: 'switch2',
                  isFilled: _switch2Inserted,
                  showLabel: false,
                  rotation: _switch2Rotation,
                  onAccept: (_) {},
                  onRotate: () {},
                  onTap: () {
                    final prev = _switch2Closed;
                    _undoRedoController.execute(ToggleBoolAction(
                      description: 'Toggle Chave 2',
                      onApply: () => setState(() {
                        _switch2Closed = !prev;
                        _testedSwitch2 = true;
                      }),
                      onUndo: () => setState(() {
                        _switch2Closed = prev;
                        _testedSwitch2 = false;
                      }),
                    ));
                  },
                  symbolWidget: CustomPaint(
                    size: const Size(75, 75),
                    painter: ComponentPhysicalPainter(
                      type: ComponentType.switchComponent,
                      isActive: _switch2Closed,
                      isDarkMode: false,
                    ),
                  ),
                ),
              ),

              // Lâmpada A
              Positioned(
                left: lamp1Pos.dx - 45,
                top: lamp1Pos.dy - 45,
                child: PhysicalBlueprintSocket<String>(
                  expectedData: 'bulb',
                  isFilled: _lampAInserted,
                  showLabel: false,
                  rotation: _lampARotation,
                  onAccept: (_) {},
                  onRotate: () {},
                  onTap: () {},
                  symbolWidget: CustomPaint(
                    size: const Size(75, 75),
                    painter: ComponentPhysicalPainter(
                      type: ComponentType.bulb,
                      isActive: _switch1Closed,
                      isDarkMode: false,
                    ),
                  ),
                ),
              ),

              // Lâmpada B
              Positioned(
                left: lamp2Pos.dx - 45,
                top: lamp2Pos.dy - 45,
                child: PhysicalBlueprintSocket<String>(
                  expectedData: 'bulb',
                  isFilled: _lampBInserted,
                  showLabel: false,
                  rotation: _lampBRotation,
                  onAccept: (_) {},
                  onRotate: () {},
                  onTap: () {},
                  symbolWidget: CustomPaint(
                    size: const Size(75, 75),
                    painter: ComponentPhysicalPainter(
                      type: ComponentType.bulb,
                      isActive: _switch2Closed,
                      isDarkMode: false,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSchematicCanvas() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        const double height = 180.0;
        final double batteryX = width * 0.18;
        final double lampX = width * 0.82;
        final double switchCenterX = width * 0.50;
        final double centerY = 90.0;

        return Container(
          height: height,
          decoration: const BoxDecoration(color: Colors.transparent),
          child: Stack(
            children: [
              CustomPaint(
                size: Size(width, height),
                painter: SchematicCircuitWirePainterM3(
                  branch1Closed: _switch1Closed,
                  branch2Closed: _switch2Closed,
                  animationValue: _currentFlowController.value,
                ),
              ),

              // Bateria
              Positioned(
                left: batteryX - 47.5,
                top: centerY - 40.0,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'battery',
                  isFilled: _batteryInserted,
                  showLabel: false,
                  rotation: _batteryRotation,
                  width: 95,
                  height: 80,
                  onAccept: (_) {},
                  onRotate: () {},
                  onTap: () {},
                  symbolWidget: CustomPaint(
                    size: const Size(54, 38),
                    painter: CircuitSymbolPainter(
                      type: ComponentType.battery,
                      color: const Color(0xFF0F172A),
                      strokeWidth: 2.2,
                    ),
                  ),
                  placeholderWidget: const SizedBox.shrink(),
                  label: '',
                ),
              ),

              // Chave 1
              Positioned(
                left: switchCenterX - 40.0,
                top: 40.0 - 25.0,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'switch1',
                  isFilled: _switch1Inserted,
                  showLabel: false,
                  rotation: _switch1Rotation,
                  width: 80,
                  height: 50,
                  onAccept: (_) {},
                  onRotate: () {},
                  onTap: () {
                    final prev = _switch1Closed;
                    _undoRedoController.execute(ToggleBoolAction(
                      description: 'Toggle Chave 1 M3',
                      onApply: () => setState(() {
                        _switch1Closed = !prev;
                        _testedSwitch1 = true;
                      }),
                      onUndo: () => setState(() {
                        _switch1Closed = prev;
                        _testedSwitch1 = false;
                      }),
                    ));
                  },
                  symbolWidget: CustomPaint(
                    size: const Size(54, 38),
                    painter: CircuitSymbolPainter(
                      type: ComponentType.switchComponent,
                      isActive: _switch1Closed,
                      color: const Color(0xFF0F172A),
                      strokeWidth: 2.2,
                    ),
                  ),
                  placeholderWidget: const SizedBox.shrink(),
                  label: '',
                ),
              ),

              // Chave 2
              Positioned(
                left: switchCenterX - 40.0,
                top: 140.0 - 25.0,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'switch2',
                  isFilled: _switch2Inserted,
                  showLabel: false,
                  rotation: _switch2Rotation,
                  width: 80,
                  height: 50,
                  onAccept: (_) {},
                  onRotate: () {},
                  onTap: () {
                    final prev = _switch2Closed;
                    _undoRedoController.execute(ToggleBoolAction(
                      description: 'Toggle Chave 2 M3',
                      onApply: () => setState(() {
                        _switch2Closed = !prev;
                        _testedSwitch2 = true;
                      }),
                      onUndo: () => setState(() {
                        _switch2Closed = prev;
                        _testedSwitch2 = false;
                      }),
                    ));
                  },
                  symbolWidget: CustomPaint(
                    size: const Size(54, 38),
                    painter: CircuitSymbolPainter(
                      type: ComponentType.switchComponent,
                      isActive: _switch2Closed,
                      color: const Color(0xFF0F172A),
                      strokeWidth: 2.2,
                    ),
                  ),
                  placeholderWidget: const SizedBox.shrink(),
                  label: '',
                ),
              ),

              // Lâmpada A
              Positioned(
                left: lampX - 40.0,
                top: 40.0 - 25.0,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'bulb',
                  isFilled: _lampAInserted,
                  showLabel: false,
                  rotation: _lampARotation,
                  width: 80,
                  height: 50,
                  onAccept: (_) {},
                  onRotate: () {},
                  onTap: () {},
                  symbolWidget: CustomPaint(
                    size: const Size(54, 38),
                    painter: CircuitSymbolPainter(
                      type: ComponentType.bulb,
                      isActive: _switch1Closed,
                      color: const Color(0xFF0F172A),
                      activeColor: const Color(0xFFD97706),
                      strokeWidth: 2.2,
                    ),
                  ),
                  placeholderWidget: const SizedBox.shrink(),
                  label: '',
                ),
              ),

              // Lâmpada B
              Positioned(
                left: lampX - 40.0,
                top: 140.0 - 25.0,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'bulb',
                  isFilled: _lampBInserted,
                  showLabel: false,
                  rotation: _lampBRotation,
                  width: 80,
                  height: 50,
                  onAccept: (_) {},
                  onRotate: () {},
                  onTap: () {},
                  symbolWidget: CustomPaint(
                    size: const Size(54, 38),
                    painter: CircuitSymbolPainter(
                      type: ComponentType.bulb,
                      isActive: _switch2Closed,
                      color: const Color(0xFF0F172A),
                      activeColor: const Color(0xFFD97706),
                      strokeWidth: 2.2,
                    ),
                  ),
                  placeholderWidget: const SizedBox.shrink(),
                  label: '',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
