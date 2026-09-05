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

/// Missão 1 do Estande 04 — Postes em Série (Alameda e Avenida).
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

  bool _m1WireConnected = false;
  bool _m1WireInserted = false;
  double _m1WireRotation = 0.0;

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

  bool get _isClosed => _m1WireInserted || _m1WireConnected;

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

      if (_m1WireInserted || _m1WireConnected) {
        final result = await MissionCircuitBuilder()
            .addBattery(id: 'bat1', voltage: 4.5)
            .addBulb(id: 'bulb1', resistance: 5.0)
            .addBulb(id: 'bulb2', resistance: 5.0)
            .connect('bat1', 'B', 'bulb1', 'A')
            .connect('bulb1', 'B', 'bulb2', 'A')
            .connect('bulb2', 'B', 'bat1', 'A')
            .simulate();
        if (result.hasClosedLoop && result.errorMessage == null) {
          final currentMa = result.current * 1000;
          feedbackMessage =
              'Circuito em série validado! Corrente: ${currentMa.toStringAsFixed(1)}mA. '
              'Ambas as lâmpadas recebem a mesma corrente.';
          isSuccess = true;
        } else {
          feedbackMessage = result.errorMessage ??
              'Circuito em série incompleto. Verifique as conexões.';
        }
      } else {
        feedbackMessage =
            'Conecte o fio condutor em série para fechar o circuito dos postes!';
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
            leftHeaderWidget: buildRuasMaqueteStatusCard(_isClosed),
            rightHeaderWidget: buildRuasMaqueteTelemetryCard(
              4.5,
              _isClosed ? 80.0 : 0.0,
              _isClosed,
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
                              lamp2X: lamp2X,
                              socketX: socketX,
                              socketRotation: _m1WireRotation,
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
        // Painel Lateral (Briefing & Validação)
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
    final isLit = _isClosed;
    return [
      Positioned(
        left: lamp1X - 40,
        top: lampY - 30,
        child: buildRuasMaqueteLampSymbol(
          isLit: isLit,
          brightnessRatio: isLit ? 0.5 : 0.0,
          usePhysicalStyle: _usePhysicalStyle,
        ),
      ),
      Positioned(
        left: lamp1X - 75,
        top: lampY + 34,
        width: 150,
        child: Center(
          child: buildRuasMaqueteLabelBadge('Poste 1 (Alameda)'),
        ),
      ),
      Positioned(
        left: lamp2X - 40,
        top: lampY - 30,
        child: buildRuasMaqueteLampSymbol(
          isLit: isLit,
          brightnessRatio: isLit ? 0.5 : 0.0,
          usePhysicalStyle: _usePhysicalStyle,
        ),
      ),
      Positioned(
        left: lamp2X - 75,
        top: lampY + 34,
        width: 150,
        child: Center(
          child: buildRuasMaqueteLabelBadge('Poste 2 (Avenida)'),
        ),
      ),
      Positioned(
        left: socketX - 40,
        top: socketY - 32,
        child: buildRuasMaqueteSocketTile(
          width: 80,
          height: 60,
          expectedData: 'battery',
          isFilled: isLit,
          symbolType: ComponentType.battery,
          label: 'Bateria 4.5V',
          usePhysicalStyle: _usePhysicalStyle,
          rotation: _m1WireRotation,
          onRotate: () => _rotateComponent(
            name: 'Bateria 4.5V',
            getRotation: () => _m1WireRotation,
            setRotation: (v) => _m1WireRotation = v,
          ),
          onAccept: () => _insertComponent(
            name: 'Bateria 4.5V',
            getInserted: () => _m1WireInserted,
            setInserted: (v) {
              _m1WireInserted = v;
              _m1WireConnected = v;
            },
            getRotation: () => _m1WireRotation,
            setRotation: (v) => _m1WireRotation = v,
          ),
          onTap: () => _insertComponent(
            name: 'Bateria 4.5V',
            getInserted: () => _m1WireInserted,
            setInserted: (v) {
              _m1WireInserted = v;
              _m1WireConnected = v;
            },
            getRotation: () => _m1WireRotation,
            setRotation: (v) => _m1WireRotation = v,
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
          'Dica do Professor Volts:',
          style: GoogleFonts.rajdhani(
            color: const Color(0xFF0284C7),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Arraste ou toque no símbolo da Bateria para energizar e conectar os dois postes da maquete em circuito em série.',
          style: GoogleFonts.rajdhani(
            color: const Color(0xFF475569),
            fontSize: 13,
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
                  'Missão 1: ${_mission.title}',
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
