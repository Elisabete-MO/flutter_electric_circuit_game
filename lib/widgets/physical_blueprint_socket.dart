import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Socket/Slot de Encaixe para o canvas físico 3D.
/// Suporta Drag and Drop, rotação de 90° ao tocar, e visual de bancada.
class PhysicalBlueprintSocket<T extends Object> extends StatelessWidget {
  final T expectedData;
  final bool isFilled;
  final ValueSetter<T> onAccept;
  final VoidCallback onTap;
  final VoidCallback? onRotate;
  final Widget symbolWidget;
  final String label;
  final Color accentColor;
  final bool showLabel;
  final double rotation;
  final double width;
  final double height;
  final Widget? placeholderWidget;

  const PhysicalBlueprintSocket({
    super.key,
    required this.expectedData,
    required this.isFilled,
    required this.onAccept,
    required this.onTap,
    required this.symbolWidget,
    this.placeholderWidget,
    this.label = '',
    this.accentColor = const Color(0xFF00E5FF),
    this.showLabel = true,
    this.rotation = 0.0,
    this.onRotate,
    this.width = 95,
    this.height = 95,
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
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: isFilled
                      ? Colors.transparent
                      : isHovering
                          ? const Color(0xFFFEF3C7)
                          : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: currentBorderColor,
                    width: isFilled ? 2.0 : (isHovering ? 2.5 : 1.5),
                  ),
                  boxShadow: isFilled
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isHovering ? 0.15 : 0.08),
                            blurRadius: isHovering ? 10 : 5,
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
                            alignment: Alignment.center,
                            children: [
                              Transform.rotate(
                                angle: rotation * math.pi / 180.0,
                                child: symbolWidget,
                              ),
                              if (onRotate != null)
                                Positioned(
                                  bottom: 3,
                                  right: 3,
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
                                  Icon(Icons.add_circle_rounded, color: const Color(0xFFD97706), size: 26),
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
                            : (placeholderWidget != null
                                ? Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Opacity(
                                        opacity: 0.5,
                                        child: placeholderWidget!,
                                      ),
                                      const Icon(Icons.add_rounded, color: Color(0xFFD97706), size: 24),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_rounded, color: const Color(0xFF94A3B8), size: 26),
                                      const SizedBox(height: 4),
                                      Text(
                                        label.isNotEmpty ? label : '',
                                        style: GoogleFonts.rajdhani(
                                          color: const Color(0xFF94A3B8),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ))),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Card de exibição de componente físico (sem drag-and-drop, apenas visual).
class PhysicalComponentCard extends StatelessWidget {
  final Widget symbolWidget;
  final String label;
  final bool isActive;
  final Color accentColor;
  final bool showLabel;
  final double width;
  final double height;

  const PhysicalComponentCard({
    super.key,
    required this.symbolWidget,
    required this.label,
    this.isActive = false,
    this.accentColor = const Color(0xFF0284C7),
    this.showLabel = true,
    this.width = 95,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    final currentBorderColor = isActive ? const Color(0xFF059669) : accentColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFF0FDF4) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: currentBorderColor,
              width: isActive ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isActive ? 0.12 : 0.06),
                blurRadius: isActive ? 8 : 4,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: symbolWidget,
          ),
        ),
        if (showLabel && label.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.rajdhani(
              color: isActive ? const Color(0xFF059669) : const Color(0xFF334155),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}
