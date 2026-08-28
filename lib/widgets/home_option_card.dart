import 'package:flutter/material.dart';
import 'package:eletrolab/app/theme.dart';
import 'glass_container.dart';

/// Modelo de uma opção do menu inicial.
@immutable
class HomeMenuOption {
  const HomeMenuOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    this.route,
    this.onTap,
    this.borderIndex = 0,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;

  /// Rota navegável a partir do cartão. Se nula, [onTap] é usado.
  final String? route;

  final VoidCallback? onTap;

  /// Índice para selecionar uma cor de borda variada da paleta EletroLab
  final int borderIndex;
}

/// Cartão do menu inicial do EletroLab com estilo Glassmorphism e profundidade visual.
class HomeOptionCard extends StatefulWidget {
  const HomeOptionCard({super.key, required this.option});

  final HomeMenuOption option;

  @override
  State<HomeOptionCard> createState() => _HomeOptionCardState();
}

class _HomeOptionCardState extends State<HomeOptionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final option = widget.option;
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark
        ? EletroLabColors.borderDarkColors[widget.option.borderIndex % EletroLabColors.borderDarkColors.length]
        : EletroLabColors.borderLightColors[widget.option.borderIndex % EletroLabColors.borderLightColors.length];

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: GlassContainer(
          accentColor: option.accentColor,
          opacity: _isHovered ? (isDark ? 0.85 : 0.9) : (isDark ? 0.6 : 0.75),
          borderWidth: _isHovered ? 1.8 : 1.2,
          padding: EdgeInsets.zero,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: option.onTap ??
                  (option.route != null
                      ? () => Navigator.of(context).pushNamed(option.route!)
                      : null),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Ícone com brilho Neon Circundante
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                option.accentColor.withValues(alpha: _isHovered ? 0.35 : 0.2),
                                option.accentColor.withValues(alpha: 0.08),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: borderColor.withValues(alpha: _isHovered ? 0.7 : 0.35),
                              width: 1.5,
                            ),
                            boxShadow: [
                              if (_isHovered)
                                BoxShadow(
                                  color: option.accentColor.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                ),
                            ],
                          ),
                          child: Icon(
                            option.icon,
                            color: option.accentColor,
                            size: 28,
                          ),
                        ),
                        // Badge / Arrow Tecnológico
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _isHovered
                                ? option.accentColor.withValues(alpha: 0.2)
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
                                ? option.accentColor
                                : scheme.onSurfaceVariant.withValues(alpha: 0.4),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      option.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      option.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}