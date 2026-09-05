import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../models/component_terminals.dart';
import '../../../models/first_step_component.dart';

/// Painter customizado que renderiza as conexões elétricas e fluxo de elétrons do Estande Ruas da Maquete.
class RuasMaquetePainter extends CustomPainter {
  final int missionIndex;
  final double animValue;
  final bool m1Connected;
  final bool m2Series;
  final bool m3Junction;
  final bool m3Return;
  final bool m4Parallel;
  final bool m5House1Broken;
  final bool usePhysicalStyle;
  final double lampY;
  final double socketY;
  final double lamp1X;
  final double lamp2X;
  final double socketX;
  final double socketRotation;

  RuasMaquetePainter({
    required this.missionIndex,
    required this.animValue,
    required this.m1Connected,
    required this.m2Series,
    required this.m3Junction,
    required this.m3Return,
    required this.m4Parallel,
    required this.m5House1Broken,
    required this.usePhysicalStyle,
    required this.lampY,
    required this.socketY,
    required this.lamp1X,
    required this.lamp2X,
    required this.socketX,
    required this.socketRotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final wirePaint = Paint()
      ..color =
          usePhysicalStyle ? const Color(0xFF94A3B8) : const Color(0xFF64748B)
      ..strokeWidth = usePhysicalStyle ? 4.0 : 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final activeWirePaint = Paint()
      ..color =
          usePhysicalStyle ? const Color(0xFF0284C7) : const Color(0xFF0F172A)
      ..strokeWidth = usePhysicalStyle ? 5.0 : 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final electronPaint = Paint()
      ..color = const Color(0xFFD97706)
      ..style = PaintingStyle.fill;

    final nodePaint = Paint()
      ..color = activeWirePaint.color
      ..style = PaintingStyle.fill;

    // Terminais dos componentes (esquerda / direita)
    const termOffset = 32.0;

    void drawStyledPath(Path path, Paint paint,
        {Color? customColor, bool isPositive = true}) {
      if (usePhysicalStyle) {
        final isActive = paint == activeWirePaint;
        final baseColor = customColor ??
            (isPositive ? const Color(0xFFDC2626) : const Color(0xFF2563EB));

        // 1. Sombra projetada do fio
        final shadowPaint = Paint()
          ..color = Colors.black.withValues(alpha: 0.22)
          ..strokeWidth = 6.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        canvas.drawPath(path.shift(const Offset(1.5, 2.5)), shadowPaint);

        // 2. Isolamento do fio
        final wireInsulationPaint = Paint()
          ..color = isActive ? baseColor : baseColor.withValues(alpha: 0.5)
          ..strokeWidth = 4.8
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        canvas.drawPath(path, wireInsulationPaint);

        // 3. Brilho especular no fio físico
        final specularPaint = Paint()
          ..color = Colors.white.withValues(alpha: isActive ? 0.40 : 0.20)
          ..strokeWidth = 1.6
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        canvas.drawPath(path.shift(const Offset(0, -1.2)), specularPaint);
      } else {
        canvas.drawPath(path, paint);
      }
    }

    void drawTerminalDot(Offset pos) {
      if (usePhysicalStyle) {
        return;
      } else {
        canvas.drawCircle(pos, 3.5, nodePaint);
      }
    }

    Path makeFlexiblePath(List<Offset> points) {
      if (points.isEmpty) return Path();
      if (points.length == 1) {
        return Path()..addOval(Rect.fromCircle(center: points.first, radius: 1));
      }

      final path = Path()..moveTo(points.first.dx, points.first.dy);

      if (points.length == 2) {
        final p0 = points[0];
        final p1 = points[1];
        final dx = (p1.dx - p0.dx).abs();
        final dy = (p1.dy - p0.dy).abs();

        if (dx > 12.0 && dy > 3.0) {
          final midX = (p0.dx + p1.dx) / 2;
          path.cubicTo(
            midX,
            p0.dy,
            midX,
            p1.dy,
            p1.dx,
            p1.dy,
          );
          return path;
        }

        path.lineTo(p1.dx, p1.dy);
        return path;
      }

      const double maxRadius = 22.0;

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

    // Terminais dinâmicos da bateria baseados no ângulo de rotação do soquete
    final batPosTerminal = getTerminalPosition(
      componentCenter: Offset(socketX, socketY),
      componentType: ComponentType.battery,
      terminalIndex: 0,
      rotationDegrees: socketRotation,
    );
    final batNegTerminal = getTerminalPosition(
      componentCenter: Offset(socketX, socketY),
      componentType: ComponentType.battery,
      terminalIndex: 1,
      rotationDegrees: socketRotation,
    );

    final topLoopY = socketY - 70.0;
    final outerLeftX = lamp1X - 70.0;
    final outerRightX = lamp2X + 70.0;

    // Determinar waypoints de saída de fiação baseados na rotação do soquete
    final List<Offset> posExitWaypoints;
    final List<Offset> negExitWaypoints;

    final normRotation = (socketRotation % 360 + 360) % 360;
    if (normRotation >= 45 && normRotation < 135) {
      posExitWaypoints = [
        batPosTerminal,
        Offset(socketX + 70.0, batPosTerminal.dy),
        Offset(socketX + 70.0, topLoopY)
      ];
      negExitWaypoints = [
        Offset(socketX + 70.0, topLoopY),
        Offset(socketX + 70.0, batNegTerminal.dy),
        batNegTerminal
      ];
    } else if (normRotation >= 135 && normRotation < 225) {
      posExitWaypoints = [
        batPosTerminal,
        Offset(batPosTerminal.dx, socketY + 70.0),
        Offset(outerLeftX, socketY + 70.0)
      ];
      negExitWaypoints = [
        Offset(outerRightX, socketY + 70.0),
        Offset(batNegTerminal.dx, socketY + 70.0),
        batNegTerminal
      ];
    } else if (normRotation >= 225 && normRotation < 315) {
      posExitWaypoints = [
        batPosTerminal,
        Offset(socketX - 70.0, batPosTerminal.dy),
        Offset(socketX - 70.0, topLoopY)
      ];
      negExitWaypoints = [
        Offset(socketX - 70.0, topLoopY),
        Offset(socketX - 70.0, batNegTerminal.dy),
        batNegTerminal
      ];
    } else {
      posExitWaypoints = [batPosTerminal, Offset(batPosTerminal.dx, topLoopY)];
      negExitWaypoints = [Offset(batNegTerminal.dx, topLoopY), batNegTerminal];
    }

    // Desenhar caminhos de fios conforme a missão
    if (missionIndex == 0) {
      final isConnected = m1Connected;
      final currentPaint = isConnected ? activeWirePaint : wirePaint;

      final path1 = makeFlexiblePath([
        ...posExitWaypoints,
        Offset(outerLeftX, topLoopY),
        Offset(outerLeftX, lampY),
        Offset(lamp1X - termOffset, lampY),
      ]);

      final path2 = makeFlexiblePath([
        Offset(lamp1X + termOffset, lampY),
        Offset(lamp2X - termOffset, lampY),
      ]);

      final path3 = makeFlexiblePath([
        Offset(lamp2X + termOffset, lampY),
        Offset(outerRightX, lampY),
        Offset(outerRightX, topLoopY),
        ...negExitWaypoints,
      ]);

      drawStyledPath(path1, currentPaint, isPositive: true);
      drawStyledPath(path2, currentPaint,
          customColor: const Color(0xFFD97706));
      drawStyledPath(path3, currentPaint, isPositive: false);

      drawTerminalDot(batPosTerminal);
      drawTerminalDot(Offset(lamp1X - termOffset, lampY));
      drawTerminalDot(Offset(lamp1X + termOffset, lampY));
      drawTerminalDot(Offset(lamp2X - termOffset, lampY));
      drawTerminalDot(Offset(lamp2X + termOffset, lampY));
      drawTerminalDot(batNegTerminal);

      if (isConnected) {
        _drawElectronsOnPath(canvas, path1, electronPaint);
        _drawElectronsOnPath(canvas, path2, electronPaint);
        _drawElectronsOnPath(canvas, path3, electronPaint);
      }
    } else if (missionIndex == 1) {
      final path1 = makeFlexiblePath([
        ...posExitWaypoints,
        Offset(outerLeftX, topLoopY),
        Offset(outerLeftX, lampY),
        Offset(lamp1X - termOffset, lampY),
      ]);

      final path2 = makeFlexiblePath([
        Offset(lamp1X + termOffset, lampY),
        Offset(lamp2X - termOffset, lampY),
      ]);

      final path3 = makeFlexiblePath([
        Offset(lamp2X + termOffset, lampY),
        Offset(outerRightX, lampY),
        Offset(outerRightX, topLoopY),
        ...negExitWaypoints,
      ]);

      drawStyledPath(path1, activeWirePaint, isPositive: true);
      drawStyledPath(path2, activeWirePaint,
          customColor: const Color(0xFFD97706));
      drawStyledPath(path3, m2Series ? activeWirePaint : wirePaint,
          isPositive: false);

      drawTerminalDot(batPosTerminal);
      drawTerminalDot(Offset(lamp1X - termOffset, lampY));
      drawTerminalDot(Offset(lamp1X + termOffset, lampY));
      drawTerminalDot(Offset(lamp2X - termOffset, lampY));
      drawTerminalDot(Offset(lamp2X + termOffset, lampY));
      drawTerminalDot(batNegTerminal);

      _drawElectronsOnPath(canvas, path1, electronPaint);
      _drawElectronsOnPath(canvas, path2, electronPaint);
      if (m2Series) {
        _drawElectronsOnPath(canvas, path3, electronPaint);
      }
    } else if (missionIndex == 2) {
      final isBothActive = m3Junction && m3Return;
      final nodeY = lampY + 45.0;

      final pathTrunkVcc = makeFlexiblePath([
        batPosTerminal,
        Offset(batPosTerminal.dx, socketY - 45.0),
        Offset(socketX, socketY - 60.0),
        Offset(socketX, nodeY + 18.0),
      ]);

      final pathBranchA = makeFlexiblePath([
        Offset(socketX, nodeY),
        Offset(lamp1X + termOffset, nodeY),
        Offset(lamp1X + termOffset, lampY),
      ]);

      final pathBranchB = makeFlexiblePath([
        Offset(socketX, nodeY),
        Offset(lamp2X - termOffset, nodeY),
        Offset(lamp2X - termOffset, lampY),
      ]);

      final pathReturnA = makeFlexiblePath([
        Offset(lamp1X - termOffset, lampY),
        Offset(outerLeftX, lampY),
        Offset(outerLeftX, topLoopY),
        ...negExitWaypoints,
      ]);

      final pathReturnB = makeFlexiblePath([
        Offset(lamp2X + termOffset, lampY),
        Offset(outerRightX, lampY),
        Offset(outerRightX, topLoopY),
        ...negExitWaypoints,
      ]);

      drawStyledPath(pathTrunkVcc, m3Junction ? activeWirePaint : wirePaint,
          isPositive: true);
      drawStyledPath(pathBranchA, m3Junction ? activeWirePaint : wirePaint,
          isPositive: true);
      drawStyledPath(pathBranchB, m3Junction ? activeWirePaint : wirePaint,
          isPositive: true);
      drawStyledPath(pathReturnA, m3Return ? activeWirePaint : wirePaint,
          isPositive: false);
      drawStyledPath(pathReturnB, m3Return ? activeWirePaint : wirePaint,
          isPositive: false);

      drawTerminalDot(batPosTerminal);
      drawTerminalDot(Offset(socketX, nodeY + 18.0));
      drawTerminalDot(Offset(lamp1X + termOffset, lampY));
      drawTerminalDot(Offset(lamp1X - termOffset, lampY));
      drawTerminalDot(Offset(lamp2X - termOffset, lampY));
      drawTerminalDot(Offset(lamp2X + termOffset, lampY));
      drawTerminalDot(batNegTerminal);

      if (isBothActive) {
        _drawElectronsOnPath(canvas, pathTrunkVcc, electronPaint);
        _drawElectronsOnPath(canvas, pathBranchA, electronPaint);
        _drawElectronsOnPath(canvas, pathBranchB, electronPaint);
        _drawElectronsOnPath(canvas, pathReturnA, electronPaint);
        _drawElectronsOnPath(canvas, pathReturnB, electronPaint);
      }
    } else if (missionIndex == 3 || missionIndex == 4) {
      final isActive = m4Parallel || missionIndex == 4;
      final currentPaint = isActive ? activeWirePaint : wirePaint;
      final topVccY = lampY - 50.0;
      final botGndY = lampY + 70.0;
      final vccGutterY = socketY - 50.0;
      final gndGutterY = socketY - 40.0;

      final x1 = size.width * 0.18; // Poste 1
      final x2 = size.width * 0.38; // Casa 1
      final x3 = size.width * 0.62; // Casa 2
      final x4 = size.width * 0.82; // Poste 2

      final busOuterLeftX = x1 - 40.0;
      final busOuterRightX = x4 + 40.0;

      final pathVccMain = makeFlexiblePath([
        batPosTerminal,
        Offset(batPosTerminal.dx, vccGutterY),
        Offset(busOuterLeftX, vccGutterY),
        Offset(busOuterLeftX, topVccY),
        Offset(x4 - termOffset, topVccY),
      ]);

      final pathVccBranch1 = makeFlexiblePath([
        Offset(x1 - termOffset, topVccY),
        Offset(x1 - termOffset, lampY),
      ]);

      final pathVccBranch2 = makeFlexiblePath([
        Offset(x2 - termOffset, topVccY),
        Offset(x2 - termOffset, lampY),
      ]);

      final pathVccBranch3 = makeFlexiblePath([
        Offset(x3 - termOffset, topVccY),
        Offset(x3 - termOffset, lampY),
      ]);

      final pathVccBranch4 = makeFlexiblePath([
        Offset(x4 - termOffset, topVccY),
        Offset(x4 - termOffset, lampY),
      ]);

      final pathGndBranch1 = makeFlexiblePath([
        Offset(x1 + termOffset, lampY),
        Offset(x1 + termOffset + 15.0, lampY),
        Offset(x1 + termOffset + 15.0, botGndY),
        Offset(busOuterRightX, botGndY),
      ]);

      final pathGndBranch2 = makeFlexiblePath([
        Offset(x2 + termOffset, lampY),
        Offset(x2 + termOffset + 15.0, lampY),
        Offset(x2 + termOffset + 15.0, botGndY),
        Offset(busOuterRightX, botGndY),
      ]);

      final pathGndBranch3 = makeFlexiblePath([
        Offset(x3 + termOffset, lampY),
        Offset(x3 + termOffset + 15.0, lampY),
        Offset(x3 + termOffset + 15.0, botGndY),
        Offset(busOuterRightX, botGndY),
      ]);

      final pathGndBranch4 = makeFlexiblePath([
        Offset(x4 + termOffset, lampY),
        Offset(busOuterRightX, lampY),
        Offset(busOuterRightX, botGndY),
      ]);

      final pathGndMain = makeFlexiblePath([
        Offset(busOuterRightX, botGndY),
        Offset(busOuterRightX, gndGutterY),
        Offset(batNegTerminal.dx, gndGutterY),
        batNegTerminal,
      ]);

      drawStyledPath(pathVccMain, currentPaint, isPositive: true);
      drawStyledPath(pathVccBranch1, isActive ? activeWirePaint : wirePaint,
          isPositive: true);
      drawStyledPath(
          pathVccBranch2,
          (isActive && (!m5House1Broken || missionIndex != 4))
              ? activeWirePaint
              : wirePaint,
          isPositive: true);
      drawStyledPath(pathVccBranch3, isActive ? activeWirePaint : wirePaint,
          isPositive: true);
      drawStyledPath(pathVccBranch4, isActive ? activeWirePaint : wirePaint,
          isPositive: true);

      drawStyledPath(pathGndBranch1, isActive ? activeWirePaint : wirePaint,
          isPositive: false);
      drawStyledPath(
          pathGndBranch2,
          (isActive && (!m5House1Broken || missionIndex != 4))
              ? activeWirePaint
              : wirePaint,
          isPositive: false);
      drawStyledPath(pathGndBranch3, isActive ? activeWirePaint : wirePaint,
          isPositive: false);
      drawStyledPath(pathGndBranch4, isActive ? activeWirePaint : wirePaint,
          isPositive: false);
      drawStyledPath(pathGndMain, isActive ? activeWirePaint : wirePaint,
          isPositive: false);

      drawTerminalDot(batPosTerminal);
      drawTerminalDot(Offset(x1 - termOffset, topVccY));
      drawTerminalDot(Offset(x2 - termOffset, topVccY));
      drawTerminalDot(Offset(x3 - termOffset, topVccY));
      drawTerminalDot(Offset(x4 - termOffset, topVccY));

      drawTerminalDot(Offset(x1 - termOffset, lampY));
      drawTerminalDot(Offset(x1 + termOffset, lampY));
      drawTerminalDot(Offset(x2 - termOffset, lampY));
      drawTerminalDot(Offset(x2 + termOffset, lampY));
      drawTerminalDot(Offset(x3 - termOffset, lampY));
      drawTerminalDot(Offset(x3 + termOffset, lampY));
      drawTerminalDot(Offset(x4 - termOffset, lampY));
      drawTerminalDot(Offset(x4 + termOffset, lampY));

      drawTerminalDot(Offset(x1 + termOffset + 15.0, botGndY));
      drawTerminalDot(Offset(x2 + termOffset + 15.0, botGndY));
      drawTerminalDot(Offset(x3 + termOffset + 15.0, botGndY));
      drawTerminalDot(Offset(busOuterRightX, botGndY));
      drawTerminalDot(batNegTerminal);

      if (isActive) {
        _drawElectronsOnPath(canvas, pathVccMain, electronPaint);
        _drawElectronsOnPath(canvas, pathGndMain, electronPaint);

        _drawElectronsOnPath(canvas, pathVccBranch1, electronPaint);
        _drawElectronsOnPath(canvas, pathGndBranch1, electronPaint);

        if (!m5House1Broken || missionIndex != 4) {
          _drawElectronsOnPath(canvas, pathVccBranch2, electronPaint);
          _drawElectronsOnPath(canvas, pathGndBranch2, electronPaint);
        }

        _drawElectronsOnPath(canvas, pathVccBranch3, electronPaint);
        _drawElectronsOnPath(canvas, pathGndBranch3, electronPaint);

        _drawElectronsOnPath(canvas, pathVccBranch4, electronPaint);
        _drawElectronsOnPath(canvas, pathGndBranch4, electronPaint);
      }
    }
  }

  void _drawElectronsOnPath(Canvas canvas, Path path, Paint paint) {
    final metrics = path.computeMetrics().toList();
    if (usePhysicalStyle) {
      final glowPaint = Paint()
        ..color = const Color(0xFFFEF08A)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

      for (final metric in metrics) {
        final length = metric.length;
        const count = 3;
        for (int i = 0; i < count; i++) {
          final distance = (length * ((animValue + i / count) % 1.0));
          final tangent = metric.getTangentForOffset(distance);
          if (tangent != null) {
            canvas.drawCircle(tangent.position, 2.5, glowPaint);
            canvas.drawCircle(
                tangent.position, 1.2, Paint()..color = Colors.white);
          }
        }
      }
    } else {
      for (final metric in metrics) {
        final length = metric.length;
        const count = 4;
        for (int i = 0; i < count; i++) {
          final distance = (length * ((animValue + i / count) % 1.0));
          final tangent = metric.getTangentForOffset(distance);
          if (tangent != null) {
            canvas.drawCircle(tangent.position, 3.5, paint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant RuasMaquetePainter oldDelegate) {
    return oldDelegate.animValue != animValue ||
        oldDelegate.missionIndex != missionIndex ||
        oldDelegate.m1Connected != m1Connected ||
        oldDelegate.m2Series != m2Series ||
        oldDelegate.m3Junction != m3Junction ||
        oldDelegate.m3Return != m3Return ||
        oldDelegate.m4Parallel != m4Parallel ||
        oldDelegate.m5House1Broken != m5House1Broken ||
        oldDelegate.usePhysicalStyle != usePhysicalStyle ||
        oldDelegate.lampY != lampY ||
        oldDelegate.socketY != socketY ||
        oldDelegate.lamp1X != lamp1X ||
        oldDelegate.lamp2X != lamp2X ||
        oldDelegate.socketX != socketX ||
        oldDelegate.socketRotation != socketRotation;
  }
}
