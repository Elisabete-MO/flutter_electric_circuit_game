import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../models/first_step_component.dart';
import '../../../models/sandbox_component.dart';
import '../../../models/sandbox_wire.dart';
import '../models/connection_source.dart';

// --- PAINTER DO GRID DE EDIÇÃO COM RETÍCULO HUD ---

class GridPainter extends CustomPainter {
  final int columns;
  final int rows;
  final bool isDark;
  final Offset? hoverCell;

  GridPainter({
    required this.columns,
    required this.rows,
    required this.isDark,
    this.hoverCell,
  });

  // Reutilização de objetos Paint para evitar alocações constantes
  static final Paint _gridLinePaint = Paint()..strokeWidth = 1.2;
  static final Paint _hoverBgPaint = Paint();
  static final Paint _bracketPaint = Paint()
    ..strokeWidth = 1.8
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    _gridLinePaint.color = isDark 
        ? Colors.white.withValues(alpha: 0.08) 
        : Colors.black.withValues(alpha: 0.05);

    final cellWidth = size.width / columns;
    final cellHeight = size.height / rows;

    // Linhas Verticais
    for (int i = 1; i < columns; i++) {
      final x = i * cellWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), _gridLinePaint);
    }

    // Linhas Horizontais
    for (int i = 1; i < rows; i++) {
      final y = i * cellHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), _gridLinePaint);
    }

    // Destaque de Célula Hover com Cantoneiras HUD (Cyber Reticle)
    if (hoverCell != null) {
      final gx = hoverCell!.dx.floor();
      final gy = hoverCell!.dy.floor();

      if (gx >= 0 && gx < columns && gy >= 0 && gy < rows) {
        final rect = Rect.fromLTWH(gx * cellWidth, gy * cellHeight, cellWidth, cellHeight);
        
        // Fundo sutil
        _hoverBgPaint.color = (isDark ? const Color(0xFF00F5D4) : const Color(0xFF00875A))
            .withValues(alpha: 0.06);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(6)),
          _hoverBgPaint,
        );

        // Cantoneiras HUD estilo cibernético
        _bracketPaint.color = isDark ? const Color(0xFF00F5D4) : const Color(0xFF00875A);

        const bLen = 8.0;
        final pad = 3.0;

        // Top-Left
        canvas.drawPath(Path()..moveTo(rect.left + pad + bLen, rect.top + pad)..lineTo(rect.left + pad, rect.top + pad)..lineTo(rect.left + pad, rect.top + pad + bLen), _bracketPaint);
        // Top-Right
        canvas.drawPath(Path()..moveTo(rect.right - pad - bLen, rect.top + pad)..lineTo(rect.right - pad, rect.top + pad)..lineTo(rect.right - pad, rect.top + pad + bLen), _bracketPaint);
        // Bottom-Left
        canvas.drawPath(Path()..moveTo(rect.left + pad + bLen, rect.bottom - pad)..lineTo(rect.left + pad, rect.bottom - pad)..lineTo(rect.left + pad, rect.bottom - pad - bLen), _bracketPaint);
        // Bottom-Right
        canvas.drawPath(Path()..moveTo(rect.right - pad - bLen, rect.bottom - pad)..lineTo(rect.right - pad, rect.bottom - pad)..lineTo(rect.right - pad, rect.bottom - pad - bLen), _bracketPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    return oldDelegate.columns != columns ||
        oldDelegate.rows != rows ||
        oldDelegate.isDark != isDark ||
        oldDelegate.hoverCell != hoverCell;
  }
}

// --- CHAVE DE CACHE PARA OS CAMINHOS DE FIO ---

class WirePathCacheKey {
  final Offset start;
  final Offset end;
  final bool isDiagramMode;
  final String componentHash;

  WirePathCacheKey(this.start, this.end, this.isDiagramMode, this.componentHash);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WirePathCacheKey &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end &&
          isDiagramMode == other.isDiagramMode &&
          componentHash == other.componentHash;

  @override
  int get hashCode => Object.hash(start, end, isDiagramMode, componentHash);
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
  final bool isShortCircuit;
  final Set<String> shortCircuitWireIds;
  final String? selectedWireId;

