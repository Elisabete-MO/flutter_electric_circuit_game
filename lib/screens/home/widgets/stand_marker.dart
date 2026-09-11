import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../models/stand_data.dart';

import '../../../core/ui_scale.dart';

/// Widget que renderiza o estande da Feira de Ciências com perspectiva top-down 3D,
/// ícones temáticos e badges visuais de status.
class StandMarker extends StatefulWidget {
  final StandData stand;
  final bool isSelected;
  final VoidCallback onTap;
  final double width;

  const StandMarker({
    super.key,
    required this.stand,
    required this.isSelected,
    required this.onTap,
    this.width = 110,
  });

  @override
  State<StandMarker> createState() => _StandMarkerState();
}

class _StandMarkerState extends State<StandMarker> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final duration = disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 220);

    // Core dimensions & properties (aspect ratio ~363x338 da mesa 3D low-poly)
    final height = widget.width * (338.0 / 363.0);
    final numberFormatted = widget.stand.number < 10
        ? '0${widget.stand.number}'
        : '${widget.stand.number}';

    final bool isTutorial = widget.stand.number == 1;
    final bool isBancadaLivre = widget.stand.isBancadaLivre;
    final bool isCompleted =
        widget.stand.hasMissions &&
        widget.stand.completedMissions >= widget.stand.totalMissions &&
        widget.stand.totalMissions > 0;

    // Border color logic (thinner green border by default, cyan/amber when active)
    final Color borderColor = widget.isSelected
        ? EletroLabColors.amber
        : (_isHovered
              ? EletroLabColors.neonCyan
              : (isBancadaLivre
                    ? const Color(0xFF00E5FF)
                    : (isTutorial
                          ? const Color(0xFFF59E0B)
                          : (isCompleted
                                ? const Color(0xFF10B981)
                                : const Color(
                                    0xFF059669,
                                  ).withValues(alpha: 0.5)))));

    // Thinner border width specification (1.0 normal, 2.0 selected/hovered)
    final double borderWidth = widget.isSelected
        ? 2.0
        : (_isHovered ? 1.5 : 1.0);

    // Dynamic glow shadow for consistent lighting & 3D floor projection
    final List<BoxShadow> shadows = [
      // Floor shadow (consistent soft directional light)
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.45),
        blurRadius: _isHovered ? 12 : 8,
        spreadRadius: 1,
        offset: const Offset(3, 6),
      ),
      if (widget.isSelected)
        BoxShadow(
          color: EletroLabColors.amber.withValues(alpha: 0.7),
          blurRadius: 16,
          spreadRadius: 2,
        )
      else if (isBancadaLivre)
        BoxShadow(
          color: const Color(
            0xFF00E5FF,
          ).withValues(alpha: _isHovered ? 0.6 : 0.35),
          blurRadius: _isHovered ? 16 : 10,
          spreadRadius: _isHovered ? 2 : 1,
        )
      else if (_isHovered)
        BoxShadow(
          color: EletroLabColors.neonCyan.withValues(alpha: 0.4),
          blurRadius: 10,
          spreadRadius: 1,
        ),
    ];

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: widget.isSelected ? 1.12 : (_isHovered ? 1.07 : 1.0),
          duration: duration,
          curve: Curves.easeOutCubic,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. Table Container (Image + Beveled Border + Shadow)
              AnimatedContainer(
                duration: duration,
                width: widget.width,
                height: height,
                decoration: ShapeDecoration(
                  shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: borderColor, width: borderWidth),
                  ),
                  shadows: shadows,
                ),
                child: ClipPath(
                  clipper: ShapeBorderClipper(
                    shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.circular(7.5),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          widget.stand.asset,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFF0F172A),
                              alignment: Alignment.center,
                              child: Text(
                                '#${widget.stand.number}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Bancada Livre Special Overlay Effect (Bancada Livre 3D Lab)
                      if (isBancadaLivre)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(
                                    0xFF00E5FF,
                                  ).withValues(alpha: 0.15),
                                  Colors.transparent,
                                  const Color(
                                    0xFF7C4DFF,
                                  ).withValues(alpha: 0.20),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // 2. Integrated Number Badge (Top-Left corner over table - Chanfrado Low-Poly)
              Positioned(
                top: 3,
                left: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: ShapeDecoration(
                    color: widget.isSelected
                        ? const Color(0xFFF59E0B)
                        : (isBancadaLivre
                              ? const Color(0xFF0EA5E9)
                              : (isTutorial
                                    ? const Color(0xFFD97706)
                                    : const Color(
                                        0xFF021B15,
                                      ).withValues(alpha: 0.92))),
                    shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                      side: BorderSide(
                        color: widget.isSelected
                            ? Colors.white
                            : (isBancadaLivre
                                  ? const Color(0xFF38BDF8)
                                  : const Color(
                                      0xFF10B981,
                                    ).withValues(alpha: 0.85)),
                        width: 1.0,
                      ),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    numberFormatted,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: UiScale.of(
                        context,
                      ).font(widget.width * 0.11, min: 11.0, max: 20.0),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),

              // 3. Special Tag Badge (Bottom-Right corner over table - Chanfrado Low-Poly)
              if (isTutorial || isBancadaLivre)
                Positioned(
                  bottom: 3,
                  right: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: ShapeDecoration(
                      color: isBancadaLivre
                          ? const Color(0xFF7C4DFF)
                          : const Color(0xFFF59E0B),
                      shape: BeveledRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: const BorderSide(color: Colors.white70, width: 0.8),
                      ),
                      shadows: const [
                        BoxShadow(color: Colors.black38, blurRadius: 3),
                      ],
                    ),
                    child: Text(
                      isBancadaLivre ? '3D LAB' : 'TUTORIAL',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: UiScale.of(
                          context,
                        ).font(widget.width * 0.08, min: 8.0, max: 15.0),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),

              // 4. Floating Checkmark Badge if Completed (Top-Right corner)
              if (isCompleted)
                Positioned(
                  top: -5,
                  right: -5,
                  child: Container(
                    padding: const EdgeInsets.all(3.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Colors.white,
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
