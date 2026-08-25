import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../models/challenge.dart';
import 'cyber_hud_container.dart';

/// Cartão responsivo e moderno para exibir um desafio na seção "Começar".
class ChallengeCard extends StatefulWidget {
  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.onTap,
    this.height,
  });

  final ChallengeModel challenge;
  final VoidCallback onTap;
  final double? height;

  @override
  State<ChallengeCard> createState() => _ChallengeCardState();
}

class _ChallengeCardState extends State<ChallengeCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final challenge = widget.challenge;
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = challenge.isLocked ? Colors.grey.shade400 : challenge.accentColor;

    return CyberHudContainer(
      accentColor: accentColor,
      onTap: challenge.isLocked ? null : widget.onTap,
      onHoverChanged: (hovered) => setState(() => _isHovered = hovered),
      padding: const EdgeInsets.all(22),
      height: widget.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Linha Superior: Ícone + Tag Cyber HUD + Estrelas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accentColor.withValues(alpha: _isHovered ? 0.35 : 0.2),
                          accentColor.withValues(alpha: 0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: accentColor.withValues(alpha: _isHovered ? 0.7 : 0.35),
                        width: 1.5,
                      ),
                      boxShadow: [
                        if (_isHovered && !challenge.isLocked)
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                      ],
                    ),
                    child: Icon(
                      challenge.isLocked ? Icons.lock_outline_rounded : challenge.icon,
                      color: accentColor,
                      size: 24,
                        ),
                      ),
                  const SizedBox(width: 10),
                  // Tag Cyber HUD do Desafio
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: isDark ? 0.08 : 0.04),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        bottomRight: Radius.circular(6),
                      ),
                      border: Border.all(
                        color: accentColor.withValues(alpha: isDark ? 0.65 : 0.45),
                        width: 1.2,
                      ),
                    ),
                    child: Text(
                      'DESAFIO 0${challenge.number} • ${challenge.difficultyLabel.toUpperCase()}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontFamily: GoogleFonts.rajdhani().fontFamily,
                        color: isDark ? accentColor : accentColor.withValues(alpha: 0.85),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              if (!challenge.isLocked && challenge.isCompleted)
                Row(
                  children: List.generate(3, (index) {
                    final isAchieved = index < challenge.stars;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.0),
                      child: Icon(
                        isAchieved ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: isAchieved 
                            ? const Color(0xFFFFB300)
                            : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                        shadows: isAchieved
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFFFB300).withValues(alpha: 0.6),
                                  blurRadius: 8,
                                )
                              ]
                            : null,
                        size: 20,
                      ),
                    );
                  }),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Título e Descrição (agrupados para ficarem contíguos)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                challenge.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                challenge.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Rodapé do Cartão: Botão de Iniciar / Ação
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    if (!challenge.isLocked)
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                  ],
                ),
                child: FilledButton.icon(
                  onPressed: challenge.isLocked ? null : widget.onTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    minimumSize: const Size(0, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(challenge.isLocked ? Icons.lock_rounded : Icons.play_arrow_rounded, size: 18),
                  label: Text(challenge.isLocked ? 'Bloqueado' : l10n.buttonStart),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