  WiresPainter({
    required this.wires,
    required this.components,
    required this.cellSize,
    required this.isDark,
    this.isDiagramMode = false,
    required this.isSimulating,
    required this.simulationValues,
    required this.animationValue,
    this.isShortCircuit = false,
    this.shortCircuitWireIds = const {},
    this.selectedWireId,
  });

  // Cache estático de caminhos para evitar recriação de Paths durante animação
  static final Map<WirePathCacheKey, Path> _pathCache = {};

  // Reutilização de objetos Paint para evitar alocações pesadas a cada frame
  static final Paint _selectPaint = Paint()
    ..color = const Color(0xFF00F5D4).withValues(alpha: 0.85)
    ..strokeWidth = 9.0
    ..style = PaintingStyle.stroke
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

  static final Paint _shortGlowPaint = Paint()
    ..style = PaintingStyle.stroke;

  static final Paint _shortCorePaint = Paint()
    ..color = const Color(0xFFFF1744)
    ..strokeWidth = 4.0
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  static final Paint _lightningYellowPaint = Paint()
    ..color = const Color(0xFFFFD54F).withValues(alpha: 0.9)
    ..strokeWidth = 2.0
    ..style = PaintingStyle.stroke;

  static final Paint _lightningWhitePaint = Paint()
    ..color = Colors.white
    ..strokeWidth = 1.0
    ..style = PaintingStyle.stroke;

  static final Paint _shadowPaint = Paint()
    ..color = Colors.black26
    ..strokeWidth = 5.5
    ..style = PaintingStyle.stroke
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

  static final Paint _baseWirePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  static final Paint _specularPaint = Paint()
    ..strokeWidth = 1.0
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  static final Paint _particlePaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;

  static final Paint _particleGlowPaint = Paint()
    ..color = const Color(0xFF00FF9D).withValues(alpha: 0.4)
    ..style = PaintingStyle.fill
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

  static final Paint _junctionDotPaint = Paint()
    ..style = PaintingStyle.fill;

  static final Paint _junctionBorderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    if (_pathCache.length > 500) {
      _pathCache.clear();
    }

    final componentHash = components.map((c) => '${c.id}_${c.gridX}_${c.gridY}_${c.rotation}').join('|');

