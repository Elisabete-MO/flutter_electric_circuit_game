import 'package:flutter/material.dart';

/// Níveis de dificuldade dos desafios.
enum ChallengeDifficulty {
  easy,
  medium,
  hard,
}

/// Modelo de dados para os desafios da seção "Começar".
class ChallengeModel {
  const ChallengeModel({
    required this.id,
    required this.number,
    required this.title,
    required this.description,
    required this.objective,
    required this.difficulty,
    required this.icon,
    required this.accentColor,
    this.isCompleted = false,
    this.isLocked = false,
    this.stars = 0,
  });

  

  final String id;
  final int number;
  final String title;
  final String description;
  final String objective;
  final ChallengeDifficulty difficulty;
  final IconData icon;
  final Color accentColor;
  final bool isCompleted;
  final bool isLocked;
  final int stars;

  /// Retorna o rótulo amigável da dificuldade.
  String get difficultyLabel {
    switch (difficulty) {
      case ChallengeDifficulty.easy:
        return 'Fácil';
      case ChallengeDifficulty.medium:
        return 'Médio';
      case ChallengeDifficulty.hard:
        return 'Difícil';
    }
  }

  /// Os 3 desafios iniciais solicitados.
  static List<ChallengeModel> get initialChallenges => const [
        ChallengeModel(
          id: 'challenge_1',
          number: 1,
          title: 'Desafio 1: Acenda a Lâmpada',
          description:
              'Monte seu primeiro circuito elétrico funcional ligando uma fonte de energia a uma lâmpada.',
          objective: 'Conecte a bateria à lâmpada usando fios de modo que a corrente flua e a lâmpada acenda.',
          difficulty: ChallengeDifficulty.easy,
          icon: Icons.lightbulb_outline_rounded,
          accentColor: Color(0xFFFF9F1C), // Âmbar — igual borderDarkColors[0]
        ),
        ChallengeModel(
          id: 'challenge_2',
          number: 2,
          title: 'Desafio 2: Controle com Interruptor',
          description:
              'Adicione um componente de controle para poder ligar e desligar a luz do circuito com segurança.',
          objective: 'Insira um interruptor entre a bateria e a lâmpada e feche o circuito para acendê-la.',
          difficulty: ChallengeDifficulty.medium,
          icon: Icons.toggle_on_rounded,
          accentColor: Color(0xFF2979FF), // Azul Elétrico — igual borderDarkColors[1]
        ),
        ChallengeModel(
          id: 'challenge_3',
          number: 3,
          title: 'Desafio 3: Proteção com Resistor',
          description:
              'Utilize um resistor para limitar a corrente e proteger componentes sensíveis como um LED.',
          objective: 'Calcule e ajuste a resistência para evitar que o LED queime ao ser ligado à bateria.',
          difficulty: ChallengeDifficulty.hard,
          icon: Icons.shield_rounded,
          accentColor: Color(0xFF00E5FF), // Ciano Neon — igual borderDarkColors[2]
        ),
      ];
}
