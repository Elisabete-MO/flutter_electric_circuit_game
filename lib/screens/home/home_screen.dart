import 'package:flutter/material.dart';
import 'package:eletrolab/app/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/routes.dart';
import '../../l10n/app_localizations.dart';
import '../../state/progress_controller.dart';
import '../../widgets/cyber_hud_container.dart';
import '../../widgets/eletrolab_logo.dart';
import '../../widgets/prof_volts_speech.dart';
import '../../widgets/tech_grid_background.dart';

/// Tela inicial do EletroLab: EstaÃ§Ã£o Cyber HUD com Dashboard e estatÃ­sticas do jogador.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final progress = ref.watch(progressControllerProvider);

    // Calcular estatÃ­sticas
    final completedCount = progress.completedChallenges.length;
    final totalStars = progress.challengeStars.values.fold<int>(
      0,
      (sum, stars) => sum + stars,
    );

    return Scaffold(
      body: TechGridBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // BARRA SUPERIOR HUD DE STATUS & ESTRELAS
                    _buildHudStatusBar(
                      context,
                      totalStars,
                      completedCount,
                      isDark,
                    ),
                    const SizedBox(height: 24),

                    // LOGO ELETROLAB
                    const Center(child: EletroLabLogo()),
                    const SizedBox(height: 24),

                    // SAUDAÃ‡ÃƒO DO PROF. VOLTS
                    ProfVoltsSpeech(
                      text: completedCount == 0
                          ? 'Bem-vindo ao EletroLab! Comece pelo tutorial de "Primeiros Passos" ou encare o primeiro desafio.'
                          : completedCount == 3
                          ? 'ParabÃ©ns, Engenheiro! VocÃª completou todos os desafios com sucesso. Continue praticando na Bancada Livre!'
                          : 'Excelente progresso! VocÃª jÃ¡ concluiu $completedCount de 3 desafios. Continue acelerando!',
                    ),
                    const SizedBox(height: 28),

                    // GRID DE OPÃ‡Ã•ES BENTO STYLED
                    _buildBentoGrid(context, l10n, completedCount),
                    const SizedBox(height: 32),

                    // RODAPÃ‰
                    Center(
                      child: Text(
                        'ELETROLAB CYBER STATION • v1.0.0',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.7,
                          ),
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHudStatusBar(
    BuildContext context,
    int totalStars,
    int completedCount,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      runSpacing: 12,
      children: [
        // HUD de Estrelas Ganhas
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFFFFB300).withValues(alpha: 0.15)
                : const Color(0xFFFFB300).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFFB300).withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFFFB300),
                size: 18,
                shadows: [BoxShadow(color: Color(0xFFFFB300), blurRadius: 8)],
              ),
              const SizedBox(width: 6),
              Text(
                '$totalStars / 9 ESTRELAS',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: isDark
                      ? const Color(0xFFFFB300)
                      : const Color(0xFFB58100),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBentoGrid(
    BuildContext context,
    AppLocalizations l10n,
    int completedCount,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 760;
        final medium =
            constraints.maxWidth >= 500 && constraints.maxWidth < 760;
        final gap = 16.0;

        _CyberMenuCard buildCard({
          required String title,
          required String description,
          required String tag,
          required IconData icon,
          required Color accentColor,
          required VoidCallback onTap,
          double? height,
          borderIndex = 0,
        }) {
          return _CyberMenuCard(
            title: title,
            description: description,
            tag: tag,
            icon: icon,
            accentColor: accentColor,
            onTap: onTap,
            borderIndex: borderIndex,
            height: height,
          );
        }

        _CyberMenuCard cardTutorial(double? h) => buildCard(
          title: l10n.menuFirstSteps,
          description: l10n.menuFirstStepsDesc,
          tag: 'PASSO A PASSO',
          icon: Icons.flash_on_rounded,
          accentColor: EletroLabColors.amber,
          onTap: () => Navigator.of(context).pushNamed(Routes.firstSteps),
          height: h,
          borderIndex: 0,
        );

        _CyberMenuCard cardCampaign(double? h) => buildCard(
          title: l10n.menuChallenges,
          description: l10n.menuChallengesDesc,
          tag: 'DESAFIOS ($completedCount/3)',
          icon: Icons.science_rounded,
          accentColor: EletroLabColors.electricBlue,
          onTap: () => Navigator.of(context).pushNamed(Routes.challenges),
          height: h,
          borderIndex: 1,
        );

        _CyberMenuCard cardSandbox(double? h) => buildCard(
          title: l10n.menuSandbox,
          description: l10n.menuSandboxDesc,
          tag: 'LABORATÃ“RIO LIVRE 3D',
          icon: Icons.biotech_rounded,
          accentColor: EletroLabColors.neonCyan,
          onTap: () => Navigator.of(context).pushNamed(Routes.sandbox),
          height: h,
          borderIndex: 2,
        );

        _CyberMenuCard cardSettings(double? h) => buildCard(
          title: l10n.menuSettings,
          description: l10n.menuSettingsDesc,
          tag: 'SISTEMA',
          icon: Icons.settings_rounded,
          accentColor: EletroLabColors.success,
          onTap: () => Navigator.of(context).pushNamed(Routes.settings),
          height: h,
          borderIndex: 3,
        );

        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: cardTutorial(245)),
              SizedBox(width: gap),
              Expanded(child: cardCampaign(245)),
              SizedBox(width: gap),
              Expanded(child: cardSandbox(245)),
              SizedBox(width: gap),
              Expanded(child: cardSettings(245)),
            ],
          );
        }

        if (medium) {
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: cardTutorial(225)),
                  SizedBox(width: gap),
                  Expanded(child: cardCampaign(225)),
                ],
              ),
              SizedBox(height: gap),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: cardSandbox(225)),
                  SizedBox(width: gap),
                  Expanded(child: cardSettings(225)),
                ],
              ),
            ],
          );
        }

        return Column(
          children: [
            cardTutorial(null),
            SizedBox(height: gap),
            cardCampaign(null),
            SizedBox(height: gap),
            cardSandbox(null),
            SizedBox(height: gap),
            cardSettings(null),
          ],
        );
      },
    );
  }
}

