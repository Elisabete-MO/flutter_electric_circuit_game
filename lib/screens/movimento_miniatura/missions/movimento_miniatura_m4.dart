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

/// Missão 4 do Estande 06 — Chaveamento com Transistor NPN e LED Sinalizador.
class MovimentoMiniaturaM4 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const MovimentoMiniaturaM4({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<MovimentoMiniaturaM4> createState() => _MovimentoMiniaturaM4State();
}

class _MovimentoMiniaturaM4State extends State<MovimentoMiniaturaM4>
    with SingleTickerProviderStateMixin {
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  late final AnimationController _animController;

  bool _usePhysicalStyle = true;
  bool _isSimulating = false;
  bool _transistorInserted = false;
  bool _ledIndicatorInserted = false;
  bool _isBaseTriggered = false;
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

  bool get _isClosed =>
      _transistorInserted && _ledIndicatorInserted && _isBaseTriggered;

  void _toggleTransistor() {
    final prev = _transistorInserted;
    _undoRedoController.execute(InsertComponentAction(
      description: prev ? 'Remover Transistor NPN' : 'Instalar Transistor NPN na Protoboard',
      onApply: () => setState(() => _transistorInserted = !prev),
      onUndo: () => setState(() => _transistorInserted = prev),
    ));
  }

  void _toggleLedIndicator() {
    final prev = _ledIndicatorInserted;
    _undoRedoController.execute(InsertComponentAction(
      description: prev ? 'Remover LED Indicador' : 'Instalar LED Verde Indicador na Protoboard',
      onApply: () => setState(() => _ledIndicatorInserted = !prev),
      onUndo: () => setState(() => _ledIndicatorInserted = prev),
    ));
  }

  void _toggleBaseTrigger() {
    setState(() => _isBaseTriggered = !_isBaseTriggered);
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
            'Como se comportam o motor e o LED indicador montados em ramos paralelos na Protoboard?',
        options: const [
          'Ambos recebem 6.0V e operam simultaneamente quando a base do transistor é polarizada',
          'O motor rouba toda a tensão e o LED fica apagado',
          'O circuito entra em curto',
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
        question: 'Por que o transistor é usado como chave eletrônica para motores?',
        options: const [
          'Uma pequena corrente de base permite comutar a corrente maior exigida pelo motor com segurança',
          'O transistor gera energia extra do nada',
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

    if (!_transistorInserted || !_ledIndicatorInserted) {
      setState(() => _isSimulating = false);
      showDialog(
        context: context,
        builder: (context) => ProfVoltsFeedbackDialog(
          isCorrect: false,
          message:
              'Instale tanto o Transistor NPN quanto o LED Indicador Verde na Protoboard para concluir o circuito de chaveamento.',
          onAction: () => Navigator.of(context).pop(),
        ),
      );
      return;
    }

    setState(() {
      _isBaseTriggered = true;
      _isSimulating = false;
    });

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    _showExplanationDialog();
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
            leftHeaderWidget: MovimentoStatusCard(isClosed: _isClosed),
            rightHeaderWidget: MovimentoTelemetryCard(
              voltage: 6.0,
              currentMa: _isClosed ? 135.0 : 0.0,
              isClosed: _isClosed,
            ),
            bottomWidget: MovimentoUndoRedoButtons(
              controller: _undoRedoController,
              onUndo: () => setState(() => _undoRedoController.undo()),
              onRedo: () => setState(() => _undoRedoController.redo()),
            ),
            child: _buildWorkbenchDisplay(),
          ),
        ),
        const SizedBox(width: 16),
        // Painel Lateral (Objetivo, Stepper & Validação)
        Expanded(
          flex: 3,
          child: WorkbenchSidePanel(
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
        ),
      ],
    );
  }

  Widget _buildWorkbenchDisplay() {
    return Stack(
      children: [
        // 1. Desenho do Motor CC, Transistor e LED na Protoboard
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
                  hasMotor: true,
                  showTransistor: _transistorInserted,
                  isTransistorTriggered: _isBaseTriggered,
                  hasIndicatorLed: _ledIndicatorInserted,
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
                    backgroundColor: _transistorInserted
                        ? const Color(0xFF0284C7)
                        : const Color(0xFF334155),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                  onPressed: _toggleTransistor,
                  icon: Icon(
                    _transistorInserted
                        ? Icons.check_circle_rounded
                        : Icons.add_circle_outline_rounded,
                    size: 16,
                  ),
                  label: Text(
                    _transistorInserted ? 'Transistor NPN Instalado' : 'Instalar Transistor NPN',
                    style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _ledIndicatorInserted
                        ? const Color(0xFF10B981)
                        : const Color(0xFF334155),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                  onPressed: _toggleLedIndicator,
                  icon: Icon(
                    _ledIndicatorInserted
                        ? Icons.check_circle_rounded
                        : Icons.add_circle_outline_rounded,
                    size: 16,
                  ),
                  label: Text(
                    _ledIndicatorInserted ? 'LED Indicador Verde Conectado' : 'Conectar LED Indicador',
                    style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                if (_transistorInserted && _ledIndicatorInserted)
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: _isBaseTriggered
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEAB308),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    onPressed: _toggleBaseTrigger,
                    icon: const Icon(Icons.flash_on_rounded, size: 16),
                    label: Text(
                      _isBaseTriggered ? 'SINAL NA BASE (ON)' : 'DISPARAR BASE NPN',
                      style: GoogleFonts.rajdhani(
                          fontWeight: FontWeight.bold, fontSize: 12),
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
              const Icon(Icons.alt_route_rounded,
                  color: Color(0xFF0284C7), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Missão 4 · Chaveamento & Indicador',
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
            'Monte o transistor NPN como chave eletrônica para o motor e adicione um LED Verde de status em paralelo para sinalizar quando o motor estiver ativo.',
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
                    'Prof. Volts: "Em circuitos paralelos, o motor e o LED compartilham a mesma tensão de 6V sem interferência de carga!"',
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
                  'Progresso do chaveamento',
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
            title: 'Prever ramo paralelo e transistor',
            isCompleted: _prediction != null,
            isActive: _prediction == null,
            onTap: _showPredictionDialog,
          ),
          const SizedBox(height: 8),
          _buildStepItem(
            stepNumber: 2,
            title: 'Instalar Transistor NPN e LED Verde',
            isCompleted: _transistorInserted && _ledIndicatorInserted,
            isActive: _prediction != null && (!_transistorInserted || !_ledIndicatorInserted),
          ),
          const SizedBox(height: 8),
          _buildStepItem(
            stepNumber: 3,
            title: 'Disparar base e validar operação',
            isCompleted: _isClosed,
            isActive: _transistorInserted && _ledIndicatorInserted,
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
