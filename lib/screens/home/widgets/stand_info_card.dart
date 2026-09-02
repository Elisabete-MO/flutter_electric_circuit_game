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
    final numberFormatted = stand.number < 10 ? '0${stand.number}' : '${stand.number}';

    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF042920), Color(0xFF021612)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.65),
            blurRadius: 24,
            spreadRadius: 3,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.25),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: const Color(0xFF10B981),
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Image Preview with Close Button & Number Tag
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        stand.asset,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF0F172A),
                          child: const Icon(Icons.science_rounded, color: Colors.white38, size: 40),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.2),
                              const Color(0xFF042920),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Stand Number Badge on Preview Image
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF021612).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF10B981), width: 1.0),
                    boxShadow: const [
                      BoxShadow(color: Colors.black45, blurRadius: 4),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(standIcon, size: 14, color: const Color(0xFF34D399)),
                      const SizedBox(width: 4),
                      Text(
                        'ESTANDE $numberFormatted',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Close Button
              Positioned(
                top: 10,
                right: 10,
                child: InkWell(
                  onTap: onClose,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white30, width: 0.8),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 2. Body Details
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  stand.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 17.0,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stand.team,
                  style: const TextStyle(
                    color: Color(0xFF34D399),
                    fontWeight: FontWeight.w700,
                    fontSize: 12.0,
                  ),
                ),
                const SizedBox(height: 10),

                // Concept Description Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
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
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Mission Progress Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      !stand.hasMissions
                          ? (stand.isBancadaLivre
                              ? 'Simulador 3D Livre'
                              : 'Tutorial Introdutório')
                          : 'Progresso da Equipe',
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5,
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

                // 5 Circles Progress Indicator Bar
                if (stand.hasMissions) ...[
                  Row(
                    children: List.generate(stand.totalMissions, (index) {
                      final isFilled = index < stand.completedMissions;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isFilled
                                ? const Color(0xFF10B981)
                                : Colors.transparent,
                            border: Border.all(
                              color: isFilled
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF64748B),
                              width: 1.8,
                            ),
                          ),
                          child: isFilled
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 9,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 14),
                ] else ...[
                  const SizedBox(height: 10),
                ],

                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onStartMission,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: const Color(0xFF022C22),
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
                          ? 'Abrir Simulador 3D'
                          : (stand.number == 1
                              ? 'Iniciar Tutorial'
                              : 'Começar missão'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
