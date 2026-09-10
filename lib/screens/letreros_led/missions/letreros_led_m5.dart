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

/// Missão 5 do Estande 05 — Entrada e Saída (Ramos Independentes em Paralelo).
class LetrerosLedM5 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const LetrerosLedM5({super.key, required this.onMissionComplete});

  @override
  State<LetrerosLedM5> createState() => _LetrerosLedM5State();
}

class _LetrerosLedM5State extends State<LetrerosLedM5>
    with SingleTickerProviderStateMixin {
  final StandMission _mission = StandMission.letrerosLedMissions[4];
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  late AnimationController _electronAnimController;
  bool _usePhysicalStyle = true;
  bool _isSimulating = false;

  bool _m5BranchEntradaActive = false;
  bool _m5BranchSaidaActive = false;
  bool _m5OneBranchDisconnected = false;
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

  bool get _isClosed =>
      _m5BranchEntradaActive ||
      (_m5BranchSaidaActive && !_m5OneBranchDisconnected);

  double get _currentTelemetryMa {
    double ma = 0.0;
    if (_m5BranchEntradaActive) ma += 10.3;
    if (_m5BranchSaidaActive && !_m5OneBranchDisconnected) ma += 10.3;
    return ma;
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
        question:
            'Em um circuito paralelo com resistores dedicados, o que acontece ao desligar um letreiro?',
        options: const [
          'O outro continua aceso com corrente estável',
          'Ambos apagam imediatamente',
          'O outro letreiro queima',
          'Não sei',
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
            'Por que cada ramo paralelo precisa de seu próprio resistor limitador?',
        options: const [
          'Para garantir que a corrente em cada LED seja independente e segura',
          'Porque a bateria só funciona se houver mais de um resistor',
          'Não sei explicar',
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
          final totalMa = result.current * 1000;
          feedbackMessage =
              'Letreiros de ENTRADA e SAÍDA funcionando em paralelo! Corrente total: ${totalMa.toStringAsFixed(1)}mA (~10.3 mA por ramo). A independência dos ramos foi demonstrada com maestria!';
          isSuccess = true;
        } else {
          feedbackMessage =
              result.errorMessage ??
              'Construa os dois ramos com seus próprios resistores.';
        }
      } else {
        feedbackMessage =
            'Construa ambos os ramos na protoboard: ENTRADA (Verde + 680 Ω) e SAÍDA (Vermelho + 680 Ω).';
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
        leftHeaderWidget: buildLetrerosLedStatusCard(_isClosed),
        rightHeaderWidget: buildLetrerosLedTelemetryCard(
          9.0,
          _currentTelemetryMa,
          _isClosed,
        ),
        bottomWidget: _buildUndoRedoButtons(),
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
          _buildSideInstructions(),
        ],
        onEnergizePressed: _onEnergizePressed,
        isLoading: _isSimulating,
      ),
    );
  }

  Widget _buildWorkbenchDisplay() {
    final entradaLit = _m5BranchEntradaActive;
    final saidaLit = _m5BranchSaidaActive && !_m5OneBranchDisconnected;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // 1. Protoboard com 2 Ramos em Paralelo e Letreiros Duplos
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _electronAnimController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: LetrerosLedBreadboardPainter(
                      animationValue: _electronAnimController.value,
                      usePhysicalStyle: _usePhysicalStyle,
                      isClosed: saidaLit,
                      signTitle: _m5OneBranchDisconnected
                          ? 'DESCONECTADO'
                          : 'SAÍDA ➔',
                      signColor: _m5OneBranchDisconnected
                          ? Colors.grey
                          : const Color(0xFFEF4444),
                      secondSignTitle: 'ENTRADA ➔',
                      secondSignColor: const Color(0xFF10B981),
                      secondSignLit: entradaLit,
                      secondBranchActive: true,
                      hasResistor:
                          _m5BranchSaidaActive && !_m5OneBranchDisconnected,
                      resistorValue: '680 Ω',
                      hasLed: _m5BranchSaidaActive && !_m5OneBranchDisconnected,
                      ledDirectPolarity: true,
                      jumperConnected:
                          _m5BranchSaidaActive && !_m5OneBranchDisconnected,
                    ),
                  );
                },
              ),
            ),

            // 2. Painel Inferior de Controle dos Ramos
            Positioned(
              left: 16,
              bottom: 12,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (entradaLit && saidaLit)
                        ? const Color(0xFF10B981)
                        : const Color(0xFF38BDF8),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Botão Ramo Entrada (Verde)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _m5BranchEntradaActive
                            ? const Color(0xFF10B981)
                            : const Color(0xFF1E293B),
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF10B981)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: Icon(
                        _m5BranchEntradaActive
                            ? Icons.check_circle_rounded
                            : Icons.add_circle_outline_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: Text(
                        _m5BranchEntradaActive
                            ? 'Ramo ENTRADA Ativo (Verde)'
                            : 'Montar Ramo ENTRADA',
                        style: GoogleFonts.rajdhani(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      onPressed: () {
                        final prev = _m5BranchEntradaActive;
                        _undoRedoController.execute(
                          ToggleBoolAction(
                            description: 'Toggle Ramo Entrada',
                            onApply: () =>
                                setState(() => _m5BranchEntradaActive = !prev),
                            onUndo: () =>
                                setState(() => _m5BranchEntradaActive = prev),
                          ),
                        );
                      },
                    ),

                    // Botão Ramo Saída (Vermelho)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _m5BranchSaidaActive
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF1E293B),
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFEF4444)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: Icon(
                        _m5BranchSaidaActive
                            ? Icons.check_circle_rounded
                            : Icons.add_circle_outline_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: Text(
                        _m5BranchSaidaActive
                            ? 'Ramo SAÍDA Ativo (Vermelho)'
                            : 'Montar Ramo SAÍDA',
                        style: GoogleFonts.rajdhani(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      onPressed: () {
                        final prev = _m5BranchSaidaActive;
                        _undoRedoController.execute(
                          ToggleBoolAction(
                            description: 'Toggle Ramo Saída',
                            onApply: () =>
                                setState(() => _m5BranchSaidaActive = !prev),
                            onUndo: () =>
                                setState(() => _m5BranchSaidaActive = prev),
                          ),
                        );
                      },
                    ),

                    // Botão Demonstrativo de Remoção do Ramo Saída
                    if (_m5BranchEntradaActive && _m5BranchSaidaActive)
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: _m5OneBranchDisconnected
                                ? Colors.amberAccent
                                : const Color(0xFF38BDF8),
                            width: 1.5,
                          ),
                          backgroundColor: const Color(0xFF1E293B),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: Icon(
                          _m5OneBranchDisconnected
                              ? Icons.power_off_rounded
                              : Icons.power_rounded,
                          color: _m5OneBranchDisconnected
                              ? Colors.amberAccent
                              : const Color(0xFF38BDF8),
                          size: 18,
                        ),
                        label: Text(
                          _m5OneBranchDisconnected
                              ? 'Ramo SAÍDA Desconectado (ENTRADA segue 100% aceso!)'
                              : 'Simular Desconexão de um Ramo',
                          style: GoogleFonts.rajdhani(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        onPressed: () {
                          final prev = _m5OneBranchDisconnected;
                          _undoRedoController.execute(
                            ToggleBoolAction(
                              description: 'Desconectar Ramo',
                              onApply: () => setState(
                                () => _m5OneBranchDisconnected = !prev,
                              ),
                              onUndo: () => setState(
                                () => _m5OneBranchDisconnected = prev,
                              ),
                            ),
                          );
                        },
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
          'Independência dos Ramos:',
          style: GoogleFonts.rajdhani(
            color: const Color(0xFF0284C7),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Cada ramo paralelo possui seu próprio resistor limitador de 680 Ω. Ao desconectar ou desligar o letreiro de Saída, o letreiro de Entrada permanece funcionando perfeitamente!',
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
