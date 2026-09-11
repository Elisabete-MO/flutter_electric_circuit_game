import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/ui_scale.dart';
import '../../../models/circuit_action.dart';
import '../../../models/stand_mission.dart';
import '../../../state/circuit_undo_redo_controller.dart';
import '../../../widgets/success_confetti_overlay.dart';
import '../../../widgets/workbench_components.dart';
import '../../../widgets/workbench_sidebar_cards.dart';
import '../../../widgets/workbench_table_frame.dart';
import '../widgets/mede_testa_explica_widgets.dart';

/// Missão 1 do Estande 07 — Medição Direta da Bateria 9V com Multímetro Realista e Pontas de Prova Soltas.
class MedeTestaExplicaM1 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const MedeTestaExplicaM1({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<MedeTestaExplicaM1> createState() => _MedeTestaExplicaM1State();
}

class _MedeTestaExplicaM1State extends State<MedeTestaExplicaM1> {
  final StandMission _mission = StandMission.medeTestaExplicaMissions[0];
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  bool _usePhysicalStyle = true;
  bool _isSimulating = false;

  // Posições das pontas de prova na bancada (agulha em Offset)
  Offset? _redProbePos;
  Offset? _blackProbePos;
  bool _isDraggingRed = false;
  bool _isDraggingBlack = false;

  MultimeterMode _multimeterMode = MultimeterMode.voltageDc;

  // Alvo em que a ponta está conectada: 'pos', 'neg' ou null (livre na bancada)
  String? _redTerminalTarget;
  String? _blackTerminalTarget;

  bool get _bothProbesConnected =>
      _redTerminalTarget != null && _blackTerminalTarget != null;

  bool get _isCorrectPolarity =>
      _redTerminalTarget == 'pos' && _blackTerminalTarget == 'neg';

  bool get _isInvertedPolarity =>
      _redTerminalTarget == 'neg' && _blackTerminalTarget == 'pos';

  double get _measuredVoltage {
    if (!_bothProbesConnected) return 0.0;
    if (_redTerminalTarget == _blackTerminalTarget) return 0.0;
    if (_isCorrectPolarity) return 9.0;
    if (_isInvertedPolarity) return -9.0;
    return 0.0;
  }

  String get _displayValue {
    if (_multimeterMode == MultimeterMode.off) return '---';
    if (!_bothProbesConnected) return '0.00';
    if (_redTerminalTarget == _blackTerminalTarget) return '0.00';

    switch (_multimeterMode) {
      case MultimeterMode.voltageDc:
        return _measuredVoltage.toStringAsFixed(2);
      case MultimeterMode.currentMa:
        return '0.00';
      case MultimeterMode.resistance:
        return 'O.L';
      case MultimeterMode.continuity:
        return '---';
      case MultimeterMode.off:
        return '---';
    }
  }

  int get _currentStepperIndex {
    if (!_bothProbesConnected) return 0;
    if (_multimeterMode != MultimeterMode.voltageDc) return 1;
    return 2;
  }

  bool _isStepCompleted(int index) {
    if (index == 0) return _bothProbesConnected;
    if (index == 1) return _multimeterMode == MultimeterMode.voltageDc;
    if (index == 2) {
      return _bothProbesConnected &&
          _multimeterMode == MultimeterMode.voltageDc &&
          _measuredVoltage.abs() == 9.0;
    }
    return false;
  }

  void _setRedTerminalTarget(String? target, {Offset? snappedPos}) {
    final prevTarget = _redTerminalTarget;
    final prevPos = _redProbePos;
    _undoRedoController.execute(ToggleProbeAction(
      description: 'Mover Ponta Vermelha para ${target ?? 'Bancada'}',
      onApply: () => setState(() {
        _redTerminalTarget = target;
        if (snappedPos != null) {
          _redProbePos = snappedPos;
        } else if (target == null) {
          _redProbePos = null;
        }
      }),
      onUndo: () => setState(() {
        _redTerminalTarget = prevTarget;
        _redProbePos = prevPos;
      }),
    ));
  }

  void _setBlackTerminalTarget(String? target, {Offset? snappedPos}) {
    final prevTarget = _blackTerminalTarget;
    final prevPos = _blackProbePos;
    _undoRedoController.execute(ToggleProbeAction(
      description: 'Mover Ponta Preta para ${target ?? 'Bancada'}',
      onApply: () => setState(() {
        _blackTerminalTarget = target;
        if (snappedPos != null) {
          _blackProbePos = snappedPos;
        } else if (target == null) {
          _blackProbePos = null;
        }
      }),
      onUndo: () => setState(() {
        _blackTerminalTarget = prevTarget;
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
      _redTerminalTarget = null;
      _blackTerminalTarget = null;
      _redProbePos = null;
      _blackProbePos = null;
      _multimeterMode = MultimeterMode.voltageDc;
    });
  }

  Future<void> _validateMission() async {
    if (_isSimulating) return;
    setState(() => _isSimulating = true);

    try {
      bool isSuccess = false;
      String feedback = _mission.failureFeedback;

      if (!_bothProbesConnected) {
        feedback =
            'Arraste e encoste as duas pontas de prova (vermelha e preta) nos terminais metálicos da bateria de 9V!';
      } else if (_redTerminalTarget == _blackTerminalTarget) {
        feedback =
            'As duas pontas estão encostadas no mesmo terminal! Encoste uma no terminal positivo (+) e outra no negativo (-).';
      } else if (_multimeterMode != MultimeterMode.voltageDc) {
        feedback =
            'Gire a chave seletora do multímetro para V⎓ (Tensão Contínua) para ler a d.d.p. da bateria.';
      } else if (_measuredVoltage.abs() == 9.0) {
        isSuccess = true;
        if (_measuredVoltage < 0) {
          feedback =
              'Excelente observação! A tensão medida foi de -9.00V porque você encostou a ponta vermelha no pólo negativo e a preta no positivo. Convenção de sinais comprovada!';
        } else {
          feedback =
              'Perfeito! Leitura direta de 9.00V DC obtida com sucesso ao encostar as pontas de prova nos pólos da bateria.';
        }
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
              'Medição Concluída!',
              style: GoogleFonts.rajdhani(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        content: Text(
          'Excelente trabalho! Você pegou as pontas de prova reais do multímetro, encostou nos terminais metálicos da bateria de 9V e comprovou a diferença de potencial elétrico de 9.00V DC!',
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
              'Revisar Pontas de Prova',
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
          isClosed: _bothProbesConnected &&
              _multimeterMode == MultimeterMode.voltageDc,
        ),
        rightHeaderWidget: MedeTestaTelemetryCard(
          voltage: _measuredVoltage.abs(),
          currentMa: 0.0,
          isClosed: _bothProbesConnected,
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
        buttonLabel: 'VALIDAR MEDIÇÃO',
        toolboxItems: [
          WorkbenchMissionObjectiveCard(
            missionNumber: 1,
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
              'Arraste as pontas de prova e encoste nos terminais da bateria',
              'Girar seletor do multímetro para V⎓ (Tensão Contínua)',
              'Validar a medição de 9.00V DC no display',
            ],
          ),
          const SizedBox(height: 12),
          _buildProbeControlsCard(),
        ],
        onEnergizePressed: _validateMission,
        isLoading: _isSimulating,
      ),
    );
  }

  Widget _buildProbeControlsCard() {
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
            'CONTROLE RÁPIDO DE PONTAS',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF94A3B8),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Dica: Você pode arrastar as pontas de prova com o dedo/mouse pela bancada.',
            style: GoogleFonts.outfit(color: Colors.white60, fontSize: 11),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                  ),
                  onPressed: () {
                    final next = _redTerminalTarget == null
                        ? 'pos'
                        : (_redTerminalTarget == 'pos' ? 'neg' : null);
                    _setRedTerminalTarget(next);
                  },
                  icon: const Icon(Icons.touch_app_rounded, size: 14),
                  label: Text(
                    'Ponta Vermelha: ${_targetLabel(_redTerminalTarget)}',
                    style: GoogleFonts.rajdhani(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                  ),
                  onPressed: () {
                    final next = _blackTerminalTarget == null
                        ? 'neg'
                        : (_blackTerminalTarget == 'neg' ? 'pos' : null);
                    _setBlackTerminalTarget(next);
                  },
                  icon: const Icon(Icons.touch_app_rounded, size: 14),
                  label: Text(
                    'Ponta Preta: ${_targetLabel(_blackTerminalTarget)}',
                    style: GoogleFonts.rajdhani(
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
              icon: const Icon(Icons.cable_rounded, size: 16),
              label: Text(
                'Soltar Pontas na Bancada',
                style: GoogleFonts.rajdhani(
                  color: const Color(0xFF94A3B8),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _targetLabel(String? target) {
    if (target == 'pos') return 'POLO (+)';
    if (target == 'neg') return 'POLO (-)';
    return 'SOLTA NA BANCADA';
  }

  Widget _buildWorkbenchContent(UiScale scale) {
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        final h = box.maxHeight;

        // Posição central da Bateria 9V na bancada (sem caixa branca!)
        final battPos = Offset(w * 0.28, h * 0.48);
        const battWidth = 110.0;
        const battHeight = 160.0;
        final battTopLeft = Offset(battPos.dx - battWidth / 2, battPos.dy - battHeight / 2);

        // Posições exatas dos pólos de contato metálicos na bateria (topo dos terminais 3D)
        final posTerminalContact = Offset(battTopLeft.dx + battWidth * 0.31, battTopLeft.dy + 4.0);
        final negTerminalContact = Offset(battTopLeft.dx + battWidth * 0.69, battTopLeft.dy + 4.0);

        // Posição do Multímetro na bancada
        final meterPos = Offset(w * 0.74, h * 0.46);
        // Bornes inferiores dos conectores banana inseridos
        final meterBlackJack = Offset(meterPos.dx - 10, meterPos.dy + 118);
        final meterRedJack = Offset(meterPos.dx + 38, meterPos.dy + 118);

        // Inicialização padrão das pontas se ainda não definidas:
        // Soltas na bancada de trabalho ao lado do multímetro, sem tocar na bateria!
        if (_redProbePos == null) {
          if (_redTerminalTarget == 'pos') {
            _redProbePos = posTerminalContact;
          } else if (_redTerminalTarget == 'neg') {
            _redProbePos = negTerminalContact;
          } else {
            _redProbePos = Offset(w * 0.44, h * 0.65);
          }
        }

        if (_blackProbePos == null) {
          if (_blackTerminalTarget == 'neg') {
            _blackProbePos = negTerminalContact;
          } else if (_blackTerminalTarget == 'pos') {
            _blackProbePos = posTerminalContact;
          } else {
            _blackProbePos = Offset(w * 0.54, h * 0.65);
          }
        }

        // Se estiver encaixada nos terminais e não estiver sendo arrastada, alinha perfeitamente
        final effectiveRedPos = _isDraggingRed
            ? _redProbePos!
            : (_redTerminalTarget == 'pos'
                ? posTerminalContact
                : (_redTerminalTarget == 'neg' ? negTerminalContact : _redProbePos!));

        final effectiveBlackPos = _isDraggingBlack
            ? _blackProbePos!
            : (_blackTerminalTarget == 'neg'
                ? negTerminalContact
                : (_blackTerminalTarget == 'pos' ? posTerminalContact : _blackProbePos!));

        // Cauda das canetas de prova (onde o cabo entra, no topo da caneta que aponta para baixo)
        final probeRedTail = Offset(effectiveRedPos.dx, effectiveRedPos.dy - 93);
        final probeBlackTail = Offset(effectiveBlackPos.dx, effectiveBlackPos.dy - 93);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. Bateria 9V Ultra-Realista (sem caixa branca, direto na bancada)
            Positioned(
              left: battTopLeft.dx,
              top: battTopLeft.dy,
              child: Realistic9VBatteryWidget(
                width: battWidth,
                height: battHeight,
                hasRedProbeConnectedPos: _redTerminalTarget == 'pos',
                hasBlackProbeConnectedPos: _blackTerminalTarget == 'pos',
                hasRedProbeConnectedNeg: _redTerminalTarget == 'neg',
                hasBlackProbeConnectedNeg: _blackTerminalTarget == 'neg',
              ),
            ),

            // 2. Multímetro Digital de Alta Fidelidade (inspirado na ilustração)
            Positioned(
              left: meterPos.dx - 97,
              top: meterPos.dy - 145,
              child: DigitalMultimeterWidget(
                currentMode: _multimeterMode,
                onModeChanged: _setMultimeterMode,
                displayValue: _displayValue,
                displayUnit: _multimeterMode.unit,
                isRedConnected: _redTerminalTarget != null,
                isBlackConnected: _blackTerminalTarget != null,
              ),
            ),

            // 3. Cabos elásticos dinâmicos (EM CIMA da bancada e da bateria, NUNCA por trás!)
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

            // 4. Caneta de Ponta de Prova Vermelha (+) Arrastável (apontando para baixo)
            Positioned(
              left: effectiveRedPos.dx - 14,
              top: effectiveRedPos.dy - 96,
              child: GestureDetector(
                onPanStart: (_) => setState(() => _isDraggingRed = true),
                onPanUpdate: (details) {
                  setState(() {
                    _redProbePos = (_redProbePos ?? effectiveRedPos) + details.delta;
                    // Desconecta temporariamente enquanto arrasta livremente
                    _redTerminalTarget = null;
                  });
                },
                onPanEnd: (_) {
                  setState(() {
                    _isDraggingRed = false;
                    // Snap magnético no terminal positivo (+)
                    if ((_redProbePos! - posTerminalContact).distance < 42) {
                      _redTerminalTarget = 'pos';
                      _redProbePos = posTerminalContact;
                    }
                    // Snap magnético no terminal negativo (-)
                    else if ((_redProbePos! - negTerminalContact).distance < 42) {
                      _redTerminalTarget = 'neg';
                      _redProbePos = negTerminalContact;
                    }
                  });
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.grab,
                  child: ProbePenWidget(
                    isRed: true,
                    isConnected: _redTerminalTarget != null,
                    isDragging: _isDraggingRed,
                    pointingDown: true,
                  ),
                ),
              ),
            ),

            // 5. Caneta de Ponta de Prova Preta (COM) Arrastável (apontando para baixo)
            Positioned(
              left: effectiveBlackPos.dx - 14,
              top: effectiveBlackPos.dy - 96,
              child: GestureDetector(
                onPanStart: (_) => setState(() => _isDraggingBlack = true),
                onPanUpdate: (details) {
                  setState(() {
                    _blackProbePos = (_blackProbePos ?? effectiveBlackPos) + details.delta;
                    _blackTerminalTarget = null;
                  });
                },
                onPanEnd: (_) {
                  setState(() {
                    _isDraggingBlack = false;
                    // Snap magnético no terminal negativo (-)
                    if ((_blackProbePos! - negTerminalContact).distance < 42) {
                      _blackTerminalTarget = 'neg';
                      _blackProbePos = negTerminalContact;
                    }
                    // Snap magnético no terminal positivo (+)
                    else if ((_blackProbePos! - posTerminalContact).distance < 42) {
                      _blackTerminalTarget = 'pos';
                      _blackProbePos = posTerminalContact;
                    }
                  });
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.grab,
                  child: ProbePenWidget(
                    isRed: false,
                    isConnected: _blackTerminalTarget != null,
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
