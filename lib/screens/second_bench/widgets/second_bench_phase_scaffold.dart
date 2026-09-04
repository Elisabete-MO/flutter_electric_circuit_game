import 'package:flutter/material.dart';
import '../second_bench_tokens.dart';
import 'second_bench_action_bar.dart';

/// Scaffold estrutural e visual reutilizável para todas as 4 fases do Estande 2 (Acende Aí).
class SecondBenchPhaseScaffold extends StatelessWidget {
  final int phase;
  final String title;
  final String instruction;
  final IconData introIcon;
  final Widget workspace;
  final Widget sidePanel;
  final SecondBenchActionBar actionBar;
  final String backgroundAsset;
  final VoidCallback? onHelpTap;

  const SecondBenchPhaseScaffold({
    super.key,
    required this.phase,
    required this.title,
    required this.instruction,
    this.introIcon = Icons.menu_book_rounded,
    required this.workspace,
    required this.sidePanel,
    required this.actionBar,
    this.backgroundAsset = 'assets/backgrounds/background_fase_02_bancada.png',
    this.onHelpTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SecondBenchLayoutTokens.bgDark,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 850;
            return isDesktop
                ? _buildDesktopLayout(context, constraints)
                : _buildMobileLayout(context, constraints);
          },
        ),
      ),
    );
  }

  // ==========================================
  // LAYOUT DESKTOP
  // ==========================================
  Widget _buildDesktopLayout(BuildContext context, BoxConstraints constraints) {
    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: SecondBenchLayoutTokens.desktopMaxWidth,
          height: SecondBenchLayoutTokens.desktopMaxHeight,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // 1. Background do Laboratório
              Positioned.fill(
                child: Image.asset(
                  backgroundAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/backgrounds/background_fase_02_bancada.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // 2. Cartão de Título e Instrução (topo esquerdo)
              Positioned(
                top: 20,
                left: 28,
                width: SecondBenchLayoutTokens.introMaxWidth,
                child: _PhaseIntroCard(
                  phase: phase,
                  title: title,
                  instruction: instruction,
                  icon: introIcon,
                ),
              ),

              // 3. Botão de Ajuda (topo direito da bancada, opcional)
              if (onHelpTap != null)
                Positioned(
                  top: 20,
                  right: SecondBenchLayoutTokens.sidePanelWidth + 40,
                  child: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: SecondBenchLayoutTokens.darkGreen,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: SecondBenchLayoutTokens.primaryGreen,
                          width: 1.5,
                        ),
                        boxShadow: const [
                          BoxShadow(color: Colors.black45, blurRadius: 8),
                        ],
                      ),
                      child: const Icon(
                        Icons.help_outline_rounded,
                        color: SecondBenchLayoutTokens.primaryGreen,
                        size: 22,
                      ),
                    ),
                    tooltip: 'Como funciona esta fase?',
                    onPressed: onHelpTap,
                  ),
                ),

              // 4. Bancada + Painel Lateral lado a lado
              Positioned(
                top: 100,
                left: 28,
                right: 28,
                bottom: 88,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: workspace,
                      ),
                    ),
                    const SizedBox(width: SecondBenchLayoutTokens.sectionGap),
                    sidePanel,
                  ],
                ),
              ),

              // 5. Barra Inferior de Ações
              Positioned(
                left: 28,
                right: 28,
                bottom: 16,
                child: actionBar,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // LAYOUT MOBILE (< 850 px)
  // ==========================================
  Widget _buildMobileLayout(BuildContext context, BoxConstraints constraints) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PhaseIntroCard(
            phase: phase,
            title: title,
            instruction: instruction,
            icon: introIcon,
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 320,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: SecondBenchLayoutTokens.primaryGreen.withValues(alpha: 0.4),
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(backgroundAsset, fit: BoxFit.cover),
                  ),
                  Positioned.fill(child: workspace),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(height: 420, child: sidePanel),
          const SizedBox(height: 14),
          actionBar,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widget privado: cartão de título e instrução da fase.
// ---------------------------------------------------------------------------
class _PhaseIntroCard extends StatelessWidget {
  final int phase;
  final String title;
  final String instruction;
  final IconData icon;

  const _PhaseIntroCard({
    required this.phase,
    required this.title,
    required this.instruction,
    this.icon = Icons.menu_book_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SecondBenchLayoutTokens.primaryGreen.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: SecondBenchLayoutTokens.primaryGreen, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Fase $phase — $title',
                  style: const TextStyle(
                    fontFamily: 'Rajdhani',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            instruction,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
