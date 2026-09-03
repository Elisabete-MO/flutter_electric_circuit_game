import 'dart:math';
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

  void _selectComponent(int index) {
    setState(() {
      _selectedIndex = index;
      _exploredIds.add(_components[index].id);
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
  // VISTA DE EXPLORAÇÃO (BANCADA + PAINEL)
  // ==========================================
  Widget _buildExplorationView() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF091C16),
            Color(0xFF16120D),
            Color(0xFF0B130E),
          ],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 850;

          if (isDesktop) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Esquerda / Centro: Título + Bancada 2.5D
                Expanded(
                  flex: 65,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitleSection(),
                        const SizedBox(height: 12),
                        Expanded(child: _buildWorkbench2D(isMobile: false)),
                      ],
                    ),
                  ),
                ),

                // Direita: Painel Informativo + Progresso e Quiz
                Container(
                  width: min(380.0, constraints.maxWidth * 0.35),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Expanded(child: _buildInfoPanel()),
                      const SizedBox(height: 12),
                      _buildFooterProgressQuiz(),
                    ],
                  ),
                ),
              ],
            );
          } else {
            // Layout Mobile / Tablet Vertical
            return SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleSection(),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 240,
                    child: _buildWorkbench2D(isMobile: true),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoPanel(),
                  const SizedBox(height: 16),
                  _buildFooterProgressQuiz(),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  // Título
  Widget _buildTitleSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.menu_book_rounded,
                    color: Color(0xFF34D399),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Fase 1 — Conheça os componentes',
                    style: TextStyle(
                      fontFamily: GoogleFonts.rajdhani().fontFamily,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Explore os cinco componentes usados para acender a primeira luz da maquete.',
                style: TextStyle(
                  fontFamily: GoogleFonts.outfit().fontFamily,
                  fontSize: 13.5,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        if (!widget.showHeader)
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
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
    );
  }

  // Bancada de Madeira 2.5D
  Widget _buildWorkbench2D({required bool isMobile}) {
    final benchWidget = Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFC4873A),
            Color(0xFF915925),
            Color(0xFF6B3D16),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFDCA862).withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xA0000000),
            blurRadius: 20,
            spreadRadius: 2,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: isMobile
          ? ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _components.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) => _buildBenchComponentItem(index, isMobile: true),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_components.length, (index) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildBenchComponentItem(index, isMobile: false),
                  ),
                );
              }),
            ),
    );

    return benchWidget;
  }

  // Item da Bancada (Imagem 2.5D + Halo quando selecionado + Plaquinha)
  Widget _buildBenchComponentItem(int index, {required bool isMobile}) {
    final item = _components[index];
    final isSelected = _selectedIndex == index;
    final isExplored = _exploredIds.contains(item.id);

    return InkWell(
      onTap: () => _selectComponent(index),
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: isMobile ? 125 : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagem Físico 2.5D com Brilho quando selecionado
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF00FF9D).withValues(alpha: 0.6),
                            blurRadius: 20,
                            spreadRadius: 3,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Image.asset(
                    item.assetPath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => CustomPaint(
                      painter: ComponentPhysicalPainter(
                        type: item.type,
                        isActive: true,
                        isDarkMode: true,
                      ),
                      child: const SizedBox(width: 80, height: 80),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Plaquinha integrada de madeira/metal escuro
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF10B981)
                    : (isExplored ? const Color(0xFF0F3D30) : const Color(0xFF1A2721)),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF00FF9D)
                      : (isExplored ? const Color(0xFF10B981) : const Color(0xFF334155)),
                  width: isSelected ? 1.8 : 1.0,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isExplored && !isSelected)
                    const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF10B981)),
                    ),
                  Flexible(
                    child: Text(
                      item.plaqueName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: GoogleFonts.rajdhani().fontFamily,
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.black : Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
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
                Text(
                  item.name,
                  style: TextStyle(
                    fontFamily: GoogleFonts.rajdhani().fontFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF03241B),
                  ),
                ),
                Icon(item.icon, color: const Color(0xFF04382B), size: 26),
              ],
            ),
            const Divider(color: Color(0xFFCBD5E1), height: 20),

            // Função
            _buildInfoSection(
              icon: Icons.bolt_rounded,
              title: 'Função',
              description: item.functionText,
            ),
            const SizedBox(height: 14),

            // Terminais
            _buildInfoSection(
              icon: Icons.alt_route_rounded,
              title: 'Terminais',
              description: item.terminalsText,
            ),

            // Ilustração Didática para LED vermelho
            if (item.type == ComponentType.led) ...[
              const SizedBox(height: 10),
              Container(
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
              ),
            ],

            const SizedBox(height: 14),

            // Cuidado
            _buildInfoSection(
              icon: Icons.warning_amber_rounded,
              title: 'Cuidado',
              description: item.cautionText,
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
