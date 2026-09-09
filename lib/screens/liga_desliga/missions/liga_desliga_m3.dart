import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/circuit_action.dart';
import '../../../models/first_step_component.dart';
import '../../../models/stand_mission.dart';
import '../../../state/circuit_undo_redo_controller.dart';
import '../../../widgets/circuit_symbol_painter.dart';
import '../../../widgets/component_physical_painter.dart';
import '../../../widgets/prof_volts_feedback_dialog.dart';
import '../../../widgets/realistic_wire_painter.dart';
import '../../../widgets/schematic_symbol_painters.dart';
import '../../../widgets/workbench_components.dart';
import '../../../widgets/workbench_table_frame.dart';
import '../../../widgets/workbench_sidebar_cards.dart';
import '../widgets/liga_desliga_widgets.dart';

/// Missão 3 do Estande 3 — Quem controla qual luz? (Duas chaves sem etiqueta).
class LigaDesligaM3 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const LigaDesligaM3({super.key, required this.onMissionComplete});

  @override
  State<LigaDesligaM3> createState() => _LigaDesligaM3State();
}

class _LigaDesligaM3State extends State<LigaDesligaM3>
    with SingleTickerProviderStateMixin {
  final StandMission _mission = StandMission.estande3Missions[2];
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  bool _usePhysicalStyle = true;
  bool _switch1Closed = false;
  bool _switch2Closed = false;
  bool _testedSwitch1 = false;
  bool _testedSwitch2 = false;
  static const double _batteryRotation = 0.0;
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

  bool get _isClosed => _switch1Closed || _switch2Closed;

  double get _currentMilliamps {
    if (_switch1Closed && _switch2Closed) return 360.0;
    if (_switch1Closed || _switch2Closed) return 180.0;
    return 0.0;
  }

  void _toggleSwitch1() {
    final prev = _switch1Closed;
    _undoRedoController.execute(
      ToggleBoolAction(
        description: 'Alternar Chave 1',
        onApply: () => setState(() {
          _switch1Closed = !prev;
          _testedSwitch1 = true;
        }),
        onUndo: () => setState(() {
          _switch1Closed = prev;
        }),
      ),
    );
  }

  void _toggleSwitch2() {
    final prev = _switch2Closed;
    _undoRedoController.execute(
      ToggleBoolAction(
        description: 'Alternar Chave 2',
        onApply: () => setState(() {
          _switch2Closed = !prev;
          _testedSwitch2 = true;
        }),
        onUndo: () => setState(() {
          _switch2Closed = prev;
        }),
      ),
    );
  }

  void _validate() {
    if (!_testedSwitch1 || !_testedSwitch2) {
      _showFeedback(
        false,
        'Para uma investigação científica justa, teste ambas as chaves individualmente antes de validar a bancada!',
      );
      return;
    }
    if (_mapSwitch1 == null || _mapSwitch2 == null) {
      _showFeedback(
        false,
        'Por favor, atribua a etiqueta para ambas as chaves antes de validar a bancada!',
      );
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
              _currentMilliamps,
              _isClosed,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Barra de Instrução com Undo/Redo alinhado
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Investigue o circuito: teste cada chave individualmente para descobrir qual luminária ela aciona.',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          shadows: const [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildUndoRedoButtons(),
                  ],
                ),
                const SizedBox(height: 6),

                // Lousa Central de Circuitos
                Expanded(
                  child: _usePhysicalStyle
                      ? _buildPhysicalCanvas()
                      : _buildSchematicCanvas(),
                ),
                const SizedBox(height: 10),

                // Console Inferior de Etiquetagem da Equipe
                _buildLabelAssignmentPanel(),
              ],
            ),
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
        color: Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCBD5E1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.undo_rounded, size: 18),
            tooltip: 'Desfazer ação',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
            color: _undoRedoController.canUndo
                ? const Color(0xFF0F172A)
                : const Color(0xFFCBD5E1),
            onPressed: _undoRedoController.canUndo
                ? () => setState(() => _undoRedoController.undo())
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.redo_rounded, size: 18),
            tooltip: 'Refazer ação',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
            color: _undoRedoController.canRedo
                ? const Color(0xFF0F172A)
                : const Color(0xFFCBD5E1),
            onPressed: _undoRedoController.canRedo
                ? () => setState(() => _undoRedoController.redo())
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPhysicalCanvas() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;

        final double centerY = height * 0.50;
        final double topY = height * 0.28;
        final double bottomY = height * 0.72;

        final batteryPos = Offset(width * 0.16, centerY);
        final switch1Pos = Offset(width * 0.48, topY);
        final switch2Pos = Offset(width * 0.48, bottomY);
        final lamp1Pos = Offset(width * 0.80, topY);
        final lamp2Pos = Offset(width * 0.80, bottomY);

        final wires = <WirePath>[];

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

        final sw1TermA = ComponentPlacement(
          position: switch1Pos,
          rotation: _switch1Rotation,
          type: ComponentType.switchComponent,
        ).getTerminalPosition(0);

        final sw1TermB = ComponentPlacement(
          position: switch1Pos,
          rotation: _switch1Rotation,
          type: ComponentType.switchComponent,
        ).getTerminalPosition(1);

        final sw2TermA = ComponentPlacement(
          position: switch2Pos,
          rotation: _switch2Rotation,
          type: ComponentType.switchComponent,
        ).getTerminalPosition(0);

        final sw2TermB = ComponentPlacement(
          position: switch2Pos,
          rotation: _switch2Rotation,
          type: ComponentType.switchComponent,
        ).getTerminalPosition(1);

        final lamp1TermA = ComponentPlacement(
          position: lamp1Pos,
          rotation: _lampARotation,
          type: ComponentType.bulb,
        ).getTerminalPosition(0);

        final lamp1TermB = ComponentPlacement(
          position: lamp1Pos,
          rotation: _lampARotation,
          type: ComponentType.bulb,
        ).getTerminalPosition(1);

        final lamp2TermA = ComponentPlacement(
          position: lamp2Pos,
          rotation: _lampBRotation,
          type: ComponentType.bulb,
        ).getTerminalPosition(0);

        final lamp2TermB = ComponentPlacement(
          position: lamp2Pos,
          rotation: _lampBRotation,
          type: ComponentType.bulb,
        ).getTerminalPosition(1);

        final busX = batteryPos.dx - 56.0;
        final bus2X = batteryPos.dx - 46.0;
        final leftReturnX = batteryPos.dx - 66.0;
        final lamp1BusX = lamp1Pos.dx - 46.0;
        final lamp2BusX = lamp2Pos.dx - 46.0;

        // Retorno Comum: Luminárias -> Bateria (-) (Azul)
        final returnX = lamp1Pos.dx + 48.0;
        final returnRailY = height - 16.0;

        // Fio Ramo 1: Bateria (+) -> Chave 1 (Vermelho)
        wires.add(
          WirePath(
            points: [
              batTermA,
              Offset(batTermA.dx, batteryPos.dy - 34.0),
              Offset(busX, batteryPos.dy - 34.0),
              Offset(busX, topY),
              sw1TermA,
            ],
            color: const Color(0xFFEF4444),
            isActive: _switch1Closed,
            thickness: 5.2,
          ),
        );

        // Fio Ramo 1: Chave 1 -> Luminária A (Vermelho)
        wires.add(
          WirePath(
            points: [
              sw1TermB,
              Offset(lamp1BusX, topY),
              Offset(lamp1BusX, lamp1TermA.dy),
              lamp1TermA,
            ],
            color: const Color(0xFFEF4444),
            isActive: _switch1Closed,
            thickness: 5.2,
          ),
        );

        // Fio Ramo 2: Bateria (+) -> Chave 2 (Âmbar)
        wires.add(
          WirePath(
            points: [
              batTermA,
              Offset(batTermA.dx, batteryPos.dy - 27.0),
              Offset(bus2X, batteryPos.dy - 27.0),
              Offset(bus2X, bottomY),
              sw2TermA,
            ],
            color: const Color(0xFFF59E0B),
            isActive: _switch2Closed,
            thickness: 5.2,
          ),
        );

        // Fio Ramo 2: Chave 2 -> Luminária B (Âmbar)
        wires.add(
          WirePath(
            points: [
              sw2TermB,
              Offset(lamp2BusX, bottomY),
              Offset(lamp2BusX, lamp2TermA.dy),
              lamp2TermA,
            ],
            color: const Color(0xFFF59E0B),
            isActive: _switch2Closed,
            thickness: 5.2,
          ),
        );

        // Retorno Comum: Luminária 1 -> Bateria (-) (Azul)
        wires.add(
          WirePath(
            points: [
              lamp1TermB,
              Offset(returnX, lamp1TermB.dy),
              Offset(returnX, returnRailY),
              Offset(leftReturnX, returnRailY),
              Offset(leftReturnX, batteryPos.dy - 42.0),
              Offset(batTermB.dx, batteryPos.dy - 42.0),
              batTermB,
            ],
            color: const Color(0xFF2563EB),
            isActive: _switch1Closed,
            thickness: 5.0,
          ),
        );

        // Retorno Comum: Luminária 2 -> Bateria (-) (Azul)
        wires.add(
          WirePath(
            points: [
              lamp2TermB,
              Offset(returnX, lamp2TermB.dy),
              Offset(returnX, returnRailY),
              Offset(leftReturnX, returnRailY),
              Offset(leftReturnX, batteryPos.dy - 42.0),
              Offset(batTermB.dx, batteryPos.dy - 42.0),
              batTermB,
            ],
            color: const Color(0xFF2563EB),
            isActive: _switch2Closed,
            thickness: 5.0,
          ),
        );

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Camada de Fios e Elétrons
            Positioned.fill(
              child: RealisticWireWidget(
                wires: wires,
                animationValue: _currentFlowController.value,
                showElectrons: _isClosed,
              ),
            ),

            // Fonte / Bateria 9V
            _buildBatteryComponent(position: batteryPos),

            // Chave 1
            _buildSwitchComponent(
              label: 'CHAVE 1',
              position: switch1Pos,
              isClosed: _switch1Closed,
              isTested: _testedSwitch1,
              onToggle: _toggleSwitch1,
            ),

            // Chave 2
            _buildSwitchComponent(
              label: 'CHAVE 2',
              position: switch2Pos,
              isClosed: _switch2Closed,
              isTested: _testedSwitch2,
              onToggle: _toggleSwitch2,
            ),

            // Luminária A
            _buildBulbComponent(
              label: 'LUMINÁRIA A',
              position: lamp1Pos,
              isLit: _switch1Closed,
            ),

            // Luminária B
            _buildBulbComponent(
              label: 'LUMINÁRIA B',
              position: lamp2Pos,
              isLit: _switch2Closed,
            ),
          ],
        );
      },
    );
  }

  Widget _buildBatteryComponent({required Offset position}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Badge centralizado acima da bateria
        Positioned(
          left: position.dx - 100,
          width: 200,
          top: position.dy - 64,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.90),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF38BDF8), width: 1.2),
              ),
              child: Text(
                'FONTE 9V',
                style: GoogleFonts.rajdhani(
                  color: const Color(0xFF38BDF8),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),

        // Componente Físico rigorosamente centralizado em `position`
        Positioned(
          left: position.dx - 51.5,
          top: position.dy - 42.0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: CustomPaint(
              size: const Size(95, 76),
              painter: ComponentPhysicalPainter(
                type: ComponentType.battery,
                isActive: true,
                isDarkMode: false,
                value: 9.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchComponent({
    required String label,
    required Offset position,
    required bool isClosed,
    required bool isTested,
    required VoidCallback onToggle,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Badge centralizado acima da chave
        Positioned(
          left: position.dx - 100,
          width: 200,
          top: position.dy - 64,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isClosed
                      ? const Color(0xFF10B981)
                      : const Color(0xFF64748B),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isClosed ? const Color(0xFF10B981) : Colors.black)
                        .withValues(alpha: 0.25),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.rajdhani(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11.5,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: isClosed
                          ? const Color(0xFF059669)
                          : const Color(0xFF475569),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isClosed ? 'FECHADA' : 'ABERTA',
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 9.5,
                      ),
                    ),
                  ),
                  if (isTested) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF10B981),
                      size: 12,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        // Componente Físico rigorosamente centralizado em `position`
        Positioned(
          left: position.dx - 51.5,
          top: position.dy - 42.0,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onToggle,
              child: Tooltip(
                message: 'Clique para alternar $label',
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isClosed
                          ? const Color(0xFF10B981).withValues(alpha: 0.7)
                          : Colors.white.withValues(alpha: 0.12),
                      width: 1.2,
                    ),
                  ),
                  child: CustomPaint(
                    size: const Size(95, 76),
                    painter: ComponentPhysicalPainter(
                      type: ComponentType.switchComponent,
                      isActive: isClosed,
                      isDarkMode: false,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBulbComponent({
    required String label,
    required Offset position,
    required bool isLit,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Placa de Identificação centralizada acima da luminária
        Positioned(
          left: position.dx - 100,
          width: 200,
          top: position.dy - 64,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isLit
                      ? const Color(0xFFFBBF24)
                      : const Color(0xFF64748B),
                  width: 1.2,
                ),
                boxShadow: [
                  if (isLit)
                    BoxShadow(
                      color: const Color(0xFFFBBF24).withValues(alpha: 0.45),
                      blurRadius: 8,
                    ),
                ],
              ),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(
                    Icons.lightbulb_rounded,
                    size: 13,
                    color: isLit
                        ? const Color(0xFFFBBF24)
                        : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: GoogleFonts.rajdhani(
                      color: isLit ? const Color(0xFFFDE047) : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11.5,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: isLit
                          ? const Color(0xFFD97706)
                          : const Color(0xFF475569),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isLit ? 'ILUMINADA' : 'APAGADA',
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 9.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Componente Físico rigorosamente centralizado em `position`
        Positioned(
          left: position.dx - 51.5,
          top: position.dy - 42.0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isLit)
                Container(
                  width: 95,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFBBF24).withValues(alpha: 0.55),
                        blurRadius: 36,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isLit
                        ? const Color(0xFFFBBF24).withValues(alpha: 0.7)
                        : Colors.white.withValues(alpha: 0.12),
                    width: 1.2,
                  ),
                ),
                child: CustomPaint(
                  size: const Size(95, 76),
                  painter: ComponentPhysicalPainter(
                    type: ComponentType.bulb,
                    isActive: isLit,
                    isDarkMode: false,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
        final double deltaY = (height * 0.28).clamp(36.0, 80.0);
        final double topY = centerY - deltaY;
        final double bottomY = centerY + deltaY;

        return Center(
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              clipBehavior: Clip.none,
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
                  left: batteryX - 32,
                  top: centerY - 23,
                  child: CustomPaint(
                    size: const Size(64, 46),
                    painter: CircuitSymbolPainter(
                      type: ComponentType.battery,
                      color: const Color(0xFFE2E8F0),
                      strokeWidth: 2.2,
                    ),
                  ),
                ),
                Positioned(
                  left: batteryX - 32,
                  top: centerY - 46,
                  child: _buildSchematicBadge(
                    'FONTE 9V',
                    const Color(0xFF38BDF8),
                  ),
                ),

                // Chave 1
                Positioned(
                  left: switchCenterX - 32,
                  top: topY - 23,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: _toggleSwitch1,
                      child: CustomPaint(
                        size: const Size(64, 46),
                        painter: CircuitSymbolPainter(
                          type: ComponentType.switchComponent,
                          isActive: _switch1Closed,
                          color: const Color(0xFFE2E8F0),
                          strokeWidth: 2.2,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: switchCenterX - 28,
                  top: topY - 46,
                  child: _buildSchematicBadge(
                    'CHAVE 1',
                    const Color(0xFF0284C7),
                  ),
                ),

                // Chave 2
                Positioned(
                  left: switchCenterX - 32,
                  top: bottomY - 23,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: _toggleSwitch2,
                      child: CustomPaint(
                        size: const Size(64, 46),
                        painter: CircuitSymbolPainter(
                          type: ComponentType.switchComponent,
                          isActive: _switch2Closed,
                          color: const Color(0xFFE2E8F0),
                          strokeWidth: 2.2,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: switchCenterX - 28,
                  top: bottomY - 46,
                  child: _buildSchematicBadge(
                    'CHAVE 2',
                    const Color(0xFF059669),
                  ),
                ),

                // Lâmpada A
                Positioned(
                  left: lampX - 32,
                  top: topY - 23,
                  child: CustomPaint(
                    size: const Size(64, 46),
                    painter: CircuitSymbolPainter(
                      type: ComponentType.bulb,
                      isActive: _switch1Closed,
                      color: const Color(0xFFE2E8F0),
                      activeColor: const Color(0xFFFBBF24),
                      strokeWidth: 2.2,
                    ),
                  ),
                ),
                Positioned(
                  left: lampX - 40,
                  top: topY - 46,
                  child: _buildSchematicBadge(
                    'LUMINÁRIA A',
                    const Color(0xFFF59E0B),
                  ),
                ),

                // Lâmpada B
                Positioned(
                  left: lampX - 32,
                  top: bottomY - 23,
                  child: CustomPaint(
                    size: const Size(64, 46),
                    painter: CircuitSymbolPainter(
                      type: ComponentType.bulb,
                      isActive: _switch2Closed,
                      color: const Color(0xFFE2E8F0),
                      activeColor: const Color(0xFFFBBF24),
                      strokeWidth: 2.2,
                    ),
                  ),
                ),
                Positioned(
                  left: lampX - 40,
                  top: bottomY - 46,
                  child: _buildSchematicBadge(
                    'LUMINÁRIA B',
                    const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSchematicBadge(String text, Color borderColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Text(
        text,
        style: GoogleFonts.rajdhani(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildLabelAssignmentPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Cartão Chave 1
          Expanded(
            child: _buildSwitchAssignmentCard(
              switchTitle: 'CHAVE 1',
              isClosed: _switch1Closed,
              isTested: _testedSwitch1,
              selectedTarget: _mapSwitch1,
              accentColor: const Color(0xFF0284C7),
              onToggle: _toggleSwitch1,
              onSelectTarget: (target) => setState(() => _mapSwitch1 = target),
            ),
          ),
          const SizedBox(width: 14),
          // Divisor vertical
          Container(width: 1, height: 50, color: const Color(0xFFE2E8F0)),
          const SizedBox(width: 14),
          // Cartão Chave 2
          Expanded(
            child: _buildSwitchAssignmentCard(
              switchTitle: 'CHAVE 2',
              isClosed: _switch2Closed,
              isTested: _testedSwitch2,
              selectedTarget: _mapSwitch2,
              accentColor: const Color(0xFF059669),
              onToggle: _toggleSwitch2,
              onSelectTarget: (target) => setState(() => _mapSwitch2 = target),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchAssignmentCard({
    required String switchTitle,
    required bool isClosed,
    required bool isTested,
    required String? selectedTarget,
    required Color accentColor,
    required VoidCallback onToggle,
    required ValueChanged<String> onSelectTarget,
  }) {
    return Row(
      children: [
        // Ação de Teste Rápido do Interruptor
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isClosed
                  ? const Color(0xFFECFDF5)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isClosed
                    ? const Color(0xFF10B981)
                    : const Color(0xFFCBD5E1),
                width: 1.2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isClosed ? Icons.power_rounded : Icons.power_off_rounded,
                      size: 14,
                      color: isClosed
                          ? const Color(0xFF059669)
                          : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      switchTitle,
                      style: GoogleFonts.rajdhani(
                        color: const Color(0xFF0F172A),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isClosed ? 'LIGADA' : 'DESLIGADA',
                      style: GoogleFonts.rajdhani(
                        color: isClosed
                            ? const Color(0xFF059669)
                            : const Color(0xFF64748B),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    if (isTested) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF10B981),
                        size: 12,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Seletores de Atribuição da Etiqueta
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Etiquetar como:',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: _buildTagButton(
                      label: 'Luminária A',
                      isSelected: selectedTarget == 'lampA',
                      accentColor: accentColor,
                      onTap: () => onSelectTarget('lampA'),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildTagButton(
                      label: 'Luminária B',
                      isSelected: selectedTarget == 'lampB',
                      accentColor: accentColor,
                      onTap: () => onSelectTarget('lampB'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTagButton({
    required String label,
    required bool isSelected,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.12)
              : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? accentColor : const Color(0xFFCBD5E1),
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? Icons.label_rounded : Icons.label_outline_rounded,
              size: 13,
              color: isSelected ? accentColor : const Color(0xFF64748B),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.rajdhani(
                  color: isSelected ? accentColor : const Color(0xFF334155),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int get _currentStepperIndex {
    if (!_testedSwitch1) return 0; // 1. Teste a chave 1
    if (_switch1Closed && !_testedSwitch2) return 1; // 2. Observe a luminária
    if (!_testedSwitch2) return 2; // 3. Teste a chave 2
    if (_mapSwitch1 == null || _mapSwitch2 == null) {
      return 3; // 4. Registre as associações
    }
    return 4; // Tudo pronto para validação!
  }

  bool _isStepCompleted(int index) {
    if (index == 0) return _testedSwitch1;
    if (index == 1) {
      return _testedSwitch1 && (_testedSwitch2 || !_switch1Closed);
    }
    if (index == 2) return _testedSwitch2;
    if (index == 3) return _mapSwitch1 != null && _mapSwitch2 != null;
    return false;
  }

  Widget _buildMissionObjectiveCard() {
    return WorkbenchMissionObjectiveCard(
      missionNumber: 3,
      title: _mission.title,
      description: _mission.objective,
      voltsTip: _mission.voltsMediation,
    );
  }

  Widget _buildInvestigationStepperCard() {
    return WorkbenchInvestigationStepperCard(
      title: 'Progresso da investigação',
      currentStepIndex: _currentStepperIndex,
      isStepCompleted: _isStepCompleted,
      steps: const [
        'Teste a chave 1',
        'Observe a luminária',
        'Teste a chave 2',
        'Registre as associações',
      ],
    );
  }
}
