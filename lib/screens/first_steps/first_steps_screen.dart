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
import '../../widgets/eletrolab_header_brand.dart';
import 'package:google_fonts/google_fonts.dart';

/// Seção "Primeiros passos" â€” introdução interativa inspirada nas telas de referência.
/// Combina o grid de 8 quadrantes nítido (Imagem 2) com a faixa de instrução orientativa
/// "Observe. You have to know these symbols for this activity." (Imagem 1).
class FirstStepsScreen extends StatefulWidget {
  final VoidCallback? onPhaseComplete;

  const FirstStepsScreen({super.key, this.onPhaseComplete});

  @override
  State<FirstStepsScreen> createState() => _FirstStepsScreenState();
}

class _FirstStepsScreenState extends State<FirstStepsScreen> {
  late List<FirstStepComponent> _gridComponents;
  late List<FirstStepComponent> _quizQuestions;
  bool _showBannerOverlay = true;
  bool _isQuizMode = false;
  bool _useRealisticAssets = true;
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
      builder: (context) => ComponentDetailDialog(
        initialComponent: component,
        useRealisticAssets: _useRealisticAssets,
      ),
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
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: GlassContainer(
            borderRadius: 24,
            accentColor: accentColor,
            opacity: isDark ? 0.8 : 0.9,
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Mascote Corpo Inteiro
                  ProfVoltsFullBody(
                    emotion: isSuccess ? ProfVoltsEmotion.happy : ProfVoltsEmotion.sad,
                    size: 150,
                  ),
                  const SizedBox(height: 16),
                  
                  // 2. Título HUD Cyber
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
                          l10n.quizResultTitle,
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

                  // 4. Botões de Ação
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSuccess && widget.onPhaseComplete != null) ...[
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
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
                              backgroundColor: const Color(0xFF00FF9D),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
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
                                l10n.quizBackStudy,
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
                                l10n.buttonRetry,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const EletroLabHeaderBrand(compact: true),
        actions: [
          // 1. Botão de alternar "Modo realista" / "Modo cartoon" (Padrão: Realista)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                setState(() {
                  _useRealisticAssets = !_useRealisticAssets;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _useRealisticAssets
                      ? theme.colorScheme.primary.withValues(alpha: 0.18)
                      : (isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _useRealisticAssets
                        ? theme.colorScheme.primary
                        : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _useRealisticAssets ? Icons.photo_library_rounded : Icons.brush_rounded,
                      size: 18,
                      color: _useRealisticAssets ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _useRealisticAssets ? 'Modo realista' : 'Modo cartoon',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontFamily: GoogleFonts.rajdhani().fontFamily,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: _useRealisticAssets ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Botão "Modo desafio" / "Modo estudo"
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                if (_isQuizMode) {
                  _resetStudyMode();
                } else {
                  _startQuizMode();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isQuizMode
                      ? (isDark ? const Color(0xFF00FF9D).withValues(alpha: 0.2) : const Color(0xFF00875A).withValues(alpha: 0.15))
                      : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isQuizMode
                        ? (isDark ? const Color(0xFF00FF9D) : const Color(0xFF00875A))
                        : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isQuizMode ? Icons.sports_esports_rounded : Icons.school_rounded,
                      size: 18,
                      color: _isQuizMode
                          ? (isDark ? const Color(0xFF00FF9D) : const Color(0xFF00875A))
                          : theme.colorScheme.onSurface,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isQuizMode ? 'Modo desafio' : 'Modo estudo',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontFamily: GoogleFonts.rajdhani().fontFamily,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: _isQuizMode
                            ? (isDark ? const Color(0xFF00FF9D) : const Color(0xFF00875A))
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Botão de interrogação por último (Help/Instrução)
          IconButton(
            icon: Icon(
              _showBannerOverlay
                  ? Icons.help_rounded
                  : Icons.help_outline_rounded,
            ),
            tooltip: 'Alternar instrução',
            onPressed: () {
              setState(() {
                _showBannerOverlay = !_showBannerOverlay;
              });
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
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
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
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(12, 6, 12, 4),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF121B2D).withValues(alpha: 0.85)
                          : Colors.white.withValues(alpha: 0.90),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.6 : 0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            // 1. Avatar Animado do Prof. Volts
                            const ProfVoltsAvatar(size: 44, isTalking: false),
                            const SizedBox(width: 12),

                            // 2. Pergunta + Destaque do Componente Alvo
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.quizWhichSymbol,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontFamily: GoogleFonts.outfit().fontFamily,
                                      fontWeight: FontWeight.w500,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  // Badge Embutido do Componente Alvo
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: theme.colorScheme.primary.withValues(alpha: 0.4),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.center_focus_strong_rounded,
                                          size: 16,
                                          color: theme.colorScheme.primary,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          (l10n.localeName == 'en'
                                                  ? _quizQuestions[_quizCurrentIndex].nameEn
                                                  : _quizQuestions[_quizCurrentIndex].namePt)
                                              .toUpperCase(),
                                          style: theme.textTheme.titleSmall?.copyWith(
                                            fontFamily: GoogleFonts.rajdhani().fontFamily,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.2,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 12),

                            // 3. Indicador de Progresso / Placar
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${_quizCurrentIndex + 1} / ${_quizQuestions.length}',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontFamily: GoogleFonts.rajdhani().fontFamily,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Acertos: $_quizScore',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: isDark ? const Color(0xFF00FF9D) : const Color(0xFF00875A),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Barra de Progresso do Quiz Cyberpunk
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (_quizCurrentIndex + 1) / _quizQuestions.length,
                            minHeight: 4,
                            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDark ? const Color(0xFF00F0FF) : theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // GRID DE 8 COMPONENTES (Ajustado dinamicamente para caber na tela com proporção ideal)
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = constraints.maxWidth >= 640 ? 4 : 2;
                        final rowCount = (_gridComponents.length / crossAxisCount).ceil();
                        
                        const spacing = 12.0;
                        final availableWidth = constraints.maxWidth;
                        final availableHeight = constraints.maxHeight;

                        final itemWidth = (availableWidth - (crossAxisCount - 1) * spacing) / crossAxisCount;
                        final itemHeight = (availableHeight - (rowCount - 1) * spacing) / rowCount;

                        final childAspectRatio = (itemWidth > 0 && itemHeight > 0)
                            ? (itemWidth / itemHeight)
                            : 0.88;

                        return GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _gridComponents.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: spacing,
                            mainAxisSpacing: spacing,
                            childAspectRatio: childAspectRatio,
                          ),
                          itemBuilder: (context, index) {
                            final comp = _gridComponents[index];

                            return SymbolCard(
                              component: comp,
                              showLabels: !_isQuizMode,
                              isCorrectlyAnswered: _answeredCorrectlyIds.contains(comp.id),
                              useRealisticAssets: _useRealisticAssets,
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
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
