/// Modelo de dados para os pontos de inspeção da Fase 2 do Segundo Estande.
library;

enum InspectionScenario {
  correct,
  reversedLed,
  missingResistor,
  incorrectResistor,
  openCircuit,
}

class InspectionPointData {
  final int id;
  final String title;
  final String description;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;

  const InspectionPointData({
    required this.id,
    required this.title,
    required this.description,
    required this.question,
    required this.options,
    this.correctOptionIndex = 0,
    required this.explanation,
  });

  static List<InspectionPointData> getPointsForScenario(InspectionScenario scenario) {
    return [
      const InspectionPointData(
        id: 1,
        title: 'Polos da Bateria',
        description: 'Verificação da bateria de 9 V e polaridade dos terminais.',
        question: 'Os polos positivo (+) e negativo (-) foram utilizados corretamente sem curto-circuito?',
        options: [
          'Sim, a conexão entre os polos e a malha está correta.',
          'Não, há ligação direta entre os dois polos (+ e -).',
        ],
        correctOptionIndex: 0,
        explanation: 'A bateria de 9 V fornece tensão em corrente contínua. Os fios conectam o polo positivo ao circuito e retornam ao negativo.',
      ),
      InspectionPointData(
        id: 2,
        title: 'Valor do Resistor',
        description: 'Verificação da presença e valor ôhmico do resistor.',
        question: scenario == InspectionScenario.missingResistor
            ? 'O resistor de proteção está instalado no percurso da corrente?'
            : (scenario == InspectionScenario.incorrectResistor
                ? 'O resistor instalado (68 Ω) é adequado para proteger o LED em 9 V?'
                : 'O resistor de 680 Ω é adequado para proteger o LED em 9 V?'),
        options: scenario == InspectionScenario.missingResistor
            ? [
                'Sim, o circuito funciona com segurança sem resistor.',
                'Não, o resistor está ausente no percurso do circuito.',
              ]
            : (scenario == InspectionScenario.incorrectResistor
                ? [
                    'Sim, a resistência de 68 Ω é adequada.',
                    'Não, 68 Ω é um valor muito baixo que causará sobrecorrente.',
                  ]
                : [
                    'Sim, ele limita a corrente em aproximadamente 10,3 mA.',
                    'Não, o resistor possui valor ôhmico inadequado.',
                  ]),
        correctOptionIndex: (scenario == InspectionScenario.missingResistor ||
                scenario == InspectionScenario.incorrectResistor)
            ? 1
            : 0,
        explanation: scenario == InspectionScenario.missingResistor
            ? 'Sem o resistor de 680 Ω, a tensão de 9 V causaria corrente excessiva e danificaria o LED.'
            : (scenario == InspectionScenario.incorrectResistor
                ? 'Um resistor de apenas 68 Ω permite corrente de ~100 mA, o que danifica o LED.'
                : 'O resistor de 680 Ω limita a corrente em 10,3 mA para a fonte de 9 V, garantindo vida útil ao LED.'),
      ),
      InspectionPointData(
        id: 3,
        title: 'Polaridade do LED',
        description: 'Inspeção da orientação dos terminais Ânodo (+) e Cátodo (-).',
        question: 'O LED está ligado no sentido correto (Ânodo ao +, Cátodo ao -)?',
        options: scenario == InspectionScenario.reversedLed
            ? [
                'Sim, o LED está ligado no sentido correto.',
                'Não, o LED está com polaridade invertida (Cátodo no +).',
              ]
            : [
                'Sim, o Ânodo (perna longa) está no lado positivo.',
                'Não, o LED está montado com polaridade invertida.',
              ],
        correctOptionIndex: scenario == InspectionScenario.reversedLed ? 1 : 0,
        explanation: 'O LED é um componente polarizado: a corrente só flui do Ânodo (+) para o Cátodo (-).',
      ),
      const InspectionPointData(
        id: 4,
        title: 'Estado do Interruptor',
        description: 'Inspeção do mecanismo de abertura e fechamento do circuito.',
        question: 'Qual é o estado atual do interruptor SPST antes de energizar?',
        options: [
          'Aberto (circuito desligado, sem circulação de corrente).',
          'Fechado (circuito energizado e operando).',
        ],
        correctOptionIndex: 0,
        explanation: 'Antes da inspeção ser concluída, o interruptor SPST deve permanecer aberto para garantir uma avaliação segura.',
      ),
      InspectionPointData(
        id: 5,
        title: 'Continuidade dos Fios',
        description: 'Inspeção dos condutores e integridade da malha elétrica.',
        question: 'Existe um percurso elétrico contínuo entre os dois polos da bateria?',
        options: scenario == InspectionScenario.openCircuit
            ? [
                'Sim, existe continuidade completa na malha.',
                'Não, existe uma desconexão visível no condutor.',
              ]
            : [
                'Sim, todos os fios e terminais estão conectados.',
                'Não, existe um segmento de fio desconectado.',
              ],
        correctOptionIndex: scenario == InspectionScenario.openCircuit ? 1 : 0,
        explanation: 'Para a corrente elétrica circular, é indispensável haver um caminho fechado e contínuo do polo positivo ao negativo.',
      ),
    ];
  }
}
