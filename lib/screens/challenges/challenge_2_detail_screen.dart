import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:confetti/confetti.dart';

import '../../l10n/app_localizations.dart';
import '../../models/first_step_component.dart';
import '../../services/audio_service.dart';
import '../../state/progress_controller.dart';
import '../../widgets/challenge_layout_components.dart';
import '../../widgets/circuit_symbol_painter.dart';
import '../../widgets/component_physical_painter.dart';
import '../../widgets/prof_volts_speech.dart';
import '../../widgets/tech_grid_background.dart';
import '../../widgets/prof_volts_challenge_dialog.dart';

/// Tela interativa da execução do Desafio 2.
///
/// Apresenta o circuito contendo: Bateria (4.5V), Interruptor e Motor.
/// Passos:
/// 1. Observe este circuito (com a opção de testar o interruptor fazendo o motor girar).
/// 2. Clicar no botão amarelo ("circuit diagram") para montar o diagrama esquemático.
/// No modo diagrama esquemático: Arrastar/selecionar os símbolos da barra lateral (Bateria, Interruptor e Motor) e posicioná-los nos locais corretos do diagrama elétrico.
class Challenge2DetailScreen extends ConsumerStatefulWidget {
  const Challenge2DetailScreen({super.key});

  @override
  ConsumerState<Challenge2DetailScreen> createState() => _Challenge2DetailScreenState();
}

