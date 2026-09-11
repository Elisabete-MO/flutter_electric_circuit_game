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
  bool isUnscrewed = false,
}) {
  final compW = width * 0.75;
  final compH = height * 0.75;

  return SizedBox(
    width: width,
    height: height,
    child: Center(
      child: usePhysicalStyle
          ? Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(compW, compH),
                  painter: StreetLampPainter(
                    isActive: isLit && !isUnscrewed,
                    brightnessRatio: isUnscrewed ? 0.0 : brightnessRatio,
                    isDarkMode: false,
                  ),
                ),
                if (isUnscrewed)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded,
                          size: 14, color: Colors.white),
                    ),
                  ),
              ],
            )
          : CustomPaint(
              size: Size(compW * 0.9, compH * 0.9),
              painter: CircuitSymbolPainter(
                type: ComponentType.bulb,
                isActive: isLit && !isUnscrewed,
                isBurned: isUnscrewed,
                color: const Color(0xFF0F172A),
                strokeWidth: 2.5,
              ),
            ),
    ),
  );
}

/// Widget interativo de poste da maquete com suporte a clique para desrosquear/rosquear lâmpada
Widget buildRuasMaqueteInteractiveLamp({
  required String label,
  required bool isLit,
  required double brightnessRatio,
  required bool usePhysicalStyle,
  required bool isUnscrewed,
  required VoidCallback onToggleUnscrew,
  double width = 100,
  double height = 80,
  String? probeVoltageText,
}) {
  return GestureDetector(
    onTap: onToggleUnscrew,
    behavior: HitTestBehavior.opaque,
    child: Tooltip(
      message: isUnscrewed
          ? 'Lâmpada desrosqueada (aberta). Toque para rosquear.'
          : 'Toque para desrosquear a lâmpada!',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              buildRuasMaqueteLampSymbol(
                isLit: isLit,
                brightnessRatio: brightnessRatio,
                usePhysicalStyle: usePhysicalStyle,
                width: width,
                height: height,
                isUnscrewed: isUnscrewed,
              ),
              if (probeVoltageText != null)
                Positioned(
                  top: -14,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 4),
                      ],
                    ),
                    child: Text(
                      probeVoltageText,
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          buildRuasMaqueteLabelBadge(
            label,
            isBroken: isUnscrewed,
            subtitle: isUnscrewed ? '(Desrosqueada)' : '(Rosqueada)',
          ),
        ],
      ),
    ),
  );
}

/// Casa residencial realista em maquete (vista superior / top-down)
Widget buildRuasMaqueteHouseSymbol({
  required String name,
  required bool isLit,
  required double brightness,
  bool isBroken = false,
  required bool usePhysicalStyle,
  double width = 85,
  double height = 75,
  VoidCallback? onToggle,
}) {
  final compW = width * 0.82;
  final compH = height * 0.82;

  Widget content;
  if (usePhysicalStyle) {
    final roofColor = isBroken
        ? const Color(0xFF7F1D1D)
        : (isLit ? const Color(0xFF9A3412) : const Color(0xFF475569));
    final windowGlow = isLit && !isBroken;

    content = Container(
      width: compW,
      height: compH,
      decoration: BoxDecoration(
        color: roofColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isBroken
              ? const Color(0xFFEF4444)
              : (isLit ? const Color(0xFFF59E0B) : const Color(0xFF64748B)),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 6,
            offset: const Offset(2, 3),
          ),
          if (windowGlow)
            BoxShadow(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.45 * brightness),
              blurRadius: 16,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Linha divisória da cumeeira do telhado da maquete
          Positioned(
            left: 0,
            right: 0,
            top: compH / 2 - 1,
            child: Container(
              height: 2,
              color: Colors.black.withValues(alpha: 0.25),
            ),
          ),
          // Claraboia/Janela de teto iluminada
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: compW * 0.36,
            height: compH * 0.36,
            decoration: BoxDecoration(
              color: windowGlow
                  ? const Color(0xFFFEF08A)
                  : const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: windowGlow
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFF334155),
                width: 1.5,
              ),
              boxShadow: windowGlow
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFEF08A)
                            .withValues(alpha: 0.8 * brightness),
                        blurRadius: 8,
                      )
                    ]
                  : null,
            ),
            child: Icon(
              isBroken
                  ? Icons.warning_amber_rounded
                  : (windowGlow
                      ? Icons.lightbulb_rounded
                      : Icons.lightbulb_outline_rounded),
              size: 16,
              color: windowGlow
                  ? const Color(0xFFD97706)
                  : (isBroken
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF64748B)),
            ),
          ),
          // Chaminé de maquete
          Positioned(
            top: 4,
            right: 6,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF334155),
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: const Color(0xFF94A3B8), width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  } else {
    content = CustomPaint(
      size: Size(compW * 0.9, compH * 0.9),
      painter: CircuitSymbolPainter(
        type: ComponentType.bulb,
        isActive: isLit && !isBroken,
        isBurned: isBroken,
        color: const Color(0xFF0F172A),
        strokeWidth: 2.5,
      ),
    );
  }

  return SizedBox(
    width: width,
    height: height,
    child: Center(
      child: onToggle != null
          ? GestureDetector(
              onTap: onToggle,
              child: content,
            )
          : content,
    ),
  );
}

