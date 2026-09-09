import 'dart:io' show Platform;
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/ui_scale.dart';

/// ----------------------------------------------------------------------------
/// AVATAR DO PROF. VOLTS
/// ----------------------------------------------------------------------------
class ProfVoltsAvatar extends StatefulWidget {
  final double size;
  final bool isTalking;

  const ProfVoltsAvatar({super.key, this.size = 38.0, this.isTalking = false});

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
    );
    final isTesting =
        !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    if (!isTesting) {
      _animationController.repeat();
    }

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
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CustomPaint(
        painter: _RobotAvatarPainter(
          isDark: false,
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
    final neonGreen = isDark
        ? const Color(0xFF00FF9D)
        : const Color(0xFF00875A);
    final shellColor = isDark ? const Color(0xFF1E1E2F) : Colors.white;
    final screenColor = isDark
        ? const Color(0xFF0B0F19)
        : const Color(0xFF151E32);
    final borderColor = isDark
        ? neonCyan.withValues(alpha: 0.75)
        : const Color(0xFF0052CC);

    // 1. Glow circular de fundo
    final glowPaint = Paint()
      ..color = (isDark ? neonCyan : neonBlue).withValues(alpha: 0.18)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center, w / 2 - 1, glowPaint);

    // 2. Pescoço/Base
    final basePaint = Paint()
      ..color = shellColor
      ..style = PaintingStyle.fill;
    final baseRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.35, h * 0.76, w * 0.3, h * 0.12),
      Radius.circular(w * 0.05),
    );
    canvas.drawRRect(baseRect, basePaint);

    // 3. Antenas laterais (Orelhas)
    final earPaint = Paint()
      ..color = isDark ? neonBlue.withValues(alpha: 0.8) : Colors.grey.shade500;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.08, h * 0.36, w * 0.08, h * 0.18),
        Radius.circular(w * 0.04),
      ),
      earPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.84, h * 0.36, w * 0.08, h * 0.18),
        Radius.circular(w * 0.04),
      ),
      earPaint,
    );

    // Piquete de antena no topo
    final antennaPaint = Paint()
      ..color = shellColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(w * 0.47, h * 0.08, w * 0.06, h * 0.10),
      antennaPaint,
    );

    // LED piscante da antena
    final ledPaint = Paint()
      ..color = isTalking ? neonGreen : neonCyan
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(w / 2, h * 0.06),
      (w * 0.05).clamp(2.0, 3.5),
      ledPaint,
    );

    // 4. Carcaça da Cabeça do Robô (cantos arredondados)
    final shellPaint = Paint()
      ..color = shellColor
      ..style = PaintingStyle.fill;
    final shellBorderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = (w * 0.045).clamp(1.2, 2.0)
      ..style = PaintingStyle.stroke;

    final headRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.14, h * 0.16, w * 0.72, h * 0.60),
      Radius.circular(w * 0.16),
    );
    canvas.drawRRect(headRRect, shellPaint);
    canvas.drawRRect(headRRect, shellBorderPaint);

    // 5. Visor (Tela interna)
    final screenPaint = Paint()
      ..color = screenColor
      ..style = PaintingStyle.fill;
    final screenRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.20, h * 0.21, w * 0.60, h * 0.50),
      Radius.circular(w * 0.10),
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
        Radius.circular(w * 0.03),
      ),
      eyePaint,
    );

    // Olho Direito
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.58, eyeY, eyeWidth, eyeHeight),
        Radius.circular(w * 0.03),
      ),
      eyePaint,
    );

    // 7. Boca de Osciloscópio (Waveform eletrônica)
    final wavePaint = Paint()
      ..color = neonGreen
      ..strokeWidth = (w * 0.035).clamp(1.0, 1.6)
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
      canvas.drawLine(
        Offset(w * 0.20, h * 0.44),
        Offset(w * 0.80, h * 0.44),
        scanPaint,
      );
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

