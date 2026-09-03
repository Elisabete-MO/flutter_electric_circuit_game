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
    final path = _buildCatenaryPath(wire.points);
    final isActive = wire.isActive;
    final color = wire.color;

    // Sombra projetada
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..strokeWidth = wire.thickness + 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawPath(path.shift(const Offset(1, 2)), shadowPaint);

    // Isolamento externo (camada grossa)
    final insulationPaint = Paint()
      ..color = isActive ? color : color.withValues(alpha: 0.5)
      ..strokeWidth = wire.thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, insulationPaint);

    // Brilho especular (reflexo de luz no isolamento)
    final specularPaint = Paint()
      ..color = Colors.white.withValues(alpha: isActive ? 0.35 : 0.15)
      ..strokeWidth = wire.thickness * 0.3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path.shift(Offset(0, -wire.thickness * 0.15)), specularPaint);

    // Condutores nas pontas (暴露 o cobre)
    _drawTerminalSpots(canvas, wire);

    // Elétrons animados quando ativo
    if (isActive && showElectrons) {
      _drawElectrons(canvas, path, wire);
    }
  }

  void _drawTerminalSpots(Canvas canvas, WirePath wire) {
    if (wire.points.length < 2) return;
    final spotPaint = Paint()..style = PaintingStyle.fill;

    // Ponto de solda na ponta inicial
    spotPaint.color = const Color(0xFFB87333); // Cobre
    canvas.drawCircle(wire.points.first, wire.thickness * 0.4, spotPaint);

    // Ponto de solda na ponta final
    canvas.drawCircle(wire.points.last, wire.thickness * 0.4, spotPaint);
  }

  void _drawElectrons(Canvas canvas, Path path, WirePath wire) {
    final electronPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.fill;

    final electronGlow = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    const totalElectrons = 8;
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      final length = metric.length;
      for (int i = 0; i < totalElectrons; i++) {
        final distance = ((animationValue + (i / totalElectrons)) % 1.0) * length;
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          final pos = tangent.position;
          canvas.drawCircle(pos, 5, electronGlow);
          canvas.drawCircle(pos, 2.5, electronPaint);
        }
      }
    }
  }

  Path _buildCatenaryPath(List<Offset> points) {
    if (points.isEmpty) return Path();
    if (points.length == 1) return Path()..addOval(Rect.fromCircle(center: points.first, radius: 1));

    final path = Path()..moveTo(points.first.dx, points.first.dy);

    if (points.length == 2) {
      // Curva suave entre dois pontos (catenária simples)
      final start = points[0];
      final end = points[1];
      final mid = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);

      // Adiciona uma leve curvatura baseada na distância
      final dist = (end - start).distance;
      final sag = dist * 0.08; // Queda natural do fio
      final controlPoint = Offset(mid.dx, mid.dy + sag);

      path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, end.dx, end.dy);
    } else {
      // Múltiplos pontos: conecta com curvas suaves
      for (int i = 1; i < points.length; i++) {
        final prev = points[i - 1];
        final curr = points[i];
        final mid = Offset((prev.dx + curr.dx) / 2, (prev.dy + curr.dy) / 2);

        path.quadraticBezierTo(prev.dx, prev.dy, mid.dx, mid.dy);
      }
      path.lineTo(points.last.dx, points.last.dy);
    }

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
