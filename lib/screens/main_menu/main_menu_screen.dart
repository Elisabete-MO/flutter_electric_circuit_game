import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:google_fonts/google_fonts.dart';
import '../../app/routes.dart';
import '../../state/progress_controller.dart';
import '../../widgets/eletrolab_header_brand.dart';

/// Tela de Menu Principal / Página Inicial do EletroLab.
/// Cabeçalho no canto superior esquerdo com marca e subtítulo 'Laboratório Virtual de Circuitos',
/// painel central glassmorphic com bordas coloridas nos botões e divisor 'MODOS DE JOGO'.
class MainMenuScreen extends ConsumerStatefulWidget {
  const MainMenuScreen({super.key});

  @override
  ConsumerState<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends ConsumerState<MainMenuScreen> {
  @override
  Widget build(BuildContext context) {
    final progressState = ref.watch(progressControllerProvider);
    final completedCount = progressState.completedChallenges.length;
    final bool hasProgress = completedCount > 0;

    return Scaffold(
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

          // 2. Conteúdo Principal (Cabeçalho Superior + Card Central)
          SafeArea(
            child: Column(
              children: [
                // Topo: Marca EletroLab no canto esquerdo e Configurações no canto direito
                _buildTopHeader(context),

                const SizedBox(height: 12),

                // Painel Central Glassmorphic
                Expanded(
                  child: Align(
                    alignment: const Alignment(0.0, 0.38),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 18,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0x99021F18,
                                  ), // Glassmorphism escuro elegante
                                  borderRadius: BorderRadius.circular(20),
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
                                      blurRadius: 24,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Opção 1: CONTINUAR DE ONDE PAROU (se houver progresso)
                                    if (hasProgress) ...[
                                      _buildMinimalButton(
                                        context,
                                        title: 'Continuar de Onde Parou',
                                        subtitle:
                                            '$completedCount de 12 estandes concluídos • Voltar à feira',
                                        accentColor: const Color(0xFF10B981),
                                        isHighlighted: true,
                                        onTap: () => Navigator.of(
                                          context,
                                        ).pushNamed(Routes.home),
                                      ),
                                      const SizedBox(height: 10),
                                    ],

                                    // Opção 2: ENTRAR NA FEIRA (Professora Nuri)
                                    _buildMinimalButton(
                                      context,
                                      title: 'Entrar na Feira',
                                      subtitle:
                                          'Falar com a Professora Nuri na entrada do Ginásio',
                                      accentColor: const Color(0xFF10B981),
                                      isHighlighted: !hasProgress,
                                      onTap: () => Navigator.of(
                                        context,
                                      ).pushNamed(Routes.intro),
                                    ),

                                    const SizedBox(height: 14),

                                    // Divisor Elegante: MODOS DE JOGO
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Divider(
                                            color: Colors.white.withValues(
                                              alpha: 0.15,
                                            ),
                                            thickness: 1,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                          child: Text(
                                            'MODOS DE JOGO',
                                            style: GoogleFonts.rajdhani(
                                              color: Colors.white.withValues(
                                                alpha: 0.5,
                                              ),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                              letterSpacing: 1.4,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Divider(
                                            color: Colors.white.withValues(
                                              alpha: 0.15,
                                            ),
                                            thickness: 1,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    // Opção 3: BANCADA LIVRE - Borda Ciano
                                    _buildMinimalButton(
                                      context,
                                      title: 'Bancada Livre',
                                      subtitle:
                                          'Laboratório aberto para montar e testar circuitos sem limites',
                                      accentColor: const Color(0xFF06B6D4),
                                      isHighlighted: false,
                                      onTap: () => Navigator.of(
                                        context,
                                      ).pushNamed(Routes.sandbox),
                                    ),

                                    const SizedBox(height: 10),

                                    // Opção 4: MAPA DA FEIRA DE CIÊNCIAS - Borda Esmeralda
                                    if (!hasProgress) ...[
                                      _buildMinimalButton(
                                        context,
                                        title: 'Mapa da Feira de Ciências',
                                        subtitle:
                                            'Navegar diretamente pelos 12 estandes de desafios',
                                        accentColor: const Color(0xFF10B981),
                                        isHighlighted: false,
                                        onTap: () => Navigator.of(
                                          context,
                                        ).pushNamed(Routes.home),
                                      ),
                                      const SizedBox(height: 10),
                                    ],

                                    // Opção 5: PRIMEIROS PASSOS & CONCEITOS - Borda Âmbar
                                    _buildMinimalButton(
                                      context,
                                      title: 'Primeiros Passos & Conceitos',
                                      subtitle:
                                          'Guia interativo com catálogo de componentes, símbolos e quiz',
                                      accentColor: const Color(0xFFF59E0B),
                                      isHighlighted: false,
                                      onTap: () => Navigator.of(
                                        context,
                                      ).pushNamed(Routes.firstSteps),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Rodapé Limpo
                Padding(
                  padding: const EdgeInsets.only(bottom: 12, top: 4),
                  child: Text(
                    'EletroLab v1.2.0 • Laboratório Virtual de Circuitos Elétricos',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF022C22),
                      fontSize: 12,
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
    );
  }

  /// Topo com Marca no Canto Esquerdo e Botão de Configurações no Canto Direito
  Widget _buildTopHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Canto Superior Esquerdo: EletroLab + Subtítulo 'Laboratório Virtual de Circuitos'
          const EletroLabHeaderBrand(),

          // Canto Superior Direito: Botão de Configurações
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed(Routes.settings),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xCC04281E),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.4),
                ),
              ),
              child: const Icon(
                Icons.settings_rounded,
                color: Colors.white70,
                size: 20,
              ),
            ),
            tooltip: 'Configurações',
          ),
        ],
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
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: isHighlighted
                ? const Color(0xFF059669)
                : const Color(0x77032E23),
            borderRadius: BorderRadius.circular(14),
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
                blurRadius: isHighlighted ? 14 : 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: isHighlighted ? 14.5 : 13.5,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.outfit(
                  color: isHighlighted
                      ? const Color(0xFFD1FAE5)
                      : Colors.white.withValues(alpha: 0.65),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
