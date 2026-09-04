import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/component_terminals.dart';
import '../models/first_step_component.dart';

/// Painter realista para fios de circuito com isolamento colorido,
/// sombra projetada, brilho especular e elétrons animados.
/// Fios orgânicos de bancada com curvas de catenária.
class RealisticWirePainter extends CustomPainter {
  final List<WirePath> wires;
  final double animationValue;
  final bool showElectrons;

  RealisticWirePainter({
    required this.wires,
    this.animationValue = 0.0,
    this.showElectrons = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final wire in wires) {
      _drawWire(canvas, size, wire);
    }
  }

  void _drawWire(Canvas canvas, Size size, WirePath wire) {
    final path = _buildFlexibleWirePath(wire.points);
    final isActive = wire.isActive;
    final color = wire.color;

    // 1. Sombra projetada do fio (idêntica ao Estande 4)
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..strokeWidth = 6.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path.shift(const Offset(1.5, 2.5)), shadowPaint);

    // 2. Isolamento do fio (Vermelho / Laranja / Azul)
    final insulationPaint = Paint()
      ..color = isActive ? color : color.withValues(alpha: 0.5)
      ..strokeWidth = 4.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, insulationPaint);

    // 3. Brilho especular no topo do fio (reflexo de luz idêntico ao Estande 4)
    final specularPaint = Paint()
      ..color = Colors.white.withValues(alpha: isActive ? 0.40 : 0.20)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path.shift(const Offset(0, -1.2)), specularPaint);

    // 4. Bornes/pontos de solda em cobre metálico
    _drawTerminalSpots(canvas, wire);

    // 5. Elétrons animados amarelos com brilho (glow)
    if (isActive && showElectrons) {
      _drawElectrons(canvas, path, wire);
    }
  }

  void _drawTerminalSpots(Canvas canvas, WirePath wire) {
    if (wire.points.isEmpty) return;
    final copperPaint = Paint()
      ..color = const Color(0xFFB87333)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(wire.points.first, 4.5, copperPaint);
    canvas.drawCircle(wire.points.last, 4.5, copperPaint);
  }

  void _drawElectrons(Canvas canvas, Path path, WirePath wire) {
    final electronGlow = Paint()
      ..color = const Color(0xFFFDE047)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

    final electronPaint = Paint()
      ..color = const Color(0xFFFEF08A)
      ..style = PaintingStyle.fill;

    const totalElectrons = 10;
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      final length = metric.length;
      for (int i = 0; i < totalElectrons; i++) {
        final distance = ((animationValue + (i / totalElectrons)) % 1.0) * length;
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          final pos = tangent.position;
          canvas.drawCircle(pos, 5.0, electronGlow);
          canvas.drawCircle(pos, 3.5, electronPaint);
        }
      }
    }
  }

  /// Constrói caminhos de fios ortogonais com linhas retas e cantos arredondados (fillets Bezier de 90°).
  Path _buildFlexibleWirePath(List<Offset> rawPoints) {
    if (rawPoints.isEmpty) return Path();
    if (rawPoints.length == 1) return Path()..addOval(Rect.fromCircle(center: rawPoints.first, radius: 1));

    // Converter conexões diretas de 2 pontos em segmentos ortogonais (retas com cantos arredondados)
    final List<Offset> points = [];
    if (rawPoints.length == 2) {
      final p0 = rawPoints[0];
      final p1 = rawPoints[1];
      final dx = (p1.dx - p0.dx).abs();
      final dy = (p1.dy - p0.dy).abs();

      if (dx > 4.0 && dy > 4.0) {
        // Linhas retas (ortogonais) e cantos arredondados (fillets de 90°):
        // Se p0 é o topo da bateria (p0.dy acima de p1.dy), sai verticalmente para alinhar a altura Y;
        // caso contrário, navega horizontalmente na altura Y do componente de origem e vira 90° em L.
        final isBatteryTopPin = (p0.dy < p1.dy - 15.0) && (dx > dy);
        final pCorner = isBatteryTopPin
            ? Offset(p0.dx, p1.dy)
            : Offset(p1.dx, p0.dy);
        points.addAll([p0, pCorner, p1]);
      } else {
        points.addAll(rawPoints);
      }
    } else {
      points.addAll(rawPoints);
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);

    if (points.length == 2) {
      path.lineTo(points.last.dx, points.last.dy);
      return path;
    }

    const double maxRadius = 18.0; // Curvatura suave e limpa nos cantos arredondados

    for (int i = 1; i < points.length - 1; i++) {
      final pPrev = points[i - 1];
      final pCurr = points[i];
      final pNext = points[i + 1];

      final v1 = pPrev - pCurr;
      final v2 = pNext - pCurr;
      final d1 = v1.distance;
      final d2 = v2.distance;

      if (d1 == 0 || d2 == 0) {
        path.lineTo(pCurr.dx, pCurr.dy);
        continue;
      }

      final radius = math.min(maxRadius, math.min(d1 / 2, d2 / 2));

      final startArc = pCurr + (v1 / d1) * radius;
      final endArc = pCurr + (v2 / d2) * radius;

      path.lineTo(startArc.dx, startArc.dy);
      path.quadraticBezierTo(pCurr.dx, pCurr.dy, endArc.dx, endArc.dy);
    }

    path.lineTo(points.last.dx, points.last.dy);
    return path;
  }

  @override
  bool shouldRepaint(covariant RealisticWirePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
      oldDelegate.wires != wires;
}

