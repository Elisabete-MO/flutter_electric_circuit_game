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
  relay,
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
        FirstStepComponent(
          id: 'relay',
          type: ComponentType.relay,
          namePt: 'Relê',
          nameEn: 'Relay',
          description:
              'Chave eletromecânica operada por uma bobina. A corrente em um circuito controla a passagem de corrente em outro circuito.',
          symbolDescription:
              'Um símbolo de bobina acoplado por uma linha tracejada a uma chave seletora com terminais normalmente aberto (NO) e normalmente fechado (NC).',
          isActive: false,
          supportsStateToggle: false,
        ),
      ];
}

/// Extensão para resolver os caminhos das imagens PNG realistas dos componentes.
extension ComponentTypeAssetX on ComponentType {
  /// Caminhos das imagens da seção "Primeiros Passos" (pasta assets/components/)
  String? getAssetPath(bool isActive) {
    switch (this) {
      case ComponentType.battery:
        return 'assets/components/battery.png';
      case ComponentType.bulb:
        return isActive ? 'assets/components/bulb_on.png' : 'assets/components/bulb_off.png';
      case ComponentType.switchComponent:
        return isActive ? 'assets/components/switch_closed.png' : 'assets/components/switch_open.png';
      case ComponentType.resistor:
        return 'assets/components/resistor.png';
      case ComponentType.diode:
        return 'assets/components/diode.png';
      case ComponentType.led:
        return isActive ? 'assets/components/led_on.png' : 'assets/components/led_off.png';
      case ComponentType.motor:
        return 'assets/components/motor.png';
      case ComponentType.capacitor:
        return 'assets/components/capacitor.png';
      case ComponentType.potentiometer:
        return 'assets/components/potentiometer.png';
      case ComponentType.fuse:
        return 'assets/components/fuse.png';
      case ComponentType.buzzer:
        return 'assets/components/buzzer.png';
      case ComponentType.relay:
        return 'assets/components/relay.png';
      case ComponentType.powerSupply:
        return 'assets/components/power_supply.png';
      case ComponentType.connectingWire:
        return 'assets/components/wires.png';
    }
  }

  /// Caminhos das imagens da bancada de desafios (com bornes de laboratório calibrados)
  String? getChallengeAssetPath(bool isActive) {
    switch (this) {
      case ComponentType.battery:
        return 'assets/images/component_battery_horizontal.png';
      case ComponentType.bulb:
        return isActive ? 'assets/images/component_bulb_on.png' : 'assets/images/component_bulb_off.png';
      case ComponentType.switchComponent:
        return isActive ? 'assets/images/component_switch_on.png' : 'assets/images/component_switch_off.png';
      case ComponentType.resistor:
        return 'assets/images/component_resistor.png';
      case ComponentType.diode:
        return 'assets/images/component_diode.png';
      case ComponentType.led:
        return isActive ? 'assets/images/component_led_on.png' : 'assets/images/component_led_off.png';
      case ComponentType.motor:
        return 'assets/images/component_motor.png';
      default:
        return getAssetPath(isActive);
    }
  }
}
