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

/// Missão 4 do Estande 07 — Dimensionamento e Medição de Resistor de Proteção do LED.
class MedeTestaExplicaM4 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const MedeTestaExplicaM4({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<MedeTestaExplicaM4> createState() => _MedeTestaExplicaM4State();
}

class _MedeTestaExplicaM4State extends State<MedeTestaExplicaM4> {
  final StandMission _mission = StandMission.medeTestaExplicaMissions[3];
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  bool _usePhysicalStyle = true;
  bool _isSimulating = false;

  // Resistor selecionado para o soquete: 100, 680 ou 10000 (null se vazio)
  int? _installedResistor = 680;

  // Resistor sendo medido na bancada de ensaio independente
  int _testedResistor = 680;

  // Modo do multímetro
  MultimeterMode _multimeterMode = MultimeterMode.currentMa;

  // Pontas de prova do multímetro
  String? _redProbeTarget = 'in';
  String? _blackProbeTarget = 'out';
  Offset? _redProbePos;
  Offset? _blackProbePos;
  bool _isDraggingRed = false;
  bool _isDraggingBlack = false;

  bool get _isProbesConnected =>
      (_redProbeTarget == 'in' && _blackProbeTarget == 'out') ||
      (_redProbeTarget == 'out' && _blackProbeTarget == 'in');

  // Corrente calculada para o resistor instalado: I = (9.0V - 2.0V) / R
  double get _circuitCurrentMa {
    if (_installedResistor == null) return 0.0;
    return (7.0 / _installedResistor!) * 1000.0;
  }

  bool get _isCurrentSafe =>
      _circuitCurrentMa >= 9.0 && _circuitCurrentMa <= 15.0;

  String get _displayValue {
    if (_multimeterMode == MultimeterMode.off) return '---';
    if (!_isProbesConnected) return '0.00';

    switch (_multimeterMode) {
      case MultimeterMode.currentMa:
        return _circuitCurrentMa.toStringAsFixed(1);
      case MultimeterMode.resistance:
        return _testedResistor.toString();
      case MultimeterMode.voltageDc:
        return '9.00';
      case MultimeterMode.continuity:
        return 'BEEP';
      case MultimeterMode.off:
        return '---';
    }
  }

  int get _currentStepperIndex {
    if (_installedResistor == null) return 0;
    if (_multimeterMode != MultimeterMode.currentMa) return 1;
    return 2;
  }

  bool _isStepCompleted(int index) {
    if (index == 0) return _installedResistor != null;
    if (index == 1) return _multimeterMode == MultimeterMode.currentMa;
    if (index == 2) {
      return _installedResistor == 680 &&
          _multimeterMode == MultimeterMode.currentMa &&
          _isCurrentSafe;
    }
    return false;
  }

  void _selectInstalledResistor(int? r) {
    final prev = _installedResistor;
    _undoRedoController.execute(SelectOptionAction(
      description: 'Instalar resistor $r Ω',
      onApply: () => setState(() => _installedResistor = r),
      onUndo: () => setState(() => _installedResistor = prev),
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
      _installedResistor = 680;
      _testedResistor = 680;
      _redProbeTarget = null;
      _blackProbeTarget = null;
      _redProbePos = null;
      _blackProbePos = null;
      _multimeterMode = MultimeterMode.currentMa;
    });
  }

  Future<void> _validateMission() async {
    if (_isSimulating) return;
    setState(() => _isSimulating = true);

    try {
      bool isSuccess = false;
      String feedback = _mission.failureFeedback;

      if (_installedResistor == null) {
        feedback = 'Instale um resistor no soquete de proteção do LED.';
      } else if (_multimeterMode != MultimeterMode.currentMa) {
        feedback =
            'Gire a chave do multímetro para mA⎓ para medir a corrente resultante no LED.';
      } else if (_installedResistor == 100) {
        feedback =
            'Alerta de sobrecorrente! Com 100Ω, a corrente atinge ${_circuitCurrentMa.toStringAsFixed(1)}mA. O LED queimaria em poucos segundos!';
      } else if (_installedResistor == 10000) {
        feedback =
            'Corrente insuficiente! Com 10kΩ, a corrente é de apenas ${_circuitCurrentMa.toStringAsFixed(2)}mA. O LED permanece praticamente apagado.';
      } else if (_installedResistor == 680 && _isCurrentSafe) {
        isSuccess = true;
        feedback =
            'Excelente escolha fundamentada em medição! Com 680Ω, a corrente medida é de ${_circuitCurrentMa.toStringAsFixed(1)}mA (faixa segura ideal 10-15 mA).';
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
              'LED Protegido com Sucesso!',
              style: GoogleFonts.rajdhani(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        content: Text(
          'Decisão impecável! Você mediu a corrente de 10.3 mA com o resistor de 680Ω, garantindo brilho ideal e vida útil prolongada ao LED sem risco de queima por sobrecorrente.',
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
              'Corrente Fora da Faixa Segura',
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
              'Testar Outro Resistor',
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
          isClosed: _installedResistor != null,
        ),
        rightHeaderWidget: MedeTestaTelemetryCard(
          voltage: 9.0,
          currentMa: _circuitCurrentMa,
          isClosed: _installedResistor != null,
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
        buttonLabel: 'VALIDAR RESISTOR SEGURO',
        toolboxItems: [
          WorkbenchMissionObjectiveCard(
            missionNumber: 4,
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
              'Selecionar um resistor para o soquete do circuito',
              'Girar seletor do multímetro para mA⎓ (Corrente)',
              'Validar a corrente na faixa segura (10 a 15 mA)',
            ],
          ),
          const SizedBox(height: 12),
          _buildResistorSelectionPanel(),
        ],
        onEnergizePressed: _validateMission,
        isLoading: _isSimulating,
      ),
    );
  }

  Widget _buildResistorSelectionPanel() {
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
            'GAVETA DE RESISTORES (ENSAIO)',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF94A3B8),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          _buildResistorChip(100, '100 Ω (Faixa Marrom-Preto-Marrom)'),
          const SizedBox(height: 6),
          _buildResistorChip(680, '680 Ω (Faixa Azul-Cinza-Marrom) ★'),
          const SizedBox(height: 6),
          _buildResistorChip(10000, '10 kΩ (Faixa Marrom-Preto-Laranja)'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: _isProbesConnected
                          ? const Color(0xFF10B981)
                          : const Color(0xFF475569),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                  ),
                  onPressed: () {
                    _setRedProbeTarget('in');
                    _setBlackProbeTarget('out');
                  },
                  child: Text(
                    'Medir Resistor\n(TP_IN - TP_OUT)',
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
                  onPressed: _reset,
                  child: Text(
                    'Soltar Pontas\nna Bancada',
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
        ],
      ),
    );
  }

  Widget _buildResistorChip(int value, String label) {
    final isSelected = _installedResistor == value;
    final color = value == 680
        ? const Color(0xFF10B981)
        : (value == 100 ? const Color(0xFFEF4444) : const Color(0xFF38BDF8));

    return InkWell(
      onTap: () {
        _selectInstalledResistor(value);
        setState(() => _testedResistor = value);
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.25)
              : const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : const Color(0xFF334155),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.rajdhani(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
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
        final socketPos = Offset(w * 0.38, h * 0.48);
        final ledPos = Offset(w * 0.58, h * 0.48);
        final meterPos = Offset(w * 0.80, h * 0.48);

        // Pontos de teste
        final tpIn = Offset(socketPos.dx - 45, socketPos.dy - 60);
        final tpOut = Offset(socketPos.dx + 45, socketPos.dy - 60);

        final meterBlackJack = Offset(meterPos.dx - 10, meterPos.dy + 118);
        final meterRedJack = Offset(meterPos.dx + 38, meterPos.dy + 118);

        // Sincronização e posicionamento livre das pontas
        if (_redProbeTarget == 'in') {
          _redProbePos = tpIn;
        } else if (_redProbeTarget == 'out') {
          _redProbePos = tpOut;
        } else {
          _redProbePos ??= Offset(w * 0.44, h * 0.65);
        }

        if (_blackProbeTarget == 'in') {
          _blackProbePos = tpIn;
        } else if (_blackProbeTarget == 'out') {
          _blackProbePos = tpOut;
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
            // 1. Fiação fixa da placa
            Positioned.fill(
              child: CustomPaint(
                painter: _M4CircuitPainter(
                  battPos: battPos,
                  socketPos: socketPos,
                  ledPos: ledPos,
                  tpIn: tpIn,
                  tpOut: tpOut,
                  hasResistor: _installedResistor != null,
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

            // 3. Soquete com Resistor Instalado
            Positioned(
              left: socketPos.dx - 55,
              top: socketPos.dy - 55,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _isCurrentSafe
                        ? const Color(0xFF10B981)
                        : const Color(0xFFCBD5E1),
                    width: _isCurrentSafe ? 2.5 : 1.5,
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
                      '${_installedResistor ?? 0} Ω',
                      style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      _isCurrentSafe ? 'FAIXA SEGURA' : 'FORA DA FAIXA',
                      style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                        color: _isCurrentSafe
                            ? const Color(0xFF059669)
                            : const Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. LED com resposta de brilho
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
                        if (_installedResistor != null)
                          Container(
                            width: 32 + (_circuitCurrentMa / 3.0),
                            height: 32 + (_circuitCurrentMa / 3.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (_installedResistor == 100
                                      ? Colors.red
                                      : const Color(0xFF10B981))
                                  .withValues(
                                      alpha: (_circuitCurrentMa / 40)
                                          .clamp(0.1, 0.9)),
                            ),
                          ),
                        CustomPaint(
                          size: const Size(44, 44),
                          painter: ComponentPhysicalPainter(
                            type: ComponentType.led,
                            isActive: _installedResistor != null,
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
                      '${_circuitCurrentMa.toStringAsFixed(1)} mA',
                      style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                        color: _isCurrentSafe
                            ? const Color(0xFF059669)
                            : const Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 5. Ponto de Teste TP_IN
            Positioned(
              left: tpIn.dx - 20,
              top: tpIn.dy - 20,
              child: TestPointNode(
                id: 'TP_IN',
                label: 'Entrada Resistor',
                hasRedProbe: _redProbeTarget == 'in',
                hasBlackProbe: _blackProbeTarget == 'in',
                onConnectRed: () => _setRedProbeTarget('in'),
                onConnectBlack: () => _setBlackProbeTarget('in'),
                onDisconnect: () {
                  if (_redProbeTarget == 'in') _setRedProbeTarget(null);
                  if (_blackProbeTarget == 'in') _setBlackProbeTarget(null);
                },
              ),
            ),

            // 6. Ponto de Teste TP_OUT
            Positioned(
              left: tpOut.dx - 20,
              top: tpOut.dy - 20,
              child: TestPointNode(
                id: 'TP_OUT',
                label: 'Saída Resistor',
                hasRedProbe: _redProbeTarget == 'out',
                hasBlackProbe: _blackProbeTarget == 'out',
                onConnectRed: () => _setRedProbeTarget('out'),
                onConnectBlack: () => _setBlackProbeTarget('out'),
                onDisconnect: () {
                  if (_redProbeTarget == 'out') _setRedProbeTarget(null);
                  if (_blackProbeTarget == 'out') _setBlackProbeTarget(null);
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
                    // Snap magnético nos pontos de teste
                    if ((_redProbePos! - tpIn).distance < 42) {
                      _redProbeTarget = 'in';
                      _redProbePos = tpIn;
                    } else if ((_redProbePos! - tpOut).distance < 42) {
                      _redProbeTarget = 'out';
                      _redProbePos = tpOut;
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
                    // Snap magnético nos pontos de teste
                    if ((_blackProbePos! - tpIn).distance < 42) {
                      _blackProbeTarget = 'in';
                      _blackProbePos = tpIn;
                    } else if ((_blackProbePos! - tpOut).distance < 42) {
                      _blackProbeTarget = 'out';
                      _blackProbePos = tpOut;
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

class _M4CircuitPainter extends CustomPainter {
  final Offset battPos;
  final Offset socketPos;
  final Offset ledPos;
  final Offset tpIn;
  final Offset tpOut;
  final bool hasResistor;

  _M4CircuitPainter({
    required this.battPos,
    required this.socketPos,
    required this.ledPos,
    required this.tpIn,
    required this.tpOut,
    required this.hasResistor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final wirePaint = Paint()
      ..color = hasResistor ? const Color(0xFF0284C7) : const Color(0xFF94A3B8)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final groundPaint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Bateria (+) -> Resistor
    final p1 = Path()
      ..moveTo(battPos.dx + 45, battPos.dy - 20)
      ..lineTo(socketPos.dx - 55, socketPos.dy - 20);
    canvas.drawPath(p1, wirePaint);

    // Resistor -> LED
    final p2 = Path()
      ..moveTo(socketPos.dx + 55, socketPos.dy - 20)
      ..lineTo(ledPos.dx - 45, ledPos.dy - 20);
    canvas.drawPath(p2, wirePaint);

    // LED (-) -> Bateria (-)
    final pReturn = Path()
      ..moveTo(ledPos.dx + 45, ledPos.dy)
      ..lineTo(ledPos.dx + 45, ledPos.dy + 75)
      ..lineTo(battPos.dx, ledPos.dy + 75)
      ..lineTo(battPos.dx, battPos.dy + 55);
    canvas.drawPath(pReturn, groundPaint);
  }

  @override
  bool shouldRepaint(covariant _M4CircuitPainter oldDelegate) =>
      oldDelegate.hasResistor != hasResistor;
}
