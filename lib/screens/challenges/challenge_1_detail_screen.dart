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

/// Tela interativa da execução do Desafio 1.
///
/// Apresenta os dois passos baseados nas imagens de referência:
/// Passos:
/// 1. Verificar se há conexões soltas fechando/ligando o interruptor.
/// 2. Clicar no botão amarelo ("circuit diagram") para montar o diagrama esquemático.
/// No modo diagrama esquemático: Arrastar/selecionar os símbolos da barra lateral esquerda e posicioná-los no lugar correto do diagrama do circuito.
class Challenge1DetailScreen extends ConsumerStatefulWidget {
  const Challenge1DetailScreen({super.key});

  @override
  ConsumerState<Challenge1DetailScreen> createState() => _Challenge1DetailScreenState();
}

class _Challenge1DetailScreenState extends ConsumerState<Challenge1DetailScreen>
    with TickerProviderStateMixin {
  // Estado do Passo 1: Interruptor e lâmpada
  bool _isSwitchClosed = false;
  bool _showDiagramMode = false;

  // Estado do Passo 2: Símbolos posicionados nos 3 slots (Bateria, Interruptor, Lâmpada)
  ComponentType? _slotBattery;
  ComponentType? _slotSwitch;
  ComponentType? _slotBulb;

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
      _slotBulb == ComponentType.bulb;

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
            await ref.read(progressControllerProvider.notifier).markAsCompleted('challenge_1', stars: stars);
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
      _slotBulb = null;
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
          l10n.challenge1DetailTitle,
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
                          text: '${l10n.challenge1Step1}\n${l10n.challenge1Step2}',
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
                          if (!_showDiagramMode)
                            Positioned.fill(
                              child: LayoutBuilder(
                                builder: (context, boardConstraints) {
                                  final w = boardConstraints.maxWidth;
                                  final h = boardConstraints.maxHeight;
                                  final batX = w * 0.18;
                                  final batY = h * 0.50;
                                  final batW = 180.0;
                                  final batH = 180.0;

                                  final swX = w * 0.65;
                                  final swY = h * 0.24;
                                  final swW = 170.0;
                                  final swH = 170.0;

                                  final bulbX = w * 0.65;
                                  final bulbY = h * 0.76;
                                  final bulbW = 170.0;
                                  final bulbH = 170.0;

                                  return Stack(
                                    children: [
                                      Positioned(
                                        left: batX - (batW / 2),
                                        top: batY - (batH / 2),
                                        width: batW,
                                        height: batH,
                                        child: Image.asset(ComponentType.battery.getChallengeAssetPath(false)!, fit: BoxFit.contain),
                                      ),
                                      Positioned(
                                        left: swX - (swW / 2),
                                        top: swY - (swH / 2),
                                        width: swW,
                                        height: swH,
                                        child: Image.asset(ComponentType.switchComponent.getChallengeAssetPath(_isSwitchClosed)!, fit: BoxFit.contain),
                                      ),
                                      Positioned(
                                        left: bulbX - (bulbW / 2),
                                        top: bulbY - (bulbH / 2),
                                        width: bulbW,
                                        height: bulbH,
                                        child: Image.asset(ComponentType.bulb.getChallengeAssetPath(_isSwitchClosed)!, fit: BoxFit.contain),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),

                          // Fundo Estático da Bancada & Fios Físicos (desenhados sobre os componentes)
                          Positioned.fill(
                            child: RepaintBoundary(
                              child: CustomPaint(
                                painter: _CircuitInteractiveBoardPainter(
                                  isSwitchClosed: _isSwitchClosed,
                                  showDiagramMode: _showDiagramMode,
                                  slotBattery: _slotBattery,
                                  slotSwitch: _slotSwitch,
                                  slotBulb: _slotBulb,
                                  isDark: isDark,
                                  useRealisticAssets: true,
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
                                      painter: _CircuitInteractiveBoardPainter(
                                        isSwitchClosed: _isSwitchClosed,
                                        showDiagramMode: _showDiagramMode,
                                        slotBattery: _slotBattery,
                                        slotSwitch: _slotSwitch,
                                        slotBulb: _slotBulb,
                                        isDark: isDark,
                                        useRealisticAssets: true,
                                        currentProgress: _currentAnimationController.value,
                                        drawParticlesOnly: true,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                          // Elementos Interativos posicionados na Bancada

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
                                        _isSwitchClosed ? 'Interruptor: FECHADO' : 'Interruptor: ABERTO',
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
                              left: constraints.maxWidth * 0.65 - 85,
                              top: constraints.maxHeight * 0.24 - 85,
                              width: 170,
                              height: 170,
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

                          // Slots de Drop no Modo Diagrama (Bateria, Interruptor, Lâmpada)
                          if (_showDiagramMode)
                            Positioned.fill(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final cx = constraints.maxWidth / 2;
                                  final cy = constraints.maxHeight / 2;

                                  // Adapta dinamicamente o tamanho do diagrama às dimensões da tela
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

                                      // Slot 3: Lâmpada (Base do Diagrama)
                                      _buildDropSlot(
                                        left: cx - 40,
                                        top: bottomY - 30,
                                        width: 80,
                                        height: 60,
                                        currentType: _slotBulb,
                                        label: l10n.compBulb,
                                        onAccept: (type) => setState(() => _slotBulb = type),
                                        onClear: () => setState(() => _slotBulb = null),
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
      ComponentType.bulb,
      ComponentType.resistor,
      ComponentType.motor,
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
              _slotBulb ??= type;
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

/// CustomPainter que desenha o fundo da bancada do circuito e os fios de ligação
class _CircuitInteractiveBoardPainter extends CustomPainter {
  _CircuitInteractiveBoardPainter({
    required this.isSwitchClosed,
    required this.showDiagramMode,
    required this.slotBattery,
    required this.slotSwitch,
    required this.slotBulb,
    required this.isDark,
    this.useRealisticAssets = true,
    this.currentProgress = 0.0,
    this.drawParticlesOnly = false,
  });

  final bool isSwitchClosed;
  final bool showDiagramMode;
  final ComponentType? slotBattery;
  final ComponentType? slotSwitch;
  final ComponentType? slotBulb;
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

    // Coordenadas calculadas dinamicamente com base nas dimensões da bancada
    final batX = w * 0.18;
    final batY = h * 0.50;
    final batW = 180.0;
    final batH = 180.0;
    final batLeft = batX - (batW / 2);
    final batTop = batY - (batH / 2);

    final swX = w * 0.65;
    final swY = h * 0.24;
    final swW = 170.0;
    final swH = 170.0;
    final swLeft = swX - (swW / 2);
    final swTop = swY - (swH / 2);

    final bulbX = w * 0.65;
    final bulbY = h * 0.76;
    final bulbW = 170.0;
    final bulbH = 170.0;
    final bulbLeft = bulbX - (bulbW / 2);
    final bulbTop = bulbY - (bulbH / 2);

    // Pontos de conexão exatos nos bornes (Entradas superiores dos bornes)
    final batPosTerm = Offset(batLeft + batW * 0.855, batTop + batH * 0.383);  // Polo (+) Bateria Horizontal
    final batNegTerm = Offset(batLeft + batW * 0.849, batTop + batH * 0.609);  // Polo (-) Bateria Horizontal

    final swRedTerm  = Offset(swLeft + swW * 0.138, swTop + swH * 0.310);     // Entrada Borne Vermelho Interruptor (Esquerda)
    final swBlackTerm = Offset(swLeft + swW * 0.876, swTop + swH * 0.310);    // Entrada Borne Preto Interruptor (Direita)

    final bulbRedTerm  = Offset(bulbLeft + bulbW * 0.120, bulbTop + bulbH * 0.400);  // Entrada Borne Vermelho Lâmpada (Esquerda)
    final bulbBlackTerm = Offset(bulbLeft + bulbW * 0.881, bulbTop + bulbH * 0.400); // Entrada Borne Preto Lâmpada (Direita)

    // --- DESENHO DOS FIOS (Saída Vertical da Bateria + Trajeto Horizontal Quadrado) ---

    // 1. Fio Vermelho (Polo (+) da Bateria -> Borne Vermelho do Interruptor)
    // Sobe na vertical a partir do polo positivo e dobra 90° à direita em direção ao interruptor
    final pathRed = Path();
    pathRed.moveTo(batPosTerm.dx, batPosTerm.dy);
    pathRed.cubicTo(
      batPosTerm.dx, swRedTerm.dy + 35,
      batPosTerm.dx + (w * 0.08), swRedTerm.dy,
      swRedTerm.dx, swRedTerm.dy,
    );

    // 2. Fio Preto de Interconexão (Borne Preto Interruptor -> Borne Preto Lâmpada)
    // Sai do borne do interruptor contornando por fora à direita até a lâmpada
    final pathWireInter = Path();
    pathWireInter.moveTo(swBlackTerm.dx, swBlackTerm.dy);
    pathWireInter.cubicTo(
      swBlackTerm.dx + (w * 0.16), swBlackTerm.dy - (h * 0.10),
      bulbBlackTerm.dx + (w * 0.16), bulbBlackTerm.dy + (h * 0.10),
      bulbBlackTerm.dx, bulbBlackTerm.dy,
    );

    // 3. Fio Preto de Retorno (Borne Vermelho da Lâmpada -> Polo (-) da Bateria)
    // Corre na horizontal da lâmpada à esquerda e dobra 90° para cima entrando no polo negativo da bateria
    final pathWireRet = Path();
    pathWireRet.moveTo(bulbRedTerm.dx, bulbRedTerm.dy);
    pathWireRet.cubicTo(
      batNegTerm.dx + (w * 0.08), bulbRedTerm.dy,
      batNegTerm.dx, bulbRedTerm.dy - 35,
      batNegTerm.dx, batNegTerm.dy,
    );

    if (drawParticlesOnly) {
      // ⚡ DESENHA APENAS AS PARTÍCULAS EM 60FPS
      if (isSwitchClosed) {
        _drawCurrentParticlesOnPath(canvas, pathRed, const Color(0xFFFFEA00), 5);
        _drawCurrentParticlesOnPath(canvas, pathWireInter, const Color(0xFFFFEA00), 4);
        _drawCurrentParticlesOnPath(canvas, pathWireRet, const Color(0xFFFFEA00), 6);
      }
      return;
    }

    // --- DESENHO DOS FIOS (Efeito Cilíndrico 3D com Brilho Especular e Sombra Projetada) ---
    final shadowTransform = Matrix4.translationValues(3, 6, 0);

    // 1. Sombra suave realista no piso da bancada
    final wireFloorShadowPaint = Paint()
      ..color = isDark ? Colors.black45 : Colors.black.withValues(alpha: 0.18)
      ..strokeWidth = 6.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawPath(pathRed.transform(shadowTransform.storage), wireFloorShadowPaint);
    canvas.drawPath(pathWireInter.transform(shadowTransform.storage), wireFloorShadowPaint);
    canvas.drawPath(pathWireRet.transform(shadowTransform.storage), wireFloorShadowPaint);

    // 2. Base escura do cabo (Sombra de volume inferior)
    final wireBaseRed = Paint()
      ..color = const Color(0xFFB71C1C)
      ..strokeWidth = 5.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final wireBaseInter = Paint()
      ..color = isDark ? const Color(0xFF424242) : const Color(0xFF111111)
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

    // 3. Camada de cor principal do cabo
    final wireRedPaint = Paint()
      ..color = const Color(0xFFEF5350)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final wireInterPaint = Paint()
      ..color = isDark ? const Color(0xFF9E9E9E) : const Color(0xFF37474F)
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

    // 4. Linha de Brilho Especular (Highlight 3D cilíndrico superior)
    final wireHighlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final highlightTransform = Matrix4.translationValues(-0.8, -0.8, 0);
    canvas.drawPath(pathRed.transform(highlightTransform.storage), wireHighlightPaint);
    canvas.drawPath(pathWireInter.transform(highlightTransform.storage), wireHighlightPaint);
    canvas.drawPath(pathWireRet.transform(highlightTransform.storage), wireHighlightPaint);

    // Conectores redondos (Plugues 3D) colocados diretamente sobre as entradas dos bornes
    _drawWireTerminalPlug(canvas, batPosTerm, const Color(0xFFEF5350));
    _drawWireTerminalPlug(canvas, batNegTerm, isDark ? const Color(0xFF9E9E9E) : const Color(0xFF37474F));
    _drawWireTerminalPlug(canvas, swRedTerm, const Color(0xFFEF5350));
    _drawWireTerminalPlug(canvas, swBlackTerm, isDark ? const Color(0xFF9E9E9E) : const Color(0xFF37474F));
    _drawWireTerminalPlug(canvas, bulbRedTerm, isDark ? const Color(0xFF9E9E9E) : const Color(0xFF37474F));
    _drawWireTerminalPlug(canvas, bulbBlackTerm, isDark ? const Color(0xFF9E9E9E) : const Color(0xFF37474F));

    if (useRealisticAssets) return;

    // --- RENDEREZAÇÃO DOS COMPONENTES FÍSICOS (CARTOON) ---
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
    final bulbPainter = ComponentPhysicalPainter(
      type: ComponentType.bulb,
      isActive: isSwitchClosed,
      isDarkMode: isDark,
    );

    // Bateria (Lado Esquerdo Central)
    canvas.save();
    canvas.translate(batX - 60, batY - 50);
    batPainter.paint(canvas, const Size(120, 100));
    canvas.restore();

    // Interruptor (Lado Direito Superior)
    canvas.save();
    canvas.translate(swX - 70, swY - 45);
    swPainter.paint(canvas, const Size(140, 90));
    canvas.restore();

    // Lâmpada (Lado Direito Inferior)
    canvas.save();
    canvas.translate(bulbX - 70, bulbY - 45);
    bulbPainter.paint(canvas, const Size(140, 90));
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

  void _drawWireTerminalPlug(Canvas canvas, Offset pos, Color color) {
    // Sombra do conector/plugue
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
    canvas.drawCircle(pos + const Offset(1, 2), 6.5, shadowPaint);

    // Anel metálico (borda prata do borne)
    final metalPaint = Paint()
      ..color = const Color(0xFFECEFF1)
      ..style = PaintingStyle.fill;
    final metalBorderPaint = Paint()
      ..color = const Color(0xFF455A64)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(pos, 7.0, metalPaint);
    canvas.drawCircle(pos, 7.0, metalBorderPaint);

    // Plugue redondo colorido (vermelho ou preto)
    final plugPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final plugBorderPaint = Paint()
      ..color = Colors.black45
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(pos, 5.2, plugPaint);
    canvas.drawCircle(pos, 5.2, plugBorderPaint);

    // Brilho especular (Highlight 3D)
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos + const Offset(-1.5, -1.5), 1.8, highlightPaint);
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

    // Topo (Interruptor): Vão entre cx - 40 e cx + 40 (80px exatos do slot)
    path.moveTo(leftX, topY);
    path.lineTo(cx - 40, topY);
    path.moveTo(cx + 40, topY);
    path.lineTo(rightX, topY);

    // Lado Direito
    path.lineTo(rightX, bottomY);

    // Base (Lâmpada): Vão entre cx + 40 e cx - 40
    path.lineTo(cx + 40, bottomY);
    path.moveTo(cx - 40, bottomY);
    path.lineTo(leftX, bottomY);

    // Lado Esquerdo (Bateria): Vão vertical entre cy - 30 e cy + 30 (60px exatos do slot)
    path.lineTo(leftX, cy + 30);
    path.moveTo(leftX, cy - 30);
    path.lineTo(leftX, topY);

    canvas.drawPath(path, wirePaint);
  }

  @override
  bool shouldRepaint(covariant _CircuitInteractiveBoardPainter oldDelegate) {
    return oldDelegate.isSwitchClosed != isSwitchClosed ||
        oldDelegate.showDiagramMode != showDiagramMode ||
        oldDelegate.slotBattery != slotBattery ||
        oldDelegate.slotSwitch != slotSwitch ||
        oldDelegate.slotBulb != slotBulb ||
        oldDelegate.isDark != isDark ||
        oldDelegate.currentProgress != currentProgress ||
        oldDelegate.drawParticlesOnly != drawParticlesOnly;
  }
}
