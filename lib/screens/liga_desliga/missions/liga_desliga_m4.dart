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
import '../../../widgets/workbench_sidebar_cards.dart';
import '../../../widgets/workbench_table_frame.dart';
import '../widgets/liga_desliga_widgets.dart';

/// Missão 4 do Estande 3 — Chave no lugar errado (Ramo Inútil para Série).
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
  bool _switchClosed = false; // Começa aberta para evidenciar imediatamente o desvio
  bool _observedBypass = true;
  bool _testedInSeries = false;

  // A bateria é renderizada na vertical (0.0°), com bornes (+) e (-) no topo
  static const double _batteryRotation = 0.0;
  static const double _lampRotation = 0.0;
  static const double _switchRotation = 0.0;

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

  double get _currentMilliamps => _isLampLit ? 90.0 : 0.0;

  void _toggleSwitch() {
    final prev = _switchClosed;
    _undoRedoController.execute(ToggleBoolAction(
      description: 'Alternar Chave M4',
      onApply: () => setState(() {
        _switchClosed = !prev;
        if (!_switchInMainBranch && !_switchClosed) {
          _observedBypass = true;
        }
        if (_switchInMainBranch) {
          _testedInSeries = true;
        }
      }),
      onUndo: () => setState(() {
        _switchClosed = prev;
      }),
    ));
  }

  void _moveToSeries() {
    if (_switchInMainBranch) return;
    _undoRedoController.execute(ToggleBoolAction(
      description: 'Mover chave para série',
      onApply: () => setState(() {
        _switchInMainBranch = true;
        _testedInSeries = true;
      }),
      onUndo: () => setState(() {
        _switchInMainBranch = false;
      }),
    ));
  }

  void _moveToBypass() {
    if (!_switchInMainBranch) return;
    _undoRedoController.execute(ToggleBoolAction(
      description: 'Mover chave para desvio',
      onApply: () => setState(() {
        _switchInMainBranch = false;
      }),
      onUndo: () => setState(() {
        _switchInMainBranch = true;
      }),
    ));
  }

  void _validate() {
    if (!_switchInMainBranch) {
      _showFeedback(
        false,
        'A chave ainda está no desvio inútil em paralelo! Mova a chave para o ponto em série no caminho da lâmpada para que ela possa interromper a corrente.',
      );
      return;
    }
    _showFeedback(
      true,
      'Excelente correção! Movendo o interruptor do ramo inútil para o ramo principal em série, a chave agora tem controle total sobre a lâmpada!',
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
              _currentMilliamps,
              _isLampLit,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Barra de Instrução com Undo/Redo alinhado
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _switchInMainBranch
                            ? 'Circuito corrigido: teste o controle da lâmpada abrindo e fechando a chave!'
                            : 'Observe a falha: a chave aberta não apaga a lâmpada! Mova a chave para o ponto em série.',
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

                // Console Inferior de Diagnóstico e Ação de Reposicionamento
                _buildDiagnosticActionConsole(),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Painel Lateral (Objetivo & Roteiro de Investigação)
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

        final double centerY = height * 0.58;
        final double yTop = height * 0.22;

        final batteryPos = Offset(width * 0.16, centerY);
        final lampPos = Offset(width * 0.82, centerY);
        final switchInutilityPos = Offset(width * 0.49, yTop);
        final switchSeriesPos = Offset(width * 0.49, centerY);

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

        final busX = batteryPos.dx - 38.0;
        final lampBusX = lampPos.dx - 26.0;

        final returnX = lampPos.dx + 48.0;
        final leftReturnX = batteryPos.dx - 52.0;
        final returnRailY = height - 16.0;

        if (!_switchInMainBranch) {
          // ESTADO 1: Chave no Ramo Inútil (Bypass/Desvio)
          final swInutilityTermA = ComponentPlacement(
            position: switchInutilityPos,
            rotation: _switchRotation,
            type: ComponentType.switchComponent,
          ).getTerminalPosition(0);

          final swInutilityTermB = ComponentPlacement(
            position: switchInutilityPos,
            rotation: _switchRotation,
            type: ComponentType.switchComponent,
          ).getTerminalPosition(1);

          // Fio Principal Direto (Vermelho) — Conduz SEMPRE contornando a chave
          wires.add(WirePath(
            points: [
              batTermA,
              Offset(batTermA.dx, batteryPos.dy - 38.0),
              Offset(busX, batteryPos.dy - 38.0),
              Offset(busX, centerY + 26.0),
              Offset(lampBusX, centerY + 26.0),
              lampTermA,
            ],
            color: const Color(0xFFEF4444),
            isActive: true,
            thickness: 4.2,
          ));

          // Fio Superior do Desvio: Entrada na Chave (Âmbar)
          wires.add(WirePath(
            points: [
              batTermA,
              Offset(batTermA.dx, batteryPos.dy - 38.0),
              Offset(busX, batteryPos.dy - 38.0),
              Offset(busX, yTop),
              swInutilityTermA,
            ],
            color: const Color(0xFFF59E0B),
            isActive: _switchClosed,
            thickness: 3.8,
          ));

          // Fio Superior do Desvio: Saída da Chave até a Lâmpada (Âmbar)
          wires.add(WirePath(
            points: [
              swInutilityTermB,
              Offset(lampBusX, yTop),
              Offset(lampBusX, lampTermA.dy),
              lampTermA,
            ],
            color: const Color(0xFFF59E0B),
            isActive: _switchClosed,
            thickness: 3.8,
          ));

          // Retorno Comum (Azul)
          wires.add(WirePath(
            points: [
              lampTermB,
              Offset(returnX, lampTermB.dy),
              Offset(returnX, returnRailY),
              Offset(leftReturnX, returnRailY),
              Offset(leftReturnX, batteryPos.dy - 38.0),
              Offset(batTermB.dx, batteryPos.dy - 38.0),
              batTermB,
            ],
            color: const Color(0xFF2563EB),
            isActive: true,
            thickness: 4.0,
          ));
        } else {
          // ESTADO 2: Chave em Série (Ramo Principal Corrigido)
          final swSeriesTermA = ComponentPlacement(
            position: switchSeriesPos,
            rotation: _switchRotation,
            type: ComponentType.switchComponent,
          ).getTerminalPosition(0);

          final swSeriesTermB = ComponentPlacement(
            position: switchSeriesPos,
            rotation: _switchRotation,
            type: ComponentType.switchComponent,
          ).getTerminalPosition(1);

          // Fio Bateria (+) -> Chave em Série (Vermelho)
          wires.add(WirePath(
            points: [
              batTermA,
              Offset(batTermA.dx, batteryPos.dy - 38.0),
              Offset(busX, batteryPos.dy - 38.0),
              Offset(busX, centerY),
              swSeriesTermA,
            ],
            color: const Color(0xFFEF4444),
            isActive: _switchClosed,
            thickness: 4.2,
          ));

          // Fio Chave em Série -> Lâmpada (Verde Esmeralda)
          wires.add(WirePath(
            points: [
              swSeriesTermB,
              Offset(lampBusX, centerY),
              Offset(lampBusX, lampTermA.dy),
              lampTermA,
            ],
            color: const Color(0xFF10B981),
            isActive: _switchClosed,
            thickness: 4.2,
          ));

          // Retorno Lâmpada -> Bateria (-) (Azul)
          wires.add(WirePath(
            points: [
              lampTermB,
              Offset(returnX, lampTermB.dy),
              Offset(returnX, returnRailY),
              Offset(leftReturnX, returnRailY),
              Offset(leftReturnX, batteryPos.dy - 38.0),
              Offset(batTermB.dx, batteryPos.dy - 38.0),
              batTermB,
            ],
            color: const Color(0xFF2563EB),
            isActive: _switchClosed,
            thickness: 4.0,
          ));
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Camada de Fios e Elétrons
            Positioned.fill(
              child: RealisticWireWidget(
                wires: wires,
                animationValue: _currentFlowController.value,
                showElectrons: _isLampLit,
              ),
            ),

            // Fonte / Bateria
            _buildBatteryComponent(position: batteryPos),

            // Lâmpada
            _buildBulbComponent(
              position: lampPos,
              isLit: _isLampLit,
              isIgnoringSwitch: !_switchInMainBranch,
            ),

            // POSIÇÃO 1: Ramo Inútil (Topo)
            if (!_switchInMainBranch)
              ..._buildActiveSwitchAtBypass(position: switchInutilityPos)
            else
              _buildDecommissionedBypassMarker(position: switchInutilityPos),

            // POSIÇÃO 2: Ponto em Série (Centro)
            if (!_switchInMainBranch)
              _buildSeriesTargetSlot(position: switchSeriesPos)
            else
              ..._buildActiveSwitchInSeries(position: switchSeriesPos),
          ],
        );
      },
    );
  }

  Widget _buildBatteryComponent({required Offset position}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Badge centralizado acima do componente
        Positioned(
          left: position.dx - 100,
          width: 200,
          top: position.dy - 58,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.90),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF38BDF8), width: 1.2),
              ),
              child: Text(
                'FONTE 4.5V',
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
          left: position.dx - 41.5,
          top: position.dy - 34.0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: CustomPaint(
              size: const Size(75, 60),
              painter: ComponentPhysicalPainter(
                type: ComponentType.battery,
                isActive: true,
                isDarkMode: false,
                value: 4.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBulbComponent({
    required Offset position,
    required bool isLit,
    required bool isIgnoringSwitch,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Placa / Badge centralizado acima da lâmpada
        Positioned(
          left: position.dx - 120,
          width: 240,
          top: position.dy - 58,
          child: Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
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
                    'LÂMPADA',
                    style: GoogleFonts.rajdhani(
                      color: isLit ? const Color(0xFFFDE047) : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11.5,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
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
          left: position.dx - 41.5,
          top: position.dy - 34.0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isLit)
                Container(
                  width: 75,
                  height: 60,
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
                  size: const Size(75, 60),
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

        // Aviso quando a lâmpada ignora a chave aberta
        if (isIgnoringSwitch && isLit && !_switchClosed)
          Positioned(
            left: position.dx - 100,
            width: 200,
            top: position.dy + 38,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'IGNORA A CHAVE!',
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildActiveSwitchAtBypass({required Offset position}) {
    return _buildPhysicalSwitchComponents(
      position: position,
      badgeText: 'DESVIO EM PARALELO',
      badgeColor: const Color(0xFFD97706),
      isDraggable: true,
    );
  }

  List<Widget> _buildActiveSwitchInSeries({required Offset position}) {
    return _buildPhysicalSwitchComponents(
      position: position,
      badgeText: 'CHAVE EM SÉRIE (CORRETO)',
      badgeColor: const Color(0xFF10B981),
      isDraggable: false,
    );
  }

  List<Widget> _buildPhysicalSwitchComponents({
    required Offset position,
    required String badgeText,
    required Color badgeColor,
    required bool isDraggable,
  }) {
    final badgeWidget = Positioned(
      left: position.dx - 160,
      width: 320,
      top: position.dy - 58,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: badgeColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: badgeColor.withValues(alpha: 0.25),
                blurRadius: 6,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  badgeText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: _switchClosed
                      ? const Color(0xFF059669)
                      : const Color(0xFF475569),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _switchClosed ? 'FECHADA' : 'ABERTA',
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
    );

    final switchBody = MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _toggleSwitch,
        child: Tooltip(
          message: 'Clique para alternar a chave',
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _switchClosed
                    ? const Color(0xFF10B981).withValues(alpha: 0.7)
                    : Colors.white.withValues(alpha: 0.12),
                width: 1.2,
              ),
            ),
            child: CustomPaint(
              size: const Size(75, 60),
              painter: ComponentPhysicalPainter(
                type: ComponentType.switchComponent,
                isActive: _switchClosed,
                isDarkMode: false,
              ),
            ),
          ),
        ),
      ),
    );

    final componentWidget = Positioned(
      left: position.dx - 41.5,
      top: position.dy - 34.0,
      child: isDraggable
          ? Draggable<String>(
              data: 'switch',
              feedback: Material(
                color: Colors.transparent,
                child: CustomPaint(
                  size: const Size(75, 60),
                  painter: ComponentPhysicalPainter(
                    type: ComponentType.switchComponent,
                    isActive: _switchClosed,
                    isDarkMode: false,
                  ),
                ),
              ),
              childWhenDragging: Opacity(opacity: 0.3, child: switchBody),
              child: switchBody,
            )
          : switchBody,
    );

    return [badgeWidget, componentWidget];
  }

  Widget _buildSeriesTargetSlot({required Offset position}) {
    return Positioned(
      left: position.dx - 85,
      top: position.dy - 32,
      child: DragTarget<String>(
        onAcceptWithDetails: (_) => _moveToSeries(),
        builder: (context, candidateData, rejectedData) {
          final isHovering = candidateData.isNotEmpty;

          return InkWell(
            onTap: _moveToSeries,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 170,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: isHovering
                    ? const Color(0xFF0284C7).withValues(alpha: 0.25)
                    : const Color(0xFF0F172A).withValues(alpha: 0.70),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isHovering
                      ? const Color(0xFF38BDF8)
                      : const Color(0xFF00E5FF).withValues(alpha: 0.8),
                  width: isHovering ? 2.2 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.20),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.touch_app_rounded,
                          color: Color(0xFF00E5FF), size: 13),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'PONTO DE CORTE EM SÉRIE',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.rajdhani(
                            color: const Color(0xFF00E5FF),
                            fontWeight: FontWeight.bold,
                            fontSize: 10.5,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'CLIQUE OU ARRASTE\nA CHAVE PARA CÁ',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.rajdhani(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 9.5,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDecommissionedBypassMarker({required Offset position}) {
    return Positioned(
      left: position.dx - 90,
      width: 180,
      top: position.dy - 16,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF64748B), width: 1.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF10B981), size: 12),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'DESVIO DESATIVADO',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.rajdhani(
                    color: const Color(0xFF94A3B8),
                    fontWeight: FontWeight.bold,
                    fontSize: 10.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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

        return Center(
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CustomPaint(
                  size: Size(width, height),
                  painter: SchematicCircuitWirePainterM4(
                    isClosed: _isLampLit,
                    switchInMainBranch: _switchInMainBranch,
                    animationValue: _currentFlowController.value,
                  ),
                ),

                // Bateria
                Positioned(
                  left: batteryX - 27,
                  top: centerY - 19,
                  child: CustomPaint(
                    size: const Size(54, 38),
                    painter: CircuitSymbolPainter(
                      type: ComponentType.battery,
                      color: const Color(0xFFE2E8F0),
                      strokeWidth: 2.2,
                    ),
                  ),
                ),
                Positioned(
                  left: batteryX - 28,
                  top: centerY - 42,
                  child:
                      _buildSchematicBadge('FONTE 4.5V', const Color(0xFF38BDF8)),
                ),

                // Lâmpada
                Positioned(
                  left: lampX - 27,
                  top: centerY - 19,
                  child: CustomPaint(
                    size: const Size(54, 38),
                    painter: CircuitSymbolPainter(
                      type: ComponentType.bulb,
                      isActive: _isLampLit,
                      color: const Color(0xFFE2E8F0),
                      activeColor: const Color(0xFFFBBF24),
                      strokeWidth: 2.2,
                    ),
                  ),
                ),
                Positioned(
                  left: lampX - 28,
                  top: centerY - 42,
                  child:
                      _buildSchematicBadge('LÂMPADA', const Color(0xFFF59E0B)),
                ),

                // Chave no Ramo Inútil (Topo)
                if (!_switchInMainBranch)
                  Positioned(
                    left: switchCenterX - 27,
                    top: 35.0 - 19,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: _toggleSwitch,
                        child: CustomPaint(
                          size: const Size(54, 38),
                          painter: CircuitSymbolPainter(
                            type: ComponentType.switchComponent,
                            isActive: _switchClosed,
                            color: const Color(0xFFE2E8F0),
                            strokeWidth: 2.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (!_switchInMainBranch)
                  Positioned(
                    left: switchCenterX - 40,
                    top: 35.0 - 42,
                    child: _buildSchematicBadge(
                        'DESVIO INÚTIL', const Color(0xFFD97706)),
                  ),

                // Ponto em Série (Centro)
                if (_switchInMainBranch)
                  Positioned(
                    left: switchCenterX - 27,
                    top: centerY - 19,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: _toggleSwitch,
                        child: CustomPaint(
                          size: const Size(54, 38),
                          painter: CircuitSymbolPainter(
                            type: ComponentType.switchComponent,
                            isActive: _switchClosed,
                            color: const Color(0xFFE2E8F0),
                            strokeWidth: 2.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_switchInMainBranch)
                  Positioned(
                    left: switchCenterX - 38,
                    top: centerY - 42,
                    child: _buildSchematicBadge(
                        'CHAVE EM SÉRIE', const Color(0xFF10B981)),
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

  Widget _buildDiagnosticActionConsole() {
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
          // Painel de Status do Interruptor
          Expanded(
            flex: 5,
            child: Row(
              children: [
                InkWell(
                  onTap: _toggleSwitch,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _switchClosed
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _switchClosed
                            ? const Color(0xFF10B981)
                            : const Color(0xFFCBD5E1),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _switchClosed
                              ? Icons.power_rounded
                              : Icons.power_off_rounded,
                          size: 16,
                          color: _switchClosed
                              ? const Color(0xFF059669)
                              : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'INTERRUPTOR',
                              style: GoogleFonts.rajdhani(
                                color: const Color(0xFF0F172A),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              _switchClosed ? 'FECHADO (ON)' : 'ABERTO (OFF)',
                              style: GoogleFonts.rajdhani(
                                color: _switchClosed
                                    ? const Color(0xFF059669)
                                    : const Color(0xFF64748B),
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Posição Atual da Chave:',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF64748B),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            _switchInMainBranch
                                ? Icons.check_circle_rounded
                                : Icons.warning_amber_rounded,
                            size: 14,
                            color: _switchInMainBranch
                                ? const Color(0xFF10B981)
                                : const Color(0xFFD97706),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              _switchInMainBranch
                                  ? 'Em Série (Caminho Obrigatório)'
                                  : 'Em Paralelo (Desvio Inútil)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.rajdhani(
                                color: _switchInMainBranch
                                    ? const Color(0xFF059669)
                                    : const Color(0xFFD97706),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 1,
            height: 48,
            color: const Color(0xFFE2E8F0),
          ),
          const SizedBox(width: 12),

          // Painel de Ação de Reposicionamento
          Expanded(
            flex: 4,
            child: !_switchInMainBranch
                ? ElevatedButton.icon(
                    onPressed: _moveToSeries,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.drive_file_move_rounded, size: 16),
                    label: Text(
                      'COLOCAR EM SÉRIE',
                      style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                        letterSpacing: 0.5,
                      ),
                    ),
                  )
                : OutlinedButton.icon(
                    onPressed: _moveToBypass,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.undo_rounded, size: 15),
                    label: Text(
                      'Reverter para Desvio',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }


  Widget _buildMissionObjectiveCard() {
    return WorkbenchMissionObjectiveCard(
      missionNumber: 4,
      title: _mission.title,
      description: _mission.objective,
      voltsTip: _mission.voltsMediation,
      accentColor: const Color(0xFF0284C7),
    );
  }

  int get _currentStepperIndex {
    if (!_observedBypass) return 0;
    if (!_switchInMainBranch) return 1;
    return 2;
  }

  bool _isStepCompleted(int index) {
    if (index == 0) return _observedBypass;
    if (index == 1) return _switchInMainBranch;
    if (index == 2) return _testedInSeries;
    return false;
  }

  Widget _buildInvestigationStepperCard() {
    return WorkbenchInvestigationStepperCard(
      title: 'Roteiro de investigação',
      currentStepIndex: _currentStepperIndex,
      isStepCompleted: _isStepCompleted,
      steps: const [
        'Notar que chave aberta não apaga a luz',
        'Reposicionar chave para o ramo em série',
        'Testar controle da lâmpada (ligar e desligar)',
      ],
    );
  }
}
