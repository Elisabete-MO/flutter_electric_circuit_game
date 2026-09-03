import 'package:flutter/material.dart';
import 'first_step_component.dart';

/// Modelo de dados pedagógicos dos 5 componentes da Fase 1.
class Phase1ComponentData {
  final String id;
  final ComponentType type;
  final String name;
  final String plaqueName;
  final String assetPath;
  final String functionText;
  final String terminalsText;
  final String? polarityText;
  final String cautionText;
  final IconData icon;

  // Quiz
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
    required this.functionText,
    required this.terminalsText,
    this.polarityText,
    required this.cautionText,
    required this.icon,
    required this.quizQuestion,
    required this.correctAnswer,
    required this.wrongAnswers,
    required this.quizExplanation,
  });

  /// Lista exata dos 5 componentes da Fase 1 em ordem didática.
  static List<Phase1ComponentData> get defaultList => const [
        Phase1ComponentData(
          id: 'battery_9v',
          type: ComponentType.battery,
          name: 'Bateria 9 V',
          plaqueName: 'Bateria 9 V',
          assetPath: 'assets/components/battery.png',
          functionText:
              'Fornece a diferença de potencial (tensão) em corrente contínua para impulsionar os elétrons pelo circuito.',
          terminalsText:
              'Possui dois terminais superiores: o polo positivo (+) e o polo negativo (-).',
          polarityText: 'Positivo (+) e Negativo (-)',
          cautionText:
              'Nunca conecte o polo positivo diretamente ao polo negativo por um fio sem carga. Isso causa um curto-circuito!',
          icon: Icons.battery_charging_full_rounded,
          quizQuestion: 'Qual componente fornece energia ao circuito?',
          correctAnswer: 'Bateria 9 V',
          wrongAnswers: ['Resistor 680 Ω', 'Interruptor'],
          quizExplanation:
              'A Bateria 9 V é a fonte geradora de energia elétrica em corrente contínua do circuito.',
        ),
        Phase1ComponentData(
          id: 'switch_spst',
          type: ComponentType.switchComponent,
          name: 'Interruptor SPST',
          plaqueName: 'Chave SPST',
          assetPath: 'assets/components/switch_open.png',
          functionText:
              'Abre ou fecha mecanicamente o caminho condutor por onde a corrente elétrica circula.',
          terminalsText:
              'Possui dois bornes metálicos de entrada e saída. Não possui polaridade.',
          cautionText:
              'Quando aberto, interrompe a corrente. Quando fechado, permite que o circuito funcione.',
          icon: Icons.toggle_off_rounded,
          quizQuestion: 'Qual componente abre ou fecha o caminho da corrente?',
          correctAnswer: 'Interruptor SPST',
          wrongAnswers: ['Fios jumper', 'Resistor 680 Ω'],
          quizExplanation:
              'O Interruptor controla o fluxo elétrico abrindo (desligado) ou fechando (ligado) o percurso.',
        ),
        Phase1ComponentData(
          id: 'resistor_680',
          type: ComponentType.resistor,
          name: 'Resistor 680 Ω',
          plaqueName: 'Resistor 680 Ω',
          assetPath: 'assets/components/resistor.png',
          functionText:
              'Limita a intensidade da corrente elétrica que passa pelo circuito, atuando como protetor.',
          terminalsText:
              'Possui dois terminais axiais simétricos. Não possui polaridade; pode ser ligado em qualquer sentido.',
          cautionText:
              'O LED é sensível e queimará se ligado à bateria de 9 V sem um resistor de valor adequado (680 Ω).',
          icon: Icons.align_horizontal_center_rounded,
          quizQuestion:
              'Qual componente limita a corrente e protege o LED?',
          correctAnswer: 'Resistor 680 Ω',
          wrongAnswers: ['LED vermelho', 'Bateria 9 V'],
          quizExplanation:
              'O Resistor reduz a corrente para um nível seguro (~10 mA), impedindo que o LED queime.',
        ),
        Phase1ComponentData(
          id: 'led_red',
          type: ComponentType.led,
          name: 'LED vermelho',
          plaqueName: 'LED vermelho',
          assetPath: 'assets/components/led_off.png',
          functionText:
              'Emite luz eficiente quando a corrente elétrica atravessa o componente no sentido correto.',
          terminalsText:
              'LEDs são polarizados. O terminal mais longo é o ÂNODO (+) e o terminal mais curto é o CÁTODO (-).',
          polarityText: 'Ânodo (+) na perna longa, Cátodo (-) na perna curta',
          cautionText:
              'Ligue sempre no sentido correto. Se for instalado invertido, o LED não acenderá.',
          icon: Icons.lightbulb_outline_rounded,
          quizQuestion: 'Qual componente produz luz?',
          correctAnswer: 'LED vermelho',
          wrongAnswers: ['Bateria 9 V', 'Fios jumper'],
          quizExplanation:
              'O LED (Diodo Emissor de Luz) transforma a energia elétrica do circuito diretamente em iluminação.',
        ),
        Phase1ComponentData(
          id: 'connecting_wires',
          type: ComponentType.connectingWire,
          name: 'Fios de conexão',
          plaqueName: 'Fios jumper',
          assetPath: 'assets/components/wires.png',
          functionText:
              'Interligam os terminais dos componentes, criando o caminho condutor contínuo para os elétrons.',
          terminalsText:
              'Pontas condutoras flexíveis com conectores nas extremidades.',
          cautionText:
              'Garantir conexões firmes sem deixar pontas soltas ou polos opostos encostando.',
          icon: Icons.alt_route_rounded,
          quizQuestion: 'Qual elemento conecta os componentes?',
          correctAnswer: 'Fios de conexão',
          wrongAnswers: ['Bateria 9 V', 'LED vermelho'],
          quizExplanation:
              'Os fios de conexão (jumpers) fecham os elos condutores interligando todos os terminais.',
        ),
      ];
}
