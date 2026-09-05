import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/circuit_action.dart';
import '../../../models/first_step_component.dart';
import '../../../models/stand_mission.dart';
import '../../../services/circuit_solver/mission_circuit_builder.dart';
import '../../../state/circuit_undo_redo_controller.dart';
import '../../../widgets/circuit_symbol_painter.dart';
import '../../../widgets/component_physical_painter.dart';
import '../../../widgets/physical_blueprint_socket.dart';
import '../../../widgets/prof_volts_explanation_dialog.dart';
import '../../../widgets/prof_volts_feedback_dialog.dart';
import '../../../widgets/prof_volts_prediction_dialog.dart';
import '../../../widgets/schematic_blueprint_socket.dart';
import '../../../widgets/success_confetti_overlay.dart';
import '../../../widgets/workbench_components.dart';
import '../../../widgets/workbench_table_frame.dart';
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

class _LetrerosLedM1State extends State<LetrerosLedM1> {
  final StandMission _mission = StandMission.letrerosLedMissions[0];
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  bool _usePhysicalStyle = true;
  bool _isSimulating = false;

  bool _m1LedDirectPolarity = true;
  bool _m1LedInserted = false;
  double _m1LedRotation = 0.0;
  String? _prediction;

  bool get _isClosed => _m1LedInserted && _m1LedDirectPolarity;

  void _insertComponent({
    required String name,
    required bool Function() getInserted,
    required void Function(bool) setInserted,
    required double Function() getRotation,
    required void Function(double) setRotation,
  }) {
    final prevInserted = getInserted();
    final prevRotation = getRotation();
    final nextInserted = !prevInserted;
    _undoRedoController.execute(InsertComponentAction(
      description: nextInserted ? 'Inserir $name' : 'Remover $name',
      onApply: () => setState(() {
        setInserted(nextInserted);
        if (nextInserted) setRotation(0);
      }),
      onUndo: () => setState(() {
        setInserted(prevInserted);
        setRotation(prevRotation);
      }),
    ));
  }

