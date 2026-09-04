import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/first_step_component.dart';
import '../../models/phase1_component_data.dart';
import '../../widgets/component_physical_painter.dart';
import '../../widgets/eletrolab_header_brand.dart';
import '../../widgets/prof_volts_feedback_dialog.dart';
import '../../widgets/prof_volts_full_body.dart';

/// Fase 1 do Primeiro Estande: Conheça os componentes.
///
/// Reproduz fielmente a interface pedagógica e estética da imagem de referência (estande1-fase1.png).
class FirstBenchPhase1 extends StatefulWidget {
  final VoidCallback? onPhaseComplete;
  final bool showHeader;

  const FirstBenchPhase1({
    super.key,
    this.onPhaseComplete,
    this.showHeader = false,
  });

  @override
  State<FirstBenchPhase1> createState() => _FirstBenchPhase1State();
}

class _FirstBenchPhase1State extends State<FirstBenchPhase1> {
  final List<Phase1ComponentData> _components = Phase1ComponentData.defaultList;
  int? _selectedIndex;
  final Set<String> _exploredIds = {};

  // Estado do Quiz
  bool _isQuizMode = false;
  int _quizCurrentIndex = 0;
  late List<Phase1ComponentData> _quizQuestions;
  late List<String> _currentOptions;

  @override
  void initState() {
    super.initState();
    // Selecionar por padrão o primeiro componente (Bateria) para dar feedback imediato
    _selectedIndex = 0;
    _exploredIds.add(_components[0].id);
    _initQuizQuestions();
  }

  void _initQuizQuestions() {
    _quizQuestions = List.from(_components)..shuffle();
    _quizCurrentIndex = 0;
    _prepareCurrentOptions();
  }

  void _prepareCurrentOptions() {
    if (_quizCurrentIndex < _quizQuestions.length) {
      final q = _quizQuestions[_quizCurrentIndex];
      final opts = [q.correctAnswer, ...q.wrongAnswers];
      opts.shuffle();
      _currentOptions = opts;
    }
  }

  bool _isLearnMoreExpanded = false;
  bool _isCheckAnswerRevealed = false;

  void _selectComponent(int index) {
    setState(() {
      _selectedIndex = index;
      _exploredIds.add(_components[index].id);
      _isLearnMoreExpanded = false;
      _isCheckAnswerRevealed = false;
    });
  }

  bool get _isAllExplored => _exploredIds.length >= _components.length;

  void _startQuiz() {
    setState(() {
      _initQuizQuestions();
      _isQuizMode = true;
    });
  }

