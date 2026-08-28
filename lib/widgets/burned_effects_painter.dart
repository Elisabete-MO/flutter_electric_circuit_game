import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Helper para renderizar animações de fumaça subindo, incandescência residual
/// e fagulhas/faíscas (Smoke & Embers) em componentes queimados.
void drawBurnedSmokeAndEmbers(
  Canvas canvas,
  Size size,
  double cx,
  double cy,
  double animationValue, {
  bool isDark = true,
}) {
  final progress = animationValue.clamp(0.0, 1.0);

  // 1. Mancha de fuligem (Soot / Charcoal stain) no fundo
  final sootRadius = size.width * 0.36;
  canvas.drawCircle(
    Offset(cx, cy),
    sootRadius,
    Paint()
      ..color = Colors.black.withValues(alpha: 0.72)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
  );

  // 2. Incandescência residual pulsante (Amber/Red Glowing Core)
  final glowPulse = 0.5 + 0.3 * math.sin(progress * math.pi * 2 * 3);
  final glowRadius = size.width * 0.24;
  final coreGlowPaint = Paint()
    ..shader = RadialGradient(
      colors: [
        const Color(0xFFFF3D00).withValues(alpha: 0.7 * glowPulse),
        const Color(0xFFFF9100).withValues(alpha: 0.35 * glowPulse),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: glowRadius));
  canvas.drawCircle(Offset(cx, cy), glowRadius, coreGlowPaint);

  // 3. Fumaça subindo (Smoke Puffs) - 6 partículas determinísticas
  const smokeCount = 6;
  for (int i = 0; i < smokeCount; i++) {
    final phase = i / smokeCount;
    final t = (progress + phase) % 1.0; // 0.0 (início) a 1.0 (dissipação)

    // A fumaça sobe do centro para cima
    final riseDistance = 26.0 + (i % 3) * 10.0;
    final dy = cy - (t * riseDistance);

    // Oscilação lateral suave (Swaying horizontal)
    final swayAmplitude = 6.0 + (i % 2) * 4.0;
    final dx = cx + math.sin(t * math.pi * 2 + i * 1.5) * swayAmplitude;

    // A partícula de fumaça expande de 3.5px para 15px
    final puffRadius = 3.5 + t * 12.0;

    // Opacidade: surge rápido, depois esmaece gradualmente
    final opacity = (t < 0.2 ? t / 0.2 : math.pow(1.0 - t, 1.4).toDouble()) * 0.45;

    final smokeColor = isDark
        ? const Color(0xFF424242).withValues(alpha: opacity)
        : const Color(0xFF616161).withValues(alpha: opacity * 0.85);

    final smokePaint = Paint()
      ..color = smokeColor
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3.0 + t * 4.0);

    canvas.drawCircle(Offset(dx, dy), puffRadius, smokePaint);
  }

  // 4. Fagulhas e faíscas incandescentes (Ember Sparks) - 8 fagulhas saltitantes
  const emberCount = 8;
  for (int j = 0; j < emberCount; j++) {
    final phase = j * 0.125;
    final t = (progress * 1.6 + phase) % 1.0;

    // Ângulo de disparo (predominantemente para cima e para os lados)
    final baseAngle = -math.pi / 2; // Para cima
    final spread = (j - 3.5) * 0.35 + math.sin(j * 2.1) * 0.2;
    final angle = baseAngle + spread;

    // Distância percorrida e pequena gravidade no final
    final speed = 14.0 + (j % 4) * 7.0;
    final dist = t * speed;
    final gravity = t * t * 6.0;

    final sx = cx + math.cos(angle) * dist;
    final sy = cy + math.sin(angle) * dist + gravity;

    // Tamanho e cintilação
    final sparkRadius = (1.0 - t * 0.7) * (2.2 + (j % 2) * 0.8);
    final sparkOpacity = (t < 0.7 ? 1.0 : (1.0 - t) / 0.3) * (0.7 + 0.3 * math.sin(t * 20 + j));

    final sparkColors = [
      const Color(0xFFFFD54F), // Amarelo incandescente
      const Color(0xFFFF9100), // Laranja fogo
      const Color(0xFFFF3D00), // Vermelho brasas
      const Color(0xFFFFFFFF), // Branco raio
    ];
    final sparkColor = sparkColors[j % sparkColors.length].withValues(alpha: sparkOpacity.clamp(0.0, 1.0));

    // Aura de brilho na fagulha
    canvas.drawCircle(
      Offset(sx, sy),
      sparkRadius * 2.2,
      Paint()
        ..color = sparkColor.withValues(alpha: (sparkOpacity * 0.4).clamp(0.0, 1.0))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    // Ponto central da fagulha
    canvas.drawCircle(
      Offset(sx, sy),
      sparkRadius,
      Paint()..color = sparkColor,
    );
  }

  // 5. Ícone/Emoji de explosão/queima no centro
  final textPainter = TextPainter(
    text: const TextSpan(
      text: '💥',
      style: TextStyle(fontSize: 18),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  textPainter.paint(canvas, Offset(cx - 9, cy - 11));
}
