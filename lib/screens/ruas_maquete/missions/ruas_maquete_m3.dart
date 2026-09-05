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
    return Row(
      children: [
        // Área Principal da Bancada
        Expanded(
          flex: 7,
          child: WorkbenchTableFrame(
            usePhysicalStyle: _usePhysicalStyle,
            onStyleChanged: (val) => setState(() => _usePhysicalStyle = val),
            leftHeaderWidget: buildRuasMaqueteStatusCard(_bothLit),
            rightHeaderWidget: buildRuasMaqueteTelemetryCard(
              9.0,
              _bothLit ? 160.0 : 0.0,
              _bothLit,
            ),
            bottomWidget: _buildUndoRedoButtons(),
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
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Painel Lateral (Briefing & Dica)
        Expanded(
          flex: 3,
          child: WorkbenchSidePanel(
            teamTitle: 'Painel da Equipe Bairro',
            toolboxItems: [
              _buildMissionBriefingCard(),
              _buildSideTools(),
            ],
            onEnergizePressed: _validate,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildOverlayElements({
    required double lamp1X,
    required double lamp2X,
    required double socketX,
    required double lampY,
    required double socketY,
  }) {
    final nodeY = lampY + 45.0;

    return [
      Positioned(
        left: lamp1X - 40,
        top: lampY - 30,
        child: buildRuasMaqueteLampSymbol(
          isLit: _bothLit,
          brightnessRatio: _bothLit ? 1.0 : 0.0,
          usePhysicalStyle: _usePhysicalStyle,
        ),
      ),
      Positioned(
        left: lamp1X - 75,
        top: lampY + 34,
        width: 150,
        child: Center(
          child: buildRuasMaqueteLabelBadge('Rua A (Nó Norte)'),
        ),
      ),
      Positioned(
        left: lamp2X - 40,
        top: lampY - 30,
        child: buildRuasMaqueteLampSymbol(
          isLit: _bothLit,
          brightnessRatio: _bothLit ? 1.0 : 0.0,
          usePhysicalStyle: _usePhysicalStyle,
        ),
      ),
      Positioned(
        left: lamp2X - 75,
        top: lampY + 34,
        width: 150,
        child: Center(
          child: buildRuasMaqueteLabelBadge('Rua B (Nó Sul)'),
        ),
      ),
      Positioned(
        left: socketX - 40,
        top: nodeY - 32,
        child: buildRuasMaqueteSocketTile(
          width: 80,
          height: 60,
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
        left: socketX - 40,
        top: socketY - 32,
        child: buildRuasMaqueteSocketTile(
          width: 80,
          height: 60,
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
}
