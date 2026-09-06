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
import '../widgets/letreros_led_widgets.dart';

/// Missão 5 do Estande 05 — Entrada e Saída (Ramos Independentes).
class LetrerosLedM5 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const LetrerosLedM5({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<LetrerosLedM5> createState() => _LetrerosLedM5State();
}

class _LetrerosLedM5State extends State<LetrerosLedM5> {
  final StandMission _mission = StandMission.letrerosLedMissions[4];
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  bool _usePhysicalStyle = true;
  bool _isSimulating = false;

  bool _m5BranchEntradaActive = false;
  bool _m5BranchSaidaActive = false;
  bool _m5OneBranchDisconnected = false;
  String? _prediction;

  bool get _isClosed =>
      _m5BranchEntradaActive ||
      (_m5BranchSaidaActive && !_m5OneBranchDisconnected);

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
        question: 'Se remover um ramo, o que acontece com o outro?',
        options: const [
          'Continua aceso',
          'Apaga junto',
          'Fica mais fraco',
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
        question: 'Por que cada placa precisa de resistor próprio?',
        options: const [
          'Cada ramo paralelo precisa limitar sua corrente',
          'O resistor protege a bateria',
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

      if (_m5BranchEntradaActive && _m5BranchSaidaActive) {
        final result = await MissionCircuitBuilder()
            .addBattery(id: 'bat1', voltage: 9.0)
            .addResistor(id: 'r1', resistance: 680.0)
            .addLed(id: 'led_entrada', reversed: false)
            .connect('bat1', 'B', 'r1', 'A')
            .connect('r1', 'B', 'led_entrada', 'A')
            .connect('led_entrada', 'B', 'bat1', 'A')
            .addResistor(id: 'r2', resistance: 680.0)
            .addLed(id: 'led_saida', reversed: false)
            .connect('bat1', 'B', 'r2', 'A')
            .connect('r2', 'B', 'led_saida', 'A')
            .connect('led_saida', 'B', 'bat1', 'A')
            .simulate();
        if (result.hasClosedLoop && result.errorMessage == null) {
          feedbackMessage =
              'Letreiros de Entrada e Saída montados em ramos independentes! Ao desligar ou remover um ramo, o outro continua aceso.';
          isSuccess = true;
        } else {
          feedbackMessage = result.errorMessage ??
              'Construa os dois ramos com seus próprios resistores.';
        }
      } else {
        feedbackMessage =
            'Construa letreiros de Entrada e Saída independentes, cada um com seu LED e resistor próprios de 680 Ω.';
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
            leftHeaderWidget: buildLetrerosLedStatusCard(_isClosed),
            rightHeaderWidget: buildLetrerosLedTelemetryCard(
              9.0,
              _isClosed ? 20.6 : 0.0,
              _isClosed,
            ),
            bottomWidget: _buildUndoRedoButtons(),
            child: _buildSignDisplay(),
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

  Widget _buildSignDisplay() {
    final entradaLit = _m5BranchEntradaActive;
    final saidaLit = _m5BranchSaidaActive && !_m5OneBranchDisconnected;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buildLetrerosLedSignBoard(
              title: 'ENTRADA',
              color: const Color(0xFF10B981),
              isLit: entradaLit,
            ),
            buildLetrerosLedSignBoard(
              title: _m5OneBranchDisconnected ? 'SAÍDA (REMOVIDO)' : 'SAÍDA',
              color: _m5OneBranchDisconnected ? Colors.grey : Colors.redAccent,
              isLit: saidaLit,
              isBurnt: _m5OneBranchDisconnected,
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: (entradaLit && _m5BranchSaidaActive)
                  ? const Color(0xFF10B981)
                  : Colors.amberAccent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _m5BranchEntradaActive
                          ? const Color(0xFF10B981)
                          : const Color(0xFF1E293B),
                      side: const BorderSide(color: Color(0xFF10B981)),
                    ),
                    icon: Icon(
                      _m5BranchEntradaActive
                          ? Icons.check
                          : Icons.add_circle_outline_rounded,
                      color: Colors.white,
                    ),
                    label: Text(
                      _m5BranchEntradaActive
                          ? 'Ramo Entrada Montado (680Ω)'
                          : 'Montar Ramo Entrada (680Ω)',
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      final prev = _m5BranchEntradaActive;
                      _undoRedoController.execute(ToggleBoolAction(
                        description: 'Toggle Ramo Entrada',
                        onApply: () =>
                            setState(() => _m5BranchEntradaActive = !prev),
                        onUndo: () =>
                            setState(() => _m5BranchEntradaActive = prev),
                      ));
                    },
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _m5BranchSaidaActive
                          ? const Color(0xFF10B981)
                          : const Color(0xFF1E293B),
                      side: const BorderSide(color: Color(0xFF10B981)),
                    ),
                    icon: Icon(
                      _m5BranchSaidaActive
                          ? Icons.check
                          : Icons.add_circle_outline_rounded,
                      color: Colors.white,
                    ),
                    label: Text(
                      _m5BranchSaidaActive
                          ? 'Ramo Saída Montado (680Ω)'
                          : 'Montar Ramo Saída (680Ω)',
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      final prev = _m5BranchSaidaActive;
                      _undoRedoController.execute(ToggleBoolAction(
                        description: 'Toggle Ramo Saída',
                        onApply: () =>
                            setState(() => _m5BranchSaidaActive = !prev),
                        onUndo: () =>
                            setState(() => _m5BranchSaidaActive = prev),
                      ));
                    },
                  ),
                ],
              ),
              if (_m5BranchEntradaActive && _m5BranchSaidaActive) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF38BDF8)),
                    backgroundColor: const Color(0xFF1E293B),
                  ),
                  icon: Icon(
                    _m5OneBranchDisconnected
                        ? Icons.power_off_rounded
                        : Icons.power_rounded,
                    color: const Color(0xFF38BDF8),
                  ),
                  label: Text(
                    _m5OneBranchDisconnected
                        ? 'Demonstrativo: Ramo Saída Desconectado (Entrada Continua Aceso!)'
                        : 'Simular Remoção do Ramo Saída pela Banca',
                    style: GoogleFonts.rajdhani(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    final prev = _m5OneBranchDisconnected;
                    _undoRedoController.execute(ToggleBoolAction(
                      description: 'Remover Ramo para Teste',
                      onApply: () =>
                          setState(() => _m5OneBranchDisconnected = !prev),
                      onUndo: () =>
                          setState(() => _m5OneBranchDisconnected = prev),
                    ));
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSideInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Independência dos Ramos:',
          style: GoogleFonts.rajdhani(
            color: const Color(0xFF0284C7),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Cada ramo paralelo possui seu próprio resistor limitador de 680Ω. Se um letreiro falhar ou for desconectado, o outro permanece funcionando com tensão e corrente nominais!',
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
    if (_prediction == null) return 0;
    if (!_m5BranchEntradaActive || !_m5BranchSaidaActive) return 1;
    return 2;
  }

  bool _isStepCompleted(int index) {
    if (index == 0) return _prediction != null;
    if (index == 1) return _m5BranchEntradaActive && _m5BranchSaidaActive;
    if (index == 2) return _m5OneBranchDisconnected;
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
      title: 'Independência dos ramos',
      currentStepIndex: _currentStepperIndex,
      isStepCompleted: _isStepCompleted,
      steps: const [
        'Prever comportamento do circuito paralelo',
        'Acender ramos de Entrada e Saída simultaneamente',
        'Desconectar um ramo e comprovar funcionamento do outro',
      ],
    );
  }
}