/// ----------------------------------------------------------------------------
/// CARD 1: OBJETIVO DA MISSÃO COM DICA DO PROF. VOLTS
/// ----------------------------------------------------------------------------
class WorkbenchMissionObjectiveCard extends StatelessWidget {
  final int missionNumber;
  final String title;
  final String description;
  final String voltsTip;
  final Color accentColor;

  const WorkbenchMissionObjectiveCard({
    super.key,
    required this.missionNumber,
    required this.title,
    required this.description,
    required this.voltsTip,
    this.accentColor = const Color(0xFF0284C7),
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;

    return Container(
      padding: EdgeInsets.all(scale.spacing(16, min: 12, max: 28)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(scale.size(18, min: 12, max: 28)),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: scale.size(10, min: 6, max: 18),
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho com Ícone e Título da Missão
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: scale.size(28, min: 22, max: 40),
                height: scale.size(28, min: 22, max: 40),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: 0.12),
                ),
                child: Icon(
                  Icons.crisis_alert_rounded,
                  color: accentColor,
                  size: scale.icon(18, min: 14, max: 26),
                ),
              ),
              SizedBox(width: scale.spacing(8, min: 5, max: 14)),
              Expanded(
                child: Text(
                  'Missão $missionNumber · $title',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.w700,
                    fontSize: scale.font(14.5, min: 12.5, max: 22.0),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: scale.spacing(10, min: 6, max: 16)),

          // Texto Descritivo do Desafio
          Text(
            description,
            style: GoogleFonts.outfit(
              color: const Color(0xFF475569),
              fontSize: scale.font(12.5, min: 11.0, max: 18.0),
              height: 1.35,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: scale.spacing(12, min: 8, max: 18)),

          // Caixa de Dica Acolhedora do Prof. Volts
          ProfVoltsTipBox(voltsTip: voltsTip),
        ],
      ),
    );
  }
}

/// ----------------------------------------------------------------------------
/// CAIXA DE DICA REUTILIZÁVEL DO PROF. VOLTS (ROBOZINHO)
/// ----------------------------------------------------------------------------
class ProfVoltsTipBox extends StatelessWidget {
  final String voltsTip;

  const ProfVoltsTipBox({super.key, required this.voltsTip});

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: scale.spacing(10, min: 6, max: 18),
        vertical: scale.spacing(10, min: 6, max: 18),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(scale.size(14, min: 10, max: 22)),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.0),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 140;
          final avatarSize = isNarrow
              ? (constraints.maxWidth * 0.35).clamp(18.0, 32.0)
              : scale.size(38, min: 28, max: 54);

          final tipContent = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Dica do Prof. Volts:',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFD97706),
                  fontWeight: FontWeight.w700,
                  fontSize: scale.font(12, min: 10.0, max: 18.0),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '“$voltsTip”',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF78350F),
                  fontSize: scale.font(11.5, min: 9.5, max: 17.0),
                  fontStyle: FontStyle.italic,
                  height: 1.3,
                ),
              ),
            ],
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ProfVoltsAvatar(size: avatarSize),
                const SizedBox(height: 6),
                tipContent,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfVoltsAvatar(size: avatarSize),
              SizedBox(width: scale.spacing(10, min: 6, max: 16)),
              Expanded(child: tipContent),
            ],
          );
        },
      ),
    );
  }
}

/// ----------------------------------------------------------------------------
/// CARD 2: PROGRESSO DA INVESTIGAÇÃO (STEPPER DINÂMICO INTERATIVO)
/// ----------------------------------------------------------------------------
class WorkbenchInvestigationStepperCard extends StatelessWidget {
  final String title;
  final List<String> steps;
  final int currentStepIndex;
  final bool Function(int index) isStepCompleted;
  final Color accentColor;

