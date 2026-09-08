import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/ui_scale.dart';
import '../../../models/circuit_action.dart';
import '../../../models/first_step_component.dart';
import '../../../models/stand_mission.dart';
import '../../../state/circuit_undo_redo_controller.dart';
import '../../../widgets/circuit_symbol_painter.dart';
import '../../../widgets/component_physical_painter.dart';
import '../../../widgets/component_vector_painters.dart';
import '../../../widgets/physical_blueprint_socket.dart';
import '../../../widgets/prof_volts_feedback_dialog.dart';
import '../../../widgets/realistic_wire_painter.dart';
import '../../../widgets/schematic_blueprint_socket.dart';
import '../../../widgets/schematic_symbol_painters.dart';
import '../../../widgets/workbench_components.dart';
import '../../../widgets/workbench_sidebar_cards.dart';
import '../../../widgets/workbench_table_frame.dart';
import '../widgets/liga_desliga_widgets.dart';

/// Missão 1 do Estande 3 — Luz sob comando (Interruptor da Luminária).
class LigaDesligaM1 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const LigaDesligaM1({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<LigaDesligaM1> createState() => _LigaDesligaM1State();
}

class _LigaDesligaM1State extends State<LigaDesligaM1>
    with SingleTickerProviderStateMixin {
  final StandMission _mission = StandMission.estande3Missions[0];
  final CircuitUndoRedoController _undoRedoController = CircuitUndoRedoController();

  bool _usePhysicalStyle = true;
  bool _switchInserted = false;
  bool _switchClosed = false;
  bool _batteryInserted = true;
  bool _bulbInserted = true;
  double _batteryRotation = 270.0;
  double _switchRotation = 0.0;
  double _bulbRotation = 0.0;

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
      _batteryInserted && _switchInserted && _switchClosed && _bulbInserted;

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

  void _validate() {
    if (!_switchInserted) {
      _showFeedback(false, _mission.failureFeedback);
      return;
    }
    _showFeedback(
      true,
      'Perfeito! O interruptor foi inserido no caminho da corrente. Quando fechado, a lâmpada acende; quando aberto, o circuito se interrompe!',
    );
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
              4.5,
              _isClosed ? 90.0 : 0.0,
              _isClosed,
            ),
            bottomWidget: _buildUndoRedoButtons(),
            child: _usePhysicalStyle
                ? _buildPhysicalCanvas()
                : _buildSchematicCanvas(),
          ),
        ),
        const SizedBox(width: 16),
        // Painel Lateral (Objetivo, Stepper Dinâmico de Investigação & Validação)
        Expanded(
          flex: 3,
          child: WorkbenchSidePanel(
            teamTitle: 'Painel da Equipe Controle',
            showTeamHeader: false,
            buttonColor: const Color(0xFF059669),
            toolboxItems: [
              _buildMissionObjectiveCard(),
              const SizedBox(height: 12),
              _buildInvestigationStepperCard(),
              const SizedBox(height: 12),
              _buildSideToolboxDrawer(),
            ],
            onEnergizePressed: _validate,
          ),
        ),
      ],
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

  int get _currentStepperIndex {
    if (!_switchInserted) return 0;
    if (!_switchClosed) return 1;
    return 2;
  }

  bool _isStepCompleted(int index) {
    if (index == 0) return _switchInserted;
    if (index == 1) return _switchInserted && _switchClosed;
    if (index == 2) return _isClosed;
    return false;
  }

  Widget _buildMissionObjectiveCard() {
    return WorkbenchMissionObjectiveCard(
      missionNumber: 1,
      title: _mission.title,
      description: _mission.objective,
      voltsTip: _mission.voltsMediation,
      accentColor: const Color(0xFF0284C7),
    );
  }

  Widget _buildInvestigationStepperCard() {
    return WorkbenchInvestigationStepperCard(
      title: 'Progresso da investigação',
      currentStepIndex: _currentStepperIndex,
      isStepCompleted: _isStepCompleted,
      steps: const [
        'Encaixar chave no circuito',
        'Acionar o interruptor',
        'Comprovar controle da lâmpada',
      ],
    );
  }

  Widget _buildSideToolboxDrawer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
          child: Text(
            'Componentes Básicos:',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            WorkbenchSymbolToolboxTile<String>(
              data: 'battery',
              label: 'Bateria',
              tooltip: 'Fonte de Alimentação 4.5V',
              symbolWidget: _usePhysicalStyle
                  ? const BatteryVectorWidget(size: 34)
                  : CustomPaint(
                      size: const Size(34, 34),
                      painter: CircuitSymbolPainter(
                        type: ComponentType.battery,
                        color: const Color(0xFFD97706),
                        strokeWidth: 2.0,
                      ),
                    ),
              color: const Color(0xFFD97706),
            ),
            WorkbenchSymbolToolboxTile<String>(
              data: 'switch',
              label: 'SPST',
              tooltip: 'Interruptor SPST (Alavanca)',
              symbolWidget: _usePhysicalStyle
                  ? CustomPaint(
                      size: const Size(34, 34),
                      painter: ComponentPhysicalPainter(
                        type: ComponentType.switchComponent,
                        isDarkMode: false,
                      ),
                    )
                  : CustomPaint(
                      size: const Size(34, 34),
                      painter: CircuitSymbolPainter(
                        type: ComponentType.switchComponent,
                        color: const Color(0xFF0284C7),
                        strokeWidth: 2.0,
                      ),
                    ),
              color: const Color(0xFF0284C7),
            ),
            WorkbenchSymbolToolboxTile<String>(
              data: 'bulb',
              label: 'Lâmpada',
              tooltip: 'Luminária Incandescente',
              symbolWidget: _usePhysicalStyle
                  ? const BulbVectorWidget(size: 34)
                  : CustomPaint(
                      size: const Size(34, 34),
                      painter: CircuitSymbolPainter(
                        type: ComponentType.bulb,
                        color: const Color(0xFFD97706),
                        strokeWidth: 2.0,
                      ),
                    ),
              color: const Color(0xFFD97706),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhysicalCanvas() {
    final scale = context.uiScale;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;
        final double centerY = height * 0.50;
        final double compSize = scale.size(96, min: 80, max: 130);
        final double halfComp = compSize / 2.0;

        final batteryPos = Offset(width * 0.18, centerY);
        final switchPos = Offset(width * 0.50, centerY);
        final lampPos = Offset(width * 0.82, centerY);

        final double railOffset = scale.size(95, min: 70, max: 140);
        final double bottomY = centerY + railOffset;
        final double topY = centerY - railOffset;
        final double leftX = batteryPos.dx - scale.size(65, min: 50, max: 100);
        final double rightX = lampPos.dx + scale.size(65, min: 50, max: 100);

        final wires = <WirePath>[];

        if (_batteryInserted && _switchInserted) {
          final batTermA = ComponentPlacement(
                  position: batteryPos,
                  rotation: _batteryRotation,
                  type: ComponentType.battery)
              .getTerminalPosition(0);
          final switchTermA = ComponentPlacement(
                  position: switchPos,
                  rotation: _switchRotation,
                  type: ComponentType.switchComponent)
              .getTerminalPosition(0);
          final leftOfSwitch = switchPos.dx - scale.size(60, min: 45, max: 90);

          final intermediate = (_batteryRotation % 360 == 270.0)
              ? [
                  Offset(leftX, batTermA.dy),
                  Offset(leftX, bottomY),
                  Offset(leftOfSwitch, bottomY),
                  Offset(leftOfSwitch, switchTermA.dy),
                ]
              : null;

          wires.add(DynamicWirePath.fromComponents(
            compA: ComponentPlacement(
                position: batteryPos,
                rotation: _batteryRotation,
                type: ComponentType.battery),
            terminalIndexA: 0,
            compB: ComponentPlacement(
                position: switchPos,
                rotation: _switchRotation,
                type: ComponentType.switchComponent),
            terminalIndexB: 0,
            color: const Color(0xFFEF4444),
            isActive: _isClosed,
            thickness: scale.size(5.5, min: 4.5, max: 8.0),
          ).toWirePath(intermediatePoints: intermediate));
        }

        if (_switchInserted && _bulbInserted) {
          final switchTermB = ComponentPlacement(
                  position: switchPos,
                  rotation: _switchRotation,
                  type: ComponentType.switchComponent)
              .getTerminalPosition(1);
          final lampTermA = ComponentPlacement(
                  position: lampPos,
                  rotation: _bulbRotation,
                  type: ComponentType.bulb)
              .getTerminalPosition(0);
          final rightOfSwitch = switchPos.dx + scale.size(60, min: 45, max: 90);
          final bottomYBulb = centerY + (railOffset * 0.9);

          final intermediateOrange = [
            Offset(rightOfSwitch, switchTermB.dy),
            Offset(rightOfSwitch, bottomYBulb),
            Offset(lampTermA.dx, bottomYBulb),
          ];

          wires.add(DynamicWirePath.fromComponents(
            compA: ComponentPlacement(
                position: switchPos,
                rotation: _switchRotation,
                type: ComponentType.switchComponent),
            terminalIndexA: 1,
            compB: ComponentPlacement(
                position: lampPos,
                rotation: _bulbRotation,
                type: ComponentType.bulb),
            terminalIndexB: 0,
            color: const Color(0xFFF97316),
            isActive: _isClosed,
            thickness: scale.size(5.5, min: 4.5, max: 8.0),
          ).toWirePath(intermediatePoints: intermediateOrange));
        }

        if (_bulbInserted && _batteryInserted) {
          final bulbTermB = ComponentPlacement(
                  position: lampPos,
                  rotation: _bulbRotation,
                  type: ComponentType.bulb)
              .getTerminalPosition(1);
          final batTermB = ComponentPlacement(
                  position: batteryPos,
                  rotation: _batteryRotation,
                  type: ComponentType.battery)
              .getTerminalPosition(1);
          final bottomYBulb = centerY + (railOffset * 0.9);

          final intermediate = (_batteryRotation % 360 == 270.0)
              ? [
                  Offset(bulbTermB.dx, bottomYBulb),
                  Offset(rightX, bottomYBulb),
                  Offset(rightX, topY),
                  Offset(leftX, topY),
                  Offset(leftX, batTermB.dy),
                ]
              : [
                  Offset(bulbTermB.dx, bottomY),
                  Offset(batTermB.dx, bottomY),
                ];

          wires.add(DynamicWirePath.fromComponents(
            compA: ComponentPlacement(
                position: lampPos,
                rotation: _bulbRotation,
                type: ComponentType.bulb),
            terminalIndexA: 1,
            compB: ComponentPlacement(
                position: batteryPos,
                rotation: _batteryRotation,
                type: ComponentType.battery),
            terminalIndexB: 1,
            color: const Color(0xFF2563EB),
            isActive: _isClosed,
            thickness: scale.size(5.5, min: 4.5, max: 8.0),
          ).toWirePath(intermediatePoints: intermediate));
        }

        return Container(
          decoration: const BoxDecoration(color: Colors.transparent),
          child: Stack(
            children: [
              Positioned.fill(
                child: RealisticWireWidget(
                  wires: wires,
                  animationValue: _currentFlowController.value,
                  showElectrons: _isClosed,
                ),
              ),

              // Bateria
              Positioned(
                left: batteryPos.dx - halfComp,
                top: batteryPos.dy - halfComp,
                child: PhysicalBlueprintSocket<String>(
                  expectedData: 'battery',
                  isFilled: _batteryInserted,
                  showLabel: false,
                  rotation: _batteryRotation,
                  onAccept: (_) => _insertComponent(
                    name: 'Bateria M1',
                    getInserted: () => _batteryInserted,
                    setInserted: (v) => _batteryInserted = v,
                    getRotation: () => _batteryRotation,
                    setRotation: (v) => _batteryRotation = v,
                  ),
                  onRotate: () => _rotateComponent(
                    name: 'Bateria M1',
                    getRotation: () => _batteryRotation,
                    setRotation: (v) => _batteryRotation = v,
                  ),
                  onTap: () => _insertComponent(
                    name: 'Bateria M1',
                    getInserted: () => _batteryInserted,
                    setInserted: (v) => _batteryInserted = v,
                    getRotation: () => _batteryRotation,
                    setRotation: (v) => _batteryRotation = v,
                  ),
                  symbolWidget: CustomPaint(
                    size: Size(compSize, compSize),
                    painter: ComponentPhysicalPainter(
                      type: ComponentType.battery,
                      isActive: true,
                      isDarkMode: false,
                      value: 4.5,
                    ),
                  ),
                ),
              ),

              // Interruptor
              Positioned(
                left: switchPos.dx - halfComp,
                top: switchPos.dy - halfComp,
                child: PhysicalBlueprintSocket<String>(
                  expectedData: 'switch',
                  isFilled: _switchInserted,
                  showLabel: false,
                  rotation: _switchRotation,
                  onAccept: (_) => _insertComponent(
                    name: 'Chave SPST M1',
                    getInserted: () => _switchInserted,
                    setInserted: (v) => _switchInserted = v,
                    getRotation: () => _switchRotation,
                    setRotation: (v) => _switchRotation = v,
                  ),
                  onRotate: () => _rotateComponent(
                    name: 'Chave SPST M1',
                    getRotation: () => _switchRotation,
                    setRotation: (v) => _switchRotation = v,
                  ),
                  onTap: () {
                    if (_switchInserted) {
                      setState(() => _switchClosed = !_switchClosed);
                    } else {
                      _insertComponent(
                        name: 'Chave SPST M1',
                        getInserted: () => _switchInserted,
                        setInserted: (v) => _switchInserted = v,
                        getRotation: () => _switchRotation,
                        setRotation: (v) => _switchRotation = v,
                      );
                    }
                  },
                  symbolWidget: CustomPaint(
                    size: Size(compSize, compSize),
                    painter: ComponentPhysicalPainter(
                      type: ComponentType.switchComponent,
                      isActive: _switchClosed,
                      isDarkMode: false,
                    ),
                  ),
                ),
              ),

              // Lâmpada
              Positioned(
                left: lampPos.dx - halfComp,
                top: lampPos.dy - halfComp,
                child: PhysicalBlueprintSocket<String>(
                  expectedData: 'bulb',
                  isFilled: _bulbInserted,
                  showLabel: false,
                  rotation: _bulbRotation,
                  onAccept: (_) => _insertComponent(
                    name: 'Lâmpada M1',
                    getInserted: () => _bulbInserted,
                    setInserted: (v) => _bulbInserted = v,
                    getRotation: () => _bulbRotation,
                    setRotation: (v) => _bulbRotation = v,
                  ),
                  onRotate: () => _rotateComponent(
                    name: 'Lâmpada M1',
                    getRotation: () => _bulbRotation,
                    setRotation: (v) => _bulbRotation = v,
                  ),
                  onTap: () => _insertComponent(
                    name: 'Lâmpada M1',
                    getInserted: () => _bulbInserted,
                    setInserted: (v) => _bulbInserted = v,
                    getRotation: () => _bulbRotation,
                    setRotation: (v) => _bulbRotation = v,
                  ),
                  symbolWidget: CustomPaint(
                    size: Size(compSize, compSize),
                    painter: ComponentPhysicalPainter(
                      type: ComponentType.bulb,
                      isActive: _isClosed,
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
        final double height = constraints.maxHeight;
        final double batteryX = width * 0.18;
        final double lampX = width * 0.82;
        final double switchCenterX = width * 0.50;
        final double centerY = height * 0.50;

        return Container(
          height: height,
          decoration: const BoxDecoration(color: Colors.transparent),
          child: Stack(
            children: [
              CustomPaint(
                size: Size(width, height),
                painter: SchematicCircuitWirePainter(
                  isClosed: _isClosed,
                  animationValue: _currentFlowController.value,
                  switchInserted: _switchInserted,
                  wireColor: const Color(0xFF1E293B),
                ),
              ),

              // Bateria
              Positioned(
                left: batteryX - 47.5,
                top: centerY - 47.5,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'battery',
                  isFilled: _batteryInserted,
                  showLabel: false,
                  rotation: _batteryRotation,
                  onAccept: (_) => _insertComponent(
                    name: 'Bateria M1',
                    getInserted: () => _batteryInserted,
                    setInserted: (v) => _batteryInserted = v,
                    getRotation: () => _batteryRotation,
                    setRotation: (v) => _batteryRotation = v,
                  ),
                  onRotate: () => _rotateComponent(
                    name: 'Bateria M1',
                    getRotation: () => _batteryRotation,
                    setRotation: (v) => _batteryRotation = v,
                  ),
                  onTap: () {},
                  symbolWidget: CustomPaint(
                    size: const Size(60, 44),
                    painter: CircuitSymbolPainter(
                      type: ComponentType.battery,
                      color: const Color(0xFF0F172A),
                      strokeWidth: 2.2,
                    ),
                  ),
                  placeholderWidget: Opacity(
                    opacity: 0.4,
                    child: CustomPaint(
                      size: const Size(54, 38),
                      painter: CircuitSymbolPainter(
                        type: ComponentType.battery,
                        color: const Color(0xFF94A3B8),
                        strokeWidth: 2.0,
                      ),
                    ),
                  ),
                  label: '',
                ),
              ),

              // Lâmpada
              Positioned(
                left: lampX - 47.5,
                top: centerY - 47.5,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'bulb',
                  isFilled: _bulbInserted,
                  showLabel: false,
                  rotation: _bulbRotation,
                  onAccept: (_) => _insertComponent(
                    name: 'Lâmpada M1',
                    getInserted: () => _bulbInserted,
                    setInserted: (v) => _bulbInserted = v,
                    getRotation: () => _bulbRotation,
                    setRotation: (v) => _bulbRotation = v,
                  ),
                  onRotate: () => _rotateComponent(
                    name: 'Lâmpada M1',
                    getRotation: () => _bulbRotation,
                    setRotation: (v) => _bulbRotation = v,
                  ),
                  onTap: () {},
                  symbolWidget: CustomPaint(
                    size: const Size(60, 44),
                    painter: CircuitSymbolPainter(
                      type: ComponentType.bulb,
                      isActive: _isClosed,
                      color: const Color(0xFF0F172A),
                      activeColor: const Color(0xFFD97706),
                      strokeWidth: 2.2,
                    ),
                  ),
                  placeholderWidget: Opacity(
                    opacity: 0.4,
                    child: CustomPaint(
                      size: const Size(54, 38),
                      painter: CircuitSymbolPainter(
                        type: ComponentType.bulb,
                        color: const Color(0xFF94A3B8),
                        strokeWidth: 2.0,
                      ),
                    ),
                  ),
                  label: '',
                ),
              ),

              // Interruptor
              Positioned(
                left: switchCenterX - 47.5,
                top: centerY - 47.5,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'switch',
                  isFilled: _switchInserted,
                  showLabel: false,
                  rotation: _switchRotation,
                  onAccept: (_) => _insertComponent(
                    name: 'Chave SPST M1',
                    getInserted: () => _switchInserted,
                    setInserted: (v) => _switchInserted = v,
                    getRotation: () => _switchRotation,
                    setRotation: (v) => _switchRotation = v,
                  ),
                  onRotate: () => _rotateComponent(
                    name: 'Chave SPST M1',
                    getRotation: () => _switchRotation,
                    setRotation: (v) => _switchRotation = v,
                  ),
                  onTap: () {
                    if (_switchInserted) {
                      setState(() => _switchClosed = !_switchClosed);
                    }
                  },
                  symbolWidget: CustomPaint(
                    size: const Size(60, 44),
                    painter: CircuitSymbolPainter(
                      type: ComponentType.switchComponent,
                      isActive: _switchClosed,
                      color: const Color(0xFF0F172A),
                      strokeWidth: 2.2,
                    ),
                  ),
                  placeholderWidget: Opacity(
                    opacity: 0.4,
                    child: CustomPaint(
                      size: const Size(54, 38),
                      painter: CircuitSymbolPainter(
                        type: ComponentType.switchComponent,
                        color: const Color(0xFF94A3B8),
                        strokeWidth: 2.0,
                      ),
                    ),
                  ),
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
