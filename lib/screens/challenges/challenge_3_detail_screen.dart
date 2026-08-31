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

/// Tela interativa da execução do Desafio 3.
///
/// Circuito com 4 componentes em série:
/// 1. Bateria (esquerda, invertida + na base)
/// 2. Chave alavanca / Interruptor (topo)
/// 3. Resistor (direita)
/// 4. Lâmpada (base)
class Challenge3DetailScreen extends ConsumerStatefulWidget {
  const Challenge3DetailScreen({super.key});

  @override
  ConsumerState<Challenge3DetailScreen> createState() => _Challenge3DetailScreenState();
}

class _Challenge3DetailScreenState extends ConsumerState<Challenge3DetailScreen>
    with TickerProviderStateMixin {
  // Estado do Passo 1: Interruptor alavanca
  bool _isSwitchClosed = false;
  bool _showDiagramMode = false;

  // Estado do Passo 2: Símbolos posicionados nos 4 slots (Bateria, Interruptor, Resistor, Lâmpada)
  ComponentType? _slotBattery;
  ComponentType? _slotSwitch;
  ComponentType? _slotResistor;
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
      _slotResistor == ComponentType.resistor &&
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
            await ref.read(progressControllerProvider.notifier).markAsCompleted('challenge_3', stars: stars);
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
      _slotResistor = null;
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
          l10n.challenge3DetailTitle,
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
                      // Componentes Físicos Realistas (PNGs) na Bancada (no fundo)
                      Positioned.fill(
                        child: Opacity(
                          opacity: _showDiagramMode ? 0.35 : 1.0,
                          child: LayoutBuilder(
                            builder: (context, boardConstraints) {
                              final w = boardConstraints.maxWidth;
                              final h = boardConstraints.maxHeight;
                              final batX = w * 0.16;
                              final batY = h * 0.48;
                              final batW = 180.0;
                              final batH = 180.0;

                              final bulbX = w * 0.50;
                              final bulbY = h * 0.24;
                              final bulbW = 160.0;
                              final bulbH = 160.0;

                              final resX = w * 0.82;
                              final resY = h * 0.48;
                              final resW = 160.0;
                              final resH = 160.0;

                              final swX = w * 0.50;
                              final swY = h * 0.74;
                              final swW = 160.0;
                              final swH = 160.0;

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
                                    left: bulbX - (bulbW / 2),
                                    top: bulbY - (bulbH / 2),
                                    width: bulbW,
                                    height: bulbH,
                                    child: Image.asset(ComponentType.bulb.getChallengeAssetPath(_isSwitchClosed)!, fit: BoxFit.contain),
                                  ),
                                  Positioned(
                                    left: resX - (resW / 2),
                                    top: resY - (resH / 2),
                                    width: resW,
                                    height: resH,
                                    child: Image.asset(ComponentType.resistor.getChallengeAssetPath(false)!, fit: BoxFit.contain),
                                  ),
                                  Positioned(
                                    left: swX - (swW / 2),
                                    top: swY - (swH / 2),
                                    width: swW,
                                    height: swH,
                                    child: Image.asset(ComponentType.switchComponent.getChallengeAssetPath(_isSwitchClosed)!, fit: BoxFit.contain),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),

                      // Fundo Estático da Bancada & Fios Físicos (desenhados sobre os componentes)
                      Positioned.fill(
                        child: RepaintBoundary(
                          child: CustomPaint(
                            painter: _Challenge3BoardPainter(
                              isSwitchClosed: _isSwitchClosed,
                              showDiagramMode: _showDiagramMode,
                              slotBattery: _slotBattery,
                              slotSwitch: _slotSwitch,
                              slotResistor: _slotResistor,
                              slotBulb: _slotBulb,
                              isDark: isDark,
                              useRealisticAssets: true,
                              drawParticlesOnly: false,
                            ),
                          ),
                        ),
                      ),

                      // Camada de Partículas Elétricas Dinâmicas (60fps)
                      if (_isSwitchClosed && !_showDiagramMode)
                        Positioned.fill(
                          child: RepaintBoundary(
                            child: AnimatedBuilder(
                              animation: _currentAnimationController,
                              builder: (context, _) {
                                return CustomPaint(
                                  painter: _Challenge3BoardPainter(
                                    isSwitchClosed: _isSwitchClosed,
                                    showDiagramMode: _showDiagramMode,
                                    slotBattery: _slotBattery,
                                    slotSwitch: _slotSwitch,
                                    slotResistor: _slotResistor,
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

<<<<<<< HEAD
=======
                      // Componentes Físicos Realistas (PNGs) na Bancada
                      if (_useRealisticAssets)
                        Positioned.fill(
                          child: Opacity(
                            opacity: _showDiagramMode ? 0.25 : 1.0,
                            child: LayoutBuilder(
                              builder: (context, boardConstraints) {
                                final w = boardConstraints.maxWidth;
                                final h = boardConstraints.maxHeight;

                                final cx = w / 2;
                                final cy = h / 2;
                                final dx = (w * 0.26).clamp(80.0, 150.0);
                                final dy = (h * 0.22).clamp(55.0, 100.0);
                                final leftX = cx - dx;
                                final rightX = cx + dx;
                                final topY = cy - dy;
                                final bottomY = cy + dy;

                                final batX = _showDiagramMode ? leftX : (w * 0.16);
                                final batY = _showDiagramMode ? cy : (h * 0.48);
                                final bulbX = _showDiagramMode ? cx : (w * 0.50);
                                final bulbY = _showDiagramMode ? topY : (h * 0.24);
                                final resX = _showDiagramMode ? rightX : (w * 0.82);
                                final resY = _showDiagramMode ? cy : (h * 0.48);
                                final swX = _showDiagramMode ? cx : (w * 0.50);
                                final swY = _showDiagramMode ? bottomY : (h * 0.74);

                                final scale = _showDiagramMode ? 0.65 : 1.0;
                                final batW = 120 * scale;
                                final batH = 100 * scale;
                                final bulbW = 130 * scale;
                                final bulbH = 85 * scale;
                                final resW = 100 * scale;
                                final resH = 70 * scale;
                                final swW = 130 * scale;
                                final swH = 80 * scale;

                                return Stack(
                                  children: [
                                    Positioned(
                                      left: batX - batW / 2,
                                      top: batY - batH / 2,
                                      width: batW,
                                      height: batH,
                                      child: Image.asset(ComponentType.battery.getAssetPath(false)!, fit: BoxFit.contain),
                                    ),
                                    Positioned(
                                      left: bulbX - bulbW / 2,
                                      top: bulbY - bulbH / 2,
                                      width: bulbW,
                                      height: bulbH,
                                      child: Image.asset(ComponentType.bulb.getAssetPath(_isSwitchClosed)!, fit: BoxFit.contain),
                                    ),
                                    Positioned(
                                      left: resX - resW / 2,
                                      top: resY - resH / 2,
                                      width: resW,
                                      height: resH,
                                      child: Image.asset(ComponentType.resistor.getAssetPath(false)!, fit: BoxFit.contain),
                                    ),
                                    Positioned(
                                      left: swX - swW / 2,
                                      top: swY - swH / 2,
                                      width: swW,
                                      height: swH,
                                      child: Image.asset(ComponentType.switchComponent.getAssetPath(_isSwitchClosed)!, fit: BoxFit.contain),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),

>>>>>>> 5535695 (diagrama)
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
                          left: constraints.maxWidth * 0.72 - 65,
                          top: constraints.maxHeight * 0.74 - 40,
                          width: 130,
                          height: 80,
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

                      // Slots de Drop no Modo Diagrama (Bateria, Interruptor, Resistor, Lâmpada)
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
                              final rightX = cx + dx;
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

                                  // Slot 2: Lâmpada (Topo do Diagrama)
                                  _buildDropSlot(
                                    left: cx - 40,
                                    top: topY - 30,
                                    width: 80,
                                    height: 60,
                                    currentType: _slotBulb,
                                    label: l10n.compBulb,
                                    onAccept: (type) => setState(() => _slotBulb = type),
                                    onClear: () => setState(() => _slotBulb = null),
                                  ),

                                  // Slot 3: Resistor (Lado Direito)
                                  _buildDropSlot(
                                    left: rightX - 40,
                                    top: cy - 30,
                                    width: 80,
                                    height: 60,
                                    currentType: _slotResistor,
                                    label: l10n.compResistor,
                                    onAccept: (type) => setState(() => _slotResistor = type),
                                    onClear: () => setState(() => _slotResistor = null),
                                    isVertical: true,
                                  ),

                                  // Slot 4: Interruptor / Chave Alavanca (Base do Diagrama)
                                  _buildDropSlot(
                                    left: cx - 40,
                                    top: bottomY - 30,
                                    width: 80,
                                    height: 60,
                                    currentType: _slotSwitch,
                                    label: l10n.compSwitch,
                                    onAccept: (type) => setState(() => _slotSwitch = type),
                                    onClear: () => setState(() => _slotSwitch = null),
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
      ComponentType.resistor,
      ComponentType.bulb,
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
              _slotResistor ??= type;
              if (_slotResistor != type) {
                _slotBulb ??= type;
              }
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
                    ? (isDark ? const Color(0xFF1E2A3A).withValues(alpha: 0.15) : const Color(0xFFE0F7FA).withValues(alpha: 0.15))
                    : (isHovered
                        ? const Color(0xFFFFF9C4).withValues(alpha: 0.4)
                        : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05))),
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

/// CustomPainter que desenha os 4 componentes físicos (bateria invertida, chave alavanca, resistor e lâmpada) e o diagrama retangular completo
class _Challenge3BoardPainter extends CustomPainter {
  _Challenge3BoardPainter({
    required this.isSwitchClosed,
    required this.showDiagramMode,
    required this.slotBattery,
    required this.slotSwitch,
    required this.slotResistor,
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
  final ComponentType? slotResistor;
  final ComponentType? slotBulb;
  final bool isDark;
  final bool useRealisticAssets;
  final double currentProgress;
  final bool drawParticlesOnly;

  @override
  void paint(Canvas canvas, Size size) {
    if (showDiagramMode) {
      if (!drawParticlesOnly) {
<<<<<<< HEAD
        // Desenha o circuito físico como fantasma no fundo (35% opacidade)
        canvas.saveLayer(Offset.zero & size, Paint()..color = Colors.white.withValues(alpha: 0.35));
=======
        // Draw the physical circuit overlay transparently
        canvas.saveLayer(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Paint()..color = Colors.white.withValues(alpha: 0.25),
        );
>>>>>>> 5535695 (diagrama)
        _drawPhysicalCircuitOverlay(canvas, size);
        canvas.restore();

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

<<<<<<< HEAD
    final batX = w * 0.16;
    final batY = h * 0.48;
    final batW = 180.0;
    final batH = 180.0;
    final batLeft = batX - (batW / 2);
    final batTop = batY - (batH / 2);

    final bulbX = w * 0.50;
    final bulbY = h * 0.24;
    final bulbW = 160.0;
    final bulbH = 160.0;
    final bulbLeft = bulbX - (bulbW / 2);
    final bulbTop = bulbY - (bulbH / 2);

    final resX = w * 0.82;
    final resY = h * 0.48;
    final resW = 160.0;
    final resH = 160.0;
    final resLeft = resX - (resW / 2);
    final resTop = resY - (resH / 2);

    final swX = w * 0.50;
    final swY = h * 0.74;
    final swW = 160.0;
    final swH = 160.0;
    final swLeft = swX - (swW / 2);
    final swTop = swY - (swH / 2);

    // Bornes
    final batPosTerm = Offset(batLeft + batW * 0.855, batTop + batH * 0.383);
    final batNegTerm = Offset(batLeft + batW * 0.849, batTop + batH * 0.609);

    final bulbRedTerm  = Offset(bulbLeft + bulbW * 0.120, bulbTop + bulbH * 0.400);
    final bulbBlackTerm = Offset(bulbLeft + bulbW * 0.881, bulbTop + bulbH * 0.400);

    final resLeftTerm  = Offset(resLeft + resW * 0.124, resTop + resH * 0.384);
    final resRightTerm = Offset(resLeft + resW * 0.880, resTop + resH * 0.383);

    final swRedTerm  = Offset(swLeft + swW * 0.138, swTop + swH * 0.310);
    final swBlackTerm = Offset(swLeft + swW * 0.876, swTop + swH * 0.310);
=======
    // Coordenadas calculadas dinamicamente com base nas dimensões da bancada e modo
    final cx = w / 2;
    final cy = h / 2;
    final dx = (w * 0.26).clamp(80.0, 150.0);
    final dy = (h * 0.22).clamp(55.0, 100.0);
    final leftX = cx - dx;
    final rightX = cx + dx;
    final topY = cy - dy;
    final bottomY = cy + dy;

    final batX = showDiagramMode ? leftX : (w * 0.16);
    final batY = showDiagramMode ? cy : (h * 0.48);

    final bulbX = showDiagramMode ? cx : (w * 0.50);
    final bulbY = showDiagramMode ? topY : (h * 0.24);

    final resX = showDiagramMode ? rightX : (w * 0.82);
    final resY = showDiagramMode ? cy : (h * 0.48);

    final swX = showDiagramMode ? cx : (w * 0.50);
    final swY = showDiagramMode ? bottomY : (h * 0.74);

    final scale = showDiagramMode ? 0.65 : 1.0;

    // Bornes
    final batPosTerm = Offset(batX + 22 * scale, batY - 26 * scale);
    final batNegTerm = Offset(batX - 16 * scale, batY - 22 * scale);

    final bulbRedTerm  = Offset(bulbX - 30 * scale, bulbY + 4 * scale);
    final bulbBlackTerm = Offset(bulbX + 30 * scale, bulbY + 4 * scale);

    final resLeftTerm  = Offset(resX - 32 * scale, resY + 4 * scale);
    final resRightTerm = Offset(resX + 32 * scale, resY + 4 * scale);

    final swRedTerm  = Offset(swX - 25 * scale, swY + 6 * scale);
    final swBlackTerm = Offset(swX + 25 * scale, swY + 6 * scale);
>>>>>>> 5535695 (diagrama)

    // Fios
    final pathRed = Path();
    pathRed.moveTo(batPosTerm.dx, batPosTerm.dy);
<<<<<<< HEAD
    pathRed.cubicTo(
      batPosTerm.dx, bulbRedTerm.dy + 35,
      batPosTerm.dx + (w * 0.08), bulbRedTerm.dy,
      bulbRedTerm.dx, bulbRedTerm.dy,
    );

    final pathBlack1 = Path();
    pathBlack1.moveTo(bulbBlackTerm.dx, bulbBlackTerm.dy);
    pathBlack1.cubicTo(
      bulbBlackTerm.dx + (w * 0.12), bulbBlackTerm.dy - (h * 0.12),
      resLeftTerm.dx - (w * 0.08), resLeftTerm.dy - (h * 0.12),
      resLeftTerm.dx, resLeftTerm.dy,
    );

    final pathBlack2 = Path();
    pathBlack2.moveTo(resRightTerm.dx, resRightTerm.dy);
    pathBlack2.cubicTo(
      resRightTerm.dx + (w * 0.14), resRightTerm.dy + (h * 0.10),
      swBlackTerm.dx + (w * 0.14), swBlackTerm.dy + (h * 0.12),
      swBlackTerm.dx, swBlackTerm.dy,
    );

    final pathBlack3 = Path();
    pathBlack3.moveTo(swRedTerm.dx, swRedTerm.dy);
    pathBlack3.cubicTo(
      batNegTerm.dx + (w * 0.08), swRedTerm.dy,
      batNegTerm.dx, swRedTerm.dy - 35,
      batNegTerm.dx, batNegTerm.dy,
    );
=======
    if (showDiagramMode) {
      pathRed.cubicTo(
        batPosTerm.dx, batPosTerm.dy - (h * 0.15),
        bulbRedTerm.dx - (w * 0.05), bulbRedTerm.dy - 20,
        bulbRedTerm.dx, bulbRedTerm.dy,
      );
    } else {
      pathRed.cubicTo(
        batPosTerm.dx + 30, batPosTerm.dy - (h * 0.22),
        bulbRedTerm.dx - (w * 0.08), bulbRedTerm.dy - (h * 0.06),
        bulbRedTerm.dx, bulbRedTerm.dy,
      );
    }

    final pathBlack1 = Path();
    pathBlack1.moveTo(bulbBlackTerm.dx, bulbBlackTerm.dy);
    if (showDiagramMode) {
      pathBlack1.cubicTo(
        bulbBlackTerm.dx + (w * 0.05), bulbBlackTerm.dy - 20,
        resLeftTerm.dx, resLeftTerm.dy - (h * 0.15),
        resLeftTerm.dx, resLeftTerm.dy,
      );
    } else {
      pathBlack1.cubicTo(
        bulbBlackTerm.dx + (w * 0.12), bulbBlackTerm.dy - (h * 0.06),
        resLeftTerm.dx - (w * 0.05), resLeftTerm.dy - (h * 0.18),
        resLeftTerm.dx, resLeftTerm.dy,
      );
    }

    final pathBlack2 = Path();
    pathBlack2.moveTo(resRightTerm.dx, resRightTerm.dy);
    if (showDiagramMode) {
      pathBlack2.cubicTo(
        resRightTerm.dx, resRightTerm.dy + (h * 0.15),
        swBlackTerm.dx + (w * 0.05), swBlackTerm.dy + 20,
        swBlackTerm.dx, swBlackTerm.dy,
      );
    } else {
      pathBlack2.cubicTo(
        resRightTerm.dx + (w * 0.08), resRightTerm.dy + (h * 0.18),
        swBlackTerm.dx + (w * 0.12), swBlackTerm.dy + (h * 0.06),
        swBlackTerm.dx, swBlackTerm.dy,
      );
    }

    final pathBlack3 = Path();
    pathBlack3.moveTo(swRedTerm.dx, swRedTerm.dy);
    if (showDiagramMode) {
      pathBlack3.cubicTo(
        swRedTerm.dx - (w * 0.05), swRedTerm.dy + 20,
        batNegTerm.dx, batNegTerm.dy + (h * 0.15),
        batNegTerm.dx, batNegTerm.dy,
      );
    } else {
      pathBlack3.cubicTo(
        swRedTerm.dx - (w * 0.12), swRedTerm.dy + (h * 0.06),
        batNegTerm.dx + (w * 0.08), batNegTerm.dy + (h * 0.22),
        batNegTerm.dx, batNegTerm.dy,
      );
    }
>>>>>>> 5535695 (diagrama)

    if (drawParticlesOnly) {
      if (isSwitchClosed) {
        _drawCurrentParticlesOnPath(canvas, pathRed, const Color(0xFFFFEA00), 4);
        _drawCurrentParticlesOnPath(canvas, pathBlack1, const Color(0xFFFFEA00), 4);
        _drawCurrentParticlesOnPath(canvas, pathBlack2, const Color(0xFFFFEA00), 4);
        _drawCurrentParticlesOnPath(canvas, pathBlack3, const Color(0xFFFFEA00), 5);
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
    canvas.drawPath(pathBlack1.transform(shadowTransform.storage), wireFloorShadowPaint);
    canvas.drawPath(pathBlack2.transform(shadowTransform.storage), wireFloorShadowPaint);
    canvas.drawPath(pathBlack3.transform(shadowTransform.storage), wireFloorShadowPaint);

    final wireBaseRed = Paint()
      ..color = const Color(0xFFB71C1C)
      ..strokeWidth = 5.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final wireBaseBlack = Paint()
      ..color = isDark ? const Color(0xFF424242) : const Color(0xFF111111)
      ..strokeWidth = 5.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(pathRed, wireBaseRed);
    canvas.drawPath(pathBlack1, wireBaseBlack);
    canvas.drawPath(pathBlack2, wireBaseBlack);
    canvas.drawPath(pathBlack3, wireBaseBlack);

    final wireRedPaint = Paint()
      ..color = const Color(0xFFEF5350)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final wireBlackPaint = Paint()
      ..color = isDark ? const Color(0xFF9E9E9E) : const Color(0xFF37474F)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(pathRed, wireRedPaint);
    canvas.drawPath(pathBlack1, wireBlackPaint);
    canvas.drawPath(pathBlack2, wireBlackPaint);
    canvas.drawPath(pathBlack3, wireBlackPaint);

    final wireHighlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final highlightTransform = Matrix4.translationValues(-0.8, -0.8, 0);
    canvas.drawPath(pathRed.transform(highlightTransform.storage), wireHighlightPaint);
    canvas.drawPath(pathBlack1.transform(highlightTransform.storage), wireHighlightPaint);
    canvas.drawPath(pathBlack2.transform(highlightTransform.storage), wireHighlightPaint);
    canvas.drawPath(pathBlack3.transform(highlightTransform.storage), wireHighlightPaint);

    // Conectores redondos (Plugues 3D) colocados diretamente sobre as entradas dos bornes
    _drawWireTerminalPlug(canvas, batPosTerm, const Color(0xFFEF5350));
    _drawWireTerminalPlug(canvas, batNegTerm, isDark ? const Color(0xFF9E9E9E) : const Color(0xFF37474F));
    _drawWireTerminalPlug(canvas, bulbRedTerm, const Color(0xFFEF5350));
    _drawWireTerminalPlug(canvas, bulbBlackTerm, isDark ? const Color(0xFF9E9E9E) : const Color(0xFF37474F));
    _drawWireTerminalPlug(canvas, resLeftTerm, isDark ? const Color(0xFF9E9E9E) : const Color(0xFF37474F));
    _drawWireTerminalPlug(canvas, resRightTerm, isDark ? const Color(0xFF9E9E9E) : const Color(0xFF37474F));
    _drawWireTerminalPlug(canvas, swRedTerm, isDark ? const Color(0xFF9E9E9E) : const Color(0xFF37474F));
    _drawWireTerminalPlug(canvas, swBlackTerm, isDark ? const Color(0xFF9E9E9E) : const Color(0xFF37474F));

    if (useRealisticAssets) return;

    final batPainter = ComponentPhysicalPainter(
      type: ComponentType.battery,
      isActive: false,
      isDarkMode: isDark,
    );
    final bulbPainter = ComponentPhysicalPainter(
      type: ComponentType.bulb,
      isActive: isSwitchClosed,
      isDarkMode: isDark,
    );
    final resPainter = ComponentPhysicalPainter(
      type: ComponentType.resistor,
      isActive: false,
      isDarkMode: isDark,
    );
    final swPainter = ComponentPhysicalPainter(
      type: ComponentType.switchComponent,
      isActive: isSwitchClosed,
      isDarkMode: isDark,
    );

    canvas.save();
    canvas.translate(batX - 60 * scale, batY - 50 * scale);
    batPainter.paint(canvas, Size(120 * scale, 100 * scale));
    canvas.restore();

    canvas.save();
    canvas.translate(bulbX - 65 * scale, bulbY - 42 * scale);
    bulbPainter.paint(canvas, Size(130 * scale, 85 * scale));
    canvas.restore();

    canvas.save();
    canvas.translate(resX - 50 * scale, resY - 35 * scale);
    resPainter.paint(canvas, Size(100 * scale, 70 * scale));
    canvas.restore();

    canvas.save();
    canvas.translate(swX - 65 * scale, swY - 40 * scale);
    swPainter.paint(canvas, Size(130 * scale, 80 * scale));
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
    path.moveTo(leftX, topY);
    path.lineTo(cx - 40, topY);
    path.moveTo(cx + 40, topY);
    path.lineTo(rightX, topY);
    path.lineTo(rightX, cy - 30);
    path.moveTo(rightX, cy + 30);
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
  bool shouldRepaint(covariant _Challenge3BoardPainter oldDelegate) {
    return oldDelegate.isSwitchClosed != isSwitchClosed ||
        oldDelegate.showDiagramMode != showDiagramMode ||
        oldDelegate.slotBattery != slotBattery ||
        oldDelegate.slotSwitch != slotSwitch ||
        oldDelegate.slotResistor != slotResistor ||
        oldDelegate.slotBulb != slotBulb ||
        oldDelegate.isDark != isDark ||
        oldDelegate.currentProgress != currentProgress ||
        oldDelegate.drawParticlesOnly != drawParticlesOnly;
  }
}
