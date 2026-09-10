import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../core/ui_scale.dart';
import '../../utils/preloader.dart';
import '../../widgets/circuit_e_emblem.dart';

/// Tela de Abertura (Splash/Boot) do EletroLab.
/// Executa o pré-carregamento dos assets pesados, exibe animação de energização
/// de circuito elétrico neon em tempo real e redireciona para o Menu Principal (`Routes.menu`).
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.minDuration = const Duration(milliseconds: 2400),
    this.preloadAssets = true,
  });

  /// Duração mínima para que a animação de energização seja apreciada.
  final Duration minDuration;

  /// Se deve pré-carregar os assets do bundle (ativo por padrão).
  final bool preloadAssets;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  Timer? _circuitTimer;
  double _circuitPhase = 0.0;
  bool _preloadFinished = false;
  bool _navigationTriggered = false;

  static const List<String> _statusMessages = [
    'Conectando à rede elétrica do Ginásio...',
    'Calibrando voltímetros e multímetros...',
    'Alimentando circuitos e componentes...',
    'Preparando os estandes da Feira...',
    'Circuito fechado! Sistema online!',
  ];

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: widget.minDuration,
    );

    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOutCubic,
    );

    _progressController.addListener(() {
      setState(() {});
    });

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Só navega quando o preload de todos os assets estiver concluído
        if (_preloadFinished || !widget.preloadAssets) {
          _navigateNext();
        }
        // Se o preload ainda não terminou, o _navigateNext() será chamado
        // pelo próprio _startPreload() ao terminar
      }
    });

    // Pulso das correntes elétricas no fundo
    _circuitTimer = Timer.periodic(const Duration(milliseconds: 32), (_) {
      if (mounted) {
        setState(() {
          _circuitPhase = (_circuitPhase + 0.035) % (math.pi * 2);
        });
      }
    });

    _progressController.forward();
    _startPreload();
  }

  @override
  void dispose() {
    _circuitTimer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _startPreload() async {
    if (!widget.preloadAssets) {
      _preloadFinished = true;
      if (_progressController.isCompleted) {
        _navigateNext();
      }
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        if (mounted) {
          await Preloader.preloadResources(
            context,
            imageAssets: Preloader.allAppAssets,
            blockInteractions: false, // Splash já é a tela de bloqueio
          );
        }
      } catch (_) {
        // Ignora caso algum asset específico não esteja disponível
      }

      if (mounted) {
        _preloadFinished = true;
        if (_progressController.isCompleted) {
          _navigateNext();
        }
      }
    });
  }

  void _navigateNext() {
    if (_navigationTriggered || !mounted) return;
    _navigationTriggered = true;

    Navigator.of(context).pushReplacementNamed(Routes.menu);
  }

  String _currentStatusMessage(double progress) {
    if (progress < 0.22) return _statusMessages[0];
    if (progress < 0.48) return _statusMessages[1];
    if (progress < 0.74) return _statusMessages[2];
    if (progress < 0.94) return _statusMessages[3];
    return _statusMessages[4];
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;
    final double progress = _progressAnimation.value.clamp(0.0, 1.0);
    final double currentVoltage = progress * 12.0;
    final int percentage = (progress * 100).toInt();
    final String statusText = _currentStatusMessage(progress);

    return Scaffold(
      backgroundColor: const Color(0xFF021712),
      body: Stack(
        children: [
          // 1. Fundo com malha de circuito elétrico animado
          Positioned.fill(
            child: CustomPaint(
              painter: _CircuitGridPainter(
                phase: _circuitPhase,
                chargeProgress: progress,
              ),
            ),
          ),

          // 2. Vinheta e gradiente sutil de profundidade
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.1,
                  colors: [
                    const Color(0xFF04382B).withValues(alpha: 0.35 * progress),
                    Colors.transparent,
                    const Color(0xFF010E0B).withValues(alpha: 0.85),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // 3. Conteúdo Central de Energização
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: scale.insetsSymmetric(horizontal: 28, vertical: 16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: scale.size(520, min: 360, max: 720),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                    children: [
                      // Emblema Central com Raio Energizado
                      _buildEnergizedEmblem(scale, progress),

                      SizedBox(height: scale.spacing(20, min: 14, max: 30)),

                      // Marca Oficial do Jogo: ELETROLAB dual-tone
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'ELETRO',
                              style: TextStyle(
                                color: const Color(0xFFF8FAFC),
                                shadows: [
                                  Shadow(
                                    color: const Color(0xFF34D399)
                                        .withValues(alpha: 0.70 * progress),
                                    blurRadius: scale.size(12),
                                  ),
                                  Shadow(
                                    color: const Color(0xFF00E5FF)
                                        .withValues(alpha: 0.55 * progress),
                                    blurRadius: scale.size(24),
                                  ),
                                ],
                              ),
                            ),
                            TextSpan(
                              text: 'LAB',
                              style: TextStyle(
                                color: const Color(0xFFFBBF24),
                                shadows: [
                                  Shadow(
                                    color: const Color(0xFFF59E0B)
                                        .withValues(alpha: 0.85 * progress),
                                    blurRadius: scale.size(16),
                                  ),
                                  Shadow(
                                    color: const Color(0xFFD97706)
                                        .withValues(alpha: 0.60 * progress),
                                    blurRadius: scale.size(32),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.orbitron(
                          fontSize: scale.font(40, min: 26, max: 54),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4.0,
                        ),
                      ),

                      SizedBox(height: scale.spacing(4)),

                      Text(
                        'ENERGIZANDO A FEIRA DE CIÊNCIAS',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF34D399),
                          fontSize: scale.font(13.5, min: 10.5, max: 17),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.8,
                        ),
                      ),

                      SizedBox(height: scale.spacing(12, min: 8, max: 18)),

                      // Badge de Franquia / Edição: JOGO 1 • VOLUME 1
                      _buildVolumeBadge(scale, progress),

                      SizedBox(height: scale.spacing(28, min: 18, max: 42)),

                      // Medidor de Voltagem e Porcentagem
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: scale.spacing(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.bolt_rounded,
                                  color: const Color(0xFF10B981),
                                  size: scale.icon(18, min: 14, max: 24),
                                ),
                                SizedBox(width: scale.spacing(4)),
                                Text(
                                  '${currentVoltage.toStringAsFixed(1)} V',
                                  style: GoogleFonts.rajdhani(
                                    color: const Color(0xFFE2E8F0),
                                    fontSize: scale.font(16, min: 13, max: 22),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '$percentage%',
                              style: GoogleFonts.rajdhani(
                                color: EletroLabColors.neonCyan,
                                fontSize: scale.font(18, min: 14, max: 24),
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: scale.spacing(8)),

                      // Barra de Carga Temática (Capacitor / Linha Neon)
                      _buildPowerBar(scale, progress),

                      SizedBox(height: scale.spacing(14, min: 10, max: 20)),

                      // Mensagem de Status Dinâmica com altura fixa para evitar sobreposição
                      SizedBox(
                        height: scale.size(26, min: 20, max: 34),
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            layoutBuilder: (currentChild, previousChildren) {
                              return Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  ...previousChildren,
                                  ?currentChild,
                                ],
                              );
                            },
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            child: Text(
                              statusText,
                              key: ValueKey<String>(statusText),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                color: Colors.white70,
                                fontSize: scale.font(14.5, min: 12, max: 19),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildEnergizedEmblem(UiScale scale, double progress) {
    final double size = scale.size(118, min: 88, max: 154);

    return CircuitEEmblem(
      size: size,
      progress: progress,
      pulseGlow: true,
    );
  }

  Widget _buildVolumeBadge(UiScale scale, double progress) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: scale.spacing(14, min: 10, max: 20),
        vertical: scale.spacing(4, min: 3, max: 6),
      ),
      decoration: BoxDecoration(
        color: const Color(
          0xFF04281E,
        ).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(scale.size(20)),
        border: Border.all(
          color: const Color(
            0xFF10B981,
          ).withValues(alpha: 0.45 + (0.35 * progress)),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF10B981,
            ).withValues(alpha: 0.20 * progress),
            blurRadius: scale.size(8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: scale.size(6, min: 5, max: 8),
            height: scale.size(6, min: 5, max: 8),
            decoration: BoxDecoration(
              color: Color.lerp(
                const Color(0xFF059669),
                const Color(0xFF10B981),
                progress,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(
                    0xFF10B981,
                  ).withValues(alpha: 0.6 * progress),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          SizedBox(width: scale.spacing(6, min: 4, max: 8)),
          Text(
            'JOGO 1 • VOLUME 1',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF6EE7B7),
              fontSize: scale.font(12.5, min: 10, max: 16),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPowerBar(UiScale scale, double progress) {
    return Container(
      height: scale.size(14, min: 10, max: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF03241B),
        borderRadius: BorderRadius.circular(scale.size(10)),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: scale.size(8),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(2.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double fillWidth = constraints.maxWidth * progress;
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: fillWidth,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF059669),
                    Color(0xFF10B981),
                    Color(0xFF00E5FF),
                  ],
                ),
                borderRadius: BorderRadius.circular(scale.size(8)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      0xFF10B981,
                    ).withValues(alpha: 0.45 + (0.40 * progress)),
                    blurRadius: scale.size(10),
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// CustomPainter que desenha uma teia estilizada de circuitos integrados neon
/// com pulso de corrente elétrica convergindo ao centro.
class _CircuitGridPainter extends CustomPainter {
  final double phase;
  final double chargeProgress;

  _CircuitGridPainter({required this.phase, required this.chargeProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = const Color(0xFF084334).withValues(alpha: 0.45)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final paintGlow = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.25 * chargeProgress)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final paintNode = Paint()
      ..color = const Color(
        0xFF10B981,
      ).withValues(alpha: 0.4 + 0.4 * chargeProgress)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);

    // Linhas esquemáticas dos 4 cantos em direção ao centro
    _drawCircuitBranch(
      canvas,
      paintLine,
      paintGlow,
      paintNode,
      Offset(0, size.height * 0.2),
      Offset(center.dx - 180, center.dy - 60),
    );

    _drawCircuitBranch(
      canvas,
      paintLine,
      paintGlow,
      paintNode,
      Offset(0, size.height * 0.8),
      Offset(center.dx - 180, center.dy + 60),
    );

    _drawCircuitBranch(
      canvas,
      paintLine,
      paintGlow,
      paintNode,
      Offset(size.width, size.height * 0.2),
      Offset(center.dx + 180, center.dy - 60),
    );

    _drawCircuitBranch(
      canvas,
      paintLine,
      paintGlow,
      paintNode,
      Offset(size.width, size.height * 0.8),
      Offset(center.dx + 180, center.dy + 60),
    );

    // Pulso de energia percorrendo a tela
    final pulseAlpha = (math.sin(phase) + 1.0) / 2.0;
    final pulsePaint = Paint()
      ..color = const Color(
        0xFF00E5FF,
      ).withValues(alpha: 0.12 * pulseAlpha * chargeProgress)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, 120 + (25 * pulseAlpha), pulsePaint);
  }

  void _drawCircuitBranch(
    Canvas canvas,
    Paint linePaint,
    Paint glowPaint,
    Paint nodePaint,
    Offset start,
    Offset end,
  ) {
    final path = Path();
    final midX = (start.dx + end.dx) / 2;

    path.moveTo(start.dx, start.dy);
    path.lineTo(midX, start.dy);
    path.lineTo(midX, end.dy);
    path.lineTo(end.dx, end.dy);

    canvas.drawPath(path, linePaint);
    canvas.drawPath(path, glowPaint);

    canvas.drawCircle(start, 3.0, nodePaint);
    canvas.drawCircle(Offset(midX, start.dy), 3.0, nodePaint);
    canvas.drawCircle(Offset(midX, end.dy), 3.0, nodePaint);
    canvas.drawCircle(end, 4.0, nodePaint);
  }

  @override
  bool shouldRepaint(covariant _CircuitGridPainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.chargeProgress != chargeProgress;
  }
}
