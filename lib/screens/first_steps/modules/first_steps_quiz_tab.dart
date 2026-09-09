import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/ui_scale.dart';
import '../../../models/first_step_component.dart';
import '../../../widgets/prof_volts_feedback_dialog.dart';
import '../../../widgets/prof_volts_full_body.dart';
import '../../../widgets/success_confetti_overlay.dart';
import '../../../widgets/workbench_components.dart';
import '../../../widgets/workbench_sidebar_cards.dart';
import '../../../widgets/workbench_table_frame.dart';
import '../widgets/first_steps_widgets.dart';

/// Módulo 3 do Estande 01 — Desafio de Fixação (Quiz do Prof. Volts).
class FirstStepsQuizTab extends StatefulWidget {
  final VoidCallback onModuleComplete;

  const FirstStepsQuizTab({
    super.key,
    required this.onModuleComplete,
  });

  @override
  State<FirstStepsQuizTab> createState() => _FirstStepsQuizTabState();
}

class _FirstStepsQuizTabState extends State<FirstStepsQuizTab> {
  late List<FirstStepComponent> _quizQuestions;
  late List<FirstStepComponent> _availableOptions;
  int _currentIndex = 0;
  int _score = 0;
  bool _usePhysicalStyle = false; // Inicia no modo esquemático para testar os símbolos
  String? _selectedOptionId;

  @override
  void initState() {
    super.initState();
    _quizQuestions = List.from(FirstStepComponent.defaultList)..shuffle();
    _availableOptions = List.from(FirstStepComponent.defaultList);
  }

  void _resetQuiz() {
    setState(() {
      _currentIndex = 0;
      _score = 0;
      _selectedOptionId = null;
      _quizQuestions = List.from(FirstStepComponent.defaultList)..shuffle();
    });
  }

