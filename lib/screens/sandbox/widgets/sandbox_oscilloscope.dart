import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/sandbox_state.dart';

class SandboxOscilloscopeWidget extends StatefulWidget {
  const SandboxOscilloscopeWidget({
    super.key,
    required this.sandboxState,
    required this.isDark,
    required this.isEn,
    required this.onClose,
    this.voltageSignal = 0.0,
    this.currentSignal = 0.0,
  });

  final SandboxState sandboxState;
  final bool isDark;
  final bool isEn;
  final VoidCallback onClose;
  final double voltageSignal;
  final double currentSignal;

  @override
  State<SandboxOscilloscopeWidget> createState() => _SandboxOscilloscopeWidgetState();
}

class _SandboxOscilloscopeWidgetState extends State<SandboxOscilloscopeWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  bool _isRunning = true;
  double _voltsPerDiv = 2.0; // 2V por divisão
  int _timePerDivMs = 5; // 5ms por divisão
  String _selectedChannel = "CH1 (V)"; // CH1 (V) ou CH2 (I)

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSimulating = widget.sandboxState.isSimulating;
    final activeSignal = _selectedChannel.startsWith("CH1") ? widget.voltageSignal : widget.currentSignal;

    return Container(
      width: 320,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF0A111E).withValues(alpha: 0.95) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00FF9D),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FF9D).withValues(alpha: 0.25),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cabeçalho do Osciloscópio
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FF9D).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.show_chart_rounded, size: 16, color: Color(0xFF00FF9D)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'CYBER-SCOPE HUD-X',
                    style: TextStyle(
                      fontFamily: GoogleFonts.rajdhani().fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: widget.isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Run / Stop Toggle
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                    icon: Icon(
                      _isRunning ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                      size: 20,
                      color: _isRunning ? const Color(0xFF00FF9D) : Colors.amber,
                    ),
                    tooltip: _isRunning ? (widget.isEn ? "Pause Scope" : "Pausar Traço") : (widget.isEn ? "Run Scope" : "Iniciar Traço"),
                    onPressed: () => setState(() => _isRunning = !_isRunning),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                    icon: Icon(Icons.close_rounded, size: 16, color: widget.isDark ? Colors.white60 : Colors.black54),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // TELA DO OSCILOSCÓPIO (GRID CRT / OLED)
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF030D0B),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF00FF9D).withValues(alpha: 0.4)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: OscilloscopeWavePainter(
                      animValue: _isRunning ? _animController.value : 0.0,
                      isSimulating: isSimulating,
                      signalValue: activeSignal,
                      voltsPerDiv: _voltsPerDiv,
                      timePerDivMs: _timePerDivMs,
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 8),

          // CONTROLES DE ESCALA & CANAL
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Seletor de Canal
              DropdownButton<String>(
                value: _selectedChannel,
                isDense: true,
                dropdownColor: widget.isDark ? const Color(0xFF0F172A) : Colors.white,
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: GoogleFonts.rajdhani().fontFamily,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00FF9D),
                ),
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(value: "CH1 (V)", child: Text("CH1: Tensão (V)")),
                  DropdownMenuItem(value: "CH2 (I)", child: Text("CH2: Corrente (A)")),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedChannel = val);
                },
              ),

              // Volts/Div e Time/Div
              Row(
                children: [
                  Text(
                    '${_voltsPerDiv}V/Div',
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: GoogleFonts.shareTechMono().fontFamily,
                      color: widget.isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 2),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                    icon: const Icon(Icons.tune_rounded, size: 14, color: Color(0xFF00F5D4)),
                    onPressed: () {
                      setState(() {
                        if (_voltsPerDiv == 1.0) {
                          _voltsPerDiv = 2.0;
                        } else if (_voltsPerDiv == 2.0) {
                          _voltsPerDiv = 5.0;
                        } else {
                          _voltsPerDiv = 1.0;
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (_timePerDivMs == 5) {
                          _timePerDivMs = 10;
                        } else if (_timePerDivMs == 10) {
                          _timePerDivMs = 2;
                        } else {
                          _timePerDivMs = 5;
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Text(
                        '${_timePerDivMs}ms',
                        style: TextStyle(
                          fontSize: 10,
                          fontFamily: GoogleFonts.shareTechMono().fontFamily,
                          color: const Color(0xFF00FF9D),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OscilloscopeWavePainter extends CustomPainter {
  OscilloscopeWavePainter({
    required this.animValue,
    required this.isSimulating,
    required this.signalValue,
    required this.voltsPerDiv,
    required this.timePerDivMs,
  });

  final double animValue;
  final bool isSimulating;
  final double signalValue;
  final double voltsPerDiv;
  final int timePerDivMs;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF00FF9D).withValues(alpha: 0.12)
      ..strokeWidth = 1.0;

    // Desenha grid de divisões (8x6)
    const cols = 8;
    const rows = 6;
    final cellW = size.width / cols;
    final cellH = size.height / rows;

    for (int i = 0; i <= cols; i++) {
      canvas.drawLine(Offset(i * cellW, 0), Offset(i * cellW, size.height), gridPaint);
    }
    for (int j = 0; j <= rows; j++) {
      canvas.drawLine(Offset(0, j * cellH), Offset(size.width, j * cellH), gridPaint);
    }

    // Linha central de zero
    final zeroPaint = Paint()
      ..color = const Color(0xFF00FF9D).withValues(alpha: 0.3)
      ..strokeWidth = 1.5;
    final centerY = size.height / 2;
    canvas.drawLine(Offset(0, centerY), Offset(size.width, centerY), zeroPaint);

    if (!isSimulating || signalValue.abs() < 0.001) {
      // Sinal de Zero
      final flatPath = Path()
        ..moveTo(0, centerY)
        ..lineTo(size.width, centerY);

      final linePaint = Paint()
        ..color = const Color(0xFF00FF9D)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      canvas.drawPath(flatPath, linePaint);
      return;
    }

    // Desenha a forma de onda do sinal em tempo real
    final wavePath = Path();
    final wavePaint = Paint()
      ..color = const Color(0xFF00FF9D)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = const Color(0xFF00FF9D).withValues(alpha: 0.5)
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    // Amplitude do sinal normalizado em pixels
    final amplitudePx = (signalValue / voltsPerDiv) * cellH;
    final yPos = centerY - amplitudePx.clamp(-size.height / 2 + 5, size.height / 2 - 5);

    for (double x = 0; x < size.width; x += 2) {
      // Adiciona leve ruído / ripple dinâmico de simulação viva
      final phase = (x / size.width) * 4 * math.pi + (animValue * 2 * math.pi);
      final ripple = math.sin(phase) * 1.5;

      if (x == 0) {
        wavePath.moveTo(x, yPos + ripple);
      } else {
        wavePath.lineTo(x, yPos + ripple);
      }
    }

    canvas.drawPath(wavePath, glowPaint);
    canvas.drawPath(wavePath, wavePaint);
  }

  @override
  bool shouldRepaint(covariant OscilloscopeWavePainter oldDelegate) {
    return oldDelegate.animValue != animValue ||
        oldDelegate.isSimulating != isSimulating ||
        oldDelegate.signalValue != signalValue ||
        oldDelegate.voltsPerDiv != voltsPerDiv;
  }
}
