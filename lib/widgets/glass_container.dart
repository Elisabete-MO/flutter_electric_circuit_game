import 'dart:ui';
import 'package:flutter/material.dart';

/// Container com efeito Glassmorphism (vidro fosco) responsivo e sombreamento volumétrico.
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.blur = 12,
    this.enableBlur = true,
    this.opacity = 0.6,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.accentColor,
    this.borderWidth = 2.2,
    this.width,
    this.height,
    this.borderGlowOnly = false,
    this.baseColor,
  });

  final Widget child;
  final double borderRadius;
  final double blur;
  final bool enableBlur;
  final double opacity;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? accentColor;
  final double borderWidth;
  final double? width;
  final double? height;
  final bool borderGlowOnly;
  final Color? baseColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final resolvedBaseColor = baseColor ?? (isDark ? const Color(0xFF0D1424) : Colors.white);
    final glowColor = accentColor ?? theme.colorScheme.primary;

    final effectiveBorderColor = accentColor != null
        ? accentColor!.withValues(alpha: isDark ? 0.6 : 0.35)
        : (isDark
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.grey.withValues(alpha: 0.25));

    final innerContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: resolvedBaseColor.withValues(alpha: enableBlur ? opacity : opacity + 0.15),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: effectiveBorderColor,
          width: borderWidth,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  (accentColor ?? Colors.white).withValues(alpha: 0.10),
                  Colors.white.withValues(alpha: 0.02),
                ]
              : [
                  Colors.white.withValues(alpha: 0.9),
                  Colors.white.withValues(alpha: 0.5),
                ],
        ),
      ),
      child: child,
    );

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          // Sombra de Profundidade Base
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.6)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            spreadRadius: isDark ? 1 : 2,
            offset: const Offset(0, 10),
          ),
          // Sombra Neon Volumétrica Iluminada
          if (accentColor != null) ...[
            if (borderGlowOnly) ...[
              BoxShadow(
                color: glowColor.withValues(alpha: isDark ? 0.20 : 0.12),
                blurRadius: 8,
                spreadRadius: 0.2,
              ),
            ] else ...[
              BoxShadow(
                color: glowColor.withValues(alpha: isDark ? 0.15 : 0.08),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: glowColor.withValues(alpha: isDark ? 0.08 : 0.04),
                blurRadius: 36,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ],
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: enableBlur && blur > 0
            ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: innerContent,
              )
            : innerContent,
      ),
    );
  }
}