/// Casa interativa completa com etiqueta e botão de disjuntor/interruptor
Widget buildRuasMaqueteInteractiveHouse({
  required String label,
  required bool isLit,
  required double brightness,
  required bool isBroken,
  required bool usePhysicalStyle,
  required VoidCallback onToggle,
  double width = 110,
  double height = 90,
}) {
  return GestureDetector(
    onTap: onToggle,
    behavior: HitTestBehavior.opaque,
    child: Tooltip(
      message: isBroken
          ? 'Casa desconectada (circuito aberto). Toque para restabelecer.'
          : 'Toque para abrir a chave de teste da casa!',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildRuasMaqueteHouseSymbol(
            name: label,
            isLit: isLit,
            brightness: brightness,
            isBroken: isBroken,
            usePhysicalStyle: usePhysicalStyle,
            width: width,
            height: height,
            onToggle: onToggle,
          ),
          const SizedBox(height: 4),
          buildRuasMaqueteLabelBadge(
            label,
            isBroken: isBroken,
            subtitle: isBroken ? '(Desligada)' : '(Conectada)',
          ),
        ],
      ),
    ),
  );
}

/// Mini-Voltímetro digital portátil para bancada (Missão 2)
Widget buildRuasMaqueteVoltmeterProbe({
  required double measuredVoltage,
  required String targetLabel,
  required VoidCallback onSwitchTarget,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFF0F172A),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFF0284C7), width: 1.5),
      boxShadow: const [
        BoxShadow(
          color: Colors.black45,
          blurRadius: 8,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(
            Icons.speed_rounded,
            size: 16,
            color: Color(0xFF38BDF8),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'VOLTÍMETRO: ',
                  style: GoogleFonts.rajdhani(
                    color: const Color(0xFF94A3B8),
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                Text(
                  targetLabel,
                  style: GoogleFonts.rajdhani(
                    color: const Color(0xFF38BDF8),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFF022C22),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFF059669)),
              ),
              child: Text(
                '${measuredVoltage.toStringAsFixed(2)} V',
                style: GoogleFonts.shareTechMono(
                  color: const Color(0xFF34D399),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: onSwitchTarget,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0284C7),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.touch_app_rounded,
                    size: 12, color: Colors.white),
                const SizedBox(width: 3),
                Text(
                  'Medir Outro',
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

/// Bloco de Derivação / Conector de Nós (Missão 3 e 4)
Widget buildRuasMaqueteJunctionBlock({
  required bool isConnected,
  required VoidCallback onTap,
  double size = 44,
}) {
  return GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Tooltip(
      message: isConnected
          ? 'Nó de derivação conectado! Toque para desconectar.'
          : 'Toque para plugar o nó de derivação!',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isConnected ? const Color(0xFF0284C7) : const Color(0xFF334155),
          shape: BoxShape.circle,
          border: Border.all(
            color: isConnected ? const Color(0xFF38BDF8) : const Color(0xFF94A3B8),
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isConnected
                  ? const Color(0xFF0284C7).withValues(alpha: 0.5)
                  : Colors.black26,
              blurRadius: 8,
              spreadRadius: isConnected ? 1 : 0,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            isConnected ? Icons.hub_rounded : Icons.radio_button_unchecked,
            size: size * 0.55,
            color: isConnected ? Colors.white : const Color(0xFF94A3B8),
          ),
        ),
      ),
    ),
  );
}

Widget buildRuasMaqueteLabelBadge(
  String text, {
  bool isBroken = false,
  String? subtitle,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: const Color(0xFF0F172A).withValues(alpha: 0.88),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(
        color: isBroken ? const Color(0xFFEF4444) : const Color(0xFF38BDF8),
        width: 1.2,
      ),
      boxShadow: const [
        BoxShadow(
          color: Colors.black38,
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: GoogleFonts.rajdhani(
            color: isBroken ? const Color(0xFFFCA5A5) : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle != null)
          Text(
            subtitle,
            style: GoogleFonts.rajdhani(
              color: isBroken
                  ? const Color(0xFFF87171)
                  : const Color(0xFF94A3B8),
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
      ],
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
