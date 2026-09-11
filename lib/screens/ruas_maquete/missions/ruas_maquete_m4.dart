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

/// Missão 4 do Estande 04 — Bairro em Pleno Funcionamento (4 Ramos em Paralelo).
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

  bool _house1Active = true;
  bool _house2Active = true;

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

  int get _activeBranchesCount {
    if (!_m4ParallelWireConnected) return 0;
    int count = 2; // Os 2 postes
    if (_house1Active) count++;
    if (_house2Active) count++;
    return count;
  }

  double get _totalCurrentMa => _activeBranchesCount * 90.0;

  void _toggleParallelBus() {
    final prev = _m4ParallelWireConnected;
    _undoRedoController.execute(ToggleBoolAction(
      description: prev ? 'Desconectar Barramento' : 'Conectar Barramento Paralelo',
      onApply: () => setState(() => _m4ParallelWireConnected = !prev),
      onUndo: () => setState(() => _m4ParallelWireConnected = prev),
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
            .addBulb(id: 'bulb1', resistance: 10.0)
            .addBulb(id: 'bulb2', resistance: 10.0)
            .addBulb(id: 'house1', resistance: 10.0)
            .addBulb(id: 'house2', resistance: 10.0)
            .connect('bat1', 'B', 'bulb1', 'A')
            .connect('bulb1', 'B', 'bat1', 'A')
            .connect('bat1', 'B', 'bulb2', 'A')
            .connect('bulb2', 'B', 'bat1', 'A')
            .connect('bat1', 'B', 'house1', 'A')
            .connect('house1', 'B', 'bat1', 'A')
            .connect('bat1', 'B', 'house2', 'A')
            .connect('house2', 'B', 'bat1', 'A')
            .simulate();

        if (result.hasClosedLoop && result.errorMessage == null) {
          feedbackMessage =
              'Rede Paralela Urbana Validada! Todos os 4 ramos (2 postes e 2 casas) recebem a tensão total '
              'de 4.5V e a corrente total do barramento somou ${_totalCurrentMa.toStringAsFixed(0)}mA. '
              'A cidade está totalmente eletrificada e segura!';
          isSuccess = true;
        } else {
          feedbackMessage = result.errorMessage ??
              'Monte as ligações em paralelo para que cada casa e poste tenha seu ramo individual.';
        }
      } else {
        feedbackMessage =
            'Conecte o Barramento de Distribuição Paralela na parte inferior para energizar os ramos do bairro.';
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
        leftHeaderWidget:
            buildRuasMaqueteStatusCard(_m4ParallelWireConnected),
        rightHeaderWidget: buildRuasMaqueteTelemetryCard(
          _m4ParallelWireConnected ? 4.5 : 0.0,
          _totalCurrentMa,
          _m4ParallelWireConnected,
        ),
        bottomWidget: _buildUndoRedoButtons(),
        voltsTip: _mission.voltsMediation,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            final lampY = h * 0.32;
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
                          brightnessRatio: _m4ParallelWireConnected ? 1.0 : 0.0,
                        ),
                      );
                    },
                  ),
                ),
                ..._buildOverlayElements(
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
    required double socketX,
    required double lampY,
    required double socketY,
    required double w,
    required double h,
  }) {
    final x1 = w * 0.18;
    final x2 = w * 0.38;
    final x3 = w * 0.62;
    final x4 = w * 0.82;

    final compW = (w * 0.13).clamp(80.0, 115.0);
    final compH = compW * 0.75;
    final sockW = (w * 0.15).clamp(95.0, 130.0);
    final sockH = sockW * 0.75;

    return [
      // Poste 1 (Alameda)
      Positioned(
        left: x1 - compW / 2,
        top: lampY - compH / 2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildRuasMaqueteLampSymbol(
              isLit: _m4ParallelWireConnected,
              brightnessRatio: 1.0,
              usePhysicalStyle: _usePhysicalStyle,
              width: compW,
              height: compH,
            ),
            const SizedBox(height: 4),
            buildRuasMaqueteLabelBadge('Poste Alameda'),
          ],
        ),
      ),
      // Casa 1
      Positioned(
        left: x2 - compW / 2,
        top: lampY - compH / 2,
        child: buildRuasMaqueteInteractiveHouse(
          label: 'Casa 1',
          isLit: _m4ParallelWireConnected && _house1Active,
          brightness: 1.0,
          isBroken: !_house1Active,
          usePhysicalStyle: _usePhysicalStyle,
          onToggle: () => setState(() => _house1Active = !_house1Active),
          width: compW,
          height: compH,
        ),
      ),
      // Casa 2
      Positioned(
        left: x3 - compW / 2,
        top: lampY - compH / 2,
        child: buildRuasMaqueteInteractiveHouse(
          label: 'Casa 2',
          isLit: _m4ParallelWireConnected && _house2Active,
          brightness: 1.0,
          isBroken: !_house2Active,
          usePhysicalStyle: _usePhysicalStyle,
          onToggle: () => setState(() => _house2Active = !_house2Active),
          width: compW,
          height: compH,
        ),
      ),
      // Poste 2 (Avenida)
      Positioned(
        left: x4 - compW / 2,
        top: lampY - compH / 2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildRuasMaqueteLampSymbol(
              isLit: _m4ParallelWireConnected,
              brightnessRatio: 1.0,
              usePhysicalStyle: _usePhysicalStyle,
              width: compW,
              height: compH,
            ),
            const SizedBox(height: 4),
            buildRuasMaqueteLabelBadge('Poste Avenida'),
          ],
        ),
      ),
      // Soquete Central do Barramento Paralelo
      Positioned(
        left: socketX - sockW / 2,
        top: socketY - sockH / 2,
        child: buildRuasMaqueteSocketTile(
          width: sockW,
          height: sockH,
          expectedData: 'fio_paralelo',
          isFilled: _m4ParallelWireConnected,
          symbolType: ComponentType.connectingWire,
          label: 'Barramento Paralelo',
          usePhysicalStyle: _usePhysicalStyle,
          rotation: _m4ParallelRotation,
          onRotate: () => _rotateComponent(
            name: 'Barramento Paralelo',
            getRotation: () => _m4ParallelRotation,
            setRotation: (v) => _m4ParallelRotation = v,
          ),
          onAccept: _toggleParallelBus,
          onTap: _toggleParallelBus,
        ),
      ),
      Positioned(
        left: socketX - 70,
        top: socketY + sockH / 2 + 6,
        width: 140,
        child: GestureDetector(
          onTap: _toggleParallelBus,
          child: Center(
            child: buildRuasMaqueteLabelBadge(
              'Barramento Paralelo',
              subtitle: _m4ParallelWireConnected ? '(Conectado)' : '(Toque p/ Ligar)',
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildSideTools() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flash_on_rounded,
                  size: 18, color: Color(0xFFD97706)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Soma das Correntes:',
                  style: GoogleFonts.rajdhani(
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Cada carga em paralelo puxa ~90mA diretamente da fonte de 4.5V. '
            'Com 4 cargas ativas, a corrente total chega a ${_totalCurrentMa.toStringAsFixed(0)}mA!',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF475569),
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ],
      ),
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
    if (!_m4ParallelWireConnected) return 0;
    return 1;
  }

  bool _isStepCompleted(int index) {
    if (index == 0) return _m4ParallelWireConnected;
    if (index == 1) return _m4ParallelWireConnected;
    return false;
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

  Widget _buildInvestigationStepperCard() {
    return WorkbenchInvestigationStepperCard(
      title: 'Etapas de Eletrificação',
      currentStepIndex: _currentStepperIndex,
      isStepCompleted: _isStepCompleted,
      steps: const [
        'Instalar o Barramento Paralelo de distribuição',
        'Verificar tensão plena 4.5V nos 4 ramos urbanos',
      ],
    );
  }
}