  void _answerQuiz(String selectedAnswer) {
    final currentQ = _quizQuestions[_quizCurrentIndex];
    final isCorrect = selectedAnswer == currentQ.correctAnswer;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProfVoltsFeedbackDialog(
        isCorrect: isCorrect,
        message: isCorrect
            ? 'Resposta correta! ${currentQ.quizExplanation}'
            : 'Incorreto. Tente novamente! ${currentQ.quizExplanation}',
        onAction: () {
          Navigator.of(context).pop();
          if (isCorrect) {
            setState(() {
              if (_quizCurrentIndex < _quizQuestions.length - 1) {
                _quizCurrentIndex++;
                _prepareCurrentOptions();
              } else {
                _showQuizCompletionDialog();
              }
            });
          }
        },
      ),
    );
  }

  void _showQuizCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 440),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF10B981), width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x6610B981),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ProfVoltsFullBody(
                emotion: ProfVoltsEmotion.happy,
                size: 140,
              ),
              const SizedBox(height: 16),
              Text(
                'FASE 1 CONCLUÍDA!',
                style: TextStyle(
                  fontFamily: GoogleFonts.rajdhani().fontFamily,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF10B981),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Parabéns! Você explorou os cinco componentes e dominou suas funções básicas.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: GoogleFonts.outfit().fontFamily,
                  fontSize: 15,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _isQuizMode = false;
                    });
                    widget.onPhaseComplete?.call();
                  },
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(
                    'AVANÇAR PARA A FASE 2',
                    style: TextStyle(
                      fontFamily: GoogleFonts.rajdhani().fontFamily,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpModal() {
    showDialog(
      context: context,
      builder: (context) {
        return KeyboardListener(
          focusNode: FocusNode()..requestFocus(),
          onKeyEvent: (event) {
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              Navigator.of(context).pop();
            }
          },
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF04382B),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.help_outline_rounded,
                          color: Color(0xFF10B981),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Como funciona esta fase?',
                          style: TextStyle(
                            fontFamily: GoogleFonts.rajdhani().fontFamily,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white70),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildHelpBullet('1. Selecione cada componente da bancada para examiná-lo.'),
                  _buildHelpBullet('2. Leia sua função, seus terminais e os cuidados necessários.'),
                  _buildHelpBullet('3. Explore os cinco componentes para liberar o botão do quiz.'),
                  _buildHelpBullet('4. Responda corretamente às perguntas para concluir a fase.'),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF10B981),
                        side: const BorderSide(color: Color(0xFF10B981)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('ENTENDI'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHelpBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(color: Color(0xFF10B981), fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: GoogleFonts.outfit().fontFamily,
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071410),
      body: SafeArea(
        child: Column(
          children: [
            // Cabeçalho opcional (somente se showHeader = true)
            if (widget.showHeader) _buildHeader(),

            // Conteúdo Principal (Exploração vs Quiz)
            Expanded(
              child: _isQuizMode ? _buildQuizView() : _buildExplorationView(),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // CABEÇALHO COMPACTO
  // ==========================================
  Widget _buildHeader() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF03241B),
        border: Border(
          bottom: BorderSide(color: Color(0xFF0F3D30), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Botão Voltar
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            tooltip: 'Voltar ao Mapa',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 4),

          // Marca EletroLab
          const EletroLabHeaderBrand(compact: true),

          const Spacer(),

          // Indicadores de Fase (Fase 1 Ativa, 2, 3 e 4 Bloqueadas)
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              children: [
                _buildPhasePill(1, 'Fase 1', isActive: true),
                const SizedBox(width: 6),
                _buildPhasePill(2, 'Fase 2', isLocked: true),
                const SizedBox(width: 6),
                _buildPhasePill(3, 'Fase 3', isLocked: true),
                const SizedBox(width: 6),
                _buildPhasePill(4, 'Fase 4', isLocked: true),
              ],
            ),
          ),

          const Spacer(),

          // Botão Dúvidas
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF04382B),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
              ),
              child: const Icon(
                Icons.help_outline_rounded,
                color: Color(0xFF10B981),
                size: 20,
              ),
            ),
            tooltip: 'Como funciona esta fase?',
            onPressed: _showHelpModal,
          ),
        ],
      ),
    );
  }

  Widget _buildPhasePill(int phaseNum, String label, {bool isActive = false, bool isLocked = false}) {
    final color = isActive ? const Color(0xFF10B981) : Colors.white38;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF04382B)
            : (isLocked ? const Color(0xFF0C1814) : const Color(0xFF1A2E26)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? const Color(0xFF10B981) : Colors.white12,
          width: isActive ? 1.5 : 1.0,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLocked)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(Icons.lock_rounded, size: 12, color: Colors.white38),
            )
          else
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          Text(
            label,
            style: TextStyle(
              fontFamily: GoogleFonts.rajdhani().fontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: isActive ? Colors.white : Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // VISTA DE EXPLORAÇÃO (STACK + SCENARIO ASSET)
  // ==========================================
  Widget _buildExplorationView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 850;

        if (isDesktop) {
          return _buildDesktopStackView(constraints);
        } else {
          return _buildMobileResponsiveView(constraints);
        }
      },
    );
  }

  // Composição Visual Principal Desktop/Tablet (Stack sobre o cenário)
  Widget _buildDesktopStackView(BoxConstraints constraints) {
    return Center(
      child: FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: 1600,
          height: 900,
          child: Stack(
            children: [
              // 1. Cenário background_fase_01_bancada.png
              Positioned.fill(
                child: Image.asset(
                  'assets/images/backgrounds/background_fase_01_bancada.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/backgrounds/background_fase_01_bancada.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // 2. Título e instrução (sobre a região superior esquerda)
              Positioned(
                top: 32,
                left: 44,
                width: 680,
                child: _buildTitleSectionStack(),
              ),

              // 3, 4, 5. Cinco componentes transparentes, placas e halos sobre a bancada
              ...List.generate(_components.length, (index) {
                return _buildBenchComponentItemPositioned(index);
              }),

              // 6 & 7. Painel informativo, progresso e botão do quiz (lado direito)
              Positioned(
                top: 28,
                right: 36,
                width: 370,
                bottom: 28,
                child: Column(
                  children: [
                    Expanded(
                      child: _buildInfoPanel(),
                    ),
                    const SizedBox(height: 12),
                    _buildFooterProgressQuiz(),
                  ],
                ),
              ),

              // 11. Botão de dúvidas (no topo direito da área principal)
              if (!widget.showHeader)
                Positioned(
                  top: 32,
                  right: 424,
                  child: _buildHelpButton(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Título e instrução com gradiente suave localizado para legibilidade perfeita
  Widget _buildTitleSectionStack() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.black.withValues(alpha: 0.65),
            Colors.black.withValues(alpha: 0.3),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.menu_book_rounded,
                color: Color(0xFF34D399),
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                'Fase 1 — Conheça os componentes',
                style: TextStyle(
                  fontFamily: GoogleFonts.rajdhani().fontFamily,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                  shadows: const [
                    Shadow(color: Colors.black87, blurRadius: 6, offset: Offset(0, 2)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Explore os cinco componentes usados para acender a primeira luz da maquete.',
            style: TextStyle(
              fontFamily: GoogleFonts.outfit().fontFamily,
              fontSize: 15,
              color: Colors.white.withValues(alpha: 0.9),
              shadows: const [
                Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(0, 1)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Botão de dúvidas estilizado
  Widget _buildHelpButton() {
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF04382B),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.7), width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 8,
            ),
          ],
        ),
        child: const Icon(
          Icons.help_outline_rounded,
          color: Color(0xFF10B981),
          size: 22,
        ),
      ),
      tooltip: 'Como funciona esta fase?',
      onPressed: _showHelpModal,
    );
  }

  // Componente individual posicionado exatamente sobre a bancada no Stack Desktop
  Widget _buildBenchComponentItemPositioned(int index) {
    final item = _components[index];
    final isSelected = _selectedIndex == index;
    final isExplored = _exploredIds.contains(item.id);

    // Posições relativas horizontais exatas especificadas (12%, 27%, 40%, 52%, 65% de 1600px)
    final centerXList = [192.0, 432.0, 640.0, 832.0, 1040.0];
    final widthList = [135.0, 155.0, 145.0, 95.0, 170.0];
    final heightList = [145.0, 130.0, 95.0, 140.0, 120.0];
    final topList = [385.0, 400.0, 435.0, 390.0, 410.0];

    final centerX = centerXList[index];
    final width = widthList[index];
    final height = heightList[index];
    final top = topList[index];
    final left = centerX - (width / 2);

    // Largura das placas
    final plaqueWidthList = [135.0, 140.0, 145.0, 135.0, 140.0];
    final plaqueWidth = plaqueWidthList[index];
    final plaqueLeft = centerX - (plaqueWidth / 2);

    Widget imageWidget = Image.asset(
      item.assetPath,
      width: width,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => CustomPaint(
        painter: ComponentPhysicalPainter(
          type: item.type,
          isActive: true,
          isDarkMode: true,
        ),
        child: SizedBox(width: width, height: height),
      ),
    );

    // 8. Halo suave ao redor do objeto PNG quando selecionado
    if (isSelected) {
      imageWidget = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.65),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: imageWidget,
      );
    } else {
      // Sombra natural de contato suave abaixo do objeto não selecionado
      imageWidget = Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: imageWidget,
      );
    }

    return Stack(
      children: [
        // Imagem do Componente PNG (Layer 3 & 5)
        Positioned(
          left: left,
          top: top,
          width: width,
          height: height,
          child: GestureDetector(
            onTap: () => _selectComponent(index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedScale(
              scale: isSelected ? 1.04 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: imageWidget,
            ),
          ),
        ),

        // 7. Placa com o nome diretamente abaixo do componente (Layer 4)
        Positioned(
          left: plaqueLeft,
          top: 540,
          width: plaqueWidth,
          height: 38,
          child: GestureDetector(
            onTap: () => _selectComponent(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0F6B45) : const Color(0xFF133824),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF10B981)
                      : (isExplored
                          ? const Color(0xFF10B981).withValues(alpha: 0.6)
                          : const Color(0xFF2E6B49)),
                  width: isSelected ? 1.5 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? const Color(0xFF10B981).withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.4),
                    blurRadius: isSelected ? 8 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isExplored && !isSelected)
                    const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.check_circle_rounded,
                        size: 12,
                        color: Color(0xFF34D399),
                      ),
                    ),
                  Flexible(
                    child: Text(
                      item.plaqueName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: GoogleFonts.rajdhani().fontFamily,
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Vista responsiva para telas menores (< 850px / Mobile)
  Widget _buildMobileResponsiveView(BoxConstraints constraints) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleSectionStack(),
          const SizedBox(height: 12),
          // Cenário da Bancada em formato compacto responsivo
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 280,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/backgrounds/background_fase_01_bancada.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/backgrounds/background_fase_01_bancada.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      itemCount: _components.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) => _buildMobileBenchItem(index),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoPanel(),
          const SizedBox(height: 16),
          _buildFooterProgressQuiz(),
        ],
      ),
    );
  }

  Widget _buildMobileBenchItem(int index) {
    final item = _components[index];
    final isSelected = _selectedIndex == index;

    Widget imgWidget = Image.asset(
      item.assetPath,
      height: 110,
      width: 110,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => CustomPaint(
        painter: ComponentPhysicalPainter(
          type: item.type,
          isActive: true,
          isDarkMode: true,
        ),
        child: const SizedBox(width: 90, height: 110),
      ),
    );

    if (isSelected) {
      imgWidget = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.65),
              blurRadius: 14,
              spreadRadius: 2,
            ),
          ],
        ),
        child: imgWidget,
      );
    }

    return GestureDetector(
      onTap: () => _selectComponent(index),
      child: SizedBox(
        width: 125,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.04 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: imgWidget,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0F6B45) : const Color(0xFF133824),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? const Color(0xFF10B981) : const Color(0xFF2E6B49),
                ),
              ),
              child: Text(
                item.plaqueName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: GoogleFonts.rajdhani().fontFamily,
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // PAINEL INFORMATIVO LATERAL (CREME / CLASSIC)
  // ==========================================
  Widget _buildInfoPanel() {
    if (_selectedIndex == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F4EC),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text('Selecione um componente para explorar.'),
        ),
      );
    }

    final item = _components[_selectedIndex!];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F4EC), // Fundo creme elegante igual à referência
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título + Ícone
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: TextStyle(
                      fontFamily: GoogleFonts.rajdhani().fontFamily,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF03241B),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF04382B),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, color: const Color(0xFF10B981), size: 22),
                ),
              ],
            ),
            const Divider(color: Color(0xFFCBD5E1), height: 18),

            // Resumo didático curto
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                item.shortDescription,
                style: TextStyle(
                  fontFamily: GoogleFonts.outfit().fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1E293B),
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Função Principal
            _buildInfoSection(
              icon: Icons.bolt_rounded,
              title: 'Função Principal',
              description: item.function,
            ),
            const SizedBox(height: 12),

            // Terminais
            _buildInfoSection(
              icon: Icons.alt_route_rounded,
              title: 'Terminais',
              description: item.terminals,
            ),

            // Polaridade (quando aplicável)
            if (item.polarity != null) ...[
              const SizedBox(height: 12),
              _buildInfoSection(
                icon: Icons.compare_arrows_rounded,
                title: 'Polaridade',
                description: item.polarity!,
              ),
            ],
            const SizedBox(height: 12),

            // Como Reconhecer
            _buildInfoSection(
              icon: Icons.visibility_rounded,
              title: 'Como Reconhecer',
              description: item.identification,
            ),
            const SizedBox(height: 12),

            // Comportamento no Circuito
            _buildInfoSection(
              icon: Icons.settings_input_component_rounded,
              title: 'Comportamento no Circuito',
              description: item.behavior,
            ),
            const SizedBox(height: 14),

            // Cuidado de Segurança (Destaque visual discreto de segurança)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDBA74), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFEA580C),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Cuidado de Segurança',
                        style: TextStyle(
                          fontFamily: GoogleFonts.rajdhani().fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFC2410C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.safety,
                    style: TextStyle(
                      fontFamily: GoogleFonts.outfit().fontFamily,
                      fontSize: 12.5,
                      color: const Color(0xFF7C2D12),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Seção Expansível "Saiba mais"
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLearnMoreExpanded = !_isLearnMoreExpanded;
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF04382B),
                  side: const BorderSide(color: Color(0xFF04382B), width: 1.2),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  minimumSize: const Size(44, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Icon(
                  _isLearnMoreExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  size: 20,
                ),
                label: Text(
                  _isLearnMoreExpanded ? 'Ocultar detalhes' : 'Saiba mais',
                  style: TextStyle(
                    fontFamily: GoogleFonts.rajdhani().fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            if (_isLearnMoreExpanded) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.learnMore,
                      style: TextStyle(
                        fontFamily: GoogleFonts.outfit().fontFamily,
                        fontSize: 12.5,
                        color: const Color(0xFF334155),
                        height: 1.35,
                      ),
                    ),
                    if (item.type == ComponentType.resistor) ...[
                      const SizedBox(height: 10),
                      _buildResistorColorCodeTable(),
                    ],
                    if (item.type == ComponentType.led) ...[
                      const SizedBox(height: 10),
                      _buildLedDiagram(),
                    ],
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),

            // Pergunta curta de checagem
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.quiz_rounded,
                        color: Color(0xFF04382B),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Checagem rápida',
                        style: TextStyle(
                          fontFamily: GoogleFonts.rajdhani().fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF03241B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.checkQuestion,
                    style: TextStyle(
                      fontFamily: GoogleFonts.outfit().fontFamily,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _isCheckAnswerRevealed = !_isCheckAnswerRevealed;
                      });
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF04382B),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: const Size(44, 44),
                    ),
                    icon: Icon(
                      _isCheckAnswerRevealed ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      size: 16,
                    ),
                    label: Text(
                      _isCheckAnswerRevealed ? 'Ocultar resposta' : 'Ver resposta',
                      style: TextStyle(
                        fontFamily: GoogleFonts.rajdhani().fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_isCheckAnswerRevealed) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF059669).withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF059669),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.checkAnswer,
                              style: TextStyle(
                                fontFamily: GoogleFonts.outfit().fontFamily,
                                fontSize: 12,
                                color: const Color(0xFF065F46),
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Contador de Exploração no rodapé do painel
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Explorados: ${_exploredIds.length} de ${_components.length}',
                style: TextStyle(
                  fontFamily: GoogleFonts.rajdhani().fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF04382B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({required IconData icon, required String title, required String description}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: Color(0xFF04382B),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF10B981), size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: GoogleFonts.rajdhani().fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF03241B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontFamily: GoogleFonts.outfit().fontFamily,
                  fontSize: 12.5,
                  color: const Color(0xFF334155),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLedDiagram() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                '+',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              Text(
                'ÂNODO',
                style: TextStyle(
                  fontFamily: GoogleFonts.rajdhani().fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF03241B),
                ),
              ),
              const Text(
                '(perna longa)',
                style: TextStyle(fontSize: 9, color: Colors.black54),
              ),
            ],
          ),
          Image.asset(
            'assets/components/led_off.png',
            height: 48,
            errorBuilder: (_, _, _) => const Icon(Icons.lightbulb, size: 36, color: Colors.red),
          ),
          Column(
            children: [
              const Text(
                '−',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                'CÁTODO',
                style: TextStyle(
                  fontFamily: GoogleFonts.rajdhani().fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF03241B),
                ),
              ),
              const Text(
                '(perna curta)',
                style: TextStyle(fontSize: 9, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResistorColorCodeTable() {
    const tableData = [
      {'color': 'Preto', 'dot': Colors.black, 'val': '0', 'mult': '×1', 'tol': '—'},
      {'color': 'Marrom', 'dot': Color(0xFF795548), 'val': '1', 'mult': '×10', 'tol': '±1%'},
      {'color': 'Vermelho', 'dot': Colors.red, 'val': '2', 'mult': '×100', 'tol': '±2%'},
      {'color': 'Laranja', 'dot': Colors.orange, 'val': '3', 'mult': '×1.000', 'tol': '—'},
      {'color': 'Amarelo', 'dot': Colors.yellow, 'val': '4', 'mult': '×10.000', 'tol': '—'},
      {'color': 'Verde', 'dot': Colors.green, 'val': '5', 'mult': '×100.000', 'tol': '±0,5%'},
      {'color': 'Azul', 'dot': Colors.blue, 'val': '6', 'mult': '×1.000.000', 'tol': '±0,25%'},
      {'color': 'Violeta', 'dot': Colors.purple, 'val': '7', 'mult': '×10.000.000', 'tol': '±0,1%'},
      {'color': 'Cinza', 'dot': Colors.grey, 'val': '8', 'mult': '×100.000.000', 'tol': '±0,05%'},
      {'color': 'Branco', 'dot': Colors.white, 'val': '9', 'mult': '×1.000.000.000', 'tol': '—'},
      {'color': 'Dourado', 'dot': Color(0xFFFFD700), 'val': '—', 'mult': '×0,1', 'tol': '±5%'},
      {'color': 'Prateado', 'dot': Color(0xFFC0C0C0), 'val': '—', 'mult': '×0,01', 'tol': '±10%'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tabela de Código de Cores (4 Faixas):',
          style: TextStyle(
            fontFamily: GoogleFonts.rajdhani().fontFamily,
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF03241B),
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            color: Colors.white,
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(2.2),
                1: FlexColumnWidth(1.0),
                2: FlexColumnWidth(1.8),
                3: FlexColumnWidth(1.2),
              },
              border: TableBorder.all(color: const Color(0xFFCBD5E1), width: 0.5),
              children: [
                TableRow(
                  decoration: const BoxDecoration(color: Color(0xFFE2E8F0)),
                  children: [
                    _buildTableCell('Cor', isHeader: true),
                    _buildTableCell('Alg.', isHeader: true),
                    _buildTableCell('Mult.', isHeader: true),
                    _buildTableCell('Tol.', isHeader: true),
                  ],
                ),
                ...tableData.map((row) {
                  final colorName = row['color'] as String;
                  final dotColor = row['dot'] as Color;
                  final val = row['val'] as String;
                  final mult = row['mult'] as String;
                  final tol = row['tol'] as String;
                  final is680Band = colorName == 'Azul' ||
                      colorName == 'Cinza' ||
                      colorName == 'Marrom' ||
                      colorName == 'Dourado';

                  return TableRow(
                    decoration: BoxDecoration(
                      color: is680Band ? const Color(0xFFECFDF5) : Colors.white,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: dotColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black26),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                colorName,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: is680Band ? FontWeight.bold : FontWeight.normal,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildTableCell(val, isBold: is680Band),
                      _buildTableCell(mult, isBold: is680Band),
                      _buildTableCell(tol, isBold: is680Band),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: isHeader ? GoogleFonts.rajdhani().fontFamily : null,
          fontSize: isHeader ? 11 : 10.5,
          fontWeight: (isHeader || isBold) ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? const Color(0xFF03241B) : Colors.black87,
        ),
      ),
    );
  }

  // ==========================================
  // RODAPÉ: PROGRESSO + BOTÃO QUIZ
  // ==========================================
  Widget _buildFooterProgressQuiz() {
    return Column(
      children: [
        // 5 Círculos Conectados de Progresso
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_components.length, (i) {
            final isDone = _exploredIds.contains(_components[i].id);
            final isCurrent = _selectedIndex == i;

            return Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isDone ? const Color(0xFF10B981) : Colors.black45,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCurrent ? const Color(0xFF00FF9D) : (isDone ? const Color(0xFF10B981) : Colors.white38),
                      width: isCurrent ? 2.0 : 1.0,
                    ),
                  ),
                  child: isDone
                      ? const Icon(Icons.check_rounded, size: 14, color: Colors.black)
                      : null,
                ),
                if (i < _components.length - 1)
                  Container(
                    width: 16,
                    height: 2,
                    color: isDone ? const Color(0xFF10B981) : Colors.white24,
                  ),
              ],
            );
          }),
        ),

        const SizedBox(height: 12),

        // Botão de Iniciar Quiz (Bloqueado vs Liberado)
        SizedBox(
          width: double.infinity,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isAllExplored
                ? FilledButton.icon(
                    key: const ValueKey('quiz_unlocked'),
                    onPressed: _startQuiz,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(
                      'Iniciar quiz',
                      style: TextStyle(
                        fontFamily: GoogleFonts.rajdhani().fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  )
                : OutlinedButton.icon(
                    key: const ValueKey('quiz_locked'),
                    onPressed: null, // Desabilitado
                    icon: const Icon(Icons.lock_rounded, size: 16),
                    label: Text(
                      'Explorar todos para liberar o quiz',
                      style: TextStyle(
                        fontFamily: GoogleFonts.rajdhani().fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white38,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // VISTA DO QUIZ
  // ==========================================
  Widget _buildQuizView() {
    final currentQ = _quizQuestions[_quizCurrentIndex];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF10B981), width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 16,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progresso do Quiz
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pergunta ${_quizCurrentIndex + 1} de ${_quizQuestions.length}',
                      style: TextStyle(
                        fontFamily: GoogleFonts.rajdhani().fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white54),
                      tooltip: 'Sair do Quiz',
                      onPressed: () {
                        setState(() {
                          _isQuizMode = false;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Pergunta
                Text(
                  currentQ.quizQuestion,
                  style: TextStyle(
                    fontFamily: GoogleFonts.rajdhani().fontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                // 3 Alternativas
                ..._currentOptions.map((option) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => _answerQuiz(option),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.radio_button_unchecked_rounded,
                              color: Color(0xFF10B981),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                option,
                                style: TextStyle(
                                  fontFamily: GoogleFonts.outfit().fontFamily,
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