class _Challenge2DetailScreenState extends ConsumerState<Challenge2DetailScreen>
    with TickerProviderStateMixin {
  // Estado do Passo 1: Interruptor e Motor
  bool _isSwitchClosed = false;
  bool _showDiagramMode = false;
  bool _useRealisticAssets = true;

  // Estado do Passo 2: Símbolos posicionados nos 3 slots (Bateria, Interruptor, Motor)
  ComponentType? _slotBattery;
  ComponentType? _slotSwitch;
  ComponentType? _slotMotor;

  late final AnimationController _currentAnimationController;
  late final AnimationController _pulseAnimationController;
  late final ConfettiController _confettiController;
  final ScrollController _paletteVerticalScrollController = ScrollController();
  final ScrollController _paletteHorizontalScrollController = ScrollController();

  int _attempts = 0;
  late final DateTime _startTime;
  Timer? _timer;
  int _elapsedSeconds = 0;
  late final AudioService _audio;

  @override
  void initState() {
    super.initState();
    _audio = ref.read(audioServiceProvider);
    _audio.playBgm();
    _startTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && !_isDiagramCorrect) {
        setState(() {
          _elapsedSeconds = DateTime.now().difference(_startTime).inSeconds;
        });
      }
    });
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _currentAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audio.stopBgm();
    _currentAnimationController.dispose();
    _pulseAnimationController.dispose();
    _confettiController.dispose();
    _paletteVerticalScrollController.dispose();
    _paletteHorizontalScrollController.dispose();
    super.dispose();
  }

  bool get _isDiagramCorrect =>
      _slotBattery == ComponentType.battery &&
      _slotSwitch == ComponentType.switchComponent &&
      _slotMotor == ComponentType.motor;

  void _verifyDiagram() {
    final l10n = AppLocalizations.of(context)!;
    final isCorrect = _isDiagramCorrect;

    int stars = 3;
    if (isCorrect) {
      final elapsedSeconds = DateTime.now().difference(_startTime).inSeconds;
      if (_attempts > 2 || elapsedSeconds > 60) {
        stars = 1;
      } else if (_attempts > 0 || elapsedSeconds > 30) {
        stars = 2;
      }

      ref.read(audioServiceProvider).playSuccess();
      _confettiController.play();
    } else {
      _attempts++;
      ref.read(audioServiceProvider).playError();
    }

    showDialog(
      context: context,
      builder: (context) => ProfVoltsChallengeDialog(
        isCorrect: isCorrect,
        title: isCorrect ? l10n.dialogCorrectTitle : l10n.dialogIncorrectTitle,
        message: isCorrect ? l10n.dialogCorrectMsg : l10n.dialogIncorrectMsg,
        stars: stars,
        onAction: () async {
          if (isCorrect) {
            await ref.read(progressControllerProvider.notifier).markAsCompleted('challenge_2', stars: stars);
            if (!context.mounted) return;
            Navigator.of(context).pop(); // fecha modal
            Navigator.of(context).pop(); // volta pra tela de desafios
          } else {
            Navigator.of(context).pop(); // apenas fecha modal para tentar de novo
          }
        },
      ),
    );
  }

  void _resetDiagram() {
    setState(() {
      _slotBattery = null;
      _slotSwitch = null;
      _slotMotor = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.challenge2DetailTitle,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: TechGridBackground(
        child: SafeArea(
          child: Stack(
            children: [
            Column(
              children: [
                // Painel Superior de Instruções (Mascote) / Timer no Modo Diagrama
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: _showDiagramMode
                      ? ChallengeTimerBadge(elapsedSeconds: _elapsedSeconds)
                      : ProfVoltsSpeech(
                          text: '${l10n.challengeObserveInstruction}\n${l10n.challengeMakeDiagramInstruction}',
                          elapsedSeconds: _elapsedSeconds,
                        ),
                ),

            // Área Principal do Desafio
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 600;

                  final circuitBoardArea = Stack(
                    children: [
                      // Fundo Estático da Bancada do Circuito (Repinta apenas quando o circuito muda de estado)
                      Positioned.fill(
                        child: RepaintBoundary(
                          child: CustomPaint(
                            painter: _Challenge2BoardPainter(
                              isSwitchClosed: _isSwitchClosed,
                              showDiagramMode: _showDiagramMode,
                              slotBattery: _slotBattery,
                              slotSwitch: _slotSwitch,
                              slotMotor: _slotMotor,
                              isDark: isDark,
                              useRealisticAssets: _useRealisticAssets,
                              drawParticlesOnly: false,
                            ),
                          ),
                        ),
                      ),

                      // Camada de Partículas Elétricas Dinâmicas (60fps isolados pela GPU via RepaintBoundary)
                      if (_isSwitchClosed && !_showDiagramMode)
                        Positioned.fill(
                          child: RepaintBoundary(
                            child: AnimatedBuilder(
                              animation: _currentAnimationController,
                              builder: (context, _) {
                                return CustomPaint(
                                  painter: _Challenge2BoardPainter(
                                    isSwitchClosed: _isSwitchClosed,
                                    showDiagramMode: _showDiagramMode,
                                    slotBattery: _slotBattery,
                                    slotSwitch: _slotSwitch,
                                    slotMotor: _slotMotor,
                                    isDark: isDark,
                                    currentProgress: _currentAnimationController.value,
                                    drawParticlesOnly: true,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                      // Componentes Físicos Realistas (PNGs) na Bancada
                      if (!_showDiagramMode && _useRealisticAssets)
                        Positioned.fill(
                          child: LayoutBuilder(
                            builder: (context, boardConstraints) {
                              final w = boardConstraints.maxWidth;
                              final h = boardConstraints.maxHeight;
                              final batX = w * 0.18;
                              final batY = h * 0.48;
                              final swX = w * 0.72;
                              final swY = h * 0.26;
                              final motorX = w * 0.72;
                              final motorY = h * 0.72;

                              return Stack(
                                children: [
                                  Positioned(
                                    left: batX - 60,
                                    top: batY - 50,
                                    width: 120,
                                    height: 100,
                                    child: Image.asset(ComponentType.battery.getAssetPath(false)!, fit: BoxFit.contain),
                                  ),
                                  Positioned(
                                    left: swX - 70,
                                    top: swY - 45,
                                    width: 140,
                                    height: 90,
                                    child: Image.asset(ComponentType.switchComponent.getAssetPath(_isSwitchClosed)!, fit: BoxFit.contain),
                                  ),
                                  Positioned(
                                    left: motorX - 70,
                                    top: motorY - 45,
                                    width: 140,
                                    height: 90,
                                    child: Image.asset(ComponentType.motor.getAssetPath(_isSwitchClosed)!, fit: BoxFit.contain),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                      // Interruptor Físico Clicável (Modo Físico)
                      if (!_showDiagramMode)
                        Positioned(
                          top: 16,
                          right: 20,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              setState(() {
                                _isSwitchClosed = !_isSwitchClosed;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E2638) : Colors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _isSwitchClosed ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                                  width: 2,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isSwitchClosed ? Icons.lock_outline : Icons.lock_open_rounded,
                                    color: _isSwitchClosed ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isSwitchClosed ? l10n.switchClosed : l10n.switchOpen,
                                    style: TextStyle(
                                      fontFamily: GoogleFonts.rajdhani().fontFamily,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      letterSpacing: 0.5,
                                      color: _isSwitchClosed ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      // Clique Direto no Asset do Interruptor Físico na Bancada
                      if (!_showDiagramMode)
                        Positioned(
                          left: constraints.maxWidth * 0.50 - 70,
                          top: constraints.maxHeight * 0.22 - 45,
                          width: 140,
                          height: 90,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                ref.read(audioServiceProvider).playClick();
                                setState(() {
                                  _isSwitchClosed = !_isSwitchClosed;
                                });
                              },
                              child: const SizedBox.expand(),
                            ),
                          ),
                        ),

                      // Painel de Controle Flutuante Inferior (Alternância de Modo + Ações do Diagrama)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 24,
                        child: Center(
                          child: FloatingActionDock(
                            children: [
                              ModeToggleSwitch(
                                isDiagramMode: _showDiagramMode,
                                onChanged: (val) {
                                  setState(() {
                                    _showDiagramMode = val;
                                  });
                                },
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  setState(() {
                                    _useRealisticAssets = !_useRealisticAssets;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _useRealisticAssets
                                        ? theme.colorScheme.primary.withValues(alpha: 0.18)
                                        : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _useRealisticAssets
                                          ? theme.colorScheme.primary
                                          : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _useRealisticAssets ? Icons.photo_library_rounded : Icons.brush_rounded,
                                        size: 14,
                                        color: _useRealisticAssets ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _useRealisticAssets ? 'Modo realista' : 'Modo cartoon',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontFamily: GoogleFonts.rajdhani().fontFamily,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.6,
                                          color: _useRealisticAssets ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (_showDiagramMode) ...[
                                DiagramActionButton(
                                  icon: Icons.verified_rounded,
                                  label: l10n.buttonVerify,
                                  gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
                                  onTap: _verifyDiagram,
                                ),
                                DiagramActionButton(
                                  icon: Icons.refresh_rounded,
                                  label: l10n.buttonReset,
                                  gradientColors: const [Color(0xFFF59E0B), Color(0xFFD97706)],
                                  onTap: _resetDiagram,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      // Slots de Drop no Modo Diagrama (Bateria, Interruptor, Motor)
                      if (_showDiagramMode)
                        Positioned.fill(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final cx = constraints.maxWidth / 2;
                              final cy = constraints.maxHeight / 2;

                              // Adapta dinamicamente o tamanho do diagrama Ã s dimensões da tela
                              final dx = (constraints.maxWidth * 0.26).clamp(80.0, 150.0);
                              final dy = (constraints.maxHeight * 0.22).clamp(55.0, 100.0);

                              final leftX = cx - dx;
                              final topY = cy - dy;
                              final bottomY = cy + dy;

                              return Stack(
                                children: [
                                  // Slot 1: Bateria (Lado Esquerdo)
                                  _buildDropSlot(
                                    left: leftX - 40,
                                    top: cy - 30,
                                    width: 80,
                                    height: 60,
                                    currentType: _slotBattery,
                                    label: l10n.compBattery,
                                    onAccept: (type) => setState(() => _slotBattery = type),
                                    onClear: () => setState(() => _slotBattery = null),
                                    isVertical: true,
                                  ),

                                  // Slot 2: Interruptor (Topo do Diagrama)
                                  _buildDropSlot(
                                    left: cx - 40,
                                    top: topY - 30,
                                    width: 80,
                                    height: 60,
                                    currentType: _slotSwitch,
                                    label: l10n.compSwitch,
                                    onAccept: (type) => setState(() => _slotSwitch = type),
                                    onClear: () => setState(() => _slotSwitch = null),
                                  ),

                                  // Slot 3: Motor (Base do Diagrama)
                                  _buildDropSlot(
                                    left: cx - 40,
                                    top: bottomY - 30,
                                    width: 80,
                                    height: 60,
                                    currentType: _slotMotor,
                                    label: l10n.compMotor,
                                    onAccept: (type) => setState(() => _slotMotor = type),
                                    onClear: () => setState(() => _slotMotor = null),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                    ],
                  );

                  if (isWide) {
                    return Row(
                      children: [
                        if (_showDiagramMode)
                          _buildSymbolsPalette(isVertical: true, isDark: isDark, l10n: l10n),
                        Expanded(child: circuitBoardArea),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        Expanded(child: circuitBoardArea),
                        if (_showDiagramMode)
                          _buildSymbolsPalette(isVertical: false, isDark: isDark, l10n: l10n),
                      ],
                    );
                  }
                },
              ),
            ), // Expanded
          ],
        ), // Column
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
          ),
        ),
      ], // Stack children
    ), // Stack
  ), // SafeArea
),
); // Scaffold
}

  Widget _buildSymbolsPalette({
    required bool isVertical,
    required bool isDark,
    required AppLocalizations l10n,
  }) {
    const symbolTypes = [
      ComponentType.battery,
      ComponentType.switchComponent,
      ComponentType.motor,
      ComponentType.bulb,
      ComponentType.resistor,
      ComponentType.diode,
      ComponentType.led,
    ];

    return SymbolsDockPanel(
      isVertical: isVertical,
      symbolTypes: symbolTypes,
      l10n: l10n,
      verticalScrollController: _paletteVerticalScrollController,
      horizontalScrollController: _paletteHorizontalScrollController,
      onTapSymbol: (type) {
        ref.read(audioServiceProvider).playClick();
        setState(() {
          _slotBattery ??= type;
          if (_slotBattery != type) {
            _slotSwitch ??= type;
            if (_slotSwitch != type) {
              _slotMotor ??= type;
            }
          }
        });
      },
    );
  }

  Widget _buildDropSlot({
    required double left,
    double? top,
    double? bottom,
    required double width,
    required double height,
    required ComponentType? currentType,
    required String label,
    required ValueChanged<ComponentType> onAccept,
    required VoidCallback onClear,
    bool isVertical = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      left: left,
      top: top,
      bottom: bottom,
      child: DragTarget<ComponentType>(
        onAcceptWithDetails: (details) {
          ref.read(audioServiceProvider).playDrop();
          onAccept(details.data);
        },
        builder: (context, candidateData, rejectedData) {
          final isHovered = candidateData.isNotEmpty;

          return GestureDetector(
            onTap: () {
              if (currentType == ComponentType.switchComponent) {
                ref.read(audioServiceProvider).playClick();
                setState(() {
                  _isSwitchClosed = !_isSwitchClosed;
                });
              }
            },
            onDoubleTap: onClear,
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: currentType != null
                    ? (isDark ? const Color(0xFF1E2A3A) : const Color(0xFFE0F7FA))
                    : (isHovered
                        ? const Color(0xFFFFF9C4)
                        : (isDark ? const Color(0xFF263238) : Colors.white)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isHovered
                      ? const Color(0xFFFFB300)
                      : (currentType != null ? const Color(0xFF00B8D4) : Colors.grey),
                  width: isHovered || currentType != null ? 2.5 : 1.5,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (currentType != null)
                    CustomPaint(
                      painter: CircuitSymbolPainter(
                        type: currentType,
                        color: isDark ? Colors.white : Colors.black87,
                        strokeWidth: 2.2,
                        isVertical: isVertical,
                      ),
                      child: const SizedBox.expand(),
                    )
                  else
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// CustomPainter que desenha o circuito físico (bateria, interruptor e motor) e o diagrama elétrico
class _Challenge2BoardPainter extends CustomPainter {
  _Challenge2BoardPainter({
    required this.isSwitchClosed,
    required this.showDiagramMode,
    required this.slotBattery,
    required this.slotSwitch,
    required this.slotMotor,
    required this.isDark,
    this.useRealisticAssets = true,
    this.currentProgress = 0.0,
    this.drawParticlesOnly = false,
  });

  final bool isSwitchClosed;
  final bool showDiagramMode;
  final ComponentType? slotBattery;
  final ComponentType? slotSwitch;
  final ComponentType? slotMotor;
  final bool isDark;
  final bool useRealisticAssets;
  final double currentProgress;
  final bool drawParticlesOnly;

  @override
  void paint(Canvas canvas, Size size) {
    if (showDiagramMode) {
      if (!drawParticlesOnly) {
        _drawDiagramBackgroundGrid(canvas, size);
        _drawDiagramWireOverlay(canvas, size);
      }
    } else {
      _drawPhysicalCircuitOverlay(canvas, size);
    }
  }

  void _drawDiagramBackgroundGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.07) : Colors.black.withValues(alpha: 0.04)
      ..strokeWidth = 1.0;

    const cols = 8;
    const rows = 6;
    final cellW = size.width / cols;
    final cellH = size.height / rows;

    for (int i = 1; i < cols; i++) {
      canvas.drawLine(Offset(i * cellW, 0), Offset(i * cellW, size.height), gridPaint);
    }
    for (int j = 1; j < rows; j++) {
      canvas.drawLine(Offset(0, j * cellH), Offset(size.width, j * cellH), gridPaint);
    }
  }

  void _drawPhysicalCircuitOverlay(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final batX = w * 0.18;
    final batY = h * 0.48;

    final swX = w * 0.72;
    final swY = h * 0.26;

    final motorX = w * 0.72;
    final motorY = h * 0.72;

    // Bornes
    final batPosTerm = Offset(batX + 22, batY - 26);
    final batNegTerm = Offset(batX - 16, batY - 22);

    final swRedTerm  = Offset(swX - 25, swY + 6);
    final swBlackTerm = Offset(swX + 25, swY + 6);

    final motorRedTerm  = Offset(motorX - 34, motorY + 4);
    final motorBlackTerm = Offset(motorX + 34, motorY + 4);

    // Fios
    final pathRed = Path();
    pathRed.moveTo(batPosTerm.dx, batPosTerm.dy);
    pathRed.cubicTo(
      batPosTerm.dx + 40, batPosTerm.dy - (h * 0.28),
      swRedTerm.dx - (w * 0.12), swRedTerm.dy - 40,
      swRedTerm.dx, swRedTerm.dy,
    );

    final pathWireInter = Path();
    pathWireInter.moveTo(swBlackTerm.dx, swBlackTerm.dy);
    pathWireInter.cubicTo(
      swBlackTerm.dx + (w * 0.10), swBlackTerm.dy + (h * 0.12),
      motorRedTerm.dx + (w * 0.08), motorRedTerm.dy - (h * 0.12),
      motorRedTerm.dx, motorRedTerm.dy,
    );

    final pathWireRet = Path();
    pathWireRet.moveTo(motorBlackTerm.dx, motorBlackTerm.dy);
    pathWireRet.cubicTo(
      motorBlackTerm.dx - (w * 0.10), motorBlackTerm.dy + (h * 0.18),
      batNegTerm.dx + (w * 0.05), batNegTerm.dy + (h * 0.32),
      batNegTerm.dx, batNegTerm.dy,
    );

    if (drawParticlesOnly) {
      if (isSwitchClosed) {
        _drawCurrentParticlesOnPath(canvas, pathRed, const Color(0xFFFFEA00), 5);
        _drawCurrentParticlesOnPath(canvas, pathWireInter, const Color(0xFFFFEA00), 4);
        _drawCurrentParticlesOnPath(canvas, pathWireRet, const Color(0xFFFFEA00), 6);
      }
      return;
    }

    // --- DESENHO DOS FIOS (Efeito Cilíndrico 3D com Brilho Especular e Sombra Projetada) ---
    final shadowTransform = Matrix4.translationValues(3, 6, 0);

    final wireFloorShadowPaint = Paint()
      ..color = isDark ? Colors.black45 : Colors.black.withValues(alpha: 0.18)
      ..strokeWidth = 6.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawPath(pathRed.transform(shadowTransform.storage), wireFloorShadowPaint);
    canvas.drawPath(pathWireInter.transform(shadowTransform.storage), wireFloorShadowPaint);
    canvas.drawPath(pathWireRet.transform(shadowTransform.storage), wireFloorShadowPaint);

    final wireBaseRed = Paint()
      ..color = const Color(0xFFB71C1C)
      ..strokeWidth = 5.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final wireBaseInter = Paint()
      ..color = isDark ? const Color(0xFF1565C0) : const Color(0xFF0D47A1)
      ..strokeWidth = 5.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final wireBaseBlack = Paint()
      ..color = isDark ? const Color(0xFF424242) : const Color(0xFF111111)
      ..strokeWidth = 5.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(pathRed, wireBaseRed);
    canvas.drawPath(pathWireInter, wireBaseInter);
    canvas.drawPath(pathWireRet, wireBaseBlack);

    final wireRedPaint = Paint()
      ..color = const Color(0xFFEF5350)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final wireInterPaint = Paint()
      ..color = isDark ? const Color(0xFF42A5F5) : const Color(0xFF1E88E5)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final wireBlackPaint = Paint()
      ..color = isDark ? const Color(0xFF9E9E9E) : const Color(0xFF37474F)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(pathRed, wireRedPaint);
    canvas.drawPath(pathWireInter, wireInterPaint);
    canvas.drawPath(pathWireRet, wireBlackPaint);

    final wireHighlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final highlightTransform = Matrix4.translationValues(-0.8, -0.8, 0);
    canvas.drawPath(pathRed.transform(highlightTransform.storage), wireHighlightPaint);
    canvas.drawPath(pathWireInter.transform(highlightTransform.storage), wireHighlightPaint);
    canvas.drawPath(pathWireRet.transform(highlightTransform.storage), wireHighlightPaint);

    final plugPaint = Paint()..color = const Color(0xFF424242);
    canvas.drawCircle(batPosTerm, 5, plugPaint);
    canvas.drawCircle(batNegTerm, 5, plugPaint);
    canvas.drawCircle(swRedTerm, 4, plugPaint);
    canvas.drawCircle(swBlackTerm, 4, plugPaint);
    canvas.drawCircle(motorRedTerm, 4, plugPaint);
    canvas.drawCircle(motorBlackTerm, 4, plugPaint);

    if (useRealisticAssets) return;

    final batPainter = ComponentPhysicalPainter(
      type: ComponentType.battery,
      isActive: false,
      isDarkMode: isDark,
    );
    final swPainter = ComponentPhysicalPainter(
      type: ComponentType.switchComponent,
      isActive: isSwitchClosed,
      isDarkMode: isDark,
    );
    final motorPainter = ComponentPhysicalPainter(
      type: ComponentType.motor,
      isActive: isSwitchClosed,
      isDarkMode: isDark,
    );

    canvas.save();
    canvas.translate(batX - 60, batY - 50);
    batPainter.paint(canvas, const Size(120, 100));
    canvas.restore();

    canvas.save();
    canvas.translate(swX - 70, swY - 45);
    swPainter.paint(canvas, const Size(140, 90));
    canvas.restore();

    canvas.save();
    canvas.translate(motorX - 70, motorY - 45);
    motorPainter.paint(canvas, const Size(140, 90));
    canvas.restore();
  }

  void _drawCurrentParticlesOnPath(Canvas canvas, Path path, Color color, int count) {
    final metrics = path.computeMetrics().firstOrNull;
    if (metrics == null) return;

    final length = metrics.length;
    final particlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    for (int i = 0; i < count; i++) {
      final t = (currentProgress + (i / count)) % 1.0;
      final tangent = metrics.getTangentForOffset(length * t);
      if (tangent != null) {
        canvas.drawCircle(tangent.position, 5.0, glowPaint);
        canvas.drawCircle(tangent.position, 3.0, particlePaint);
      }
    }
  }

  void _drawDiagramWireOverlay(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    final wirePaint = Paint()
      ..color = isDark ? const Color(0xFF00E5FF) : const Color(0xFF1E293B)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    // Adapta dinamicamente a largura e a altura do retângulo do diagrama Ã  tela
    final dx = (w * 0.26).clamp(80.0, 150.0);
    final dy = (h * 0.22).clamp(55.0, 100.0);

    final leftX = cx - dx;
    final rightX = cx + dx;
    final topY = cy - dy;
    final bottomY = cy + dy;

    final path = Path();
    path.moveTo(leftX, topY);
    path.lineTo(cx - 40, topY);
    path.moveTo(cx + 40, topY);
    path.lineTo(rightX, topY);
    path.lineTo(rightX, bottomY);
    path.lineTo(cx + 40, bottomY);
    path.moveTo(cx - 40, bottomY);
    path.lineTo(leftX, bottomY);
    path.lineTo(leftX, cy + 30);
    path.moveTo(leftX, cy - 30);
    path.lineTo(leftX, topY);

    canvas.drawPath(path, wirePaint);
  }

  @override
  bool shouldRepaint(covariant _Challenge2BoardPainter oldDelegate) {
    return oldDelegate.isSwitchClosed != isSwitchClosed ||
        oldDelegate.showDiagramMode != showDiagramMode ||
        oldDelegate.slotBattery != slotBattery ||
        oldDelegate.slotSwitch != slotSwitch ||
        oldDelegate.slotMotor != slotMotor ||
        oldDelegate.isDark != isDark ||
        oldDelegate.currentProgress != currentProgress ||
        oldDelegate.drawParticlesOnly != drawParticlesOnly;
  }
}
