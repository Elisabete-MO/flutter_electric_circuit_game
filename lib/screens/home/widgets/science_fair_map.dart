import 'package:flutter/material.dart';
import '../../../models/stand_data.dart';
import 'stand_info_card.dart';
import 'stand_marker.dart';

/// The interactive Science Fair Map component that renders the gymnasium top-down background,
/// stand markers, central collective model marker, and the floating info card edge-to-edge.
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

        // Responsive marker width proportional to map container width
        final double markerW = (mapW * 0.095).clamp(80.0, 140.0);

        final isNarrow = mapW < 650;

        Widget mapContent = SizedBox(
          width: mapW,
          height: mapH,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // 1. Gymnasium Background Court Image filling map container completely edge-to-edge
              Positioned.fill(
                child: Image.asset(
                  'assets/stands/background2.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFF1E293B),
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

              // 2. Center Circle: "Maquete Coletiva" Marker
              Positioned(
                left: mapW * 0.50 - (markerW * 0.70),
                top: mapH * 0.50 - (markerW * 0.70),
                child: GestureDetector(
                  onTap: onTapMaqueteColetiva,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      width: markerW * 1.4,
                      height: markerW * 1.4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(
                          0xFF10B981,
                        ).withValues(alpha: 0.92),
                        border: Border.all(color: Colors.white, width: 3.0),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF10B981,
                            ).withValues(alpha: 0.6),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.location_city_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Maquete\ncoletiva',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: (markerW * 0.12).clamp(10.0, 13.0),
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 3. Stand Markers (01 to 12)
              ...stands.map((stand) {
                final double left = mapW * stand.relX - (markerW / 2);
                final double top = mapH * stand.relY - (markerW / 3);

                return Positioned(
                  left: left,
                  top: top,
                  child: StandMarker(
                    stand: stand,
                    isSelected: selectedStand?.id == stand.id,
                    width: markerW,
                    onTap: () => onSelectStand(stand),
                  ),
                );
              }),

              // 4. Floating Info Card overlaid when a stand is tapped
              if (selectedStand != null) ...[
                Builder(
                  builder: (context) {
                    final stand = selectedStand!;
                    final double targetX = mapW * stand.relX;
                    final double targetY = mapH * stand.relY;

                    const double cardW = 270.0;
                    const double cardH = 240.0;

                    final double cardLeft = (targetX - 35.0).clamp(
                      10.0,
                      mapW - cardW - 10.0,
                    );

                    final bool placeAbove = targetY > (mapH * 0.55);
                    final double cardTop = placeAbove
                        ? (targetY - cardH - 25.0).clamp(10.0, mapH - cardH)
                        : (targetY + 25.0).clamp(10.0, mapH - cardH);

                    return Positioned(
                      left: cardLeft,
                      top: cardTop,
                      child: Material(
                        type: MaterialType.transparency,
                        child: StandInfoCard(
                          stand: stand,
                          onStartMission: () => onStartMission(stand),
                          onClose: onCloseCard,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        );

        if (isNarrow) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 750,
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
