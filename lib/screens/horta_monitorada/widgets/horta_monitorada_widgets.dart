import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Cards e controles de suporte para as missões do Estande 09.

class HortaStatusCard extends StatelessWidget {
  final String statusText;
  final bool isHealthy;
  final IconData icon;

  const HortaStatusCard({
    super.key,
    required this.statusText,
    required this.isHealthy,
    this.icon = Icons.eco_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final color = isHealthy ? const Color(0xFF10B981) : const Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: GoogleFonts.rajdhani(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class HortaTelemetryCard extends StatelessWidget {
  final double voltage;
  final double currentMa;
  final double lightPercent;
  final double moisturePercent;
  final double temperatureC;

  const HortaTelemetryCard({
    super.key,
    this.voltage = 9.0,
    this.currentMa = 45.0,
    this.lightPercent = 85.0,
    this.moisturePercent = 70.0,
    this.temperatureC = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildItem(Icons.bolt_rounded, '${voltage.toStringAsFixed(1)}V', const Color(0xFFEAB308)),
          const SizedBox(width: 12),
          _buildItem(Icons.electric_meter_rounded, '${currentMa.toStringAsFixed(0)}mA', const Color(0xFF38BDF8)),
          const SizedBox(width: 12),
          _buildItem(Icons.wb_sunny_rounded, '${lightPercent.toStringAsFixed(0)}%', const Color(0xFFFBBF24)),
          const SizedBox(width: 12),
          _buildItem(Icons.water_drop_rounded, '${moisturePercent.toStringAsFixed(0)}%', const Color(0xFF06B6D4)),
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.rajdhani(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