/// Representa um fio com pontos, cor e estado.
class WirePath {
  final List<Offset> points;
  final Color color;
  final bool isActive;
  final double thickness;

  const WirePath({
    required this.points,
    this.color = const Color(0xFFDC2626), // Vermelho por padrão
    this.isActive = true,
    this.thickness = 4.0,
  });
}

/// Widget wrapper para o RealisticWirePainter.
class RealisticWireWidget extends StatelessWidget {
  final List<WirePath> wires;
  final double animationValue;
  final bool showElectrons;

  const RealisticWireWidget({
    super.key,
    required this.wires,
    this.animationValue = 0.0,
    this.showElectrons = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RealisticWirePainter(
        wires: wires,
        animationValue: animationValue,
        showElectrons: showElectrons,
      ),
      size: Size.infinite,
    );
  }
}

/// Posição e rotação de um componente no canvas físico.
class ComponentPlacement {
  final Offset position;
  final double rotation;
  final ComponentType type;

  const ComponentPlacement({
    required this.position,
    required this.rotation,
    required this.type,
  });

  /// Retorna a posição absoluta de um terminal no canvas.
  Offset getTerminalPosition(int terminalIndex) {
    return getTerminalPositionStatic(
      componentCenter: position,
      componentType: type,
      terminalIndex: terminalIndex,
      rotationDegrees: rotation,
    );
  }
}

/// Calcula posição de terminal (função estática para uso externo).
Offset getTerminalPositionStatic({
  required Offset componentCenter,
  required ComponentType componentType,
  required int terminalIndex,
  required double rotationDegrees,
}) {
  final terminals = componentTerminals[componentType];
  if (terminals == null || terminalIndex >= terminals.length) {
    return componentCenter;
  }
  final terminal = terminals[terminalIndex];
  final rotatedOffset = rotateTerminalOffset(terminal.offset, rotationDegrees);
  return componentCenter + rotatedOffset;
}

/// Fio dinâmico que conecta terminais de dois componentes.
class DynamicWirePath {
  final Offset start;
  final Offset end;
  final Color color;
  final bool isActive;
  final double thickness;

  const DynamicWirePath({
    required this.start,
    required this.end,
    this.color = const Color(0xFFDC2626),
    this.isActive = true,
    this.thickness = 4.0,
  });

  /// Cria um DynamicWirePath conectando terminais de dois componentes.
  factory DynamicWirePath.fromComponents({
    required ComponentPlacement compA,
    required int terminalIndexA,
    required ComponentPlacement compB,
    required int terminalIndexB,
    required Color color,
    bool isActive = true,
    double thickness = 4.0,
  }) {
    return DynamicWirePath(
      start: compA.getTerminalPosition(terminalIndexA),
      end: compB.getTerminalPosition(terminalIndexB),
      color: color,
      isActive: isActive,
      thickness: thickness,
    );
  }

  /// Converte para WirePath (com curva intermediária se necessário).
  WirePath toWirePath({List<Offset>? intermediatePoints}) {
    final points = <Offset>[start];
    if (intermediatePoints != null) {
      points.addAll(intermediatePoints);
    }
    points.add(end);
    return WirePath(
      points: points,
      color: color,
      isActive: isActive,
      thickness: thickness,
    );
  }
}

/// Lista de fios dinâmicos que só aparecem quando ambos os terminais existem.
class DynamicWireBundle {
  final List<DynamicWirePath> _wires;

  const DynamicWireBundle(this._wires);

  /// Cria a lista de WirePath, filtrando fios onde os componentes não existem.
  List<WirePath> toWirePaths({
    List<Offset>? Function(DynamicWirePath wire)? intermediatePointsBuilder,
  }) {
    return _wires.map((wire) {
      final intermediate = intermediatePointsBuilder?.call(wire);
      return wire.toWirePath(intermediatePoints: intermediate);
    }).toList();
  }
}
