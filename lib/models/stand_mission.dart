import 'package:flutter/foundation.dart';

/// Modelo de dados para representação das Missões Pedagógicas dos Estandes da Feira de Ciências.
@immutable
class StandMission {
  final String id;
  final String standId;
  final int number;
  final String title;
  final String objective;
  final String componentsInfo;
  final String victoryCriteria;
  final String failureFeedback;
  final String voltsMediation;

  const StandMission({
    required this.id,
    required this.standId,
    required this.number,
    required this.title,
    required this.objective,
    required this.componentsInfo,
    required this.victoryCriteria,
    required this.failureFeedback,
    required this.voltsMediation,
  });

  /// Fala oficial de mediação do Professor Volts para o Estande 3 ("Liga e Desliga")
  static const String voltsMediationEstande3 =
      'Um interruptor não cria energia. Ele decide se o caminho está completo ou interrompido.';

  static List<StandMission> get estande3Missions => const [
        StandMission(
          id: 'liga_desliga_m1',
          standId: 'liga_desliga',
          number: 1,
          title: 'Interruptor da luminária',
          objective: 'Conectar a bateria, o interruptor e a lâmpada para controlar a luminária.',
          componentsInfo: 'Bateria (4.5V), Interruptor, Lâmpada e Fios condutores',
          victoryCriteria: 'Lâmpada responde ao interruptor (acende no estado fechado e apaga no aberto)',
          failureFeedback: 'O interruptor precisa estar no caminho.',
          voltsMediation: voltsMediationEstande3,
        ),
        StandMission(
          id: 'liga_desliga_m2',
          standId: 'liga_desliga',
          number: 2,
          title: 'Aberto ou fechado?',
          objective: 'Analisar o circuito pronto e prever corretamente os dois estados de funcionamento.',
          componentsInfo: 'Circuito montado com interruptor e lâmpada',
          victoryCriteria: 'Prever corretamente os dois estados (Aberto = Interrompido, Fechado = Condução)',
          failureFeedback: 'Circuito aberto interrompe a passagem.',
          voltsMediation: voltsMediationEstande3,
        ),
        StandMission(
          id: 'liga_desliga_m3',
          standId: 'liga_desliga',
          number: 3,
          title: 'Dois controles',
          objective: 'Mapear a relação entre 2 interruptores e 2 lâmpadas independentes.',
          componentsInfo: '2 Interruptores, 2 Lâmpadas e Fonte de energia',
          victoryCriteria: 'Mapear controle-lâmpada (Descobrir qual chave aciona cada lâmpada)',
          failureFeedback: 'Teste um interruptor por vez.',
          voltsMediation: voltsMediationEstande3,
        ),
        StandMission(
          id: 'liga_desliga_m4',
          standId: 'liga_desliga',
          number: 4,
          title: 'Conferência',
          objective: 'Diagnosticar o circuito defeituoso e reposicionar a chave que está em um ramo inútil.',
          componentsInfo: 'Montagem com interruptor em ramo paralelo inútil',
          victoryCriteria: 'Reposicionar o interruptor para o ramo correto em série com a lâmpada',
          failureFeedback: 'Essa chave não interrompe a corrente da lâmpada.',
          voltsMediation: voltsMediationEstande3,
        ),
        StandMission(
          id: 'liga_desliga_m5',
          standId: 'liga_desliga',
          number: 5,
          title: 'Demonstração guiada',
          objective: 'Atender às solicitações dos visitantes acionando a sequência correta de estados.',
          componentsInfo: 'Painel com instruções e controles de iluminação',
          victoryCriteria: 'Cumprir a sequência de estados solicitada pelos visitantes',
          failureFeedback: 'Leia o pedido do visitante antes de montar.',
          voltsMediation: voltsMediationEstande3,
        ),
      ];
}
