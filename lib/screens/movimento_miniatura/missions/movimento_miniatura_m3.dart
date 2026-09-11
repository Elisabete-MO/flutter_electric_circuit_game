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

/// Missão 3 do Estande 06 — Botão de Partida (Chave Táctil na Protoboard).
class MovimentoMiniaturaM3 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const MovimentoMiniaturaM3({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<MovimentoMiniaturaM3> createState() => _MovimentoMiniaturaM3State();
}

class _MovimentoMiniaturaM3State extends State<MovimentoMiniaturaM3>
    with SingleTickerProviderStateMixin {
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  late final AnimationController _animController;

  bool _usePhysicalStyle = true;
  bool _isSimulating = false;
  bool _buttonInserted = false;
  bool _isButtonPressed = false;
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

  bool get _isClosed => _buttonInserted && _isButtonPressed;

  void _toggleButtonInserted() {
    final prev = _buttonInserted;
    _undoRedoController.execute(InsertComponentAction(
      description: prev ? 'Remover Pushbutton' : 'Inserir Pushbutton na Protoboard',
      onApply: () => setState(() {
        _buttonInserted = !prev;
        if (!_buttonInserted) _isButtonPressed = false;
      }),
      onUndo: () => setState(() {
        _buttonInserted = prev;
        if (!_buttonInserted) _isButtonPressed = false;
      }),
    ));
  }

  void _toggleButtonState() {
    if (!_buttonInserted) return;
    setState(() => _isButtonPressed = !_isButtonPressed);
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
            'O que acontecerá ao adicionar uma chave táctil (pushbutton) em série com o motor?',
        options: const [
          'O motor só gira enquanto o botão estiver pressionado',
          'O motor fica ligado direto sem parar',
          'O botão queima por excesso de corrente',
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
        question: 'Qual o papel de uma chave táctil (pushbutton) no controle de motores?',
        options: const [
          'Interrompe fisicamente o circuito quando solta, permitindo controle sob demanda',
          'Aumenta a velocidade máxima do motor',
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

    if (!_buttonInserted) {
      setState(() {
        _isSimulating = false;
      });
      showDialog(
        context: context,
        builder: (context) => ProfVoltsFeedbackDialog(
          isCorrect: false,
          message:
              'Insira a chave táctil (pushbutton) na vala central da Protoboard para controlar a partida do motor.',
          onAction: () => Navigator.of(context).pop(),
        ),
      );
      return;
    }

    setState(() {
      _isButtonPressed = true;
      _isSimulating = false;
    });

    await Future.delayed(const Duration(milliseconds: 700));
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
        voltsTip: 'O pushbutton interrompe o circuito em repouso (normalmente aberto) e só fecha contato quando você mantém pressionado!',
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
          _buildPushbuttonSideControl(),
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

  Widget _buildPushbuttonSideControl() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _buttonInserted
              ? (_isButtonPressed ? const Color(0xFF10B981) : const Color(0xFF0284C7))
              : const Color(0xFF475569),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Controle do Pushbutton:',
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: _buttonInserted
                  ? const Color(0xFF0284C7)
                  : const Color(0xFF334155),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
            ),
            onPressed: _toggleButtonInserted,
            icon: Icon(
              _buttonInserted
                  ? Icons.check_circle_rounded
                  : Icons.add_circle_outline_rounded,
              size: 18,
            ),
            label: Text(
              _buttonInserted
                  ? 'Pushbutton Instalado na Vala'
                  : 'Instalar Pushbutton na Protoboard',
              style: GoogleFonts.rajdhani(
                  fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          if (_buttonInserted) ...[
            const SizedBox(height: 8),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: _isButtonPressed
                    ? const Color(0xFF10B981)
                    : const Color(0xFFDC2626),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
              ),
              onPressed: _toggleButtonState,
              icon: Icon(
                _isButtonPressed
                    ? Icons.play_arrow_rounded
                    : Icons.stop_rounded,
                size: 18,
              ),
              label: Text(
                _isButtonPressed
                    ? 'BOTÃO PRESSIONADO (ON)'
                    : 'PRESSIONAR BOTÃO (TESTE)',
                style: GoogleFonts.rajdhani(
                    fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
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
        final motorLeft = (w * 0.03).clamp(8.0, 42.0);
        final batWidth = (w * 0.16).clamp(52.0, 145.0);
        final batRight = w - 12.0;
        final batLeft = batRight - batWidth;
        final spacing = (w * 0.03).clamp(8.0, 24.0);
        final bbLeft = motorLeft + motorWidth + spacing;
        final bbWidth = (batLeft - bbLeft - spacing).clamp(130.0, 440.0);
        final bbTop = (h * 0.22).clamp(60.0, 105.0);
        final bbHeight = (h * 0.54).clamp(140.0, 235.0);

        return Stack(
          children: [
            // 1. Desenho do Motor CC e Pushbutton na Protoboard
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
                      showPushButton: _buttonInserted,
                      isPushButtonPressed: _isButtonPressed,
                    ),
                  );
                },
              ),
            ),

            // 2. Hotspot Tátil Direto no Pushbutton na Protoboard
            Positioned(
              left: bbLeft + bbWidth * 0.36,
              top: bbTop + bbHeight * 0.30,
              width: bbWidth * 0.30,
              height: bbHeight * 0.40,
              child: Tooltip(
                message: !_buttonInserted
                    ? 'Toque para instalar o Pushbutton na vala central'
                    : (_isButtonPressed
                        ? 'Toque para soltar o botão (OFF)'
                        : 'Toque para pressionar o botão (ON)'),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    splashColor: const Color(0xFF10B981).withValues(alpha: 0.3),
                    highlightColor: const Color(0xFF10B981).withValues(alpha: 0.15),
                    onTap: !_buttonInserted ? _toggleButtonInserted : _toggleButtonState,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: !_buttonInserted
                              ? Colors.amber.withValues(alpha: 0.7)
                              : (_isButtonPressed
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF0284C7).withValues(alpha: 0.5)),
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
                            color: !_buttonInserted
                                ? Colors.amber
                                : (_isButtonPressed ? const Color(0xFF10B981) : const Color(0xFF0284C7)),
                          ),
                        ),
                        child: Text(
                          !_buttonInserted
                              ? 'Toque p/ Instalar Botão'
                              : (_isButtonPressed ? 'Pressionado (ON)' : 'Toque p/ Ligar (OFF)'),
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
              const Icon(Icons.touch_app_rounded,
                  color: Color(0xFF0284C7), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Missão 3 · Botão de Partida',
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
            'Instale o Pushbutton na vala central da Protoboard em série com o motor CC para implementar o controle de partida e parada pulsada sob demanda.',
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
                    'Prof. Volts: "A chave SPST momentânea é o elemento fundamental de controle em painéis de partida industrial!"',
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
            title: 'Prever acionamento pulsado',
            isCompleted: _prediction != null,
            isActive: _prediction == null,
            onTap: _showPredictionDialog,
          ),
          const SizedBox(height: 8),
          _buildStepItem(
            stepNumber: 2,
            title: 'Instalar Pushbutton na Protoboard',
            isCompleted: _buttonInserted,
            isActive: _prediction != null && !_buttonInserted,
          ),
          const SizedBox(height: 8),
          _buildStepItem(
            stepNumber: 3,
            title: 'Pressionar botão e testar partida',
            isCompleted: _isClosed,
            isActive: _buttonInserted,
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
