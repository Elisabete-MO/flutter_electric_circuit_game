import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/ui_scale.dart';
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
    final scale = context.uiScale;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: pulseAnimation,
        builder: (context, child) {
          final animScale = 1.0 + (pulseAnimation.value * 0.04);

          return Transform.scale(
            scale: animScale,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(
                horizontal: scale.spacing(18, min: 14, max: 32),
                vertical: scale.spacing(12, min: 8, max: 20),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: showDiagramMode
                      ? [const Color(0xFFFF5252), const Color(0xFFFF1744)]
                      : [const Color(0xFF3B82F6), const Color(0xFF00B8D4)],
                ),
                borderRadius: BorderRadius.circular(scale.size(24, min: 18, max: 36)),
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
                  fontSize: scale.font(15, min: 13, max: 24),
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
    final scale = context.uiScale;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(
          horizontal: scale.spacing(20, min: 14, max: 36),
          vertical: scale.spacing(12, min: 8, max: 22),
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(scale.size(24, min: 18, max: 36)),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withValues(alpha: 0.35),
              blurRadius: scale.size(12, min: 8, max: 20),
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
            fontSize: scale.font(15, min: 13, max: 24),
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
    final scale = context.uiScale;

    return Align(
      alignment: Alignment.topRight,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: scale.spacing(14, min: 10, max: 24),
          vertical: scale.spacing(7, min: 5, max: 14),
        ),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF00F0FF).withValues(alpha: 0.15)
              : const Color(0xFF0066FF).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(scale.size(16, min: 12, max: 24)),
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
              size: scale.icon(16, min: 14, max: 26),
              color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0066FF),
            ),
            SizedBox(width: scale.spacing(6, min: 4, max: 10)),
            Text(
              '$m:$s',
              style: TextStyle(
                fontFamily: GoogleFonts.rajdhani().fontFamily,
                color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0066FF),
                fontWeight: FontWeight.bold,
                fontSize: scale.font(14, min: 12, max: 22),
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
    final scale = context.uiScale;

    final horizontalPadding = isCompact
        ? scale.spacing(10.0, min: 8.0, max: 16.0)
        : scale.spacing(14.0, min: 10.0, max: 24.0);
    final verticalPadding = isCompact
        ? scale.spacing(6.0, min: 4.0, max: 10.0)
        : scale.spacing(9.5, min: 6.0, max: 15.0);
    final iconSize = isCompact
        ? scale.icon(15.0, min: 13.0, max: 22.0)
        : scale.icon(17.0, min: 14.0, max: 26.0);
    final fontSize = isCompact
        ? scale.font(11.0, min: 10.0, max: 16.0)
        : scale.font(13.0, min: 11.5, max: 20.0);

    return Container(
      padding: isCompact ? EdgeInsets.zero : const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isDark ? Colors.black54 : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(scale.size(isCompact ? 20 : 24, min: 16, max: 36)),
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
                  blurRadius: scale.size(8, min: 5, max: 14),
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
                borderRadius: BorderRadius.circular(scale.size(isCompact ? 16 : 20, min: 12, max: 28)),
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
                  SizedBox(width: scale.spacing(5, min: 3, max: 8)),
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
                borderRadius: BorderRadius.circular(scale.size(isCompact ? 16 : 20, min: 12, max: 28)),
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
                  SizedBox(width: scale.spacing(5, min: 3, max: 8)),
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
    final scale = context.uiScale;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: scale.spacing(16, min: 12, max: 28),
        vertical: scale.spacing(8, min: 6, max: 16),
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1424).withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(scale.size(30, min: 20, max: 44)),
        border: Border.all(
          color: isDark ? const Color(0xFF00F5D4).withValues(alpha: 0.3) : const Color(0xFF00F5D4).withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFF00F5D4) : Colors.black).withValues(alpha: 0.15),
            blurRadius: scale.size(16, min: 10, max: 24),
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Wrap(
        spacing: scale.spacing(12, min: 8, max: 20),
        runSpacing: scale.spacing(8, min: 6, max: 14),
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
    final scale = context.uiScale;

    final cardWidth = isVerticalList
        ? scale.size(96, min: 72, max: 140)
        : scale.size(74, min: 58, max: 110);
    final cardHeight = scale.size(52, min: 42, max: 80);

    final cardContent = Container(
      width: cardWidth,
      height: cardHeight,
      margin: const EdgeInsets.all(4),
      padding: EdgeInsets.all(scale.spacing(6, min: 4, max: 10)),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2F6),
        borderRadius: BorderRadius.circular(scale.size(12, min: 8, max: 18)),
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
          size: Size(cardWidth * 0.6, cardHeight * 0.6),
          painter: CircuitSymbolPainter(
            type: type,
            color: isDark ? const Color(0xFF00F5D4) : const Color(0xFF0F172A),
            strokeWidth: scale.size(2, min: 1.5, max: 3.5),
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
    final scale = context.uiScale;

    final symbolCards = symbolTypes.map((type) {
      return DraggableSymbolCard(
        type: type,
        isVerticalList: isVertical,
        onTap: () => onTapSymbol(type),
      );
    }).toList();

    if (isVertical) {
      return Container(
        width: scale.size(116, min: 90, max: 170),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF0F172A).withValues(alpha: 0.92)
              : Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(scale.size(20, min: 14, max: 30)),
          border: Border.all(
            color: isDark
                ? const Color(0xFF00F5D4).withValues(alpha: 0.3)
                : const Color(0xFF00F5D4).withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: scale.size(14, min: 8, max: 22),
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: scale.spacing(10, min: 6, max: 16),
                bottom: scale.spacing(6, min: 4, max: 10),
              ),
              child: Text(
                l10n.symbolsPaletteTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: GoogleFonts.rajdhani().fontFamily,
                  fontWeight: FontWeight.bold,
                  fontSize: scale.font(13, min: 11, max: 20),
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
        height: scale.size(88, min: 72, max: 130),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF0F172A).withValues(alpha: 0.92)
              : Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(scale.size(20, min: 14, max: 30)),
          border: Border.all(
            color: isDark
                ? const Color(0xFF00F5D4).withValues(alpha: 0.3)
                : const Color(0xFF00F5D4).withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: scale.size(14, min: 8, max: 22),
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: scale.spacing(6, min: 4, max: 10),
                bottom: scale.spacing(2, min: 2, max: 6),
              ),
              child: Text(
                l10n.symbolsPaletteTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: GoogleFonts.rajdhani().fontFamily,
                  fontWeight: FontWeight.bold,
                  fontSize: scale.font(11, min: 10, max: 17),
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


