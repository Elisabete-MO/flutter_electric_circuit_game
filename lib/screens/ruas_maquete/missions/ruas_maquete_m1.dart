import 'package:flutter/material.dart';

import '../../../models/circuit_action.dart';
import '../../../models/first_step_component.dart';
import '../../../models/stand_mission.dart';
import '../../../services/circuit_solver/mission_circuit_builder.dart';
import '../../../state/circuit_undo_redo_controller.dart';
import '../../../widgets/prof_volts_feedback_dialog.dart';
import '../../../widgets/success_confetti_overlay.dart';
import '../../../widgets/workbench_components.dart';
import '../../../widgets/workbench_sidebar_cards.dart';
import '../../../widgets/workbench_table_frame.dart';
import '../widgets/ruas_maquete_painter.dart';
import '../widgets/ruas_maquete_widgets.dart';

/// Missão 1 do Estande 04 — Primeiro Poste da Alameda (Circuito Simples).
class RuasMaqueteM1 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const RuasMaqueteM1({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<RuasMaqueteM1> createState() => _RuasMaqueteM1State();
}

class _RuasMaqueteM1State extends State<RuasMaqueteM1>
    with SingleTickerProviderStateMixin {
  final StandMission _mission = StandMission.ruasMaqueteMissions[0];
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  late AnimationController _electronAnimController;
  bool _usePhysicalStyle = true;
  bool _isSimulating = false;

  bool _m1BatteryConnected = false;
  bool _m1BatteryInserted = false;
  double _m1BatteryRotation = 0.0;
  bool _m1BulbUnscrewed = false;

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
      (_m1BatteryInserted || _m1BatteryConnected) && !_m1BulbUnscrewed;

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

  void _toggleBulb() {
    final prev = _m1BulbUnscrewed;
    _undoRedoController.execute(ToggleBoolAction(
      description: prev ? 'Rosquear Lâmpada' : 'Desrosquear Lâmpada',
      onApply: () => setState(() => _m1BulbUnscrewed = !prev),
      onUndo: () => setState(() => _m1BulbUnscrewed = prev),
    ));
  }

  Future<void> _validate() async {
    if (_isSimulating) return;
    setState(() => _isSimulating = true);

    try {
      bool isSuccess = false;
      String feedbackMessage = _mission.failureFeedback;

      if (_m1BulbUnscrewed) {
        feedbackMessage =
            'A lâmpada do poste está desrosqueada! Rosqueie-a no soquete tocando no poste.';
      } else if (_m1BatteryInserted || _m1BatteryConnected) {
        final result = await MissionCircuitBuilder()
            .addBattery(id: 'bat1', voltage: 4.5)
            .addBulb(id: 'bulb1', resistance: 10.0)
            .connect('bat1', 'B', 'bulb1', 'A')
            .connect('bulb1', 'B', 'bat1', 'A')
            .simulate();
        if (result.hasClosedLoop && result.errorMessage == null) {
          final currentMa = result.current * 1000;
          feedbackMessage =
              'Circuito simples validado com sucesso! Corrente de ${currentMa.toStringAsFixed(1)}mA circulando '
              'pelo poste com alimentação e retorno fechados.';
          isSuccess = true;
        } else {
          feedbackMessage = result.errorMessage ??
              'Circuito incompleto. Verifique se a bateria está conectada aos terminais.';
        }
      } else {
        feedbackMessage =
            'Conecte a bateria aos terminais de alimentação e retorno do poste!';
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
          _isClosed ? 90.0 : 0.0,
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
            final lamp1X = w * 0.50; // Centralizado na alameda
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
                          missionIndex: 0,
                          animValue: _electronAnimController.value,
                          m1Connected: _isClosed,
                          m2Series: false,
                          m3Junction: false,
                          m3Return: false,
                          m4Parallel: false,
                          m5House1Broken: false,
                          usePhysicalStyle: _usePhysicalStyle,
                          lampY: lampY,
                          socketY: socketY,
                          lamp1X: lamp1X,
                          lamp2X: lamp1X,
                          socketX: socketX,
                          socketRotation: _m1BatteryRotation,
                          bulb1Unscrewed: _m1BulbUnscrewed,
                          brightnessRatio: _isClosed ? 1.0 : 0.0,
                        ),
                      );
                    },
                  ),
                ),
                ..._buildOverlayElements(
                  lamp1X: lamp1X,
                  socketX: socketX,
                  lampY: lampY,
                  socketY: socketY,
                  w: w,
                  h: h,
                ),
              ],
            );
          },
        ),
      ),
      sidePanel: WorkbenchSidePanel(
        teamTitle: 'Painel da Alameda',
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
    required double socketX,
    required double lampY,
    required double socketY,
    required double w,
    required double h,
  }) {
    final compW = (w * 0.16).clamp(100.0, 140.0);
    final compH = compW * 0.80;

    return [
      Positioned(
        left: lamp1X - compW / 2,
        top: lampY - compH / 2,
        child: buildRuasMaqueteInteractiveLamp(
          label: 'Poste 1 (Alameda)',
          isLit: _isClosed,
          brightnessRatio: _isClosed ? 1.0 : 0.0,
          usePhysicalStyle: _usePhysicalStyle,
          isUnscrewed: _m1BulbUnscrewed,
          onToggleUnscrew: _toggleBulb,
          width: compW,
          height: compH,
        ),
      ),
      Positioned(
        left: socketX - compW / 2,
        top: socketY - compH / 2,
        child: buildRuasMaqueteSocketTile(
          width: compW,
          height: compH,
          expectedData: 'battery',
          isFilled: _m1BatteryInserted || _m1BatteryConnected,
          symbolType: ComponentType.battery,
          label: 'Bateria 4.5V',
          usePhysicalStyle: _usePhysicalStyle,
          rotation: _m1BatteryRotation,
          onRotate: () => _rotateComponent(
            name: 'Bateria 4.5V',
            getRotation: () => _m1BatteryRotation,
            setRotation: (v) => _m1BatteryRotation = v,
          ),
          onAccept: () => _insertComponent(
            name: 'Bateria 4.5V',
            getInserted: () => _m1BatteryInserted,
            setInserted: (v) {
              _m1BatteryInserted = v;
              _m1BatteryConnected = v;
            },
            getRotation: () => _m1BatteryRotation,
            setRotation: (v) => _m1BatteryRotation = v,
          ),
          onTap: () => _insertComponent(
            name: 'Bateria 4.5V',
            getInserted: () => _m1BatteryInserted,
            setInserted: (v) {
              _m1BatteryInserted = v;
              _m1BatteryConnected = v;
            },
            getRotation: () => _m1BatteryRotation,
            setRotation: (v) => _m1BatteryRotation = v,
          ),
        ),
      ),
      Positioned(
        left: socketX - 65,
        top: socketY + compH / 2 + 6,
        width: 130,
        child: Center(child: buildRuasMaqueteLabelBadge('Bateria 4.5V')),
      ),
    ];
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
    if (!_isClosed) return 1;
    return 2;
  }

  bool _isStepCompleted(int index) {
    if (index == 0) return true;
    if (index == 1) return _isClosed;
    if (index == 2) return _isClosed && !_m1BulbUnscrewed;
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
      title: 'Progresso da iluminação',
      currentStepIndex: _currentStepperIndex,
      isStepCompleted: _isStepCompleted,
      steps: const [
        'Instalar fonte de alimentação 4.5V',
        'Conectar condutores de ida e volta',
        'Acender primeiro poste da alameda',
      ],
    );
  }
}
