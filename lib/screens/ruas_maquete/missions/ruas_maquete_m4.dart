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

/// Missão 4 do Estande 04 — Casas Independentes / Ligação em Paralelo.
class RuasMaqueteM4 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const RuasMaqueteM4({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<RuasMaqueteM4> createState() => _RuasMaqueteM4State();
}

class _RuasMaqueteM4State extends State<RuasMaqueteM4>
    with SingleTickerProviderStateMixin {
  final StandMission _mission = StandMission.ruasMaqueteMissions[3];
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  late AnimationController _electronAnimController;
  bool _usePhysicalStyle = true;
  bool _isSimulating = false;

  bool _m4ParallelWireConnected = false;
  double _m4ParallelRotation = 0.0;

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

      if (_m4ParallelWireConnected) {
        final result = await MissionCircuitBuilder()
            .addBattery(id: 'bat1', voltage: 4.5)
            .addBulb(id: 'bulb1', resistance: 5.0)
            .addBulb(id: 'bulb2', resistance: 5.0)
            .connect('bat1', 'B', 'bulb1', 'A')
            .connect('bulb1', 'B', 'bat1', 'A')
            .connect('bat1', 'B', 'bulb2', 'A')
            .connect('bulb2', 'B', 'bat1', 'A')
            .simulate();
        if (result.hasClosedLoop && result.errorMessage == null) {
          final current1 = (result.componentCurrents['bulb1'] ?? 0) * 1000;
          final current2 = (result.componentCurrents['bulb2'] ?? 0) * 1000;
          feedbackMessage = 'Circuito em paralelo validado! '
              'Lâmpada 1: ${current1.toStringAsFixed(1)}mA, Lâmpada 2: ${current2.toStringAsFixed(1)}mA. '
              'Ambas recebem tensão total da bateria.';
          isSuccess = true;
        } else {
          feedbackMessage = result.errorMessage ??
              'Monte as ligações em paralelo para que cada casa tenha seu ramo individual.';
        }
      } else {
        feedbackMessage =
            'Monte as ligações em paralelo para que cada casa tenha seu ramo individual.';
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
            leftHeaderWidget:
                buildRuasMaqueteStatusCard(_m4ParallelWireConnected),
            rightHeaderWidget: buildRuasMaqueteTelemetryCard(
              4.5,
              _m4ParallelWireConnected ? 180.0 : 0.0,
              _m4ParallelWireConnected,
            ),
            bottomWidget: _buildUndoRedoButtons(),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;
                final lampY = h * 0.28;
                final socketY = h * 0.80;
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
                              missionIndex: 3,
                              animValue: _electronAnimController.value,
                              m1Connected: false,
                              m2Series: false,
                              m3Junction: false,
                              m3Return: false,
                              m4Parallel: _m4ParallelWireConnected,
                              m5House1Broken: false,
                              usePhysicalStyle: _usePhysicalStyle,
                              lampY: lampY,
                              socketY: socketY,
                              lamp1X: w * 0.34,
                              lamp2X: w * 0.66,
                              socketX: socketX,
                              socketRotation: _m4ParallelRotation,
                            ),
                          );
                        },
                      ),
                    ),
                    ..._buildOverlayElements(
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
    required double socketX,
    required double lampY,
    required double socketY,
  }) {
    return [
      LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final x1 = w * 0.18;
          final x2 = w * 0.38;
          final x3 = w * 0.62;
          final x4 = w * 0.82;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Poste 1 (Alameda)
              Positioned(
                left: x1 - 40,
                top: lampY - 30,
                child: buildRuasMaqueteLampSymbol(
                  isLit: _m4ParallelWireConnected,
                  brightnessRatio: 1.0,
                  usePhysicalStyle: _usePhysicalStyle,
                ),
              ),
              Positioned(
                left: x1 - 65,
                top: lampY + 34,
                width: 130,
                child: Center(
                  child: buildRuasMaqueteLabelBadge('Poste 1'),
                ),
              ),

              // Casa 01 (Alameda)
              Positioned(
                left: x2 - 40,
                top: lampY - 30,
                child: buildRuasMaqueteHouseSymbol(
                  name: 'Casa 01 (Alameda)',
                  isLit: _m4ParallelWireConnected,
                  brightness: 1.0,
                  usePhysicalStyle: _usePhysicalStyle,
                ),
              ),
              Positioned(
                left: x2 - 65,
                top: lampY + 34,
                width: 130,
                child: Center(
                  child: buildRuasMaqueteLabelBadge('Casa 01'),
                ),
              ),

              // Casa 02 (Praça)
              Positioned(
                left: x3 - 40,
                top: lampY - 30,
                child: buildRuasMaqueteHouseSymbol(
                  name: 'Casa 02 (Praça)',
                  isLit: _m4ParallelWireConnected,
                  brightness: 1.0,
                  usePhysicalStyle: _usePhysicalStyle,
                ),
              ),
              Positioned(
                left: x3 - 65,
                top: lampY + 34,
                width: 130,
                child: Center(
                  child: buildRuasMaqueteLabelBadge('Casa 02'),
                ),
              ),

              // Poste 2 (Avenida)
              Positioned(
                left: x4 - 40,
                top: lampY - 30,
                child: buildRuasMaqueteLampSymbol(
                  isLit: _m4ParallelWireConnected,
                  brightnessRatio: 1.0,
                  usePhysicalStyle: _usePhysicalStyle,
                ),
              ),
              Positioned(
                left: x4 - 65,
                top: lampY + 34,
                width: 130,
                child: Center(
                  child: buildRuasMaqueteLabelBadge('Poste 2'),
                ),
              ),

              // Soquete do Barramento Paralelo
              Positioned(
                left: socketX - 40,
                top: socketY - 32,
                child: buildRuasMaqueteSocketTile(
                  width: 80,
                  height: 60,
                  expectedData: 'fio_paralelo',
                  isFilled: _m4ParallelWireConnected,
                  symbolType: ComponentType.connectingWire,
                  label: 'Fiação Paralela',
                  usePhysicalStyle: _usePhysicalStyle,
                  rotation: _m4ParallelRotation,
                  onRotate: () => _rotateComponent(
                    name: 'Fiação em Paralelo',
                    getRotation: () => _m4ParallelRotation,
                    setRotation: (v) => _m4ParallelRotation = v,
                  ),
                  onAccept: () => _insertComponent(
                    name: 'Fiação em Paralelo',
                    getInserted: () => _m4ParallelWireConnected,
                    setInserted: (v) => _m4ParallelWireConnected = v,
                    getRotation: () => _m4ParallelRotation,
                    setRotation: (v) => _m4ParallelRotation = v,
                  ),
                  onTap: () => _insertComponent(
                    name: 'Fiação em Paralelo',
                    getInserted: () => _m4ParallelWireConnected,
                    setInserted: (v) => _m4ParallelWireConnected = v,
                    getRotation: () => _m4ParallelRotation,
                    setRotation: (v) => _m4ParallelRotation = v,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ];
  }

  Widget _buildSideTools() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vantagem do Circuito em Paralelo:',
          style: GoogleFonts.rajdhani(
            color: const Color(0xFFD97706),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Cada casa do bairro recebe a tensão total da bateria (4.5V). Assim, todas as lâmpadas acendem com 100% de brilho máximo sem interferência!',
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
}
