import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/first_step_component.dart';
import '../../widgets/component_detail_dialog.dart';
import '../../widgets/prof_volts_speech.dart';
import '../../widgets/symbol_card.dart';
import '../../widgets/prof_volts_feedback_dialog.dart';
import '../../widgets/prof_volts_full_body.dart';
import '../../widgets/glass_container.dart';

import '../../widgets/tech_grid_background.dart';
import 'package:google_fonts/google_fonts.dart';

/// SeÃ§Ã£o "Primeiros passos" â€” introduÃ§Ã£o interativa inspirada nas telas de referÃªncia.
/// Combina o grid de 8 quadrantes nÃ­tido (Imagem 2) com a faixa de instruÃ§Ã£o orientativa
/// "Observe. You have to know these symbols for this activity." (Imagem 1).
class FirstStepsScreen extends StatefulWidget {
  const FirstStepsScreen({super.key});

  @override
  State<FirstStepsScreen> createState() => _FirstStepsScreenState();
}

class _FirstStepsScreenState extends State<FirstStepsScreen> {
  late List<FirstStepComponent> _gridComponents;
  late List<FirstStepComponent> _quizQuestions;
  bool _showBannerOverlay = true;
  bool _isQuizMode = false;
  int _quizScore = 0;
  int _quizCurrentIndex = 0;
  final Set<String> _answeredCorrectlyIds = {};

  @override
  void initState() {
    super.initState();
    _gridComponents = List.from(FirstStepComponent.defaultList);
    _quizQuestions = List.from(FirstStepComponent.defaultList);
  }

  void _toggleComponentState(int index) {
    setState(() {
      final item = _gridComponents[index];
      _gridComponents[index] = item.copyWith(isActive: !item.isActive);
    });
  }

  void _openDetailModal(FirstStepComponent component) {
    showDialog(
      context: context,
      builder: (context) => ComponentDetailDialog(initialComponent: component),
    );
  }

  void _startQuizMode() {
    setState(() {
      _isQuizMode = true;
      _quizScore = 0;
      _quizCurrentIndex = 0;
      _answeredCorrectlyIds.clear();
      _gridComponents = List.from(FirstStepComponent.defaultList)..shuffle();
      _quizQuestions = List.from(FirstStepComponent.defaultList)..shuffle();
    });
  }

  void _resetStudyMode() {
    setState(() {
      _isQuizMode = false;
      _answeredCorrectlyIds.clear();
      _gridComponents = List.from(FirstStepComponent.defaultList);
    });
  }

