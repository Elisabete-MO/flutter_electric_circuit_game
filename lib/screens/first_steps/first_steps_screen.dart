import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/first_step_component.dart';
import '../../widgets/component_detail_dialog.dart';
import '../../widgets/prof_volts_speech.dart';
import '../../widgets/symbol_card.dart';

import '../../widgets/tech_grid_background.dart';
import 'package:google_fonts/google_fonts.dart';

/// Seção "Primeiros passos" — introdução interativa inspirada nas telas de referência.
/// Combina o grid de 8 quadrantes nítido (Imagem 2) com a faixa de instrução orientativa
/// "Observe. You have to know these symbols for this activity." (Imagem 1).
class FirstStepsScreen extends StatefulWidget {
  const FirstStepsScreen({super.key});

  @override
  State<FirstStepsScreen> createState() => _FirstStepsScreenState();
}

class _FirstStepsScreenState extends State<FirstStepsScreen> {
  late List<FirstStepComponent> _components;
  bool _showBannerOverlay = true;
  bool _isQuizMode = false;
  int _quizScore = 0;
  int _quizCurrentIndex = 0;

  @override
  void initState() {
    super.initState();
    _components = List.from(FirstStepComponent.defaultList);
  }

  void _toggleComponentState(int index) {
    setState(() {
      final item = _components[index];
      _components[index] = item.copyWith(isActive: !item.isActive);
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
      _components.shuffle();
    });
  }

  void _resetStudyMode() {
    setState(() {
      _isQuizMode = false;
      _components = List.from(FirstStepComponent.defaultList);
    });
  }

  void _answerQuiz(FirstStepComponent selected) {
    final currentTarget = _components[_quizCurrentIndex];
    final isCorrect = selected.id == currentTarget.id;
    final l10n = AppLocalizations.of(context)!;
    final name = l10n.localeName == 'en' ? selected.nameEn : selected.namePt;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCorrect
              ? l10n.quizCorrect
              : l10n.quizIncorrect(name),
        ),
        backgroundColor: isCorrect ? Colors.green[700] : Colors.red[700],
        duration: const Duration(seconds: 2),
      ),
    );

    setState(() {
      if (isCorrect) {
        _quizScore++;
        if (_quizCurrentIndex < _components.length - 1) {
          _quizCurrentIndex++;
        } else {
          _showQuizResultsDialog();
        }
      }
    });
  }

  void _showQuizResultsDialog() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFB300)),
            const SizedBox(width: 8),
            Text(
              l10n.quizResultTitle,
              style: TextStyle(
                fontFamily: GoogleFonts.rajdhani().fontFamily,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          l10n.quizResultMsg(_quizScore, _components.length),
          style: TextStyle(
            fontSize: 16,
            fontFamily: GoogleFonts.outfit().fontFamily,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetStudyMode();
            },
            child: Text(l10n.quizBackStudy),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startQuizMode();
            },
            child: Text(l10n.buttonRetry),
          ),
        ],
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
            tooltip: 'Alternar instrução',
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
            // Balão de fala do Prof. Volts orientativo
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
                                ? _components[_quizCurrentIndex].nameEn
                                : _components[_quizCurrentIndex].namePt,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.quizQuestionCount(_quizCurrentIndex + 1, _components.length),
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),

                // GRID DE 8 COMPONENTES (Inspirado exatamente nas 8 divisões das referências)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Determina colunas responsivas: 4 em telas largas, 2 em telas estreitas
                        final crossAxisCount = constraints.maxWidth >= 640 ? 4 : 2;

                        return GridView.builder(
                          itemCount: _components.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.88,
                          ),
                          itemBuilder: (context, index) {
                            final comp = _components[index];

                            return SymbolCard(
                              component: comp,
                              showLabels: !_isQuizMode,
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