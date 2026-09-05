import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'stand_flow_tokens.dart';

/// Scaffold estrutural e visual reutilizável para as missões dos estandes.
/// Mantém as mesmas proporções de bancada (desktop 1600x900 / 1440x810 com FittedBox e mobile adaptável).
class StandFlowScaffold extends StatelessWidget {
  final int missionNumber;
  final String title;
  final String instruction;
  final IconData introIcon;
  final Widget workspace;
  final Widget sidePanel;
  final Widget actionBar;
  final String backgroundAsset;
  final VoidCallback? onHelpTap;

  const StandFlowScaffold({
    super.key,
    required this.missionNumber,
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
      backgroundColor: StandFlowTokens.bgDark,
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

  Widget _buildDesktopLayout(BuildContext context, BoxConstraints constraints) {
    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: StandFlowTokens.desktopMaxWidth,
          height: StandFlowTokens.desktopMaxHeight,
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
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF021712),
                    ),
                  ),
                ),
              ),

              // 2. Cartão de Título e Instrução (topo esquerdo)
              Positioned(
                top: 20,
                left: 28,
                width: StandFlowTokens.introMaxWidth,
                child: _MissionIntroCard(
                  missionNumber: missionNumber,
                  title: title,
                  instruction: instruction,
                  icon: introIcon,
                ),
              ),

              // 3. Botão de Ajuda (topo direito da bancada)
              if (onHelpTap != null)
                Positioned(
                  top: 20,
                  right: StandFlowTokens.sidePanelWidth + 40,
                  child: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: StandFlowTokens.darkGreen,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: StandFlowTokens.primaryGreen,
                          width: 1.5,
                        ),
                        boxShadow: const [
                          BoxShadow(color: Colors.black45, blurRadius: 8),
                        ],
                      ),
                      child: const Icon(
                        Icons.help_outline_rounded,
                        color: StandFlowTokens.primaryGreen,
                        size: 22,
                      ),
                    ),
                    tooltip: 'Como funciona esta missão?',
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
                    const SizedBox(width: StandFlowTokens.sectionGap),
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

  Widget _buildMobileLayout(BuildContext context, BoxConstraints constraints) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MissionIntroCard(
            missionNumber: missionNumber,
            title: title,
            instruction: instruction,
            icon: introIcon,
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 340,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: StandFlowTokens.primaryGreen.withValues(alpha: 0.4),
                ),
              ),
              child: workspace,
            ),
          ),
          const SizedBox(height: 12),
          sidePanel,
          const SizedBox(height: 12),
          actionBar,
        ],
      ),
    );
  }
}

class _MissionIntroCard extends StatelessWidget {
  final int missionNumber;
  final String title;
  final String instruction;
  final IconData icon;

  const _MissionIntroCard({
    required this.missionNumber,
    required this.title,
    required this.instruction,
    this.icon = Icons.menu_book_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: StandFlowTokens.primaryGreen.withValues(alpha: 0.4),
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
              Icon(icon, color: StandFlowTokens.accentGreen, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Missão $missionNumber — $title',
                  style: TextStyle(
                    fontFamily: GoogleFonts.rajdhani().fontFamily,
                    fontSize: 22,
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
              fontFamily: GoogleFonts.outfit().fontFamily,
              fontSize: 13.5,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
