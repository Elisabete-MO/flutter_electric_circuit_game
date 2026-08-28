import 'dart:math' as math;
import 'package:flutter/material.dart';

enum ProfVoltsEmotion { happy, sad, neutral }

class ProfVoltsFullBody extends StatefulWidget {
  const ProfVoltsFullBody({
    super.key,
    required this.emotion,
    this.size = 180.0,
  });

  final ProfVoltsEmotion emotion;
  final double size;

  @override
  State<ProfVoltsFullBody> createState() => _ProfVoltsFullBodyState();
}

class _ProfVoltsFullBodyState extends State<ProfVoltsFullBody>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size * 1.25,
          child: CustomPaint(
            painter: _FullBodyRobotPainter(
              isDark: isDark,
              emotion: widget.emotion,
              animationValue: _controller.value,
            ),
          ),
        );
      },
    );
  }
}

class _FullBodyRobotPainter extends CustomPainter {
  final bool isDark;
  final ProfVoltsEmotion emotion;
  final double animationValue;

  _FullBodyRobotPainter({
    required this.isDark,
    required this.emotion,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Cores Cyberpunk do EletroLab adaptadas para o contraste de cada tema
    final neonCyan = isDark ? const Color(0xFF00F0FF) : const Color(0xFF0097A7);
    const neonBlue = Color(0xFF0066FF);
    final neonGreen = isDark ? const Color(0xFF00FF9D) : const Color(0xFF00875A);
    final neonPink = isDark ? const Color(0xFFFF3B7F) : const Color(0xFFD81B60);
    final neonAmber = isDark ? const Color(0xFFFF9F1C) : const Color(0xFFE65100);

    final shellColor = isDark ? const Color(0xFF2E2E3E) : Colors.white;
    final jointColor = isDark ? const Color(0xFF1F1F2E) : Colors.grey.shade400;
    final screenColor = isDark ? const Color(0xFF0B0F19) : const Color(0xFF151E32);
    final primaryGlow = isDark ? neonCyan : neonBlue;

    // 1. Glow Geral Traseiro (Aura)
    final auraColor = emotion == ProfVoltsEmotion.happy
        ? neonGreen.withValues(alpha: 0.12)
        : emotion == ProfVoltsEmotion.sad
            ? neonPink.withValues(alpha: 0.12)
            : primaryGlow.withValues(alpha: 0.10);
    final auraPaint = Paint()
      ..color = auraColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(Offset(w / 2, h * 0.45), w * 0.42, auraPaint);

    // 2. Monociclo (Roda & Suporte na Base)
    final wheelCenter = Offset(w / 2, h * 0.88);
    final wheelRadius = w * 0.11;

    // Garfo de suspensão
    final forkPaint = Paint()
      ..color = jointColor
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final forkPath = Path()
      ..moveTo(w * 0.44, h * 0.74)
      ..lineTo(w * 0.44, h * 0.80)
      ..lineTo(w * 0.38, h * 0.88)
      ..lineTo(w / 2, h * 0.88)
      ..moveTo(w * 0.56, h * 0.74)
      ..lineTo(w * 0.56, h * 0.80)
      ..lineTo(w * 0.62, h * 0.88)
      ..lineTo(w / 2, h * 0.88);
    canvas.drawPath(forkPath, forkPaint);

    // Pneu
    final tirePaint = Paint()
      ..color = isDark ? const Color(0xFF12121A) : Colors.grey.shade700
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(wheelCenter, wheelRadius, tirePaint);

    // Aro Interno Neon
    final rimPaint = Paint()
      ..color = emotion == ProfVoltsEmotion.happy
          ? neonGreen
          : emotion == ProfVoltsEmotion.sad
              ? neonPink
              : primaryGlow
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(wheelCenter, wheelRadius - 3.5, rimPaint);

    // Raios da Roda Rotativos (Efeito de Rolagem)
    final spokePaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5)
      ..strokeWidth = 2;
    
    final rotationAngle = animationValue * 2 * math.pi * (emotion == ProfVoltsEmotion.happy ? 2.0 : 0.5);
    for (int i = 0; i < 4; i++) {
      final angle = rotationAngle + (i * math.pi / 2);
      final dx = math.cos(angle) * (wheelRadius - 4);
      final dy = math.sin(angle) * (wheelRadius - 4);
      canvas.drawLine(wheelCenter, Offset(wheelCenter.dx + dx, wheelCenter.dy + dy), spokePaint);
    }

    // 3. Tronco / Corpo (Torso)
    final torsoPaint = Paint()..color = shellColor;
    final torsoBorderPaint = Paint()
      ..color = primaryGlow.withValues(alpha: 0.8)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final torsoRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.28, h * 0.44, w * 0.44, h * 0.32),
      const Radius.circular(16),
    );
    canvas.drawRRect(torsoRect, torsoPaint);
    canvas.drawRRect(torsoRect, torsoBorderPaint);

    // Tela do Peito
    final chestPaint = Paint()..color = screenColor;
    final chestRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.34, h * 0.49, w * 0.32, h * 0.20),
      const Radius.circular(8),
    );
    canvas.drawRRect(chestRect, chestPaint);

    // Detalhe na tela do peito conforme emoção
    if (emotion == ProfVoltsEmotion.happy) {
      // Raio neon feliz (Pulsando)
      final thunderPaint = Paint()
        ..color = neonAmber
        ..style = PaintingStyle.fill;
      final thunderPath = Path()
        ..moveTo(w * 0.50, h * 0.51)
        ..lineTo(w * 0.43, h * 0.60)
        ..lineTo(w * 0.49, h * 0.60)
        ..lineTo(w * 0.46, h * 0.67)
        ..lineTo(w * 0.57, h * 0.58)
        ..lineTo(w * 0.51, h * 0.58)
        ..close();
      canvas.drawPath(thunderPath, thunderPaint);
    } else if (emotion == ProfVoltsEmotion.sad) {
      // Bateria descarregada piscando
      final pulse = (math.sin(animationValue * 2 * math.pi * 2) + 1) / 2;
      final batPaint = Paint()
        ..color = neonPink.withValues(alpha: 0.2 + 0.8 * pulse)
        ..style = PaintingStyle.fill;
      
      final borderBatPaint = Paint()
        ..color = neonPink
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      
      final bRect = Rect.fromLTWH(w * 0.42, h * 0.55, w * 0.14, h * 0.08);
      canvas.drawRect(bRect, borderBatPaint);
      canvas.drawRect(Rect.fromLTWH(w * 0.56, h * 0.57, w * 0.02, h * 0.04), borderBatPaint); // polo
      canvas.drawRect(Rect.fromLTWH(w * 0.435, h * 0.56, w * 0.03, h * 0.06), batPaint);
    } else {
      // Batimento Cardíaco Neutro
      final pulsePaint = Paint()
        ..color = primaryGlow
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      final pulsePath = Path()
        ..moveTo(w * 0.36, h * 0.59)
        ..lineTo(w * 0.44, h * 0.59)
        ..lineTo(w * 0.47, h * 0.53)
        ..lineTo(w * 0.51, h * 0.65)
        ..lineTo(w * 0.54, h * 0.59)
        ..lineTo(w * 0.64, h * 0.59);
      canvas.drawPath(pulsePath, pulsePaint);
    }

    // 4. Pescoço
    final neckPaint = Paint()..color = jointColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.46, h * 0.40, w * 0.08, h * 0.04),
        const Radius.circular(2),
      ),
      neckPaint,
    );

    // 5. Cabeça (com pequena oscilação/inclinação física)
    canvas.save();
    
    double headTilt = 0.0;
    double headBob = 0.0;
    if (emotion == ProfVoltsEmotion.happy) {
      headBob = math.sin(animationValue * 2 * math.pi * 2) * 1.5;
    } else if (emotion == ProfVoltsEmotion.sad) {
      headTilt = math.sin(animationValue * 2 * math.pi) * 0.035;
      headBob = math.sin(animationValue * 2 * math.pi) * 0.8;
    }

    canvas.translate(w / 2, h * 0.28);
    canvas.rotate(headTilt);
    canvas.translate(-w / 2, -h * 0.28 + headBob);

    // Cabeça Físico
    final headRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.25, h * 0.16, w * 0.50, h * 0.24),
      const Radius.circular(10),
    );
    canvas.drawRRect(headRect, torsoPaint);
    canvas.drawRRect(headRect, torsoBorderPaint);

    // Visor
    final visorRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.29, h * 0.19, w * 0.42, h * 0.18),
      const Radius.circular(6),
    );
    canvas.drawRRect(visorRect, chestPaint);

    // Antena no topo
    final antStemPaint = Paint()..color = shellColor;
    canvas.drawRect(Rect.fromLTWH(w * 0.485, h * 0.09, w * 0.03, h * 0.07), antStemPaint);
    
    final antLedPaint = Paint()
      ..color = emotion == ProfVoltsEmotion.happy
          ? neonGreen
          : emotion == ProfVoltsEmotion.sad
              ? neonPink
              : neonCyan
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w / 2, h * 0.075), 4, antLedPaint);

    // Olhos
    final eyePaint = Paint()
      ..color = emotion == ProfVoltsEmotion.happy
          ? neonGreen
          : emotion == ProfVoltsEmotion.sad
              ? neonPink
              : neonCyan
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final leftEyeCenter = Offset(w * 0.40, h * 0.25);
    final rightEyeCenter = Offset(w * 0.60, h * 0.25);
    final eyeRadius = w * 0.04;

    if (emotion == ProfVoltsEmotion.happy) {
      // Olhos ^ ^
      final lPath = Path()
        ..addArc(Rect.fromCircle(center: leftEyeCenter, radius: eyeRadius), math.pi, math.pi);
      final rPath = Path()
        ..addArc(Rect.fromCircle(center: rightEyeCenter, radius: eyeRadius), math.pi, math.pi);
      canvas.drawPath(lPath, eyePaint);
      canvas.drawPath(rPath, eyePaint);
    } else if (emotion == ProfVoltsEmotion.sad) {
      // Olhos de choro / caídos v v
      final lPath = Path()
        ..addArc(Rect.fromCircle(center: leftEyeCenter, radius: eyeRadius), 0, math.pi);
      final rPath = Path()
        ..addArc(Rect.fromCircle(center: rightEyeCenter, radius: eyeRadius), 0, math.pi);
      canvas.drawPath(lPath, eyePaint);
      canvas.drawPath(rPath, eyePaint);
      
      // Lagrima caindo animada
      final tearPaint = Paint()
        ..color = neonBlue
        ..style = PaintingStyle.fill;
      final tearY = leftEyeCenter.dy + 8 + (animationValue * 14);
      if (tearY < h * 0.36) {
        canvas.drawCircle(Offset(leftEyeCenter.dx + 4, tearY), 2.5, tearPaint);
      }
    } else {
      // Círculos normais
      final fillEyePaint = Paint()
        ..color = neonCyan
        ..style = PaintingStyle.fill;
      canvas.drawCircle(leftEyeCenter, 3.5, fillEyePaint);
      canvas.drawCircle(rightEyeCenter, 3.5, fillEyePaint);
    }

    // Boca
    final mouthPaint = Paint()
      ..color = emotion == ProfVoltsEmotion.happy
          ? neonGreen
          : emotion == ProfVoltsEmotion.sad
              ? neonPink
              : primaryGlow
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (emotion == ProfVoltsEmotion.happy) {
      final mPath = Path()
        ..addArc(Rect.fromLTWH(w * 0.46, h * 0.28, w * 0.08, h * 0.05), 0, math.pi);
      canvas.drawPath(mPath, mouthPaint);
    } else if (emotion == ProfVoltsEmotion.sad) {
      final mPath = Path()
        ..addArc(Rect.fromLTWH(w * 0.46, h * 0.31, w * 0.08, h * 0.05), math.pi, math.pi);
      canvas.drawPath(mPath, mouthPaint);
    } else {
      canvas.drawLine(Offset(w * 0.46, h * 0.31), Offset(w * 0.54, h * 0.31), mouthPaint);
    }

    canvas.restore();

    // 6. Braços
    final armPaint = Paint()
      ..color = jointColor
      ..strokeWidth = 4.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final handPaint = Paint()
      ..color = shellColor
      ..style = PaintingStyle.fill;

    if (emotion == ProfVoltsEmotion.happy) {
      // Braços erguidos comemorando!
      final swing = math.sin(animationValue * 2 * math.pi * 3) * 5;
      
      final lArmPath = Path()
        ..moveTo(w * 0.28, h * 0.48)
        ..lineTo(w * 0.17, h * 0.37 + swing)
        ..lineTo(w * 0.13, h * 0.25 + swing);
      canvas.drawPath(lArmPath, armPaint);
      canvas.drawCircle(Offset(w * 0.13, h * 0.25 + swing), 5, handPaint);
      
      final sparkPaint = Paint()
        ..color = neonAmber
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(w * 0.09, h * 0.19 + swing), Offset(w * 0.05, h * 0.15 + swing), sparkPaint);
      canvas.drawLine(Offset(w * 0.17, h * 0.19 + swing), Offset(w * 0.21, h * 0.15 + swing), sparkPaint);

      final rArmPath = Path()
        ..moveTo(w * 0.72, h * 0.48)
        ..lineTo(w * 0.83, h * 0.37 - swing)
        ..lineTo(w * 0.87, h * 0.25 - swing);
      canvas.drawPath(rArmPath, armPaint);
      canvas.drawCircle(Offset(w * 0.87, h * 0.25 - swing), 5, handPaint);
      
      canvas.drawLine(Offset(w * 0.91, h * 0.19 - swing), Offset(w * 0.95, h * 0.15 - swing), sparkPaint);
      canvas.drawLine(Offset(w * 0.83, h * 0.19 - swing), Offset(w * 0.79, h * 0.15 - swing), sparkPaint);
    } else if (emotion == ProfVoltsEmotion.sad) {
      // Braços caídos
      final sway = math.sin(animationValue * 2 * math.pi) * 2.0;
      
      final lArmPath = Path()
        ..moveTo(w * 0.28, h * 0.48)
        ..lineTo(w * 0.19 + sway, h * 0.58)
        ..lineTo(w * 0.17 + sway, h * 0.68);
      canvas.drawPath(lArmPath, armPaint);
      canvas.drawCircle(Offset(w * 0.17 + sway, h * 0.68), 5, handPaint);

      final rArmPath = Path()
        ..moveTo(w * 0.72, h * 0.48)
        ..lineTo(w * 0.81 - sway, h * 0.58)
        ..lineTo(w * 0.83 - sway, h * 0.68);
      canvas.drawPath(rArmPath, armPaint);
      canvas.drawCircle(Offset(w * 0.83 - sway, h * 0.68), 5, handPaint);
    } else {
      // Braços neutros
      final lArmPath = Path()
        ..moveTo(w * 0.28, h * 0.48)
        ..lineTo(w * 0.18, h * 0.54)
        ..lineTo(w * 0.22, h * 0.62);
      canvas.drawPath(lArmPath, armPaint);
      canvas.drawCircle(Offset(w * 0.22, h * 0.62), 5, handPaint);

      final rArmPath = Path()
        ..moveTo(w * 0.72, h * 0.48)
        ..lineTo(w * 0.82, h * 0.54)
        ..lineTo(w * 0.78, h * 0.62);
      canvas.drawPath(rArmPath, armPaint);
      canvas.drawCircle(Offset(w * 0.78, h * 0.62), 5, handPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FullBodyRobotPainter oldDelegate) {
    return oldDelegate.isDark != isDark ||
        oldDelegate.emotion != emotion ||
        oldDelegate.animationValue != animationValue;
  }
}
