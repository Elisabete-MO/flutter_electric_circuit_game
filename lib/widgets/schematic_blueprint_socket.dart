import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Socket/Slot de Encaixe para Diagramas Esquemáticos Didáticos.
/// Suporta Drag and Drop de símbolos elétricos padrão (Bateria, Lâmpada, Interruptor, LED, Resistor, Motor, etc.).
class SchematicBlueprintSocket<T extends Object> extends StatelessWidget {
  final T expectedData;
  final bool isFilled;
  final ValueSetter<T> onAccept;
  final VoidCallback onTap;
  final Widget symbolWidget;
  final Widget placeholderWidget;
  final String label;
  final Color accentColor;

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
                width: 95,
                height: 75,
                decoration: BoxDecoration(
                  color: isFilled
                      ? const Color(0xFFF0FDF4)
                      : isHovering
                          ? const Color(0xFFFEF3C7)
                          : const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: currentBorderColor,
                    width: isFilled || isHovering ? 2.5 : 1.8,
                  ),
                  boxShadow: [
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
                        ? symbolWidget
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
                            : opacityPlaceholder(placeholderWidget)),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: GoogleFonts.rajdhani(
                  color: isFilled ? const Color(0xFF059669) : const Color(0xFF334155),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
