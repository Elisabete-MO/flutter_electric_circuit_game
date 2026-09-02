import 'package:flutter/material.dart';
import '../../../models/stand_data.dart';
import 'stand_info_card.dart';
import 'stand_marker.dart';

/// The interactive Science Fair Map component featuring 50% larger tables, 3D Alpha Lumen central logo,
/// visual progression paths, unified lighting vignette, and responsive info panel.
class ScienceFairMap extends StatelessWidget {
  final List<StandData> stands;
  final StandData? selectedStand;
  final ValueChanged<StandData> onSelectStand;
  final ValueChanged<StandData> onStartMission;
  final VoidCallback onCloseCard;
  final VoidCallback onTapMaqueteColetiva;

  const ScienceFairMap({
    super.key,
    required this.stands,
    required this.selectedStand,
    required this.onSelectStand,
    required this.onStartMission,
    required this.onCloseCard,
    required this.onTapMaqueteColetiva,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double mapW = constraints.maxWidth;
        final double mapH = constraints.maxHeight;

        // 50% larger table base width (was ~0.095, now ~0.14)
        final double baseMarkerW = (mapW * 0.14).clamp(115.0, 185.0);

        final isNarrow = mapW < 700;

        // Sort stands by number for the progression path
        final sortedStands = List<StandData>.from(stands)
          ..sort((a, b) => a.number.compareTo(b.number));

        Widget mapContent = SizedBox(
          width: mapW,
          height: mapH,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // 1. Gymnasium Background Court Image fill
              Positioned.fill(
                child: Image.asset(
                  'assets/stands/background2.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFF0F172A),
                      child: const Center(
                        child: Text(
                          'Ginásio EletroLab',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 2. Consistent Lighting Vignette Overlay (Spotlight effect from center)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.85,
                        colors: [
                          Colors.transparent,
                          const Color(0xFF021712).withValues(alpha: 0.40),
                          const Color(0xFF021712).withValues(alpha: 0.75),
                        ],
                        stops: const [0.35, 0.75, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              // 3. Visual Progression Path Painter (Connecting stands 1 to 12)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: ProgressionPathPainter(
                      stands: sortedStands,
                      mapW: mapW,
                      mapH: mapH,
                    ),
                  ),
                ),
              ),

              // 4. Central 3D Alpha Lumen Logo (Center of Gymnasium)
              Positioned(
                left: mapW * 0.50 - (baseMarkerW * 0.75),
                top: mapH * 0.50 - (baseMarkerW * 0.75),
                child: GestureDetector(
                  onTap: onTapMaqueteColetiva,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: _AlphaLumenCentralLogo(size: baseMarkerW * 1.5),
                  ),
                ),
              ),

              // 5. Stand Markers (01 to 12)
              ...stands.map((stand) {
                // Bancada Livre (Stand 12) is extra large and special
                final double standW = stand.isBancadaLivre
                    ? (baseMarkerW * 1.45).clamp(150.0, 240.0)
                    : baseMarkerW;

                final double left = mapW * stand.relX - (standW / 2);
                final double top = mapH * stand.relY - (standW * 0.33);

                return Positioned(
                  left: left,
                  top: top,
                  child: StandMarker(
                    stand: stand,
                    isSelected: selectedStand?.id == stand.id,
                    width: standW,
                    onTap: () => onSelectStand(stand),
                  ),
                );
              }),

              // 6. Side Info Panel upon selection
              if (selectedStand != null)
                Positioned(
                  top: 16,
                  right: 16,
                  bottom: 16,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: SingleChildScrollView(
                      child: StandInfoCard(
                        stand: selectedStand!,
                        onStartMission: () => onStartMission(selectedStand!),
                        onClose: onCloseCard,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );

        if (isNarrow) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 850,
              height: mapH,
              child: mapContent,
            ),
          );
        }

        return mapContent;
      },
    );
  }
}

/// Central 3D Elevated Institutional Alpha Lumen Platform
class _AlphaLumenCentralLogo extends StatelessWidget {
  final double size;

