import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:google_fonts/google_fonts.dart';
import '../../app/routes.dart';
import '../../core/ui_scale.dart';
import '../../state/progress_controller.dart';
import '../../widgets/circuit_e_emblem.dart';
import '../../widgets/low_poly_badge.dart';
import '../../widgets/low_poly_button.dart';

/// Tela de Menu Principal / Página Inicial do EletroLab.
/// Cabeçalho com marca idêntica à tela de carregamento e card central compacto com modais.
class MainMenuScreen extends ConsumerStatefulWidget {
  const MainMenuScreen({super.key});

  @override
  ConsumerState<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends ConsumerState<MainMenuScreen> {
  bool _showGameModes = false;

  @override
  Widget build(BuildContext context) {
    final progressState = ref.watch(progressControllerProvider);
    final completedCount = progressState.completedChallenges.length;
    final bool hasProgress = completedCount > 0;
    final scale = context.uiScale;

    return PopScope(
      canPop: !_showGameModes,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _showGameModes) {
          setState(() => _showGameModes = false);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF021712),
        body: Stack(
          children: [
            // 1. Imagem de Fundo (Fachada do Ginásio sem camada escura)
            Positioned.fill(
              child: Image.asset(
                'assets/low-poly/ginasio-alpha-low-poly-portas-fechadas.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: const Color(0xFF03281E));
                },
              ),
            ),

            // 2. Conteúdo Principal (Cabeçalho Superior + Marca Central + Card)
            SafeArea(
              child: Column(
                children: [
                  // Topo: Botão de Configurações no canto direito
                  _buildTopHeader(context),

                  // Painel Central: Marca Oficial + Card Glassmorphic do Menu
                  Expanded(
                    child: Align(
                      alignment: const Alignment(0.0, 0.52),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: scale.insetsSymmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Identidade Oficial em formato horizontal (oculta no submenu)
                              if (!_showGameModes) ...[
                                _buildBrandingHeader(scale),
                                SizedBox(
                                  height: scale.spacing(12, min: 8, max: 18),
                                ),
                              ],

                              // Card de Ações do Menu (Estilo Low-Poly 3D)
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: scale.size(520, min: 360, max: 800),
                                ),
                                child: Container(
                                  decoration: ShapeDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xF003261E),
                                        Color(0xFA011712),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BeveledRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        scale.size(20),
                                      ),
                                      side: const BorderSide(
                                        color: Color(0xFF10B981),
                                        width: 1.5,
                                      ),
                                    ),
                                    shadows: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.60,
                                        ),
                                        blurRadius: scale.size(28),
                                        offset: Offset(0, scale.size(8)),
                                      ),
                                      BoxShadow(
                                        color: const Color(
                                          0xFF10B981,
                                        ).withValues(alpha: 0.25),
                                        blurRadius: scale.size(18),
                                      ),
                                    ],
                                  ),
                                  child: ClipPath(
                                    clipper: ShapeBorderClipper(
                                      shape: BeveledRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          scale.size(19.5),
                                        ),
                                      ),
                                    ),
                                    child: Container(
                                      padding: scale.insetsSymmetric(
                                        horizontal: 22,
                                        vertical: 18,
                                      ),
                                      child: AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 220,
                                        ),
                                        transitionBuilder: (child, animation) {
                                          return FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          );
                                        },
                                        child: _showGameModes
                                            ? KeyedSubtree(
                                                key: const ValueKey(
                                                  'game_modes_view',
                                                ),
                                                child: _buildGameModesView(
                                                  context,
                                                  scale,
                                                  hasProgress,
                                                ),
                                              )
                                            : KeyedSubtree(
                                                key: const ValueKey(
                                                  'main_menu_view',
                                                ),
                                                child: _buildMainMenuView(
                                                  context,
                                                  scale,
                                                  hasProgress,
                                                  completedCount,
                                                ),
                                              ),
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

                  // Rodapé Limpo
                  Padding(
                    padding: scale.insetsOnly(bottom: 14, top: 4),
                    child: Text(
                      'EletroLab v1.2.0 • Laboratório Virtual de Circuitos Elétricos',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF022C22),
                        fontSize: scale.font(13.5),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Visão Principal do Menu: Entrada / Continuação e Acesso aos Modos de Jogo
  Widget _buildMainMenuView(
    BuildContext context,
    UiScale scale,
    bool hasProgress,
    int completedCount,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. CONTINUAR DE ONDE PAROU (se houver progresso)
        if (hasProgress) ...[
          _buildLowPolyMenuButton(
            context,
            title: 'Continuar de Onde Parou',
            subtitle:
                '$completedCount de 12 estandes concluídos • Voltar à feira',
            accentColor: const Color(0xFF10B981),
            isHighlighted: true,
            trailing: Icon(
              Icons.play_arrow_rounded,
              color: const Color(0xFF021B14),
              size: scale.icon(24),
            ),
            onTap: () => Navigator.of(context).pushNamed(Routes.home),
          ),
          SizedBox(height: scale.spacing(12)),

          // Opção secundária: Entrar na Feira (falar com Professora Nuri)
          _buildLowPolyMenuButton(
            context,
            title: 'Entrar na Feira',
            subtitle: 'Falar com a Professora Nuri na entrada do Ginásio',
            accentColor: const Color(0xFF10B981),
            isHighlighted: false,
            onTap: () => Navigator.of(context).pushNamed(Routes.intro),
          ),
          SizedBox(height: scale.spacing(12)),
        ] else ...[
          // Se não há progresso: ENTRAR NA FEIRA é a ação principal destacada
          _buildLowPolyMenuButton(
            context,
            title: 'Entrar na Feira',
            subtitle: 'Falar com a Professora Nuri na entrada do Ginásio',
            accentColor: const Color(0xFF10B981),
            isHighlighted: true,
            trailing: Icon(
              Icons.play_arrow_rounded,
              color: const Color(0xFF021B14),
              size: scale.icon(24),
            ),
            onTap: () => Navigator.of(context).pushNamed(Routes.intro),
          ),
          SizedBox(height: scale.spacing(12)),
        ],

        // 2. MODOS DE JOGO (Abre o submenu de modos extras)
        _buildLowPolyMenuButton(
          context,
          title: 'Modos de Jogo',
          subtitle: 'Bancada Livre e Primeiros Passos & Conceitos',
          accentColor: const Color(0xFF00E5FF),
          isHighlighted: false,
          trailing: Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white.withValues(alpha: 0.8),
            size: scale.icon(16),
          ),
          onTap: () => setState(() => _showGameModes = true),
        ),
      ],
    );
  }

  /// Visão do Submenu: Modos de Jogo (Bancada Livre, Primeiros Passos, etc.)
  Widget _buildGameModesView(
    BuildContext context,
    UiScale scale,
    bool hasProgress,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Barra Superior com botão Voltar e Título (Chanfrado Low-Poly)
        Padding(
          padding: scale.insetsOnly(bottom: 14),
          child: Row(
            children: [
              Material(
                color: const Color(0xFF03261E),
                shape: BeveledRectangleBorder(
                  borderRadius: BorderRadius.circular(scale.size(6)),
                  side: const BorderSide(color: Color(0xFF10B981), width: 1.0),
                ),
                child: InkWell(
                  onTap: () => setState(() => _showGameModes = false),
                  customBorder: BeveledRectangleBorder(
                    borderRadius: BorderRadius.circular(scale.size(6)),
                  ),
                  child: Padding(
                    padding: scale.insetsSymmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_back_rounded,
                          color: const Color(0xFF34D399),
                          size: scale.icon(16),
                        ),
                        SizedBox(width: scale.spacing(4)),
                        Text(
                          'Voltar',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF34D399),
                            fontSize: scale.font(13),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(),
              const LowPolyBadge(
                label: 'MODOS DE JOGO',
                variant: LowPolyBadgeVariant.cyan,
                fontSize: 11.5,
                bevelRadius: 4.0,
              ),
            ],
          ),
        ),

        // Opção 1: BANCADA LIVRE - Borda Ciano
        _buildLowPolyMenuButton(
          context,
          title: 'Bancada Livre',
          subtitle:
              'Laboratório aberto para montar e testar circuitos sem limites',
          accentColor: const Color(0xFF00E5FF),
          isHighlighted: false,
          onTap: () => Navigator.of(context).pushNamed(Routes.sandbox),
        ),

        SizedBox(height: scale.spacing(10)),

        // Opção 2: PRIMEIROS PASSOS & CONCEITOS - Borda Âmbar
        _buildLowPolyMenuButton(
          context,
          title: 'Primeiros Passos & Conceitos',
          subtitle:
              'Guia interativo com catálogo de componentes, símbolos e quiz',
          accentColor: const Color(0xFFF59E0B),
          isHighlighted: false,
          onTap: () => Navigator.of(context).pushNamed(Routes.firstSteps),
        ),

        // Opção 3: MAPA DIRETO (se ainda não iniciou e quer ver estandes)
        if (!hasProgress) ...[
          SizedBox(height: scale.spacing(10)),
          _buildLowPolyMenuButton(
            context,
            title: 'Mapa da Feira de Ciências',
            subtitle: 'Navegar diretamente pelos 12 estandes de desafios',
            accentColor: const Color(0xFF10B981),
            isHighlighted: false,
            onTap: () => Navigator.of(context).pushNamed(Routes.home),
          ),
        ],
      ],
    );
  }

  /// Topo com Botão de Configurações no Canto Direito (Chanfrado Low-Poly 3D)
  Widget _buildTopHeader(BuildContext context) {
    final scale = context.uiScale;
    final double buttonSize = scale.size(46, min: 40, max: 56);
    final double bevel = scale.size(8, min: 6, max: 12);

    return Padding(
      padding: scale.insetsSymmetric(horizontal: 24, vertical: 12),
      child: Align(
        alignment: Alignment.topRight,
        child: Tooltip(
          message: 'Configurações',
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: SizedBox(
              width: buttonSize,
              height: buttonSize + 3.0,
              child: Stack(
                children: [
                  // Base 3D inferior
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: buttonSize,
                    child: Material(
                      color: const Color(0xFF021B14),
                      shape: BeveledRectangleBorder(
                        borderRadius: BorderRadius.circular(bevel),
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  // Face frontal
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: buttonSize,
                    child: Material(
                      color: const Color(0xFF063B2C),
                      shape: BeveledRectangleBorder(
                        borderRadius: BorderRadius.circular(bevel),
                        side: BorderSide(
                          color: const Color(0xFF10B981).withValues(alpha: 0.8),
                          width: 1.4,
                        ),
                      ),
                      elevation: 3,
                      child: InkWell(
                        onTap: () =>
                            Navigator.of(context).pushNamed(Routes.settings),
                        customBorder: BeveledRectangleBorder(
                          borderRadius: BorderRadius.circular(bevel),
                        ),
                        splashColor: const Color(0xFF10B981).withValues(alpha: 0.3),
                        child: Center(
                          child: Icon(
                            Icons.settings_rounded,
                            color: Colors.white70,
                            size: scale.icon(22),
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
    );
  }

  /// Botão de Menu no Padrão Low-Poly 3D com Chanfros e Efeito Push-Down
  Widget _buildLowPolyMenuButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color accentColor,
    required bool isHighlighted,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final scale = context.uiScale;
    final double bevel = scale.size(10.0, min: 8.0, max: 14.0);
    final double depth = scale.size(4.0, min: 3.0, max: 5.0);

    return _LowPolyMenuCardButton(
      title: title,
      subtitle: subtitle,
      accentColor: accentColor,
      isHighlighted: isHighlighted,
      bevel: bevel,
      depth: depth,
      onTap: onTap,
      trailing: trailing,
    );
  }

  /// Cabeçalho com a Marca Oficial Horizontal sem fundo (monograma na altura dos textos)
  Widget _buildBrandingHeader(UiScale scale) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Emblema Vetorial monocromático branco acompanhando a altura total dos textos
          CircuitEEmblem(
            size: scale.size(54, min: 44, max: 64),
            color: Colors.white,
            progress: 1.0,
            pulseGlow: true,
          ),

          SizedBox(width: scale.spacing(14, min: 10, max: 18)),

          // Textos alinhados horizontalmente ao lado do emblema
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Linha superior: Marca Oficial ELETROLAB dual-tone + Badge de Volume
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'ELETRO',
                          style: TextStyle(
                            color: const Color(0xFFF8FAFC),
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.75),
                                blurRadius: scale.size(8),
                                offset: Offset(0, scale.size(2)),
                              ),
                              Shadow(
                                color: const Color(
                                  0xFF34D399,
                                ).withValues(alpha: 0.70),
                                blurRadius: scale.size(10),
                              ),
                            ],
                          ),
                        ),
                        TextSpan(
                          text: 'LAB',
                          style: TextStyle(
                            color: const Color(0xFFFBBF24),
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.75),
                                blurRadius: scale.size(8),
                                offset: Offset(0, scale.size(2)),
                              ),
                              Shadow(
                                color: const Color(
                                  0xFFF59E0B,
                                ).withValues(alpha: 0.85),
                                blurRadius: scale.size(12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    style: GoogleFonts.orbitron(
                      fontSize: scale.font(22, min: 17, max: 28),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.5,
                    ),
                  ),
                  SizedBox(width: scale.spacing(8, min: 6, max: 12)),
                  _buildVolumeBadge(scale),
                ],
              ),

              SizedBox(height: scale.spacing(3)),

              // Subtítulo Oficial
              Text(
                'ENERGIZANDO A FEIRA DE CIÊNCIAS',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: scale.font(10.5, min: 8.5, max: 13.0),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.85),
                      blurRadius: scale.size(6),
                      offset: Offset(0, scale.size(1.5)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Badge de Franquia / Edição (Chanfrado Low-Poly)
  Widget _buildVolumeBadge(UiScale scale) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: scale.spacing(12, min: 9, max: 16),
        vertical: scale.spacing(3, min: 2, max: 5),
      ),
      decoration: ShapeDecoration(
        color: const Color(0xDD021F18),
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(scale.size(6)),
          side: const BorderSide(color: Color(0xFF10B981), width: 1.0),
        ),
        shadows: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: scale.size(6, min: 5, max: 7),
            height: scale.size(6, min: 5, max: 7),
            decoration: ShapeDecoration(
              color: const Color(0xFF10B981),
              shape: BeveledRectangleBorder(
                borderRadius: BorderRadius.circular(2),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0xFF10B981),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          SizedBox(width: scale.spacing(6, min: 4, max: 8)),
          Text(
            'JOGO 1 • VOLUME 1',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFFE2E8F0),
              fontSize: scale.font(11.5, min: 9.5, max: 14),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Botão em card estilizado no formato Low-Poly 3D com base mecânica push-down.
class _LowPolyMenuCardButton extends StatefulWidget {
  final String title;
  final String subtitle;
  final Color accentColor;
  final bool isHighlighted;
  final double bevel;
  final double depth;
  final VoidCallback onTap;
  final Widget? trailing;

  const _LowPolyMenuCardButton({
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.isHighlighted,
    required this.bevel,
    required this.depth,
    required this.onTap,
    this.trailing,
  });

  @override
  State<_LowPolyMenuCardButton> createState() => _LowPolyMenuCardButtonState();
}

class _LowPolyMenuCardButtonState extends State<_LowPolyMenuCardButton> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;
    final double depth = widget.depth;
    final double currentOffset = _isPressed ? depth : 0.0;

    // Paleta Low-Poly 3D
    final Color topFaceColor = widget.isHighlighted
        ? (_isHovered ? const Color(0xFF15D898) : const Color(0xFF10B981))
        : (_isHovered ? const Color(0xFF093E31) : const Color(0xFF04281E));

    final Color bottomBaseColor = widget.isHighlighted
        ? const Color(0xFF047857)
        : const Color(0xFF011611);

    final Color borderColor = widget.isHighlighted
        ? const Color(0xFF6EE7B7)
        : (_isHovered
              ? widget.accentColor
              : widget.accentColor.withValues(alpha: 0.60));

    final Color titleColor = widget.isHighlighted
        ? const Color(0xFF01241B)
        : Colors.white;

    final Color subtitleColor = widget.isHighlighted
        ? const Color(0xFF02382B)
        : Colors.white.withValues(alpha: 0.72);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        if (mounted) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (mounted) {
          setState(() {
            _isHovered = false;
            _isPressed = false;
          });
        }
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () {
          if (mounted) setState(() => _isPressed = false);
        },
        child: SizedBox(
          width: double.infinity,
          child: Stack(
            children: [
              // 1. Base 3D Inferior Fixa (extrusão sólida)
              Positioned.fill(
                top: depth,
                child: Material(
                  color: bottomBaseColor,
                  shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.circular(widget.bevel),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),

              // 2. Face Superior Dinâmica (translada com efeito mecânico)
              Transform.translate(
                offset: Offset(0, currentOffset),
                child: Material(
                  color: topFaceColor,
                  shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.circular(widget.bevel),
                    side: BorderSide(
                      color: borderColor,
                      width: widget.isHighlighted ? 1.8 : 1.3,
                    ),
                  ),
                  elevation: _isPressed ? 0 : (widget.isHighlighted ? 3 : 1),
                  child: Padding(
                    padding: scale.insetsSymmetric(
                      horizontal: 18,
                      vertical: 13,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.title,
                                style: GoogleFonts.outfit(
                                  color: titleColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: scale.font(
                                    widget.isHighlighted ? 17.0 : 15.5,
                                  ),
                                  letterSpacing: 0.3,
                                ),
                              ),
                              SizedBox(height: scale.spacing(3)),
                              Text(
                                widget.subtitle,
                                style: GoogleFonts.outfit(
                                  color: subtitleColor,
                                  fontSize: scale.font(12.8),
                                  fontWeight: widget.isHighlighted
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.trailing != null) ...[
                          SizedBox(width: scale.spacing(8)),
                          widget.trailing!,
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
