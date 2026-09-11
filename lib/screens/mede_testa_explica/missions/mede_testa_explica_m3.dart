import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/ui_scale.dart';
import '../../../models/circuit_action.dart';
import '../../../models/first_step_component.dart';
import '../../../models/stand_mission.dart';
import '../../../state/circuit_undo_redo_controller.dart';
import '../../../widgets/component_physical_painter.dart';
import '../../../widgets/success_confetti_overlay.dart';
import '../../../widgets/workbench_components.dart';
import '../../../widgets/workbench_sidebar_cards.dart';
import '../../../widgets/workbench_table_frame.dart';
import '../widgets/mede_testa_explica_widgets.dart';

/// Missão 3 do Estande 07 — Lei de Ohm com Potenciômetro Rotativo e Multímetro em Série.
class MedeTestaExplicaM3 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const MedeTestaExplicaM3({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<MedeTestaExplicaM3> createState() => _MedeTestaExplicaM3State();
}

class _MedeTestaExplicaM3State extends State<MedeTestaExplicaM3> {
  final StandMission _mission = StandMission.medeTestaExplicaMissions[2];
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  bool _usePhysicalStyle = true;
  bool _isSimulating = false;

  // Valor da resistência ajustável (100 a 1000 Ohms)
  double _resistanceValue = 500.0;
  bool _hasTunedResistance = false;

  // Conexões das pontas do multímetro em série: TP2 e TP3
  String? _redProbeTarget = 'tp2';
  String? _blackProbeTarget = 'tp3';

  MultimeterMode _multimeterMode = MultimeterMode.currentMa;

  bool get _isAmperimeterConnected =>
      (_redProbeTarget == 'tp2' && _blackProbeTarget == 'tp3') ||
      (_redProbeTarget == 'tp3' && _blackProbeTarget == 'tp2');

  // Cálculo da corrente pela Lei de Ohm: I = (V_bat - V_led) / R
  // V_bat = 9V, V_led = 2.0V -> V_net = 7.0V
  double get _currentMa {
    if (!_isAmperimeterConnected) return 0.0;
    return (7.0 / _resistanceValue) * 1000.0;
  }

  String get _displayValue {
    if (_multimeterMode == MultimeterMode.off) return '---';
    if (!_isAmperimeterConnected) return '0.00';

    switch (_multimeterMode) {
      case MultimeterMode.currentMa:
        return _currentMa.toStringAsFixed(1);
      case MultimeterMode.voltageDc:
        // Queda no amperímetro em série é praticamente zero
        return '0.02';
      case MultimeterMode.resistance:
        return _resistanceValue.round().toString();
      case MultimeterMode.continuity:
        return 'BEEP';
      case MultimeterMode.off:
        return '---';
    }
  }

  int get _currentStepperIndex {
    if (_multimeterMode != MultimeterMode.currentMa) return 0;
    if (!_hasTunedResistance) return 1;
    return 2;
  }

  bool _isStepCompleted(int index) {
    if (index == 0) return _multimeterMode == MultimeterMode.currentMa;
    if (index == 1) return _hasTunedResistance;
    if (index == 2) {
      return _multimeterMode == MultimeterMode.currentMa &&
          _isAmperimeterConnected &&
          _hasTunedResistance;
    }
    return false;
  }

  void _onResistanceChanged(double val) {
    setState(() {
      _resistanceValue = val;
      _hasTunedResistance = true;
    });
  }

  void _setMultimeterMode(MultimeterMode mode) {
    final prev = _multimeterMode;
    _undoRedoController.execute(SelectOptionAction(
      description: 'Mudar seletor para ${mode.shortLabel}',
      onApply: () => setState(() => _multimeterMode = mode),
      onUndo: () => setState(() => _multimeterMode = prev),
    ));
  }

  void _setRedProbeTarget(String? target) {
    final prev = _redProbeTarget;
    _undoRedoController.execute(ToggleProbeAction(
      description: 'Mover Ponta Vermelha para $target',
      onApply: () => setState(() => _redProbeTarget = target),
      onUndo: () => setState(() => _redProbeTarget = prev),
    ));
  }

  void _setBlackProbeTarget(String? target) {
    final prev = _blackProbeTarget;
    _undoRedoController.execute(ToggleProbeAction(
      description: 'Mover Ponta Preta para $target',
      onApply: () => setState(() => _blackProbeTarget = target),
      onUndo: () => setState(() => _blackProbeTarget = prev),
    ));
  }

  void _reset() {
    setState(() {
      _resistanceValue = 500.0;
      _hasTunedResistance = false;
      _redProbeTarget = 'tp2';
      _blackProbeTarget = 'tp3';
      _multimeterMode = MultimeterMode.currentMa;
    });
  }

  Future<void> _validateMission() async {
    if (_isSimulating) return;
    setState(() => _isSimulating = true);

    try {
      bool isSuccess = false;
      String feedback = _mission.failureFeedback;

      if (_multimeterMode != MultimeterMode.currentMa) {
        feedback =
            'Gire a chave seletora para mA⎓ para medir a corrente elétrica do circuito em série.';
      } else if (!_isAmperimeterConnected) {
        feedback =
            'O amperímetro deve ser inserido em série no circuito através dos pontos TP2 e TP3.';
      } else {
        isSuccess = true;
        feedback =
            'Excelente! Com R = ${_resistanceValue.round()}Ω, a corrente medida foi de ${_currentMa.toStringAsFixed(1)}mA. '
            'Você comprovou a Lei de Ohm: a corrente varia de forma inversamente proporcional à resistência!';
      }

      if (isSuccess) {
        _showSuccessDialog();
      } else {
        _showFailureDialog(feedback);
      }
    } finally {
      if (mounted) setState(() => _isSimulating = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF06231E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF10B981), width: 2),
        ),
        title: Row(
          children: [
            const Icon(Icons.verified_rounded,
                color: Color(0xFF10B981), size: 32),
            const SizedBox(width: 12),
            Text(
              'Lei de Ohm Comprovada!',
              style: GoogleFonts.rajdhani(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        content: Text(
          'Fantástico! Você usou o multímetro em série no modo amperímetro e viu os elétrons responderem ao giro do potenciômetro: ao aumentar a resistência, a corrente cai (I = V ÷ R) e o brilho do LED diminui suavemente.',
          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              showSuccessConfetti(context);
              widget.onMissionComplete();
            },
            child: Text(
              'Avançar Missão',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showFailureDialog(String feedback) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1010),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFEF4444), width: 2),
        ),
        title: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Color(0xFFEF4444), size: 28),
            const SizedBox(width: 10),
            Text(
              'Ajuste Necessário',
              style: GoogleFonts.rajdhani(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Text(
          feedback,
          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Revisar Instrumento',
              style: GoogleFonts.rajdhani(
                color: const Color(0xFFEF4444),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = UiScale.of(context);

    return WorkbenchResponsiveLayout(
      workbench: WorkbenchTableFrame(
        usePhysicalStyle: _usePhysicalStyle,
        onStyleChanged: (val) => setState(() => _usePhysicalStyle = val),
        leftHeaderWidget: MedeTestaStatusCard(
          isClosed: _isAmperimeterConnected,
        ),
        rightHeaderWidget: MedeTestaTelemetryCard(
          voltage: 9.0,
          currentMa: _currentMa,
          isClosed: _isAmperimeterConnected,
        ),
        bottomWidget: MedeTestaUndoRedoButtons(
          controller: _undoRedoController,
          onUndo: () => setState(() => _undoRedoController.undo()),
          onRedo: () => setState(() => _undoRedoController.redo()),
        ),
        voltsTip: _mission.voltsMediation,
        child: _buildWorkbenchContent(scale),
      ),
      sidePanel: WorkbenchSidePanel(
        teamTitle: 'Equipe Instrumentação',
        showTeamHeader: false,
        buttonColor: const Color(0xFF059669),
        buttonLabel: 'COMPROVAR LEI DE OHM',
        toolboxItems: [
          WorkbenchMissionObjectiveCard(
            missionNumber: 3,
            title: _mission.title,
            description: _mission.objective,
            voltsTip: _mission.voltsMediation,
          ),
          const SizedBox(height: 12),
          WorkbenchInvestigationStepperCard(
            title: 'Roteiro de Investigação',
            currentStepIndex: _currentStepperIndex,
            isStepCompleted: _isStepCompleted,
            steps: const [
              'Girar seletor do multímetro para mA⎓ (Corrente)',
              'Girar o potenciômetro e observar a variação de corrente',
              'Comprovar a Lei de Ohm (Maior R = Menor Corrente)',
            ],
          ),
          const SizedBox(height: 12),
          _buildSideOhmSummary(),
        ],
        onEnergizePressed: _validateMission,
        isLoading: _isSimulating,
      ),
    );
  }

  Widget _buildSideOhmSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CÁLCULO EM TEMPO REAL',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF94A3B8),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Fórmula: I = V ÷ R',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFFF59E0B),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'R = ${_resistanceValue.round()} Ω  ➔  I = ${_currentMa.toStringAsFixed(1)} mA',
            style: GoogleFonts.shareTechMono(
              color: const Color(0xFF38BDF8),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF475569)),
                padding: const EdgeInsets.symmetric(vertical: 6),
              ),
              onPressed: _reset,
              child: Text(
                'Restaurar (500 Ω)',
                style: GoogleFonts.rajdhani(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkbenchContent(UiScale scale) {
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        final h = box.maxHeight;

        // Posições dos componentes
        final battPos = Offset(w * 0.15, h * 0.48);
        final potPos = Offset(w * 0.36, h * 0.48);
        final tp2Pos = Offset(w * 0.48, h * 0.30); // Saída do potenciômetro
        final tp3Pos = Offset(w * 0.58, h * 0.30); // Entrada do LED
        final ledPos = Offset(w * 0.56, h * 0.65);
        final meterPos = Offset(w * 0.80, h * 0.48);

        // Terminais do multímetro
        final meterRedJack = Offset(meterPos.dx - 35, meterPos.dy + 120);
        final meterBlackJack = Offset(meterPos.dx + 35, meterPos.dy + 120);

        final targetRed = _redProbeTarget == 'tp2'
            ? tp2Pos
            : (_redProbeTarget == 'tp3' ? tp3Pos : null);

        final targetBlack = _blackProbeTarget == 'tp3'
            ? tp3Pos
            : (_blackProbeTarget == 'tp2' ? tp2Pos : null);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Cabos flexíveis ligando o multímetro em série aos pontos TP2 e TP3
            Positioned.fill(
              child: CustomPaint(
                painter: ProbeCablesPainter(
                  meterRedJack: meterRedJack,
                  meterBlackJack: meterBlackJack,
                  targetRed: targetRed,
                  targetBlack: targetBlack,
                ),
              ),
            ),

            // Título Didático
            Positioned(
              top: 16,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LEI DE OHM & CONTROLE DE CORRENTE',
                    style: GoogleFonts.rajdhani(
                      color: const Color(0xFF0F172A),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    'Gire o botão do potenciômetro e veja a corrente oscilar no multímetro em série.',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Fiação fixa do circuito
            Positioned.fill(
              child: CustomPaint(
                painter: _OhmCircuitPainter(
                  battPos: battPos,
                  potPos: potPos,
                  tp2Pos: tp2Pos,
                  tp3Pos: tp3Pos,
                  ledPos: ledPos,
                  isClosed: _isAmperimeterConnected,
                ),
              ),
            ),

            // 1. Bateria 9V
            Positioned(
              left: battPos.dx - 45,
              top: battPos.dy - 55,
              child: Container(
                width: 90,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(48, 48),
                      painter: ComponentPhysicalPainter(
                        type: ComponentType.battery,
                        isDarkMode: false,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'BATERIA 9V',
                      style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Potenciômetro Rotativo Interativo
            Positioned(
              left: potPos.dx - 65,
              top: potPos.dy - 85,
              child: InteractivePotentiometerKnob(
                value: _resistanceValue,
                min: 100.0,
                max: 1000.0,
                onChanged: _onResistanceChanged,
              ),
            ),

            // Ponto de Teste TP2 (Saída do Potenciômetro)
            Positioned(
              left: tp2Pos.dx - 20,
              top: tp2Pos.dy - 20,
              child: TestPointNode(
                id: 'TP2',
                label: 'Saída do Potenciômetro',
                hasRedProbe: _redProbeTarget == 'tp2',
                hasBlackProbe: _blackProbeTarget == 'tp2',
                onConnectRed: () => _setRedProbeTarget('tp2'),
                onConnectBlack: () => _setBlackProbeTarget('tp2'),
                onDisconnect: () {
                  if (_redProbeTarget == 'tp2') _setRedProbeTarget(null);
                  if (_blackProbeTarget == 'tp2') _setBlackProbeTarget(null);
                },
              ),
            ),

            // Ponto de Teste TP3 (Entrada do LED)
            Positioned(
              left: tp3Pos.dx - 20,
              top: tp3Pos.dy - 20,
              child: TestPointNode(
                id: 'TP3',
                label: 'Entrada do LED',
                hasRedProbe: _redProbeTarget == 'tp3',
                hasBlackProbe: _blackProbeTarget == 'tp3',
                onConnectRed: () => _setRedProbeTarget('tp3'),
                onConnectBlack: () => _setBlackProbeTarget('tp3'),
                onDisconnect: () {
                  if (_redProbeTarget == 'tp3') _setRedProbeTarget(null);
                  if (_blackProbeTarget == 'tp3') _setBlackProbeTarget(null);
                },
              ),
            ),

            // 3. LED Indicador (com brilho proporcional à corrente)
            Positioned(
              left: ledPos.dx - 45,
              top: ledPos.dy - 55,
              child: Container(
                width: 90,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_isAmperimeterConnected)
                          Container(
                            width: 36 + (_currentMa / 2.5),
                            height: 36 + (_currentMa / 2.5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: (_currentMa / 80).clamp(0.2, 0.8)),
                            ),
                          ),
                        CustomPaint(
                          size: const Size(44, 44),
                          painter: ComponentPhysicalPainter(
                            type: ComponentType.led,
                            isActive: _isAmperimeterConnected,
                            isDarkMode: false,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'LED VERDE',
                      style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      _isAmperimeterConnected
                          ? '${_currentMa.toStringAsFixed(1)} mA'
                          : 'APAGADO (0 mA)',
                      style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                        color: _isAmperimeterConnected
                            ? const Color(0xFF059669)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Multímetro Digital de Bancada
            Positioned(
              left: meterPos.dx - 87,
              top: meterPos.dy - 140,
              child: DigitalMultimeterWidget(
                currentMode: _multimeterMode,
                onModeChanged: _setMultimeterMode,
                displayValue: _displayValue,
                displayUnit: _multimeterMode.unit,
                isRedConnected: _redProbeTarget != null,
                isBlackConnected: _blackProbeTarget != null,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Fiação do circuito da Lei de Ohm conectando bateria, potenciômetro, TPs e LED
class _OhmCircuitPainter extends CustomPainter {
  final Offset battPos;
  final Offset potPos;
  final Offset tp2Pos;
  final Offset tp3Pos;
  final Offset ledPos;
  final bool isClosed;

  _OhmCircuitPainter({
    required this.battPos,
    required this.potPos,
    required this.tp2Pos,
    required this.tp3Pos,
    required this.ledPos,
    required this.isClosed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final wirePaint = Paint()
      ..color = isClosed ? const Color(0xFF0284C7) : const Color(0xFF94A3B8)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final groundPaint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Bateria (+) -> Potenciômetro
    final p1 = Path()
      ..moveTo(battPos.dx + 45, battPos.dy - 20)
      ..lineTo(potPos.dx - 65, potPos.dy - 20);
    canvas.drawPath(p1, wirePaint);

    // Potenciômetro -> TP2
    final p2 = Path()
      ..moveTo(potPos.dx + 65, potPos.dy - 20)
      ..lineTo(tp2Pos.dx, tp2Pos.dy + 20);
    canvas.drawPath(p2, wirePaint);

    // TP3 -> LED
    final p3 = Path()
      ..moveTo(tp3Pos.dx, tp3Pos.dy + 20)
      ..lineTo(ledPos.dx, ledPos.dy - 55);
    canvas.drawPath(p3, wirePaint);

    // LED (-) -> Retorno Bateria (-)
    final pReturn = Path()
      ..moveTo(ledPos.dx, ledPos.dy + 55)
      ..lineTo(ledPos.dx, ledPos.dy + 75)
      ..lineTo(battPos.dx, ledPos.dy + 75)
      ..lineTo(battPos.dx, battPos.dy + 55);
    canvas.drawPath(pReturn, groundPaint);
  }

  @override
  bool shouldRepaint(covariant _OhmCircuitPainter oldDelegate) =>
      oldDelegate.isClosed != isClosed;
}
