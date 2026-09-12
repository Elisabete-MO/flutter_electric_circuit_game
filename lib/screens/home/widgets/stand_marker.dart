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

    // Dynamic ground selection aura color
    final Color? floorGlowColor = widget.isSelected
        ? EletroLabColors.amber
        : (_isHovered
              ? EletroLabColors.neonCyan
              : (isBancadaLivre ? const Color(0xFF00E5FF) : null));

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: widget.isSelected ? 1.10 : (_isHovered ? 1.05 : 1.0),
          duration: duration,
          curve: Curves.easeOutCubic,
          child: SizedBox(
            width: widget.width,
            height: height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Sombra Realista de Contato no Piso (Ground Contact Shadow)
                Positioned(
                  left: widget.width * 0.08,
                  right: widget.width * 0.08,
                  bottom: height * 0.01,
                  height: height * 0.26,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.elliptical(
                          widget.width * 0.42,
                          height * 0.13,
                        ),
                      ),
                      gradient: RadialGradient(
                        colors: [
                          Colors.black.withValues(
                            alpha: _isHovered ? 0.65 : 0.50,
                          ),
                          Colors.black.withValues(
                            alpha: _isHovered ? 0.35 : 0.22,
                          ),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.58, 1.0],
                      ),
                    ),
                  ),
                ),

                // 2. Halo Luminoso / Pedestal de Seleção no Piso (quando Selecionado ou Hover)
                if (floorGlowColor != null)
                  Positioned(
                    left: widget.width * 0.03,
                    right: widget.width * 0.03,
                    bottom: 0,
                    height: height * 0.32,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.elliptical(
                            widget.width * 0.47,
                            height * 0.16,
                          ),
                        ),
                        gradient: RadialGradient(
                          colors: [
                            floorGlowColor.withValues(
                              alpha: widget.isSelected ? 0.55 : 0.30,
                            ),
                            floorGlowColor.withValues(
                              alpha: widget.isSelected ? 0.25 : 0.10,
                            ),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.60, 1.0],
                        ),
                      ),
                    ),
                  ),

                // 3. Imagem 3D da Mesa (Renderizada diretamente sobre o chão)
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

                // Bancada Livre Special Glow Overlay (3D Lab)
                if (isBancadaLivre)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF00E5FF).withValues(alpha: 0.10),
                              Colors.transparent,
                              const Color(0xFF7C4DFF).withValues(alpha: 0.15),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
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
    ),
  );
}
}
