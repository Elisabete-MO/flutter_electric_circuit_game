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

class _LetrerosLedM4State extends State<LetrerosLedM4>
    with SingleTickerProviderStateMixin {
  final StandMission _mission = StandMission.letrerosLedMissions[3];
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  late AnimationController _electronAnimController;
  bool _usePhysicalStyle = true;
  bool _isSimulating = false;

  String? _m4SelectedResistor;
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

  bool get _isClosed => _m4SelectedResistor == '680';

  double get _currentMa {
    if (_m4SelectedResistor == '68') return 103.0;
    if (_m4SelectedResistor == '6800') return 1.0;
    if (_m4SelectedResistor == '680') return 10.3;
    return 0.0;
  }

  void _selectResistor(String value) {
    final prev = _m4SelectedResistor;
    _undoRedoController.execute(SelectOptionAction(
      description: 'Selecionar Resistor $value Ω',
      onApply: () => setState(() => _m4SelectedResistor = value),
      onUndo: () => setState(() => _m4SelectedResistor = prev),
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
        question: 'Qual resistor oferece corrente segura (~10 mA) e brilho ideal com bateria 9V?',
        options: const [
          '68 Ω (baixo - perigo de queima)',
          '680 Ω (ideal - brilho equilibrado e seguro)',
          '6,8 kΩ (muito alto - brilho imperceptível)',
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
            'Por que o LED queima com resistor muito baixo e quase não acende com resistor muito alto?',
        options: const [
          'I = (V - Vled)/R: R baixo eleva a corrente além do limite do LED; R alto reduz demais o fluxo',
          'R baixo divide muita tensão e R alto queima a bateria',
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
                'Excelente escolha! O resistor de 680 Ω limita a corrente em ${currentMa.toStringAsFixed(1)}mA, garantindo longevidade ao LED e iluminação perfeita para o letreiro ENTRADA.';
            isSuccess = true;
          } else if (resistance == 68.0) {
            feedbackMessage =
                'Cuidado! Corrente de ${currentMa.toStringAsFixed(1)}mA excede o limite do LED (máx 20mA). O componente sofreu sobrecorrente e queimou!';
          } else {
            feedbackMessage =
                'Corrente insuficiente (${currentMa.toStringAsFixed(1)}mA). Com 6,8 kΩ o letreiro fica quase invisível na escuridão.';
          }
        } else {
          feedbackMessage =
              result.errorMessage ?? 'Erro na montagem do resistor.';
        }
      } else {
        feedbackMessage =
            'Selecione um dos 3 resistores na bancada para testar o circuito.';
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
              _buildSideToolboxDrawer(),
            ],
            onEnergizePressed: _onEnergizePressed,
            isLoading: _isSimulating,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkbenchDisplay() {
    final isIdeal = _m4SelectedResistor == '680';
    final isBurnt = _m4SelectedResistor == '68';
    final isTooWeak = _m4SelectedResistor == '6800';

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // 1. Protoboard, Bateria 9V, Resistor Selecionado e Letreiro
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _electronAnimController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: LetrerosLedBreadboardPainter(
                      animationValue: _electronAnimController.value,
                      usePhysicalStyle: _usePhysicalStyle,
                      isClosed: isIdeal,
                      isBurnt: isBurnt,
                      isDim: isTooWeak,
                      signTitle: isBurnt ? 'SOBRECORRENTE!' : 'ENTRADA ➔',
                      signColor: isBurnt
                          ? const Color(0xFFEF4444)
                          : (isIdeal ? const Color(0xFF10B981) : Colors.amber),
                      hasResistor: _m4SelectedResistor != null,
                      resistorValue: _m4SelectedResistor == '68'
                          ? '68 Ω'
                          : (_m4SelectedResistor == '6800' ? '6.8 kΩ' : '680 Ω'),
                      hasLed: true,
                      ledDirectPolarity: true,
                      jumperConnected: true,
                    ),
                  );
                },
              ),
            ),

            // 2. Painel Inferior de Troca Rápida de Resistor
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
                    color: isIdeal
                        ? const Color(0xFF10B981)
                        : (isBurnt ? const Color(0xFFEF4444) : Colors.amberAccent),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Selecione o Resistor para Encaixar na Protoboard:',
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildResistorOptionButton(
                          label: '68 Ω (Baixo / 103 mA)',
                          value: '68',
                          color: const Color(0xFFEF4444),
                          icon: Icons.flash_on_rounded,
                        ),
                        _buildResistorOptionButton(
                          label: '680 Ω (Ideal / 10.3 mA)',
                          value: '680',
                          color: const Color(0xFF10B981),
                          icon: Icons.check_circle_rounded,
                        ),
                        _buildResistorOptionButton(
                          label: '6,8 kΩ (Alto / 1.0 mA)',
                          value: '6800',
                          color: const Color(0xFFF59E0B),
                          icon: Icons.wb_twilight_rounded,
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

  Widget _buildResistorOptionButton({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    final isSelected = _m4SelectedResistor == value;
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        side: BorderSide(
          color: isSelected ? color : const Color(0xFF475569),
          width: 1.5,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: Icon(icon, size: 16, color: Colors.white),
      label: Text(
        label,
        style: GoogleFonts.rajdhani(
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
      onPressed: () => _selectResistor(value),
    );
  }

  Widget _buildSideToolboxDrawer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
          child: Text(
            'Opções de Resistores:',
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
              onTap: () => _selectResistor('68'),
              child: WorkbenchSymbolToolboxTile<String>(
                data: 'r68',
                label: '68 Ω',
                tooltip: 'Azul-Cinza-Preto (Alto risco)',
                symbolWidget: _usePhysicalStyle
                    ? CustomPaint(
                        size: const Size(40, 24),
                        painter: ComponentPhysicalPainter(
                          type: ComponentType.resistor,
                          isActive: _m4SelectedResistor == '68',
                          isDarkMode: false,
                        ),
                      )
                    : CustomPaint(
                        size: const Size(40, 20),
                        painter: CircuitSymbolPainter(
                          type: ComponentType.resistor,
                          isActive: _m4SelectedResistor == '68',
                          color: const Color(0xFF0F172A),
                          strokeWidth: 2.0,
                        ),
                      ),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _selectResistor('680'),
              child: WorkbenchSymbolToolboxTile<String>(
                data: 'r680',
                label: '680 Ω (Ideal)',
                tooltip: 'Azul-Cinza-Marrom (Seguro)',
                symbolWidget: _usePhysicalStyle
                    ? CustomPaint(
                        size: const Size(40, 24),
                        painter: ComponentPhysicalPainter(
                          type: ComponentType.resistor,
                          isActive: _m4SelectedResistor == '680',
                          isDarkMode: false,
                        ),
                      )
                    : CustomPaint(
                        size: const Size(40, 20),
                        painter: CircuitSymbolPainter(
                          type: ComponentType.resistor,
                          isActive: _m4SelectedResistor == '680',
                          color: const Color(0xFF0F172A),
                          strokeWidth: 2.0,
                        ),
                      ),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _selectResistor('6800'),
              child: WorkbenchSymbolToolboxTile<String>(
                data: 'r6800',
                label: '6.8 kΩ',
                tooltip: 'Azul-Cinza-Vermelho (Fraco)',
                symbolWidget: _usePhysicalStyle
                    ? CustomPaint(
                        size: const Size(40, 24),
                        painter: ComponentPhysicalPainter(
                          type: ComponentType.resistor,
                          isActive: _m4SelectedResistor == '6800',
                          isDarkMode: false,
                        ),
                      )
                    : CustomPaint(
                        size: const Size(40, 20),
                        painter: CircuitSymbolPainter(
                          type: ComponentType.resistor,
                          isActive: _m4SelectedResistor == '6800',
                          color: const Color(0xFF0F172A),
                          strokeWidth: 2.0,
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
    if (_m4SelectedResistor == null) return 1;
    return 2;
  }

  bool _isStepCompleted(int index) {
    if (index == 0) return _prediction != null;
    if (index == 1) return _m4SelectedResistor != null;
    if (index == 2) return _isClosed;
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
      title: 'Dimensionamento de resistor',
      currentStepIndex: _currentStepperIndex,
      isStepCompleted: _isStepCompleted,
      steps: const [
        'Prever resistor adequado para 9V',
        'Experimentar 68Ω, 680Ω e 6.8kΩ na protoboard',
        'Garantir corrente segura e brilho radiante',
      ],
    );
  }
}