/// CartÃ£o Bento TecnolÃ³gico Cyber com Tag HUD e Efeitos Neon Interativos.
class _CyberMenuCard extends StatefulWidget {
  const _CyberMenuCard({
    required this.title,
    required this.description,
    required this.tag,
    required this.icon,
    required this.accentColor,
    required this.onTap,
    this.borderIndex = 0,
    this.height,
  });

  final String title;
  final String description;
  final String tag;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;
  final int borderIndex;
  final double? height;

  @override
  State<_CyberMenuCard> createState() => _CyberMenuCardState();
}

class _CyberMenuCardState extends State<_CyberMenuCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark
        ? EletroLabColors.borderDarkColors[widget.borderIndex %
              EletroLabColors.borderDarkColors.length]
        : EletroLabColors.borderLightColors[widget.borderIndex %
              EletroLabColors.borderLightColors.length];

    return CyberHudContainer(
      accentColor: widget.accentColor,
      onTap: widget.onTap,
      onHoverChanged: (hovered) => setState(() => _isHovered = hovered),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      height: widget.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Row: Tag HUD + Ãcone Neon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Spacer(),
              // Ãcone com brilho Neon
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.accentColor.withValues(
                        alpha: _isHovered ? 0.35 : 0.2,
                      ),
                      widget.accentColor.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: borderColor.withValues(
                      alpha: _isHovered ? 0.7 : 0.35,
                    ),
                    width: 1.5,
                  ),
                  boxShadow: [
                    if (_isHovered)
                      BoxShadow(
                        color: widget.accentColor.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                  ],
                ),
                child: Icon(widget.icon, color: widget.accentColor, size: 26),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // TÃ­tulo
          Text(
            widget.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),

          // DescriÃ§Ã£o
          Text(
            widget.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),

          // RodapÃ©: Seta AÃ§Ã£o
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _isHovered
                      ? widget.accentColor.withValues(alpha: 0.2)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _isHovered
                        ? borderColor.withValues(alpha: 0.6)
                        : Colors.transparent,
                  ),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: _isHovered
                      ? widget.accentColor
                      : scheme.onSurfaceVariant.withValues(alpha: 0.4),
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
