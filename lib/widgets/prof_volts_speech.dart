import 'dart:async';
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

    final widgetContent = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mascote Avatar Holográfico Cyber HUD
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF00F0FF), Color(0xFF0066FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00F0FF).withValues(alpha: 0.4),
                blurRadius: 4,
                spreadRadius: 0.5,
              ),
            ],
          ),
          padding: const EdgeInsets.all(2.5),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? const Color(0xFF0B132B) : const Color(0xFFEFF6FF),
            ),
            child: const Center(
              child: Text('🤖', style: TextStyle(fontSize: 32)),
            ),
          ),
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
                  accentColor: const Color(0xFF00F0FF),
                  opacity: isDark ? 0.7 : 0.85,
                  borderWidth: 1.5,
                  borderGlowOnly: true,
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
                                decoration: const BoxDecoration(
                                  color: Color(0xFF00FF9D),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF00FF9D),
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
                                  color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0052CC),
                                ),
                              ),
                            ],
                          ),
                          if (widget.elapsedSeconds != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF00F0FF).withValues(alpha: 0.15)
                                    : const Color(0xFF0066FF).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF00F0FF).withValues(alpha: 0.4)
                                      : const Color(0xFF0066FF).withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.timer_rounded,
                                    size: 14,
                                    color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0066FF),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatTime(widget.elapsedSeconds!),
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0066FF),
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
                    color: isDark ? const Color(0xFF1E3A8A) : Colors.white.withValues(alpha: 0.9),
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
