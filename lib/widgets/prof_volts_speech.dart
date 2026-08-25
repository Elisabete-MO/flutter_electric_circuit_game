import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/settings_controller.dart';
import 'glass_container.dart';

class ProfVoltsSpeech extends ConsumerStatefulWidget {
  const ProfVoltsSpeech({
    super.key,
    required this.text,
    this.elapsedSeconds,
  });

  final String text;
  final int? elapsedSeconds;

  @override
  ConsumerState<ProfVoltsSpeech> createState() => _ProfVoltsSpeechState();
}

class _ProfVoltsSpeechState extends ConsumerState<ProfVoltsSpeech>
    with SingleTickerProviderStateMixin {
  late AnimationController _appearanceController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  String _displayedText = '';
  int _charIndex = 0;
  Timer? _typewriterTimer;

  @override
  void initState() {
    super.initState();
    _appearanceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _slideAnimation = Tween<double>(begin: 15.0, end: 0.0).animate(
      CurvedAnimation(parent: _appearanceController, curve: Curves.easeOutQuad),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _appearanceController, curve: Curves.easeIn),
    );

    _appearanceController.forward();
    _startTypewriter();
  }

  @override
  void didUpdateWidget(covariant ProfVoltsSpeech oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _startTypewriter();
    }
  }

  void _startTypewriter() {
    _typewriterTimer?.cancel();
    final settings = ref.read(settingsControllerProvider);
    
    if (settings.reduceAnimations) {
      setState(() {
        _displayedText = widget.text;
        _charIndex = widget.text.length;
      });
      return;
    }

    _charIndex = 0;
    _displayedText = '';

    const charDuration = Duration(milliseconds: 12);
    _typewriterTimer = Timer.periodic(charDuration, (timer) {
      if (_charIndex < widget.text.length) {
        setState(() {
          _displayedText += widget.text[_charIndex];
          _charIndex++;
        });
      } else {
        _typewriterTimer?.cancel();
      }
    });
  }

  void _completeTypewriter() {
    if (_charIndex < widget.text.length) {
      _typewriterTimer?.cancel();
      setState(() {
        _displayedText = widget.text;
        _charIndex = widget.text.length;
      });
    }
  }

  @override
  void dispose() {
    _appearanceController.dispose();
    _typewriterTimer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = (seconds / 60).floor().toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = ref.watch(settingsControllerProvider);
    final isTalking = _charIndex < widget.text.length;

    final widgetContent = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mascote Avatar Holográfico Cyber HUD Animado
        ProfVoltsAvatar(
          isTalking: isTalking,
          size: 62.0,
        ),
        const SizedBox(width: 16),
        // Speech Bubble HUD Holográfico
        Expanded(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: _completeTypewriter,
                behavior: HitTestBehavior.opaque,
                child: GlassContainer(
                  padding: const EdgeInsets.all(16),
                  accentColor: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0052CC),
                  baseColor: Colors.white,
                  opacity: 1.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF00FF9D) : const Color(0xFF00875A),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDark ? const Color(0xFF00FF9D) : const Color(0xFF00875A),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'PROF. VOLTS',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  color: const Color(0xFF0052CC),
                                ),
                              ),
                            ],
                          ),
                          if (widget.elapsedSeconds != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0066FF).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: const Color(0xFF0066FF).withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.timer_rounded,
                                    size: 14,
                                    color: const Color(0xFF0066FF),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatTime(widget.elapsedSeconds!),
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: const Color(0xFF0066FF),
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _displayedText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Speech bubble triangle pointing left
              Positioned(
                left: -8,
                top: 20,
                child: CustomPaint(
                  size: const Size(10, 10),
                  painter: _TrianglePainter(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (settings.reduceAnimations) {
      return widgetContent;
    }

    return AnimatedBuilder(
      animation: _appearanceController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0.0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: widgetContent,
          ),
        );
      },
    );
  }
}

/// Avatar Robótico Cyberpunk Animado
class ProfVoltsAvatar extends StatefulWidget {
  const ProfVoltsAvatar({
    super.key,
    required this.isTalking,
    this.size = 62.0,
  });

  final bool isTalking;
  final double size;

  @override
  State<ProfVoltsAvatar> createState() => _ProfVoltsAvatarState();
}

