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

/// Missão 4 do Estande 3 — Conferência e Correção (Ramo Inútil para Série).
class LigaDesligaM4 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const LigaDesligaM4({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<LigaDesligaM4> createState() => _LigaDesligaM4State();
}

class _LigaDesligaM4State extends State<LigaDesligaM4>
    with SingleTickerProviderStateMixin {
  final StandMission _mission = StandMission.estande3Missions[3];
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  bool _usePhysicalStyle = true;
  bool _switchInMainBranch = false;
  bool _switchClosed = true;
  bool _batteryInserted = true;
  bool _switchSeriesInserted = true;
  bool _lampInserted = true;
  double _batteryRotation = 270.0;
  double _switchSeriesRotation = 0.0;
  double _lampRotation = 0.0;

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

  bool get _isLampLit => _switchInMainBranch ? _switchClosed : true;

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
    if (!_switchInMainBranch) {
      _showFeedback(false, _mission.failureFeedback);
      return;
    }
    _showFeedback(
      true,
      'Excelente correção! Movendo o interruptor do ramo inútil para o ramo principal em série, a chave agora interrompe a corrente da lâmpada.',
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
            leftHeaderWidget: buildLigaDesligaStatusCard(_isLampLit),
            rightHeaderWidget: buildLigaDesligaTelemetryCard(
              4.5,
              _isLampLit ? 90.0 : 0.0,
              _isLampLit,
            ),
            bottomWidget: _buildUndoRedoButtons(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    'Observe o circuito com erro: o interruptor está em um ramo paralelo inútil. Clique ou arraste o interruptor para o soquete central em série!',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      shadows: const [
                        Shadow(
                          color: Colors.black45,
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
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
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Painel Lateral (Briefing, Toolbox & Validação)
        Expanded(
          flex: 3,
          child: WorkbenchSidePanel(
            teamTitle: 'Painel da Equipe Controle',
            toolboxItems: [
              _buildMissionBriefingCard(),
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
              const Icon(Icons.task_alt_rounded,
                  color: Color(0xFF0284C7), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Missão 4: ${_mission.title}',
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

  Widget _buildSideToolboxDrawer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
          child: Text(
            'Componentes:',
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
              data: 'switch',
              label: 'Chave SPST',
              tooltip: 'Interruptor Liga/Desliga',
              symbolWidget: _usePhysicalStyle
                  ? CustomPaint(
                      size: const Size(44, 44),
                      painter: ComponentPhysicalPainter(
                        type: ComponentType.switchComponent,
                        isActive: true,
                        isDarkMode: false,
                      ),
                    )
                  : CustomPaint(
                      size: const Size(40, 30),
                      painter: CircuitSymbolPainter(
                        type: ComponentType.switchComponent,
                        isActive: true,
                        color: const Color(0xFF0F172A),
                        strokeWidth: 2.2,
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhysicalCanvas() {
    final bool isLampLit = _batteryInserted &&
        _lampInserted &&
        _switchSeriesInserted &&
        (!_switchInMainBranch || _switchClosed);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        const double height = 250.0;

        final double centerY = 135.0;
        final batteryPos = Offset(width * 0.18, centerY);
        final switchInutilityPos = Offset(width * 0.50, 65.0);
        final switchSeriesPos = Offset(width * 0.50, centerY);
        final lampPos = Offset(width * 0.82, centerY);

        final wires = <WirePath>[];

        if (_batteryInserted && _lampInserted) {
          final batTermA = ComponentPlacement(
            position: batteryPos,
            rotation: _batteryRotation,
            type: ComponentType.battery,
          ).getTerminalPosition(0);
          final batTermB = ComponentPlacement(
            position: batteryPos,
            rotation: _batteryRotation,
            type: ComponentType.battery,
          ).getTerminalPosition(1);
          final lampTermA = ComponentPlacement(
            position: lampPos,
            rotation: _lampRotation,
            type: ComponentType.bulb,
          ).getTerminalPosition(0);
          final lampTermB = ComponentPlacement(
            position: lampPos,
            rotation: _lampRotation,
            type: ComponentType.bulb,
          ).getTerminalPosition(1);

          final rightX = lampPos.dx + 70.0;
          final leftX = batteryPos.dx - 70.0;
          const topY = 10.0;
          const bottomYBulb = 195.0;
          const bottomY = 195.0;

          if (_switchInMainBranch) {
            if (_switchSeriesInserted) {
              final switchSeriesTermA = ComponentPlacement(
                position: switchSeriesPos,
                rotation: _switchSeriesRotation,
                type: ComponentType.switchComponent,
              ).getTerminalPosition(0);
              final switchSeriesTermB = ComponentPlacement(
                position: switchSeriesPos,
                rotation: _switchSeriesRotation,
                type: ComponentType.switchComponent,
              ).getTerminalPosition(1);
              final leftOfSwitch = switchSeriesPos.dx - 65.0;
              final rightOfSwitch = switchSeriesPos.dx + 65.0;

              final intermediateRed = [
                Offset(leftX, batTermA.dy),
                Offset(leftX, bottomY),
                Offset(leftOfSwitch, bottomY),
                Offset(leftOfSwitch, switchSeriesTermA.dy),
              ];

              wires.add(DynamicWirePath.fromComponents(
                compA: ComponentPlacement(
                  position: batteryPos,
                  rotation: _batteryRotation,
                  type: ComponentType.battery,
                ),
                terminalIndexA: 0,
                compB: ComponentPlacement(
                  position: switchSeriesPos,
                  rotation: _switchSeriesRotation,
                  type: ComponentType.switchComponent,
                ),
                terminalIndexB: 0,
                color: const Color(0xFFEF4444),
                isActive: isLampLit,
                thickness: 4.0,
              ).toWirePath(intermediatePoints: intermediateRed));

              final intermediateGreen = [
                Offset(rightOfSwitch, switchSeriesTermB.dy),
                Offset(rightOfSwitch, bottomYBulb),
                Offset(lampTermA.dx, bottomYBulb),
              ];

              wires.add(DynamicWirePath.fromComponents(
                compA: ComponentPlacement(
                  position: switchSeriesPos,
                  rotation: _switchSeriesRotation,
                  type: ComponentType.switchComponent,
                ),
                terminalIndexA: 1,
                compB: ComponentPlacement(
                  position: lampPos,
                  rotation: _lampRotation,
                  type: ComponentType.bulb,
                ),
                terminalIndexB: 0,
                color: const Color(0xFF10B981),
                isActive: isLampLit,
                thickness: 4.0,
              ).toWirePath(intermediatePoints: intermediateGreen));
            }
          } else {
            final intermediateRedDirect = [
              Offset(leftX, batTermA.dy),
              Offset(leftX, bottomY),
              Offset(lampTermA.dx, bottomY),
            ];

            wires.add(DynamicWirePath.fromComponents(
              compA: ComponentPlacement(
                position: batteryPos,
                rotation: _batteryRotation,
                type: ComponentType.battery,
              ),
              terminalIndexA: 0,
              compB: ComponentPlacement(
                position: lampPos,
                rotation: _lampRotation,
                type: ComponentType.bulb,
              ),
              terminalIndexB: 0,
              color: const Color(0xFFEF4444),
              isActive: isLampLit,
              thickness: 4.0,
            ).toWirePath(intermediatePoints: intermediateRedDirect));

            if (_switchSeriesInserted) {
              final switchInutilityTermA = ComponentPlacement(
                position: switchInutilityPos,
                rotation: _switchSeriesRotation,
                type: ComponentType.switchComponent,
              ).getTerminalPosition(0);
              final switchInutilityTermB = ComponentPlacement(
                position: switchInutilityPos,
                rotation: _switchSeriesRotation,
                type: ComponentType.switchComponent,
              ).getTerminalPosition(1);
              final leftOfTopSwitch = switchInutilityPos.dx - 65.0;
              final rightOfTopSwitch = switchInutilityPos.dx + 65.0;

              final intermediateYellowA = [
                Offset(leftX, batTermA.dy),
                Offset(leftX, 65.0),
                Offset(leftOfTopSwitch, 65.0),
                Offset(leftOfTopSwitch, switchInutilityTermA.dy),
              ];

              wires.add(DynamicWirePath.fromComponents(
                compA: ComponentPlacement(
                  position: batteryPos,
                  rotation: _batteryRotation,
                  type: ComponentType.battery,
                ),
                terminalIndexA: 0,
                compB: ComponentPlacement(
                  position: switchInutilityPos,
                  rotation: _switchSeriesRotation,
                  type: ComponentType.switchComponent,
                ),
                terminalIndexB: 0,
                color: const Color(0xFFEAB308),
                isActive: _switchClosed,
                thickness: 3.5,
              ).toWirePath(intermediatePoints: intermediateYellowA));

              final intermediateYellowB = [
                Offset(rightOfTopSwitch, switchInutilityTermB.dy),
                Offset(rightOfTopSwitch, 65.0),
                Offset(lampTermA.dx, 65.0),
              ];

              wires.add(DynamicWirePath.fromComponents(
                compA: ComponentPlacement(
                  position: switchInutilityPos,
                  rotation: _switchSeriesRotation,
                  type: ComponentType.switchComponent,
                ),
                terminalIndexA: 1,
                compB: ComponentPlacement(
                  position: lampPos,
                  rotation: _lampRotation,
                  type: ComponentType.bulb,
                ),
                terminalIndexB: 0,
                color: const Color(0xFFEAB308),
                isActive: _switchClosed,
                thickness: 3.5,
              ).toWirePath(intermediatePoints: intermediateYellowB));
            }
          }

          final intermediateReturn = [
            Offset(lampTermB.dx, topY + 15.0),
            Offset(rightX, topY + 15.0),
            Offset(rightX, topY),
            Offset(leftX, topY),
            Offset(leftX, batTermB.dy),
          ];

          wires.add(DynamicWirePath.fromComponents(
            compA: ComponentPlacement(
              position: lampPos,
              rotation: _lampRotation,
              type: ComponentType.bulb,
            ),
            terminalIndexA: 1,
            compB: ComponentPlacement(
              position: batteryPos,
              rotation: _batteryRotation,
              type: ComponentType.battery,
            ),
            terminalIndexB: 1,
            color: const Color(0xFF2563EB),
            isActive: isLampLit,
            thickness: 4.0,
          ).toWirePath(intermediatePoints: intermediateReturn));
        }

        return Container(
          height: height,
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: RealisticWireWidget(
                  wires: wires,
                  animationValue: _currentFlowController.value,
                  showElectrons: isLampLit,
                ),
              ),

              // Socket Bateria
              Positioned(
                left: batteryPos.dx - 47.5,
                top: batteryPos.dy - 47.5,
                child: PhysicalBlueprintSocket<String>(
                  expectedData: 'battery',
                  isFilled: _batteryInserted,
                  showLabel: false,
                  rotation: _batteryRotation,
                  onAccept: (_) => _insertComponent(
                    name: 'Bateria M4',
                    getInserted: () => _batteryInserted,
                    setInserted: (v) => _batteryInserted = v,
                    getRotation: () => _batteryRotation,
                    setRotation: (v) => _batteryRotation = v,
                  ),
                  onRotate: () => _rotateComponent(
                    name: 'Bateria M4',
                    getRotation: () => _batteryRotation,
                    setRotation: (v) => _batteryRotation = v,
                  ),
                  onTap: () {},
                  symbolWidget: CustomPaint(
                    size: const Size(80, 80),
                    painter: ComponentPhysicalPainter(
                      type: ComponentType.battery,
                      isActive: true,
                      isDarkMode: false,
                      value: 4.5,
                    ),
                  ),
                ),
              ),

              // Posicionamento A: Ramo Inútil (Topo)
              Positioned(
                left: switchInutilityPos.dx - 47.5,
                top: switchInutilityPos.dy - 47.5,
                child: PhysicalBlueprintSocket<String>(
                  expectedData: 'switch',
                  isFilled: _switchSeriesInserted && !_switchInMainBranch,
                  showLabel: false,
                  rotation: _switchSeriesRotation,
                  accentColor: !_switchInMainBranch
                      ? const Color(0xFFD97706)
                      : const Color(0xFF94A3B8),
                  onAccept: (_) {
                    final prevInserted = _switchSeriesInserted;
                    final prevInMain = _switchInMainBranch;
                    final prevClosed = _switchClosed;
                    _undoRedoController.execute(CompoundAction(
                      description: 'Inserir no Ramo Inútil M4',
                      actions: [
                        InsertComponentAction(
                          description: 'Inserir Interruptor',
                          onApply: () => setState(() {
                            _switchSeriesInserted = true;
                            _switchInMainBranch = false;
                            _switchClosed = true;
                          }),
                          onUndo: () => setState(() {
                            _switchSeriesInserted = prevInserted;
                            _switchInMainBranch = prevInMain;
                            _switchClosed = prevClosed;
                          }),
                        ),
                      ],
                    ));
                  },
                  onRotate: () => _rotateComponent(
                    name: 'Interruptor M4',
                    getRotation: () => _switchSeriesRotation,
                    setRotation: (v) => _switchSeriesRotation = v,
                  ),
                  onTap: () {
                    if (_switchSeriesInserted && !_switchInMainBranch) {
                      final prev = _switchClosed;
                      _undoRedoController.execute(ToggleBoolAction(
                        description: 'Toggle Interruptor M4',
                        onApply: () => setState(() => _switchClosed = !prev),
                        onUndo: () => setState(() => _switchClosed = prev),
                      ));
                    } else {
                      final prevInMain = _switchInMainBranch;
                      _undoRedoController.execute(ToggleBoolAction(
                        description: 'Mover para Ramo Inútil M4',
                        onApply: () => setState(() {
                          _switchSeriesInserted = true;
                          _switchInMainBranch = false;
                        }),
                        onUndo: () =>
                            setState(() => _switchInMainBranch = prevInMain),
                      ));
                    }
                  },
                  symbolWidget: CustomPaint(
                    size: const Size(80, 70),
                    painter: ComponentPhysicalPainter(
                      type: ComponentType.switchComponent,
                      isActive: _switchClosed,
                      isDarkMode: false,
                    ),
                  ),
                ),
              ),

              // Posicionamento B: Ramo Principal em Série (Centro)
              Positioned(
                left: switchSeriesPos.dx - 47.5,
                top: switchSeriesPos.dy - 47.5,
                child: PhysicalBlueprintSocket<String>(
                  expectedData: 'switch',
                  isFilled: _switchSeriesInserted && _switchInMainBranch,
                  showLabel: false,
                  rotation: _switchSeriesRotation,
                  accentColor: _switchInMainBranch
                      ? const Color(0xFF059669)
                      : const Color(0xFF94A3B8),
                  onAccept: (_) {
                    final prevInserted = _switchSeriesInserted;
                    final prevInMain = _switchInMainBranch;
                    final prevClosed = _switchClosed;
                    _undoRedoController.execute(CompoundAction(
                      description: 'Inserir no Ramo Principal M4',
                      actions: [
                        InsertComponentAction(
                          description: 'Inserir Interruptor',
                          onApply: () => setState(() {
                            _switchSeriesInserted = true;
                            _switchInMainBranch = true;
                            _switchClosed = true;
                          }),
                          onUndo: () => setState(() {
                            _switchSeriesInserted = prevInserted;
                            _switchInMainBranch = prevInMain;
                            _switchClosed = prevClosed;
                          }),
                        ),
                      ],
                    ));
                  },
                  onRotate: () => _rotateComponent(
                    name: 'Interruptor M4',
                    getRotation: () => _switchSeriesRotation,
                    setRotation: (v) => _switchSeriesRotation = v,
                  ),
                  onTap: () {
                    if (_switchSeriesInserted && _switchInMainBranch) {
                      final prev = _switchClosed;
                      _undoRedoController.execute(ToggleBoolAction(
                        description: 'Toggle Interruptor M4',
                        onApply: () => setState(() => _switchClosed = !prev),
                        onUndo: () => setState(() => _switchClosed = prev),
                      ));
                    } else {
                      final prevInMain = _switchInMainBranch;
                      _undoRedoController.execute(ToggleBoolAction(
                        description: 'Mover para Ramo Principal M4',
                        onApply: () => setState(() {
                          _switchSeriesInserted = true;
                          _switchInMainBranch = true;
                        }),
                        onUndo: () =>
                            setState(() => _switchInMainBranch = prevInMain),
                      ));
                    }
                  },
                  symbolWidget: CustomPaint(
                    size: const Size(80, 70),
                    painter: ComponentPhysicalPainter(
                      type: ComponentType.switchComponent,
                      isActive: _switchClosed,
                      isDarkMode: false,
                    ),
                  ),
                ),
              ),

              // Socket Lâmpada
              Positioned(
                left: lampPos.dx - 47.5,
                top: lampPos.dy - 47.5,
                child: PhysicalBlueprintSocket<String>(
                  expectedData: 'bulb',
                  isFilled: _lampInserted,
                  showLabel: false,
                  rotation: _lampRotation,
                  onAccept: (_) => _insertComponent(
                    name: 'Lâmpada M4',
                    getInserted: () => _lampInserted,
                    setInserted: (v) => _lampInserted = v,
                    getRotation: () => _lampRotation,
                    setRotation: (v) => _lampRotation = v,
                  ),
                  onRotate: () => _rotateComponent(
                    name: 'Lâmpada M4',
                    getRotation: () => _lampRotation,
                    setRotation: (v) => _lampRotation = v,
                  ),
                  onTap: () {},
                  symbolWidget: CustomPaint(
                    size: const Size(80, 80),
                    painter: ComponentPhysicalPainter(
                      type: ComponentType.bulb,
                      isActive: isLampLit,
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
    final bool isLampLit = _switchInMainBranch ? _switchClosed : true;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        const double height = 270.0;
        final double batteryX = width * 0.18;
        final double lampX = width * 0.82;
        final double switchCenterX = width * 0.50;
        final double centerY = height * 0.50;

        return Container(
          height: height,
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: Stack(
            children: [
              CustomPaint(
                size: Size(width, height),
                painter: SchematicCircuitWirePainterM4(
                  isClosed: isLampLit,
                  switchInMainBranch: _switchInMainBranch,
                  animationValue: _currentFlowController.value,
                ),
              ),

              // Bateria Card
              Positioned(
                left: batteryX - 47.5,
                top: centerY - 47.5,
                child: SchematicComponentCard(
                  label: '',
                  showLabel: false,
                  symbolWidget: CustomPaint(
                    size: const Size(54, 38),
                    painter: CircuitSymbolPainter(
                      type: ComponentType.battery,
                      color: const Color(0xFF0F172A),
                      strokeWidth: 2.2,
                    ),
                  ),
                ),
              ),

              // Lâmpada Card
              Positioned(
                left: lampX - 47.5,
                top: centerY - 47.5,
                child: SchematicComponentCard(
                  label: '',
                  showLabel: false,
                  isActive: isLampLit,
                  symbolWidget: CustomPaint(
                    size: const Size(54, 38),
                    painter: CircuitSymbolPainter(
                      type: ComponentType.bulb,
                      isActive: isLampLit,
                      color: const Color(0xFF0F172A),
                      activeColor: const Color(0xFFD97706),
                      strokeWidth: 2.2,
                    ),
                  ),
                ),
              ),

              // Posicionamento A: Ramo Inútil (Topo)
              Positioned(
                left: switchCenterX - 47.5,
                top: (centerY - 55.0) - 47.5,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'switch',
                  isFilled: !_switchInMainBranch,
                  showLabel: false,
                  accentColor: !_switchInMainBranch
                      ? const Color(0xFFD97706)
                      : const Color(0xFF94A3B8),
                  onAccept: (_) {
                    final prevInMain = _switchInMainBranch;
                    final prevClosed = _switchClosed;
                    _undoRedoController.execute(CompoundAction(
                      description: 'Inserir no Ramo Inútil M4',
                      actions: [
                        ToggleBoolAction(
                          description: 'Mover para Ramo Inútil',
                          onApply: () =>
                              setState(() => _switchInMainBranch = false),
                          onUndo: () =>
                              setState(() => _switchInMainBranch = prevInMain),
                        ),
                        ToggleBoolAction(
                          description: 'Fechar Interruptor',
                          onApply: () => setState(() => _switchClosed = true),
                          onUndo: () =>
                              setState(() => _switchClosed = prevClosed),
                        ),
                      ],
                    ));
                  },
                  onTap: () {
                    if (!_switchInMainBranch) {
                      final prev = _switchClosed;
                      _undoRedoController.execute(ToggleBoolAction(
                        description: 'Toggle Interruptor M4',
                        onApply: () => setState(() => _switchClosed = !prev),
                        onUndo: () => setState(() => _switchClosed = prev),
                      ));
                    } else {
                      final prevInMain = _switchInMainBranch;
                      _undoRedoController.execute(ToggleBoolAction(
                        description: 'Mover para Ramo Inútil M4',
                        onApply: () =>
                              setState(() => _switchInMainBranch = false),
                        onUndo: () =>
                              setState(() => _switchInMainBranch = prevInMain),
                      ));
                    }
                  },
                  symbolWidget: CustomPaint(
                    size: const Size(54, 38),
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
                      size: const Size(48, 34),
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

              // Posicionamento B: Ramo Principal em Série (Centro)
              Positioned(
                left: switchCenterX - 47.5,
                top: centerY - 47.5,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'switch',
                  isFilled: _switchInMainBranch,
                  showLabel: false,
                  accentColor: _switchInMainBranch
                      ? const Color(0xFF059669)
                      : const Color(0xFF94A3B8),
                  onAccept: (_) {
                    final prevInMain = _switchInMainBranch;
                    final prevClosed = _switchClosed;
                    _undoRedoController.execute(CompoundAction(
                      description: 'Inserir no Ramo Principal M4',
                      actions: [
                        ToggleBoolAction(
                          description: 'Mover para Ramo Principal',
                          onApply: () =>
                              setState(() => _switchInMainBranch = true),
                          onUndo: () =>
                              setState(() => _switchInMainBranch = prevInMain),
                        ),
                        ToggleBoolAction(
                          description: 'Fechar Interruptor',
                          onApply: () => setState(() => _switchClosed = true),
                          onUndo: () =>
                              setState(() => _switchClosed = prevClosed),
                        ),
                      ],
                    ));
                  },
                  onTap: () {
                    if (_switchInMainBranch) {
                      final prev = _switchClosed;
                      _undoRedoController.execute(ToggleBoolAction(
                        description: 'Toggle Interruptor M4',
                        onApply: () => setState(() => _switchClosed = !prev),
                        onUndo: () => setState(() => _switchClosed = prev),
                      ));
                    } else {
                      final prevInMain = _switchInMainBranch;
                      _undoRedoController.execute(ToggleBoolAction(
                        description: 'Mover para Ramo Principal M4',
                        onApply: () =>
                              setState(() => _switchInMainBranch = true),
                        onUndo: () =>
                              setState(() => _switchInMainBranch = prevInMain),
                      ));
                    }
                  },
                  symbolWidget: CustomPaint(
                    size: const Size(54, 38),
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
                      size: const Size(48, 34),
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
