import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/theme.dart';
import '../l10n/app_localizations.dart';
import 'electrical_calculator.dart';

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

// ─────────────────────────────────────────────────────────────────────────────
/// Painel lateral retrátil da Calculadora Elétrica.
/// Expandido: calculadora completa (280px).
/// Recolhido: aba vertical fina com ícone clicável (48px).
class CalculatorSidePanel extends StatefulWidget {
  const CalculatorSidePanel({super.key});

  @override
  State<CalculatorSidePanel> createState() => _CalculatorSidePanelState();
}

class _CalculatorSidePanelState extends State<CalculatorSidePanel> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = EletroLabColors.electricBlue.withValues(alpha: 0.22);
    final bgColor = isDark ? const Color(0xFF080C1A) : const Color(0xFFF0F4FF);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
      width: _expanded ? 280 : 48,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          left: BorderSide(color: borderColor, width: 1.5),
        ),
      ),
      child: _expanded ? _buildExpanded(isDark) : _buildCollapsed(isDark),
    );
  }

  // ── Estado expandido ────────────────────────────────────────────────────────
  Widget _buildExpanded(bool isDark) {
    return Column(
      children: [
        // Cabeçalho com botão de recolher
        GestureDetector(
          onTap: () => setState(() => _expanded = false),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: EletroLabColors.electricBlue
                  .withValues(alpha: isDark ? 0.12 : 0.08),
              border: Border(
                bottom: BorderSide(
                  color: EletroLabColors.electricBlue.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calculate_rounded,
                  size: 15,
                  color: EletroLabColors.electricBlue,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'CALCULADORA',
                    style: TextStyle(
                      fontFamily: GoogleFonts.rajdhani().fontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 1.5,
                      color: EletroLabColors.electricBlue,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: EletroLabColors.electricBlue.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
        // Calculadora com scroll
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: const ElectricalCalculatorWidget(),
          ),
        ),
      ],
    );
  }

  // ── Estado recolhido ────────────────────────────────────────────────────────
  Widget _buildCollapsed(bool isDark) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = true),
      child: Tooltip(
        message: 'Abrir calculadora',
        preferBelow: false,
        child: Container(
          width: 48,
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calculate_rounded,
                size: 22,
                color: EletroLabColors.electricBlue,
              ),
              const SizedBox(height: 8),
              RotatedBox(
                quarterTurns: 3,
                child: Text(
                  'CALCULADORA',
                  style: TextStyle(
                    fontFamily: GoogleFonts.rajdhani().fontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 1.4,
                    color: EletroLabColors.electricBlue
                        .withValues(alpha: 0.8),
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
