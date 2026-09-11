import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/circuit_action.dart';
import '../../../models/stand_mission.dart';
import '../../../services/circuit_solver/mission_circuit_builder.dart';
import '../../../state/circuit_undo_redo_controller.dart';
import '../../../widgets/prof_volts_explanation_dialog.dart';
import '../../../widgets/prof_volts_feedback_dialog.dart';
import '../../../widgets/prof_volts_prediction_dialog.dart';
import '../../../widgets/success_confetti_overlay.dart';
import '../../../widgets/workbench_components.dart';
import '../../../widgets/workbench_sidebar_cards.dart';
import '../../../widgets/workbench_table_frame.dart';
import '../widgets/letreros_led_breadboard_painter.dart';
import '../widgets/letreros_led_widgets.dart';

/// Missão 2 do Estande 05 — E se o LED estiver invertido?
class LetrerosLedM2 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const LetrerosLedM2({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<LetrerosLedM2> createState() => _LetrerosLedM2State();
}

class _LetrerosLedM2State extends State<LetrerosLedM2>
    with SingleTickerProviderStateMixin {
  final StandMission _mission = StandMission.letrerosLedMissions[1];
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  late AnimationController _electronAnimController;
  bool _usePhysicalStyle = true;
  bool _isSimulating = false;

  bool _m2LedInvertedFixed = false;
  String? _prediction;

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

  void _toggleLedPolarity() {
    final prev = _m2LedInvertedFixed;
    _undoRedoController.execute(ToggleBoolAction(
      description: 'Girar LED na Protoboard',
      onApply: () => setState(() => _m2LedInvertedFixed = !prev),
      onUndo: () => setState(() => _m2LedInvertedFixed = prev),
    ));
  }

  void _onEnergizePressed() {
    if (_prediction == null) {
      _showPredictionDialog();
    } else {
      _validate();
    }
  }

  void _showPredictionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProfVoltsPredictionDialog(
        question: 'O LED está com K (Cátodo) no positivo. O que acontece ao energizar?',
        options: const [
          'LED não acende (bloqueia a corrente)',
          'LED acende fraco',
          'LED queima',
          'Não sei'
        ],
        onPredict: (prediction) {
          Navigator.of(context).pop();
          setState(() => _prediction = prediction);
          _validate();
        },
      ),
    );
  }

  void _showExplanationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProfVoltsExplanationDialog(
        question: 'Por que o LED não acendia antes da correção?',
        options: const [
          'Polaridade invertida bloqueia corrente (LED é um diodo)',
          'Resistor estava em valor errado',
          'Fio estava solto',
          'Não sei explicar'
        ],
        onExplain: (_) {
          Navigator.of(context).pop();
          showSuccessConfetti(context);
          widget.onMissionComplete();
        },
      ),
    );
  }

  Future<void> _validate() async {
    if (_isSimulating) return;
    setState(() => _isSimulating = true);

    try {
      bool isSuccess = false;
      String feedbackMessage = _mission.failureFeedback;

      if (_m2LedInvertedFixed) {
        final result = await MissionCircuitBuilder()
            .addBattery(id: 'bat1', voltage: 9.0)
            .addResistor(id: 'r1', resistance: 680.0)
            .addLed(id: 'led1', reversed: false)
            .connect('bat1', 'B', 'r1', 'A')
            .connect('r1', 'B', 'led1', 'A')
            .connect('led1', 'B', 'bat1', 'A')
            .simulate();
        if (result.hasClosedLoop && result.errorMessage == null) {
          final currentMa = result.current * 1000;
          feedbackMessage =
              'Polaridade corrigida com sucesso! Corrente de ${currentMa.toStringAsFixed(1)}mA fluindo do Ânodo (+) para o Cátodo (-). O letreiro acendeu com brilho verde!';
          isSuccess = true;
        } else {
          feedbackMessage =
              result.errorMessage ?? 'Gire o LED para a polaridade correta.';
        }
      } else {
        feedbackMessage =
            'O LED invertido bloqueia a passagem de corrente elétrica (0.0 mA). Toque no LED na protoboard para invertê-lo!';
      }

      final fullMessage = isSuccess
          ? 'Missão "${_mission.title}" concluída! ${_mission.victoryCriteria}.\n\nSua previsão: "$_prediction"\n\nProf. Volts: "${_mission.voltsMediation}"'
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
                _showExplanationDialog();
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
        leftHeaderWidget: buildLetrerosLedStatusCard(_m2LedInvertedFixed),
        rightHeaderWidget: buildLetrerosLedTelemetryCard(
          9.0,
          _m2LedInvertedFixed ? 10.3 : 0.0,
          _m2LedInvertedFixed,
        ),
        bottomWidget: _buildUndoRedoButtons(),
        voltsTip: _mission.voltsMediation,
        child: _buildWorkbenchDisplay(),
      ),
      sidePanel: WorkbenchSidePanel(
        teamTitle: 'Painel da Equipe Sinalização',
        showTeamHeader: false,
        buttonColor: const Color(0xFF059669),
        toolboxItems: [
          _buildMissionObjectiveCard(),
          const SizedBox(height: 12),
          _buildInvestigationStepperCard(),
          const SizedBox(height: 12),
          buildLetrerosLedPredictionBadge(_prediction),
          const SizedBox(height: 12),
          _buildSideControls(),
        ],
        onEnergizePressed: _onEnergizePressed,
        isLoading: _isSimulating,
      ),
    );
  }

  Widget _buildWorkbenchDisplay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // 1. Protoboard, Bateria 9V e Letreiro Verde
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _electronAnimController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: LetrerosLedBreadboardPainter(
                      animationValue: _electronAnimController.value,
                      usePhysicalStyle: _usePhysicalStyle,
                      isClosed: _m2LedInvertedFixed,
                      signTitle: 'SAÍDA ➔',
                      signColor: const Color(0xFF10B981),
                      hasResistor: true,
                      resistorValue: '680 Ω',
                      hasLed: true,
                      ledDirectPolarity: _m2LedInvertedFixed,
                      jumperConnected: true,
                    ),
                  );
                },
              ),
            ),

            // 2. Hotspot Tátil de Toque Direto no LED da Protoboard
            ..._buildLedTouchHotspot(constraints),
          ],
        );
      },
    );
  }

  List<Widget> _buildLedTouchHotspot(BoxConstraints constraints) {
    final w = constraints.maxWidth;
    final h = constraints.maxHeight;
    final batWidth = (w * 0.17).clamp(55.0, 155.0);
    final batLeft = (w * 0.03).clamp(8.0, 32.0);
    final spacing = (w * 0.03).clamp(8.0, 24.0);
    final bbLeft = batLeft + batWidth + spacing;
    final bbWidth = (w - bbLeft - 14.0).clamp(140.0, 560.0);
    final bbTop = (h * 0.24).clamp(60.0, 115.0);
    final bbHeight = (h * 0.54).clamp(140.0, 240.0);

    const cols = 20;
    final startX = bbLeft + 32.0;
    final stepX = (bbWidth - 64.0) / (cols - 1);
    final rowStepTop = (bbHeight * 0.22) / 4;
    final rowFY = bbTop + bbHeight * 0.24 + 4 * rowStepTop;

    final ledLeft = startX + 6 * stepX - 12;
    final ledWidth = 3 * stepX + 24;

    return [
      Positioned(
        left: ledLeft,
        top: rowFY - 22,
        width: ledWidth,
        height: 44,
        child: Tooltip(
          message: _m2LedInvertedFixed
              ? 'LED em Sentido Direto (Toque para inverter polaridade)'
              : 'LED Invertido na Protoboard (Toque para girar 180°)',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: _toggleLedPolarity,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _m2LedInvertedFixed
                        ? const Color(0xFF10B981).withValues(alpha: 0.4)
                        : Colors.amberAccent.withValues(alpha: 0.7),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildSideControls() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _m2LedInvertedFixed
              ? const Color(0xFF10B981)
              : Colors.amberAccent,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                _m2LedInvertedFixed
                    ? Icons.check_circle_rounded
                    : Icons.warning_amber_rounded,
                color: _m2LedInvertedFixed
                    ? const Color(0xFF10B981)
                    : Colors.amberAccent,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _m2LedInvertedFixed
                      ? 'LED na Protoboard em Sentido Direto'
                      : 'LED Invertido na Protoboard [K(-) no +]',
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _m2LedInvertedFixed
                  ? const Color(0xFF10B981)
                  : const Color(0xFF0284C7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.rotate_right_rounded, size: 18),
            label: Text(
              _m2LedInvertedFixed
                  ? 'Inverter Novamente (180°)'
                  : 'Girar LED na Protoboard (180°)',
              style: GoogleFonts.rajdhani(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            onPressed: _toggleLedPolarity,
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
    if (_prediction == null) return 0;
    if (!_m2LedInvertedFixed) return 1;
    return 2;
  }

  bool _isStepCompleted(int index) {
    if (index == 0) return _prediction != null;
    if (index == 1) return _m2LedInvertedFixed;
    if (index == 2) return _m2LedInvertedFixed && _prediction != null;
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
      title: 'Progresso da correção de polaridade',
      currentStepIndex: _currentStepperIndex,
      isStepCompleted: _isStepCompleted,
      steps: const [
        'Prever efeito da polarização reversa',
        'Inverter orientação do LED para o sentido direto',
        'Energizar e validar funcionamento',
      ],
    );
  }
}