  void _onAnswer(FirstStepComponent selected) {
    setState(() {
      _selectedOptionId = selected.id;
    });

    final currentTarget = _quizQuestions[_currentIndex];
    final isCorrect = selected.id == currentTarget.id;

    final feedbackMessage = isCorrect
        ? 'Excelente! Você identificou corretamente o símbolo do(a) ${currentTarget.namePt}.'
        : 'Atenção: Você selecionou o símbolo de ${selected.namePt}, mas o componente procurado era ${currentTarget.namePt}.';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProfVoltsFeedbackDialog(
        isCorrect: isCorrect,
        message: feedbackMessage,
        onAction: () {
          Navigator.of(context).pop();
          setState(() {
            _selectedOptionId = null;
            if (isCorrect) {
              _score++;
            }
            if (_currentIndex < _quizQuestions.length - 1) {
              _currentIndex++;
            } else {
              _showQuizResultsDialog();
            }
          });
        },
      ),
    );
  }

  void _showQuizResultsDialog() {
    final isSuccess = _score >= (_quizQuestions.length / 2);
    final scale = context.uiScale;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSuccess ? const Color(0xFF10B981) : Colors.amber,
            width: 2,
          ),
        ),
        title: Row(
          children: [
            Icon(
              isSuccess ? Icons.emoji_events_rounded : Icons.info_outline_rounded,
              color: isSuccess ? const Color(0xFF10B981) : Colors.amber,
              size: 28,
            ),
            const SizedBox(width: 10),
            Text(
              isSuccess ? 'Tutorial Concluído!' : 'Quase lá!',
              style: GoogleFonts.rajdhani(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: scale.font(20, min: 16, max: 24),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ProfVoltsFullBody(
              emotion: isSuccess ? ProfVoltsEmotion.happy : ProfVoltsEmotion.sad,
              size: scale.size(110, min: 80, max: 150),
            ),
            const SizedBox(height: 12),
            Text(
              'Você acertou $_score de ${_quizQuestions.length} questões!',
              style: GoogleFonts.rajdhani(
                color: const Color(0xFF00E5FF),
                fontWeight: FontWeight.bold,
                fontSize: scale.font(16, min: 14, max: 22),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isSuccess
                  ? 'Parabéns! Você dominou os componentes fundamentais e seus símbolos esquemáticos. Agora está preparado para explorar os circuitos da Feira de Ciências!'
                  : 'Recomendamos revisar a vitrine de componentes para memorizar os símbolos esquemáticos.',
              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          if (!isSuccess)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetQuiz();
              },
              child: Text(
                'TENTAR NOVAMENTE',
                style: GoogleFonts.rajdhani(
                  color: const Color(0xFF00E5FF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              if (isSuccess) {
                showSuccessConfetti(context);
                widget.onModuleComplete();
              } else {
                _resetQuiz();
              }
            },
            child: Text(
              isSuccess ? 'CONCLUIR TUTORIAL' : 'REVISAR',
              style: GoogleFonts.rajdhani(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;
    final currentTarget = _quizQuestions[_currentIndex];

    return Row(
      children: [
        // Coluna Esquerda (7 flex) — Bancada do Quiz
        Expanded(
          flex: 7,
          child: Column(
            children: [
              Expanded(
                child: WorkbenchTableFrame(
                  usePhysicalStyle: _usePhysicalStyle,
                  onStyleChanged: (val) =>
                      setState(() => _usePhysicalStyle = val),
                  leftHeaderWidget: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: scale.spacing(12, min: 8, max: 20),
                      vertical: scale.spacing(6, min: 4, max: 12),
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF0284C7),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      'Pergunta ${_currentIndex + 1} de ${_quizQuestions.length}',
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontSize: scale.font(13, min: 11, max: 18),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Card da Pergunta com Instrução em Destaque
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: scale.spacing(16, min: 12, max: 24),
                            vertical: scale.spacing(10, min: 8, max: 16),
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFF0284C7),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'SELECIONE O SÍMBOLO OU COMPONENTE CORRESPONDENTE:',
                                style: GoogleFonts.rajdhani(
                                  color: const Color(0xFF00E5FF),
                                  fontWeight: FontWeight.bold,
                                  fontSize: scale.font(14, min: 12, max: 18),
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                currentTarget.namePt.toUpperCase(),
                                style: GoogleFonts.rajdhani(
                                  color: const Color(0xFF10B981),
                                  fontSize: scale.font(24, min: 19, max: 32),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Grid com opções (sem os nomes escritos para não entregar a resposta!)
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final crossAxisCount =
                                  constraints.maxWidth >= 700 ? 4 : 2;
                              final spacing = scale.spacing(12, min: 8, max: 18);

                              return GridView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: _availableOptions.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: spacing,
                                  mainAxisSpacing: spacing,
                                  childAspectRatio: 1.1,
                                ),
                                itemBuilder: (context, index) {
                                  final comp = _availableOptions[index];
                                  final isSelected = comp.id == _selectedOptionId;

                                  return FirstStepsComponentTile(
                                    component: comp,
                                    isSelected: isSelected,
                                    usePhysicalStyle: _usePhysicalStyle,
                                    hideLabel: true,
                                    badgeText: 'Opção ${String.fromCharCode(65 + index)}',
                                    onTap: () => _onAnswer(comp),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Coluna Direita (3 flex) — Painel Lateral
        Expanded(
          flex: 3,
          child: WorkbenchSidePanel(
            teamTitle: 'Desafio do Prof. Volts',
            showTeamHeader: false,
            buttonColor: const Color(0xFF059669),
            buttonLabel: 'FINALIZAR QUIZ ➔',
            toolboxItems: [
              WorkbenchMissionObjectiveCard(
                missionNumber: 3,
                title: 'Desafio de Fixação',
                description:
                    'Identifique o componente ou símbolo esquemático solicitado. Teste sua memória visual para consolidar o aprendizado!',
                voltsTip:
                    'Alterne entre o modo Físico e Esquemático no topo da bancada se quiser treinar a identificação de símbolos.',
              ),
              const SizedBox(height: 12),
              // Card do Placar
              Container(
                padding: EdgeInsets.all(scale.spacing(14, min: 10, max: 20)),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.stars_rounded, color: Colors.amber, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          'SEU PLACAR',
                          style: GoogleFonts.rajdhani(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: scale.font(15, min: 13, max: 20),
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$_score / ${_quizQuestions.length}',
                      style: GoogleFonts.rajdhani(
                        color: const Color(0xFF10B981),
                        fontSize: scale.font(34, min: 26, max: 44),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (_currentIndex + 1) / _quizQuestions.length,
                        minHeight: 8,
                        backgroundColor: const Color(0xFF0F172A),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF00E5FF),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Progresso: ${(((_currentIndex + 1) / _quizQuestions.length) * 100).toInt()}%',
                      style: GoogleFonts.outfit(
                        color: Colors.white60,
                        fontSize: scale.font(11, min: 9.5, max: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            onEnergizePressed: _showQuizResultsDialog,
            isLoading: false,
          ),
        ),
      ],
    );
  }
}
