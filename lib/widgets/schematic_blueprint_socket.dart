import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Socket/Slot de Encaixe para Diagramas Esquemáticos Didáticos.
/// Suporta Drag and Drop de símbolos elétricos padrão (Bateria, Lâmpada, Interruptor, LED, Resistor, Motor, etc.).
/// Suporta rotação de 90° ao tocar no componente preenchido.
class SchematicBlueprintSocket<T extends Object> extends StatelessWidget {
  final T expectedData;
  final bool isFilled;
  final ValueSetter<T> onAccept;
  final VoidCallback onTap;
  final VoidCallback? onRotate;
  final Widget symbolWidget;
  final Widget placeholderWidget;
  final String label;
  final Color accentColor;
  final bool showLabel;
  final double rotation;
  final double? width;
  final double? height;

  const SchematicBlueprintSocket({
    super.key,
    required this.expectedData,
    required this.isFilled,
    required this.onAccept,
    required this.onTap,
    required this.symbolWidget,
    required this.placeholderWidget,
    required this.label,
    this.accentColor = const Color(0xFF00E5FF),
    this.showLabel = true,
    this.rotation = 0.0,
    this.onRotate,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<T>(
      onWillAcceptWithDetails: (details) => details.data == expectedData,
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        final currentBorderColor = isFilled
            ? const Color(0xFF059669)
            : isHovering
                ? const Color(0xFFD97706)
                : accentColor;

        return GestureDetector(
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: width ?? 95,
                height: height ?? 75,
                decoration: BoxDecoration(
                  color: isFilled
                      ? Colors.transparent
                      : isHovering
                          ? const Color(0xFFFEF3C7)
                          : const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: currentBorderColor,
                    width: isFilled ? 2.0 : (isHovering ? 2.5 : 1.8),
                  ),
                  boxShadow: isFilled
                      ? []
                      : [
                          BoxShadow(
                            color: currentBorderColor.withValues(alpha: isHovering ? 0.25 : 0.10),
                            blurRadius: isHovering ? 12 : 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: isFilled
                        ? Stack(
                            key: ValueKey('filled_$rotation'),
                            children: [
                              Center(
                                child: Transform.rotate(
                                  angle: rotation * math.pi / 180.0,
                                  child: symbolWidget,
                                ),
                              ),
                              if (onRotate != null)
                                Positioned(
                                  bottom: 2,
                                  right: 2,
                                  child: GestureDetector(
                                    onTap: onRotate,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: const Color(0xFF00FF9D), width: 1.2),
                                      ),
                                      child: const Icon(
                                        Icons.screen_rotation_rounded,
                                        size: 12,
                                        color: Color(0xFF00FF9D),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          )
                        : (isHovering
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add_circle_rounded, color: Color(0xFFD97706), size: 24),
                                  const SizedBox(height: 2),
                                  Text(
                                    'SOLTE AQUI',
                                    style: GoogleFonts.rajdhani(
                                      color: const Color(0xFFD97706),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : const Icon(Icons.add_rounded, color: Color(0xFF94A3B8), size: 26)),
                  ),
                ),
              ),
              if (showLabel && label.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.rajdhani(
                    color: isFilled ? const Color(0xFF059669) : const Color(0xFF334155),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget opacityPlaceholder(Widget child) {
    return Opacity(
      opacity: 0.4,
      child: child,
    );
  }
}

/// Card de Exibição de Componente no Blueprint Esquemático (Bateria, Lâmpada, etc.).
class SchematicComponentCard extends StatelessWidget {
  final Widget symbolWidget;
  final String label;
  final bool isActive;
  final Color accentColor;
  final bool showLabel;

  const SchematicComponentCard({
    super.key,
    required this.symbolWidget,
    required this.label,
    this.isActive = false,
    this.accentColor = const Color(0xFF0284C7),
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final currentBorderColor = isActive ? const Color(0xFF059669) : accentColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 95,
          height: 75,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFF0FDF4) : const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: currentBorderColor,
              width: isActive ? 2.5 : 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: currentBorderColor.withValues(alpha: isActive ? 0.25 : 0.10),
                blurRadius: isActive ? 12 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: symbolWidget,
          ),
        ),
        if (showLabel && label.isNotEmpty) ...[
          const SizedBox(height: 5),
          Text(
            label,
            style: GoogleFonts.rajdhani(
              color: isActive ? const Color(0xFF059669) : const Color(0xFF334155),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}
