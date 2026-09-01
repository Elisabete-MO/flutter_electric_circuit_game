import 'package:flutter/material.dart';
import '../../../models/stand_data.dart';

/// Floating info card that displays details of the selected stand with pointer arrow.
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 280,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF5),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: const Color(0xFFE2D6B5),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Title & Close Button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      stand.name,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: onClose,
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.all(2.0),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),

              // Team Subtitle
              Text(
                stand.team,
                style: const TextStyle(
                  color: Color(0xFF0F52BA),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),

              // Concept Description
              Text(
                stand.concept,
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 12.5,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),

              // Progress Header
              Text(
                !stand.hasMissions
                    ? (stand.isBancadaLivre
                        ? 'Simulador 3D Livre'
                        : 'Tutorial Introdutório')
                    : '${stand.completedMissions}/${stand.totalMissions} missões',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
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
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isFilled
                              ? const Color(0xFF0F52BA)
                              : Colors.transparent,
                          border: Border.all(
                            color: isFilled
                                ? const Color(0xFF0F52BA)
                                : const Color(0xFF94A3B8),
                            width: 2.0,
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
                const SizedBox(height: 6),
              ],

              // Action Button ("Começar missão" / "Iniciar Tutorial" / "Abrir Simulador")
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onStartMission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F52BA),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
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
          padding: const EdgeInsets.only(left: 28.0),
          child: CustomPaint(
            size: const Size(18, 10),
            painter: _CardArrowPainter(),
          ),
        ),
      ],
    );
  }
}

class _CardArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFFDF5)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..color = const Color(0xFFE2D6B5)
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
