import 'package:flutter/foundation.dart';

/// Model representing a Science Fair stand in EletroLab.
@immutable
class StandData {
  final String id;
  final int number;
  final String name;
  final String team;
  final String concept;
  final String asset;
  final double relX;
  final double relY;
  final int completedMissions;
  final int totalMissions;
  final bool hasMissions;
  final bool isBancadaLivre;
  final bool isMaqueteColetiva;

  const StandData({
    required this.id,
    required this.number,
    required this.name,
    required this.team,
    required this.concept,
    required this.asset,
    required this.relX,
    required this.relY,
    this.completedMissions = 0,
    this.totalMissions = 5,
    this.hasMissions = true,
    this.isBancadaLivre = false,
    this.isMaqueteColetiva = false,
  });

  StandData copyWith({
    int? completedMissions,
  }) {
    return StandData(
      id: id,
      number: number,
      name: name,
      team: team,
      concept: concept,
      asset: asset,
      relX: relX,
      relY: relY,
      completedMissions: completedMissions ?? this.completedMissions,
      totalMissions: totalMissions,
      hasMissions: hasMissions,
      isBancadaLivre: isBancadaLivre,
      isMaqueteColetiva: isMaqueteColetiva,
    );
  }

  /// Lista oficial dos 12 estandes da Feira de Ciências.
  static List<StandData> get defaultStands => const [
        // 01. Primeiros Passos (Tutorial) - Coluna 1 topo
        StandData(
          id: 'primeiros_passos',
          number: 1,
          name: 'Primeiros Passos',
          team: 'Equipe Tutorial',
          concept: 'Aprenda os conceitos fundamentais de circuitos e navegação',
          asset: 'assets/stands/estande_01.png',
          relX: 0.15,
          relY: 0.20,
          hasMissions: false,
          totalMissions: 0,
        ),

        // 02. Acende Aí (Missão 1) - Coluna 1 meio
        StandData(
          id: 'acende_ai',
          number: 2,
          name: 'Acende Aí',
          team: 'Equipe Luz',
          concept: 'Aprenda a conectar fonte, fios e lâmpada em um circuito fechado',
          asset: 'assets/stands/estande_01.png',
          relX: 0.15,
          relY: 0.50,
          totalMissions: 5,
        ),

        // 03. Liga e Desliga (Missão 2) - Coluna 1 base
        StandData(
          id: 'liga_desliga',
          number: 3,
          name: 'Liga e Desliga',
          team: 'Equipe Controle',
          concept: 'Interruptor e estados do circuito',
          asset: 'assets/stands/estande_03.png',
          relX: 0.15,
          relY: 0.80,
          totalMissions: 5,
        ),

        // 04. Ruas da Maquete (Missão 3) - Coluna 2 topo
        StandData(
          id: 'ruas_maquete',
          number: 4,
          name: 'Ruas da Maquete',
          team: 'Equipe Bairro',
          concept: 'Série, paralelo e ramificações',
          asset: 'assets/stands/estande_02.png',
          relX: 0.33,
          relY: 0.32,
          totalMissions: 5,
        ),

        // 05. Letreros de LED (Missão 4) - Coluna 2 base
        StandData(
          id: 'letreros_led',
          number: 5,
          name: 'Letreros de LED',
          team: 'Equipe Sinalização',
          concept: 'Polaridade, LED, diodo e resistor',
          asset: 'assets/stands/estande_05.png',
          relX: 0.33,
          relY: 0.68,
          totalMissions: 5,
        ),

        // 06. Movimento em Miniatura (Missão 5) - Coluna 3 topo
        StandData(
          id: 'movimento',
          number: 6,
          name: 'Movimento em Miniatura',
          team: 'Equipe Mecânica',
          concept: 'Motor CC e inversão de polaridade',
          asset: 'assets/stands/estande_04.png',
          relX: 0.67,
          relY: 0.32,
          totalMissions: 5,
        ),

        // 07. Mede, Testa e Explica (Missão 6) - Coluna 3 base
        StandData(
          id: 'mede_testa',
          number: 7,
          name: 'Mede, Testa e Explica',
          team: 'Equipe Investigação',
          concept: 'Tensão, corrente e resistência',
          asset: 'assets/stands/estande_06.png',
          relX: 0.67,
          relY: 0.68,
          totalMissions: 5,
        ),

        // 08. Circuito Seguro (Missão 7) - Coluna 4 topo
        StandData(
          id: 'circuito_seguro',
          number: 8,
          name: 'Circuito Seguro',
          team: 'Equipe Segurança',
          concept: 'Curto, circuito aberto e fusível didático',
          asset: 'assets/stands/estande_07.png',
          relX: 0.85,
          relY: 0.20,
          totalMissions: 5,
        ),

        // 09. Horta Monitorada (Missão 8) - Coluna 4 meio
        StandData(
          id: 'horta_monitorada',
          number: 9,
          name: 'Horta Monitorada',
          team: 'Equipe Ambiente',
          concept: 'Potenciômetro, sensor e capacitor',
          asset: 'assets/stands/estande_08.png',
          relX: 0.85,
          relY: 0.50,
          totalMissions: 5,
        ),

        // 10. Portão da Escola (Missão 9) - Coluna 4 base
        StandData(
          id: 'portao_escola',
          number: 10,
          name: 'Portão da Escola',
          team: 'Equipe Automação',
          concept: 'Relé, comando e carga',
          asset: 'assets/stands/estande_09.png',
          relX: 0.85,
          relY: 0.80,
          totalMissions: 5,
        ),

        // 11. Praça da Maquete Coletiva (Missão 10 - topo centro)
        StandData(
          id: 'praca_maquete',
          number: 11,
          name: 'Praça da Maquete Coletiva',
          team: 'Todas as equipes',
          concept: 'Integração, diagnóstico e apresentação',
          asset: 'assets/stands/estande_12.png',
          relX: 0.50,
          relY: 0.15,
          isMaqueteColetiva: true,
          totalMissions: 5,
        ),

        // 12. Bancada Livre - Modo Livre 3D (base centro - Especial)
        StandData(
          id: 'bancada_livre',
          number: 12,
          name: 'Bancada Livre',
          team: 'Laboratório 3D',
          concept: 'Simulação livre de circuitos elétricos',
          asset: 'assets/stands/estande_11.png',
          relX: 0.50,
          relY: 0.85,
          hasMissions: false,
          totalMissions: 0,
          isBancadaLivre: true,
        ),
      ];
}
