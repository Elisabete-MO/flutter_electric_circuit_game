import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/phase1_component_data.dart';
import '../../widgets/component_physical_painter.dart';
import '../../widgets/prof_volts_feedback_dialog.dart';
import '../../widgets/prof_volts_full_body.dart';
import '../common_stand/stand_flow_tokens.dart';
import '../../widgets/workbench_components.dart';
import '../../widgets/workbench_sidebar_cards.dart';
import '../../widgets/workbench_table_frame.dart';

/// Fase 1 do Segundo Estande (Acende Aí): Conheça os componentes.
class SecondBenchPhase1 extends StatefulWidget {
  final VoidCallback? onPhaseComplete;

  const SecondBenchPhase1({
    super.key,
    this.onPhaseComplete,
  });

  @override
  State<SecondBenchPhase1> createState() => _SecondBenchPhase1State();
}

class _SecondBenchPhase1State extends State<SecondBenchPhase1> {
  final List<Phase1ComponentData> _components = Phase1ComponentData.defaultList;
  int? _selectedIndex;
  final Set<String> _exploredIds = {};

  // Estado do Quiz
  bool _isQuizMode = false;
  int _quizCurrentIndex = 0;
  late List<Phase1ComponentData> _quizQuestions;
  late List<String> _currentOptions;

  bool _isLearnMoreExpanded = false;
  bool _isCheckAnswerRevealed = false;