  const _AlphaLumenCentralLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(-0.035), // Subtle 2.5D top-down perspective tilt matching gym stands
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // Institutional Green Gradient (dark green border to lighter green center)
          gradient: const RadialGradient(
            colors: [
              Color(0xFF0B634B),
              Color(0xFF04382B),
              Color(0xFF021B15),
            ],
            stops: [0.0, 0.70, 1.0],
          ),
          // Fine light-green border
          border: Border.all(
            color: const Color(0xFF10B981),
            width: 1.8,
          ),
          boxShadow: [
            // Soft discrete green glow at base (no cyan/blue)
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.35),
              blurRadius: 22,
              spreadRadius: 2,
            ),
            // Projected floor shadow for 3D elevation
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.55),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Inner subtle rim ring
            Container(
              width: size * 0.90,
              height: size * 0.90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF34D399).withValues(alpha: 0.3),
                  width: 1.0,
                ),
              ),
            ),

            // Platform Content: Symbol in upper half + Institutional Texts below
            Padding(
              padding: EdgeInsets.symmetric(vertical: size * 0.10, horizontal: size * 0.08),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Official Symbol (Pure White, 34% of circle diameter, upper half)
                  SizedBox(
                    width: size * 0.34,
                    height: size * 0.34,
                    child: const Icon(
                      Icons.stars_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),

                  SizedBox(height: size * 0.04),

                  // Text Line 1: "INSTITUTO ALPHA LUMEN"
                  Text(
                    'INSTITUTO ALPHA LUMEN',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: (size * 0.072).clamp(8.0, 11.5),
                      letterSpacing: 0.6,
                      shadows: const [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 2),

                  // Text Line 2: "EletroLab"
                  Text(
                    'EletroLab',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(
                      color: const Color(0xFF34D399),
                      fontWeight: FontWeight.w700,
                      fontSize: (size * 0.065).clamp(7.0, 10.0),
                      letterSpacing: 0.4,
                      shadows: const [
                        Shadow(
                          color: Colors.black45,
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom Painter that draws a smooth progression path connecting stands 1 through 12,
/// terminating cleanly at the outer boundary of the central platform.
class ProgressionPathPainter extends CustomPainter {
  final List<StandData> stands;
  final double mapW;
  final double mapH;

  ProgressionPathPainter({
    required this.stands,
    required this.mapW,
    required this.mapH,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (stands.length < 2) return;

    final double baseMarkerW = (mapW * 0.14).clamp(115.0, 185.0);
    final Offset center = Offset(mapW * 0.50, mapH * 0.50);
    final double platformRadius = (baseMarkerW * 1.5) / 2;

    // Clip canvas so lines stop cleanly at the central platform outer edge
    canvas.save();
    final clipPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, mapW, mapH))
      ..addOval(Rect.fromCircle(center: center, radius: platformRadius + 2))
      ..fillType = PathFillType.evenOdd;
    canvas.clipPath(clipPath);

    final glowPaint = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final pathPaint = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Move to first stand center
    final firstPoint = Offset(stands.first.relX * mapW, stands.first.relY * mapH);
    path.moveTo(firstPoint.dx, firstPoint.dy);

    for (int i = 0; i < stands.length - 1; i++) {
      final p1 = Offset(stands[i].relX * mapW, stands[i].relY * mapH);
      final p2 = Offset(stands[i + 1].relX * mapW, stands[i + 1].relY * mapH);

      // Smooth curved control points
      final controlPoint1 = Offset(p1.dx, (p1.dy + p2.dy) / 2);
      final controlPoint2 = Offset(p2.dx, (p1.dy + p2.dy) / 2);

      path.cubicTo(
        controlPoint1.dx, controlPoint1.dy,
        controlPoint2.dx, controlPoint2.dy,
        p2.dx, p2.dy,
      );
    }

    // Draw background glow path and foreground path
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, pathPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ProgressionPathPainter oldDelegate) {
    return oldDelegate.mapW != mapW || oldDelegate.mapH != mapH;
  }
}

