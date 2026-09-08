import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildLetrerosLedSignBoard({
  required String title,
  required Color color,
  required bool isLit,
  bool isBurnt = false,
  bool isDim = false,
  double? fontSize,
  double? iconSize,
  EdgeInsetsGeometry? padding,
}) {
  final activeColor = isBurnt
      ? Colors.grey
      : isLit
          ? color
          : Colors.white10;

  final effFontSize = fontSize ?? 28.0;
  final effIconSize = iconSize ?? 36.0;
  final effPadding = padding ??
      const EdgeInsets.symmetric(horizontal: 40, vertical: 22);

  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    padding: effPadding,
    decoration: BoxDecoration(
      color: const Color(0xFF0A0F1D),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(
        color: activeColor,
        width: 3.5,
      ),
      boxShadow: isLit && !isBurnt
          ? [
              BoxShadow(
                color: color.withValues(alpha: isDim ? 0.25 : 0.65),
                blurRadius: isDim ? 16 : 36,
                spreadRadius: isDim ? 3 : 8,
              ),
              BoxShadow(
                color: color.withValues(alpha: isDim ? 0.15 : 0.35),
                blurRadius: isDim ? 30 : 60,
                spreadRadius: isDim ? 6 : 16,
              ),
            ]
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isBurnt
              ? Icons.flash_off_rounded
              : isLit
                  ? Icons.lightbulb_rounded
                  : Icons.lightbulb_outline_rounded,
          color: activeColor,
          size: effIconSize,
        ),
        const SizedBox(width: 14),
        Text(
          title,
          style: GoogleFonts.rajdhani(
            color: activeColor,
            fontWeight: FontWeight.bold,
            fontSize: effFontSize,
            letterSpacing: 3.5,
          ),
        ),
      ],
    ),
  );
}

Widget buildLetrerosLedStatusCard(bool isClosed) {
  final statusColor =
      isClosed ? const Color(0xFF10B981) : const Color(0xFF64748B);
  final statusText =
      isClosed ? 'CIRCUITO FECHADO (ON)' : 'CIRCUITO ABERTO (OFF)';

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
        Text(
          statusText,
          style: GoogleFonts.rajdhani(
            color: statusColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

Widget buildLetrerosLedTelemetryCard(
    double voltage, double currentMa, bool isClosed) {
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
        Text(
          'TENSÃO: ',
          style: GoogleFonts.rajdhani(
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
        Text(
          '${voltage.toStringAsFixed(1)}V',
          style: GoogleFonts.rajdhani(
            color: const Color(0xFF0284C7),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '| CORRENTE: ',
          style: GoogleFonts.rajdhani(
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
        Text(
          '${currentMa.toStringAsFixed(1)}mA',
          style: GoogleFonts.rajdhani(
            color:
                isClosed ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

Widget buildLetrerosLedPredictionBadge(String? prediction) {
  final Color bgColor;
  final Color borderColor;
  final IconData icon;
  final String text;

  if (prediction == null) {
    bgColor = const Color(0xFFFEF3C7);
    borderColor = const Color(0xFFF59E0B);
    icon = Icons.psychology_rounded;
    text = 'Previsão: Pendente';
  } else {
    bgColor = const Color(0xFFDBEAFE);
    borderColor = const Color(0xFF3B82F6);
    icon = Icons.check_circle_outline_rounded;
    text = 'Previsão: $prediction';
  }

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: borderColor, width: 1.5),
    ),
    child: Row(
      children: [
        Icon(icon, color: borderColor, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}
