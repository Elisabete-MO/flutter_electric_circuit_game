import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../models/first_step_component.dart';
import 'circuit_symbol_painter.dart';

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

/// Seletor de Modo de Visualização Unificado (Físico vs Diagrama Esquemático)
class ModeToggleSwitch extends StatelessWidget {
  const ModeToggleSwitch({
    super.key,
    required this.isDiagramMode,
    required this.onChanged,
    this.isCompact = false,
  });

  final bool isDiagramMode;
  final ValueChanged<bool> onChanged;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;
    final isEn = locale == 'en';

    final horizontalPadding = isCompact ? 10.0 : 14.0;
    final verticalPadding = isCompact ? 6.0 : 9.5;
    final iconSize = isCompact ? 15.0 : 17.0;
    final fontSize = isCompact ? 11.0 : 13.0;

    return Container(
      padding: isCompact ? EdgeInsets.zero : const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isDark ? Colors.black54 : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(isCompact ? 20 : 24),
        border: Border.all(
          color: isDark
              ? const Color(0xFF00F5D4).withValues(alpha: 0.4)
              : const Color(0xFF00F5D4),
          width: isCompact ? 1.2 : 1.5,
        ),
        boxShadow: isCompact
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF00F5D4).withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => onChanged(false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              decoration: BoxDecoration(
                color: !isDiagramMode
                    ? const Color(0xFF00F5D4)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(isCompact ? 16 : 20),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.view_in_ar_rounded,
                    size: iconSize,
                    color: !isDiagramMode
                        ? Colors.black
                        : (isDark ? Colors.white70 : Colors.black87),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    isEn ? 'Physical' : 'Físico',
                    style: TextStyle(
                      fontFamily: GoogleFonts.rajdhani().fontFamily,
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: !isDiagramMode
                          ? Colors.black
                          : (isDark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(true),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              decoration: BoxDecoration(
                color: isDiagramMode
                    ? const Color(0xFF00F5D4)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(isCompact ? 16 : 20),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schema_outlined,
                    size: iconSize,
                    color: isDiagramMode
                        ? Colors.black
                        : (isDark ? Colors.white70 : Colors.black87),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    isEn ? 'Diagram' : 'Diagrama',
                    style: TextStyle(
                      fontFamily: GoogleFonts.rajdhani().fontFamily,
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: isDiagramMode
                          ? Colors.black
                          : (isDark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dock Flutuante de Ações Inferior Cyberpunk HUD
class FloatingActionDock extends StatelessWidget {
  const FloatingActionDock({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1424).withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isDark ? const Color(0xFF00F5D4).withValues(alpha: 0.3) : const Color(0xFF00F5D4).withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFF00F5D4) : Colors.black).withValues(alpha: 0.15),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: children,
      ),
    );
  }
}

/// Card de Símbolo Arrastável para a Paleta de Símbolos Esquémáticos (sem rótulos de texto)
class DraggableSymbolCard extends StatelessWidget {
  const DraggableSymbolCard({
    super.key,
    required this.type,
    required this.isVerticalList,
    required this.onTap,
  });

  final ComponentType type;
  final bool isVerticalList;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardContent = Container(
      width: isVerticalList ? 96 : 74,
      height: 52,
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : const Color(0xFFCBD5E1),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: const Size(54, 30),
          painter: CircuitSymbolPainter(
            type: type,
            color: isDark ? const Color(0xFF00F5D4) : const Color(0xFF0F172A),
            strokeWidth: 2,
          ),
        ),
      ),
    );

    return Draggable<ComponentType>(
      affinity: isVerticalList ? Axis.horizontal : Axis.vertical,
      data: type,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.85,
          child: cardContent,
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: cardContent,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: cardContent,
      ),
    );
  }
}

/// Dock Flutuante de Símbolos Esquemáticos ("SÍMBOLOS")
class SymbolsDockPanel extends StatelessWidget {
  const SymbolsDockPanel({
    super.key,
    required this.isVertical,
    required this.symbolTypes,
    required this.onTapSymbol,
    required this.l10n,
    this.verticalScrollController,
    this.horizontalScrollController,
  });

  final bool isVertical;
  final List<ComponentType> symbolTypes;
  final ValueChanged<ComponentType> onTapSymbol;
  final AppLocalizations l10n;
  final ScrollController? verticalScrollController;
  final ScrollController? horizontalScrollController;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final symbolCards = symbolTypes.map((type) {
      return DraggableSymbolCard(
        type: type,
        isVerticalList: isVertical,
        onTap: () => onTapSymbol(type),
      );
    }).toList();

    if (isVertical) {
      return Container(
        width: 116,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF0F172A).withValues(alpha: 0.92)
              : Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? const Color(0xFF00F5D4).withValues(alpha: 0.3)
                : const Color(0xFF00F5D4).withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 6),
              child: Text(
                l10n.symbolsPaletteTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: GoogleFonts.rajdhani().fontFamily,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 1.5,
                  color: isDark ? const Color(0xFF00F5D4) : const Color(0xFF0F172A),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                controller: verticalScrollController,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                children: symbolCards,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        height: 88,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF0F172A).withValues(alpha: 0.92)
              : Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? const Color(0xFF00F5D4).withValues(alpha: 0.3)
                : const Color(0xFF00F5D4).withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 2),
              child: Text(
                l10n.symbolsPaletteTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: GoogleFonts.rajdhani().fontFamily,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 1.5,
                  color: isDark ? const Color(0xFF00F5D4) : const Color(0xFF0F172A),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                controller: horizontalScrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                children: symbolCards,
              ),
            ),
          ],
        ),
      );
    }
  }
}