  @override
  void initState() {
    super.initState();
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
            border: Border.all(color: StandFlowTokens.primaryGreen, width: 2),
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
                  color: StandFlowTokens.primaryGreen,
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
                    backgroundColor: StandFlowTokens.primaryGreen,
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
                border: Border.all(color: StandFlowTokens.primaryGreen, width: 1.5),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 16),
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
                          color: StandFlowTokens.primaryGreen,
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
                        foregroundColor: StandFlowTokens.primaryGreen,
                        side: const BorderSide(color: StandFlowTokens.primaryGreen),
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
            style: TextStyle(
              color: StandFlowTokens.primaryGreen,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
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
    if (_isQuizMode) {
      return _buildQuizScaffold();
    }

    return Row(
      children: [
        // Área Principal da Bancada
        Expanded(
          flex: 7,
          child: WorkbenchTableFrame(
            usePhysicalStyle: true,
            onStyleChanged: (_) {},
            showModeSelector: false,
            leftHeaderWidget: _buildExplorationStatusBadge(),
            rightHeaderWidget: _buildExplorationProgressBadge(),
            child: _buildBenchWorkspace(),
          ),
        ),
        const SizedBox(width: 16),
        // Painel Lateral (Objetivo + Detalhes Didáticos + Ação)
        Expanded(
          flex: 3,
          child: WorkbenchSidePanel(
            teamTitle: 'Painel da Equipe Iluminação',
            showTeamHeader: false,
            buttonColor: _isAllExplored
                ? const Color(0xFF10B981)
                : const Color(0xFF0284C7),
            buttonLabel: _isAllExplored
                ? 'INICIAR QUIZ DE FIXAÇÃO'
                : 'EXPLORE OS 5 COMPONENTES (${_exploredIds.length}/5)',
            toolboxItems: [
              const WorkbenchMissionObjectiveCard(
                missionNumber: 1,
                title: 'Conheça os componentes',
                description: 'Explore os cinco componentes da bancada para entender suas funções didáticas e liberar o quiz.',
                voltsTip: 'Toque em cada peça na bancada para examinar seus terminais e funções didáticas.',
                accentColor: Color(0xFF0284C7),
              ),
              const SizedBox(height: 12),
              _buildSidePanelContent(),
            ],
            onEnergizePressed: () {
              if (_isAllExplored) {
                _startQuiz();
              } else {
                _showHelpModal();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExplorationStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isAllExplored ? Icons.check_circle_rounded : Icons.search_rounded,
            color: _isAllExplored ? const Color(0xFF10B981) : const Color(0xFF0284C7),
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            _isAllExplored ? 'EXPLORAÇÃO COMPLETA' : 'MODO EXPLORAÇÃO',
            style: GoogleFonts.rajdhani(
              color: _isAllExplored ? const Color(0xFF10B981) : const Color(0xFF0284C7),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplorationProgressBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.fact_check_rounded, color: Color(0xFF00FF9D), size: 16),
          const SizedBox(width: 6),
          Text(
            '${_exploredIds.length} de ${_components.length} explorados',
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // AMBIENTE DA BANCADA DE MADEIRA (73-75% de largura no Desktop)
  // ==========================================
  Widget _buildBenchWorkspace() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        // Proporções relativas horizontais dos 5 componentes sobre a bancada
        final relativeXs = [0.12, 0.28, 0.46, 0.65, 0.82];
        final relativeYs = [0.42, 0.44, 0.46, 0.42, 0.44];
        final widths = [130.0, 140.0, 135.0, 90.0, 140.0];
        final heights = [135.0, 120.0, 90.0, 130.0, 110.0];

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Superfície 2.5D da bancada de madeira
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black.withValues(alpha: 0.1),
                ),
              ),
            ),

            // Os 5 Componentes Interativos com Placa de Identificação
            ...List.generate(_components.length, (index) {
              final comp = _components[index];
              final isSelected = _selectedIndex == index;
              final isExplored = _exploredIds.contains(comp.id);

              final posX = (w * relativeXs[index]) - (widths[index] / 2);
              final posY = (h * relativeYs[index]) - (heights[index] / 2);

              Widget compImage = CustomPaint(
                painter: ComponentPhysicalPainter(
                  type: comp.type,
                  isActive: true,
                  isDarkMode: false,
                ),
                child: SizedBox(width: widths[index], height: heights[index]),
              );

              if (isSelected) {
                compImage = Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: StandFlowTokens.primaryGreen.withValues(alpha: 0.7),
                        blurRadius: 18,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: compImage,
                );
              }

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Imagem do Componente
                  Positioned(
                    left: posX.clamp(10.0, w - widths[index] - 10.0),
                    top: posY.clamp(10.0, h - heights[index] - 50.0),
                    width: widths[index],
                    height: heights[index],
                    child: GestureDetector(
                      onTap: () => _selectComponent(index),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedScale(
                        scale: isSelected ? 1.05 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: compImage,
                      ),
                    ),
                  ),

                  // Placa com Nome abaixo do Componente
                  Positioned(
                    left: (posX - 10).clamp(5.0, w - widths[index] - 5.0),
                    top: posY + heights[index] + 8,
                    width: widths[index] + 20,
                    child: GestureDetector(
                      onTap: () => _selectComponent(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF0F6B45)
                              : const Color(0xFF133824),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? StandFlowTokens.primaryGreen
                                : (isExplored
                                    ? StandFlowTokens.primaryGreen.withValues(alpha: 0.6)
                                    : const Color(0xFF2E6B49)),
                            width: isSelected ? 1.8 : 1.0,
                          ),
                          boxShadow: const [
                            BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2)),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isExplored && !isSelected)
                              const Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Icon(
                                  Icons.check_circle_rounded,
                                  size: 13,
                                  color: StandFlowTokens.accentGreen,
                                ),
                              ),
                            Flexible(
                              child: Text(
                                comp.plaqueName,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: GoogleFonts.rajdhani().fontFamily,
                                  fontSize: 13,
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
                    ),
                  ),
                ],
              );
            }),
          ],
        );
      },
    );
  }

  // ==========================================
  // PAINEL LATERAL PADRONIZADO (Cor Creme)
  // ==========================================
  Widget _buildSidePanelContent() {
    if (_selectedIndex == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Center(
          child: Text(
            'Toque em qualquer componente na bancada para examinar seus detalhes didáticos.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(color: const Color(0xFF64748B), fontSize: 13),
          ),
        ),
      );
    }

    final item = _components[_selectedIndex!];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFECFDF5),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: const Color(0xFF059669), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: GoogleFonts.rajdhani(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      item.shortDescription,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildDetailSection('Função Didática', item.function, Icons.settings_power_rounded),
          _buildDetailSection('Terminais de Conexão', item.terminals, Icons.electrical_services_rounded),
          if (item.polarity != null)
            _buildDetailSection('Polaridade', item.polarity!, Icons.swap_horiz_rounded),
          _buildDetailSection('Cuidados & Segurança', item.safety, Icons.warning_amber_rounded, isCaution: true),
          const SizedBox(height: 12),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: Material(
              color: Colors.transparent,
              child: ExpansionTile(
                initiallyExpanded: _isLearnMoreExpanded,
                onExpansionChanged: (exp) => setState(() => _isLearnMoreExpanded = exp),
                tilePadding: EdgeInsets.zero,
                iconColor: StandFlowTokens.darkGreen,
                title: Text(
                  'Saiba mais sobre o componente',
                  style: TextStyle(
                    fontFamily: GoogleFonts.rajdhani().fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: StandFlowTokens.darkGreen,
                  ),
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Text(
                      item.learnMore,
                      style: TextStyle(
                        fontFamily: GoogleFonts.outfit().fontFamily,
                        fontSize: 13,
                        color: StandFlowTokens.textDark,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4EE),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: StandFlowTokens.primaryGreen.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.help_outline_rounded, size: 18, color: StandFlowTokens.darkGreen),
                    const SizedBox(width: 6),
                    Text(
                      'Teste Rápido',
                      style: TextStyle(
                        fontFamily: GoogleFonts.rajdhani().fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: StandFlowTokens.darkGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.checkQuestion,
                  style: TextStyle(
                    fontFamily: GoogleFonts.outfit().fontFamily,
                    fontSize: 13,
                    color: StandFlowTokens.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                if (!_isCheckAnswerRevealed)
                  OutlinedButton(
                    onPressed: () => setState(() => _isCheckAnswerRevealed = true),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: StandFlowTokens.darkGreen,
                      side: const BorderSide(color: StandFlowTokens.darkGreen),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    child: const Text('Revelar Resposta'),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: StandFlowTokens.primaryGreen),
                    ),
                    child: Text(
                      item.checkAnswer,
                      style: TextStyle(
                        fontFamily: GoogleFonts.outfit().fontFamily,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: StandFlowTokens.darkGreen,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String label, String content, IconData icon, {bool isCaution = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isCaution ? const Color(0xFFD97706) : StandFlowTokens.darkGreen,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: GoogleFonts.rajdhani().fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isCaution ? const Color(0xFFD97706) : StandFlowTokens.darkGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            content,
            style: TextStyle(
              fontFamily: GoogleFonts.outfit().fontFamily,
              fontSize: 13,
              color: StandFlowTokens.textDark,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // VISTA DO QUIZ DE FIXAÇÃO
  // ==========================================
  Widget _buildQuizScaffold() {
    final q = _quizQuestions[_quizCurrentIndex];

    return Scaffold(
      backgroundColor: StandFlowTokens.bgDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: StandFlowTokens.primaryGreen, width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Colors.black54, blurRadius: 16, offset: Offset(0, 4)),
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
                            Icons.quiz_rounded,
                            color: StandFlowTokens.primaryGreen,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quiz de Fixação — Fase 1',
                                style: TextStyle(
                                  fontFamily: GoogleFonts.rajdhani().fontFamily,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Pergunta ${_quizCurrentIndex + 1} de ${_quizQuestions.length}',
                                style: TextStyle(
                                  fontFamily: GoogleFonts.outfit().fontFamily,
                                  fontSize: 13,
                                  color: StandFlowTokens.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white70),
                          onPressed: () => setState(() => _isQuizMode = false),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      q.quizQuestion,
                      style: TextStyle(
                        fontFamily: GoogleFonts.outfit().fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Opções de Resposta
                    ..._currentOptions.map((option) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: OutlinedButton(
                          onPressed: () => _answerQuiz(option),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFF1E3A2F)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: const Color(0xFF081C15),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              option,
                              style: TextStyle(
                                fontFamily: GoogleFonts.outfit().fontFamily,
                                fontSize: 14,
                                color: Colors.white70,
                              ),
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
        ),
      ),
    );
  }
}
