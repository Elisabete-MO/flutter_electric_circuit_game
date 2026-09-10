import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/circuit_action.dart';
import '../../../models/first_step_component.dart';
import '../../../models/stand_mission.dart';
import '../../../services/circuit_solver/mission_circuit_builder.dart';
import '../../../state/circuit_undo_redo_controller.dart';
import '../../../widgets/circuit_symbol_painter.dart';
import '../../../widgets/component_physical_painter.dart';
import '../../../widgets/prof_volts_explanation_dialog.dart';
import '../../../widgets/prof_volts_feedback_dialog.dart';
import '../../../widgets/prof_volts_prediction_dialog.dart';
import '../../../widgets/success_confetti_overlay.dart';
import '../../../widgets/workbench_components.dart';
import '../../../widgets/workbench_sidebar_cards.dart';
import '../../../widgets/workbench_table_frame.dart';
import '../widgets/letreros_led_breadboard_painter.dart';
import '../widgets/letreros_led_widgets.dart';

/// Missão 1 do Estande 05 — Placa de Saída (Ânodo/Cátodo e Resistor 680 Ω).
class LetrerosLedM1 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const LetrerosLedM1({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<LetrerosLedM1> createState() => _LetrerosLedM1State();
}

class _LetrerosLedM1State extends State<LetrerosLedM1>
    with SingleTickerProviderStateMixin {
  final StandMission _mission = StandMission.letrerosLedMissions[0];
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  late AnimationController _electronAnimController;
  bool _usePhysicalStyle = true;
  bool _isSimulating = false;

  bool _m1LedDirectPolarity = true;
  bool _m1LedInserted = false;
  bool _m1ResistorInserted = true;
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
      _m1LedInserted && _m1LedDirectPolarity && _m1ResistorInserted;

  void _insertComponent({
    required String name,
    required bool Function() getInserted,
    required void Function(bool) setInserted,
  }) {
    final prevInserted = getInserted();
    final nextInserted = !prevInserted;
    _undoRedoController.execute(InsertComponentAction(
      description: nextInserted ? 'Inserir $name' : 'Remover $name',
      onApply: () => setState(() => setInserted(nextInserted)),
      onUndo: () => setState(() => setInserted(prevInserted)),
    ));
  }

  void _togglePolarity() {
    final prev = _m1LedDirectPolarity;
    _undoRedoController.execute(ToggleBoolAction(
      description: 'Alternar polaridade do LED',
      onApply: () => setState(() => _m1LedDirectPolarity = !prev),
      onUndo: () => setState(() => _m1LedDirectPolarity = prev),
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
        question:
            'O que acontecerá ao energizar com R680Ω e LED em polaridade direta?',
        options: const [
          'LED acende normalmente e aciona letreiro',
          'LED não acende',
          'LED queima por falta de resistor',
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
        question: 'Por que o LED precisa de resistor e polaridade correta?',
        options: const [
          'Resistor limita corrente; LED é um diodo que conduz em um só sentido',
          'Resistor divide tensão; LED é bidirecional',
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

      if (_m1LedInserted && _m1LedDirectPolarity && _m1ResistorInserted) {
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
              'Letreiro SAÍDA aceso com corrente segura (${currentMa.toStringAsFixed(1)}mA)! Ânodo (+) e Cátodo (-) ligados com resistor limitador de 680 Ω na protoboard.';
          isSuccess = true;
        } else {
          feedbackMessage = result.errorMessage ??
              'Verifique a montagem da Placa de Saída na protoboard.';
        }
      } else if (!_m1ResistorInserted) {
        feedbackMessage = 'Insira o resistor de proteção de 680 Ω na protoboard!';
      } else if (!_m1LedInserted) {
        feedbackMessage = 'Insira o LED no soquete da protoboard!';
      } else {
        feedbackMessage =
            'Verifique a polaridade do LED: a corrente contínua só passa no sentido ânodo (+) para cátodo (-).';
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
          _isClosed ? 10.3 : 0.0,
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
          _buildSideToolboxDrawer(),
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
            // 1. Desenho da Protoboard, Bateria 9V, Fios e Letreiro
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _electronAnimController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: LetrerosLedBreadboardPainter(
                      animationValue: _electronAnimController.value,
                      usePhysicalStyle: _usePhysicalStyle,
                      isClosed: _isClosed,
                      signTitle: 'SAÍDA ➔',
                      signColor: const Color(0xFFEF4444),
                      hasResistor: _m1ResistorInserted,
                      resistorValue: '680 Ω',
                      hasLed: _m1LedInserted,
                      ledDirectPolarity: _m1LedDirectPolarity,
                      jumperConnected: true,
                    ),
                  );
                },
              ),
            ),

            // 2. Painel Interativo de Bancada
            Positioned(
              left: 20,
              bottom: 16,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF334155)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Botão Inserir/Remover LED
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _m1LedInserted
                            ? const Color(0xFF0284C7)
                            : const Color(0xFF1E293B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: Icon(
                        _m1LedInserted
                            ? Icons.check_circle_rounded
                            : Icons.add_circle_outline_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: Text(
                        _m1LedInserted
                            ? 'LED Vermelho Inserido'
                            : 'Inserir LED na Protoboard',
                        style: GoogleFonts.rajdhani(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      onPressed: () => _insertComponent(
                        name: 'LED Vermelho',
                        getInserted: () => _m1LedInserted,
                        setInserted: (v) => _m1LedInserted = v,
                      ),
                    ),

                    // Botão Inverter Polaridade do LED
                    if (_m1LedInserted)
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E293B),
                          side: BorderSide(
                            color: _m1LedDirectPolarity
                                ? const Color(0xFF10B981)
                                : Colors.amberAccent,
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: Icon(
                          Icons.flip_camera_android_rounded,
                          size: 18,
                          color: _m1LedDirectPolarity
                              ? const Color(0xFF10B981)
                              : Colors.amberAccent,
                        ),
                        label: Text(
                          _m1LedDirectPolarity
                              ? 'Polaridade: Direta [A(+) → K(-)]'
                              : 'Polaridade: Invertida [K(-) → A(+)]',
                          style: GoogleFonts.rajdhani(
                            color: _m1LedDirectPolarity
                                ? const Color(0xFF10B981)
                                : Colors.amberAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        onPressed: _togglePolarity,
                      ),

                    // Botão Resistor 680 Ω
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _m1ResistorInserted
                            ? const Color(0xFF059669)
                            : const Color(0xFF1E293B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: Icon(
                        _m1ResistorInserted
                            ? Icons.verified_rounded
                            : Icons.add_circle_outline_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: Text(
                        _m1ResistorInserted
                            ? 'Resistor 680 Ω Conectado'
                            : 'Inserir Resistor 680 Ω',
                        style: GoogleFonts.rajdhani(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      onPressed: () => _insertComponent(
                        name: 'Resistor 680 Ω',
                        getInserted: () => _m1ResistorInserted,
                        setInserted: (v) => _m1ResistorInserted = v,
                      ),
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

  Widget _buildSideToolboxDrawer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
          child: Text(
            'Componentes da Bancada:',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _insertComponent(
                name: 'LED Vermelho',
                getInserted: () => _m1LedInserted,
                setInserted: (v) => _m1LedInserted = v,
              ),
              child: WorkbenchSymbolToolboxTile<String>(
                data: 'led_red',
                label: 'LED Vermelho',
                tooltip: 'Toque para inserir na protoboard',
                symbolWidget: _usePhysicalStyle
                    ? CustomPaint(
                        size: const Size(44, 44),
                        painter: ComponentPhysicalPainter(
                          type: ComponentType.led,
                          isActive: true,
                          isDarkMode: false,
                        ),
                      )
                    : CustomPaint(
                        size: const Size(40, 30),
                        painter: CircuitSymbolPainter(
                          type: ComponentType.led,
                          isActive: true,
                          color: const Color(0xFF0F172A),
                          strokeWidth: 2.2,
                        ),
                      ),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _insertComponent(
                name: 'Resistor 680 Ω',
                getInserted: () => _m1ResistorInserted,
                setInserted: (v) => _m1ResistorInserted = v,
              ),
              child: WorkbenchSymbolToolboxTile<String>(
                data: 'resistor_680',
                label: 'Resistor 680 Ω',
                tooltip: 'Limita corrente para proteger o LED',
                symbolWidget: _usePhysicalStyle
                    ? CustomPaint(
                        size: const Size(44, 44),
                        painter: ComponentPhysicalPainter(
                          type: ComponentType.resistor,
                          isActive: true,
                          isDarkMode: false,
                        ),
                      )
                    : CustomPaint(
                        size: const Size(40, 30),
                        painter: CircuitSymbolPainter(
                          type: ComponentType.resistor,
                          isActive: true,
                          color: const Color(0xFF0F172A),
                          strokeWidth: 2.2,
                        ),
                      ),
              ),
            ),
          ],
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
    if (!_m1LedInserted || !_m1ResistorInserted || !_m1LedDirectPolarity) return 1;
    return 2;
  }

  bool _isStepCompleted(int index) {
    if (index == 0) return _prediction != null;
    if (index == 1) return _m1LedInserted && _m1ResistorInserted;
    if (index == 2) return _isClosed;
    return false;
  }

  Widget _buildMissionObjectiveCard() {
    return WorkbenchMissionObjectiveCard(
      missionNumber: 1,
      title: _mission.title,
      description: _mission.objective,
      voltsTip: _mission.voltsMediation,
      accentColor: const Color(0xFF0284C7),
    );
  }

  Widget _buildInvestigationStepperCard() {
    return WorkbenchInvestigationStepperCard(
      title: 'Progresso da polarização',
      currentStepIndex: _currentStepperIndex,
      isStepCompleted: _isStepCompleted,
      steps: const [
        'Registrar previsão de acendimento',
        'Encaixar LED e Resistor 680 Ω na Protoboard',
        'Energizar e verificar luminosidade do Letreiro',
      ],
    );
  }
}
