import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

/// Missão 5 do Estande 3 — Controle por Push-Button.
class LigaDesligaM5 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const LigaDesligaM5({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<LigaDesligaM5> createState() => _LigaDesligaM5State();
}

class _LigaDesligaM5State extends State<LigaDesligaM5>
    with SingleTickerProviderStateMixin {
  final StandMission _mission = StandMission.estande3Missions[4];
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  bool _usePhysicalStyle = true;
  bool _pushButtonInserted = false;
  bool _pushButtonPressed = false;
  bool _testedHoldAndRelease = false;
  bool _batteryInserted = true;
  bool _lampInserted = true;
  double _batteryRotation = 270.0;
  double _pushButtonRotation = 0.0;
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

  bool get _isLit =>
      _batteryInserted &&
      _pushButtonInserted &&
      _pushButtonPressed &&
      _lampInserted;

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
    if (!_pushButtonInserted) {
      _showFeedback(
        false,
        'Instale o interruptor do tipo push-button no circuito!',
      );
      return;
    }
    if (_testedHoldAndRelease) {
      _showFeedback(
        true,
        'Excelente! O push-button só mantém a luz acesa enquanto o visitante o mantém pressionado.',
      );
    } else {
      _showFeedback(
        false,
        'Mantenha o push-button pressionado para acender a luminária e solte em seguida antes de validar.',
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
            leftHeaderWidget: buildLigaDesligaStatusCard(_isLit),
            rightHeaderWidget: buildLigaDesligaTelemetryCard(
              4.5,
              _isLit ? 90.0 : 0.0,
              _isLit,
            ),
            bottomWidget: _buildUndoRedoButtons(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    'Arraste o Push-Button para a bancada e mantenha pressionado para testar o acionamento momentâneo:',
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
                const SizedBox(height: 10),
                if (_pushButtonInserted)
                  Center(
                    child: GestureDetector(
                      onTapDown: (_) {
                        setState(() {
                          _pushButtonPressed = true;
                          _testedHoldAndRelease = true;
                        });
                      },
                      onTapUp: (_) {
                        setState(() {
                          _pushButtonPressed = false;
                        });
                      },
                      onTapCancel: () {
                        setState(() {
                          _pushButtonPressed = false;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: _pushButtonPressed
                              ? const Color(0xFF0284C7)
                              : const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: (_pushButtonPressed
                                      ? const Color(0xFF0284C7)
                                      : const Color(0xFF0F172A))
                                  .withValues(alpha: 0.25),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _pushButtonPressed
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.touch_app_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _pushButtonPressed
                                  ? 'CONTATO PRESSIONADO (FECHADO)'
                                  : 'SEGURE PARA PRESSIONAR O BOTÃO',
                              style: GoogleFonts.rajdhani(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Painel Lateral (Briefing, Toolbox & Validação)
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
    if (!_pushButtonInserted) return 0;
    if (!_pushButtonPressed && !_testedHoldAndRelease) return 1;
    return 2;
  }

  bool _isStepCompleted(int index) {
    if (index == 0) return _pushButtonInserted;
    if (index == 1) {
      return _pushButtonInserted &&
          (_pushButtonPressed || _testedHoldAndRelease);
    }
    if (index == 2) return _testedHoldAndRelease;
    return false;
  }

  Widget _buildMissionObjectiveCard() {
    return WorkbenchMissionObjectiveCard(
      missionNumber: 5,
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
        'Inserir push-button no circuito',
        'Pressionar para acender a lâmpada',
        'Soltar e comprovar retorno automático',
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
              data: 'push_button',
              label: 'Push-Button',
              tooltip: 'Botão Momentâneo',
              symbolWidget: _usePhysicalStyle
                  ? const PushButtonVectorWidget(
                      size: 44,
                      isPressed: false,
                    )
                  : const SchematicSwitchWidget(
                      size: 40,
                      isPushButton: true,
                      isClosed: false,
                      color: Color(0xFF0F172A),
                    ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhysicalCanvas() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;
        final double centerY = height * 0.50;
        final double deltaY = (height * 0.28).clamp(45.0, 90.0);
        final double bottomY = centerY + deltaY;
        final double topY = centerY - deltaY;

        final batteryPos = Offset(width * 0.18, centerY);
        final pushButtonPos = Offset(width * 0.50, centerY);
        final lampPos = Offset(width * 0.82, centerY);

        final double socketSize = (width * 0.16).clamp(80.0, 110.0);
        final double halfSocket = socketSize / 2;

        final wires = <WirePath>[];

        if (_batteryInserted && _pushButtonInserted) {
          final batTermA = ComponentPlacement(
            position: batteryPos,
            rotation: _batteryRotation,
            type: ComponentType.battery,
          ).getTerminalPosition(0);
          final pushButtonTermA = ComponentPlacement(
            position: pushButtonPos,
            rotation: _pushButtonRotation,
            type: ComponentType.switchComponent,
          ).getTerminalPosition(0);
          final leftX = batteryPos.dx - 70.0;
          final leftOfButton = pushButtonPos.dx - 65.0;

          final intermediateRed = [
            Offset(leftX, batTermA.dy),
            Offset(leftX, bottomY),
            Offset(leftOfButton, bottomY),
            Offset(leftOfButton, pushButtonTermA.dy),
          ];

          wires.add(DynamicWirePath.fromComponents(
            compA: ComponentPlacement(
              position: batteryPos,
              rotation: _batteryRotation,
              type: ComponentType.battery,
            ),
            terminalIndexA: 0,
            compB: ComponentPlacement(
              position: pushButtonPos,
              rotation: _pushButtonRotation,
              type: ComponentType.switchComponent,
            ),
            terminalIndexB: 0,
            color: const Color(0xFFEF4444),
            isActive: _isLit,
            thickness: 5.2,
          ).toWirePath(intermediatePoints: intermediateRed));
        }

        if (_pushButtonInserted && _lampInserted) {
          final pushButtonTermB = ComponentPlacement(
            position: pushButtonPos,
            rotation: _pushButtonRotation,
            type: ComponentType.switchComponent,
          ).getTerminalPosition(1);
          final lampTermA = ComponentPlacement(
            position: lampPos,
            rotation: _lampRotation,
            type: ComponentType.bulb,
          ).getTerminalPosition(0);
          final rightOfButton = pushButtonPos.dx + 65.0;

          final intermediateOrange = [
            Offset(rightOfButton, pushButtonTermB.dy),
            Offset(rightOfButton, bottomY),
            Offset(lampTermA.dx, bottomY),
          ];

          wires.add(DynamicWirePath.fromComponents(
            compA: ComponentPlacement(
              position: pushButtonPos,
              rotation: _pushButtonRotation,
              type: ComponentType.switchComponent,
            ),
            terminalIndexA: 1,
            compB: ComponentPlacement(
              position: lampPos,
              rotation: _lampRotation,
              type: ComponentType.bulb,
            ),
            terminalIndexB: 0,
            color: const Color(0xFFF97316),
            isActive: _isLit,
            thickness: 5.2,
          ).toWirePath(intermediatePoints: intermediateOrange));
        }

        if (_lampInserted && _batteryInserted) {
          final lampTerm = ComponentPlacement(
            position: lampPos,
            rotation: _lampRotation,
            type: ComponentType.bulb,
          ).getTerminalPosition(1);
          final batTerm = ComponentPlacement(
            position: batteryPos,
            rotation: _batteryRotation,
            type: ComponentType.battery,
          ).getTerminalPosition(1);
          final rightX = lampPos.dx + 70.0;
          final leftX = batteryPos.dx - 70.0;

          final intermediateReturn = [
            Offset(lampTerm.dx, bottomY),
            Offset(rightX, bottomY),
            Offset(rightX, topY),
            Offset(leftX, topY),
            Offset(leftX, batTerm.dy),
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
            isActive: _isLit,
            thickness: 5.0,
          ).toWirePath(intermediatePoints: intermediateReturn));
        }

        return Stack(
          children: [
            Positioned.fill(
              child: RealisticWireWidget(
                wires: wires,
                animationValue: _currentFlowController.value,
                showElectrons: _isLit,
              ),
            ),

            // Socket Bateria
            Positioned(
              left: batteryPos.dx - halfSocket,
              top: batteryPos.dy - halfSocket,
              child: PhysicalBlueprintSocket<String>(
                expectedData: 'battery',
                isFilled: _batteryInserted,
                showLabel: false,
                rotation: _batteryRotation,
                onAccept: (_) => _insertComponent(
                  name: 'Bateria M5',
                  getInserted: () => _batteryInserted,
                  setInserted: (v) => _batteryInserted = v,
                  getRotation: () => _batteryRotation,
                  setRotation: (v) => _batteryRotation = v,
                ),
                onRotate: () => _rotateComponent(
                  name: 'Bateria M5',
                  getRotation: () => _batteryRotation,
                  setRotation: (v) => _batteryRotation = v,
                ),
                onTap: () {},
                symbolWidget: CustomPaint(
                  size: Size(socketSize * 0.85, socketSize * 0.85),
                  painter: ComponentPhysicalPainter(
                    type: ComponentType.battery,
                    isActive: true,
                    isDarkMode: false,
                    value: 4.5,
                  ),
                ),
              ),
            ),

            // Socket Push-Button
            Positioned(
              left: pushButtonPos.dx - halfSocket,
              top: pushButtonPos.dy - halfSocket,
              child: PhysicalBlueprintSocket<String>(
                expectedData: 'push_button',
                isFilled: _pushButtonInserted,
                showLabel: false,
                rotation: _pushButtonRotation,
                onAccept: (_) => _insertComponent(
                  name: 'Botão M5',
                  getInserted: () => _pushButtonInserted,
                  setInserted: (v) => _pushButtonInserted = v,
                  getRotation: () => _pushButtonRotation,
                  setRotation: (v) => _pushButtonRotation = v,
                ),
                onRotate: () => _rotateComponent(
                  name: 'Botão M5',
                  getRotation: () => _pushButtonRotation,
                  setRotation: (v) => _pushButtonRotation = v,
                ),
                onTap: () {
                  if (_pushButtonInserted) {
                    final prev = _pushButtonPressed;
                    _undoRedoController.execute(ToggleBoolAction(
                      description: 'Pressionar Botão M5',
                      onApply: () => setState(() {
                        _pushButtonPressed = !prev;
                        _testedHoldAndRelease = true;
                      }),
                      onUndo: () => setState(() {
                        _pushButtonPressed = prev;
                      }),
                    ));
                  }
                },
                symbolWidget: PushButtonVectorWidget(
                  size: socketSize * 0.70,
                  isPressed: _pushButtonPressed,
                ),
              ),
            ),

            // Socket Lâmpada
            Positioned(
              left: lampPos.dx - halfSocket,
              top: lampPos.dy - halfSocket,
              child: PhysicalBlueprintSocket<String>(
                expectedData: 'bulb',
                isFilled: _lampInserted,
                showLabel: false,
                rotation: _lampRotation,
                onAccept: (_) => _insertComponent(
                  name: 'Lâmpada M5',
                  getInserted: () => _lampInserted,
                  setInserted: (v) => _lampInserted = v,
                  getRotation: () => _lampRotation,
                  setRotation: (v) => _lampRotation = v,
                ),
                onRotate: () => _rotateComponent(
                  name: 'Lâmpada M5',
                  getRotation: () => _lampRotation,
                  setRotation: (v) => _lampRotation = v,
                ),
                onTap: () {},
                symbolWidget: CustomPaint(
                  size: Size(socketSize * 0.85, socketSize * 0.85),
                  painter: ComponentPhysicalPainter(
                    type: ComponentType.bulb,
                    isActive: _isLit,
                    isDarkMode: false,
                  ),
                ),
              ),
            ),
          ],
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

        final double cardSize = (width * 0.16).clamp(75.0, 105.0);
        final double halfCard = cardSize / 2;

        return Stack(
          children: [
            CustomPaint(
              size: Size(width, height),
              painter: SchematicCircuitWirePainter(
                isClosed: _isLit,
                animationValue: _currentFlowController.value,
                switchInserted: _pushButtonInserted,
                wireColor: const Color(0xFF1E293B),
              ),
            ),

            // Bateria em Card
            Positioned(
              left: batteryX - halfCard,
              top: centerY - halfCard,
              child: SchematicComponentCard(
                label: '',
                showLabel: false,
                symbolWidget: CustomPaint(
                  size: Size(cardSize * 0.65, cardSize * 0.48),
                  painter: CircuitSymbolPainter(
                    type: ComponentType.battery,
                    color: const Color(0xFF0F172A),
                    strokeWidth: 2.2,
                  ),
                ),
              ),
            ),

            // Lâmpada em Card
            Positioned(
              left: lampX - halfCard,
              top: centerY - halfCard,
              child: SchematicComponentCard(
                label: '',
                showLabel: false,
                isActive: _isLit,
                symbolWidget: CustomPaint(
                  size: Size(cardSize * 0.65, cardSize * 0.48),
                  painter: CircuitSymbolPainter(
                    type: ComponentType.bulb,
                    isActive: _isLit,
                    color: const Color(0xFF0F172A),
                    activeColor: const Color(0xFFD97706),
                    strokeWidth: 2.2,
                  ),
                ),
              ),
            ),

            // Soquete do Push-Button
            Positioned(
              left: switchCenterX - halfCard,
              top: centerY - halfCard,
              child: SchematicBlueprintSocket<String>(
                expectedData: 'push_button',
                isFilled: _pushButtonInserted,
                showLabel: false,
                onAccept: (_) => _insertComponent(
                  name: 'Botão M5',
                  getInserted: () => _pushButtonInserted,
                  setInserted: (v) => _pushButtonInserted = v,
                  getRotation: () => _pushButtonRotation,
                  setRotation: (v) => _pushButtonRotation = v,
                ),
                onTap: () {
                  if (_pushButtonInserted) {
                    final prev = _pushButtonPressed;
                    _undoRedoController.execute(ToggleBoolAction(
                      description: 'Pressionar Botão M5',
                      onApply: () => setState(() {
                        _pushButtonPressed = !prev;
                        _testedHoldAndRelease = true;
                      }),
                      onUndo: () => setState(() {
                        _pushButtonPressed = prev;
                      }),
                    ));
                  }
                },
                symbolWidget: SchematicSwitchWidget(
                  size: cardSize * 0.55,
                  isPushButton: true,
                  isClosed: _pushButtonPressed,
                  color: const Color(0xFF0F172A),
                ),
                placeholderWidget: Opacity(
                  opacity: 0.4,
                  child: SchematicSwitchWidget(
                    size: cardSize * 0.50,
                    isPushButton: true,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                label: '',
              ),
            ),
          ],
        );
      },
    );
  }
}
