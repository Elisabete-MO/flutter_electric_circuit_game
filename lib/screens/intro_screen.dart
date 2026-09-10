import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:google_fonts/google_fonts.dart';
import '../app/routes.dart';
import '../app/theme.dart';
import '../core/ui_scale.dart';
import '../state/progress_controller.dart';
import '../widgets/eletrolab_header_brand.dart';

/// Posição da cauda/pointer do Balão de Fala.
enum TailPosition { left, bottom }

/// Estrutura para cada etapa do diálogo de introdução.
class DialogueStep {
  final String title;
  final String speaker;
  final String text;
  final int defaultFrame;
  final List<int> talkFrames;
  final String buttonText;

  const DialogueStep({
    required this.title,
    required this.speaker,
    required this.text,
    required this.defaultFrame,
    required this.talkFrames,
    required this.buttonText,
  });
}

/// Tela de Introdução/Boas-Vindas com a Professora Nuri no lado esquerdo
class IntroScreen extends ConsumerStatefulWidget {
  const IntroScreen({super.key});

  @override
  ConsumerState<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends ConsumerState<IntroScreen>
    with TickerProviderStateMixin {
  int _currentStepIndex = 0;
  String _displayedText = '';
  bool _isTyping = false;
  Timer? _typingTimer;
  Timer? _spriteTimer;

  int _currentFrame = 0; // Pose inicial da spritesheet de 3 quadros (Frame 0)

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  static const List<DialogueStep> _steps = [
    DialogueStep(
      speaker: 'Professora Nuri',
      title: 'Boas-Vindas!',
      text:
          'Olá, jovem cientista! Seja muito bem-vindo(a) à Feira de Ciências da Comunidade!',
      defaultFrame: 0, // Pose 1
      talkFrames: [0],
      buttonText: 'Próximo',
    ),
    DialogueStep(
      speaker: 'Professora Nuri',
      title: 'O Ginásio do Bairro',
      text:
          'Todas as equipes da nossa comunidade se reuniram aqui no Ginásio para apresentar estandes interativos de circuitos elétricos, energia renovável e automação!',
      defaultFrame: 1, // Pose 2 (Muda ao avançar/passar de etapa)
      talkFrames: [1],
      buttonText: 'Continuar',
    ),
    DialogueStep(
      speaker: 'Professora Nuri',
      title: 'Sua Missão Especial',
      text:
          'Sua missão é explorar cada estande, superar os desafios de circuitos e energizar a grande Maquete Coletiva da nossa cidade. Vamos começar?',
      defaultFrame:
          2, // Pose 3 (Muda para a última atitude de convite ao Ginásio)
      talkFrames: [2],
      buttonText: 'Entrar no Ginásio',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _startStep(_currentStepIndex);
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _spriteTimer?.cancel();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startStep(int stepIndex) {
    _typingTimer?.cancel();
    _spriteTimer?.cancel();

    final step = _steps[stepIndex];
    setState(() {
      _currentStepIndex = stepIndex;
      _displayedText = '';
      _isTyping = true;
      _currentFrame = step
          .defaultFrame; // Altera a pose da Professora Nuri para o frame correspondente
    });

    // Digitação letra por letra
    int charIndex = 0;
    _typingTimer = Timer.periodic(const Duration(milliseconds: 28), (timer) {
      if (charIndex < step.text.length) {
        setState(() {
          charIndex++;
          _displayedText = step.text.substring(0, charIndex);
        });
      } else {
        _finishTyping();
      }
    });
  }

  void _finishTyping() {
    _typingTimer?.cancel();
    _spriteTimer?.cancel();
    final step = _steps[_currentStepIndex];
    setState(() {
      _displayedText = step.text;
      _isTyping = false;
      _currentFrame = step.defaultFrame;
    });
  }

  void _onNextPressed() {
    if (_isTyping) {
      _finishTyping();
      return;
    }

    if (_currentStepIndex < _steps.length - 1) {
      _startStep(_currentStepIndex + 1);
    } else {
      _enterGym();
    }
  }

  void _enterGym() {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      prefs.setBool('has_seen_intro', true);
    } catch (_) {
      // Ignora caso SharedPreferences não esteja configurado
    }
    Navigator.of(context).pushReplacementNamed(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = _steps[_currentStepIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF021712),
      body: Stack(
        children: [
          // 1. Imagem de Fundo (Porta Aberta do Ginásio sem camada escura)
          Positioned.fill(
            child: Image.asset(
              'assets/intro/gym_front_open_door.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFF04281E),
                  child: const Center(
                    child: Icon(
                      Icons.school_rounded,
                      color: Colors.white24,
                      size: 80,
                    ),
                  ),
                );
              },
            ),
          ),

          // 2. Conteúdo da Cena (Cabeçalho + Layout Responsivo Alinhado ao Chão)
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Cabeçalho da Tela (EletroLab + Pular)
                  _buildHeader(context),

                  // Área Principal da Cena (Nuri no chão)
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return _buildSceneLayout(
                          context,
                          currentStep,
                          constraints,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Barra de topo com o título do EletroLab e o botão Pular
  Widget _buildHeader(BuildContext context) {
    final scale = context.uiScale;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: scale.spacing(20, min: 14, max: 32),
        vertical: scale.spacing(12, min: 8, max: 20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const EletroLabHeaderBrand(),

          InkWell(
            onTap: _enterGym,
            borderRadius: BorderRadius.circular(
              scale.size(22, min: 16, max: 30),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: scale.spacing(16, min: 12, max: 24),
                vertical: scale.spacing(9, min: 7, max: 15),
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF04281E).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(
                  scale.size(22, min: 16, max: 30),
                ),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.45),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Pular',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      fontSize: scale.font(14.5, min: 12, max: 20),
                    ),
                  ),
                  SizedBox(width: scale.spacing(6, min: 3, max: 10)),
                  Icon(
                    Icons.fast_forward_rounded,
                    color: const Color(0xFF10B981),
                    size: scale.icon(18, min: 15, max: 24),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Layout Responsivo da Cena (Alinhado ao chão do ginásio)
  Widget _buildSceneLayout(
    BuildContext context,
    DialogueStep step,
    BoxConstraints constraints,
  ) {
    final double maxW = constraints.maxWidth;
    final double maxH = constraints.maxHeight;
    // Tablets use the stacked scene instead of shrinking the character and dialogue.
    final bool isWide = maxW >= 1100;
    final uiScale = UiScale.fromSize(maxW, maxH);

    if (isWide) {
      // LAYOUT COM NURI FIRMEMENTE NO CHÃO (Desktop/Tablet - Tamanho Destaque proporcional)
      final double maxSpriteH = uiScale.size(
        uiScale.isDesktop ? 680.0 : 470.0,
        min: 400.0,
        max: 960.0,
      );
      final double spriteHeight = (maxH * 0.78).clamp(310.0, maxSpriteH);
      final double spriteWidth = spriteHeight * (540.0 / 900.0);
      final double bubbleMaxWidth = uiScale.dialogWidth(
        uiScale.isDesktop ? 760 : 540,
        min: 500,
        max: 980,
      );

      return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(
            left: uiScale.spacing(24, min: 16, max: 40),
            right: uiScale.spacing(24, min: 16, max: 40),
            bottom: uiScale.spacing(20, min: 12, max: 32),
            top: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 1. PERSONAGEM PROFESSORA NURI (FIRMEMENTE NO CHÃO)
              SizedBox(
                width: spriteWidth + 16,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Positioned(
                      bottom: 4,
                      child: Container(
                        width: spriteWidth * 0.75,
                        height: uiScale.size(16, min: 12, max: 24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.60),
                              blurRadius: 14,
                              spreadRadius: 2,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildNuriSprite(spriteWidth, spriteHeight),
                  ],
                ),
              ),

              SizedBox(width: uiScale.spacing(24, min: 16, max: 40)),

              // 2. BALÃO DE FALA (Ao lado da Nuri, suspenso na altura do rosto/boca)
              Padding(
                padding: EdgeInsets.only(
                  bottom: (spriteHeight * 0.48).clamp(
                    180.0,
                    uiScale.isDesktop ? 420.0 : 260.0,
                  ),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: bubbleMaxWidth),
                  child: SpeechBubbleWidget(
                    step: step,
                    displayedText: _displayedText,
                    currentStepIndex: _currentStepIndex,
                    totalSteps: _steps.length,
                    isTyping: _isTyping,
                    pulseAnimation: _pulseAnimation,
                    tailPosition: TailPosition.left,
                    onTapCard: () {
                      if (_isTyping) _finishTyping();
                    },
                    onPressedNext: _onNextPressed,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // LAYOUT MOBILE (Nuri no chão, balão acima)
      final double spriteHeight = (maxH * 0.45).clamp(200.0, 320.0);
      final double spriteWidth = spriteHeight * (540.0 / 900.0);

      return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16,
            top: 8,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // 1. BALÃO DE FALA
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: SpeechBubbleWidget(
                  step: step,
                  displayedText: _displayedText,
                  currentStepIndex: _currentStepIndex,
                  totalSteps: _steps.length,
                  isTyping: _isTyping,
                  pulseAnimation: _pulseAnimation,
                  tailPosition: TailPosition.bottom,
                  onTapCard: () {
                    if (_isTyping) _finishTyping();
                  },
                  onPressedNext: _onNextPressed,
                ),
              ),

              const SizedBox(height: 10),

              // 2. PROFESSORA NURI (NO CHÃO)
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Positioned(
                    bottom: 4,
                    child: Container(
                      width: spriteWidth * 0.75,
                      height: 14,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.60),
                            blurRadius: 14,
                            spreadRadius: 2,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildNuriSprite(spriteWidth, spriteHeight),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  /// Renderizador da Spritesheet de 3 quadros da Professora Nuri (spritesheet_nuri.png)
  Widget _buildNuriSprite(double spriteWidth, double spriteHeight) {
    final int frameIndex = _currentFrame.clamp(0, 2);

    return SizedBox(
      width: spriteWidth,
      height: spriteHeight,
      child: ClipRect(
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              left: -frameIndex * spriteWidth,
              top: 0,
              width: spriteWidth * 3.0,
              height: spriteHeight,
              child: Image.asset(
                'assets/intro/spritesheet_nuri.png',
                width: spriteWidth * 3.0,
                height: spriteHeight,
                fit: BoxFit.fill,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: spriteWidth,
                    height: spriteHeight,
                    color: Colors.transparent,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_rounded,
                          size: 70,
                          color: Color(0xFF10B981),
                        ),
                        Text(
                          'Professora Nuri',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget do Balão de Fala (Speech Bubble) com cauda/pointer customizável (esquerda ou inferior)
class SpeechBubbleWidget extends StatelessWidget {
  final DialogueStep step;
  final String displayedText;
  final int currentStepIndex;
  final int totalSteps;
  final bool isTyping;
  final Animation<double> pulseAnimation;
  final TailPosition tailPosition;
  final VoidCallback onTapCard;
  final VoidCallback onPressedNext;

  const SpeechBubbleWidget({
    super.key,
    required this.step,
    required this.displayedText,
    required this.currentStepIndex,
    required this.totalSteps,
    required this.isTyping,
    required this.pulseAnimation,
    this.tailPosition = TailPosition.bottom,
    required this.onTapCard,
    required this.onPressedNext,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLastStep = currentStepIndex == totalSteps - 1;
    final bool isLeftTail = tailPosition == TailPosition.left;
    final scale = context.uiScale;

    return GestureDetector(
      onTap: onTapCard,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: isLeftTail ? Alignment.centerLeft : Alignment.bottomCenter,
        children: [
          // Conteúdo Principal do Balão de Fala
          Container(
            margin: EdgeInsets.only(
              left: isLeftTail ? 12 : 0,
              bottom: isLeftTail ? 0 : 12,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                scale.size(24, min: 18, max: 36),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  padding: EdgeInsets.all(scale.spacing(22, min: 16, max: 32)),
                  decoration: BoxDecoration(
                    color: const Color(
                      0x9903241B,
                    ), // Glassmorphism verde esmeralda meio transparente
                    borderRadius: BorderRadius.circular(
                      scale.size(24, min: 18, max: 36),
                    ),
                    border: Border.all(
                      color: const Color(0xFF10B981),
                      width: 1.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.45),
                        blurRadius: scale.size(22, min: 14, max: 32),
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.20),
                        blurRadius: scale.size(18, min: 12, max: 28),
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Orador e Progresso
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // Badge Orador
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: scale.spacing(
                                    12,
                                    min: 8,
                                    max: 18,
                                  ),
                                  vertical: scale.spacing(6, min: 4, max: 10),
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF059669),
                                  borderRadius: BorderRadius.circular(
                                    scale.size(12, min: 8, max: 18),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF10B981,
                                      ).withValues(alpha: 0.4),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.record_voice_over_rounded,
                                      color: Colors.white,
                                      size: scale.icon(16, min: 14, max: 22),
                                    ),
                                    SizedBox(
                                      width: scale.spacing(6, min: 4, max: 10),
                                    ),
                                    Text(
                                      step.speaker,
                                      style: GoogleFonts.rajdhani(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: scale.font(
                                          16,
                                          min: 13.5,
                                          max: 22,
                                        ),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: scale.spacing(8, min: 4, max: 14)),

                          // Indicadores (Passos 1/3, 2/3, 3/3)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(totalSteps, (index) {
                              final bool active = index == currentStepIndex;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: EdgeInsets.only(
                                  left: scale.spacing(5, min: 3, max: 9),
                                ),
                                width: active
                                    ? scale.size(22, min: 16, max: 32)
                                    : scale.size(10, min: 7, max: 16),
                                height: scale.size(10, min: 7, max: 16),
                                decoration: BoxDecoration(
                                  color: active
                                      ? EletroLabColors.neonCyan
                                      : const Color(0xFF065F46),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),

                      SizedBox(height: scale.spacing(14, min: 10, max: 20)),

                      // Texto com Efeito Typewriter
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: scale.size(64, min: 48, max: 96),
                        ),
                        child: Text(
                          displayedText,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: scale.font(17.5, min: 14.5, max: 24.0),
                            height: 1.48,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.25,
                          ),
                        ),
                      ),

                      SizedBox(height: scale.spacing(16, min: 12, max: 22)),

                      // Botão Ação (Próximo / Entrar)
                      Align(
                        alignment: Alignment.centerRight,
                        child: isLastStep
                            ? ScaleTransition(
                                scale: pulseAnimation,
                                child: ElevatedButton.icon(
                                  onPressed: onPressedNext,
                                  icon: Icon(
                                    Icons.bolt_rounded,
                                    size: scale.icon(24, min: 20, max: 34),
                                  ),
                                  label: Text(
                                    step.buttonText,
                                    style: GoogleFonts.rajdhani(
                                      fontWeight: FontWeight.bold,
                                      fontSize: scale.font(
                                        18,
                                        min: 15.0,
                                        max: 25.0,
                                      ),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF10B981),
                                    foregroundColor: const Color(0xFF021712),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: scale.spacing(
                                        26,
                                        min: 18,
                                        max: 38,
                                      ),
                                      vertical: scale.spacing(
                                        14,
                                        min: 10,
                                        max: 22,
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        scale.size(16, min: 12, max: 24),
                                      ),
                                    ),
                                    elevation: 8,
                                    shadowColor: const Color(
                                      0xFF10B981,
                                    ).withValues(alpha: 0.6),
                                  ),
                                ),
                              )
                            : ElevatedButton.icon(
                                onPressed: onPressedNext,
                                icon: Icon(
                                  isTyping
                                      ? Icons.fast_forward_rounded
                                      : Icons.arrow_forward_rounded,
                                  size: scale.icon(20, min: 16, max: 28),
                                ),
                                label: Text(
                                  isTyping ? 'Completo' : step.buttonText,
                                  style: GoogleFonts.rajdhani(
                                    fontWeight: FontWeight.bold,
                                    fontSize: scale.font(
                                      17,
                                      min: 14.0,
                                      max: 24.0,
                                    ),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF047857),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: scale.spacing(
                                      22,
                                      min: 16,
                                      max: 32,
                                    ),
                                    vertical: scale.spacing(
                                      12,
                                      min: 8,
                                      max: 18,
                                    ),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      scale.size(14, min: 10, max: 22),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Cauda / Pointer do Balão de Fala (Alinhado à altura dos ombros da Nuri quando na esquerda)
          Positioned(
            left: isLeftTail ? 0 : null,
            top: isLeftTail ? scale.size(36, min: 28, max: 54) : null,
            bottom: isLeftTail ? null : 0,
            child: CustomPaint(
              size: isLeftTail
                  ? Size(
                      scale.size(14, min: 10, max: 22),
                      scale.size(22, min: 16, max: 32),
                    )
                  : Size(
                      scale.size(22, min: 16, max: 32),
                      scale.size(14, min: 10, max: 22),
                    ),
              painter: _BubbleTailPainter(
                color: const Color(0x9903241B),
                borderColor: const Color(0xFF10B981),
                position: tailPosition,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Desenha o rabo/triângulo indicador do balão de fala (apontando para a esquerda ou para baixo)
class _BubbleTailPainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final TailPosition position;

  _BubbleTailPainter({
    required this.color,
    required this.borderColor,
    required this.position,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (position == TailPosition.left) {
      // Triângulo na esquerda apontando para a esquerda (<-)
      path.moveTo(size.width, 0);
      path.lineTo(0, size.height / 2);
      path.lineTo(size.width, size.height);
      path.close();
    } else {
      // Triângulo na parte inferior apontando para baixo (\/)
      path.moveTo(0, 0);
      path.lineTo(size.width / 2, size.height);
      path.lineTo(size.width, 0);
      path.close();
    }

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