  void _rotateComponent({
    required String name,
    required double Function() getRotation,
    required void Function(double) setRotation,
  }) {
    final prevRotation = getRotation();
    final newRotation = (prevRotation + 90) % 360;
    _undoRedoController.execute(RotateComponentAction(
      description: 'Girar $name',
      onApply: () => setState(() => setRotation(newRotation)),
      onUndo: () => setState(() => setRotation(prevRotation)),
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
            'O que acontecerá ao energizar com R680Ω e LED em polaridade correta?',
        options: const [
          'LED acende normalmente',
          'LED não acende',
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
        question: 'Por que o LED precisa de resistor e polaridade correta?',
        options: const [
          'Resistor limita corrente; LED é polarizado',
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

      if (_m1LedInserted && _m1LedDirectPolarity) {
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
              'LED aceso em corrente segura (${currentMa.toStringAsFixed(1)}mA)! Ânodo (+) e Cátodo (-) ligados com resistor de 680 Ω.';
          isSuccess = true;
        } else {
          feedbackMessage = result.errorMessage ??
              'Verifique a montagem da Placa de Saída.';
        }
      } else if (!_m1LedInserted) {
        feedbackMessage = 'Insira o LED no soquete do circuito!';
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
              _isClosed ? 10.3 : 0.0,
              _isClosed,
            ),
            bottomWidget: _buildUndoRedoButtons(),
            child: _buildSignDisplay(),
          ),
        ),
        const SizedBox(width: 16),
        // Painel Lateral (Briefing & Validação)
        Expanded(
          flex: 3,
          child: WorkbenchSidePanel(
            teamTitle: 'Painel da Equipe Sinalização',
            toolboxItems: [
              _buildMissionBriefingCard(),
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

  Widget _buildSignDisplay() {
    final isLit = _m1LedInserted && _m1LedDirectPolarity;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildLetrerosLedSignBoard(
          title: 'SAÍDA',
          color: Colors.redAccent,
          isLit: isLit,
        ),
        _usePhysicalStyle
            ? PhysicalBlueprintSocket<String>(
                expectedData: 'led_red',
                isFilled: _m1LedInserted,
                showLabel: false,
                rotation: _m1LedRotation,
                onAccept: (_) => _insertComponent(
                  name: 'LED Vermelho',
                  getInserted: () => _m1LedInserted,
                  setInserted: (v) => _m1LedInserted = v,
                  getRotation: () => _m1LedRotation,
                  setRotation: (v) => _m1LedRotation = v,
                ),
                onRotate: () => _rotateComponent(
                  name: 'LED Vermelho',
                  getRotation: () => _m1LedRotation,
                  setRotation: (v) => _m1LedRotation = v,
                ),
                onTap: () => _insertComponent(
                  name: 'LED Vermelho',
                  getInserted: () => _m1LedInserted,
                  setInserted: (v) => _m1LedInserted = v,
                  getRotation: () => _m1LedRotation,
                  setRotation: (v) => _m1LedRotation = v,
                ),
                symbolWidget: CustomPaint(
                  size: const Size(60, 60),
                  painter: ComponentPhysicalPainter(
                    type: ComponentType.led,
                    isActive: isLit,
                    isDarkMode: false,
                  ),
                ),
                placeholderWidget: CustomPaint(
                  size: const Size(45, 45),
                  painter: ComponentPhysicalPainter(
                    type: ComponentType.led,
                    isActive: false,
                    isDarkMode: false,
                  ),
                ),
                label: '',
              )
            : SchematicBlueprintSocket<String>(
                expectedData: 'led_red',
                isFilled: _m1LedInserted,
                showLabel: false,
                rotation: _m1LedRotation,
                onAccept: (_) => _insertComponent(
                  name: 'LED Vermelho',
                  getInserted: () => _m1LedInserted,
                  setInserted: (v) => _m1LedInserted = v,
                  getRotation: () => _m1LedRotation,
                  setRotation: (v) => _m1LedRotation = v,
                ),
                onRotate: () => _rotateComponent(
                  name: 'LED Vermelho',
                  getRotation: () => _m1LedRotation,
                  setRotation: (v) => _m1LedRotation = v,
                ),
                onTap: () => _insertComponent(
                  name: 'LED Vermelho',
                  getInserted: () => _m1LedInserted,
                  setInserted: (v) => _m1LedInserted = v,
                  getRotation: () => _m1LedRotation,
                  setRotation: (v) => _m1LedRotation = v,
                ),
                symbolWidget: CustomPaint(
                  size: const Size(55, 55),
                  painter: CircuitSymbolPainter(
                    type: ComponentType.led,
                    isActive: isLit,
                    color: const Color(0xFF0F172A),
                    strokeWidth: 2.5,
                  ),
                ),
                placeholderWidget: CustomPaint(
                  size: const Size(45, 45),
                  painter: CircuitSymbolPainter(
                    type: ComponentType.led,
                    isActive: false,
                    color: const Color(0xFF94A3B8),
                    strokeWidth: 2.0,
                  ),
                ),
                label: '',
              ),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            backgroundColor: const Color(0xFF0F172A),
            side: const BorderSide(color: Color(0xFF00E5FF)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          icon: const Icon(Icons.flip_camera_android_rounded,
              color: Color(0xFF00E5FF)),
          label: Text(
            _m1LedDirectPolarity
                ? 'Polaridade: Direta [Ânodo (+) → Cátodo (-)]'
                : 'Polaridade: Inversa [Cátodo (-) → Ânodo (+)]',
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          onPressed: () {
            final prev = _m1LedDirectPolarity;
            _undoRedoController.execute(ToggleBoolAction(
              description: 'Toggle Polaridade LED',
              onApply: () => setState(() => _m1LedDirectPolarity = !prev),
              onUndo: () => setState(() => _m1LedDirectPolarity = prev),
            ));
          },
        ),
      ],
    );
  }

  Widget _buildSideToolboxDrawer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
          child: Text(
            'Componentes:',
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
            WorkbenchSymbolToolboxTile<String>(
              data: 'led_red',
              label: 'LED Vermelho',
              tooltip: 'Diodo Emissor de Luz',
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
                  'Missão 1: ${_mission.title}',
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
