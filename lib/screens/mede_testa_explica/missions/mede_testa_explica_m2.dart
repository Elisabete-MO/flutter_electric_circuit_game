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

/// Missão 2 do Estande 07 — Queda de Tensão na Carga (Lâmpada) com Multímetro Interativo.
class MedeTestaExplicaM2 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const MedeTestaExplicaM2({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<MedeTestaExplicaM2> createState() => _MedeTestaExplicaM2State();
}

class _MedeTestaExplicaM2State extends State<MedeTestaExplicaM2> {
  final StandMission _mission = StandMission.medeTestaExplicaMissions[1];
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  bool _usePhysicalStyle = true;
  bool _isSimulating = false;

  // Estado do circuito
  bool _switchClosed = true;

  // Conexões das pontas nos Test Points: 'tp1' (+9V), 'tp2' (Chave/Lâmpada), 'tp3' (0V Terra)
  String? _redProbeTarget;
  String? _blackProbeTarget;
  Offset? _redProbePos;
  Offset? _blackProbePos;
  bool _isDraggingRed = false;
  bool _isDraggingBlack = false;

  MultimeterMode _multimeterMode = MultimeterMode.voltageDc;

  bool get _bothProbesConnected =>
      _redProbeTarget != null && _blackProbeTarget != null;

  // Medição da ddp entre os nós
  double get _measuredVoltage {
    if (_multimeterMode != MultimeterMode.voltageDc) return 0.0;
    if (!_bothProbesConnected) return 0.0;
    if (_redProbeTarget == _blackProbeTarget) return 0.0;

    // Medindo sobre a lâmpada (TP2 e TP3)
    if ((_redProbeTarget == 'tp2' && _blackProbeTarget == 'tp3') ||
        (_redProbeTarget == 'tp3' && _blackProbeTarget == 'tp2')) {
      final sign = (_redProbeTarget == 'tp2') ? 1.0 : -1.0;
      return _switchClosed ? (9.0 * sign) : 0.0;
    }

    // Medindo sobre a chave (TP1 e TP2)
    if ((_redProbeTarget == 'tp1' && _blackProbeTarget == 'tp2') ||
        (_redProbeTarget == 'tp2' && _blackProbeTarget == 'tp1')) {
      final sign = (_redProbeTarget == 'tp1') ? 1.0 : -1.0;
      return _switchClosed ? 0.0 : (9.0 * sign);
    }

    // Medindo sobre a fonte total (TP1 e TP3)
    if ((_redProbeTarget == 'tp1' && _blackProbeTarget == 'tp3') ||
        (_redProbeTarget == 'tp3' && _blackProbeTarget == 'tp1')) {
      final sign = (_redProbeTarget == 'tp1') ? 1.0 : -1.0;
      return 9.0 * sign;
    }

    return 0.0;
  }

  String get _displayValue {
    if (_multimeterMode == MultimeterMode.off) return '---';
    if (!_bothProbesConnected) return '0.00';
    if (_redProbeTarget == _blackProbeTarget) return '0.00';

    switch (_multimeterMode) {
      case MultimeterMode.voltageDc:
        return _measuredVoltage.toStringAsFixed(2);
      case MultimeterMode.currentMa:
        return _switchClosed ? '180.0' : '0.00';
      case MultimeterMode.resistance:
        return _switchClosed ? '50.0' : 'O.L';
      case MultimeterMode.continuity:
        return (_switchClosed &&
                ((_redProbeTarget == 'tp1' && _blackProbeTarget == 'tp2') ||
                    (_redProbeTarget == 'tp2' && _blackProbeTarget == 'tp1')))
            ? 'BEEP'
            : '---';
      case MultimeterMode.off:
        return '---';
    }
  }

  bool get _isBulbMeasured =>
      (_redProbeTarget == 'tp2' && _blackProbeTarget == 'tp3') ||
      (_redProbeTarget == 'tp3' && _blackProbeTarget == 'tp2');

  int get _currentStepperIndex {
    if (!_switchClosed) return 0;
    if (!_isBulbMeasured) return 1;
    if (_multimeterMode != MultimeterMode.voltageDc) return 1;
    return 2;
  }

  bool _isStepCompleted(int index) {
    if (index == 0) return _switchClosed;
    if (index == 1) return _isBulbMeasured;
    if (index == 2) {
      return _switchClosed &&
          _isBulbMeasured &&
          _multimeterMode == MultimeterMode.voltageDc &&
          _measuredVoltage.abs() == 9.0;
    }
    return false;
  }

  void _toggleSwitch() {
    final prev = _switchClosed;
    _undoRedoController.execute(ToggleBoolAction(
      description: _switchClosed ? 'Abrir chave' : 'Fechar chave',
      onApply: () => setState(() => _switchClosed = !_switchClosed),
      onUndo: () => setState(() => _switchClosed = prev),
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

  void _reset() {
    setState(() {
      _switchClosed = true;
      _redProbeTarget = null;
      _blackProbeTarget = null;
      _redProbePos = null;
      _blackProbePos = null;
      _multimeterMode = MultimeterMode.voltageDc;
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


  Future<void> _validateMission() async {
    if (_isSimulating) return;
    setState(() => _isSimulating = true);

    try {
      bool isSuccess = false;
      String feedback = _mission.failureFeedback;

      if (!_switchClosed) {
        feedback =
            'Feche o interruptor para energizar o circuito e acender a lâmpada.';
      } else if (!_bothProbesConnected) {
        feedback =
            'Posicione as duas pontas de prova nos terminais da carga (TP2 e TP3).';
      } else if (!_isBulbMeasured) {
        if ((_redProbeTarget == 'tp1' && _blackProbeTarget == 'tp2') ||
            (_redProbeTarget == 'tp2' && _blackProbeTarget == 'tp1')) {
          feedback =
              'Você está medindo sobre a chave fechada (0.00V)! O objetivo é medir a queda de tensão na lâmpada (TP2 e TP3).';
        } else {
          feedback =
              'Conecte as pontas de prova diretamente sobre a lâmpada (TP2 e TP3).';
        }
      } else if (_multimeterMode != MultimeterMode.voltageDc) {
        feedback =
            'Gire a chave seletora do multímetro para V⎓ (Tensão Contínua).';
      } else if (_measuredVoltage.abs() == 9.0) {
        isSuccess = true;
        feedback =
            'Perfeito! Queda de tensão de 9.00V medida sobre a lâmpada. Toda a energia da fonte é consumida na carga!';
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
              'Queda de Tensão Comprovada!',
              style: GoogleFonts.rajdhani(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        content: Text(
          'Brilhante! Você demonstrou que um condutor/chave fechada não consome tensão (0V de queda) e que praticamente toda a d.d.p. de 9.00V da fonte é convertida em luz e calor sobre a lâmpada!',
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
              'Revisar Pontos de Teste',
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
        leftHeaderWidget: MedeTestaStatusCard(isClosed: _switchClosed),
        rightHeaderWidget: MedeTestaTelemetryCard(
          voltage: _measuredVoltage.abs(),
          currentMa: _switchClosed ? 180.0 : 0.0,
          isClosed: _switchClosed,
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
        buttonLabel: 'VALIDAR QUEDA NA CARGA',
        toolboxItems: [
          WorkbenchMissionObjectiveCard(
            missionNumber: 2,
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
              'Ligar a chave para acender a lâmpada',
              'Conectar pontas de prova nos nós da lâmpada (TP2 e TP3)',
              'Girar seletor para V⎓ e validar 9.00V de queda na carga',
            ],
          ),
          const SizedBox(height: 12),
          _buildQuickControls(),
        ],
        onEnergizePressed: _validateMission,
        isLoading: _isSimulating,
      ),
    );
  }

  Widget _buildQuickControls() {
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
            'CONTROLE DO CIRCUITO & PONTAS',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF94A3B8),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          // Botão Chave
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: _switchClosed
                    ? const Color(0xFF10B981)
                    : const Color(0xFF64748B),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onPressed: _toggleSwitch,
              icon: Icon(_switchClosed
                  ? Icons.toggle_on_rounded
                  : Icons.toggle_off_rounded),
              label: Text(
                _switchClosed ? 'CHAVE: FECHADA (ON)' : 'CHAVE: ABERTA (OFF)',
                style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Botões de medição rápida
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    side: BorderSide(
                      color: _isBulbMeasured
                          ? const Color(0xFF10B981)
                          : const Color(0xFF475569),
                    ),
                  ),
                  onPressed: () {
                    _setRedProbeTarget('tp2');
                    _setBlackProbeTarget('tp3');
                  },
                  child: Text(
                    'Medir Lâmpada\n(TP2-TP3)',
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
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    side: const BorderSide(color: Color(0xFF475569)),
                  ),
                  onPressed: () {
                    _setRedProbeTarget('tp1');
                    _setBlackProbeTarget('tp2');
                  },
                  child: Text(
                    'Medir Chave\n(TP1-TP2)',
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
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 6),
                side: const BorderSide(color: Color(0xFF475569)),
              ),
              onPressed: _reset,
              icon: const Icon(Icons.link_off_rounded, size: 14, color: Colors.white70),
              label: Text(
                'Soltar Pontas na Bancada',
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
    );
  }

  Widget _buildWorkbenchContent(UiScale scale) {
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        final h = box.maxHeight;

        // Posições dos componentes do circuito em série
        final battPos = Offset(w * 0.16, h * 0.50);
        final switchPos = Offset(w * 0.34, h * 0.50);
        final bulbPos = Offset(w * 0.52, h * 0.50);
        final meterPos = Offset(w * 0.76, h * 0.50);

        // Pontos de teste
        final tp1Pos = Offset(w * 0.25, h * 0.32); // Entre bateria e chave
        final tp2Pos = Offset(w * 0.43, h * 0.32); // Entre chave e lâmpada
        final tp3Pos = Offset(w * 0.60, h * 0.32); // Retorno da lâmpada

        // Bornes do multímetro (COM preto à esquerda, VΩ vermelho à direita)
        final meterBlackJack = Offset(meterPos.dx - 10, meterPos.dy + 118);
        final meterRedJack = Offset(meterPos.dx + 38, meterPos.dy + 118);

        // Sincronização e posicionamento livre das pontas
        if (_redProbeTarget == 'tp1') {
          _redProbePos = tp1Pos;
        } else if (_redProbeTarget == 'tp2') {
          _redProbePos = tp2Pos;
        } else if (_redProbeTarget == 'tp3') {
          _redProbePos = tp3Pos;
        } else {
          _redProbePos ??= Offset(w * 0.44, h * 0.65);
        }

        if (_blackProbeTarget == 'tp1') {
          _blackProbePos = tp1Pos;
        } else if (_blackProbeTarget == 'tp2') {
          _blackProbePos = tp2Pos;
        } else if (_blackProbeTarget == 'tp3') {
          _blackProbePos = tp3Pos;
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
            // 1. Trilhas da placa de ensaio conectando os componentes
            Positioned.fill(
              child: CustomPaint(
                painter: _CircuitBusPainter(
                  battPos: battPos,
                  switchPos: switchPos,
                  bulbPos: bulbPos,
                  tp1Pos: tp1Pos,
                  tp2Pos: tp2Pos,
                  tp3Pos: tp3Pos,
                  isClosed: _switchClosed,
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

            // 3. Chave Liga/Desliga Interativa
            Positioned(
              left: switchPos.dx - 45,
              top: switchPos.dy - 55,
              child: InkWell(
                onTap: _toggleSwitch,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 90,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _switchClosed
                          ? const Color(0xFF10B981)
                          : const Color(0xFFCBD5E1),
                      width: _switchClosed ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _switchClosed
                            ? Icons.toggle_on_rounded
                            : Icons.toggle_off_rounded,
                        size: 42,
                        color: _switchClosed
                            ? const Color(0xFF10B981)
                            : const Color(0xFF64748B),
                      ),
                      Text(
                        _switchClosed ? 'CHAVE ON' : 'CHAVE OFF',
                        style: GoogleFonts.rajdhani(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: _switchClosed
                              ? const Color(0xFF059669)
                              : const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        'Toque p/ alternar',
                        style: GoogleFonts.outfit(
                          fontSize: 9,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 4. Lâmpada Incandescente (Carga)
            Positioned(
              left: bulbPos.dx - 45,
              top: bulbPos.dy - 55,
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
                        type: ComponentType.bulb,
                        isActive: _switchClosed,
                        isDarkMode: false,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'LÂMPADA',
                      style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      _switchClosed ? 'ACESA (9V)' : 'APAGADA (0V)',
                      style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                        color: _switchClosed
                            ? const Color(0xFFD97706)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 5. Ponto de Teste TP1 (+9V saída da bateria)
            Positioned(
              left: tp1Pos.dx - 20,
              top: tp1Pos.dy - 20,
              child: TestPointNode(
                id: 'TP1',
                label: 'Positivo (+9V)',
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

            // 6. Ponto de Teste TP2 (Entre chave e lâmpada)
            Positioned(
              left: tp2Pos.dx - 20,
              top: tp2Pos.dy - 20,
              child: TestPointNode(
                id: 'TP2',
                label: 'Entrada da Lâmpada',
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

            // 7. Ponto de Teste TP3 (Retorno terra da lâmpada)
            Positioned(
              left: tp3Pos.dx - 20,
              top: tp3Pos.dy - 20,
              child: TestPointNode(
                id: 'TP3',
                label: 'Saída da Lâmpada (0V / Terra)',
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

            // 8. Multímetro Digital de Bancada
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

            // 9. Cabos elásticos dinâmicos (EM CIMA da bancada e componentes, NUNCA por trás!)
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

            // 10. Caneta de Ponta de Prova Vermelha (+) Arrastável (apontando para baixo)
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
                    // Snap magnético nos pontos de teste
                    if ((_redProbePos! - tp1Pos).distance < 42) {
                      _redProbeTarget = 'tp1';
                      _redProbePos = tp1Pos;
                    } else if ((_redProbePos! - tp2Pos).distance < 42) {
                      _redProbeTarget = 'tp2';
                      _redProbePos = tp2Pos;
                    } else if ((_redProbePos! - tp3Pos).distance < 42) {
                      _redProbeTarget = 'tp3';
                      _redProbePos = tp3Pos;
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

            // 11. Caneta de Ponta de Prova Preta (COM) Arrastável (apontando para baixo)
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
                    // Snap magnético nos pontos de teste
                    if ((_blackProbePos! - tp1Pos).distance < 42) {
                      _blackProbeTarget = 'tp1';
                      _blackProbePos = tp1Pos;
                    } else if ((_blackProbePos! - tp2Pos).distance < 42) {
                      _blackProbeTarget = 'tp2';
                      _blackProbePos = tp2Pos;
                    } else if ((_blackProbePos! - tp3Pos).distance < 42) {
                      _blackProbeTarget = 'tp3';
                      _blackProbePos = tp3Pos;
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

/// Linhas de fiação da bancada conectando a bateria, chave e lâmpada
class _CircuitBusPainter extends CustomPainter {
  final Offset battPos;
  final Offset switchPos;
  final Offset bulbPos;
  final Offset tp1Pos;
  final Offset tp2Pos;
  final Offset tp3Pos;
  final bool isClosed;

  _CircuitBusPainter({
    required this.battPos,
    required this.switchPos,
    required this.bulbPos,
    required this.tp1Pos,
    required this.tp2Pos,
    required this.tp3Pos,
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

    // Fio superior: Bateria (+) -> TP1 -> Chave
    final topPath = Path()
      ..moveTo(battPos.dx + 45, battPos.dy - 20)
      ..lineTo(tp1Pos.dx, tp1Pos.dy + 20)
      ..lineTo(switchPos.dx - 45, switchPos.dy - 20);
    canvas.drawPath(topPath, wirePaint);

    // Fio médio: Chave -> TP2 -> Lâmpada
    final midPath = Path()
      ..moveTo(switchPos.dx + 45, switchPos.dy - 20)
      ..lineTo(tp2Pos.dx, tp2Pos.dy + 20)
      ..lineTo(bulbPos.dx - 45, bulbPos.dy - 20);
    canvas.drawPath(midPath, wirePaint);

    // Fio de retorno inferior: Lâmpada -> TP3 -> Bateria (-)
    final returnPath = Path()
      ..moveTo(bulbPos.dx + 45, bulbPos.dy)
      ..lineTo(tp3Pos.dx, tp3Pos.dy + 20)
      ..lineTo(tp3Pos.dx, bulbPos.dy + 75)
      ..lineTo(battPos.dx, bulbPos.dy + 75)
      ..lineTo(battPos.dx, battPos.dy + 55);
    canvas.drawPath(returnPath, groundPaint);
  }

  @override
  bool shouldRepaint(covariant _CircuitBusPainter oldDelegate) =>
      oldDelegate.isClosed != isClosed;
}
