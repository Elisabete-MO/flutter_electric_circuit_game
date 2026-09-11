import 'package:flutter/material.dart';

import '../../../models/circuit_action.dart';
import '../../../models/first_step_component.dart';
import '../../../models/stand_mission.dart';
import '../../../services/circuit_solver/mission_circuit_builder.dart';
import '../../../state/circuit_undo_redo_controller.dart';
import '../../../widgets/circuit_symbol_painter.dart';
import '../../../widgets/component_physical_painter.dart';
import '../../../widgets/physical_blueprint_socket.dart';
import '../../../widgets/schematic_blueprint_socket.dart';
import '../../../widgets/prof_volts_feedback_dialog.dart';
import '../../../widgets/success_confetti_overlay.dart';
import '../../../widgets/workbench_components.dart';
import '../../../widgets/workbench_sidebar_cards.dart';
import '../../../widgets/workbench_table_frame.dart';
import '../widgets/ruas_maquete_painter.dart';
import '../widgets/ruas_maquete_widgets.dart';

/// Missão 2 do Estande 04 — O Dilema das Duas Lâmpadas em Série (Divisão de Tensão e Dependência).
class RuasMaqueteM2 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const RuasMaqueteM2({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<RuasMaqueteM2> createState() => _RuasMaqueteM2State();
}

class _RuasMaqueteM2State extends State<RuasMaqueteM2>
    with SingleTickerProviderStateMixin {
  final StandMission _mission = StandMission.ruasMaqueteMissions[1];
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  late AnimationController _electronAnimController;
  bool _usePhysicalStyle = true;
  bool _isSimulating = false;

  bool _m2IsSeriesTwoBulbs = true;
  bool _m2Bulb1Unscrewed = false;
  bool _m2Bulb2Unscrewed = false;
  double _m2SecondaryBulbRotation = 0.0;

  // 0 = Poste 1, 1 = Poste 2, 2 = Bateria Total
  int _probeTargetIndex = 0;
  bool _hasUsedVoltmeter = false;
  bool _hasTestedUnscrew = false;

  @override
  void initState() {
    super.initState();
    _electronAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _electronAnimController.dispose();
    super.dispose();
  }

  bool get _isClosed =>
      _m2IsSeriesTwoBulbs && !_m2Bulb1Unscrewed && !_m2Bulb2Unscrewed;

  double get _measuredVoltage {
    if (!_isClosed) return 0.0;
    switch (_probeTargetIndex) {
      case 0:
        return 2.25; // Poste 1
      case 1:
        return 2.25; // Poste 2
      case 2:
        return 4.50; // Total
      default:
        return 2.25;
    }
  }

  String get _probeTargetName {
    switch (_probeTargetIndex) {
      case 0:
        return 'Poste 1 (Alameda)';
      case 1:
        return 'Poste 2 (Avenida)';
      case 2:
        return 'Bateria Total (VCC)';
      default:
        return 'Poste 1';
    }
  }

  void _switchProbeTarget() {
    setState(() {
      _probeTargetIndex = (_probeTargetIndex + 1) % 3;
      _hasUsedVoltmeter = true;
    });
  }

  void _toggleBulb1() {
    final prev = _m2Bulb1Unscrewed;
    _undoRedoController.execute(ToggleBoolAction(
      description: prev ? 'Rosquear Poste 1' : 'Desrosquear Poste 1',
      onApply: () => setState(() {
        _m2Bulb1Unscrewed = !prev;
        _hasTestedUnscrew = true;
      }),
      onUndo: () => setState(() => _m2Bulb1Unscrewed = prev),
    ));
  }

  void _toggleBulb2() {
    final prev = _m2Bulb2Unscrewed;
    _undoRedoController.execute(ToggleBoolAction(
      description: prev ? 'Rosquear Poste 2' : 'Desrosquear Poste 2',
      onApply: () => setState(() {
        _m2Bulb2Unscrewed = !prev;
        _hasTestedUnscrew = true;
      }),
      onUndo: () => setState(() => _m2Bulb2Unscrewed = prev),
    ));
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
      description: 'Girar $name (${newRotation.toInt()}°)',
      onApply: () => setState(() => setRotation(newRotation)),
      onUndo: () => setState(() => setRotation(prevRotation)),
    ));
  }

  Future<void> _validate() async {
    if (_isSimulating) return;
    setState(() => _isSimulating = true);

    try {
      bool isSuccess = false;
      String feedbackMessage = _mission.failureFeedback;

      if (!_m2IsSeriesTwoBulbs) {
        feedbackMessage =
            'Insira o segundo poste no soquete para analisar o comportamento em série!';
      } else if (_m2Bulb1Unscrewed || _m2Bulb2Unscrewed) {
        feedbackMessage =
            'Você comprovou o efeito cascata: desrosquear uma lâmpada em série abre o circuito e apaga tudo! '
            'Agora rosqueie as duas para medir a divisão de tensão e concluir a investigação.';
      } else {
        final result = await MissionCircuitBuilder()
            .addBattery(id: 'bat1', voltage: 4.5)
            .addBulb(id: 'bulb1', resistance: 10.0)
            .addBulb(id: 'bulb2', resistance: 10.0)
            .connect('bat1', 'B', 'bulb1', 'A')
            .connect('bulb1', 'B', 'bulb2', 'A')
            .connect('bulb2', 'B', 'bat1', 'A')
            .simulate();

        if (result.hasClosedLoop && result.errorMessage == null) {
          final currentMa = result.current * 1000;
          feedbackMessage =
              'Investigação em Série Concluída! Ambas as lâmpadas dividem a tensão da fonte (2.25V cada) '
              'e a corrente caiu para ${currentMa.toStringAsFixed(1)}mA, gerando apenas 35% de brilho. '
              'Por isso bairros e cidades nunca usam ligação em série!';
          isSuccess = true;
        } else {
          feedbackMessage = result.errorMessage ?? 'Erro na montagem em série.';
        }
      }

      final fullMessage = isSuccess
          ? 'Missão "${_mission.title}" concluída com êxito! ${_mission.victoryCriteria}.\n\nProf. Volts: "${_mission.voltsMediation}"'
          : '$feedbackMessage\n\nProf. Volts: "${_mission.voltsMediation}"';

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => ProfVoltsFeedbackDialog(
            isCorrect: isSuccess,
            message: fullMessage,
            onAction: () {
              Navigator.of(context).pop();
              if (isSuccess) {
                showSuccessConfetti(context);
                widget.onMissionComplete();
              }
            },
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSimulating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WorkbenchResponsiveLayout(
      workbench: WorkbenchTableFrame(
        usePhysicalStyle: _usePhysicalStyle,
        onStyleChanged: (val) => setState(() => _usePhysicalStyle = val),
        leftHeaderWidget: buildRuasMaqueteStatusCard(_isClosed),
        rightHeaderWidget: buildRuasMaqueteTelemetryCard(
          _isClosed ? 4.5 : 0.0,
          _isClosed ? 45.0 : 0.0,
          _isClosed,
        ),
        bottomWidget: _buildUndoRedoButtons(),
        voltsTip: _mission.voltsMediation,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            final lampY = h * 0.32;
            final socketY = h * 0.78;
            final lamp1X = w * 0.34;
            final lamp2X = w * 0.66;
            final socketX = w * 0.50;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _electronAnimController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: RuasMaquetePainter(
                          missionIndex: 1,
                          animValue: _electronAnimController.value,
                          m1Connected: true,
                          m2Series: _m2IsSeriesTwoBulbs,
                          m3Junction: false,
                          m3Return: false,
                          m4Parallel: false,
                          m5House1Broken: false,
                          usePhysicalStyle: _usePhysicalStyle,
                          lampY: lampY,
                          socketY: socketY,
                          lamp1X: lamp1X,
                          lamp2X: lamp2X,
                          socketX: socketX,
                          socketRotation: 0.0,
                          bulb1Unscrewed: _m2Bulb1Unscrewed,
                          bulb2Unscrewed: _m2Bulb2Unscrewed,
                          brightnessRatio: _isClosed ? 0.35 : 0.0,
                        ),
                      );
                    },
                  ),
                ),
                ..._buildOverlayElements(
                  lamp1X: lamp1X,
                  lamp2X: lamp2X,
                  socketX: socketX,
                  lampY: lampY,
                  socketY: socketY,
                  w: w,
                  h: h,
                ),
                // Mini-Voltímetro interativo na bancada
                Positioned(
                  left: 14,
                  bottom: 14,
                  child: buildRuasMaqueteVoltmeterProbe(
                    measuredVoltage: _measuredVoltage,
                    targetLabel: _probeTargetName,
                    onSwitchTarget: _switchProbeTarget,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      sidePanel: WorkbenchSidePanel(
        teamTitle: 'Laboratório Urbano',
        showTeamHeader: false,
        buttonColor: const Color(0xFF059669),
        toolboxItems: [
          _buildMissionObjectiveCard(),
          const SizedBox(height: 12),
          _buildInvestigationStepperCard(),
        ],
        onEnergizePressed: _validate,
      ),
    );
  }

  List<Widget> _buildOverlayElements({
    required double lamp1X,
    required double lamp2X,
    required double socketX,
    required double lampY,
    required double socketY,
    required double w,
    required double h,
  }) {
    final compW = (w * 0.14).clamp(95.0, 130.0);
    final compH = compW * 0.75;

    return [
      Positioned(
        left: lamp1X - compW / 2,
        top: lampY - compH / 2,
        child: buildRuasMaqueteInteractiveLamp(
          label: 'Poste 1 (Alameda)',
          isLit: _isClosed,
          brightnessRatio: _isClosed ? 0.35 : 0.0,
          usePhysicalStyle: _usePhysicalStyle,
          isUnscrewed: _m2Bulb1Unscrewed,
          onToggleUnscrew: _toggleBulb1,
          probeVoltageText: _probeTargetIndex == 0 ? '${_measuredVoltage}V' : null,
          width: compW,
          height: compH,
        ),
      ),
      Positioned(
        left: lamp2X - compW / 2,
        top: lampY - compH / 2,
        child: _m2IsSeriesTwoBulbs
            ? buildRuasMaqueteInteractiveLamp(
                label: 'Poste 2 (Avenida)',
                isLit: _isClosed,
                brightnessRatio: _isClosed ? 0.35 : 0.0,
                usePhysicalStyle: _usePhysicalStyle,
                isUnscrewed: _m2Bulb2Unscrewed,
                onToggleUnscrew: _toggleBulb2,
                probeVoltageText:
                    _probeTargetIndex == 1 ? '${_measuredVoltage}V' : null,
                width: compW,
                height: compH,
              )
            : buildRuasMaqueteSocketTile(
                width: compW,
                height: compH,
                expectedData: 'bulb',
                isFilled: false,
                symbolType: ComponentType.bulb,
                label: 'Encaixe do Poste 2',
                brightnessRatio: 0.35,
                usePhysicalStyle: _usePhysicalStyle,
                rotation: _m2SecondaryBulbRotation,
                onRotate: () => _rotateComponent(
                  name: 'Poste 2',
                  getRotation: () => _m2SecondaryBulbRotation,
                  setRotation: (v) => _m2SecondaryBulbRotation = v,
                ),
                onAccept: () => _insertComponent(
                  name: 'Poste 2',
                  getInserted: () => _m2IsSeriesTwoBulbs,
                  setInserted: (v) => _m2IsSeriesTwoBulbs = v,
                  getRotation: () => _m2SecondaryBulbRotation,
                  setRotation: (v) => _m2SecondaryBulbRotation = v,
                ),
                onTap: () => _insertComponent(
                  name: 'Poste 2',
                  getInserted: () => _m2IsSeriesTwoBulbs,
                  setInserted: (v) => _m2IsSeriesTwoBulbs = v,
                  getRotation: () => _m2SecondaryBulbRotation,
                  setRotation: (v) => _m2SecondaryBulbRotation = v,
                ),
              ),
      ),
      Positioned(
        left: socketX - compW / 2,
        top: socketY - compH / 2,
        child: _buildBatteryWidget(compW, compH),
      ),
    ];
  }

  Widget _buildBatteryWidget(double width, double height) {
    final symSize = Size(width * 0.72, height * 0.72);

    final symbolWidget = _usePhysicalStyle
        ? CustomPaint(
            size: symSize,
            painter: ComponentPhysicalPainter(
              type: ComponentType.battery,
              isDarkMode: false,
            ),
          )
        : CustomPaint(
            size: symSize,
            painter: CircuitSymbolPainter(
              type: ComponentType.battery,
              isActive: true,
              color: const Color(0xFF0F172A),
              strokeWidth: 2.5,
            ),
          );

    return _usePhysicalStyle
        ? PhysicalComponentCard(
            width: width,
            height: height,
            symbolWidget: symbolWidget,
            label: 'Bateria 4.5V',
            isActive: true,
          )
        : SchematicComponentCard(
            symbolWidget: symbolWidget,
            label: 'Bateria 4.5V',
            isActive: true,
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
    if (!_m2IsSeriesTwoBulbs) return 0;
    if (!_hasUsedVoltmeter) return 1;
    if (!_hasTestedUnscrew) return 2;
    return 3;
  }

  bool _isStepCompleted(int index) {
    if (index == 0) return _m2IsSeriesTwoBulbs;
    if (index == 1) return _hasUsedVoltmeter;
    if (index == 2) return _hasTestedUnscrew;
    if (index == 3) return _isClosed;
    return false;
  }

  Widget _buildMissionObjectiveCard() {
    return WorkbenchMissionObjectiveCard(
      missionNumber: 2,
      title: _mission.title,
      description: _mission.objective,
      voltsTip: _mission.voltsMediation,
      accentColor: const Color(0xFF0284C7),
    );
  }

  Widget _buildInvestigationStepperCard() {
    return WorkbenchInvestigationStepperCard(
      title: 'Roteiro de Investigação Experimental',
      currentStepIndex: _currentStepperIndex,
      isStepCompleted: _isStepCompleted,
      steps: const [
        'Conectar segundo poste em série',
        'Medir queda de tensão (2.25V no voltímetro)',
        'Tocar no poste para testar o efeito cascata',
        'Comprovar por que cidades evitam série',
      ],
    );
  }
}
