import 'package:flutter/material.dart';
import 'first_step_component.dart';

/// Modelo de dados pedagógicos e didáticos dos 5 componentes do EletroLab.
class Phase1ComponentData {
  final String id;
  final ComponentType type;
  final String name;
  final String plaqueName;
  final String assetPath;
  final String shortDescription;
  final String function;
  final String terminals;
  final String? polarity;
  final String identification;
  final String behavior;
  final String safety;
  final String learnMore;
  final String checkQuestion;
  final String checkAnswer;
  final IconData icon;

  // Campos do Quiz de fixação
  final String quizQuestion;
  final String correctAnswer;
  final List<String> wrongAnswers;
  final String quizExplanation;

  const Phase1ComponentData({
    required this.id,
    required this.type,
    required this.name,
    required this.plaqueName,
    required this.assetPath,
    required this.shortDescription,
    required this.function,
    required this.terminals,
    this.polarity,
    required this.identification,
    required this.behavior,
    required this.safety,
    required this.learnMore,
    required this.checkQuestion,
    required this.checkAnswer,
    required this.icon,
    required this.quizQuestion,
    required this.correctAnswer,
    required this.wrongAnswers,
    required this.quizExplanation,
  });

  // Getters para compatibilidade legada
  String get functionText => function;
  String get terminalsText => terminals;
  String? get polarityText => polarity;
  String get cautionText => safety;

