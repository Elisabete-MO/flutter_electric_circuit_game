/// Tipos de componentes disponíveis nos Primeiros Passos.
enum ComponentType {
  battery,
  connectingWire,
  switchComponent,
  bulb,
  resistor,
  diode,
  led,
  motor,
  potentiometer,
  powerSupply,
  fuse,
  capacitor,
  buzzer,
}

/// Modelo que define um componente educativo para a seção de Primeiros Passos.
class FirstStepComponent {
  const FirstStepComponent({
    required this.id,
    required this.type,
    required this.namePt,
    required this.nameEn,
    required this.description,
    required this.symbolDescription,
    this.isActive = false,
    this.supportsStateToggle = false,
  });

  final String id;
  final ComponentType type;
  final String namePt;
  final String nameEn;
  final String description;
  final String symbolDescription;
  final bool isActive;
  final bool supportsStateToggle;

  FirstStepComponent copyWith({
    bool? isActive,
  }) {
    return FirstStepComponent(
      id: id,
      type: type,
      namePt: namePt,
      nameEn: nameEn,
      description: description,
      symbolDescription: symbolDescription,
      isActive: isActive ?? this.isActive,
      supportsStateToggle: supportsStateToggle,
    );
  }

  /// Lista completa dos 8 componentes da imagem de referência.
  static List<FirstStepComponent> get defaultList => const [
        FirstStepComponent(
          id: 'battery',
          type: ComponentType.battery,
          namePt: 'Bateria',
          nameEn: 'battery',
          description:
              'Fonte de energia elétrica. Fornece a diferença de potencial (tensão) para mover a corrente.',
          symbolDescription:
              'Linha longa representa o polo positivo (+), linha curta e mais espessa representa o polo negativo (-).',
          supportsStateToggle: false,
        ),
        FirstStepComponent(
          id: 'connecting_wire',
          type: ComponentType.connectingWire,
          namePt: 'Fio de conexão',
          nameEn: 'connecting wire',
          description:
              'Condutor por onde os elétrons fluem livremente, interligando os componentes do circuito.',
          symbolDescription:
              'Linhas retas indicam conexões perfeitas. O ponto escuro indica junção/nó elétrico.',
          supportsStateToggle: false,
        ),
        FirstStepComponent(
          id: 'switch',
          type: ComponentType.switchComponent,
          namePt: 'Interruptor',
          nameEn: 'electrical switch (interruptor)',
          description:
              'Dispositivo de controle que abre (desliga) ou fecha (liga) a passagem da corrente elétrica.',
          symbolDescription:
              'Linha inclinada desconectada = aberto. Linha alinhada fechando o trecho = fechado.',
          isActive: false,
          supportsStateToggle: true,
        ),
        FirstStepComponent(
          id: 'bulb',
          type: ComponentType.bulb,
          namePt: 'Lâmpada',
          nameEn: 'bulb',
          description:
              'Transforma a energia elétrica em luz (e calor). Acende quando há fluxo de corrente.',
          symbolDescription:
              'Círculo com um X no interior (ou filamento curvado) representando o filamento incandescente.',
          isActive: false,
          supportsStateToggle: true,
        ),
        FirstStepComponent(
          id: 'resistor',
          type: ComponentType.resistor,
          namePt: 'Resistor',
          nameEn: 'resistor',
          description:
              'Dificulta a passagem da corrente elétrica, limitando a intensidade e protegendo componentes.',
          symbolDescription:
              'Retângulo plano segundo a norma internacional IEC (ou linha em ziguezague no padrão ANSI).',
          supportsStateToggle: false,
        ),
        FirstStepComponent(
          id: 'diode',
          type: ComponentType.diode,
          namePt: 'Diodo',
          nameEn: 'diode',
          description:
              'Permite a passagem da corrente elétrica em apenas um sentido (anodo para catodo).',
          symbolDescription:
              'Triângulo apontando no sentido da corrente permitida, encostado em uma barra vertical que bloqueia o sentido inverso.',
          supportsStateToggle: false,
        ),
        FirstStepComponent(
          id: 'led',
          type: ComponentType.led,
          namePt: 'LED',
          nameEn: 'LED (Light-Emitting Diode)',
          description:
              'Diodo Emissor de Luz. Emite luz eficientemente quando a corrente flui no sentido correto.',
          symbolDescription:
              'Símbolo de um diodo acrescido de duas pequenas setas saindo, indicando a emissão de fótons/luz.',
          isActive: false,
          supportsStateToggle: true,
        ),
        FirstStepComponent(
          id: 'motor',
          type: ComponentType.motor,
          namePt: 'Motor',
          nameEn: 'motor',
          description:
              'Converte energia elétrica em energia mecânica de rotação.',
          symbolDescription:
              'Círculo contendo a letra "M" maiúscula no centro.',
          isActive: false,
          supportsStateToggle: true,
        ),
      ];
}
