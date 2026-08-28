import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/first_step_component.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/component_physical_painter.dart';
import '../../../widgets/circuit_symbol_painter.dart';

class SandboxToolboxWidget extends StatelessWidget {
  final bool isHorizontal;
  final bool isDark;
  final bool isDiagramMode;
  final String Function(ComponentType, AppLocalizations) getComponentName;

  const SandboxToolboxWidget({
    super.key,
    this.isHorizontal = false,
    required this.isDark,
    required this.isDiagramMode,
    required this.getComponentName,
  });

  List<ComponentType> get _availableTypes => const [
        ComponentType.battery,
        ComponentType.powerSupply,
        ComponentType.switchComponent,
        ComponentType.bulb,
        ComponentType.resistor,
        ComponentType.potentiometer,
        ComponentType.motor,
        ComponentType.led,
        ComponentType.diode,
        ComponentType.fuse,
        ComponentType.capacitor,
        ComponentType.buzzer,
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (isHorizontal) {
      return GlassContainer(
        borderRadius: 16,
        opacity: isDark ? 0.35 : 0.6,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.symbolsPaletteTitle,
              style: GoogleFonts.rajdhani(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _availableTypes.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 90,
                    child: _buildToolboxItem(_availableTypes[index], l10n, compact: true),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    return GlassContainer(
      borderRadius: 16,
      opacity: isDark ? 0.35 : 0.6,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.symbolsPaletteTitle,
            style: GoogleFonts.rajdhani(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              letterSpacing: 1.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: _availableTypes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return _buildToolboxItem(_availableTypes[index], l10n);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolboxItem(ComponentType type, AppLocalizations l10n, {bool compact = false}) {
    final name = getComponentName(type, l10n);

    Widget buildCard({Color? bgColor, Color? borderColor, double fontSize = 10}) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        decoration: BoxDecoration(
          color: bgColor ?? (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: borderColor ?? (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AspectRatio(
              aspectRatio: compact ? 2.0 : 1.8,
              child: CustomPaint(
                painter: isDiagramMode
                    ? CircuitSymbolPainter(
                        type: type,
                        isActive: false,
                        color: isDark ? const Color(0xFF00F5D4) : Colors.black87,
                        activeColor: const Color(0xFFFFB300),
                        strokeWidth: 2.0,
                      )
                    : ComponentPhysicalPainter(
                        type: type,
                        isActive: false,
                        isDarkMode: isDark,
                      ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              name,
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }

    final itemWidget = buildCard();

    final feedbackWidget = Material(
      color: Colors.transparent,
      child: SizedBox(
        width: 88,
        height: 88,
        child: Opacity(
          opacity: 0.85,
          child: buildCard(
            bgColor: isDark ? Colors.white.withValues(alpha: 0.14) : Colors.white.withValues(alpha: 0.9),
            borderColor: const Color(0xFF00F5D4),
            fontSize: 10,
          ),
        ),
      ),
    );

    return Draggable<ComponentType>(
      data: type,
      feedback: feedbackWidget,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      childWhenDragging: Opacity(opacity: 0.35, child: itemWidget),
      child: itemWidget,
    );
  }
}