  const WorkbenchInvestigationStepperCard({
    super.key,
    this.title = 'Progresso da investigação',
    required this.steps,
    required this.currentStepIndex,
    required this.isStepCompleted,
    this.accentColor = const Color(0xFF0284C7),
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;

    return Container(
      padding: EdgeInsets.all(scale.spacing(16, min: 12, max: 28)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(scale.size(18, min: 12, max: 28)),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: scale.size(10, min: 6, max: 18),
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho com Prancheta
          Row(
            children: [
              Container(
                width: scale.size(28, min: 22, max: 40),
                height: scale.size(28, min: 22, max: 40),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: 0.12),
                ),
                child: Icon(
                  Icons.assignment_turned_in_rounded,
                  color: accentColor,
                  size: scale.icon(18, min: 14, max: 26),
                ),
              ),
              SizedBox(width: scale.spacing(8, min: 5, max: 14)),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.w700,
                    fontSize: scale.font(14.5, min: 12.5, max: 22.0),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: scale.spacing(12, min: 8, max: 18)),

          // Lista de Etapas do Stepper
          for (int i = 0; i < steps.length; i++) ...[
            _buildStepRow(
              context: context,
              index: i,
              label: steps[i],
              isCompleted: isStepCompleted(i),
              isActive: i == currentStepIndex && !isStepCompleted(i),
            ),
            if (i < steps.length - 1) SizedBox(height: scale.spacing(6, min: 4, max: 10)),
          ],
        ],
      ),
    );
  }

  Widget _buildStepRow({
    required BuildContext context,
    required int index,
    required String label,
    required bool isCompleted,
    required bool isActive,
  }) {
    final stepNumber = index + 1;
    final scale = context.uiScale;

    // 1. Etapa Ativa (Destaque em Verde-Menta com Seta)
    if (isActive) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: scale.spacing(10, min: 7, max: 18),
          vertical: scale.spacing(7, min: 5, max: 13),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(scale.size(12, min: 8, max: 18)),
          border: Border.all(color: const Color(0xFFA7F3D0), width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              width: scale.size(24, min: 20, max: 36),
              height: scale.size(24, min: 20, max: 36),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF059669),
              ),
              child: Center(
                child: Text(
                  '$stepNumber',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: scale.font(12, min: 10, max: 18),
                  ),
                ),
              ),
            ),
            SizedBox(width: scale.spacing(10, min: 6, max: 16)),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.outfit(
                  color: const Color(0xFF065F46),
                  fontWeight: FontWeight.w700,
                  fontSize: scale.font(12.5, min: 11.0, max: 18.0),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              color: const Color(0xFF059669),
              size: scale.icon(16, min: 13, max: 24),
            ),
          ],
        ),
      );
    }

    // 2. Etapa Concluída (Círculo Verde com Check)
    if (isCompleted) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: scale.spacing(10, min: 7, max: 18),
          vertical: scale.spacing(5, min: 3, max: 10),
        ),
        child: Row(
          children: [
            Container(
              width: scale.size(24, min: 20, max: 36),
              height: scale.size(24, min: 20, max: 36),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF10B981),
              ),
              child: Center(
                child: Icon(Icons.check_rounded, color: Colors.white, size: scale.icon(14, min: 12, max: 22)),
              ),
            ),
            SizedBox(width: scale.spacing(10, min: 6, max: 16)),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.outfit(
                  color: const Color(0xFF0F172A),
                  fontWeight: FontWeight.w500,
                  fontSize: scale.font(12.5, min: 11.0, max: 18.0),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 3. Etapa Pendente (Círculo Cinza com Número)
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: scale.spacing(10, min: 7, max: 18),
        vertical: scale.spacing(5, min: 3, max: 10),
      ),
      child: Row(
        children: [
          Container(
            width: scale.size(24, min: 20, max: 36),
            height: scale.size(24, min: 20, max: 36),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF94A3B8),
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: scale.font(12, min: 10, max: 18),
                ),
              ),
            ),
          ),
          SizedBox(width: scale.spacing(10, min: 6, max: 16)),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w400,
                fontSize: scale.font(12.5, min: 11.0, max: 18.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

