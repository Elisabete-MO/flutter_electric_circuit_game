import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildScoreRow(String label, String value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: GoogleFonts.outfit(
          color: Colors.white70,
          fontSize: 14,
        ),
      ),
      Text(
        value,
        style: GoogleFonts.rajdhani(
          color: const Color(0xFF10B981),
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    ],
  );
}

Widget buildLigaDesligaStatusCard(bool isClosed) {
  final statusColor = isClosed
      ? const Color(0xFF10B981)
      : const Color(0xFF64748B);
  final statusText = isClosed
      ? 'CIRCUITO FECHADO (ON)'
      : 'CIRCUITO ABERTO (OFF)';

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFCBD5E1)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
            boxShadow: [
              if (isClosed)
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.6),
                  blurRadius: 6,
                  spreadRadius: 1.5,
                ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            statusText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.rajdhani(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget buildLigaDesligaTelemetryCard(
    double voltage, double currentMa, bool isClosed) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFF0F172A).withValues(alpha: 0.90),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: const Color(0xFF10B981).withValues(alpha: 0.4),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.bolt_rounded, color: Color(0xFFFACC15), size: 16),
        const SizedBox(width: 4),
        Text(
          '${voltage.toStringAsFixed(1)} V',
          style: GoogleFonts.rajdhani(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 10),
        Icon(
          Icons.speed_rounded,
          color: isClosed ? const Color(0xFF00FF9D) : Colors.white38,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          '${currentMa.toStringAsFixed(0)} mA',
          style: GoogleFonts.rajdhani(
            color: isClosed ? const Color(0xFF00FF9D) : Colors.white38,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}
