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

/// Missão 5 do Estande 06 — Ponte H e Controle Bidirecional do Motor CC.
class MovimentoMiniaturaM5 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const MovimentoMiniaturaM5({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<MovimentoMiniaturaM5> createState() => _MovimentoMiniaturaM5State();
}

class _MovimentoMiniaturaM5State extends State<MovimentoMiniaturaM5>
    with SingleTickerProviderStateMixin {
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  late final AnimationController _animController;

  bool _usePhysicalStyle = true;
  bool _isSimulating = false;
  bool _hBridgeInstalled = false;
  int _activeChannel = 1; // 1 = D0 (Horário / Verde), 2 = D1 (Anti-horário / Vermelho), 0 = Parado
  bool _testedForward = false;
  bool _testedReverse = false;
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

  bool get _isClosed => _hBridgeInstalled && _activeChannel != 0;

  void _toggleHBridge() {
    final prev = _hBridgeInstalled;
    _undoRedoController.execute(InsertComponentAction(
      description: prev ? 'Remover Módulo Ponte H' : 'Instalar Ponte H na Protoboard',
      onApply: () => setState(() => _hBridgeInstalled = !prev),
      onUndo: () => setState(() => _hBridgeInstalled = prev),
    ));
  }

  void _selectChannel(int channel) {
    setState(() {
      _activeChannel = channel;
      if (channel == 1) _testedForward = true;
      if (channel == 2) _testedReverse = true;
    });
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
            'Como a Ponte H permite reverter o motor CC eletronicamente sem trocar fios manuais?',
        options: const [
          'Chaveia 4 transistores em pares diagonais, invertendo o sentido da corrente no motor',
          'Altera a frequência da rede elétrica',
          'Inverte a posição física da bateria',
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
        question: 'Por que a Ponte H é a base de robôs, carrinhos e automação industrial?',
        options: const [
          'Permite que sinais lógicos de microcontroladores (D0/D1) controlem sentido e frenagem com segurança',
          'Diminui a necessidade de bateria',
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

    if (!_hBridgeInstalled) {
      setState(() => _isSimulating = false);
      showDialog(
        context: context,
        builder: (context) => ProfVoltsFeedbackDialog(
          isCorrect: false,
          message:
              'Instale os 4 transistores e conexões da Ponte H na Protoboard para permitir controle bidirecional.',
          onAction: () => Navigator.of(context).pop(),
        ),
      );
      return;
    }

    if (!_testedForward || !_testedReverse) {
      setState(() => _isSimulating = false);
      showDialog(
        context: context,
        builder: (context) => ProfVoltsFeedbackDialog(
          isCorrect: false,
          message:
              'Acione tanto o canal D0 (Horário ↻) quanto o canal D1 (Anti-horário ↺) para validar a reversão eletrônica completa.',
          onAction: () => Navigator.of(context).pop(),
        ),
      );
      return;
    }

    setState(() => _isSimulating = false);
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
          currentMa: _isClosed ? 140.0 : 0.0,
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
        // 1. Desenho da Ponte H na Protoboard com Motor CC
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return CustomPaint(
                painter: MovimentoMiniaturaBreadboardPainter(
                  animationValue: _animController.value,
                  usePhysicalStyle: _usePhysicalStyle,
                  isClosed: _isClosed,
                  isReversed: _activeChannel == 2,
                  hasMotor: true,
                  showHBridge: _hBridgeInstalled,
                  hBridgeDirection: _activeChannel,
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
                    backgroundColor: _hBridgeInstalled
                        ? const Color(0xFF0284C7)
                        : const Color(0xFF334155),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                  onPressed: _toggleHBridge,
                  icon: Icon(
                    _hBridgeInstalled
                        ? Icons.check_circle_rounded
                        : Icons.add_circle_outline_rounded,
                    size: 16,
                  ),
                  label: Text(
                    _hBridgeInstalled ? 'Ponte H Conectada (4x NPN)' : 'Instalar Ponte H na Protoboard',
                    style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                if (_hBridgeInstalled) ...[
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: _activeChannel == 1
                          ? const Color(0xFF10B981)
                          : const Color(0xFF334155),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    onPressed: () => _selectChannel(1),
                    icon: const Icon(Icons.rotate_right_rounded, size: 16),
                    label: Text(
                      'CANAL D0: HORÁRIO ↻ (LED VERDE)',
                      style: GoogleFonts.rajdhani(
                          fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: _activeChannel == 2
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF334155),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    onPressed: () => _selectChannel(2),
                    icon: const Icon(Icons.rotate_left_rounded, size: 16),
                    label: Text(
                      'CANAL D1: ANTI-HORÁRIO ↺ (LED VERMELHO)',
                      style: GoogleFonts.rajdhani(
                          fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
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
              const Icon(Icons.hub_rounded,
                  color: Color(0xFF0284C7), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Missão 5 · Ponte H Bidirecional',
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
            'Implemente uma Ponte H com 4 transistores na Protoboard e comande o giro horário e anti-horário pelos canais lógicos D0 e D1 com sinalização por LEDs.',
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
                    'Prof. Volts: "Com a Ponte H, controlamos a direção de rotação com sinais lógicos de 5V sem mover nenhum fio!"',
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
                  'Progresso da Ponte H',
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
            title: 'Prever funcionamento da Ponte H',
            isCompleted: _prediction != null,
            isActive: _prediction == null,
            onTap: _showPredictionDialog,
          ),
          const SizedBox(height: 8),
          _buildStepItem(
            stepNumber: 2,
            title: 'Instalar Ponte H na Protoboard',
            isCompleted: _hBridgeInstalled,
            isActive: _prediction != null && !_hBridgeInstalled,
          ),
          const SizedBox(height: 8),
          _buildStepItem(
            stepNumber: 3,
            title: 'Testar giro D0 (Horário) e D1 (Anti-horário)',
            isCompleted: _testedForward && _testedReverse,
            isActive: _hBridgeInstalled,
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