class _ProfVoltsAvatarState extends State<ProfVoltsAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isBlinking = false;
  double _talkingOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _animationController.addListener(() {
      if (widget.isTalking) {
        setState(() {
          _talkingOffset = _animationController.value * 2 * math.pi * 12;
        });
      }
      
      final val = _animationController.value;
      final shouldBlink = val > 0.94 && val < 0.97;
      if (shouldBlink != _isBlinking) {
        setState(() {
          _isBlinking = shouldBlink;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CustomPaint(
        painter: _RobotAvatarPainter(
          isDark: isDark,
          isTalking: widget.isTalking,
          isBlinking: _isBlinking,
          talkingOffset: _talkingOffset,
        ),
      ),
    );
  }
}

class _RobotAvatarPainter extends CustomPainter {
  final bool isDark;
  final bool isTalking;
  final bool isBlinking;
  final double talkingOffset;

  _RobotAvatarPainter({
    required this.isDark,
    required this.isTalking,
    required this.isBlinking,
    required this.talkingOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    final neonCyan = isDark ? const Color(0xFF00F0FF) : const Color(0xFF0097A7);
    const neonBlue = Color(0xFF0066FF);
    final neonGreen = isDark ? const Color(0xFF00FF9D) : const Color(0xFF00875A);
    final shellColor = isDark ? const Color(0xFF1E1E2F) : Colors.white;
    final screenColor = isDark ? const Color(0xFF0B0F19) : const Color(0xFF151E32);
    final borderColor = isDark ? neonCyan.withValues(alpha: 0.75) : const Color(0xFF0052CC);

    // 1. Glow circular de fundo
    final glowPaint = Paint()
      ..color = (isDark ? neonCyan : neonBlue).withValues(alpha: 0.18)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(center, w / 2 - 2, glowPaint);

    // 2. Pescoço/Base
    final basePaint = Paint()
      ..color = shellColor
      ..style = PaintingStyle.fill;
    final baseRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.35, h * 0.76, w * 0.3, h * 0.12),
      const Radius.circular(3),
    );
    canvas.drawRRect(baseRect, basePaint);

    // 3. Antenas laterais (Orelhas)
    final earPaint = Paint()
      ..color = isDark ? neonBlue.withValues(alpha: 0.8) : Colors.grey.shade500;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.08, h * 0.36, w * 0.08, h * 0.18),
        const Radius.circular(2),
      ),
      earPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.84, h * 0.36, w * 0.08, h * 0.18),
        const Radius.circular(2),
      ),
      earPaint,
    );

    // Piquete de antena no topo
    final antennaPaint = Paint()
      ..color = shellColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(w * 0.47, h * 0.08, w * 0.06, h * 0.10), antennaPaint);
    
    // LED piscante da antena
    final ledPaint = Paint()
      ..color = isTalking ? neonGreen : neonCyan
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w / 2, h * 0.06), 3, ledPaint);

    // 4. Carcaça da Cabeça do Robô (cantos arredondados)
    final shellPaint = Paint()
      ..color = shellColor
      ..style = PaintingStyle.fill;
    final shellBorderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final headRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.14, h * 0.16, w * 0.72, h * 0.60),
      const Radius.circular(10),
    );
    canvas.drawRRect(headRRect, shellPaint);
    canvas.drawRRect(headRRect, shellBorderPaint);

    // 5. Visor (Tela interna)
    final screenPaint = Paint()
      ..color = screenColor
      ..style = PaintingStyle.fill;
    final screenRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.20, h * 0.21, w * 0.60, h * 0.50),
      const Radius.circular(6),
    );
    canvas.drawRRect(screenRRect, screenPaint);

    // 6. Olhos digitais LED (Piscam ciclicamente)
    final eyePaint = Paint()
      ..color = isDark ? neonCyan : neonBlue
      ..style = PaintingStyle.fill;

    final eyeWidth = w * 0.09;
    final eyeHeight = isBlinking ? h * 0.015 : h * 0.10;
    final eyeY = h * 0.32 + (isBlinking ? (h * 0.042) : 0);

    // Olho Esquerdo
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.32, eyeY, eyeWidth, eyeHeight),
        const Radius.circular(2),
      ),
      eyePaint,
    );

    // Olho Direito
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.58, eyeY, eyeWidth, eyeHeight),
        const Radius.circular(2),
      ),
      eyePaint,
    );

    // 7. Boca de Osciloscópio (Waveform eletrônica)
    final wavePaint = Paint()
      ..color = neonGreen
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final wavePath = Path();
    final waveY = h * 0.56;
    final startX = w * 0.32;
    final endX = w * 0.68;
    final waveWidth = endX - startX;

    wavePath.moveTo(startX, waveY);

    if (isTalking) {
      for (double x = 0; x <= waveWidth; x += 1) {
        final currentX = startX + x;
        final factor = math.sin((x / waveWidth) * math.pi);
        final amplitude = h * 0.08 * factor;
        final waveValue = math.sin((x * 0.45) - talkingOffset) * amplitude;
        wavePath.lineTo(currentX, waveY + waveValue);
      }
    } else {
      for (double x = 0; x <= waveWidth; x += 1) {
        final currentX = startX + x;
        final factor = math.sin((x / waveWidth) * math.pi);
        final waveValue = math.sin(x * 0.15) * 1.5 * factor;
        wavePath.lineTo(currentX, waveY + waveValue);
      }
    }
    canvas.drawPath(wavePath, wavePaint);
    
    // 8. Linha de varredura (Scanline) holográfica sutil
    if (isDark) {
      final scanPaint = Paint()
        ..color = neonCyan.withValues(alpha: 0.12)
        ..strokeWidth = 1.0;
      canvas.drawLine(Offset(w * 0.20, h * 0.44), Offset(w * 0.80, h * 0.44), scanPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RobotAvatarPainter oldDelegate) {
    return oldDelegate.isDark != isDark ||
        oldDelegate.isTalking != isTalking ||
        oldDelegate.isBlinking != isBlinking ||
        oldDelegate.talkingOffset != talkingOffset;
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(0, size.height / 2)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
