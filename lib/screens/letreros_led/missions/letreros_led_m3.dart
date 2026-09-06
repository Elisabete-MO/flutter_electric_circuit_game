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

class _LetrerosLedM3State extends State<LetrerosLedM3> {
  final StandMission _mission = StandMission.letrerosLedMissions[2];
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  bool _usePhysicalStyle = true;
  bool _isSimulating = false;

  bool _m3LedRotated = false;
  bool _m3WireConnected = false;
  bool _m3ResistorInBranch = false;
  String? _prediction;

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
        question: 'A placa não acende. Qual a causa mais provável?',
        options: const [
          'LED invertido',
          'Fio aberto',
          'Resistor fora',
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
        question: 'Qual evidência mostrou a falha real?',
        options: const [
          'Medição de tensão / inspeção visual',
          'Teste de continuidade',
          'Substituição de componente',
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
          feedbackMessage =
              'Excelente investigação! Todas as 3 causas (LED invertido, fio aberto e resistor fora do ramo) foram diagnosticadas e corrigidas.';
          isSuccess = true;
        } else {
          feedbackMessage =
              result.errorMessage ?? 'Ainda há um problema na placa.';
        }
      } else {
        final missing = <String>[];
        if (!_m3LedRotated) missing.add('LED invertido');
        if (!_m3WireConnected) missing.add('Fio aberto');
        if (!_m3ResistorInBranch) missing.add('Resistor fora do ramo');
        feedbackMessage =
            'Verifique e corrija as falhas encontradas: ${missing.join(", ")}.';
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildLetrerosLedSignBoard(
          title: _allFixed ? 'SAÍDA (OK!)' : 'APAGADO',
          color: _allFixed ? const Color(0xFF10B981) : Colors.redAccent,
          isLit: _allFixed,
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _allFixed ? const Color(0xFF10B981) : Colors.amberAccent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(
                'Painel de Investigação de Falhas (Testar Hipóteses):',
                style: GoogleFonts.rajdhani(
                  color: Colors.amberAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _m3LedRotated
                          ? const Color(0xFF10B981)
                          : const Color(0xFF1E293B),
                      side: const BorderSide(color: Color(0xFF10B981)),
                    ),
                    icon: Icon(
                      _m3LedRotated ? Icons.check : Icons.rotate_right_rounded,
                      color: Colors.white,
                    ),
                    label: Text(
                      _m3LedRotated
                          ? 'H1: LED Girado (Ok)'
                          : 'H1: Girar LED Invertido',
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      final prev = _m3LedRotated;
                      _undoRedoController.execute(ToggleBoolAction(
                        description: 'Girar LED',
                        onApply: () =>
                            setState(() => _m3LedRotated = !prev),
                        onUndo: () => setState(() => _m3LedRotated = prev),
                      ));
                    },
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _m3WireConnected
                          ? const Color(0xFF10B981)
                          : const Color(0xFF1E293B),
                      side: const BorderSide(color: Color(0xFF10B981)),
                    ),
                    icon: Icon(
                      _m3WireConnected ? Icons.check : Icons.cable_rounded,
                      color: Colors.white,
                    ),
                    label: Text(
                      _m3WireConnected
                          ? 'H2: Fio Conectado (Ok)'
                          : 'H2: Fechar Fio Aberto',
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      final prev = _m3WireConnected;
                      _undoRedoController.execute(ToggleBoolAction(
                        description: 'Conectar Fio',
                        onApply: () =>
                            setState(() => _m3WireConnected = !prev),
                        onUndo: () =>
                            setState(() => _m3WireConnected = prev),
                      ));
                    },
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _m3ResistorInBranch
                          ? const Color(0xFF10B981)
                          : const Color(0xFF1E293B),
                      side: const BorderSide(color: Color(0xFF10B981)),
                    ),
                    icon: Icon(
                      _m3ResistorInBranch ? Icons.check : Icons.security_rounded,
                      color: Colors.white,
                    ),
                    label: Text(
                      _m3ResistorInBranch
                          ? 'H3: Resistor no Ramo (Ok)'
                          : 'H3: Inserir Resistor no Ramo',
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      final prev = _m3ResistorInBranch;
                      _undoRedoController.execute(ToggleBoolAction(
                        description: 'Inserir Resistor',
                        onApply: () =>
                            setState(() => _m3ResistorInBranch = !prev),
                        onUndo: () =>
                            setState(() => _m3ResistorInBranch = prev),
                      ));
                    },
                  ),
                ],
              ),
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
          'Diagnóstico de Falhas:',
          style: GoogleFonts.rajdhani(
            color: const Color(0xFF0284C7),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Ao depurar um circuito que não funciona, teste sistematicamente cada hipótese: continuidade física dos fios, valor/posição dos resistores e polaridade dos semicondutores!',
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
    if (!_m3LedRotated) return 1;
    if (!_m3ResistorInBranch) return 2;
    return 3;
  }

  bool _isStepCompleted(int index) {
    if (index == 0) return _m3WireConnected;
    if (index == 1) return _m3LedRotated;
    if (index == 2) return _m3ResistorInBranch;
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
        'Conectar fio rompido',
        'Girar LED para polarização direta',
        'Inserir resistor limitador no ramo',
        'Validar restauração do letreiro',
      ],
    );
  }
}
