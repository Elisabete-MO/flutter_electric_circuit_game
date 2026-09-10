import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:google_fonts/google_fonts.dart';
import '../../app/routes.dart';
import '../../core/ui_scale.dart';
import '../../state/progress_controller.dart';
import '../../widgets/circuit_e_emblem.dart';

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
                'assets/intro/gym_front.png',
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

                              // Card de Ações do Menu
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: scale.size(500, min: 360, max: 800),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    scale.size(22),
                                  ),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 16,
                                      sigmaY: 16,
                                    ),
                                    child: Container(
                                      padding: scale.insetsSymmetric(
                                        horizontal: 22,
                                        vertical: 18,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0x99021F18,
                                        ), // Glassmorphism escuro elegante
                                        borderRadius: BorderRadius.circular(
                                          scale.size(22),
                                        ),
                                        border: Border.all(
                                          color: const Color(
                                            0xFF10B981,
                                          ).withValues(alpha: 0.35),
                                          width: 1.4,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.4,
                                            ),
                                            blurRadius: scale.size(24),
                                            offset: Offset(0, scale.size(6)),
                                          ),
                                        ],
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
          _buildMinimalButton(
            context,
            title: 'Continuar de Onde Parou',
            subtitle:
                '$completedCount de 12 estandes concluídos • Voltar à feira',
            accentColor: const Color(0xFF10B981),
            isHighlighted: true,
            trailing: Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: scale.icon(24),
            ),
            onTap: () => Navigator.of(context).pushNamed(Routes.home),
          ),
          SizedBox(height: scale.spacing(10)),

          // Opção secundária: Entrar na Feira (falar com Professora Nuri)
          _buildMinimalButton(
            context,
            title: 'Entrar na Feira',
            subtitle: 'Falar com a Professora Nuri na entrada do Ginásio',
            accentColor: const Color(0xFF10B981),
            isHighlighted: false,
            onTap: () => Navigator.of(context).pushNamed(Routes.intro),
          ),
          SizedBox(height: scale.spacing(10)),
        ] else ...[
          // Se não há progresso: ENTRAR NA FEIRA é a ação principal destacada
          _buildMinimalButton(
            context,
            title: 'Entrar na Feira',
            subtitle: 'Falar com a Professora Nuri na entrada do Ginásio',
            accentColor: const Color(0xFF10B981),
            isHighlighted: true,
            trailing: Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: scale.icon(24),
            ),
            onTap: () => Navigator.of(context).pushNamed(Routes.intro),
          ),
          SizedBox(height: scale.spacing(10)),
        ],

        // 2. MODOS DE JOGO (Abre o submenu de modos extras)
        _buildMinimalButton(
          context,
          title: 'Modos de Jogo',
          subtitle: 'Bancada Livre e Primeiros Passos & Conceitos',
          accentColor: const Color(0xFF06B6D4),
          isHighlighted: false,
          trailing: Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white.withValues(alpha: 0.65),
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
        // Barra Superior com botão Voltar e Título
        Padding(
          padding: scale.insetsOnly(bottom: 12),
          child: Row(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() => _showGameModes = false),
                  borderRadius: BorderRadius.circular(scale.size(10)),
                  child: Padding(
                    padding: scale.insetsSymmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_back_rounded,
                          color: const Color(0xFF34D399),
                          size: scale.icon(18),
                        ),
                        SizedBox(width: scale.spacing(4)),
                        Text(
                          'Voltar',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF34D399),
                            fontSize: scale.font(14),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'MODOS DE JOGO',
                style: GoogleFonts.rajdhani(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.bold,
                  fontSize: scale.font(13),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),

        // Opção 1: BANCADA LIVRE - Borda Ciano
        _buildMinimalButton(
          context,
          title: 'Bancada Livre',
          subtitle:
              'Laboratório aberto para montar e testar circuitos sem limites',
          accentColor: const Color(0xFF06B6D4),
          isHighlighted: false,
          onTap: () => Navigator.of(context).pushNamed(Routes.sandbox),
        ),

        SizedBox(height: scale.spacing(10)),

        // Opção 2: PRIMEIROS PASSOS & CONCEITOS - Borda Âmbar
        _buildMinimalButton(
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
          _buildMinimalButton(
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

  /// Topo com Botão de Configurações no Canto Direito
  Widget _buildTopHeader(BuildContext context) {
    final scale = context.uiScale;

    return Padding(
      padding: scale.insetsSymmetric(horizontal: 24, vertical: 12),
      child: Align(
        alignment: Alignment.topRight,
        child: IconButton(
          onPressed: () => Navigator.of(context).pushNamed(Routes.settings),
          icon: Container(
            padding: scale.insetsAll(10),
            decoration: BoxDecoration(
              color: const Color(0xCC04281E),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.4),
              ),
            ),
            child: Icon(
              Icons.settings_rounded,
              color: Colors.white70,
              size: scale.icon(22),
            ),
          ),
          tooltip: 'Configurações',
        ),
      ),
    );
  }

  /// Botão Minimalista com Bordas Coloridas e Efeito Glassmorphism
  Widget _buildMinimalButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color accentColor,
    required bool isHighlighted,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final scale = context.uiScale;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(scale.size(16)),
        child: Container(
          width: double.infinity,
          padding: scale.insetsSymmetric(horizontal: 18, vertical: 13),
          decoration: BoxDecoration(
            color: isHighlighted
                ? const Color(0xFF059669)
                : const Color(0x77032E23),
            borderRadius: BorderRadius.circular(scale.size(16)),
            border: Border.all(
              color: isHighlighted
                  ? const Color(0xFF34D399)
                  : accentColor.withValues(alpha: 0.5),
              width: isHighlighted ? 1.6 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isHighlighted
                    ? const Color(0xFF10B981).withValues(alpha: 0.35)
                    : accentColor.withValues(alpha: 0.12),
                blurRadius: scale.size(isHighlighted ? 14 : 8),
                offset: Offset(0, scale.size(3)),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: scale.font(isHighlighted ? 17.0 : 15.5),
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: scale.spacing(3)),
                    Text(
                      subtitle,
                      style: GoogleFonts.outfit(
                        color: isHighlighted
                            ? const Color(0xFFD1FAE5)
                            : Colors.white.withValues(alpha: 0.70),
                        fontSize: scale.font(12.8),
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                SizedBox(width: scale.spacing(8)),
                trailing,
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Cabeçalho com a Marca Oficial Horizontal sem fundo (monograma na altura dos textos)
  Widget _buildBrandingHeader(UiScale scale) {
    return Row(
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
                color: const Color(0xFF34D399),
                fontSize: scale.font(10.5, min: 8.5, max: 13.0),
                fontWeight: FontWeight.w700,
                letterSpacing: 1.6,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.8),
                    blurRadius: scale.size(6),
                    offset: Offset(0, scale.size(1.5)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Badge de Franquia / Edição
  Widget _buildVolumeBadge(UiScale scale) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: scale.spacing(12, min: 9, max: 16),
        vertical: scale.spacing(3, min: 2, max: 5),
      ),
      decoration: BoxDecoration(
        color: const Color(0xCC04281E),
        borderRadius: BorderRadius.circular(scale.size(16)),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.55),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.20),
            blurRadius: scale.size(8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: scale.size(6, min: 5, max: 7),
            height: scale.size(6, min: 5, max: 7),
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
              boxShadow: [
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