  void _answerQuiz(FirstStepComponent selected) {
    final currentTarget = _quizQuestions[_quizCurrentIndex];
    final isCorrect = selected.id == currentTarget.id;
    final l10n = AppLocalizations.of(context)!;
    final name = l10n.localeName == 'en' ? selected.nameEn : selected.namePt;

    final feedbackMessage = isCorrect
        ? l10n.quizCorrect
        : l10n.quizIncorrect(name);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProfVoltsFeedbackDialog(
        isCorrect: isCorrect,
        message: feedbackMessage,
        onAction: () {
          Navigator.of(context).pop();
          if (isCorrect) {
            setState(() {
              _quizScore++;
              _answeredCorrectlyIds.add(selected.id);
              if (_quizCurrentIndex < _quizQuestions.length - 1) {
                _quizCurrentIndex++;
              } else {
                _showQuizResultsDialog();
              }
            });
          }
        },
      ),
    );
  }

  void _showQuizResultsDialog() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final isSuccess = _quizScore >= (_quizQuestions.length / 2);
    final accentColor = isSuccess
        ? (isDark ? const Color(0xFF00FF9D) : const Color(0xFF00875A))
        : (isDark ? const Color(0xFFFF3B7F) : const Color(0xFFD81B60));
    final buttonTextColor = isDark ? Colors.black : Colors.white;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: GlassContainer(
          borderRadius: 24,
          accentColor: accentColor,
          opacity: isDark ? 0.8 : 0.9,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Mascote Corpo Inteiro
              ProfVoltsFullBody(
                emotion: isSuccess ? ProfVoltsEmotion.happy : ProfVoltsEmotion.sad,
                size: 150,
              ),
              const SizedBox(height: 16),
              
              // 2. TÃ­tulo HUD Cyber
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: accentColor.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSuccess ? Icons.emoji_events_rounded : Icons.info_outline_rounded,
                      color: accentColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.quizResultTitle.toUpperCase(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontFamily: GoogleFonts.rajdhani().fontFamily,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                        letterSpacing: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. Mensagem explicativa
              Text(
                l10n.quizResultMsg(_quizScore, _quizQuestions.length),
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.4,
                  fontSize: 16,
                  fontFamily: GoogleFonts.outfit().fontFamily,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // 4. BotÃµes de AÃ§Ã£o
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _resetStudyMode();
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        l10n.quizBackStudy.toUpperCase(),
                        style: TextStyle(
                          fontFamily: GoogleFonts.rajdhani().fontFamily,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _startQuizMode();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: buttonTextColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        l10n.buttonRetry.toUpperCase(),
                        style: TextStyle(
                          fontFamily: GoogleFonts.rajdhani().fontFamily,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.firstStepsTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showBannerOverlay
                  ? Icons.info_rounded
                  : Icons.info_outline_rounded,
            ),
            tooltip: 'Alternar instruÃ§Ã£o',
            onPressed: () {
              setState(() {
                _showBannerOverlay = !_showBannerOverlay;
              });
            },
          ),
          IconButton(
            icon: Icon(
              _isQuizMode ? Icons.school_rounded : Icons.quiz_rounded,
            ),
            tooltip: _isQuizMode ? 'Modo Estudo' : l10n.challengeMode,
            onPressed: () {
              if (_isQuizMode) {
                _resetStudyMode();
              } else {
                _startQuizMode();
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: TechGridBackground(
        child: SafeArea(
          child: Column(
          children: [
            // BalÃ£o de fala do Prof. Volts orientativo
            if (_showBannerOverlay && !_isQuizMode)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Stack(
                  children: [
                    ProfVoltsSpeech(
                      text: l10n.firstStepsBanner,
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => setState(() => _showBannerOverlay = false),
                      ),
                    ),
                  ],
                ),
              ),

                // Se estiver no Modo Quiz / Desafio
                if (_isQuizMode)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.colorScheme.primary),
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.quizWhichSymbol,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Chip(
                          avatar: const Icon(Icons.category_rounded, size: 18),
                          label: Text(
                            l10n.localeName == 'en'
                                ? _quizQuestions[_quizCurrentIndex].nameEn
                                : _quizQuestions[_quizCurrentIndex].namePt,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.quizQuestionCount(_quizCurrentIndex + 1, _quizQuestions.length),
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),

                // GRID DE 8 COMPONENTES (Inspirado exatamente nas 8 divisÃµes das referÃªncias)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Determina colunas responsivas: 4 em telas largas, 2 em telas estreitas
                        final crossAxisCount = constraints.maxWidth >= 640 ? 4 : 2;

                        return GridView.builder(
                          itemCount: _gridComponents.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.88,
                          ),
                          itemBuilder: (context, index) {
                            final comp = _gridComponents[index];

                            return SymbolCard(
                              component: comp,
                              showLabels: !_isQuizMode,
                              isCorrectlyAnswered: _answeredCorrectlyIds.contains(comp.id),
                              onTap: () {
                                if (_isQuizMode) {
                                  _answerQuiz(comp);
                                } else {
                                  _openDetailModal(comp);
                                }
                              },
                              onToggleState: () => _toggleComponentState(index),
                            );
                          },
                        );
                      },
                    ),
                ),
              ),
          ],
        ),
      ),
    ),
    );
  }
}
