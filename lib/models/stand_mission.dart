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
          title: 'Interruptor SPST em Série',
          objective: 'Instalar um interruptor SPST em série para controlar uma luminária.',
          componentsInfo: 'Bateria (4.5V), Interruptor SPST, Lâmpada e Fios condutores',
          victoryCriteria: 'Lâmpada responde ao interruptor (acende no estado fechado e apaga no aberto)',
          failureFeedback: 'O interruptor SPST precisa estar no caminho da corrente.',
          voltsMediation: voltsMediationEstande3,
        ),
        StandMission(
          id: 'liga_desliga_m2',
          standId: 'liga_desliga',
          number: 2,
          title: 'Previsão de Estado',
          objective: 'Prever o estado da lâmpada em dois esquemas, com chave aberta ou fechada.',
          componentsInfo: 'Circuito montado com interruptor e lâmpada',
          victoryCriteria: 'Prever corretamente os dois estados (Aberto = Interrompido, Fechado = Condução)',
          failureFeedback: 'Circuito aberto interrompe a passagem da corrente.',
          voltsMediation: voltsMediationEstande3,
        ),
        StandMission(
          id: 'liga_desliga_m3',
          standId: 'liga_desliga',
          number: 3,
          title: 'Mapeamento de Chaves Sem Etiqueta',
          objective: 'Mapear duas chaves sem etiqueta, testando uma variável por vez e registrando qual lâmpada responde.',
          componentsInfo: '2 Interruptores sem etiqueta, 2 Lâmpadas e Fonte de energia',
          victoryCriteria: 'Mapear controle-lâmpada testando uma variável por vez',
          failureFeedback: 'Teste um interruptor por vez e observe qual luz responde.',
          voltsMediation: voltsMediationEstande3,
        ),
        StandMission(
          id: 'liga_desliga_m4',
          standId: 'liga_desliga',
          number: 4,
          title: 'Correção de Desvio Paralelo',
          objective: 'Corrigir uma chave em desvio paralelo que não consegue desligar a lâmpada.',
          componentsInfo: 'Montagem com interruptor em desvio paralelo',
          victoryCriteria: 'Reposicionar a chave do desvio paralelo para o ramo principal em série com a lâmpada',
          failureFeedback: 'Essa chave em paralelo não interrompe a corrente da lâmpada.',
          voltsMediation: voltsMediationEstande3,
        ),
        StandMission(
          id: 'liga_desliga_m5',
          standId: 'liga_desliga',
          number: 5,
          title: 'Controle por Push-Button',
          objective: 'Montar um push-button para uma luz que só fica acesa enquanto o visitante o mantém pressionado.',
          componentsInfo: 'Bateria, botão de pressão (push-button), lâmpada',
          victoryCriteria: 'Luz permanece acesa apenas enquanto o visitante mantém o push-button pressionado',
          failureFeedback: 'O push-button deve manter a luz acesa apenas durante a pressão contínua.',
          voltsMediation: voltsMediationEstande3,
        ),
      ];

  static List<StandMission> get ruasMaqueteMissions => const [
        StandMission(
          id: 'ruas_maquete_m1',
          standId: 'ruas_maquete',
          number: 1,
          title: 'Primeiro Poste de Rua',
          objective: 'Montar o primeiro poste de rua.',
          componentsInfo: 'Bateria 4.5V, 1 lâmpada de poste, fios',
          victoryCriteria: 'Conectar a lâmpada do poste criando um percurso fechado contínuo com a fonte',
          failureFeedback: 'Certifique-se de conectar a lâmpada do poste entre os dois polos da fonte.',
          voltsMediation: voltsMediationEstandeRuasMaquete,
        ),
        StandMission(
          id: 'ruas_maquete_m2',
          standId: 'ruas_maquete',
          number: 2,
          title: 'Comparação Série vs Paralelo',
          objective: 'Comparar as previsões para um segundo poste em série e em paralelo: brilho e efeito de remover uma lâmpada.',
          componentsInfo: 'Circuito comutável com opções em série e em paralelo',
          victoryCriteria: 'Identificar a queda de brilho no circuito em série e a independência de brilho no paralelo',
          failureFeedback: 'Em série o brilho cai e a remoção apaga ambos; em paralelo os ramos são independentes.',
          voltsMediation: voltsMediationEstandeRuasMaquete,
        ),
        StandMission(
          id: 'ruas_maquete_m3',
          standId: 'ruas_maquete',
          number: 3,
          title: 'Manutenção da Casa da Vizinhança',
          objective: 'Manter uma casa desligada para manutenção sem apagar a vizinhança.',
          componentsInfo: 'Circuito residencial em paralelo com chaves individuais de controle',
          victoryCriteria: 'Abrir a chave da casa em manutenção mantendo as demais casas acesas',
          failureFeedback: 'Cada casa deve estar em seu próprio ramo paralelo para permitir desligamento isolado.',
          voltsMediation: voltsMediationEstandeRuasMaquete,
        ),
        StandMission(
          id: 'ruas_maquete_m4',
          standId: 'ruas_maquete',
          number: 4,
          title: 'Rede de Casas e Postes',
          objective: 'Projetar uma rede para duas casas e dois postes, com ramos independentes e retornos corretos.',
          componentsInfo: 'Fonte, 2 lâmpadas de casas, 2 lâmpadas de postes, junções de fios',
          victoryCriteria: 'Conectar 4 ramos independentes em paralelo com caminhos de retorno adequados à fonte',
          failureFeedback: 'Todos os 4 ramos precisam se conectar de forma independente à linha de retorno.',
          voltsMediation: voltsMediationEstandeRuasMaquete,
        ),
        StandMission(
          id: 'ruas_maquete_m5',
          standId: 'ruas_maquete',
          number: 5,
          title: 'Remoção de Lâmpada na Visita',
          objective: 'Remover uma lâmpada durante a visita e explicar por que os outros pontos continuam acesos.',
          componentsInfo: 'Rede do bairro em paralelo com lâmpada removível',
          victoryCriteria: 'Remover a lâmpada do soquete e comprovar a continuidade da corrente nos demais ramos',
          failureFeedback: 'Em paralelo, remover uma carga interrompe apenas aquele ramo específico.',
          voltsMediation: voltsMediationEstandeRuasMaquete,
        ),
      ];

  static List<StandMission> get letrerosLedMissions => const [
        StandMission(
          id: 'letreros_led_m1',
          standId: 'letreros_led',
          number: 1,
          title: 'Placa de Saída com LED',
          objective: 'Montar uma placa de saída com LED, resistor de 680 Ω e bateria de 9 V, respeitando polaridade.',
          componentsInfo: 'Bateria 9V, LED vermelho, Resistor 680Ω',
          victoryCriteria: 'Montar o circuito do LED com resistor de 680 Ω na polaridade correta (ânodo ao positivo)',
          failureFeedback: 'Verifique a polaridade do LED: o ânodo deve ir no positivo e a corrente precisa do resistor de 680 Ω.',
          voltsMediation: voltsMediationEstandeLetrerosLed,
        ),
        StandMission(
          id: 'letreros_led_m2',
          standId: 'letreros_led',
          number: 2,
          title: 'Hipótese do LED Invertido',
          objective: 'Formular e testar a hipótese de LED invertido em um letreiro apagado.',
          componentsInfo: 'Letreiro apagado com LED em polaridade invertida',
          victoryCriteria: 'Inverter a orientação dos terminais do LED permitindo a condução direta',
          failureFeedback: 'O LED no sentido inverso bloqueia a corrente.',
          voltsMediation: voltsMediationEstandeLetrerosLed,
        ),
        StandMission(
          id: 'letreros_led_m3',
          standId: 'letreros_led',
          number: 3,
          title: 'Escolha do Resistor Limitador',
          objective: 'Comparar 68 Ω, 680 Ω e 6,8 kΩ; prever brilho e segurança antes de escolher o resistor.',
          componentsInfo: 'Bateria 9V, LED, resistores (68Ω, 680Ω, 6.8kΩ)',
          victoryCriteria: 'Escolher o resistor de 680 Ω como a opção ideal de brilho e segurança',
          failureFeedback: '68 Ω causa risco de queima por sobrecorrente e 6.8 kΩ deixa a luz fraca demais.',
          voltsMediation: voltsMediationEstandeLetrerosLed,
        ),
        StandMission(
          id: 'letreros_led_m4',
          standId: 'letreros_led',
          number: 4,
          title: 'Letreiros Entrada e Saída Independentes',
          objective: 'Construir letreiros de Entrada e Saída independentes, cada um com LED e resistor próprios.',
          componentsInfo: '2 LEDs (Entrada e Saída), 2 resistores de 680 Ω, bateria 9V',
          victoryCriteria: 'Montar 2 ramos paralelos independentes com resistores de limitação em cada ramo',
          failureFeedback: 'Cada letreiro precisa de seu próprio resistor de limitação no ramo.',
          voltsMediation: voltsMediationEstandeLetrerosLed,
        ),
        StandMission(
          id: 'letreros_led_m5',
          standId: 'letreros_led',
          number: 5,
          title: 'Revisão de Placa Defeituosa',
          objective: 'Revisar uma placa com dois erros: polaridade e resistor inadequado.',
          componentsInfo: 'Placa defeituosa com LED verde invertido e resistor de 0 Ω no LED vermelho',
          victoryCriteria: 'Corrigir a polaridade do LED verde e substituir o resistor de 0 Ω por 680 Ω',
          failureFeedback: 'Inspecione a polaridade do LED e substitua o resistor subdimensionado antes de energizar.',
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
          title: 'Mini Ventilador com Motor CC',
          objective: 'Fazer o mini ventilador girar com motor CC e fonte.',
          componentsInfo: 'Bateria, motor CC didático com hélice',
          victoryCriteria: 'Fechar o circuito e fazer o eixo e a hélice do motor girarem',
          failureFeedback: 'Confira se ambos os terminais do motor estão conectados à fonte.',
          voltsMediation: voltsMediationEstandeMovimentoMiniatura,
        ),
        StandMission(
          id: 'movimento_miniatura_m2',
          standId: 'movimento',
          number: 2,
          title: 'Sentido do Carrinho e Inversão de Polaridade',
          objective: 'Prever o sentido de um carrinho e inverter a polaridade para fazê-lo avançar ou retornar ao ponto indicado.',
          componentsInfo: 'Bateria comutável, motor CC de tração do carrinho',
          victoryCriteria: 'Inverter os polos da fonte alterando o sentido de rotação de horário para anti-horário',
          failureFeedback: 'Inverta a polaridade para alterar o sentido do campo magnético e da rotação.',
          voltsMediation: voltsMediationEstandeMovimentoMiniatura,
        ),
        StandMission(
          id: 'movimento_miniatura_m3',
          standId: 'movimento',
          number: 3,
          title: 'Partida por Push-Button',
          objective: 'Instalar push-button para que o motor só funcione enquanto o botão estiver pressionado.',
          componentsInfo: 'Bateria, motor CC, interruptor tipo push-button',
          victoryCriteria: 'Acionar o motor mantendo o push-button pressionado e observar a interrupção ao soltar',
          failureFeedback: 'O interruptor deve interromper a rota da corrente quando solto.',
          voltsMediation: voltsMediationEstandeMovimentoMiniatura,
        ),
        StandMission(
          id: 'movimento_miniatura_m4',
          standId: 'movimento',
          number: 4,
          title: 'LED Indicador Protegido',
          objective: 'Criar um LED protegido em paralelo que indique motor energizado.',
          componentsInfo: 'Bateria, motor CC, LED indicador, resistor de 680 Ω',
          victoryCriteria: 'Conectar o ramo paralelo do LED com seu resistor de proteção em série',
          failureFeedback: 'O LED indicador em paralelo necessita de resistor de proteção em série.',
          voltsMediation: voltsMediationEstandeMovimentoMiniatura,
        ),
        StandMission(
          id: 'movimento_miniatura_m5',
          standId: 'movimento',
          number: 5,
          title: 'Diagnóstico do Mini Carrinho',
          objective: 'Diagnosticar um carrinho parado planejando testes de fonte, chave e terminais antes de reparar o mau contato.',
          componentsInfo: 'Carrinho inoperante com fiação desconectada no terminal',
          victoryCriteria: 'Localizar o ponto de interrupção e reconectar o terminal do motor',
          failureFeedback: 'Siga a sequência de testes (fonte, chave, terminais) para localizar o ponto de interrupção.',
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
          title: 'Tensão da Bateria em Paralelo',
          objective: 'Confirmar a tensão de uma bateria de 9 V com voltímetro em paralelo.',
          componentsInfo: 'Bateria 9V, voltímetro didático',
          victoryCriteria: 'Posicionar as pontas de prova nos polos da bateria no modo V DC (leitura de 9.0 V)',
          failureFeedback: 'O voltímetro deve ser conectado em paralelo com os terminais da fonte.',
          voltsMediation: voltsMediationEstandeMedeTestaExplica,
        ),
        StandMission(
          id: 'mede_testa_m2',
          standId: 'mede_testa',
          number: 2,
          title: 'Queda de Tensão na Carga',
          objective: 'Escolher os pontos certos para medir queda de tensão na carga e interpretar o valor.',
          componentsInfo: 'Bateria 9V, lâmpada de carga, voltímetro didático',
          victoryCriteria: 'Medir a diferença de potencial diretamente sobre os terminais da lâmpada',
          failureFeedback: 'Verifique exatamente entre quais dois pontos sobre a carga as pontas foram colocadas.',
          voltsMediation: voltsMediationEstandeMedeTestaExplica,
        ),
        StandMission(
          id: 'mede_testa_m3',
          standId: 'mede_testa',
          number: 3,
          title: 'Resistência Variável e Corrente',
          objective: 'Prever e observar, com amperímetro, como resistência variável altera a corrente.',
          componentsInfo: 'Resistor variável/reostato, LED, amperímetro didático',
          victoryCriteria: 'Ajustar a resistência e comprovar que o aumento da resistência diminui a corrente (I = V / R)',
          failureFeedback: 'Maior resistência elétrica resulta em menor corrente no circuito (I = V / R).',
          voltsMediation: voltsMediationEstandeMedeTestaExplica,
        ),
        StandMission(
          id: 'mede_testa_m4',
          standId: 'mede_testa',
          number: 4,
          title: 'Dimensionamento da Corrente Segura',
          objective: 'Escolher o resistor que produz brilho visível sem exceder a corrente segura do LED.',
          componentsInfo: 'Resistores de 68Ω, 680Ω e 6.8kΩ, LED, bateria 9V, amperímetro',
          victoryCriteria: 'Selecionar o resistor de 680 Ω garantindo corrente na faixa segura de 10 a 15 mA',
          failureFeedback: 'Selecione uma resistência que proteja a carga (10-15 mA) sem apagar o brilho.',
          voltsMediation: voltsMediationEstandeMedeTestaExplica,
        ),
        StandMission(
          id: 'mede_testa_m5',
          standId: 'mede_testa',
          number: 5,
          title: 'Resolução do Caso do LED Fraco',
          objective: 'Resolver o caso do LED fraco: usar medições para eliminar as hipóteses de bateria fraca, resistor alto ou LED invertido e registrar a conclusão.',
          componentsInfo: 'Circuito com LED de brilho fraco, multímetro, painel de hipóteses',
          victoryCriteria: 'Eliminar hipóteses através das medições e confirmar que o resistor de 10 kΩ causou a limitação excessiva',
          failureFeedback: 'Uma conclusão científica deve utilizar dados medidos com precisão para descartar hipóteses.',
          voltsMediation: voltsMediationEstandeMedeTestaExplica,
        ),
      ];
}

