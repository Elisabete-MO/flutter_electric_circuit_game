import 'package:flutter/material.dart';
import '../../../models/first_step_component.dart';
import '../models/schematic_models.dart';

class SchematicPainter extends CustomPainter {
  final double cellSize;
  final List<SchematicComponent> components;
  final List<SchematicWire> wires;
  
  /// Opcional: Para desenhar a linha atual que o usuário está arrastando
  final Offset? currentDragStart;
  final Offset? currentDragEnd;

  SchematicPainter({
    required this.cellSize,
    required this.components,
    required this.wires,
    this.currentDragStart,
    this.currentDragEnd,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBlueprintGrid(canvas, size);
    _drawGridNodes(canvas, size);
    _drawWires(canvas);
    _drawComponents(canvas);
    _drawCurrentDrag(canvas);
  }

  void _drawBlueprintGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 1.0;

    for (double i = 0; i <= size.width; i += cellSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double j = 0; j <= size.height; j += cellSize) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), paint);
    }
  }

  void _drawGridNodes(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (double i = cellSize; i < size.width; i += cellSize) {
      for (double j = cellSize; j < size.height; j += cellSize) {
        canvas.drawCircle(Offset(i, j), 4.0, paint);
      }
    }
  }

  void _drawWires(Canvas canvas) {
    final glowPaint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.4)
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);

    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (var wire in wires) {
      final startOffset = _getOffsetForNode(wire.start);
      final endOffset = _getOffsetForNode(wire.end);
      final path = _buildSmoothOrthogonalPath(startOffset, endOffset);
      
      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, paint);
    }
  }

  void _drawComponents(Canvas canvas) {
    // Desenha o símbolo de bateria e lâmpada baseado nos terminais
    for (var comp in components) {
      final terms = comp.terminals;
      final start = _getOffsetForNode(terms[0]);
      final end = _getOffsetForNode(terms[1]);
      final center = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);

      _drawComponentSymbol(canvas, comp.type, center, comp.isHorizontal);
    }
  }

  void _drawComponentSymbol(Canvas canvas, ComponentType type, Offset center, bool isHorizontal) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    if (!isHorizontal) {
      canvas.rotate(1.5708); // 90 graus
    }

    if (type == ComponentType.battery) {
      // Símbolo simples de bateria
      canvas.drawLine(const Offset(-10, -20), const Offset(-10, 20), paint);
      canvas.drawLine(const Offset(10, -10), const Offset(10, 10), paint..strokeWidth = 5.0);
    } else if (type == ComponentType.bulb) {
      // Símbolo simples de lâmpada
      canvas.drawCircle(Offset.zero, 15, paint);
      canvas.drawLine(const Offset(-10.6, -10.6), const Offset(10.6, 10.6), paint);
      canvas.drawLine(const Offset(10.6, -10.6), const Offset(-10.6, 10.6), paint);
    } else {
      // Símbolo genérico
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: 20, height: 20), paint);
    }

    canvas.restore();
  }

  void _drawCurrentDrag(Canvas canvas) {
    if (currentDragStart != null && currentDragEnd != null) {
      final glowPaint = Paint()
        ..color = Colors.cyanAccent.withValues(alpha: 0.3)
        ..strokeWidth = 10.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);

      final paint = Paint()
        ..color = Colors.white.withValues(alpha: 0.7)
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final path = _buildSmoothOrthogonalPath(currentDragStart!, currentDragEnd!);
      
      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, paint);
    }
  }

  Path _buildSmoothOrthogonalPath(Offset start, Offset end) {
    final path = Path();
    path.moveTo(start.dx, start.dy);
    
    if (start.dx == end.dx || start.dy == end.dy) {
      path.lineTo(end.dx, end.dy);
      return path;
    }

    // Trajeto em L com quina arredondada
    // Primeiro vai na horizontal, depois na vertical
    final corner = Offset(end.dx, start.dy);
    
    double radius = 15.0; 
    final dx = (end.dx - start.dx).abs();
    final dy = (end.dy - start.dy).abs();
    
    if (radius > dx / 2) radius = dx / 2;
    if (radius > dy / 2) radius = dy / 2;

    final p1 = Offset(corner.dx - (end.dx > start.dx ? radius : -radius), corner.dy);
    final p2 = corner;
    final p3 = Offset(corner.dx, corner.dy + (end.dy > start.dy ? radius : -radius));

    path.lineTo(p1.dx, p1.dy);
    path.quadraticBezierTo(p2.dx, p2.dy, p3.dx, p3.dy);
    path.lineTo(end.dx, end.dy);

    return path;
  }

  Offset _getOffsetForNode(GridNode node) {
    return Offset(node.x * cellSize, node.y * cellSize);
  }

  @override
  bool shouldRepaint(covariant SchematicPainter oldDelegate) {
    return true; // Para simplificar, sempre repinta na interação
  }
}
