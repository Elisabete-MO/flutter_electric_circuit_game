import 'package:flutter/material.dart';
import '../../../models/stand_data.dart';

/// Floating info card with 3D top-down perspective detailing the selected stand.
class StandInfoCard extends StatelessWidget {
  final StandData stand;
  final VoidCallback onStartMission;
  final VoidCallback onClose;

  const StandInfoCard({
    super.key,
    required this.stand,
    required this.onStartMission,
    required this.onClose,
  });

  IconData _getStandIcon(int number, bool isBancadaLivre) {
    if (isBancadaLivre) return Icons.science_rounded;
    switch (number) {
      case 1:
        return Icons.school_rounded;
      case 2:
        return Icons.tungsten_rounded;
      case 3:
        return Icons.toggle_on_rounded;
      case 4:
        return Icons.alt_route_rounded;
      case 5:
        return Icons.lightbulb_rounded;
      case 6:
        return Icons.autorenew_rounded;
      case 7:
        return Icons.speed_rounded;
      case 8:
        return Icons.shield_rounded;
      case 9:
        return Icons.eco_rounded;
      case 10:
        return Icons.sensor_door_rounded;
      case 11:
        return Icons.location_city_rounded;
      case 12:
        return Icons.handyman_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final IconData standIcon = _getStandIcon(stand.number, stand.isBancadaLivre);

    return Transform(
      alignment: Alignment.bottomCenter,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001) // Projeção de perspectiva 3D top-down
        ..rotateX(-0.06), // Inclinação suave alinhada ao mapa da quadra
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 270),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF063328), Color(0xFF021B15)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.55),
                  blurRadius: 22,
                  spreadRadius: 2,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(
                color: const Color(0xFF059669),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row: Icon + Title & Close Button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: 0.4),
                        ),
                      ),
                      child: Icon(
                        standIcon,
                        size: 20,
                        color: const Color(0xFF34D399),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stand.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 16.0,
                              letterSpacing: -0.2,
                            ),
                          ),
                          Text(
                            stand.team,
                            style: const TextStyle(
                              color: Color(0xFF34D399),
                              fontWeight: FontWeight.w700,
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: onClose,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Concept Description
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Text(
                    stand.concept,
                    style: const TextStyle(
                      color: Color(0xFFE2E8F0),
                      fontSize: 12.0,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Progress Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        !stand.hasMissions
                            ? (stand.isBancadaLivre
                                ? 'Simulador 3D Livre'
                                : 'Tutorial Introdutório')
                            : 'Progresso da Equipe',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w700,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                    if (stand.hasMissions)
                      Text(
                        '${stand.completedMissions}/${stand.totalMissions} missões',
                        style: const TextStyle(
                          color: Color(0xFF34D399),
                          fontWeight: FontWeight.w800,
                          fontSize: 11.5,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),

                // 5 Circles Progress Indicator Bar (only shown for stands with missions)
                if (stand.hasMissions) ...[
                  Row(
                    children: List.generate(stand.totalMissions, (index) {
                      final isFilled = index < stand.completedMissions;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isFilled
                                ? const Color(0xFF10B981)
                                : Colors.transparent,
                            border: Border.all(
                              color: isFilled
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF64748B),
                              width: 2.0,
                            ),
                          ),
                          child: isFilled
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 10,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 14),
                ] else ...[
                  const SizedBox(height: 6),
                ],

                // Action Button ("Começar missão" / "Iniciar Tutorial" / "Abrir Simulador")
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onStartMission,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: const Color(0xFF022C22),
                      elevation: 3,
                      padding: const EdgeInsets.symmetric(vertical: 11.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13.5,
                        letterSpacing: 0.3,
                      ),
                    ),
                    icon: Icon(
                      stand.isBancadaLivre
                          ? Icons.biotech_rounded
                          : (stand.number == 1
                              ? Icons.school_rounded
                              : Icons.play_arrow_rounded),
                      size: 19,
                    ),
                    label: Text(
                      stand.isBancadaLivre
                          ? 'Abrir Simulador'
                          : (stand.number == 1
                              ? 'Iniciar Tutorial'
                              : 'Começar missão'),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Arrow Pointer at Bottom
          Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: CustomPaint(
              size: const Size(18, 10),
              painter: _CardArrowPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF021B15)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..color = const Color(0xFF059669)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final borderPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0);

    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
