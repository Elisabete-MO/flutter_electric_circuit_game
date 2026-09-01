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

  /// Lista oficial de estandes da Feira de Ciências.
  static List<StandData> get defaultStands => const [
        // 1. Primeiros Passos (Tutorial) - Sem missões 0/5
        StandData(
          id: 'primeiros_passos',
          number: 1,
          name: 'Primeiros Passos',
          team: 'Equipe Luz',
          concept: 'Aprenda a conectar fonte, fios e lâmpada em um circuito fechado',
          asset: 'assets/stands/estande_01.png',
          relX: 0.16,
          relY: 0.30,
          hasMissions: false,
          totalMissions: 0,
        ),

        // 2. Liga e Desliga
        StandData(
          id: 'liga_desliga',
          number: 2,
          name: 'Liga e Desliga',
          team: 'Equipe Controle',
          concept: 'Interruptor e estados do circuito',
          asset: 'assets/stands/estande_02.png',
          relX: 0.16,
          relY: 0.50,
          totalMissions: 5,
        ),

        // 3. Ruas da Maquete
        StandData(
          id: 'ruas_maquete',
          number: 3,
          name: 'Ruas da Maquete',
          team: 'Equipe Bairro',
          concept: 'Série, paralelo e ramificações',
          asset: 'assets/stands/estande_03.png',
          relX: 0.16,
          relY: 0.70,
          totalMissions: 5,
        ),

        // 4. Letreiros de LED
        StandData(
          id: 'letreiros_led',
          number: 4,
          name: 'Letreiros de LED',
          team: 'Equipe Sinalização',
          concept: 'Polaridade, LED, diodo e resistor',
          asset: 'assets/stands/estande_04.png',
          relX: 0.33,
          relY: 0.35,
          totalMissions: 5,
        ),

        // 5. Movimento em Miniatura
        StandData(
          id: 'movimento',
          number: 5,
          name: 'Movimento em Miniatura',
          team: 'Equipe Mecânica',
          concept: 'Motor CC e inversão de polaridade',
          asset: 'assets/stands/estande_05.png',
          relX: 0.33,
          relY: 0.70,
          totalMissions: 5,
        ),

        // 6. Mede, Testa e Explica
        StandData(
          id: 'mede_testa',
          number: 6,
          name: 'Mede, Testa e Explica',
          team: 'Equipe Investigação',
          concept: 'Tensão, corrente e resistência',
          asset: 'assets/stands/estande_06.png',
          relX: 0.67,
          relY: 0.35,
          totalMissions: 5,
        ),

        // 7. Circuito Seguro
        StandData(
          id: 'circuito_seguro',
          number: 7,
          name: 'Circuito Seguro',
          team: 'Equipe Segurança',
          concept: 'Curto, circuito aberto e fusível didático',
          asset: 'assets/stands/estande_07.png',
          relX: 0.67,
          relY: 0.70,
          totalMissions: 5,
        ),

        // 8. Horta Monitorada
        StandData(
          id: 'horta_monitorada',
          number: 8,
          name: 'Horta Monitorada',
          team: 'Equipe Ambiente',
          concept: 'Potenciômetro, sensor e capacitor',
          asset: 'assets/stands/estande_08.png',
          relX: 0.84,
          relY: 0.30,
          totalMissions: 5,
        ),

        // 9. Portão da Escola
        StandData(
          id: 'portao_escola',
          number: 9,
          name: 'Portão da Escola',
          team: 'Equipe Automação',
          concept: 'Relé, comando e carga',
          asset: 'assets/stands/estande_09.png',
          relX: 0.84,
          relY: 0.50,
          totalMissions: 5,
        ),

        // 10. Praça da Maquete Coletiva
        StandData(
          id: 'praca_maquete',
          number: 10,
          name: 'Praça da Maquete Coletiva',
          team: 'Todas as equipes',
          concept: 'Integração, diagnóstico e apresentação',
          asset: 'assets/stands/estande_10.png',
          relX: 0.84,
          relY: 0.70,
          totalMissions: 5,
        ),

        // 11. Maquete Coletiva
        StandData(
          id: 'maquete_coletiva',
          number: 11,
          name: 'Maquete Coletiva',
          team: 'Integração Comunitária',
          concept: 'Integração final dos subsistemas',
          asset: 'assets/stands/estande_11.png',
          relX: 0.50,
          relY: 0.28,
          isMaqueteColetiva: true,
          totalMissions: 5,
        ),

        // 12. Bancada Livre - Sem missões 0/5
        StandData(
          id: 'bancada_livre',
          number: 12,
          name: 'Bancada Livre',
          team: 'Laboratório 3D',
          concept: 'Simulação livre de circuitos elétricos',
          asset: 'assets/stands/estande_12.png',
          relX: 0.50,
          relY: 0.76,
          hasMissions: false,
          totalMissions: 0,
          isBancadaLivre: true,
        ),
      ];
}
