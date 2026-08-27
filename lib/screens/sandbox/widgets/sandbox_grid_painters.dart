import 'package:flutter/material.dart';
import '../../../models/sandbox_component.dart';
import '../../../models/sandbox_wire.dart';
import '../models/connection_source.dart';

// --- PAINTER DO GRID DE EDIÇÃO ---

class GridPainter extends CustomPainter {
  final int columns;
  final int rows;
  final bool isDark;

  GridPainter({required this.columns, required this.rows, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05)
      ..strokeWidth = 1.2;

    final cellWidth = size.width / columns;
    final cellHeight = size.height / rows;

    // Linhas Verticais
    for (int i = 1; i < columns; i++) {
      final x = i * cellWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Linhas Horizontais
    for (int i = 1; i < rows; i++) {
      final y = i * cellHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- PAINTER DOS FIOS CONECTADOS ---

class WiresPainter extends CustomPainter {
  final List<SandboxWire> wires;
  final List<SandboxComponent> components;
  final double cellSize;
  final bool isDark;
  final bool isDiagramMode;
  final bool isSimulating;
  final Map<String, double> simulationValues;
  final double animationValue;

  WiresPainter({
    required this.wires,
    required this.components,
    required this.cellSize,
    required this.isDark,
    this.isDiagramMode = false,
    required this.isSimulating,
    required this.simulationValues,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final wire in wires) {
      final fromCompList = components.where((c) => c.id == wire.fromComponentId).toList();
      final toCompList = components.where((c) => c.id == wire.toComponentId).toList();
      if (fromCompList.isEmpty || toCompList.isEmpty) continue;

      final fromComp = fromCompList.first;
      final toComp = toCompList.first;

      // Obtém as coordenadas relativas dos terminais A ou B
      final fromRelPos = wire.fromTerminal == 'A' ? fromComp.getTerminalAPosition() : fromComp.getTerminalBPosition();
      final toRelPos = wire.toTerminal == 'A' ? toComp.getTerminalAPosition() : toComp.getTerminalBPosition();

      // Transforma para coordenadas absolutas em pixels
      final start = Offset(fromRelPos.dx * cellSize, fromRelPos.dy * cellSize);
      final end = Offset(toRelPos.dx * cellSize, toRelPos.dy * cellSize);

      // Rota eletricamente ativa se a simulação estiver rodando e ambos os componentes conectados tiverem corrente
      final isWireActive = isSimulating && 
          simulationValues['active_${fromComp.id}'] == 1.0 && 
          simulationValues['active_${toComp.id}'] == 1.0;

      // Desenha o cabo elétrico com Roteamento Inteligente (Ortogonal para Diagrama, Curvo para Físico)
      final path = _buildSmartWirePath(
        start: start,
        end: end,
        cellSize: cellSize,
        isDiagramMode: isDiagramMode,
        components: components,
      );

      if (isDiagramMode) {
        // Estilo Diagrama Esquemático: Linhas limpas e nítidas
        final wireColor = isWireActive
            ? const Color(0xFF00FF9D)
            : (isDark ? const Color(0xFF00F5D4) : Colors.black87);

        canvas.drawPath(
          path,
          Paint()
            ..color = wireColor
            ..strokeWidth = isWireActive ? 3.0 : 2.2
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round,
        );
      } else {
        // Estilo Físico Volumétrico 3D com Sombra e Brilho Especular
        // 1. Sombra do Fio
        canvas.drawPath(
          path,
          Paint()
            ..color = Colors.black26
            ..strokeWidth = 5.0
            ..style = PaintingStyle.stroke
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
        );

        // 2. Fio de base
        canvas.drawPath(
          path,
          Paint()
            ..color = isWireActive
                ? const Color(0xFF00FF9D).withValues(alpha: 0.8)
                : (isDark ? Colors.blueGrey.shade700 : Colors.grey.shade400)
            ..strokeWidth = 3.5
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round,
        );

        // 3. Highlight especular central para efeito 3D metálico
        canvas.drawPath(
          path,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.4)
            ..strokeWidth = 1.0
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round,
        );
      }

      // 4. Animação de fluxo de corrente (partículas de elétrons pulsantes/correndo)
      if (isWireActive) {
        final paintParticle = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        
        for (final metric in path.computeMetrics()) {
          final length = metric.length;
          const double spacing = 24.0;
          final double initialOffset = animationValue * spacing;
          
          for (double d = initialOffset; d < length; d += spacing) {
            final tangent = metric.getTangentForOffset(d);
            if (tangent != null) {
              // Desenha o elétron como um círculo branco brilhante
              canvas.drawCircle(tangent.position, 2.0, paintParticle);
              
              // Efeito de brilho ao redor do elétron
              canvas.drawCircle(
                tangent.position, 
                4.5, 
                Paint()
                  ..color = const Color(0xFF00FF9D).withValues(alpha: 0.4)
                  ..style = PaintingStyle.fill
                  ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1),
              );
            }
          }
        }
      }
    }

    // 5. Renderiza Nós de Junção Elétrica (T-Junction Dots) em conexões múltiplas
    final junctionPaint = Paint()
      ..color = isDark ? const Color(0xFF00FF9D) : const Color(0xFF00875A)
      ..style = PaintingStyle.fill;

    final terminalWireCounts = <String, Offset>{};
    for (final wire in wires) {
      final fromComp = components.where((c) => c.id == wire.fromComponentId).firstOrNull;
      final toComp = components.where((c) => c.id == wire.toComponentId).firstOrNull;
      if (fromComp != null && toComp != null) {
        final fromPos = wire.fromTerminal == 'A' ? fromComp.getTerminalAPosition() : fromComp.getTerminalBPosition();
        final toPos = wire.toTerminal == 'A' ? toComp.getTerminalAPosition() : toComp.getTerminalBPosition();

        final fromKey = '${wire.fromComponentId}_${wire.fromTerminal}';
        final toKey = '${wire.toComponentId}_${wire.toTerminal}';

        terminalWireCounts[fromKey] = Offset(fromPos.dx * cellSize, fromPos.dy * cellSize);
        terminalWireCounts[toKey] = Offset(toPos.dx * cellSize, toPos.dy * cellSize);
      }
    }

    for (final entry in terminalWireCounts.entries) {
      final connectedWireCount = wires.where((w) =>
          '${w.fromComponentId}_${w.fromTerminal}' == entry.key ||
          '${w.toComponentId}_${w.toTerminal}' == entry.key).length;

      if (connectedWireCount >= 2) {
        final pos = entry.value;
        canvas.drawCircle(pos, 4.5, junctionPaint);
        canvas.drawCircle(
          pos,
          6.5,
          Paint()
            ..color = (isDark ? const Color(0xFF00FF9D) : Colors.black87).withValues(alpha: 0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant WiresPainter oldDelegate) {
    return oldDelegate.wires != wires ||
        oldDelegate.components != components ||
        oldDelegate.cellSize != cellSize ||
        oldDelegate.isDark != isDark ||
        oldDelegate.isDiagramMode != isDiagramMode ||
        oldDelegate.isSimulating != isSimulating ||
        oldDelegate.simulationValues != simulationValues ||
        oldDelegate.animationValue != animationValue;
  }
}

// --- CAMADA VISUAL DE FIO TEMPORÁRIO (ENQUANTO ARRASTA) ---

class TemporaryWireLayer extends StatelessWidget {
  final ConnectionSource source;
  final ConnectionSource? snappedTarget;
  final Offset? mousePosition;
  final List<SandboxComponent> components;
  final double cellSize;
  final bool isDark;

  const TemporaryWireLayer({
    super.key,
    required this.source,
    this.snappedTarget,
    this.mousePosition,
    required this.components,
    required this.cellSize,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final fromCompList = components.where((c) => c.id == source.componentId).toList();
    if (fromCompList.isEmpty) return const SizedBox.shrink();
    final fromComp = fromCompList.first;

    final fromRel = source.terminal == 'A' ? fromComp.getTerminalAPosition() : fromComp.getTerminalBPosition();
    final start = Offset(fromRel.dx * cellSize, fromRel.dy * cellSize);

    Offset? end;
    if (snappedTarget != null) {
      final toCompList = components.where((c) => c.id == snappedTarget!.componentId).toList();
      if (toCompList.isNotEmpty) {
        final toComp = toCompList.first;
        final toRel = snappedTarget!.terminal == 'A' ? toComp.getTerminalAPosition() : toComp.getTerminalBPosition();
        end = Offset(toRel.dx * cellSize, toRel.dy * cellSize);
      }
    }
    end ??= mousePosition;

    if (end == null) return const SizedBox.shrink();

    return CustomPaint(
      painter: _TempWirePainter(
        start: start,
        currentEnd: end,
        isSnapped: snappedTarget != null,
        isDark: isDark,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _TempWirePainter extends CustomPainter {
  final Offset start;
  final Offset? currentEnd;
  final bool isSnapped;
  final bool isDark;

  _TempWirePainter({
    required this.start,
    required this.currentEnd,
    required this.isSnapped,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final end = currentEnd;
    if (end == null) return;

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        (start.dx + end.dx) / 2, start.dy,
        (start.dx + end.dx) / 2, end.dy,
        end.dx, end.dy,
      );

    // 1. Sombra do Fio Temporário
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black38
        ..strokeWidth = isSnapped ? 6.0 : 4.0
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    // 2. Fio Temporário em tom Neon Cyan com espessura maior se magnetizado
    canvas.drawPath(
      path,
      Paint()
        ..color = isSnapped
            ? const Color(0xFF00F5D4)
            : (isDark ? const Color(0xFF00F5D4).withValues(alpha: 0.7) : const Color(0xFF00875A).withValues(alpha: 0.6))
        ..strokeWidth = isSnapped ? 4.0 : 3.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // 3. Brilho Neon Especular se Magnetizado
    if (isSnapped) {
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.9)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );

      // Efeito de pulso e auréola magnética no ponto de conexão alvo
      canvas.drawCircle(
        end,
        18.0,
        Paint()
          ..color = const Color(0xFF00F5D4).withValues(alpha: 0.4)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );

      canvas.drawCircle(
        end,
        13.0,
        Paint()
          ..color = const Color(0xFF00F5D4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TempWirePainter oldDelegate) {
    return oldDelegate.start != start ||
        oldDelegate.currentEnd != currentEnd ||
        oldDelegate.isSnapped != isSnapped ||
        oldDelegate.isDark != isDark;
  }
}

Path _buildSmartWirePath({
  required Offset start,
  required Offset end,
  required double cellSize,
  required bool isDiagramMode,
  required List<SandboxComponent> components,
}) {
  final path = Path()..moveTo(start.dx, start.dy);

  final dx = end.dx - start.dx;
  final dy = end.dy - start.dy;

  // Detecta se é um fio de retorno (da direita para a esquerda)
  final isReturn = dx < -10;

  if (isDiagramMode) {
    if (isReturn) {
      // Roteamento ortogonal de retorno por baixo dos componentes
      double maxY = start.dy > end.dy ? start.dy : end.dy;
      for (final comp in components) {
        final compY = (comp.gridY + 1) * cellSize;
        if (compY > maxY) maxY = compY;
      }
      final routeY = maxY + (cellSize * 0.4);
      const radius = 12.0;

      path.lineTo(start.dx + 20 - radius, start.dy);
      path.quadraticBezierTo(start.dx + 20, start.dy, start.dx + 20, start.dy + radius);
      path.lineTo(start.dx + 20, routeY - radius);
      path.quadraticBezierTo(start.dx + 20, routeY, start.dx + 20 - radius, routeY);
      path.lineTo(end.dx - 20 + radius, routeY);
      path.quadraticBezierTo(end.dx - 20, routeY, end.dx - 20, routeY - radius);
      path.lineTo(end.dx - 20, end.dy + radius);
      path.quadraticBezierTo(end.dx - 20, end.dy, end.dx - 20 + radius, end.dy);
      path.lineTo(end.dx, end.dy);
    } else if (dy.abs() < 5) {
      // Linha direta reta horizontal
      path.lineTo(end.dx, end.dy);
    } else {
      // Degrau ortogonal Z/L suave
      final midX = start.dx + dx / 2;
      const radius = 10.0;
      final ySign = dy > 0 ? 1 : -1;

      path.lineTo(midX - radius, start.dy);
      path.quadraticBezierTo(midX, start.dy, midX, start.dy + radius * ySign);
      path.lineTo(midX, end.dy - radius * ySign);
      path.quadraticBezierTo(midX, end.dy, midX + radius, end.dy);
      path.lineTo(end.dx, end.dy);
    }
  } else {
    // Modo Físico Realista (Cabo curvo por gravidade)
    if (isReturn) {
      double maxY = start.dy > end.dy ? start.dy : end.dy;
      for (final comp in components) {
        final compY = (comp.gridY + 1) * cellSize;
        if (compY > maxY) maxY = compY;
      }
      final routeY = maxY + (cellSize * 0.6);

      path.cubicTo(
        start.dx + 40, routeY,
        end.dx - 40, routeY,
        end.dx, end.dy,
      );
    } else {
      path.cubicTo(
        (start.dx + end.dx) / 2, start.dy,
        (start.dx + end.dx) / 2, end.dy,
        end.dx, end.dy,
      );
    }
  }

  return path;
}