    for (final wire in wires) {
      final fromCompList = components.where((c) => c.id == wire.fromComponentId).toList();
      final toCompList = components.where((c) => c.id == wire.toComponentId).toList();
      if (fromCompList.isEmpty || toCompList.isEmpty) continue;

      final fromComp = fromCompList.first;
      final toComp = toCompList.first;

      // Obtém as coordenadas relativas dos terminais
      final fromRelPos = fromComp.getTerminalPosition(wire.fromTerminal);
      final toRelPos = toComp.getTerminalPosition(wire.toTerminal);

      // Transforma para coordenadas absolutas em pixels
      final start = Offset(fromRelPos.dx * cellSize, fromRelPos.dy * cellSize);
      final end = Offset(toRelPos.dx * cellSize, toRelPos.dy * cellSize);

      final isShortWire = isShortCircuit && (shortCircuitWireIds.isEmpty || shortCircuitWireIds.contains(wire.id));
      final isSelected = wire.id == selectedWireId;

      // Rota eletricamente ativa se a simulação estiver rodando e ambos os componentes conectados tiverem corrente
      final isWireActive = isSimulating && 
          !isShortCircuit &&
          simulationValues['active_${fromComp.id}'] == 1.0 && 
          simulationValues['active_${toComp.id}'] == 1.0;

      // Usa cache para evitar reconstruir o Path do fio a cada frame animado
      final cacheKey = WirePathCacheKey(start, end, isDiagramMode, componentHash);
      final path = _pathCache[cacheKey] ??= buildSmartWirePath(
        start: start,
        end: end,
        cellSize: cellSize,
        isDiagramMode: isDiagramMode,
        components: components,
        fromComponentId: fromComp.id,
        toComponentId: toComp.id,
      );

      if (isSelected) {
        canvas.drawPath(path, _selectPaint);
      }

      // Cor Didática do Fio por Polaridade de Origem (Vermelho +, Azul -, Amarelo Sinal)
      final isFromPosPower = (fromComp.type == ComponentType.battery || fromComp.type == ComponentType.powerSupply) && wire.fromTerminal == 'B';
      final isToPosPower = (toComp.type == ComponentType.battery || toComp.type == ComponentType.powerSupply) && wire.toTerminal == 'B';

      final isFromNegPower = (fromComp.type == ComponentType.battery || fromComp.type == ComponentType.powerSupply) && wire.fromTerminal == 'A';
      final isToNegPower = (toComp.type == ComponentType.battery || toComp.type == ComponentType.powerSupply) && wire.toTerminal == 'A';

      final Color wireBaseColor;
      final Color wireGlowColor;

      if (isFromPosPower || isToPosPower) {
        wireBaseColor = const Color(0xFFE53935);
        wireGlowColor = const Color(0xFFFF3B7F);
      } else if (isFromNegPower || isToNegPower) {
        wireBaseColor = isDark ? const Color(0xFF1E88E5) : const Color(0xFF1565C0);
        wireGlowColor = const Color(0xFF00E5FF);
      } else {
        wireBaseColor = isDark ? const Color(0xFFFFB300) : const Color(0xFFFB8C00);
        wireGlowColor = const Color(0xFF00FF9D);
      }

      final wireColor = isWireActive ? wireGlowColor : wireBaseColor;

      if (isShortWire) {
        final pulse = 0.5 + 0.5 * math.sin(animationValue * math.pi * 6);
        final glowColor = const Color(0xFFFF3B7F);

        canvas.drawPath(
          path,
          _shortGlowPaint
            ..color = glowColor.withValues(alpha: 0.6 + pulse * 0.4)
            ..strokeWidth = 9.0 + pulse * 5.0
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4.0 + pulse * 6.0),
        );

        canvas.drawPath(path, _shortCorePaint);

        // Raios elétricos
        final lightningPath = Path();
        for (final metric in path.computeMetrics()) {
          final length = metric.length;
          bool isFirst = true;
          for (double d = 0; d <= length; d += 8.0) {
            final tangent = metric.getTangentForOffset(d);
            if (tangent != null) {
              final normal = Offset(-tangent.vector.dy, tangent.vector.dx);
              final jitter = math.sin((d * 0.5) + (animationValue * math.pi * 12)) * (4.0 + pulse * 3.0);
              final pt = tangent.position + normal * jitter;
              if (isFirst) {
                lightningPath.moveTo(pt.dx, pt.dy);
                isFirst = false;
              } else {
                lightningPath.lineTo(pt.dx, pt.dy);
              }
            }
          }
        }

        canvas.drawPath(lightningPath, _lightningYellowPaint);
        canvas.drawPath(lightningPath, _lightningWhitePaint);

        // Explosão de faíscas nos terminais
        for (final terminalPos in [start, end]) {
          const sparkCount = 6;
          for (int i = 0; i < sparkCount; i++) {
            final angle = (i * math.pi / 3) + (animationValue * math.pi * 4);
            final len = 6.0 + (pulse * 14.0);
            final p1 = terminalPos;
            final p2 = Offset(terminalPos.dx + len * math.cos(angle), terminalPos.dy + len * math.sin(angle));

            final sparkPaint = Paint()
              ..color = i % 2 == 0 ? const Color(0xFFFFD54F) : const Color(0xFFFF3B7F)
              ..strokeWidth = 2.0
              ..strokeCap = StrokeCap.round;

            canvas.drawLine(p1, p2, sparkPaint);
          }
          canvas.drawCircle(
            terminalPos,
            5.0 + pulse * 4.0,
            Paint()
              ..color = Colors.white.withValues(alpha: 0.9)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
          );
        }
      } else if (isDiagramMode) {
        canvas.drawPath(
          path,
          _baseWirePaint
            ..color = wireColor
            ..strokeWidth = isWireActive ? 3.2 : 2.4,
        );
      } else {
        // Sombra do Fio
        canvas.drawPath(path, _shadowPaint);

        // Fio de base
        canvas.drawPath(
          path,
          _baseWirePaint
            ..color = wireColor
            ..strokeWidth = isWireActive ? 4.2 : 3.5,
        );

        // Highlight especular central
        canvas.drawPath(
          path,
          _specularPaint..color = Colors.white.withValues(alpha: isWireActive ? 0.6 : 0.35),
        );
      }