  /// Lista exata dos 5 componentes do EletroLab em ordem didática.
  static List<Phase1ComponentData> get defaultList => const [
        Phase1ComponentData(
          id: 'battery_9v',
          type: ComponentType.battery,
          name: 'Bateria de 9 V',
          plaqueName: 'Bateria 9 V',
          assetPath: 'assets/components/battery.png',
          shortDescription:
              'Transforma energia química em energia elétrica, fornecendo uma diferença de potencial de 9 V para mover as cargas quando o circuito está fechado.',
          function:
              'Fornece uma diferença de potencial (tensão) de 9 V, transformando energia química em energia elétrica para mover as cargas quando o circuito está fechado.',
          terminals:
              'Possui dois terminais superiores: o polo positivo (+) e o polo negativo (−).',
          polarity: 'Positivo (+) e Negativo (−)',
          identification:
              'Formato retangular com dois conectores metálicos do tipo snap na parte superior (um maior e um menor).',
          behavior:
              'A corrente convencional sai do polo positivo, atravessa o circuito externo e retorna ao polo negativo apenas se houver um caminho fechado. Nos fios metálicos, os elétrons se deslocam no sentido oposto.',
          safety:
              'Não encoste fios ou objetos metálicos diretamente nos dois polos. Isso provoca um curto-circuito e pode aquecer ou danificar a bateria.',
          learnMore:
              'Pense na bateria como uma bomba de energia: as reações químicas em seu interior separam cargas e mantêm uma diferença de potencial (tensão) de 9,0 V entre os dois polos.\n\n'
              'A bateria não "contém corrente" guardada nem envia eletricidade sozinha. Para haver fluxo de corrente, os componentes e fios devem formar uma volta completa do polo positivo ao negativo.\n\n'
              'No jogo e em diagramas técnicos, representamos a corrente convencional (do polo positivo + para o negativo −). Nos fios metálicos, os elétrons reais se deslocam no sentido oposto (do polo negativo − para o positivo +).',
          checkQuestion:
              'A bateria está conectada a um LED, mas existe uma abertura no caminho. O LED acende?',
          checkAnswer:
              'Não. A tensão existe entre os polos, porém a corrente somente percorre o circuito quando existe um caminho fechado.',
          icon: Icons.battery_charging_full_rounded,
          quizQuestion: 'Qual componente fornece a diferença de potencial (tensão) de 9 V ao circuito?',
          correctAnswer: 'Bateria de 9 V',
          wrongAnswers: ['Resistor 680 Ω', 'Interruptor SPST'],
          quizExplanation:
              'A Bateria de 9 V transforma energia química em energia elétrica, fornecendo tensão quando o circuito está fechado.',
        ),
        Phase1ComponentData(
          id: 'switch_spst',
          type: ComponentType.switchComponent,
          name: 'Interruptor SPST',
          plaqueName: 'Chave SPST',
          assetPath: 'assets/components/switch_open.png',
          shortDescription:
              'Funciona como uma porta no caminho da corrente: aberto separa os contatos e interrompe o circuito; fechado une os contatos e permite a passagem.',
          function:
              'Controla a passagem da corrente elétrica, abrindo ou fechando um único caminho elétrico. Ele não fornece energia nem gasta corrente.',
          terminals:
              'Possui dois terminais metálicos de conexão (entrada e saída).',
          polarity: 'Sem polaridade (neste circuito simples, pode ser ligado em qualquer sentido)',
          identification:
              'Componente com alavanca móvel de duas posições e dois pinos de contato metálicos na base.',
          behavior:
              'Aberto: contatos separados, caminho elétrico interrompido e corrente zerada. Fechado: contatos unidos, caminho elétrico completo e passagem de corrente permitida.',
          safety:
              'Antes de fechar o interruptor, verifique se o resistor e o LED estão montados corretamente para evitar acionamentos inseguros.',
          learnMore:
              'SPST significa Single Pole, Single Throw (um polo, uma posição): ele controla um único caminho elétrico com duas situações: aberto ou fechado.\n\n'
              'Comparação com uma porta no caminho elétrico:\n'
              '• Porta aberta no caminho elétrico: passagem interrompida (interruptor aberto = sem corrente).\n'
              '• Porta fechada fisicamente entre os contatos: caminho elétrico unido (interruptor fechado = corrente permitida).\n\n'
              'Atenção à linguagem elétrica:\n'
              '• Interruptor aberto = circuito desligado e corrente interrompida.\n'
              '• Interruptor fechado = circuito ligado e corrente permitida.',
          checkQuestion:
              'Se todos os componentes estiverem corretos, mas o interruptor estiver aberto, o que acontece?',
          checkAnswer:
              'O circuito está montado, porém os contatos estão separados e o caminho fica interrompido, mantendo o LED apagado.',
          icon: Icons.toggle_off_rounded,
          quizQuestion: 'Qual é o efeito de deixar o interruptor SPST no estado aberto?',
          correctAnswer: 'Separar os contatos e interromper a corrente',
          wrongAnswers: ['Aumentar a tensão da bateria', 'Inverter os polos do LED'],
          quizExplanation:
              'Interruptor aberto significa contatos separados e circuito interrompido.',
        ),
        Phase1ComponentData(
          id: 'resistor_680',
          type: ComponentType.resistor,
          name: 'Resistor 680 Ω',
          plaqueName: 'Resistor 680 Ω',
          assetPath: 'assets/components/resistor.png',
          shortDescription:
              'Limita a corrente elétrica e protege o LED contra corrente excessiva. A resistência é medida em ohms (Ω).',
          function:
              'Limita a intensidade da corrente elétrica no circuito para proteger componentes sensíveis como o LED. Quanto maior a resistência, menor será a corrente para a mesma tensão.',
          terminals:
              'Possui dois terminais axiais (arames metálicos retos e simétricos em cada ponta).',
          polarity: 'Sem polaridade (pode ser conectado em qualquer sentido e ficar antes ou depois do LED no circuito em série)',
          identification:
              'Corpo cilíndrico bege com faixas coloridas impressas e dois arames de conexão.',
          behavior:
              'Oferece oposição controlada à passagem de cargas. No EletroLab, com bateria de 9 V e LED de ~2 V, o valor de 680 Ω limita a corrente em aproximadamente 10,3 mA.',
          safety:
              'Nunca ligue o LED diretamente à bateria de 9 V. A corrente excessiva pode danificá-lo. Use sempre o resistor adequado em série.',
          learnMore:
              'Cálculo resolvido da corrente no EletroLab:\n'
              'I = (9 V − 2 V) ÷ 680 Ω ≈ 10,3 mA\n\n'
              'Código de cores para resistores de 4 faixas:\n'
              '1ª faixa: 1º algarismo | 2ª faixa: 2º algarismo | 3ª faixa: multiplicador | 4ª faixa: tolerância\n\n'
              'Destaque do Resistor de 680 Ω (ideal do desafio):\n'
              '• Azul = 6 (1º algarismo)\n'
              '• Cinza = 8 (2º algarismo)\n'
              '• Marrom = ×10 (multiplicador)\n'
              '• Dourado = ±5% (tolerância)\n'
              'Cálculo: 68 × 10 = 680 Ω (Azul – Cinza – Marrom – Dourado)\n\n'
              'Resistores disponíveis no desafio:\n'
              '• 68 Ω: azul – cinza – preto – dourado (corrente muito alta)\n'
              '• 680 Ω: azul – cinza – marrom – dourado (corrente adequada de ~10,3 mA)\n'
              '• 6,8 kΩ: azul – cinza – vermelho – dourado (corrente muito baixa)',
          checkQuestion:
              'Qual sequência de cores identifica o resistor de 680 Ω com 5% de tolerância?',
          checkAnswer:
              'Azul (6), Cinza (8), Marrom (×10) e Dourado (±5%), resultando em 68 × 10 = 680 Ω.',
          icon: Icons.compress_rounded,
          quizQuestion: 'Por que o resistor de 680 Ω é indispensável no circuito do EletroLab?',
          correctAnswer: 'Para limitar a corrente e proteger o LED',
          wrongAnswers: ['Para armazenar carga elétrica', 'Para fornecer 9 V de energia'],
          quizExplanation:
              'O resistor de 680 Ω limita a corrente em ~10,3 mA, protegendo o LED contra corrente excessiva.',
        ),
        Phase1ComponentData(
          id: 'led_red',
          type: ComponentType.led,
          name: 'LED vermelho',
          plaqueName: 'LED vermelho',
          assetPath: 'assets/components/led_off.png',
          shortDescription:
              'Diodo Emissor de Luz que transforma energia elétrica em iluminação. É polarizado e requer polaridade correta para conduzir.',
          function:
              'Transforma parte da energia elétrica em luz. Funciona como um diodo, permitindo a passagem da corrente principalmente do Ânodo (+) para o Cátodo (−).',
          terminals:
              'Possui dois terminais: Ânodo (positivo, perna mais longa) and Cátodo (negativo, perna mais curta e lado achatado na cápsula).',
          polarity: 'Polarizado: Ânodo (+) voltado ao polo positivo e Cátodo (−) voltado ao polo negativo',
          identification:
              'Cápsula de resina epóxi vermelha com 5 mm, duas pernas metálicas de comprimentos diferentes e um lado plano (achatado) na base.',
          behavior:
              'Orientado corretamente, acende ao fechar o circuito. Invertido (cátodo no positivo), bloqueia a corrente e permanece apagado. O LED vermelho do modelo didático apresenta aproximadamente 2 V de tensão direta.',
          safety:
              'Nunca ligue o LED diretamente à bateria de 9 V. A corrente excessiva pode danificá-lo. Use sempre o resistor adequado em série.',
          learnMore:
              'LED significa Light-Emitting Diode (Diodo Emissor de Luz).\n\n'
              'Identificação física da polaridade:\n'
              '• Ânodo (+): terminal positivo, normalmente a perna mais longa.\n'
              '• Cátodo (−): terminal negativo, normalmente a perna mais curta e marcada pelo lado achatado da cápsula.\n'
              'Observação: se as pernas tiverem sido cortadas, observe a borda achatada na base do componente, que sempre indica o cátodo.\n\n'
              'Tensão direta no EletroLab:\n'
              'O LED vermelho do modelo didático apresenta aproximadamente 2 V de queda de tensão direta. Esse é um valor aproximado adotado para o desafio.',
          checkQuestion:
              'O que acontece se o LED for conectado com o cátodo voltado para o lado positivo da bateria?',
          checkAnswer:
              'O LED permanece apagado porque a corrente fica bloqueada quando o componente está invertido.',
          icon: Icons.lightbulb_outline_rounded,
          quizQuestion: 'Como reconhecer o cátodo (terminal negativo) de um LED novo?',
          correctAnswer: 'Pela perna mais curta e lado achatado na cápsula',
          wrongAnswers: ['Pela perna mais longa', 'Pelas faixas coloridas no corpo'],
          quizExplanation:
              'O cátodo (−) do LED é identificado pela perna mais curta e pela borda plana/achatada no corpo do componente.',
        ),
        Phase1ComponentData(
          id: 'connecting_wires',
          type: ComponentType.connectingWire,
          name: 'Fios de conexão',
          plaqueName: 'Fios jumper',
          assetPath: 'assets/components/wires.png',
          shortDescription:
              'Interligam os terminais dos componentes, criando o caminho condutor contínuo para o fluxo de corrente.',
          function:
              'Conectam os terminais dos componentes e criam o caminho condutor por onde as cargas se movem. Não fornecem energia nem possuem polaridade própria.',
          terminals:
              'Extremidades metálicas condutoras (pinos machos ou fêmeas) encaixadas nos terminais dos componentes.',
          polarity: 'Sem polaridade própria (as cores dos fios são convenções de organização visual, não regras elétricas)',
          identification:
              'Cabos flexíveis encapados com plástico isolante colorido e ponteiras metálicas nas extremidades.',
          behavior:
              'Garantem a continuidade do circuito. Um fio solto ou ausente deixa o circuito aberto, impedindo a corrente. Uma ponta solta encostando em local indevido pode causar curto-circuito.',
          safety:
              'Não deixe pontas metálicas soltas e nunca faça uma ligação direta entre os polos positivo e negativo da bateria.',
          learnMore:
              'Estrutura dos fios:\n'
              'Internamente possuem um condutor metálico (geralmente cobre), excelente condutor elétrico. Externamente possuem uma camada de plástico isolante.\n\n'
              'Cores dos fios são convenções de organização:\n'
              '• Vermelho: pode representar o lado positivo (+).\n'
              '• Preto: pode representar o retorno negativo (−).\n'
              '• Outras cores: identificam diferentes trechos.\n'
              'A cor do plástico não determina eletricamente a polaridade do fio; o que determina a função do fio são os terminais aos quais ele é conectado!\n\n'
              'Continuidade:\n'
              'Existe continuidade quando há um percurso metálico completo entre os polos da fonte.',
          checkQuestion:
              'Se a capa de um fio for vermelha, ele é eletricamente diferente de um fio com capa preta?',
          checkAnswer:
              'Não. As cores são apenas convenções visuais de organização. Por dentro, ambos possuem condutores de cobre idênticos.',
          icon: Icons.alt_route_rounded,
          quizQuestion: 'Qual é a consequência de existir um fio solto ou desconectado no circuito?',
          correctAnswer: 'O circuito fica aberto e a corrente não circula',
          wrongAnswers: ['A corrente elétrica aumenta', 'O resistor altera sua resistência'],
          quizExplanation:
              'Um fio solto rompe a continuidade, deixando o circuito aberto e bloqueando a corrente.',
        ),
      ];
}

