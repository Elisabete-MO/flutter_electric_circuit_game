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

/// Missão 3 do Estande 05 — Por que a placa não acende? (Investigação de 3 Hipóteses).
class LetrerosLedM3 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const LetrerosLedM3({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<LetrerosLedM3> createState() => _LetrerosLedM3State();
}

class _LetrerosLedM3State extends State<LetrerosLedM3>
    with SingleTickerProviderStateMixin {
  final StandMission _mission = StandMission.letrerosLedMissions[2];
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  late AnimationController _electronAnimController;
  bool _usePhysicalStyle = true;
  bool _isSimulating = false;

  bool _m3LedRotated = false;
  bool _m3WireConnected = false;
  bool _m3ResistorInBranch = false;
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

  bool get _allFixed =>
      _m3LedRotated && _m3WireConnected && _m3ResistorInBranch;

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
        question: 'O letreiro de emergência está apagado. Qual falha deve ser inspecionada?',
        options: const [
          'Inspecionar jumper, resistor e polaridade do LED',
          'Apenas trocar a bateria de 9V',
          'Aumentar a tensão para 220V',
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
        question: 'Qual o método científico correto para diagnosticar um circuito?',
        options: const [
          'Descartar uma hipótese por vez: continuidade, polaridade e resistor',
          'Trocar todos os componentes ao mesmo tempo',
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

      if (_allFixed) {
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
              'Excelente investigação de bancada! O jumper foi reconectado, o resistor inserido no trilho correto e o LED orientado em polaridade direta. Corrente estabilizada em ${currentMa.toStringAsFixed(1)}mA e letreiro aceso!';
          isSuccess = true;
        } else {
          feedbackMessage =
              result.errorMessage ?? 'Ainda há um problema na placa.';
        }
      } else {
        final missing = <String>[];
        if (!_m3WireConnected) missing.add('Fio jumper aberto');
        if (!_m3ResistorInBranch) missing.add('Resistor fora do trilho');
        if (!_m3LedRotated) missing.add('LED invertido');
        feedbackMessage =
            'Corrija as falhas encontradas na protoboard: ${missing.join(", ")}.';
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
    return Row(
      children: [
        // Área Principal da Bancada
        Expanded(
          flex: 7,
          child: WorkbenchTableFrame(
            usePhysicalStyle: _usePhysicalStyle,
            onStyleChanged: (val) => setState(() => _usePhysicalStyle = val),
            leftHeaderWidget: buildLetrerosLedStatusCard(_allFixed),
            rightHeaderWidget: buildLetrerosLedTelemetryCard(
              9.0,
              _allFixed ? 10.3 : 0.0,
              _allFixed,
            ),
            bottomWidget: _buildUndoRedoButtons(),
            child: _buildWorkbenchDisplay(),
          ),
        ),
        const SizedBox(width: 16),
        // Painel Lateral (Objetivo, Stepper & Validação)
        Expanded(
          flex: 3,
          child: WorkbenchSidePanel(
            teamTitle: 'Painel da Equipe Sinalização',
            showTeamHeader: false,
            buttonColor: const Color(0xFF059669),
            toolboxItems: [
              _buildMissionObjectiveCard(),
              const SizedBox(height: 12),
              _buildInvestigationStepperCard(),
              const SizedBox(height: 12),
              buildLetrerosLedPredictionBadge(_prediction),
              _buildSideInstructions(),
            ],
            onEnergizePressed: _onEnergizePressed,
            isLoading: _isSimulating,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkbenchDisplay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // 1. Protoboard, Bateria 9V com Falhas e Letreiro
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _electronAnimController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: LetrerosLedBreadboardPainter(
                      animationValue: _electronAnimController.value,
                      usePhysicalStyle: _usePhysicalStyle,
                      isClosed: _allFixed,
                      signTitle: _allFixed ? 'SAÍDA ➔' : 'APAGADO',
                      signColor: _allFixed ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      hasResistor: true,
                      resistorValue: '680 Ω',
                      resistorInCorrectTrack: _m3ResistorInBranch,
                      hasLed: true,
                      ledDirectPolarity: _m3LedRotated,
                      jumperConnected: _m3WireConnected,
                    ),
                  );
                },
              ),
            ),

            // 2. Painel de Investigação de Hipóteses
            Positioned(
              left: 20,
              bottom: 14,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _allFixed ? const Color(0xFF10B981) : Colors.amberAccent,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_allFixed ? const Color(0xFF10B981) : Colors.amberAccent)
                          .withValues(alpha: 0.16),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        Icon(
                          _allFixed ? Icons.check_circle_rounded : Icons.search_rounded,
                          color: _allFixed ? const Color(0xFF10B981) : Colors.amberAccent,
                          size: 18,
                        ),
                        Text(
                          _allFixed
                              ? 'Diagnóstico Concluído: Circuito 100% Restaurado!'
                              : 'Investigação de Falhas (Testar Hipóteses na Protoboard):',
                          style: GoogleFonts.rajdhani(
                            color: _allFixed ? const Color(0xFF10B981) : Colors.amberAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        // H1: Conectar Fio Jumper
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _m3WireConnected
                                ? const Color(0xFF10B981)
                                : const Color(0xFF1E293B),
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: _m3WireConnected
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF475569),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: Icon(
                            _m3WireConnected ? Icons.check : Icons.cable_rounded,
                            size: 16,
                          ),
                          label: Text(
                            _m3WireConnected
                                ? 'H1: Jumper Conectado'
                                : 'H1: Fechar Jumper Aberto',
                            style: GoogleFonts.rajdhani(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          onPressed: () {
                            final prev = _m3WireConnected;
                            _undoRedoController.execute(ToggleBoolAction(
                              description: 'Conectar Jumper',
                              onApply: () =>
                                  setState(() => _m3WireConnected = !prev),
                              onUndo: () =>
                                  setState(() => _m3WireConnected = prev),
                            ));
                          },
                        ),

                        // H2: Resistor no Trilho
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _m3ResistorInBranch
                                ? const Color(0xFF10B981)
                                : const Color(0xFF1E293B),
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: _m3ResistorInBranch
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF475569),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: Icon(
                            _m3ResistorInBranch ? Icons.check : Icons.security_rounded,
                            size: 16,
                          ),
                          label: Text(
                            _m3ResistorInBranch
                                ? 'H2: Resistor no Trilho'
                                : 'H2: Alinhar Resistor no Ramo',
                            style: GoogleFonts.rajdhani(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          onPressed: () {
                            final prev = _m3ResistorInBranch;
                            _undoRedoController.execute(ToggleBoolAction(
                              description: 'Alinhar Resistor',
                              onApply: () =>
                                  setState(() => _m3ResistorInBranch = !prev),
                              onUndo: () =>
                                  setState(() => _m3ResistorInBranch = prev),
                            ));
                          },
                        ),

                        // H3: Girar LED
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _m3LedRotated
                                ? const Color(0xFF10B981)
                                : const Color(0xFF1E293B),
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: _m3LedRotated
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF475569),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: Icon(
                            _m3LedRotated ? Icons.check : Icons.rotate_right_rounded,
                            size: 16,
                          ),
                          label: Text(
                            _m3LedRotated
                                ? 'H3: LED Orientado [A(+) → K(-)]'
                                : 'H3: Inverter LED na Protoboard',
                            style: GoogleFonts.rajdhani(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          onPressed: () {
                            final prev = _m3LedRotated;
                            _undoRedoController.execute(ToggleBoolAction(
                              description: 'Girar LED',
                              onApply: () =>
                                  setState(() => _m3LedRotated = !prev),
                              onUndo: () =>
                                  setState(() => _m3LedRotated = prev),
                            ));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSideInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Diagnóstico de Falhas:',
          style: GoogleFonts.rajdhani(
            color: const Color(0xFF0284C7),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Ao depurar um circuito que não funciona, inspecione sistematicamente: continuidade dos jumpers, alinhamento dos resistores nos furos corretos da protoboard e orientação do LED!',
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

  int get _currentStepperIndex {
    if (!_m3WireConnected) return 0;
    if (!_m3ResistorInBranch) return 1;
    if (!_m3LedRotated) return 2;
    return 3;
  }

  bool _isStepCompleted(int index) {
    if (index == 0) return _m3WireConnected;
    if (index == 1) return _m3ResistorInBranch;
    if (index == 2) return _m3LedRotated;
    if (index == 3) return _allFixed;
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
      title: 'Diagnóstico de defeitos',
      currentStepIndex: _currentStepperIndex,
      isStepCompleted: _isStepCompleted,
      steps: const [
        'Conectar jumper rompido na alimentação',
        'Inserir resistor limitador no trilho',
        'Girar LED para polarização direta',
        'Validar restauração do letreiro',
      ],
    );
  }
}
