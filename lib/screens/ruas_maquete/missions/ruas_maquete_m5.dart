import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/circuit_action.dart';
import '../../../models/first_step_component.dart';
import '../../../models/stand_mission.dart';
import '../../../state/circuit_undo_redo_controller.dart';
import '../../../widgets/prof_volts_feedback_dialog.dart';
import '../../../widgets/success_confetti_overlay.dart';
import '../../../widgets/workbench_components.dart';
import '../../../widgets/workbench_sidebar_cards.dart';
import '../../../widgets/workbench_table_frame.dart';
import '../widgets/ruas_maquete_painter.dart';
import '../widgets/ruas_maquete_widgets.dart';

/// Missão 5 do Estande 04 — Teste de Manutenção e Independência dos Ramos em Paralelo.
class RuasMaqueteM5 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const RuasMaqueteM5({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<RuasMaqueteM5> createState() => _RuasMaqueteM5State();
}

class _RuasMaqueteM5State extends State<RuasMaqueteM5>
    with SingleTickerProviderStateMixin {
  final StandMission _mission = StandMission.ruasMaqueteMissions[4];
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  late AnimationController _electronAnimController;
  bool _usePhysicalStyle = true;
  bool _isSimulating = false;

  bool _m5House1Broken = false;
  bool _m5Bulb1Unscrewed = false;
  bool _m5Bulb2Unscrewed = false;
  bool _m5MaintenanceConfirmed = false;
  double _m5BusRotation = 0.0;

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

  void _toggleHouse1() {
    final prev = _m5House1Broken;
    _undoRedoController.execute(ToggleBoolAction(
      description: prev ? 'Reconectar Casa 01' : 'Simular Falha na Casa 01',
      onApply: () => setState(() {
        _m5House1Broken = !prev;
        if (!prev) _m5MaintenanceConfirmed = true;
      }),
      onUndo: () => setState(() => _m5House1Broken = prev),
    ));
  }

  void _toggleBulb1() {
    setState(() => _m5Bulb1Unscrewed = !_m5Bulb1Unscrewed);
  }

  void _toggleBulb2() {
    setState(() => _m5Bulb2Unscrewed = !_m5Bulb2Unscrewed);
  }

  int get _activeCount {
    int c = 0;
    if (!_m5Bulb1Unscrewed) c++;
    if (!_m5House1Broken) c++;
    c++; // Casa 2 sempre ativa
    if (!_m5Bulb2Unscrewed) c++;
    return c;
  }

  double get _currentMa => _activeCount * 90.0;

  Future<void> _validate() async {
    if (_isSimulating) return;
    setState(() => _isSimulating = true);

    try {
      bool isSuccess = false;
      String feedbackMessage = _mission.failureFeedback;

      if (_m5House1Broken || _m5MaintenanceConfirmed) {
        isSuccess = true;
        feedbackMessage =
            'Inspeção do Bairro Aprovada! Mesmo com a Casa 01 desconectada em manutenção, '
            'a Casa 02 e os dois Postes continuam acesos a 100% de brilho com 4.5V nominais. '
            'Você dominou a independência dos circuitos em paralelo!';
      } else {
        feedbackMessage =
            'Toque na Casa 01 para abrir o interruptor de manutenção e testar a independência da vizinhança!';
      }

      final fullMessage = isSuccess
          ? 'Inspeção do Bairro Aprovada! Missão "${_mission.title}" concluída com êxito! ${_mission.victoryCriteria}.\n\nProf. Volts: "${_mission.voltsMediation}"'
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
        leftHeaderWidget: buildRuasMaqueteStatusCard(true),
        rightHeaderWidget: buildRuasMaqueteTelemetryCard(
          4.5,
          _currentMa,
          true,
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
                          missionIndex: 4,
                          animValue: _electronAnimController.value,
                          m1Connected: false,
                          m2Series: false,
                          m3Junction: false,
                          m3Return: false,
                          m4Parallel: true,
                          m5House1Broken: _m5House1Broken,
                          usePhysicalStyle: _usePhysicalStyle,
                          lampY: lampY,
                          socketY: socketY,
                          lamp1X: w * 0.34,
                          lamp2X: w * 0.66,
                          socketX: socketX,
                          socketRotation: _m5BusRotation,
                          bulb1Unscrewed: _m5Bulb1Unscrewed,
                          bulb2Unscrewed: _m5Bulb2Unscrewed,
                          brightnessRatio: 1.0,
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
        teamTitle: 'Painel do Inspetor Urbano',
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
      // Poste 1 (Alameda) - Clicável para testar desrosquear
      Positioned(
        left: x1 - compW / 2,
        top: lampY - compH / 2,
        child: buildRuasMaqueteInteractiveLamp(
          label: 'Poste Alameda',
          isLit: !_m5Bulb1Unscrewed,
          brightnessRatio: 1.0,
          usePhysicalStyle: _usePhysicalStyle,
          isUnscrewed: _m5Bulb1Unscrewed,
          onToggleUnscrew: _toggleBulb1,
          width: compW,
          height: compH,
        ),
      ),

      // Casa 01 (Em Manutenção / Interativa via toque)
      Positioned(
        left: x2 - compW / 2,
        top: lampY - compH / 2,
        child: buildRuasMaqueteInteractiveHouse(
          label: 'Casa 01 (Alvo)',
          isLit: !_m5House1Broken,
          brightness: 1.0,
          isBroken: _m5House1Broken,
          usePhysicalStyle: _usePhysicalStyle,
          onToggle: _toggleHouse1,
          width: compW,
          height: compH,
        ),
      ),

      // Casa 02 (Vizinha - Segue acesa a 100%)
      Positioned(
        left: x3 - compW / 2,
        top: lampY - compH / 2,
        child: buildRuasMaqueteInteractiveHouse(
          label: 'Casa 02 (Vizinha)',
          isLit: true,
          brightness: 1.0,
          isBroken: false,
          usePhysicalStyle: _usePhysicalStyle,
          onToggle: () {},
          width: compW,
          height: compH,
        ),
      ),

      // Poste 2 (Avenida) - Clicável para testar desrosquear
      Positioned(
        left: x4 - compW / 2,
        top: lampY - compH / 2,
        child: buildRuasMaqueteInteractiveLamp(
          label: 'Poste Avenida',
          isLit: !_m5Bulb2Unscrewed,
          brightnessRatio: 1.0,
          usePhysicalStyle: _usePhysicalStyle,
          isUnscrewed: _m5Bulb2Unscrewed,
          onToggleUnscrew: _toggleBulb2,
          width: compW,
          height: compH,
        ),
      ),

      // Barramento de Alimentação Central
      Positioned(
        left: socketX - sockW / 2,
        top: socketY - sockH / 2,
        child: buildRuasMaqueteSocketTile(
          width: sockW,
          height: sockH,
          expectedData: 'fio_paralelo',
          isFilled: true,
          symbolType: ComponentType.connectingWire,
          label: 'Rede Ativa (4.5V)',
          usePhysicalStyle: _usePhysicalStyle,
          rotation: _m5BusRotation,
          onRotate: () => setState(() => _m5BusRotation = (_m5BusRotation + 90) % 360),
          onAccept: () {},
          onTap: () {},
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
              const Icon(Icons.verified_user_rounded,
                  size: 18, color: Color(0xFF10B981)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Independência dos Ramos:',
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
            'Toque na Casa 01 para abrir seu disjuntor de manutenção. '
            'Observe que a corrente cessa apenas no seu ramal — todos os demais vizinhos continuam 100% acesos!',
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
    if (!_m5House1Broken && !_m5MaintenanceConfirmed) return 0;
    return 1;
  }

  bool _isStepCompleted(int index) {
    if (index == 0) return _m5House1Broken || _m5MaintenanceConfirmed;
    if (index == 1) return _m5House1Broken || _m5MaintenanceConfirmed;
    return false;
  }

  Widget _buildMissionObjectiveCard() {
    return WorkbenchMissionObjectiveCard(
      missionNumber: 5,
      title: _mission.title,
      description: _mission.objective,
      voltsTip: _mission.voltsMediation,
      accentColor: const Color(0xFF0284C7),
    );
  }

  Widget _buildInvestigationStepperCard() {
    return WorkbenchInvestigationStepperCard(
      title: 'Procedimento de Inspeção',
      currentStepIndex: _currentStepperIndex,
      isStepCompleted: _isStepCompleted,
      steps: const [
        'Tocar na Casa 01 para simular manutenção',
        'Comprovar que os outros 3 ramos continuam acesos',
      ],
    );
  }
}
