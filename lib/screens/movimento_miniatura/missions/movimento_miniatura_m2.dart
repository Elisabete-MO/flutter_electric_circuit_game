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

/// Missão 2 do Estande 06 — Inversão de Polaridade e Sentido de Rotação.
class MovimentoMiniaturaM2 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const MovimentoMiniaturaM2({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<MovimentoMiniaturaM2> createState() => _MovimentoMiniaturaM2State();
}

class _MovimentoMiniaturaM2State extends State<MovimentoMiniaturaM2>
    with SingleTickerProviderStateMixin {
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  late final AnimationController _animController;

  bool _usePhysicalStyle = true;
  bool _isSimulating = false;
  bool _isReversed = false;
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

  bool get _isClosed => _isEnergized;

  void _togglePolarity() {
    final prev = _isReversed;
    _undoRedoController.execute(ToggleBoolAction(
      description: 'Inverter Polaridade dos Cabos do Motor',
      onApply: () => setState(() => _isReversed = !prev),
      onUndo: () => setState(() => _isReversed = prev),
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
            'O que acontecerá ao inverter os polos (+) e (–) conectados ao motor CC?',
        options: const [
          'O sentido de rotação se inverte para anti-horário ↺',
          'O motor para de girar',
          'O motor queima',
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
        question: 'Por que inverter a polaridade inverte o sentido do motor CC?',
        options: const [
          'Inverter a corrente inverte o sentido do campo magnético, invertendo a força no rotor',
          'A hélice física muda de ângulo sozinha',
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

    if (!_isReversed) {
      setState(() {
        _isEnergized = false;
        _isSimulating = false;
      });
      showDialog(
        context: context,
        builder: (context) => ProfVoltsFeedbackDialog(
          isCorrect: false,
          message:
              'O motor ainda está em polaridade direta. Use o botão na bancada para inverter os terminais e comprovar a reversão de giro.',
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

  Widget _buildWorkbenchDisplay() {
    return Stack(
      children: [
        // 1. Desenho do Motor CC na Protoboard
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return CustomPaint(
                painter: MovimentoMiniaturaBreadboardPainter(
                  animationValue: _animController.value,
                  usePhysicalStyle: _usePhysicalStyle,
                  isClosed: _isClosed,
                  isReversed: _isReversed,
                  hasMotor: true,
                ),
              );
            },
          ),
        ),

        // 2. Dock de Controle na Bancada
        Positioned(
          left: 20,
          bottom: 16,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF0284C7).withValues(alpha: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _isReversed
                        ? const Color(0xFFF97316)
                        : const Color(0xFF0284C7),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                  ),
                  onPressed: _togglePolarity,
                  icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                  label: Text(
                    _isReversed
                        ? 'Polaridade Invertida: Polo (–) ➔ Polo (+)'
                        : 'Polaridade Direta: Polo (+) ➔ Polo (–)',
                    style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
              const Icon(Icons.sync_rounded,
                  color: Color(0xFF0284C7), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Missão 2 · Troca de Sentido',
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
            'Inverta a polaridade dos cabos de alimentação na Protoboard para comprovar que o sentido de rotação do motor CC muda para anti-horário ↺.',
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
                    'Prof. Volts: "A regra da mão direita explica: invertendo a corrente, a força magnética no enrolamento se inverte instantaneamente!"',
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
                  'Progresso da reversão',
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
            title: 'Prever efeito da inversão',
            isCompleted: _prediction != null,
            isActive: _prediction == null,
            onTap: _showPredictionDialog,
          ),
          const SizedBox(height: 8),
          _buildStepItem(
            stepNumber: 2,
            title: 'Inverter polaridade dos cabos',
            isCompleted: _isReversed,
            isActive: _prediction != null && !_isReversed,
          ),
          const SizedBox(height: 8),
          _buildStepItem(
            stepNumber: 3,
            title: 'Energizar e verificar rotação anti-horária ↺',
            isCompleted: _isClosed && _isReversed,
            isActive: _isReversed,
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
