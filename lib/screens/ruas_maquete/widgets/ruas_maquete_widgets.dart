import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/first_step_component.dart';
import '../../../widgets/circuit_symbol_painter.dart';
import '../../../widgets/component_physical_painter.dart';
import '../../../widgets/physical_blueprint_socket.dart';
import '../../../widgets/schematic_blueprint_socket.dart';
import '../../../widgets/street_lamp_painter.dart';

Widget buildRuasMaqueteStatusCard(bool isClosed) {
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

Widget buildRuasMaqueteTelemetryCard(
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
          '${currentMa.toStringAsFixed(0)}mA',
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

Widget buildRuasMaqueteLampSymbol({
  required bool isLit,
  required double brightnessRatio,
  required bool usePhysicalStyle,
  double width = 80,
  double height = 60,
}) {
  final compW = width * 0.75;
  final compH = height * 0.75;

  return SizedBox(
    width: width,
    height: height,
    child: Center(
      child: usePhysicalStyle
          ? CustomPaint(
              size: Size(compW, compH),
              painter: StreetLampPainter(
                isActive: isLit,
                brightnessRatio: brightnessRatio,
                isDarkMode: false,
              ),
            )
          : CustomPaint(
              size: Size(compW * 0.9, compH * 0.9),
              painter: CircuitSymbolPainter(
                type: ComponentType.bulb,
                isActive: isLit,
                color: const Color(0xFF0F172A),
                strokeWidth: 2.5,
              ),
            ),
    ),
  );
}

Widget buildRuasMaqueteHouseSymbol({
  required String name,
  required bool isLit,
  required double brightness,
  bool isBroken = false,
  required bool usePhysicalStyle,
  double width = 80,
  double height = 60,
}) {
  final compW = width * 0.75;
  final compH = height * 0.75;
  final iconSize = (height * 0.52).clamp(28.0, 42.0);

  return SizedBox(
    width: width,
    height: height,
    child: Center(
      child: usePhysicalStyle
          ? Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isBroken
                      ? const Color(0xFFDC2626)
                      : isLit
                          ? const Color(0xFFD97706)
                          : const Color(0xFFCBD5E1),
                  width: 2,
                ),
                boxShadow: isLit
                    ? [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                          blurRadius: 14,
                        )
                      ]
                    : [],
              ),
              child: Icon(
                isBroken
                    ? Icons.gavel_rounded
                    : isLit
                        ? Icons.home_rounded
                        : Icons.home_outlined,
                size: iconSize,
                color: isBroken
                    ? const Color(0xFFDC2626)
                    : isLit
                        ? const Color(0xFFD97706)
                        : const Color(0xFF64748B),
              ),
            )
          : CustomPaint(
              size: Size(compW * 0.9, compH * 0.9),
              painter: CircuitSymbolPainter(
                type: ComponentType.bulb,
                isActive: isLit && !isBroken,
                isBurned: isBroken,
                color: const Color(0xFF0F172A),
                strokeWidth: 2.5,
              ),
            ),
    ),
  );
}

Widget buildRuasMaqueteLabelBadge(String text, {bool isBroken = false}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFF0F172A).withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: isBroken ? const Color(0xFFEF4444) : const Color(0xFF38BDF8),
        width: 1.2,
      ),
      boxShadow: const [
        BoxShadow(
          color: Colors.black38,
          blurRadius: 6,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Text(
      text,
      style: GoogleFonts.rajdhani(
        color: isBroken ? const Color(0xFFFCA5A5) : Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
  );
}

Widget buildRuasMaqueteSocketTile({
  required double width,
  required double height,
  required String expectedData,
  required bool isFilled,
  required VoidCallback onAccept,
  required VoidCallback onTap,
  required VoidCallback onRotate,
  required double rotation,
  required ComponentType symbolType,
  required String label,
  required bool usePhysicalStyle,
  double brightnessRatio = 1.0,
}) {
  final symSize = Size(width * 0.72, height * 0.72);
  final phSize = Size(width * 0.60, height * 0.60);

  final symbolWidget = usePhysicalStyle
      ? (symbolType == ComponentType.bulb
          ? CustomPaint(
              size: symSize,
              painter: StreetLampPainter(
                isActive: isFilled,
                brightnessRatio: brightnessRatio,
                isDarkMode: false,
              ),
            )
          : CustomPaint(
              size: symSize,
              painter: ComponentPhysicalPainter(
                type: symbolType,
                isDarkMode: false,
                wireKind: expectedData == 'junction_node'
                    ? 'junction'
                    : (expectedData == 'fio_paralelo' ? 'parallel' : 'series'),
              ),
            ))
      : CustomPaint(
          size: symSize,
          painter: CircuitSymbolPainter(
            type: symbolType,
            isActive: isFilled,
            isJunction: expectedData == 'junction_node',
            isParallel: expectedData == 'fio_paralelo',
            color: const Color(0xFF0F172A),
            strokeWidth: 2.5,
          ),
        );

  final placeholderWidget = usePhysicalStyle
      ? (symbolType == ComponentType.bulb
          ? CustomPaint(
              size: phSize,
              painter: StreetLampPainter(
                isActive: false,
                brightnessRatio: 0.0,
                isDarkMode: false,
              ),
            )
          : CustomPaint(
              size: phSize,
              painter: ComponentPhysicalPainter(
                type: symbolType,
                isDarkMode: false,
                wireKind: expectedData == 'junction_node'
                    ? 'junction'
                    : (expectedData == 'fio_paralelo' ? 'parallel' : 'series'),
              ),
            ))
      : CustomPaint(
          size: phSize,
          painter: CircuitSymbolPainter(
            type: symbolType,
            isJunction: expectedData == 'junction_node',
            isParallel: expectedData == 'fio_paralelo',
            color: const Color(0xFF94A3B8),
            strokeWidth: 2.0,
          ),
        );

  if (usePhysicalStyle) {
    return PhysicalBlueprintSocket<String>(
      width: width,
      height: height,
      expectedData: expectedData,
      isFilled: isFilled,
      onAccept: (_) => onAccept(),
      onTap: onTap,
      onRotate: onRotate,
      rotation: rotation,
      symbolWidget: symbolWidget,
      placeholderWidget: placeholderWidget,
      showLabel: label.isNotEmpty,
      label: label,
    );
  } else {
    return SchematicBlueprintSocket<String>(
      width: width,
      height: height,
      expectedData: expectedData,
      isFilled: isFilled,
      onAccept: (_) => onAccept(),
      onTap: onTap,
      onRotate: onRotate,
      rotation: rotation,
      symbolWidget: symbolWidget,
      placeholderWidget: placeholderWidget,
      showLabel: label.isNotEmpty,
      label: label,
    );
  }
}
