import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/ui_scale.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/first_step_component.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/component_physical_painter.dart';
import '../../../widgets/circuit_symbol_painter.dart';

class SandboxToolboxWidget extends StatelessWidget {
  final bool isHorizontal;
  final bool isDark;
  final bool isDiagramMode;
  final bool useRealisticAssets;
  final String Function(ComponentType, AppLocalizations) getComponentName;

  const SandboxToolboxWidget({
    super.key,
    this.isHorizontal = false,
    required this.isDark,
    required this.isDiagramMode,
    this.useRealisticAssets = true,
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
    final scale = context.uiScale;

    if (isHorizontal) {
      return GlassContainer(
        borderRadius: scale.size(16, min: 12, max: 24),
        opacity: isDark ? 0.35 : 0.6,
        padding: EdgeInsets.symmetric(
          vertical: scale.spacing(8, min: 6, max: 14),
          horizontal: scale.spacing(12, min: 8, max: 20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.symbolsPaletteTitle,
              style: GoogleFonts.rajdhani(
                fontWeight: FontWeight.bold,
                fontSize: scale.font(14, min: 12, max: 20),
                letterSpacing: 1.0,
              ),
            ),
            SizedBox(height: scale.spacing(6, min: 4, max: 10)),
            Expanded(
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _availableTypes.length,
                separatorBuilder: (context, index) => SizedBox(width: scale.spacing(10, min: 6, max: 16)),
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: scale.size(90, min: 72, max: 140),
                    child: _buildToolboxItem(context, _availableTypes[index], l10n, compact: true),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    return GlassContainer(
      borderRadius: scale.size(16, min: 12, max: 24),
      opacity: isDark ? 0.35 : 0.6,
      padding: EdgeInsets.symmetric(
        vertical: scale.spacing(16, min: 12, max: 24),
        horizontal: scale.spacing(12, min: 8, max: 20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.symbolsPaletteTitle,
            style: GoogleFonts.rajdhani(
              fontWeight: FontWeight.bold,
              fontSize: scale.font(15, min: 13, max: 22),
              letterSpacing: 1.0,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: scale.spacing(12, min: 8, max: 18)),
          Expanded(
            child: ListView.separated(
              itemCount: _availableTypes.length,
              separatorBuilder: (context, index) => SizedBox(height: scale.spacing(10, min: 6, max: 16)),
              itemBuilder: (context, index) {
                return _buildToolboxItem(context, _availableTypes[index], l10n);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolboxItem(BuildContext context, ComponentType type, AppLocalizations l10n, {bool compact = false}) {
    final name = getComponentName(type, l10n);
    final scale = context.uiScale;

    Widget buildCard({Color? bgColor, Color? borderColor, double? fontSize}) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: scale.spacing(6, min: 4, max: 10),
          vertical: scale.spacing(5, min: 3, max: 8),
        ),
        decoration: BoxDecoration(
          color: bgColor ?? (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03)),
          borderRadius: BorderRadius.circular(scale.size(10, min: 8, max: 16)),
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
              child: Stack(
                children: [
                  if (isDiagramMode)
                    Positioned.fill(
                      child: Opacity(
                        opacity: isDark ? 0.25 : 0.30,
                        child: (useRealisticAssets && type.getAssetPath(false) != null
                            ? Image.asset(
                                type.getAssetPath(false)!,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => CustomPaint(
                                  painter: ComponentPhysicalPainter(
                                    type: type,
                                    isActive: false,
                                    isDarkMode: isDark,
                                  ),
                                ),
                              )
                            : CustomPaint(
                                painter: ComponentPhysicalPainter(
                                  type: type,
                                  isActive: false,
                                  isDarkMode: isDark,
                                ),
                              )),
                      ),
                    ),
                  Positioned.fill(
                    child: isDiagramMode
                        ? CustomPaint(
                            painter: CircuitSymbolPainter(
                              type: type,
                              isActive: false,
                              color: isDark ? const Color(0xFF00F5D4) : Colors.black87,
                              activeColor: const Color(0xFFFFB300),
                              strokeWidth: scale.size(2.0, min: 1.5, max: 3.0),
                            ),
                          )
                        : (useRealisticAssets && type.getAssetPath(false) != null
                            ? Image.asset(
                                type.getAssetPath(false)!,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => CustomPaint(
                                  painter: ComponentPhysicalPainter(
                                    type: type,
                                    isActive: false,
                                    isDarkMode: isDark,
                                  ),
                                ),
                              )
                            : CustomPaint(
                                painter: ComponentPhysicalPainter(
                                  type: type,
                                  isActive: false,
                                  isDarkMode: isDark,
                                ),
                              )),
                  ),
                ],
              ),
            ),
            SizedBox(height: scale.spacing(3, min: 2, max: 6)),
            Text(
              name,
              style: TextStyle(fontSize: fontSize ?? scale.font(10, min: 9, max: 15), fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }

    final itemWidget = buildCard();
    final feedbackSize = scale.size(88, min: 72, max: 130);

    final feedbackWidget = Material(
      color: Colors.transparent,
      child: SizedBox(
        width: feedbackSize,
        height: feedbackSize,
        child: Opacity(
          opacity: 0.85,
          child: buildCard(
            bgColor: isDark ? Colors.white.withValues(alpha: 0.14) : Colors.white.withValues(alpha: 0.9),
            borderColor: const Color(0xFF00F5D4),
            fontSize: scale.font(10, min: 9, max: 15),
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

