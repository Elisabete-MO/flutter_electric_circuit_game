import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';

/// Constantes nomeadas de layout para posições, offsets e dimensões de componentes de circuitos
abstract final class ChallengeLayoutConstants {
  static const double wireStrokeWidth = 3.5;
  static const double diagramWireStrokeWidth = 3.0;
  static const double particleRadius = 3.0;
  static const double particleGlowRadius = 5.0;

  // Offsets proporcionais padrão dos componentes físicos em relação às dimensões da bancada
  static const double batteryXFactor = 0.18;
  static const double batteryYOffset = -30.0;
  
  static const double topComponentXFactor = 0.20;
  static const double topComponentYFactor = -0.22;

  static const double bottomComponentXFactor = 0.20;
  static const double bottomComponentYFactor = 0.22;

  static const Size physicalComponentSize = Size(140, 90);
  static const Size batteryPhysicalSize = Size(120, 100);
}

/// Widget contendo o botão de alternância do diagrama elétrico em estilo cápsula glassmorphic
class DiagramToggleButton extends StatelessWidget {
  const DiagramToggleButton({
    super.key,
    required this.showDiagramMode,
    required this.onTap,
    required this.pulseAnimation,
  });

  final bool showDiagramMode;
  final VoidCallback onTap;
  final Animation<double> pulseAnimation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = showDiagramMode ? const Color(0xFFFF5252) : const Color(0xFF00B8D4);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: pulseAnimation,
        builder: (context, child) {
          final scale = 1.0 + (pulseAnimation.value * 0.04);

          return Transform.scale(
            scale: scale,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: showDiagramMode
                      ? [const Color(0xFFFF5252), const Color(0xFFFF1744)]
                      : [const Color(0xFF3B82F6), const Color(0xFF00B8D4)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(
                      alpha: 0.35 + (pulseAnimation.value * 0.35),
                    ),
                    blurRadius: 16 + (pulseAnimation.value * 8),
                    spreadRadius: 1 + (pulseAnimation.value * 2),
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: isDark ? 0.35 : 0.6),
                  width: 1.5,
                ),
              ),
              child: Text(
                showDiagramMode ? 'Fechar Diagrama' : l10n.circuitDiagramButton,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: GoogleFonts.rajdhani().fontFamily,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Botão de ação secundário do diagrama (Verificar, Reiniciar, etc) em estilo cápsula glassmorphic
class DiagramActionButton extends StatelessWidget {
  const DiagramActionButton({
    super.key,
    this.icon,
    required this.label,
    required this.onTap,
    this.gradientColors,
    this.accentColor,
  });

  final IconData? icon;
  final String label;
  final VoidCallback onTap;
  final List<Color>? gradientColors;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultGradient = [const Color(0xFF10B981), const Color(0xFF059669)];
    final colors = gradientColors ?? defaultGradient;
    final shadowColor = accentColor ?? colors.first;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withValues(alpha: 0.35),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.white.withValues(alpha: isDark ? 0.35 : 0.6),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontFamily: GoogleFonts.rajdhani().fontFamily,
            fontWeight: FontWeight.bold,
            fontSize: 15,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}

/// Widget de crachá de cronômetro no canto superior direito para o modo diagrama
class ChallengeTimerBadge extends StatelessWidget {
  const ChallengeTimerBadge({super.key, required this.elapsedSeconds});

  final int elapsedSeconds;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final m = (elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (elapsedSeconds % 60).toString().padLeft(2, '0');

    return Align(
      alignment: Alignment.topRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF00F0FF).withValues(alpha: 0.15)
              : const Color(0xFF0066FF).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? const Color(0xFF00F0FF).withValues(alpha: 0.4)
                : const Color(0xFF0066FF).withValues(alpha: 0.3),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer_rounded,
              size: 16,
              color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0066FF),
            ),
            const SizedBox(width: 6),
            Text(
              '$m:$s',
              style: TextStyle(
                fontFamily: GoogleFonts.rajdhani().fontFamily,
                color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0066FF),
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


