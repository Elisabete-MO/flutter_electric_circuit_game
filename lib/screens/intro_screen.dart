import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:google_fonts/google_fonts.dart';
import '../app/routes.dart';
import '../app/theme.dart';
import '../core/ui_scale.dart';
import '../state/progress_controller.dart';

/// Posição da cauda/pointer do Balão de Fala.
enum TailPosition { left, bottom, none }

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

  /// Barra de topo com o botão Pular
  Widget _buildHeader(BuildContext context) {
    final scale = context.uiScale;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: scale.spacing(20, min: 14, max: 32),
        vertical: scale.spacing(8, min: 4, max: 14),
      ),
      child: Align(
        alignment: Alignment.topRight,
        child: InkWell(
          onTap: _enterGym,
          borderRadius: BorderRadius.circular(
            scale.size(20, min: 16, max: 28),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: scale.spacing(16, min: 12, max: 22),
              vertical: scale.spacing(8, min: 6, max: 12),
            ),
            decoration: BoxDecoration(
              color: const Color(0xB3021D16),
              borderRadius: BorderRadius.circular(
                scale.size(20, min: 16, max: 28),
              ),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.50),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pular',
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: scale.font(14.5, min: 12, max: 18),
                    letterSpacing: 0.6,
                  ),
                ),
                SizedBox(width: scale.spacing(6, min: 4, max: 8)),
                Icon(
                  Icons.skip_next_rounded,
                  color: const Color(0xFF34D399),
                  size: scale.icon(18, min: 14, max: 22),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Layout Responsivo da Cena (Alinhado ao chão do ginásio e diálogo na altura dos olhos da Nuri)
  Widget _buildSceneLayout(
    BuildContext context,
    DialogueStep step,
    BoxConstraints constraints,
  ) {
    final double maxW = constraints.maxWidth;
    final double maxH = constraints.maxHeight;
    final bool isWide = (maxW >= 640 && maxW > maxH) || maxW >= 768;
    final uiScale = UiScale.fromSize(maxW, maxH);

    if (isWide) {
      // LAYOUT WIDESCREEN / DESKTOP / TABLET (Nuri no chão, Diálogo na altura da cabeça/olhos)
      final double maxSpriteH = uiScale.size(
        uiScale.isDesktop ? 640.0 : 460.0,
        min: 200.0,
        max: 850.0,
      );
      final double spriteHeight = (maxH * (maxH < 450 ? 0.62 : 0.74)).clamp(160.0, maxSpriteH);
      final double spriteWidth = spriteHeight * (540.0 / 900.0);

      return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(
            left: uiScale.spacing(20, min: 12, max: 36),
            right: uiScale.spacing(20, min: 12, max: 36),
            bottom: (maxH < 450) ? 6 : uiScale.spacing(14, min: 8, max: 24),
            top: 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 1. PERSONAGEM PROFESSORA NURI (FIRMEMENTE NO CHÃO)
              SizedBox(
                width: spriteWidth + 12,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Positioned(
                      bottom: 4,
                      child: Container(
                        width: spriteWidth * 0.75,
                        height: uiScale.size(16, min: 10, max: 22),
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

              SizedBox(width: uiScale.spacing(18, min: 12, max: 28)),

              // 2. CARD NARRATIVO ALINHADO EM BAIXO (NO CHÃO JUNTO À NURI)
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: (maxH < 450) ? 0 : uiScale.spacing(8, min: 4, max: 14),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: uiScale.isDesktop ? 820.0 : 640.0,
                    ),
                    child: SpeechBubbleWidget(
                      step: step,
                      displayedText: _displayedText,
                      currentStepIndex: _currentStepIndex,
                      totalSteps: _steps.length,
                      isTyping: _isTyping,
                      pulseAnimation: _pulseAnimation,
                      tailPosition: TailPosition.none,
                      onTapCard: () {
                        if (_isTyping) _finishTyping();
                      },
                      onPressedNext: _onNextPressed,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // LAYOUT MOBILE / TELAS VERTICAIS ESTREITAS
      final double spriteHeight = (maxH * 0.36).clamp(140.0, 240.0);
      final double spriteWidth = spriteHeight * (540.0 / 900.0);

      return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 12,
            right: 12,
            bottom: 10,
            top: 4,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // 1. PROFESSORA NURI (NO CHÃO)
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Positioned(
                    bottom: 4,
                    child: Container(
                      width: spriteWidth * 0.75,
                      height: 12,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.55),
                            blurRadius: 12,
                            spreadRadius: 2,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildNuriSprite(spriteWidth, spriteHeight),
                ],
              ),

              const SizedBox(height: 6),

              // 2. CARD NARRATIVO NA BASE
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: SpeechBubbleWidget(
                  step: step,
                  displayedText: _displayedText,
                  currentStepIndex: _currentStepIndex,
                  totalSteps: _steps.length,
                  isTyping: _isTyping,
                  pulseAnimation: _pulseAnimation,
                  tailPosition: TailPosition.none,
                  onTapCard: () {
                    if (_isTyping) _finishTyping();
                  },
                  onPressedNext: _onNextPressed,
                ),
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
    final bool isBottomTail = tailPosition == TailPosition.bottom;
    final scale = context.uiScale;

    return GestureDetector(
      onTap: onTapCard,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: isLeftTail ? Alignment.centerLeft : Alignment.bottomCenter,
        children: [
          // Conteúdo Principal do Card Narrativo (Estilo HUD de Laboratório)
          Container(
            margin: EdgeInsets.only(
              left: isLeftTail ? 12 : 0,
              bottom: isBottomTail ? 12 : 0,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                scale.size(22, min: 16, max: 30),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: scale.spacing(20, min: 14, max: 28),
                    vertical: scale.spacing(18, min: 13, max: 24),
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xE603241B), Color(0xF201140E)],
                    ),
                    borderRadius: BorderRadius.circular(
                      scale.size(22, min: 16, max: 30),
                    ),
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.50),
                      width: 1.4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.55),
                        blurRadius: scale.size(24, min: 16, max: 36),
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.18),
                        blurRadius: scale.size(16, min: 10, max: 24),
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cabeçalho: Badge Orador + Indicadores de Etapas
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Badge Orador (Professora Nuri - Tamanho refinado com auto-scale para telas compactas)
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: scale.spacing(9, min: 6, max: 13),
                                  vertical: scale.spacing(3.5, min: 2.5, max: 6),
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF059669), Color(0xFF047857)],
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    scale.size(9, min: 7, max: 13),
                                  ),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF34D399,
                                    ).withValues(alpha: 0.60),
                                    width: 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF10B981,
                                      ).withValues(alpha: 0.30),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.school_rounded,
                                      color: Colors.white,
                                      size: scale.icon(14, min: 11, max: 17),
                                    ),
                                    SizedBox(
                                      width: scale.spacing(5, min: 3, max: 7),
                                    ),
                                    Text(
                                      step.speaker,
                                      style: GoogleFonts.rajdhani(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: scale.font(
                                          14,
                                          min: 11.5,
                                          max: 17,
                                        ),
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: scale.spacing(8, min: 4, max: 14)),

                          // Indicadores de Etapa (1/3, 2/3, 3/3)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(totalSteps, (index) {
                              final bool active = index == currentStepIndex;
                              final bool completed = index < currentStepIndex;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: EdgeInsets.only(
                                  left: scale.spacing(5, min: 3, max: 8),
                                ),
                                width: active
                                    ? scale.size(24, min: 16, max: 32)
                                    : scale.size(8, min: 6, max: 12),
                                height: scale.size(7, min: 5, max: 10),
                                decoration: BoxDecoration(
                                  color: active
                                      ? EletroLabColors.neonCyan
                                      : completed
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFF064E3B),
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: active
                                      ? [
                                          BoxShadow(
                                            color: EletroLabColors.neonCyan
                                                .withValues(alpha: 0.6),
                                            blurRadius: 6,
                                          ),
                                        ]
                                      : null,
                                ),
                              );
                            }),
                          ),
                        ],
                      ),

                      SizedBox(height: scale.spacing(12, min: 8, max: 18)),

                      // Texto com Efeito Typewriter e Realce de Palavras-Chave
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: scale.size(54, min: 40, max: 78),
                        ),
                        child: _buildRichDialogueText(displayedText, scale),
                      ),

                      SizedBox(height: scale.spacing(14, min: 10, max: 20)),

                      // Linha de Rodapé: Dica interativa à esquerda + Botão de Ação à direita
                      LayoutBuilder(
                        builder: (context, footerConstraints) {
                          final bool showHint = footerConstraints.maxWidth >= 310;
                          return Row(
                            mainAxisAlignment: showHint
                                ? MainAxisAlignment.spaceBetween
                                : MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Dica sutil interativa (oculta em telas ultra-estreitas)
                              if (showHint) ...[
                                Flexible(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isTyping
                                            ? Icons.touch_app_rounded
                                            : Icons.touch_app_outlined,
                                        color: Colors.white38,
                                        size: scale.icon(15, min: 12, max: 18),
                                      ),
                                      SizedBox(
                                        width: scale.spacing(5, min: 3, max: 7),
                                      ),
                                      Flexible(
                                        child: Text(
                                          isTyping
                                              ? 'Toque para acelerar'
                                              : 'Toque para avançar',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.outfit(
                                            color: Colors.white38,
                                            fontSize: scale.font(
                                              12,
                                              min: 10,
                                              max: 14.5,
                                            ),
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: scale.spacing(8, min: 4, max: 12)),
                              ],

                              // Botão de Ação (com auto-scale para telas compactas)
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerRight,
                                  child: isLastStep && !isTyping
                                      ? ScaleTransition(
                                          scale: pulseAnimation,
                                          child: ElevatedButton.icon(
                                            onPressed: onPressedNext,
                                            icon: Icon(
                                              Icons.bolt_rounded,
                                              size: scale.icon(22, min: 18, max: 30),
                                            ),
                                            label: Text(
                                              step.buttonText,
                                              style: GoogleFonts.rajdhani(
                                                fontWeight: FontWeight.bold,
                                                fontSize: scale.font(
                                                  17.5,
                                                  min: 14.5,
                                                  max: 24.0,
                                                ),
                                                letterSpacing: 0.6,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF10B981),
                                              foregroundColor: const Color(0xFF021712),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: scale.spacing(
                                                  24,
                                                  min: 18,
                                                  max: 34,
                                                ),
                                                vertical: scale.spacing(
                                                  12,
                                                  min: 9,
                                                  max: 18,
                                                ),
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                  scale.size(14, min: 10, max: 20),
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
                                            size: scale.icon(18, min: 14, max: 24),
                                          ),
                                          label: Text(
                                            isTyping ? 'Acelerar' : step.buttonText,
                                            style: GoogleFonts.rajdhani(
                                              fontWeight: FontWeight.bold,
                                              fontSize: scale.font(
                                                16.5,
                                                min: 13.5,
                                                max: 23.0,
                                              ),
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isTyping
                                                ? const Color(0x99047857)
                                                : const Color(0xFF059669),
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: scale.spacing(
                                                20,
                                                min: 15,
                                                max: 28,
                                              ),
                                              vertical: scale.spacing(
                                                11,
                                                min: 8,
                                                max: 16,
                                              ),
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                scale.size(12, min: 9, max: 18),
                                              ),
                                              side: isTyping
                                                  ? BorderSide(
                                                      color: const Color(
                                                        0xFF10B981,
                                                      ).withValues(alpha: 0.5),
                                                      width: 1.0,
                                                    )
                                                  : BorderSide.none,
                                            ),
                                            elevation: isTyping ? 0 : 4,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Cauda / Pointer do Balão de Fala (apenas quando não for TailPosition.none)
          if (isLeftTail || isBottomTail)
            Positioned(
              left: isLeftTail ? 0 : null,
              top: isLeftTail ? scale.size(36, min: 28, max: 54) : null,
              bottom: isBottomTail ? 0 : null,
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
                  color: const Color(0xE603241B),
                  borderColor: const Color(0xFF10B981),
                  position: tailPosition,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Constrói o texto do diálogo com realce visual em palavras-chave científicas
  Widget _buildRichDialogueText(String text, UiScale scale) {
    final baseStyle = GoogleFonts.outfit(
      color: const Color(0xFFF1F5F9),
      fontSize: scale.font(17.0, min: 14.5, max: 22.0),
      height: 1.5,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
    );

    final pattern = RegExp(
      r'(Feira de Ciências|Ginásio|circuitos elétricos|energia renovável|automação|desafios de circuitos|Maquete Coletiva)',
      caseSensitive: false,
    );

    final matches = pattern.allMatches(text);
    if (matches.isEmpty) {
      return Text(text, style: baseStyle);
    }

    final spans = <TextSpan>[];
    int lastIndex = 0;

    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
      }

      final matchedText = match.group(0)!;
      final lower = matchedText.toLowerCase();

      Color highlightColor = const Color(0xFF34D399);
      if (lower.contains('circuito') || lower.contains('ginásio')) {
        highlightColor = const Color(0xFF00E5FF);
      } else if (lower.contains('automação') || lower.contains('maquete')) {
        highlightColor = const Color(0xFFFBBF24);
      } else if (lower.contains('renovável')) {
        highlightColor = const Color(0xFF10B981);
      }

      spans.add(
        TextSpan(
          text: matchedText,
          style: TextStyle(
            color: highlightColor,
            fontWeight: FontWeight.w700,
            shadows: [
              Shadow(
                color: highlightColor.withValues(alpha: 0.45),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      );
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }

    return Text.rich(TextSpan(style: baseStyle, children: spans));
  }
}

/// Desenha o rabo/triângulo indicador do balão de fala (quando ativado)
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
    if (position == TailPosition.none) return;

    final path = Path();
    if (position == TailPosition.left) {
      path.moveTo(size.width, 0);
      path.lineTo(0, size.height / 2);
      path.lineTo(size.width, size.height);
      path.close();
    } else {
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
