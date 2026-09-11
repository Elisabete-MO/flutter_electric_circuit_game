import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

/// Missão 3 do Estande 04 — Bifurcação de Fios / Nó (Rua A e Rua B).
class RuasMaqueteM3 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const RuasMaqueteM3({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<RuasMaqueteM3> createState() => _RuasMaqueteM3State();
}

class _RuasMaqueteM3State extends State<RuasMaqueteM3>
    with SingleTickerProviderStateMixin {
  final StandMission _mission = StandMission.ruasMaqueteMissions[2];
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  late AnimationController _electronAnimController;
  bool _usePhysicalStyle = true;
  bool _isSimulating = false;

  bool _m3JunctionInserted = false;
  bool _m3ReturnConnected = false;
  double _m3JunctionRotation = 0.0;
  double _m3ReturnRotation = 0.0;

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

  bool get _bothLit => _m3JunctionInserted && _m3ReturnConnected;

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

      if (_m3JunctionInserted && _m3ReturnConnected) {
        final result = await MissionCircuitBuilder()
            .addBattery(id: 'bat1', voltage: 4.5)
            .addBulb(id: 'bulbA', resistance: 5.0)
            .addBulb(id: 'bulbB', resistance: 5.0)
            .connect('bat1', 'B', 'bulbA', 'A')
            .connect('bulbA', 'B', 'bat1', 'A')
            .connect('bat1', 'B', 'bulbB', 'A')
            .connect('bulbB', 'B', 'bat1', 'A')
            .simulate();
        if (result.hasClosedLoop && result.errorMessage == null) {
          feedbackMessage =
              'Bifurcação validada! A corrente se divide em dois ramos independentes e reconverge ao polo negativo.';
          isSuccess = true;
        } else {
          feedbackMessage = result.errorMessage ??
              'A bifurcação precisa se reconectar ao polo negativo da fonte.';
        }
      } else if (!_m3JunctionInserted) {
        feedbackMessage =
            'Insira o nó de bifurcação para dividir a corrente para as duas ruas.';
      } else {
        feedbackMessage =
            'A bifurcação precisa se reconectar ao polo negativo da fonte.';
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
        leftHeaderWidget: buildRuasMaqueteStatusCard(_bothLit),
        rightHeaderWidget: buildRuasMaqueteTelemetryCard(
          9.0,
          _bothLit ? 160.0 : 0.0,
          _bothLit,
        ),
        bottomWidget: _buildUndoRedoButtons(),
        voltsTip: _mission.voltsMediation,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            final lampY = h * 0.28;
            final socketY = h * 0.80;
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
                          missionIndex: 2,
                          animValue: _electronAnimController.value,
                          m1Connected: false,
                          m2Series: false,
                          m3Junction: _m3JunctionInserted,
                          m3Return: _m3ReturnConnected,
                          m4Parallel: false,
                          m5House1Broken: false,
                          usePhysicalStyle: _usePhysicalStyle,
                          lampY: lampY,
                          socketY: socketY,
                          lamp1X: lamp1X,
                          lamp2X: lamp2X,
                          socketX: socketX,
                          socketRotation: _m3ReturnRotation,
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
              ],
            );
          },
        ),
      ),
      sidePanel: WorkbenchSidePanel(
        teamTitle: 'Painel da Equipe Bairro',
        showTeamHeader: false,
        buttonColor: const Color(0xFF059669),
        toolboxItems: [
          _buildMissionObjectiveCard(),
          const SizedBox(height: 12),
          _buildInvestigationStepperCard(),
          const SizedBox(height: 12),
          _buildSideTools(),
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
    final nodeY = lampY + (h * 0.16).clamp(35.0, 60.0);

    return [
      Positioned(
        left: lamp1X - compW / 2,
        top: lampY - compH / 2,
        child: buildRuasMaqueteLampSymbol(
          isLit: _bothLit,
          brightnessRatio: _bothLit ? 1.0 : 0.0,
          usePhysicalStyle: _usePhysicalStyle,
          width: compW,
          height: compH,
        ),
      ),
      Positioned(
        left: lamp1X - 85,
        top: lampY + compH / 2 + 6,
        width: 170,
        child: Center(
          child: buildRuasMaqueteLabelBadge('Rua A (Nó Norte)'),
        ),
      ),
      Positioned(
        left: lamp2X - compW / 2,
        top: lampY - compH / 2,
        child: buildRuasMaqueteLampSymbol(
          isLit: _bothLit,
          brightnessRatio: _bothLit ? 1.0 : 0.0,
          usePhysicalStyle: _usePhysicalStyle,
          width: compW,
          height: compH,
        ),
      ),
      Positioned(
        left: lamp2X - 85,
        top: lampY + compH / 2 + 6,
        width: 170,
        child: Center(
          child: buildRuasMaqueteLabelBadge('Rua B (Nó Sul)'),
        ),
      ),
      Positioned(
        left: socketX - compW / 2,
        top: nodeY - compH / 2,
        child: buildRuasMaqueteSocketTile(
          width: compW,
          height: compH,
          expectedData: 'junction_node',
          isFilled: _m3JunctionInserted,
          symbolType: ComponentType.connectingWire,
          label: 'Nó (+)',
          usePhysicalStyle: _usePhysicalStyle,
          rotation: _m3JunctionRotation,
          onRotate: () => _rotateComponent(
            name: 'Nó de Junção',
            getRotation: () => _m3JunctionRotation,
            setRotation: (v) => _m3JunctionRotation = v,
          ),
          onAccept: () => _insertComponent(
            name: 'Nó de Junção',
            getInserted: () => _m3JunctionInserted,
            setInserted: (v) => _m3JunctionInserted = v,
            getRotation: () => _m3JunctionRotation,
            setRotation: (v) => _m3JunctionRotation = v,
          ),
          onTap: () => _insertComponent(
            name: 'Nó de Junção',
            getInserted: () => _m3JunctionInserted,
            setInserted: (v) => _m3JunctionInserted = v,
            getRotation: () => _m3JunctionRotation,
            setRotation: (v) => _m3JunctionRotation = v,
          ),
        ),
      ),
      Positioned(
        left: socketX - compW / 2,
        top: socketY - compH / 2,
        child: buildRuasMaqueteSocketTile(
          width: compW,
          height: compH,
          expectedData: 'fio_serie',
          isFilled: _m3ReturnConnected,
          symbolType: ComponentType.connectingWire,
          label: 'Retorno (-)',
          usePhysicalStyle: _usePhysicalStyle,
          rotation: _m3ReturnRotation,
          onRotate: () => _rotateComponent(
            name: 'Retorno Reconectado',
            getRotation: () => _m3ReturnRotation,
            setRotation: (v) => _m3ReturnRotation = v,
          ),
          onAccept: () => _insertComponent(
            name: 'Retorno Reconectado',
            getInserted: () => _m3ReturnConnected,
            setInserted: (v) => _m3ReturnConnected = v,
            getRotation: () => _m3ReturnRotation,
            setRotation: (v) => _m3ReturnRotation = v,
          ),
          onTap: () => _insertComponent(
            name: 'Retorno Reconectado',
            getInserted: () => _m3ReturnConnected,
            setInserted: (v) => _m3ReturnConnected = v,
            getRotation: () => _m3ReturnRotation,
            setRotation: (v) => _m3ReturnRotation = v,
          ),
        ),
      ),
    ];
  }

  Widget _buildSideTools() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dica Pedagógica do Prof. Volts:',
          style: GoogleFonts.rajdhani(
            color: const Color(0xFFD97706),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Uma bifurcação (nó) divide a corrente em duas rotas separadas (Rua A e Rua B). Ambas precisam se reconectar ao polo negativo para fechar o circuito!',
          style: GoogleFonts.rajdhani(
            color: const Color(0xFF475569),
            fontSize: 14,
            height: 1.3,
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
    if (!_m3JunctionInserted) return 0;
    if (!_m3ReturnConnected) return 1;
    return 2;
  }

  bool _isStepCompleted(int index) {
    if (index == 0) return _m3JunctionInserted;
    if (index == 1) return _m3ReturnConnected;
    if (index == 2) return _bothLit;
    return false;
  }

  Widget _buildMissionObjectiveCard() {
    return WorkbenchMissionObjectiveCard(
      missionNumber: 3,
      title: _mission.title,
      description: _mission.objective,
      voltsTip: _mission.voltsMediation,
      accentColor: const Color(0xFF0284C7),
    );
  }

  Widget _buildInvestigationStepperCard() {
    return WorkbenchInvestigationStepperCard(
      title: 'Progresso da malha paralela',
      currentStepIndex: _currentStepperIndex,
      isStepCompleted: _isStepCompleted,
      steps: const [
        'Conectar nó de derivação (alimentação)',
        'Conectar nó de retorno ao polo negativo',
        'Comprovar brilho pleno e independente',
      ],
    );
  }
}
