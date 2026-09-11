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

/// Missão 3 do Estande 04 — O Nó de Derivação (Bifurcação de Kirchhoff e Independência).
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
  double _m3ReturnRotation = 0.0;

  bool _houseSwitchOpen = false;

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

  void _toggleJunction() {
    final prev = _m3JunctionInserted;
    _undoRedoController.execute(ToggleBoolAction(
      description: prev ? 'Remover Nó de Derivação' : 'Conectar Nó de Derivação',
      onApply: () => setState(() => _m3JunctionInserted = !prev),
      onUndo: () => setState(() => _m3JunctionInserted = prev),
    ));
  }

  void _toggleReturn() {
    final prev = _m3ReturnConnected;
    _undoRedoController.execute(ToggleBoolAction(
      description: prev ? 'Desconectar Retorno' : 'Conectar Linha de Retorno',
      onApply: () => setState(() => _m3ReturnConnected = !prev),
      onUndo: () => setState(() => _m3ReturnConnected = prev),
    ));
  }

  void _toggleHouseSwitch() {
    setState(() => _houseSwitchOpen = !_houseSwitchOpen);
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
            .addBulb(id: 'bulbA', resistance: 10.0)
            .addBulb(id: 'bulbB', resistance: 10.0)
            .connect('bat1', 'B', 'bulbA', 'A')
            .connect('bulbA', 'B', 'bat1', 'A')
            .connect('bat1', 'B', 'bulbB', 'A')
            .connect('bulbB', 'B', 'bat1', 'A')
            .simulate();

        if (result.hasClosedLoop && result.errorMessage == null) {
          final totalCurrent = result.current * 1000;
          feedbackMessage =
              'Bifurcação em Nó Validada! A corrente total (${totalCurrent.toStringAsFixed(0)}mA) '
              'divide-se igualmente pelos dois ramos (~450mA cada), e ambas as lâmpadas brilham com 100% '
              'da tensão nominal (4.5V).';
          isSuccess = true;
        } else {
          feedbackMessage = result.errorMessage ??
              'A bifurcação precisa se reconectar ao polo negativo da fonte.';
        }
      } else if (!_m3JunctionInserted) {
        feedbackMessage =
            'Conecte o Nó de Derivação na bifurcação para dividir a corrente para o poste e para a casa.';
      } else {
        feedbackMessage =
            'A bifurcação precisa fechar o circuito com o barramento de retorno negativo da fonte.';
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
          _bothLit ? 4.5 : 0.0,
          _bothLit ? 180.0 : 0.0,
          _bothLit,
        ),
        bottomWidget: _buildUndoRedoButtons(),
        voltsTip: _mission.voltsMediation,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            final lampY = h * 0.32;
            final socketY = h * 0.80;
            final lamp1X = w * 0.32; // Poste
            final lamp2X = w * 0.68; // Casa
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
                          brightnessRatio: _bothLit ? 1.0 : 0.0,
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
      // Poste da Alameda
      Positioned(
        left: lamp1X - compW / 2,
        top: lampY - compH / 2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildRuasMaqueteLampSymbol(
              isLit: _bothLit,
              brightnessRatio: _bothLit ? 1.0 : 0.0,
              usePhysicalStyle: _usePhysicalStyle,
              width: compW,
              height: compH,
            ),
            const SizedBox(height: 4),
            buildRuasMaqueteLabelBadge('Poste Alameda (Ramal 1)'),
          ],
        ),
      ),
      // Casa Residencial (com janelinha iluminada)
      Positioned(
        left: lamp2X - compW / 2,
        top: lampY - compH / 2,
        child: buildRuasMaqueteInteractiveHouse(
          label: 'Casa Residencial (Ramal 2)',
          isLit: _bothLit && !_houseSwitchOpen,
          brightness: _bothLit ? 1.0 : 0.0,
          isBroken: _houseSwitchOpen,
          usePhysicalStyle: _usePhysicalStyle,
          onToggle: _toggleHouseSwitch,
          width: compW,
          height: compH,
        ),
      ),
      // Nó de Derivação tátil na bifurcação
      Positioned(
        left: socketX - 22,
        top: nodeY - 22,
        child: buildRuasMaqueteJunctionBlock(
          isConnected: _m3JunctionInserted,
          onTap: _toggleJunction,
          size: 44,
        ),
      ),
      Positioned(
        left: socketX - 70,
        top: nodeY + 24,
        width: 140,
        child: GestureDetector(
          onTap: _toggleJunction,
          child: Center(
            child: buildRuasMaqueteLabelBadge(
              'Nó de Kirchhoff (+)',
              subtitle: _m3JunctionInserted ? '(Conectado)' : '(Toque p/ Ligar)',
            ),
          ),
        ),
      ),
      // Conexão do Barramento de Retorno (-)
      Positioned(
        left: socketX - compW / 2,
        top: socketY - compH / 2,
        child: buildRuasMaqueteSocketTile(
          width: compW,
          height: compH,
          expectedData: 'fio_serie',
          isFilled: _m3ReturnConnected,
          symbolType: ComponentType.connectingWire,
          label: 'Barramento de Retorno (-)',
          usePhysicalStyle: _usePhysicalStyle,
          rotation: _m3ReturnRotation,
          onRotate: () => _rotateComponent(
            name: 'Retorno',
            getRotation: () => _m3ReturnRotation,
            setRotation: (v) => _m3ReturnRotation = v,
          ),
          onAccept: _toggleReturn,
          onTap: _toggleReturn,
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
              const Icon(Icons.alt_route_rounded,
                  size: 18, color: Color(0xFF0284C7)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '1ª Lei de Kirchhoff (Nós):',
                  style: GoogleFonts.rajdhani(
                    color: const Color(0xFF0284C7),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Ao inserir o Nó de Derivação, o fluxo de elétrons se divide em dois caminhos paralelos independentes. Ambas as cargas recebem os 4.5V totais!',
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
      title: 'Passos da Bifurcação',
      currentStepIndex: _currentStepperIndex,
      isStepCompleted: _isStepCompleted,
      steps: const [
        'Inserir o Nó de Derivação central',
        'Ligar o Barramento de Retorno (-)',
        'Observar corrente dividida e brilho 100%',
      ],
    );
  }
}
