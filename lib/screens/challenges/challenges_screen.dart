import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../models/challenge.dart';
import '../../widgets/challenge_card.dart';
import '../../widgets/prof_volts_speech.dart';
import '../../widgets/tech_grid_background.dart';
import '../../state/progress_controller.dart';
import 'challenge_1_detail_screen.dart';
import 'challenge_2_detail_screen.dart';
import 'challenge_3_detail_screen.dart';

/// Seção "Começar" — Desafios práticos de circuitos.
class ChallengesScreen extends ConsumerStatefulWidget {
  const ChallengesScreen({super.key});

  @override
  ConsumerState<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends ConsumerState<ChallengesScreen> {
  @override
  void initState() {
    super.initState();
  }

  void _onChallengeTap(ChallengeModel challenge) {
    switch (challenge.id) {
      case 'challenge_1':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const Challenge1DetailScreen(),
          ),
        );
        return;
      case 'challenge_2':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const Challenge2DetailScreen(),
          ),
        );
        return;
      case 'challenge_3':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const Challenge3DetailScreen(),
          ),
        );
        return;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final progress = ref.watch(progressControllerProvider);

    final localizedChallenges = [
      ChallengeModel(
        id: 'challenge_1',
        number: 1,
        title: l10n.challenge1Title,
        description: l10n.challenge1Desc,
        objective: '',
        difficulty: ChallengeDifficulty.easy,
        icon: Icons.lightbulb_outline_rounded,
        accentColor: const Color(0xFFFF9F1C), // âmbar — paleta oficial
        isCompleted: progress.completedChallenges.contains('challenge_1'),
        isLocked: false,
        stars: progress.challengeStars['challenge_1'] ?? 0,
      ),
      ChallengeModel(
        id: 'challenge_2',
        number: 2,
        title: l10n.challenge2Title,
        description: l10n.challenge2Desc,
        objective: '',
        difficulty: ChallengeDifficulty.medium,
        icon: Icons.toggle_on_rounded,
        accentColor: const Color(0xFF2979FF), // azul elétrico — paleta oficial
        isCompleted: progress.completedChallenges.contains('challenge_2'),
        isLocked: !progress.completedChallenges.contains('challenge_1'),
        stars: progress.challengeStars['challenge_2'] ?? 0,
      ),
      ChallengeModel(
        id: 'challenge_3',
        number: 3,
        title: l10n.challenge3Title,
        description: l10n.challenge3Desc,
        objective: '',
        difficulty: ChallengeDifficulty.hard,
        icon: Icons.shield_rounded,
        accentColor: const Color(0xFF00E5FF), // ciano neon — paleta oficial
        isCompleted: progress.completedChallenges.contains('challenge_3'),
        isLocked: !progress.completedChallenges.contains('challenge_2'),
        stars: progress.challengeStars['challenge_3'] ?? 0,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.challengesTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: TechGridBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fala do Prof. Volts explicando a seção
                ProfVoltsSpeech(
                  text: '${l10n.challengesHeaderTitle}\n${l10n.challengesHeaderDesc}',
                ),
                const SizedBox(height: 24),

                Text(
                  l10n.challengesAvailable(localizedChallenges.length),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // GRID RESPONSIVO DOS 3 DESAFIOS
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 720;

                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final challenge in localizedChallenges) ...[
                            Expanded(
                              child: ChallengeCard(
                                challenge: challenge,
                                height: 265,
                                onTap: () => _onChallengeTap(challenge),
                              ),
                            ),
                            if (challenge != localizedChallenges.last)
                              const SizedBox(width: 16),
                          ],
                        ],
                      );
                    }

                    return Column(
                      children: [
                        for (final challenge in localizedChallenges) ...[
                          ChallengeCard(
                            challenge: challenge,
                            onTap: () => _onChallengeTap(challenge),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}