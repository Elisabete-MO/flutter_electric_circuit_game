import 'dart:math';
import 'package:flutter/material.dart';

/// Widget que exibe animação de confetti/estrelas ao completar uma missão.
/// Use com um AnimationController ou直接 chame [show] para um efeito one-shot.
class SuccessConfettiOverlay extends StatefulWidget {
  final Widget child;
  final bool show;

  const SuccessConfettiOverlay({
    super.key,
    required this.child,
    this.show = false,
  });

  @override
  State<SuccessConfettiOverlay> createState() => _SuccessConfettiOverlayState();
}

class _SuccessConfettiOverlayState extends State<SuccessConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..addListener(_tick);

    if (widget.show) {
      _startConfetti();
    }
  }

  @override
  void didUpdateWidget(SuccessConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show && !oldWidget.show) {
      _startConfetti();
    } else if (!widget.show && oldWidget.show) {
      _controller.stop();
      setState(() => _particles.clear());
    }
  }

  void _startConfetti() {
    _particles.clear();
    for (int i = 0; i < 50; i++) {
      _particles.add(_Particle(
        x: 0.3 + _random.nextDouble() * 0.4,
        y: 0.3 + _random.nextDouble() * 0.2,
        vx: (_random.nextDouble() - 0.5) * 0.4,
        vy: -0.3 - _random.nextDouble() * 0.5,
        size: 4 + _random.nextDouble() * 8,
        color: [
          const Color(0xFFF59E0B),
          const Color(0xFF10B981),
          const Color(0xFF0284C7),
          const Color(0xFFDC2626),
          const Color(0xFF8B5CF6),
        ][_random.nextInt(5)],
        rotation: _random.nextDouble() * pi * 2,
        rotSpeed: (_random.nextDouble() - 0.5) * 0.3,
        shape: _random.nextBool() ? _ParticleShape.circle : _ParticleShape.star,
      ));
    }
    _controller.forward(from: 0);
  }

  void _tick() {
    for (final p in _particles) {
      p.x += p.vx * 0.016;
      p.y += p.vy * 0.016;
      p.vy += 0.15;
      p.rotation += p.rotSpeed;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_controller.isAnimating)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ConfettiPainter(particles: _particles),
              ),
            ),
          ),
      ],
    );
  }
}

enum _ParticleShape { circle, star }

class _Particle {
  double x, y, vx, vy, size, rotation, rotSpeed;
  final Color color;
  final _ParticleShape shape;

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotSpeed,
    required this.shape,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;

  _ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = p.color.withValues(alpha: max(0.0, 1 - (p.y + 0.5).clamp(0, 1)))
        ..style = PaintingStyle.fill;

      final cx = p.x * size.width;
      final cy = p.y * size.height;

      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(p.rotation);

      if (p.shape == _ParticleShape.circle) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        _drawStar(canvas, p.size / 2, paint);
      }

      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final outerAngle = (i * 2 * pi / 5) - pi / 2;
      final innerAngle = outerAngle + pi / 5;
      final outerR = radius;
      final innerR = radius * 0.4;

      if (i == 0) {
        path.moveTo(cos(outerAngle) * outerR, sin(outerAngle) * outerR);
      } else {
        path.lineTo(cos(outerAngle) * outerR, sin(outerAngle) * outerR);
      }
      path.lineTo(cos(innerAngle) * innerR, sin(innerAngle) * innerR);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => true;
}

/// Mostra confetti sobre um contexto por 2 segundos.
void showSuccessConfetti(BuildContext context) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _SuccessConfettiEntry(
      onDone: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

class _SuccessConfettiEntry extends StatefulWidget {
  final VoidCallback onDone;

  const _SuccessConfettiEntry({required this.onDone});

  @override
  State<_SuccessConfettiEntry> createState() => _SuccessConfettiEntryState();
}

class _SuccessConfettiEntryState extends State<_SuccessConfettiEntry>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onDone();
        }
      })..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SuccessConfettiOverlay(
      show: _controller.isAnimating,
      child: const SizedBox.expand(),
    );
  }
}
