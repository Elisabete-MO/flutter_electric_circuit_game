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
import '../../../widgets/workbench_table_frame.dart';
import '../widgets/letreros_led_widgets.dart';

/// Missão 4 do Estande 05 — Brilho com responsabilidade (Escolha de Resistor).
class LetrerosLedM4 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const LetrerosLedM4({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<LetrerosLedM4> createState() => _LetrerosLedM4State();
}

class _LetrerosLedM4State extends State<LetrerosLedM4> {
  final StandMission _mission = StandMission.letrerosLedMissions[3];
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  bool _usePhysicalStyle = true;
  bool _isSimulating = false;

  String? _m4SelectedResistor;
  String? _prediction;

  bool get _isClosed => _m4SelectedResistor == '680';

  double get _currentMa {
    if (_m4SelectedResistor == '68') return 103.0;
    if (_m4SelectedResistor == '6800') return 1.0;
    if (_m4SelectedResistor == '680') return 10.3;
    return 0.0;
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
        question: 'Qual resistor oferece brilho seguro para o LED?',
        options: const [
          '68Ω (muito baixo)',
          '680Ω (ideal)',
          '6,8kΩ (muito alto)',
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
        question:
            'Por que o LED fica inseguro com resistor pequeno e fraco com grande?',
        options: const [
          'R baixo → corrente alta; R alto → corrente baixa',
          'R baixo → pouca queda; R alto → muita queda',
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

      if (_m4SelectedResistor != null) {
        final resistance = double.parse(_m4SelectedResistor!);
        final result = await MissionCircuitBuilder()
            .addBattery(id: 'bat1', voltage: 9.0)
            .addResistor(id: 'r1', resistance: resistance)
            .addLed(id: 'led1')
            .connect('bat1', 'B', 'r1', 'A')
            .connect('r1', 'B', 'led1', 'A')
            .connect('led1', 'B', 'bat1', 'A')
            .simulate();
        if (result.hasClosedLoop && result.errorMessage == null) {
          final currentMa = result.current * 1000;
          if (resistance == 680.0) {
            feedbackMessage =
                'Resistor de 680 Ω escolhido! Corrente de ${currentMa.toStringAsFixed(1)}mA garante excelente brilho com segurança total.';
            isSuccess = true;
          } else if (resistance == 68.0) {
            feedbackMessage =
                'Corrente excessiva (${currentMa.toStringAsFixed(1)}mA)! Resistor de 68 Ω é baixo demais e pode queimar o LED.';
          } else {
            feedbackMessage =
                'Corrente muito baixa (${currentMa.toStringAsFixed(1)}mA)! Resistor de 6,8 kΩ deixa a iluminação fraca demais.';
          }
        } else {
          feedbackMessage =
              result.errorMessage ?? 'Erro na montagem do resistor.';
        }
      } else {
        feedbackMessage =
            'Compare 68 Ω, 680 Ω e 6,8 kΩ na montagem e selecione o resistor ideal.';
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
              _currentMa,
              _m4SelectedResistor != null,
            ),
            bottomWidget: _buildUndoRedoButtons(),
            child: _buildSignDisplay(),
          ),
        ),
        const SizedBox(width: 16),
        // Painel Lateral (Briefing & Investigação)
        Expanded(
          flex: 3,
          child: WorkbenchSidePanel(
            teamTitle: 'Painel da Equipe Sinalização',
            toolboxItems: [
              _buildMissionBriefingCard(),
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
    final isIdeal = _m4SelectedResistor == '680';
    final isBurnt = _m4SelectedResistor == '68';
    final isTooWeak = _m4SelectedResistor == '6800';

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildLetrerosLedSignBoard(
          title: isBurnt ? 'SOBRECORRENTE!' : 'ENTRADA',
          color: isBurnt
              ? Colors.redAccent
              : isIdeal
                  ? const Color(0xFF10B981)
                  : Colors.amber,
          isLit: isIdeal || isBurnt,
          isBurnt: isBurnt,
          isDim: isTooWeak,
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isIdeal ? const Color(0xFF10B981) : Colors.white24,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(
                'Resistor em Série Selecionado: ${_m4SelectedResistor == '6800' ? '6,8 k' : (_m4SelectedResistor ?? 'Nenhum')} ${_m4SelectedResistor != null ? 'Ω' : ''}',
                style: GoogleFonts.rajdhani(
                  color: Colors.amberAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildResistorChip('68 Ω (Baixo)', '68'),
                  _buildResistorChip('680 Ω (Ideal)', '680'),
                  _buildResistorChip('6,8 kΩ (Alto)', '6800'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResistorChip(String label, String value) {
    final isSelected = _m4SelectedResistor == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        final prev = _m4SelectedResistor;
        final next = val ? value : null;
        _undoRedoController.execute(SelectOptionAction(
          description: 'Selecionar Resistor $value Ω',
          onApply: () => setState(() => _m4SelectedResistor = next),
          onUndo: () => setState(() => _m4SelectedResistor = prev),
        ));
      },
      selectedColor: const Color(0xFF10B981),
      backgroundColor: const Color(0xFF1E293B),
      labelStyle: GoogleFonts.rajdhani(
        color: isSelected ? Colors.white : Colors.white70,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSideInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dimensionamento de Resistor:',
          style: GoogleFonts.rajdhani(
            color: const Color(0xFF0284C7),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Pela Primeira Lei de Ohm, R = (V_fonte - V_led) / I_desejada. Para 9V e LED de 2V com ~10mA, R = 700Ω (usamos o comercial de 680Ω)!',
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
