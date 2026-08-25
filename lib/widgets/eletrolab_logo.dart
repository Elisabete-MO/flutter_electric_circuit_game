import 'package:flutter/material.dart';
import '../app/theme.dart';

/// Identidade visual do EletroLab: ícone de raio azul com pulso neon e o nome do
/// aplicativo alinhado horizontalmente, além de subtítulo tecnológico opcional.
class EletroLabLogo extends StatefulWidget {
  const EletroLabLogo({super.key, this.compact = false});

  /// Modo compacto reduz o tamanho do ícone/texto e oculta o subtítulo.
  final bool compact;

  @override
  State<EletroLabLogo> createState() => _EletroLabLogoState();
}

class _EletroLabLogoState extends State<EletroLabLogo> with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
      lowerBound: 0.4,
      upperBound: 1.0,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final iconSize = widget.compact ? 36.0 : 64.0;
    final titleStyle = widget.compact
        ? theme.textTheme.headlineSmall
        : theme.textTheme.displayMedium;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            final glowValue = _glowController.value;
            return Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Raio Azul com Brilho Neon Pulsante
                Icon(
                  Icons.bolt_rounded,
                  color: EletroLabColors.neonCyan, // Azul Neon / Cyan
                  size: iconSize,
                  shadows: [
                    Shadow(
                      color: EletroLabColors.electricBlue.withValues(alpha: glowValue * 0.8),
                      blurRadius: 10 + glowValue * 15,
                    ),
                    Shadow(
                      color: EletroLabColors.neonCyan.withValues(alpha: glowValue * 0.6),
                      blurRadius: 20 + glowValue * 25,
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                // Texto EletroLab com Brilho Neon (no modo escuro)
                Text(
                  'EletroLab',
                  style: titleStyle?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    shadows: [
                      if (isDark) ...[
                        Shadow(
                          color: EletroLabColors.neonCyan.withValues(alpha: glowValue * 0.4),
                          blurRadius: 8 + glowValue * 8,
                        ),
                        Shadow(
                          color: EletroLabColors.neonPurple.withValues(alpha: glowValue * 0.3),
                          blurRadius: 16 + glowValue * 12,
                        ),
                      ] else ...[
                        Shadow(
                          color: EletroLabColors.electricBlue.withValues(alpha: 0.15),
                          blurRadius: 6,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        if (!widget.compact) ...[
          const SizedBox(height: 8),
          Text(
            'LABORATÓRIO VIRTUAL DE CIRCUITOS',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              letterSpacing: 2.0,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
