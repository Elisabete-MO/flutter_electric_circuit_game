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

  static List<StandMission> get ruasMaqueteMissions => const [
        StandMission(
          id: 'ruas_maquete_m1',
          standId: 'ruas_maquete',
          number: 1,
          title: 'Postes em Série',
          objective: 'Conectar 2 lâmpadas na mesma rota em série.',
          componentsInfo: 'Bateria, 2 lâmpadas, fios',
          victoryCriteria: 'Conectar 2 lâmpadas na mesma rota contínua em série',
          failureFeedback: 'Há apenas uma rota contínua para as duas lâmpadas.',
          voltsMediation: voltsMediationEstandeRuasMaquete,
        ),
        StandMission(
          id: 'ruas_maquete_m2',
          standId: 'ruas_maquete',
          number: 2,
          title: 'Comparação de Brilho',
          objective: 'Analisar o circuito em série com 1 vs 2 lâmpadas e identificar o motivo da redução de brilho.',
          componentsInfo: 'Circuito em série comutável (1 ou 2 lâmpadas)',
          victoryCriteria: 'Medir/observar a queda de brilho e selecionar a razão física correta',
          failureFeedback: 'Adicionar cargas em série reduz a corrente disponível para cada uma.',
          voltsMediation: voltsMediationEstandeRuasMaquete,
        ),
        StandMission(
          id: 'ruas_maquete_m3',
          standId: 'ruas_maquete',
          number: 3,
          title: 'Bifurcação de Fios',
          objective: 'Criar um ponto de junção (nó) para dividir o percurso da corrente.',
          componentsInfo: 'Junção de fiação, 2 lâmpadas, bateria',
          victoryCriteria: 'Criar um ponto de junção (nó) para dividir e reconectar o percurso ao polo negativo',
          failureFeedback: 'A bifurcação precisa se reconectar ao polo negativo da fonte.',
          voltsMediation: voltsMediationEstandeRuasMaquete,
        ),
        StandMission(
          id: 'ruas_maquete_m4',
          standId: 'ruas_maquete',
          number: 4,
          title: 'Casas Independentes (Paralelo)',
          objective: 'Conectar 2 lâmpadas em paralelo para que cada uma tenha seu ramo próprio.',
          componentsInfo: '2 lâmpadas em paralelo, bateria, fios',
          victoryCriteria: 'Ambas as lâmpadas acesas com brilho total em ramos próprios',
          failureFeedback: 'Cada ramo deve ter seu caminho individual até a bateria.',
          voltsMediation: voltsMediationEstandeRuasMaquete,
        ),
        StandMission(
          id: 'ruas_maquete_m5',
          standId: 'ruas_maquete',
          number: 5,
          title: 'Teste de Manutenção do Bairro',
          objective: 'Simular defeito em um dos ramos e verificar a independência do circuito em paralelo.',
          componentsInfo: 'Circuito em paralelo com simulação de defeito',
          victoryCriteria: 'Desconectar uma lâmpada e comprovar que a outra permanece acesa',
          failureFeedback: 'Em paralelo, os ramos funcionam de forma independente.',
          voltsMediation: voltsMediationEstandeRuasMaquete,
        ),
      ];

  static List<StandMission> get letrerosLedMissions => const [
        StandMission(
          id: 'letreros_led_m1',
          standId: 'letreros_led',
          number: 1,
          title: 'Polaridade do LED',
          objective: 'Conectar o LED vermelho na orientação correta de ânodo (+) e cátodo (-).',
          componentsInfo: 'Bateria 9V, LED vermelho, Resistor 680Ω',
          victoryCriteria: 'Conectar o LED respeitando a orientação ânodo (+) e cátodo (-)',
          failureFeedback: 'Verifique a polaridade do LED: a corrente só passa em um sentido.',
          voltsMediation: voltsMediationEstandeLetrerosLed,
        ),
        StandMission(
          id: 'letreros_led_m2',
          standId: 'letreros_led',
          number: 2,
          title: 'Diagnóstico de LED Invertido',
          objective: 'Identificar por que o LED não acende e inverter os seus terminais.',
          componentsInfo: 'Circuito montado sem brilho (LED invertido)',
          victoryCriteria: 'Identificar a inversão de polaridade do LED e inverter seus terminais',
          failureFeedback: 'O LED no sentido inverso bloqueia a corrente.',
          voltsMediation: voltsMediationEstandeLetrerosLed,
        ),
        StandMission(
          id: 'letreros_led_m3',
          standId: 'letreros_led',
          number: 3,
          title: 'Resistor Limitador de Corrente',
          objective: 'Escolher e posicionar o resistor em série adequado para evitar sobrecorrente.',
          componentsInfo: 'Bateria 9V, LED, resistores variados (0Ω, 220Ω, 680Ω, 10kΩ)',
          victoryCriteria: 'Escolher e posicionar o resistor em série adequado (680Ω) para proteção de corrente',
          failureFeedback: 'Sem resistor de limitação, o LED receberá corrente excessiva!',
          voltsMediation: voltsMediationEstandeLetrerosLed,
        ),
        StandMission(
          id: 'letreros_led_m4',
          standId: 'letreros_led',
          number: 4,
          title: 'Painel de Sinalização Dupla',
          objective: 'Montar dois ramos em paralelo, cada um com seu LED e resistor protetor dedicado.',
          componentsInfo: '2 LEDs (Verde e Vermelho), 2 resistores (680Ω), Bateria',
          victoryCriteria: 'Montar dois ramos em paralelo, cada um com seu LED e resistor protetor',
          failureFeedback: 'Cada LED precisa de proteção adequada em seu ramo.',
          voltsMediation: voltsMediationEstandeLetrerosLed,
        ),
        StandMission(
          id: 'letreros_led_m5',
          standId: 'letreros_led',
          number: 5,
          title: 'Revisão do Letreiro Defeituoso',
          objective: 'Inspecionar a placa com 2 erros de montagem e corrigir a polaridade e a resistência.',
          componentsInfo: 'Placa de sinalização com 2 erros de montagem',
          victoryCriteria: 'Corrigir a polaridade de um LED e o resistor subdimensionado',
          failureFeedback: 'Inspecione a polaridade e os valores de resistência antes de energizar.',
          voltsMediation: voltsMediationEstandeLetrerosLed,
        ),
      ];

  /// Fala oficial de mediação do Professor Volts para o Estande "Movimento em Miniatura"
  static const String voltsMediationEstandeMovimentoMiniatura =
      'Luz e movimento são formas diferentes de energia geradas pela corrente elétrica. Vamos explorar o motor CC.';

  static List<StandMission> get movimentoMiniaturaMissions => const [
        StandMission(
          id: 'movimento_miniatura_m1',
          standId: 'movimento_miniatura',
          number: 1,
          title: 'Primeiro Giro do Motor',
          objective: 'Conectar o motor CC à fonte de alimentação didática.',
          componentsInfo: 'Bateria, motor CC didático',
          victoryCriteria: 'Fechar o circuito e fazer o eixo do motor girar',
          failureFeedback: 'Confira se ambos os terminais do motor estão conectados.',
          voltsMediation: voltsMediationEstandeMovimentoMiniatura,
        ),
        StandMission(
          id: 'movimento_miniatura_m2',
          standId: 'movimento_miniatura',
          number: 2,
          title: 'Inversão de Sentido de Rotação',
          objective: 'Inverter a polaridade da fonte para alterar o sentido de giro do motor (horário/anti-horário).',
          componentsInfo: 'Bateria, motor CC',
          victoryCriteria: 'Inverter os polos da fonte para mudar o sentido de giro (horário/anti-horário)',
          failureFeedback: 'Inverta a polaridade para alterar o sentido do campo magnético.',
          voltsMediation: voltsMediationEstandeMovimentoMiniatura,
        ),
        StandMission(
          id: 'movimento_miniatura_m3',
          standId: 'movimento_miniatura',
          number: 3,
          title: 'Botão de Partida do Motor',
          objective: 'Controlar o acionamento do motor utilizando um interruptor de pressão (push-button).',
          componentsInfo: 'Bateria, motor CC, interruptor tipo push-button',
          victoryCriteria: 'Controlar o acionamento do motor via botão de pressão',
          failureFeedback: 'O interruptor deve interromper a rota da corrente quando solto.',
          voltsMediation: voltsMediationEstandeMovimentoMiniatura,
        ),
        StandMission(
          id: 'movimento_miniatura_m4',
          standId: 'movimento_miniatura',
          number: 4,
          title: 'Painel com LED Indicador',
          objective: 'Conectar um LED com resistor em paralelo ao motor para sinalizar visualmente a operação.',
          componentsInfo: 'Bateria, motor CC, LED, resistor',
          victoryCriteria: 'Montar LED indicador em paralelo ao motor para sinalizar funcionamento',
          failureFeedback: 'O LED indicador também necessita de resistor de proteção.',
          voltsMediation: voltsMediationEstandeMovimentoMiniatura,
        ),
        StandMission(
          id: 'movimento_miniatura_m5',
          standId: 'movimento_miniatura',
          number: 5,
          title: 'Diagnóstico do Mini Carrinho',
          objective: 'Inspecionar um carrinho com motor travado e reparar o ponto de mau contato elétrico.',
          componentsInfo: 'Protótipo com motor travado',
          victoryCriteria: 'Descobrir mau contato nos terminais do motor e reparar a fiação',
          failureFeedback: 'Teste a fonte, a fiação e o interruptor para achar a interrupção.',
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
          title: 'Medindo Tensão da Bateria',
          objective: 'Posicionar pontas de prova nos polos da bateria e ler a tensão correta.',
          componentsInfo: 'Bateria 9V, voltímetro didático',
          victoryCriteria: 'Posicionar pontas de prova nos polos da bateria e ler a tensão correta (9.0V)',
          failureFeedback: 'O voltímetro deve ser conectado em paralelo com os pontos de medição.',
          voltsMediation: voltsMediationEstandeMedeTestaExplica,
        ),
        StandMission(
          id: 'mede_testa_m2',
          standId: 'mede_testa',
          number: 2,
          title: 'Queda de Tensão no Circuito',
          objective: 'Medir a diferença de potencial sobre a carga e interpretar a leitura.',
          componentsInfo: 'Bateria 9V, lâmpada, voltímetro',
          victoryCriteria: 'Medir a diferença de potencial sobre a carga e interpretar a leitura',
          failureFeedback: 'Verifique exatamente entre quais dois pontos as pontas foram colocadas.',
          voltsMediation: voltsMediationEstandeMedeTestaExplica,
        ),
        StandMission(
          id: 'mede_testa_m3',
          standId: 'mede_testa',
          number: 3,
          title: 'Resistência e Corrente',
          objective: 'Variar a resistência do circuito e observar o impacto direto na corrente medida.',
          componentsInfo: 'Resistor variável, LED, amperímetro',
          victoryCriteria: 'Variar a resistência e observar o impacto direto na corrente medida (I = V / R)',
          failureFeedback: 'Maior resistência elétrica resulta em menor corrente no circuito.',
          voltsMediation: voltsMediationEstandeMedeTestaExplica,
        ),
        StandMission(
          id: 'mede_testa_m4',
          standId: 'mede_testa',
          number: 4,
          title: 'Dimensionamento Seguro',
          objective: 'Selecionar o resistor ideal que garante corrente segura entre 10mA e 15mA.',
          componentsInfo: 'Resistores de 68Ω, 680Ω e 6.8kΩ, LED, bateria 9V',
          victoryCriteria: 'Selecionar o resistor que garante corrente ideal (~10mA a 15mA)',
          failureFeedback: 'Selecione uma resistência que proteja a carga sem apagar o brilho.',
          voltsMediation: voltsMediationEstandeMedeTestaExplica,
        ),
        StandMission(
          id: 'mede_testa_m5',
          standId: 'mede_testa',
          number: 5,
          title: 'Diário de Investigação',
          objective: 'Diagnosticar a falha no circuito por medição e registrar a conclusão científica.',
          componentsInfo: 'Circuito com LED fraco, painel de relatório',
          victoryCriteria: 'Identificar a causa da falha por medições e registrar o relatório final',
          failureFeedback: 'Uma conclusão científica deve utilizar dados medidos com precisão.',
          voltsMediation: voltsMediationEstandeMedeTestaExplica,
        ),
      ];
}

