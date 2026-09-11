import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/circuit_action.dart';
import '../../../state/circuit_undo_redo_controller.dart';
import '../../../widgets/prof_volts_explanation_dialog.dart';
import '../../../widgets/prof_volts_feedback_dialog.dart';
import '../../../widgets/prof_volts_prediction_dialog.dart';
import '../../../widgets/success_confetti_overlay.dart';
import '../../../widgets/workbench_components.dart';
import '../../../widgets/workbench_table_frame.dart';
import '../widgets/movimento_miniatura_breadboard_painter.dart';
import '../widgets/movimento_miniatura_widgets.dart';

/// Missão 1 do Estande 06 — Primeiro Giro do Motor CC na Protoboard.
class MovimentoMiniaturaM1 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const MovimentoMiniaturaM1({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<MovimentoMiniaturaM1> createState() => _MovimentoMiniaturaM1State();
}

class _MovimentoMiniaturaM1State extends State<MovimentoMiniaturaM1>
    with SingleTickerProviderStateMixin {
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  late final AnimationController _animController;

  bool _usePhysicalStyle = true;
  bool _isSimulating = false;
  bool _motorConnected = false;
  bool _isEnergized = false;
  String? _prediction;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  bool get _isClosed => _motorConnected && _isEnergized;

  void _toggleMotor() {
    final prev = _motorConnected;
    _undoRedoController.execute(InsertComponentAction(
      description: prev ? 'Desconectar Motor CC' : 'Conectar Motor CC na Protoboard',
      onApply: () => setState(() => _motorConnected = !prev),
      onUndo: () => setState(() => _motorConnected = prev),
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
            'O que acontecerá ao ligar a fonte CC com o motor conectado na Protoboard?',
        options: const [
          'O motor CC gira no sentido horário ↻',
          'O motor não se move',
          'O motor queima instantaneamente',
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
        question: 'Por que o motor CC gira quando o circuito é fechado?',
        options: const [
          'A corrente elétrica cria um campo magnético que produz torque mecânico no rotor',
          'A bateria empurra ar através do motor',
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
    setState(() => _isSimulating = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    if (!_motorConnected) {
      setState(() {
        _isEnergized = false;
        _isSimulating = false;
      });
      showDialog(
        context: context,
        builder: (context) => ProfVoltsFeedbackDialog(
          isCorrect: false,
          message:
              'O motor CC precisa estar conectado aos barramentos da Protoboard para receber energia.',
          onAction: () => Navigator.of(context).pop(),
        ),
      );
      return;
    }

    setState(() {
      _isEnergized = true;
      _isSimulating = false;
    });

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    _showExplanationDialog();
  }

  @override
  Widget build(BuildContext context) {
    return WorkbenchResponsiveLayout(
      workbench: WorkbenchTableFrame(
        usePhysicalStyle: _usePhysicalStyle,
        onStyleChanged: (val) => setState(() => _usePhysicalStyle = val),
        leftHeaderWidget: MovimentoStatusCard(isClosed: _isClosed),
        rightHeaderWidget: MovimentoTelemetryCard(
          voltage: 6.0,
          currentMa: _isClosed ? 120.0 : 0.0,
          isClosed: _isClosed,
        ),
        voltsTip: 'A corrente elétrica que percorre a bobina interna interage com os ímãs fixos do estator, fazendo o eixo girar!',
        bottomWidget: MovimentoUndoRedoButtons(
          controller: _undoRedoController,
          onUndo: () => setState(() => _undoRedoController.undo()),
          onRedo: () => setState(() => _undoRedoController.redo()),
        ),
        child: _buildWorkbenchDisplay(),
      ),
      sidePanel: WorkbenchSidePanel(
        teamTitle: 'Painel da Equipe Mecânica',
        showTeamHeader: false,
        buttonColor: const Color(0xFF0284C7),
        toolboxItems: [
          _buildMotorSideControl(),
          const SizedBox(height: 12),
          _buildMissionObjectiveCard(),
          const SizedBox(height: 12),
          _buildInvestigationStepperCard(),
          const SizedBox(height: 12),
          MovimentoPredictionBadge(prediction: _prediction),
          MovimentoSideToolbox(usePhysicalStyle: _usePhysicalStyle),
        ],
        onEnergizePressed: _onEnergizePressed,
        isLoading: _isSimulating,
      ),
    );
  }

  Widget _buildMotorSideControl() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _motorConnected
              ? const Color(0xFF0284C7)
              : const Color(0xFF475569),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Montagem do Atuador:',
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: _motorConnected
                  ? const Color(0xFF0284C7)
                  : const Color(0xFF334155),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
            ),
            onPressed: _toggleMotor,
            icon: Icon(
              _motorConnected
                  ? Icons.check_circle_rounded
                  : Icons.add_circle_outline_rounded,
              size: 18,
            ),
            label: Text(
              _motorConnected
                  ? 'Motor Conectado na Protoboard'
                  : 'Conectar Motor CC na Protoboard',
              style: GoogleFonts.rajdhani(
                  fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkbenchDisplay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        final motorWidth = (w * 0.13).clamp(46.0, 96.0);
        final motorHeight = (motorWidth * 1.45).clamp(66.0, 138.0);
        final motorLeft = (w * 0.03).clamp(8.0, 42.0);
        final bbTop = (h * 0.22).clamp(60.0, 105.0);
        final bbHeight = (h * 0.54).clamp(140.0, 235.0);
        final motorTop = bbTop + (bbHeight - motorHeight) * 0.52 + 10.0;

        return Stack(
          children: [
            // 1. Desenho do Motor CC, Protoboard e Bateria 9V
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: MovimentoMiniaturaBreadboardPainter(
                      animationValue: _animController.value,
                      usePhysicalStyle: _usePhysicalStyle,
                      isClosed: _isClosed,
                      isReversed: false,
                      hasMotor: _motorConnected,
                    ),
                  );
                },
              ),
            ),

            // 2. Hotspot Tátil Direto no Motor CC
            Positioned(
              left: motorLeft - 4,
              top: motorTop - 20,
              width: motorWidth + 8,
              height: motorHeight + 35,
              child: Tooltip(
                message: _motorConnected
                    ? 'Toque no Motor CC para desconectar'
                    : 'Toque no Motor CC para conectar à protoboard',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    splashColor: const Color(0xFF0284C7).withValues(alpha: 0.3),
                    highlightColor: const Color(0xFF0284C7).withValues(alpha: 0.15),
                    onTap: _toggleMotor,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _motorConnected
                              ? const Color(0xFF0284C7).withValues(alpha: 0.3)
                              : Colors.amber.withValues(alpha: 0.7),
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _motorConnected
                                ? const Color(0xFF0284C7)
                                : Colors.amber,
                          ),
                        ),
                        child: Text(
                          _motorConnected ? '✓ Motor Ativo' : 'Toque p/ Conectar',
                          style: GoogleFonts.rajdhani(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMissionObjectiveCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.motion_photos_on_rounded,
                  color: Color(0xFF0284C7), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Missão 1 · Primeiro Giro',
                  style: GoogleFonts.rajdhani(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Conecte o motor CC à Protoboard e ligue a alimentação para observar a conversão de energia elétrica em torque rotacional no sentido horário ↻.',
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: const Color(0xFF64748B),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.smart_toy_rounded,
                    color: Color(0xFFD97706), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Prof. Volts: "A corrente elétrica que percorre a bobina interna interage com os ímãs fixos do estator, fazendo o eixo girar!"',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFF92400E),
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

  Widget _buildInvestigationStepperCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fact_check_rounded,
                  color: Color(0xFF0284C7), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Progresso da montagem',
                  style: GoogleFonts.rajdhani(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildStepItem(
            stepNumber: 1,
            title: 'Registrar previsão de rotação',
            isCompleted: _prediction != null,
            isActive: _prediction == null,
            onTap: _showPredictionDialog,
          ),
          const SizedBox(height: 8),
          _buildStepItem(
            stepNumber: 2,
            title: 'Conectar Motor CC na Protoboard',
            isCompleted: _motorConnected,
            isActive: _prediction != null && !_motorConnected,
          ),
          const SizedBox(height: 8),
          _buildStepItem(
            stepNumber: 3,
            title: 'Energizar e verificar giro do eixo',
            isCompleted: _isClosed,
            isActive: _motorConnected,
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required int stepNumber,
    required String title,
    required bool isCompleted,
    required bool isActive,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF0284C7).withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isActive
              ? Border.all(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.4))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? const Color(0xFF10B981)
                    : (isActive
                        ? const Color(0xFF0284C7)
                        : const Color(0xFFE2E8F0)),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : Text(
                        '$stepNumber',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isActive
                              ? Colors.white
                              : const Color(0xFF64748B),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight:
                      isActive ? FontWeight.bold : FontWeight.normal,
                  color: isCompleted
                      ? const Color(0xFF0F172A)
                      : (isActive
                          ? const Color(0xFF0284C7)
                          : const Color(0xFF64748B)),
                ),
              ),
            ),
            if (onTap != null && !isCompleted)
              const Icon(Icons.arrow_forward_rounded,
                  size: 14, color: Color(0xFF0284C7)),
          ],
        ),
      ),
    );
  }
}
