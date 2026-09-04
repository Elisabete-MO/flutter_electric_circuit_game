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

  /// Fala oficial de mediação do Professor Volts para o Estande "Ruas da Maquete"
  static const String voltsMediationEstandeRuasMaquete =
      'Quando há mais de um destino, a organização dos caminhos altera o comportamento de todo o circuito.';

  /// Fala oficial de mediação do Professor Volts para o Estande "Letreiros de LED"
  static const String voltsMediationEstandeLetrerosLed =
      'Componentes semicondutores como LEDs possuem sentido certo para conduzir. E limitar a corrente é fundamental para sua durabilidade.';

  static List<StandMission> get estande3Missions => const [
        StandMission(
          id: 'liga_desliga_m1',
          standId: 'liga_desliga',
          number: 1,
          title: 'Luz sob comando',
          objective: 'A equipe da recepção quer controlar a luminária sem desconectar fios toda vez. Inclua uma chave SPST no próprio caminho da lâmpada e mostre que ela cria ou interrompe o percurso conforme abre e fecha.',
          componentsInfo: 'Bateria (4.5V), Interruptor SPST, Lâmpada e Fios condutores',
          victoryCriteria: 'Chave aberta apaga; fechada acende.',
          failureFeedback: 'O interruptor SPST precisa estar no caminho da corrente.',
          voltsMediation: voltsMediationEstande3,
        ),
        StandMission(
          id: 'liga_desliga_m2',
          standId: 'liga_desliga',
          number: 2,
          title: 'Preveja a chave',
          objective: 'Dois cartazes mostram a mesma lâmpada em estados diferentes de chave. Sem energizar, leia os símbolos, registre a sua aposta e só então revele se o caminho está completo ou interrompido.',
          componentsInfo: 'Circuito montado com interruptor e lâmpada',
          victoryCriteria: 'Previsões e justificativas corretas.',
          failureFeedback: 'Circuito aberto interrompe a passagem da corrente.',
          voltsMediation: voltsMediationEstande3,
        ),
        StandMission(
          id: 'liga_desliga_m3',
          standId: 'liga_desliga',
          number: 3,
          title: 'Quem controla qual luz?',
          objective: 'Duas chaves foram instaladas sem etiqueta na pressa da montagem. Planeje uma investigação justa — mudando uma coisa por vez — para descobrir qual comando pertence a cada luminária e preparar as etiquetas da equipe.',
          componentsInfo: '2 Interruptores sem etiqueta, 2 Lâmpadas e Fonte de energia',
          victoryCriteria: 'Mapa correto com testes controlados.',
          failureFeedback: 'Teste um interruptor por vez e observe qual luz responde.',
          voltsMediation: voltsMediationEstande3,
        ),
        StandMission(
          id: 'liga_desliga_m4',
          standId: 'liga_desliga',
          number: 4,
          title: 'Chave no lugar errado',
          objective: 'A lâmpada continua acesa mesmo com a chave aberta, porque a corrente encontrou um desvio. Reconheça por que esse comando não tem efeito e coloque-o no ponto em que ele realmente consegue interromper o ramo da carga.',
          componentsInfo: 'Montagem com interruptor em desvio paralelo',
          victoryCriteria: 'SPST reposicionado em série.',
          failureFeedback: 'Essa chave em paralelo não interrompe a corrente da lâmpada.',
          voltsMediation: voltsMediationEstande3,
        ),
        StandMission(
          id: 'liga_desliga_m5',
          standId: 'liga_desliga',
          number: 5,
          title: 'Luz de chamada',
          objective: 'Na bancada de dúvidas, a luz deve avisar somente enquanto alguém pressiona o botão. Monte esse comando momentâneo e diferencie sua função da de um interruptor que permanece na posição escolhida.',
          componentsInfo: 'Bateria, botão de pressão, lâmpada',
          victoryCriteria: 'Estado acompanha o botão.',
          failureFeedback: 'O botão de pressão deve manter a luz acesa apenas durante a pressão contínua.',
          voltsMediation: voltsMediationEstande3,
        ),
      ];

  static List<StandMission> get ruasMaqueteMissions => const [
        StandMission(
          id: 'ruas_maquete_m1',
          standId: 'ruas_maquete',
          number: 1,
          title: 'Primeiro poste',
          objective: 'Liga bateria, fios e o poste-lâmpada.',
          componentsInfo: 'Bateria 4.5V, 1 lâmpada de poste, fios condutores',
          victoryCriteria: 'Poste iluminado com retorno.',
          failureFeedback: 'Certifique-se de conectar a lâmpada do poste entre os dois polos da fonte.',
          voltsMediation: voltsMediationEstandeRuasMaquete,
        ),
        StandMission(
          id: 'ruas_maquete_m2',
          standId: 'ruas_maquete',
          number: 2,
          title: 'Uma segunda luz',
          objective: 'Monta série e paralelo, prevê brilho e retirada de lâmpada, depois testa.',
          componentsInfo: 'Circuito comutável com opções em série e em paralelo',
          victoryCriteria: 'Compara topologias observando.',
          failureFeedback: 'Em série o brilho cai e a remoção apaga ambos; em paralelo os ramos são independentes.',
          voltsMediation: voltsMediationEstandeRuasMaquete,
        ),
        StandMission(
          id: 'ruas_maquete_m3',
          standId: 'ruas_maquete',
          number: 3,
          title: 'Casa em manutenção',
          objective: 'Abre uma casa numa rede que apaga tudo e segue os ramos.',
          componentsInfo: 'Circuito residencial com ligação inadequada em série',
          victoryCriteria: 'Encontra ligação em série indevida.',
          failureFeedback: 'Cada casa deve estar em seu próprio ramo paralelo para permitir desligamento isolado.',
          voltsMediation: voltsMediationEstandeRuasMaquete,
        ),
        StandMission(
          id: 'ruas_maquete_m4',
          standId: 'ruas_maquete',
          number: 4,
          title: 'Bairro em funcionamento',
          objective: 'Usa junções para construir dois postes e duas casas em quatro ramos.',
          componentsInfo: 'Fonte, 2 lâmpadas de casas, 2 lâmpadas de postes, junções de fios',
          victoryCriteria: 'Quatro cargas independentes.',
          failureFeedback: 'Todos os 4 ramos precisam se conectar de forma independente à linha de retorno.',
          voltsMediation: voltsMediationEstandeRuasMaquete,
        ),
        StandMission(
          id: 'ruas_maquete_m5',
          standId: 'ruas_maquete',
          number: 5,
          title: 'Manutenção durante a visita',
          objective: 'Abre chave de uma casa ou remove lâmpada diante do visitante.',
          componentsInfo: 'Rede do bairro em paralelo com lâmpada removível',
          victoryCriteria: 'Outros ramos permanecem acesos.',
          failureFeedback: 'Em paralelo, remover uma carga interrompe apenas aquele ramo específico.',
          voltsMediation: voltsMediationEstandeRuasMaquete,
        ),
      ];

  static List<StandMission> get letrerosLedMissions => const [
        StandMission(
          id: 'letreros_led_m1',
          standId: 'letreros_led',
          number: 1,
          title: 'Placa de Saída',
          objective: 'Gira LED, conecta ânodo/cátodo e inclui resistor 680 Ω em série com 9 V.',
          componentsInfo: 'Bateria 9V, LED vermelho, Resistor 680Ω',
          victoryCriteria: 'LED aceso em corrente segura.',
          failureFeedback: 'Verifique a polaridade do LED: o ânodo deve ir no positivo e a corrente precisa do resistor de 680 Ω.',
          voltsMediation: voltsMediationEstandeLetrerosLed,
        ),
        StandMission(
          id: 'letreros_led_m2',
          standId: 'letreros_led',
          number: 2,
          title: 'E se o LED estiver invertido?',
          objective: 'Prevê o efeito, gira o LED apagado e testa.',
          componentsInfo: 'Letreiro apagado com LED em polaridade invertida',
          victoryCriteria: 'Compara polaridade e resultado.',
          failureFeedback: 'O LED no sentido inverso bloqueia a corrente.',
          voltsMediation: voltsMediationEstandeLetrerosLed,
        ),
        StandMission(
          id: 'letreros_led_m3',
          standId: 'letreros_led',
          number: 3,
          title: 'Por que a placa não acende?',
          objective: 'Testa LED invertido, fio aberto e resistor fora do ramo por inspeção/medição.',
          componentsInfo: 'Bateria 9V, LED, resistores (68Ω, 680Ω, 6.8kΩ)',
          victoryCriteria: 'Descarta hipóteses com evidência.',
          failureFeedback: 'Testar e descartar as causas de falha com medições antes de energizar.',
          voltsMediation: voltsMediationEstandeLetrerosLed,
        ),
        StandMission(
          id: 'letreros_led_m4',
          standId: 'letreros_led',
          number: 4,
          title: 'Brilho com responsabilidade',
          objective: 'Troca 68 Ω, 680 Ω e 6,8 kΩ na montagem real.',
          componentsInfo: '2 LEDs (Entrada e Saída), resistores de 68Ω, 680Ω, 6.8kΩ, bateria 9V',
          victoryCriteria: 'Escolhe 680 Ω por proteção e brilho.',
          failureFeedback: '68 Ω causa sobrecorrente e 6.8 kΩ deixa a luz fraca demais.',
          voltsMediation: voltsMediationEstandeLetrerosLed,
        ),
        StandMission(
          id: 'letreros_led_m5',
          standId: 'letreros_led',
          number: 5,
          title: 'Entrada e Saída',
          objective: 'Monta dois ramos LED+resistor e a banca remove um deles.',
          componentsInfo: 'Dois ramos de LED com resistores de limitação',
          victoryCriteria: 'Outro letreiro continua funcional.',
          failureFeedback: 'Em paralelo com resistores próprios, remover um ramo mantém o outro operacional.',
          voltsMediation: voltsMediationEstandeLetrerosLed,
        ),
      ];

  /// Fala oficial de mediação do Professor Volts para o Estande "Movimento em Miniatura"
  static const String voltsMediationEstandeMovimentoMiniatura =
      'Luz e movimento são formas diferentes de energia geradas pela corrente elétrica. Vamos explorar o motor CC.';

  static List<StandMission> get movimentoMiniaturaMissions => const [
        StandMission(
          id: 'movimento_miniatura_m1',
          standId: 'movimento',
          number: 1,
          title: 'Ventilador do estande',
          objective: 'Conecta fonte e motor CC pelos terminais.',
          componentsInfo: 'Bateria, motor CC didático com hélice',
          victoryCriteria: 'Motor gira.',
          failureFeedback: 'Confira se ambos os terminais do motor estão conectados à fonte.',
          voltsMediation: voltsMediationEstandeMovimentoMiniatura,
        ),
        StandMission(
          id: 'movimento_miniatura_m2',
          standId: 'movimento',
          number: 2,
          title: 'Carrinho de ida e volta',
          objective: 'Prevê o sentido e troca os dois fios do motor.',
          componentsInfo: 'Bateria comutável, motor CC de tração do carrinho',
          victoryCriteria: 'Carrinho chega ao destino.',
          failureFeedback: 'Inverta a polaridade para alterar o sentido do campo magnético e da rotação.',
          voltsMediation: voltsMediationEstandeMovimentoMiniatura,
        ),
        StandMission(
          id: 'movimento_miniatura_m3',
          standId: 'movimento',
          number: 3,
          title: 'Carrinho parado',
          objective: 'Executa testes de fonte, chave e continuidade para achar mau contato.',
          componentsInfo: 'Bateria, motor CC, chave e terminais com defeito oculto',
          victoryCriteria: 'Falha achada por testes.',
          failureFeedback: 'Siga a sequência de testes (fonte, chave, terminais) para localizar a abertura.',
          voltsMediation: voltsMediationEstandeMovimentoMiniatura,
        ),
        StandMission(
          id: 'movimento_miniatura_m4',
          standId: 'movimento',
          number: 4,
          title: 'Motor sob comando',
          objective: 'Insere push-button em série e LED+resistor em paralelo.',
          componentsInfo: 'Bateria, motor CC, botão de pressão, LED indicador, resistor 680 Ω',
          victoryCriteria: 'Motor e indicador respondem juntos.',
          failureFeedback: 'O botão controla o conjunto e o LED necessita de resistor de proteção.',
          voltsMediation: voltsMediationEstandeMovimentoMiniatura,
        ),
        StandMission(
          id: 'movimento_miniatura_m5',
          standId: 'movimento',
          number: 5,
          title: 'Mostre o movimento',
          objective: 'Visitante pressiona botão; jogador troca polaridade para escolher rota.',
          componentsInfo: 'Montagem completa com botão e reversão de polaridade',
          victoryCriteria: 'Explica comando e reversão.',
          failureFeedback: 'Demonstre a função do botão de acionamento e a rotação por polaridade.',
          voltsMediation: voltsMediationEstandeMovimentoMiniatura,
        ),
      ];

  /// Fala oficial de mediação do Professor Volts para o Estande "Mede, Testa e Explica"
  static const String voltsMediationEstandeMedeTestaExplica =
      'Medir é enxergar o invisível: o multímetro revela quanta tensão e quanta corrente estão presentes no circuito.';

  static List<StandMission> get medeTestaExplicaMissions => const [
        StandMission(
          id: 'mede_testa_m1',
          standId: 'mede_testa',
          number: 1,
          title: 'Tensão da bateria',
          objective: 'Prende voltímetro em paralelo aos polos da bateria 9 V.',
          componentsInfo: 'Bateria 9V, voltímetro didático',
          victoryCriteria: 'Leitura aproximada de 9 V.',
          failureFeedback: 'O voltímetro deve ser conectado em paralelo com os terminais da fonte.',
          voltsMediation: voltsMediationEstandeMedeTestaExplica,
        ),
        StandMission(
          id: 'mede_testa_m2',
          standId: 'mede_testa',
          number: 2,
          title: 'Queda na carga',
          objective: 'Posiciona ponteiras na carga, prevê leitura e testa.',
          componentsInfo: 'Bateria 9V, lâmpada de carga, voltímetro didático',
          victoryCriteria: 'Mede em paralelo e interpreta.',
          failureFeedback: 'Verifique exatamente entre quais dois pontos sobre a carga as pontas foram colocadas.',
          voltsMediation: voltsMediationEstandeMedeTestaExplica,
        ),
        StandMission(
          id: 'mede_testa_m3',
          standId: 'mede_testa',
          number: 3,
          title: 'Corrente sob controle',
          objective: 'Abre ramo, encaixa amperímetro em série e gira potenciômetro.',
          componentsInfo: 'Resistor variável/potenciômetro, LED, amperímetro didático',
          victoryCriteria: 'Registra relação resistência/corrente.',
          failureFeedback: 'Maior resistência elétrica resulta em menor corrente no circuito (I = V / R).',
          voltsMediation: voltsMediationEstandeMedeTestaExplica,
        ),
        StandMission(
          id: 'mede_testa_m4',
          standId: 'mede_testa',
          number: 4,
          title: 'Escolha baseada em medida',
          objective: 'Troca resistores de LED, mede corrente e mantém valor seguro.',
          componentsInfo: 'Resistores de 68Ω, 680Ω e 6.8kΩ, LED, bateria 9V, amperímetro',
          victoryCriteria: 'Escolha justificada por valor medido.',
          failureFeedback: 'Selecione uma resistência que proteja a carga (10-15 mA) sem apagar o brilho.',
          voltsMediation: voltsMediationEstandeMedeTestaExplica,
        ),
        StandMission(
          id: 'mede_testa_m5',
          standId: 'mede_testa',
          number: 5,
          title: 'Caso do LED fraco',
          objective: 'Mede fonte, resistor e polaridade para distinguir causas.',
          componentsInfo: 'Circuito com LED de brilho fraco, multímetro, painel de hipóteses',
          victoryCriteria: 'Relato à banca usa evidência.',
          failureFeedback: 'Uma conclusão científica deve utilizar dados medidos com precisão para descartar hipóteses.',
          voltsMediation: voltsMediationEstandeMedeTestaExplica,
        ),
      ];
}