      // Animação de fluxo de corrente (partículas de elétrons pulsantes/correndo)
      if (isWireActive) {
        for (final metric in path.computeMetrics()) {
          final length = metric.length;
          const double spacing = 24.0;
          final double initialOffset = animationValue * spacing;
          
          for (double d = initialOffset; d < length; d += spacing) {
            final tangent = metric.getTangentForOffset(d);
            if (tangent != null) {
              canvas.drawCircle(tangent.position, 2.0, _particlePaint);
              canvas.drawCircle(tangent.position, 4.5, _particleGlowPaint);
            }
          }
        }
      }
    }

    // Renderiza Nós de Junção Elétrica
    _junctionDotPaint.color = isDark ? const Color(0xFF00FF9D) : const Color(0xFF00875A);
    _junctionBorderPaint.color = (isDark ? const Color(0xFF00FF9D) : Colors.black87).withValues(alpha: 0.3);

    final terminalWireCounts = <String, Offset>{};
    for (final wire in wires) {
      final fromComp = components.where((c) => c.id == wire.fromComponentId).firstOrNull;
      final toComp = components.where((c) => c.id == wire.toComponentId).firstOrNull;
      if (fromComp != null && toComp != null) {
        final fromPos = fromComp.getTerminalPosition(wire.fromTerminal);
        final toPos = toComp.getTerminalPosition(wire.toTerminal);

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
        canvas.drawCircle(pos, 4.5, _junctionDotPaint);
        canvas.drawCircle(pos, 6.5, _junctionBorderPaint);
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
        oldDelegate.animationValue != animationValue ||
        oldDelegate.isShortCircuit != isShortCircuit ||
        oldDelegate.shortCircuitWireIds != shortCircuitWireIds ||
        oldDelegate.selectedWireId != selectedWireId;
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

    final fromRel = fromComp.getTerminalPosition(source.terminal);
    final start = Offset(fromRel.dx * cellSize, fromRel.dy * cellSize);

    Offset? end;
    if (snappedTarget != null) {
      final toCompList = components.where((c) => c.id == snappedTarget!.componentId).toList();
      if (toCompList.isNotEmpty) {
        final toComp = toCompList.first;
        final toRel = toComp.getTerminalPosition(snappedTarget!.terminal);
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

  static final Paint _tempShadowPaint = Paint()
    ..color = Colors.black38
    ..style = PaintingStyle.stroke
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

  static final Paint _tempBasePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  static final Paint _tempSpecularPaint = Paint()
    ..color = Colors.white.withValues(alpha: 0.9)
    ..strokeWidth = 1.5
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  static final Paint _tempGlowPaint = Paint()
    ..color = const Color(0xFF00F5D4).withValues(alpha: 0.4)
    ..style = PaintingStyle.fill
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

  static final Paint _tempBorderPaint = Paint()
    ..color = const Color(0xFF00F5D4)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  static final Paint _tempLockPaint = Paint()
    ..color = const Color(0xFF00FF9D)
    ..strokeWidth = 1.5
    ..style = PaintingStyle.stroke;

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
      _tempShadowPaint..strokeWidth = isSnapped ? 6.0 : 4.0,
    );

    // 2. Fio Temporário em tom Neon Cyan
    canvas.drawPath(
      path,
      _tempBasePaint
        ..color = isSnapped
            ? const Color(0xFF00F5D4)
            : (isDark ? const Color(0xFF00F5D4).withValues(alpha: 0.7) : const Color(0xFF00875A).withValues(alpha: 0.6))
        ..strokeWidth = isSnapped ? 4.0 : 3.0,
    );

    // 3. Brilho Neon Especular se Magnetizado
    if (isSnapped) {
      canvas.drawPath(path, _tempSpecularPaint);

      // Efeito de pulso e auréola magnética
      canvas.drawCircle(end, 18.0, _tempGlowPaint);
      canvas.drawCircle(end, 13.0, _tempBorderPaint);

      // Retículo de Mira Cibernética no Alvo
      const arm = 6.0;
      canvas.drawLine(Offset(end.dx - 18, end.dy), Offset(end.dx - 18 + arm, end.dy), _tempLockPaint);
      canvas.drawLine(Offset(end.dx + 18, end.dy), Offset(end.dx + 18 - arm, end.dy), _tempLockPaint);
      canvas.drawLine(Offset(end.dx, end.dy - 18), Offset(end.dx, end.dy - 18 + arm), _tempLockPaint);
      canvas.drawLine(Offset(end.dx, end.dy + 18), Offset(end.dx, end.dy + 18 - arm), _tempLockPaint);
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

// --- PAINTER DE FAÍSCA DE CONEXÃO ELÉTRICA (SPARK BURST) ---

class ConnectionSparkPainter extends CustomPainter {
  final Offset position;
  final double progress;

  ConnectionSparkPainter({required this.position, required this.progress});

  static final Paint _sparkCyanPaint = Paint()
    ..strokeWidth = 2.2
    ..strokeCap = StrokeCap.round;

  static final Paint _sparkGoldPaint = Paint()
    ..strokeWidth = 1.6
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress >= 1.0) return;

    final alpha = (1.0 - progress).clamp(0.0, 1.0);
    _sparkCyanPaint.color = const Color(0xFF00F5D4).withValues(alpha: alpha);
    _sparkGoldPaint.color = const Color(0xFFFFD54F).withValues(alpha: alpha);

    const int count = 8;
    for (int i = 0; i < count; i++) {
      final angle = (i * math.pi / 4) + (progress * 0.4);
      final innerDist = progress * 6.0;
      final outerDist = progress * 22.0 + 5.0;

      final p1 = Offset(position.dx + innerDist * math.cos(angle), position.dy + innerDist * math.sin(angle));
      final p2 = Offset(position.dx + outerDist * math.cos(angle), position.dy + outerDist * math.sin(angle));

      canvas.drawLine(p1, p2, i % 2 == 0 ? _sparkCyanPaint : _sparkGoldPaint);
    }

    // Flash central de impacto luminoso
    canvas.drawCircle(
      position,
      (1.0 - progress) * 10.0,
      Paint()
        ..color = Colors.white.withValues(alpha: alpha * 0.95)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );
  }

  @override
  bool shouldRepaint(covariant ConnectionSparkPainter oldDelegate) {
    return oldDelegate.position != position || oldDelegate.progress != progress;
  }
}

Path buildSmartWirePath({
  required Offset start,
  required Offset end,
  required double cellSize,
  required bool isDiagramMode,
  required List<SandboxComponent> components,
  String? fromComponentId,
  String? toComponentId,
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
    // Modo Físico Realista Orgânico (Catenária fluida de alta fidelidade física)
    final minX = math.min(start.dx, end.dx);
    final maxX = math.max(start.dx, end.dx);

    // Identifica se há componentes intermediários no caminho horizontal entre start e end
    double maxObstacleBottomY = 0.0;
    bool hasIntermediateObstacle = false;

    for (final comp in components) {
      if (comp.id == fromComponentId || comp.id == toComponentId) {
        continue; // Não considera o próprio componente de origem ou destino como obstáculo
      }

      final compLeft = comp.gridX * cellSize;
      final compRight = (comp.gridX + 1) * cellSize;
      final compBottom = (comp.gridY + 1) * cellSize;

      if (compRight > minX + 5 && compLeft < maxX - 5) {
        final compTop = comp.gridY * cellSize;
        if (math.min(start.dy, end.dy) <= compBottom && math.max(start.dy, end.dy) >= compTop - 10) {
          hasIntermediateObstacle = true;
          if (compBottom > maxObstacleBottomY) {
            maxObstacleBottomY = compBottom;
          }
        }
      }
    }

    final startIsLeft = (start.dx % cellSize) < (cellSize / 2);
    final endIsLeft = (end.dx % cellSize) < (cellSize / 2);

    final dist = (end - start).distance;
    final absDx = (end.dx - start.dx).abs();
    final isLongSpan = dist > cellSize * 1.4;

    if (hasIntermediateObstacle || (isLongSpan && (start.dy - end.dy).abs() < 10)) {
      // Conexão de longa distância (sobrevoando/subvoando outros cartões)
      final startRowBottom = ((start.dy / cellSize).floor() + 1.0) * cellSize;
      final endRowBottom = ((end.dy / cellSize).floor() + 1.0) * cellSize;
      final cardBottomY = math.max(startRowBottom, endRowBottom);
      final targetBottom = hasIntermediateObstacle ? math.max(maxObstacleBottomY, cardBottomY) : cardBottomY;

      final baseSag = (dist * 0.22).clamp(18.0, 55.0);
      double controlY = math.max(targetBottom + 20.0, math.max(start.dy, end.dy) + baseSag);

      if (isReturn) {
        controlY += 14.0;
      }

      final cp1X = startIsLeft ? start.dx - 22.0 : start.dx + 22.0;
      final cp2X = endIsLeft ? end.dx - 22.0 : end.dx + 22.0;

      path.cubicTo(
        cp1X,
        controlY,
        cp2X,
        controlY,
        end.dx,
        end.dy,
      );
    } else {
      // Determina a direção de saída do pino (normal) baseado na posição dele na célula
      Offset getExitVector(Offset pt) {
        final relX = (pt.dx % cellSize) / cellSize;
        final relY = (pt.dy % cellSize) / cellSize;
        if (relY < 0.2) return const Offset(0, -1); // Sai para cima
        if (relY > 0.8) return const Offset(0, 1);  // Sai para baixo
        if (relX < 0.5) return const Offset(-1, 0); // Sai para esquerda
        return const Offset(1, 0);                  // Sai para direita
      }

      final outStart = getExitVector(start);
      final outEnd = getExitVector(end);

      final armLen = math.min(32.0, math.max(12.0, dist * 0.3));

      final cp1X = start.dx + outStart.dx * armLen;
      final cp1Y = start.dy + outStart.dy * armLen + (outStart.dy == 0 ? armLen * 0.5 : 0); // Leve gravidade
      
      final cp2X = end.dx + outEnd.dx * armLen;
      final cp2Y = end.dy + outEnd.dy * armLen + (outEnd.dy == 0 ? armLen * 0.5 : 0);

      path.cubicTo(
        cp1X,
        cp1Y,
        cp2X,
        cp2Y,
        end.dx,
        end.dy,
      );
    }
  }

  return path;
}

// --- PAINTER DE SELEÇÃO POR CAIXA (MARQUEE SELECTION) ---

class MarqueeSelectionPainter extends CustomPainter {
  final Offset start;
  final Offset current;
  final bool isDark;

  MarqueeSelectionPainter({
    required this.start,
    required this.current,
    required this.isDark,
  });

  static final Paint _marqueeFillPaint = Paint();
  static final Paint _marqueeBorderPaint = Paint()
    ..strokeWidth = 1.6
    ..style = PaintingStyle.stroke;
  static final Paint _marqueeBracketPaint = Paint()
    ..strokeWidth = 2.4
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromPoints(start, current);

    // 1. Fundo semitransparente estilo HUD néon
    _marqueeFillPaint.color = isDark
        ? const Color(0xFF00F5D4).withValues(alpha: 0.12)
        : const Color(0xFF00875A).withValues(alpha: 0.10);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      _marqueeFillPaint,
    );

    // 2. Borda externa em tom Cyber Neon
    final borderColor = isDark ? const Color(0xFF00F5D4) : const Color(0xFF00875A);
    _marqueeBorderPaint.color = borderColor.withValues(alpha: 0.8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      _marqueeBorderPaint,
    );

    // 3. Cantoneiras de mira ciber (Cyber Corner Reticles)
    _marqueeBracketPaint.color = borderColor;

    final bLen = math.min(12.0, math.min(rect.width.abs(), rect.height.abs()) / 3);

    // Top-Left
    canvas.drawPath(Path()..moveTo(rect.left + bLen, rect.top)..lineTo(rect.left, rect.top)..lineTo(rect.left, rect.top + bLen), _marqueeBracketPaint);
    // Top-Right
    canvas.drawPath(Path()..moveTo(rect.right - bLen, rect.top)..lineTo(rect.right, rect.top)..lineTo(rect.right, rect.top + bLen), _marqueeBracketPaint);
    // Bottom-Left
    canvas.drawPath(Path()..moveTo(rect.left + bLen, rect.bottom)..lineTo(rect.left, rect.bottom)..lineTo(rect.left, rect.bottom - bLen), _marqueeBracketPaint);
    // Bottom-Right
    canvas.drawPath(Path()..moveTo(rect.right - bLen, rect.bottom)..lineTo(rect.right, rect.bottom)..lineTo(rect.right, rect.bottom - bLen), _marqueeBracketPaint);
  }

  @override
  bool shouldRepaint(covariant MarqueeSelectionPainter oldDelegate) {
    return oldDelegate.start != start ||
        oldDelegate.current != current ||
        oldDelegate.isDark != isDark;
  }
}
