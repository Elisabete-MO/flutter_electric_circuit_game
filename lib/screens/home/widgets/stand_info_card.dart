import 'package:flutter/material.dart';
import '../../../core/ui_scale.dart';
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

  @override
  Widget build(BuildContext context) {
    final numberFormatted = stand.number < 10
        ? '0${stand.number}'
        : '${stand.number}';
    final scale = context.uiScale;

    return Container(
      constraints: BoxConstraints(
        maxWidth: scale.size(410, min: 320, max: 680),
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF042920), Color(0xFF021612)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(scale.size(18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.65),
            blurRadius: scale.size(24),
            spreadRadius: scale.size(3),
            offset: Offset(0, scale.size(10)),
          ),
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.25),
            blurRadius: scale.size(16),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(color: const Color(0xFF10B981), width: 1.4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Image Preview with Close Button & Number Tag
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(scale.size(17)),
                ),
                child: Container(
                  height: scale.size(160, min: 130, max: 280),
                  width: double.infinity,
                  color: const Color(0xFF021612),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Padding(
                        padding: scale.insetsAll(8),
                        child: Image.asset(
                          stand.asset,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFF0F172A),
                            child: Icon(
                              Icons.science_rounded,
                              color: Colors.white38,
                              size: scale.icon(40),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.1),
                              Colors.transparent,
                              const Color(0xFF042920).withValues(alpha: 0.5),
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
                top: scale.spacing(10),
                left: scale.spacing(10),
                child: Container(
                  padding: scale.insetsSymmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF021612).withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(scale.size(8)),
                    border: Border.all(
                      color: const Color(0xFF10B981),
                      width: 1.2,
                    ),
                    boxShadow: const [
                      BoxShadow(color: Colors.black45, blurRadius: 4),
                    ],
                  ),
                  child: Text(
                    'ESTANDE $numberFormatted',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: scale.font(12.5),
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),

              // Close Button
              Positioned(
                top: scale.spacing(10),
                right: scale.spacing(10),
                child: InkWell(
                  onTap: onClose,
                  borderRadius: BorderRadius.circular(scale.size(18)),
                  child: Container(
                    padding: scale.insetsAll(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white38, width: 0.9),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: scale.icon(18),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 2. Body Details
          Padding(
            padding: scale.insetsAll(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  stand.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: scale.font(20.0),
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: scale.spacing(3)),
                Text(
                  stand.team,
                  style: TextStyle(
                    color: const Color(0xFF34D399),
                    fontWeight: FontWeight.w700,
                    fontSize: scale.font(13.5),
                  ),
                ),
                SizedBox(height: scale.spacing(12)),

                // Concept Description Box
                Container(
                  width: double.infinity,
                  padding: scale.insetsAll(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(scale.size(12)),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10),
                    ),
                  ),
                  child: Text(
                    stand.concept,
                    style: TextStyle(
                      color: const Color(0xFFE2E8F0),
                      fontSize: scale.font(14.0),
                      height: 1.45,
                    ),
                  ),
                ),
                SizedBox(height: scale.spacing(14)),

                // Mission Progress Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        !stand.hasMissions
                            ? (stand.isBancadaLivre
                                  ? 'Simulador 3D Livre'
                                  : 'Tutorial Introdutório')
                            : 'Progresso da Equipe',
                        style: TextStyle(
                          color: const Color(0xFF94A3B8),
                          fontWeight: FontWeight.w700,
                          fontSize: scale.font(13.0),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (stand.hasMissions) ...[
                      const SizedBox(width: 8),
                      Text(
                        '${stand.completedMissions}/${stand.totalMissions} missões',
                        style: TextStyle(
                          color: const Color(0xFF34D399),
                          fontWeight: FontWeight.w800,
                          fontSize: scale.font(13.0),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: scale.spacing(8)),

                // 5 Circles Progress Indicator Bar
                if (stand.hasMissions) ...[
                  Row(
                    children: List.generate(stand.totalMissions, (index) {
                      final isFilled = index < stand.completedMissions;
                      return Padding(
                        padding: EdgeInsets.only(right: scale.spacing(7.0)),
                        child: Container(
                          width: scale.size(17),
                          height: scale.size(17),
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
                              ? Icon(
                                  Icons.check_rounded,
                                  size: scale.icon(11),
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: scale.spacing(16)),
                ] else ...[
                  SizedBox(height: scale.spacing(12)),
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
                      padding: scale.insetsSymmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(scale.size(12)),
                      ),
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: scale.font(16.0),
                        letterSpacing: 0.3,
                      ),
                    ),
                    icon: Icon(
                      stand.isBancadaLivre
                          ? Icons.biotech_rounded
                          : (stand.number == 1
                                ? Icons.school_rounded
                                : Icons.play_arrow_rounded),
                      size: scale.icon(22),
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
