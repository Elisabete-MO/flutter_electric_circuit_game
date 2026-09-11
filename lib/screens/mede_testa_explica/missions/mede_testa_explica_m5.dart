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

/// Missão 5 do Estande 07 — Perícia de Bancada e Diagnóstico de Falha com Multímetro.
class MedeTestaExplicaM5 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const MedeTestaExplicaM5({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<MedeTestaExplicaM5> createState() => _MedeTestaExplicaM5State();
}

class _MedeTestaExplicaM5State extends State<MedeTestaExplicaM5> {
  final StandMission _mission = StandMission.medeTestaExplicaMissions[4];
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  bool _usePhysicalStyle = true;
  bool _isSimulating = false;

  // Estado da perícia: o resistor com defeito é de 10kΩ. Se reparado, vira 680Ω.
  bool _isFixed = false;
  int get _installedResistance => _isFixed ? 680 : 10000;

  // Conexões das pontas do multímetro nos nós: 'tp1' (+9V), 'tp2' (Chave/Resistor), 'tp3' (Resistor/LED), 'tp4' (Terra 0V)
  String? _redProbeTarget = 'tp2';
  String? _blackProbeTarget = 'tp3';
  Offset? _redProbePos;
  Offset? _blackProbePos;
  bool _isDraggingRed = false;
  bool _isDraggingBlack = false;

  MultimeterMode _multimeterMode = MultimeterMode.resistance;
  bool _hasInspectedResistor = false;

  // Corrente no circuito: I = (9V - 2V) / R
  double get _currentMa => (7.0 / _installedResistance) * 1000.0;

  double get _measuredVoltage {
    if (_redProbeTarget == null || _blackProbeTarget == null) return 0.0;
    if (_redProbeTarget == _blackProbeTarget) return 0.0;

    // Medindo a bateria (TP1 e TP4)
    if ((_redProbeTarget == 'tp1' && _blackProbeTarget == 'tp4') ||
        (_redProbeTarget == 'tp4' && _blackProbeTarget == 'tp1')) {
      return 9.0;
    }
    // Medindo o resistor sob suspeita (TP2 e TP3)
    if ((_redProbeTarget == 'tp2' && _blackProbeTarget == 'tp3') ||
        (_redProbeTarget == 'tp3' && _blackProbeTarget == 'tp2')) {
      return _isFixed ? 7.0 : 8.8; // Quase toda a ddp retida no resistor de 10k
    }
    // Medindo o LED (TP3 e TP4)
    if ((_redProbeTarget == 'tp3' && _blackProbeTarget == 'tp4') ||
        (_redProbeTarget == 'tp4' && _blackProbeTarget == 'tp3')) {
      return _isFixed ? 2.0 : 0.2;
    }
    return 0.0;
  }

  String get _displayValue {
    if (_multimeterMode == MultimeterMode.off) return '---';
    if (_redProbeTarget == null || _blackProbeTarget == null) return '0.00';

    switch (_multimeterMode) {
      case MultimeterMode.resistance:
        // Medindo sobre o resistor com defeito (TP2 e TP3)
        if ((_redProbeTarget == 'tp2' && _blackProbeTarget == 'tp3') ||
            (_redProbeTarget == 'tp3' && _blackProbeTarget == 'tp2')) {
          _hasInspectedResistor = true;
          return _isFixed ? '680' : '10000';
        }
        return 'OL'; // Circuito aberto ou outro nó
      case MultimeterMode.voltageDc:
        return _measuredVoltage.toStringAsFixed(2);
      case MultimeterMode.currentMa:
        return _currentMa.toStringAsFixed(1);
      case MultimeterMode.continuity:
        // Continuidade na chave fechada
        if ((_redProbeTarget == 'tp1' && _blackProbeTarget == 'tp2') ||
            (_redProbeTarget == 'tp2' && _blackProbeTarget == 'tp1')) {
          return 'BEEP';
        }
        return 'OPEN';
      case MultimeterMode.off:
        return '---';
    }
  }

  int get _currentStepperIndex {
    if (!_hasInspectedResistor) return 0;
    if (!_isFixed) return 1;
    return 2;
  }

  bool _isStepCompleted(int index) {
    if (index == 0) return _hasInspectedResistor;
    if (index == 1) return _isFixed;
    if (index == 2) return _isFixed && _currentMa >= 9.0;
    return false;
  }

  void _replaceFaultyResistor() {
    final prev = _isFixed;
    _undoRedoController.execute(ToggleBoolAction(
      description: 'Substituir resistor defeituoso por 680 Ω',
      onApply: () => setState(() => _isFixed = true),
      onUndo: () => setState(() => _isFixed = prev),
    ));
  }

  void _setRedProbeTarget(String? target, {Offset? snappedPos}) {
    final prev = _redProbeTarget;
    final prevPos = _redProbePos;
    _undoRedoController.execute(ToggleProbeAction(
      description: 'Mover Ponta Vermelha para ${target ?? 'Bancada'}',
      onApply: () => setState(() {
        _redProbeTarget = target;
        if (snappedPos != null) {
          _redProbePos = snappedPos;
        } else if (target == null) {
          _redProbePos = null;
        }
      }),
      onUndo: () => setState(() {
        _redProbeTarget = prev;
        _redProbePos = prevPos;
      }),
    ));
  }

  void _setBlackProbeTarget(String? target, {Offset? snappedPos}) {
    final prev = _blackProbeTarget;
    final prevPos = _blackProbePos;
    _undoRedoController.execute(ToggleProbeAction(
      description: 'Mover Ponta Preta para ${target ?? 'Bancada'}',
      onApply: () => setState(() {
        _blackProbeTarget = target;
        if (snappedPos != null) {
          _blackProbePos = snappedPos;
        } else if (target == null) {
          _blackProbePos = null;
        }
      }),
      onUndo: () => setState(() {
        _blackProbeTarget = prev;
        _blackProbePos = prevPos;
      }),
    ));
  }

  void _setMultimeterMode(MultimeterMode mode) {
    final prev = _multimeterMode;
    _undoRedoController.execute(SelectOptionAction(
      description: 'Mudar seletor para ${mode.shortLabel}',
      onApply: () => setState(() => _multimeterMode = mode),
      onUndo: () => setState(() => _multimeterMode = prev),
    ));
  }

  void _reset() {
    setState(() {
      _isFixed = false;
      _hasInspectedResistor = false;
      _redProbeTarget = null;
      _blackProbeTarget = null;
      _redProbePos = null;
      _blackProbePos = null;
      _multimeterMode = MultimeterMode.resistance;
    });
  }

  Future<void> _validateMission() async {
    if (_isSimulating) return;
    setState(() => _isSimulating = true);

    try {
      bool isSuccess = false;
      String feedback = _mission.failureFeedback;

      if (!_hasInspectedResistor) {
        feedback =
            'Use o multímetro nos pontos de teste do resistor (TP2 e TP3) para diagnosticar a causa do LED apagado/fraco.';
      } else if (!_isFixed) {
        feedback =
            'Diagnóstico correto (resistor de 10kΩ estrangulando a corrente)! Agora clique em "Substituir por 680 Ω" para consertar a placa.';
      } else {
        isSuccess = true;
        feedback =
            'Perícia concluída com louvor! O resistor anômalo de 10kΩ foi identificado e substituído pelo de 680Ω. Circuito restabelecido com corrente ideal de 10.3 mA!';
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
              'Diagnóstico Pericial Confirmado!',
              style: GoogleFonts.rajdhani(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        content: Text(
          'Parabéns! Você utilizou as pontas de prova do multímetro de verdade, detectou que o resistor estava com valor 15x maior (10kΩ em vez de 680Ω), limitando a corrente a quase zero, e restabeleceu a placa com perfeição!',
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
              'Concluir Estande 07',
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
              'Diagnóstico Incompleto',
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
              'Continuar Investigação',
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
        leftHeaderWidget: MedeTestaStatusCard(isClosed: _isFixed),
        rightHeaderWidget: MedeTestaTelemetryCard(
          voltage: 9.0,
          currentMa: _currentMa,
          isClosed: true,
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
        buttonLabel: 'CONCLUIR DIAGNÓSTICO',
        toolboxItems: [
          WorkbenchMissionObjectiveCard(
            missionNumber: 5,
            title: _mission.title,
            description: _mission.objective,
            voltsTip: _mission.voltsMediation,
          ),
          const SizedBox(height: 12),
          WorkbenchInvestigationStepperCard(
            title: 'Roteiro Pericial',
            currentStepIndex: _currentStepperIndex,
            isStepCompleted: _isStepCompleted,
            steps: const [
              'Medir o resistor nos nós TP2 e TP3 com o multímetro',
              'Constatar o valor anômalo e substituir a peça',
              'Validar a recuperação do circuito com 10.3 mA',
            ],
          ),
          const SizedBox(height: 12),
          _buildDiagnosticToolbox(),
        ],
        onEnergizePressed: _validateMission,
        isLoading: _isSimulating,
      ),
    );
  }

  Widget _buildDiagnosticToolbox() {
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
            'AÇÕES PERICIAIS',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF94A3B8),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          // Botão Substituir Resistor
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: _isFixed
                    ? const Color(0xFF10B981)
                    : const Color(0xFFD97706),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: _isFixed ? null : _replaceFaultyResistor,
              icon: Icon(
                  _isFixed ? Icons.check_circle_rounded : Icons.build_rounded,
                  size: 18),
              label: Text(
                _isFixed
                    ? 'RESISTOR 680 Ω INSTALADO'
                    : 'SUBSTITUIR POR 680 Ω',
                style: GoogleFonts.rajdhani(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Atalhos rápidos das pontas
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF475569)),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                  ),
                  onPressed: () {
                    _setRedProbeTarget('tp2');
                    _setBlackProbeTarget('tp3');
                    _setMultimeterMode(MultimeterMode.resistance);
                  },
                  child: Text(
                    'Medir Resistor\n(TP2-TP3)',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.rajdhani(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF475569)),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                  ),
                  onPressed: () {
                    _setRedProbeTarget('tp1');
                    _setBlackProbeTarget('tp4');
                    _setMultimeterMode(MultimeterMode.voltageDc);
                  },
                  child: Text(
                    'Medir Bateria\n(TP1-TP4)',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.rajdhani(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.link_off_rounded, size: 16),
              label: Text(
                'Soltar Pontas na Bancada',
                style: GoogleFonts.rajdhani(
                  color: const Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text(
                'Restaurar Caso Original',
                style: GoogleFonts.rajdhani(
                  color: const Color(0xFF94A3B8),
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

        // Posições no circuito
        final battPos = Offset(w * 0.16, h * 0.48);
        final switchPos = Offset(w * 0.32, h * 0.48);
        final resistorPos = Offset(w * 0.48, h * 0.48);
        final ledPos = Offset(w * 0.64, h * 0.48);
        final meterPos = Offset(w * 0.83, h * 0.48);

        // Pontos de teste
        final tp1Pos = Offset(w * 0.24, h * 0.30); // Entre bateria e chave (+9V)
        final tp2Pos = Offset(w * 0.40, h * 0.30); // Entrada do resistor
        final tp3Pos = Offset(w * 0.56, h * 0.30); // Saída do resistor / entrada LED
        final tp4Pos = Offset(w * 0.72, h * 0.30); // Terra / Saída LED

        final meterBlackJack = Offset(meterPos.dx - 10, meterPos.dy + 118);
        final meterRedJack = Offset(meterPos.dx + 38, meterPos.dy + 118);

        // Sincronização e posicionamento livre das pontas
        if (_redProbeTarget == 'tp1') {
          _redProbePos = tp1Pos;
        } else if (_redProbeTarget == 'tp2') {
          _redProbePos = tp2Pos;
        } else if (_redProbeTarget == 'tp3') {
          _redProbePos = tp3Pos;
        } else if (_redProbeTarget == 'tp4') {
          _redProbePos = tp4Pos;
        } else {
          _redProbePos ??= Offset(w * 0.44, h * 0.65);
        }

        if (_blackProbeTarget == 'tp1') {
          _blackProbePos = tp1Pos;
        } else if (_blackProbeTarget == 'tp2') {
          _blackProbePos = tp2Pos;
        } else if (_blackProbeTarget == 'tp3') {
          _blackProbePos = tp3Pos;
        } else if (_blackProbeTarget == 'tp4') {
          _blackProbePos = tp4Pos;
        } else {
          _blackProbePos ??= Offset(w * 0.54, h * 0.65);
        }

        final effectiveRedPos = _redProbePos!;
        final effectiveBlackPos = _blackProbePos!;

        final probeRedTail = Offset(effectiveRedPos.dx, effectiveRedPos.dy - 93);
        final probeBlackTail = Offset(effectiveBlackPos.dx, effectiveBlackPos.dy - 93);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. Fiação fixa do circuito de perícia
            Positioned.fill(
              child: CustomPaint(
                painter: _M5CircuitPainter(
                  battPos: battPos,
                  switchPos: switchPos,
                  resistorPos: resistorPos,
                  ledPos: ledPos,
                  tp1Pos: tp1Pos,
                  tp2Pos: tp2Pos,
                  tp3Pos: tp3Pos,
                  tp4Pos: tp4Pos,
                  isFixed: _isFixed,
                ),
              ),
            ),

            // 2. Bateria 9V
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

            // 3. Chave Liga/Desliga
            Positioned(
              left: switchPos.dx - 45,
              top: switchPos.dy - 55,
              child: Container(
                width: 90,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF10B981),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.toggle_on_rounded,
                      size: 42,
                      color: Color(0xFF10B981),
                    ),
                    Text(
                      'CHAVE ON',
                      style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: const Color(0xFF059669),
                      ),
                    ),
                    Text(
                      'Fechada',
                      style: GoogleFonts.outfit(
                        fontSize: 9,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. Resistor sob Suspeita
            Positioned(
              left: resistorPos.dx - 55,
              top: resistorPos.dy - 55,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _isFixed
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(48, 48),
                      painter: ComponentPhysicalPainter(
                        type: ComponentType.resistor,
                        isDarkMode: false,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isFixed ? '680 Ω' : '10 kΩ !',
                      style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: _isFixed
                            ? const Color(0xFF059669)
                            : const Color(0xFFDC2626),
                      ),
                    ),
                    Text(
                      _isFixed ? 'CORRETO' : 'ANÔMALO',
                      style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                        color: _isFixed
                            ? const Color(0xFF059669)
                            : const Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 5. LED de Saída
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
                        Container(
                          width: _isFixed ? 44 : 28,
                          height: _isFixed ? 44 : 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF10B981)
                                .withValues(alpha: _isFixed ? 0.6 : 0.15),
                          ),
                        ),
                        CustomPaint(
                          size: const Size(40, 40),
                          painter: ComponentPhysicalPainter(
                            type: ComponentType.led,
                            isActive: true,
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
                        fontSize: 10,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      _isFixed ? 'ACESO (10mA)' : 'FRACO (0.7mA)',
                      style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.bold,
                        fontSize: 8,
                        color: _isFixed
                            ? const Color(0xFF059669)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 6. Pontos de teste nos nós (TP1 a TP4)
            Positioned(
              left: tp1Pos.dx - 20,
              top: tp1Pos.dy - 20,
              child: TestPointNode(
                id: 'TP1',
                label: 'Positivo da Fonte (+9V)',
                hasRedProbe: _redProbeTarget == 'tp1',
                hasBlackProbe: _blackProbeTarget == 'tp1',
                onConnectRed: () => _setRedProbeTarget('tp1'),
                onConnectBlack: () => _setBlackProbeTarget('tp1'),
                onDisconnect: () {
                  if (_redProbeTarget == 'tp1') _setRedProbeTarget(null);
                  if (_blackProbeTarget == 'tp1') _setBlackProbeTarget(null);
                },
              ),
            ),

            Positioned(
              left: tp2Pos.dx - 20,
              top: tp2Pos.dy - 20,
              child: TestPointNode(
                id: 'TP2',
                label: 'Entrada do Resistor',
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

            Positioned(
              left: tp3Pos.dx - 20,
              top: tp3Pos.dy - 20,
              child: TestPointNode(
                id: 'TP3',
                label: 'Saída do Resistor / Ânodo do LED',
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

            Positioned(
              left: tp4Pos.dx - 20,
              top: tp4Pos.dy - 20,
              child: TestPointNode(
                id: 'TP4',
                label: 'Cátodo do LED / Terra',
                hasRedProbe: _redProbeTarget == 'tp4',
                hasBlackProbe: _blackProbeTarget == 'tp4',
                onConnectRed: () => _setRedProbeTarget('tp4'),
                onConnectBlack: () => _setBlackProbeTarget('tp4'),
                onDisconnect: () {
                  if (_redProbeTarget == 'tp4') _setRedProbeTarget(null);
                  if (_blackProbeTarget == 'tp4') _setBlackProbeTarget(null);
                },
              ),
            ),

            // 7. Multímetro Digital de Bancada
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

            // 8. Cabos elásticos dinâmicos (EM CIMA da bancada e componentes, NUNCA por trás!)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: ProbeCablesPainter(
                    meterRedJack: meterRedJack,
                    meterBlackJack: meterBlackJack,
                    probeRedTail: probeRedTail,
                    probeBlackTail: probeBlackTail,
                  ),
                ),
              ),
            ),

            // 9. Caneta de Ponta de Prova Vermelha (+) Arrastável (apontando para baixo)
            Positioned(
              left: effectiveRedPos.dx - 14,
              top: effectiveRedPos.dy - 96,
              child: GestureDetector(
                onPanStart: (_) => setState(() => _isDraggingRed = true),
                onPanUpdate: (details) {
                  setState(() {
                    _redProbePos = (_redProbePos ?? effectiveRedPos) + details.delta;
                    _redProbeTarget = null;
                  });
                },
                onPanEnd: (_) {
                  setState(() {
                    _isDraggingRed = false;
                    // Snap magnético nos 4 nós de teste
                    if ((_redProbePos! - tp1Pos).distance < 42) {
                      _redProbeTarget = 'tp1';
                      _redProbePos = tp1Pos;
                    } else if ((_redProbePos! - tp2Pos).distance < 42) {
                      _redProbeTarget = 'tp2';
                      _redProbePos = tp2Pos;
                    } else if ((_redProbePos! - tp3Pos).distance < 42) {
                      _redProbeTarget = 'tp3';
                      _redProbePos = tp3Pos;
                    } else if ((_redProbePos! - tp4Pos).distance < 42) {
                      _redProbeTarget = 'tp4';
                      _redProbePos = tp4Pos;
                    }
                  });
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.grab,
                  child: ProbePenWidget(
                    isRed: true,
                    isConnected: _redProbeTarget != null,
                    isDragging: _isDraggingRed,
                    pointingDown: true,
                  ),
                ),
              ),
            ),

            // 10. Caneta de Ponta de Prova Preta (COM) Arrastável (apontando para baixo)
            Positioned(
              left: effectiveBlackPos.dx - 14,
              top: effectiveBlackPos.dy - 96,
              child: GestureDetector(
                onPanStart: (_) => setState(() => _isDraggingBlack = true),
                onPanUpdate: (details) {
                  setState(() {
                    _blackProbePos = (_blackProbePos ?? effectiveBlackPos) + details.delta;
                    _blackProbeTarget = null;
                  });
                },
                onPanEnd: (_) {
                  setState(() {
                    _isDraggingBlack = false;
                    // Snap magnético nos 4 nós de teste
                    if ((_blackProbePos! - tp1Pos).distance < 42) {
                      _blackProbeTarget = 'tp1';
                      _blackProbePos = tp1Pos;
                    } else if ((_blackProbePos! - tp2Pos).distance < 42) {
                      _blackProbeTarget = 'tp2';
                      _blackProbePos = tp2Pos;
                    } else if ((_blackProbePos! - tp3Pos).distance < 42) {
                      _blackProbeTarget = 'tp3';
                      _blackProbePos = tp3Pos;
                    } else if ((_blackProbePos! - tp4Pos).distance < 42) {
                      _blackProbeTarget = 'tp4';
                      _blackProbePos = tp4Pos;
                    }
                  });
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.grab,
                  child: ProbePenWidget(
                    isRed: false,
                    isConnected: _blackProbeTarget != null,
                    isDragging: _isDraggingBlack,
                    pointingDown: true,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _M5CircuitPainter extends CustomPainter {
  final Offset battPos;
  final Offset switchPos;
  final Offset resistorPos;
  final Offset ledPos;
  final Offset tp1Pos;
  final Offset tp2Pos;
  final Offset tp3Pos;
  final Offset tp4Pos;
  final bool isFixed;

  _M5CircuitPainter({
    required this.battPos,
    required this.switchPos,
    required this.resistorPos,
    required this.ledPos,
    required this.tp1Pos,
    required this.tp2Pos,
    required this.tp3Pos,
    required this.tp4Pos,
    required this.isFixed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final wirePaint = Paint()
      ..color = isFixed ? const Color(0xFF0284C7) : const Color(0xFF64748B)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final groundPaint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Bateria (+) -> Chave
    final p1 = Path()
      ..moveTo(battPos.dx + 40, battPos.dy - 20)
      ..lineTo(tp1Pos.dx, tp1Pos.dy + 20)
      ..lineTo(switchPos.dx - 40, switchPos.dy - 20);
    canvas.drawPath(p1, wirePaint);

    // Chave -> Resistor
    final p2 = Path()
      ..moveTo(switchPos.dx + 40, switchPos.dy - 20)
      ..lineTo(tp2Pos.dx, tp2Pos.dy + 20)
      ..lineTo(resistorPos.dx - 45, resistorPos.dy - 20);
    canvas.drawPath(p2, wirePaint);

    // Resistor -> LED
    final p3 = Path()
      ..moveTo(resistorPos.dx + 45, resistorPos.dy - 20)
      ..lineTo(tp3Pos.dx, tp3Pos.dy + 20)
      ..lineTo(ledPos.dx - 40, ledPos.dy - 20);
    canvas.drawPath(p3, wirePaint);

    // LED (-) -> Retorno Bateria (-)
    final pReturn = Path()
      ..moveTo(ledPos.dx + 40, ledPos.dy)
      ..lineTo(tp4Pos.dx, tp4Pos.dy + 20)
      ..lineTo(tp4Pos.dx, ledPos.dy + 75)
      ..lineTo(battPos.dx, ledPos.dy + 75)
      ..lineTo(battPos.dx, battPos.dy + 55);
    canvas.drawPath(pReturn, groundPaint);
  }

  @override
  bool shouldRepaint(covariant _M5CircuitPainter oldDelegate) =>
      oldDelegate.isFixed != isFixed;
}
