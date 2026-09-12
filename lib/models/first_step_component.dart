/// Tipos de componentes disponíveis no jogo e na bancada livre.
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
  // Tipos estendidos para as 6 categorias da Bancada Livre
  batteryAA,
  batteryPack4_5V,
  lampLed,
  pushbutton,
  switchThreeWay,
  switchFourWay,
  relay,
  hBridge,
  masterSwitch,
  circuitBreaker,
  ceramicCapacitor,
  ldrSensor,
  soilMoisture,
  limitSwitch,
  pirSensor,
  ntcThermistor,
  transistorBjt,
  breadboard,
  multimeterTool,
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

/// Extensão para resolver os caminhos das imagens PNG realistas dos componentes.
extension ComponentTypeAssetX on ComponentType {
  /// Caminhos das imagens da seção "Primeiros Passos" (pasta assets/components/)
  String? getAssetPath(bool isActive) {
    switch (this) {
      case ComponentType.battery:
      case ComponentType.batteryAA:
      case ComponentType.batteryPack4_5V:
        return 'assets/components/battery.png';
      case ComponentType.bulb:
      case ComponentType.lampLed:
        return isActive ? 'assets/components/bulb_on.png' : 'assets/components/bulb_off.png';
      case ComponentType.switchComponent:
      case ComponentType.pushbutton:
      case ComponentType.switchThreeWay:
      case ComponentType.switchFourWay:
      case ComponentType.masterSwitch:
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
      case ComponentType.ceramicCapacitor:
        return 'assets/components/capacitor.png';
      case ComponentType.potentiometer:
        return 'assets/components/potentiometer.png';
      case ComponentType.fuse:
      case ComponentType.circuitBreaker:
        return 'assets/components/fuse.png';
      case ComponentType.buzzer:
        return 'assets/components/buzzer.png';
      case ComponentType.powerSupply:
        return 'assets/components/power_supply.png';
      case ComponentType.connectingWire:
        return 'assets/components/wires.png';
      default:
        return getLowPolyAssetPath(isActive);
    }
  }

  /// Caminhos oficiais dos modelos Low-Poly 3D (pasta assets/components-low-poly/)
  String? getLowPolyAssetPath(bool isActive) {
    switch (this) {
      case ComponentType.battery:
        return 'assets/components-low-poly/bateria-9v-low-poly.png';
      case ComponentType.batteryAA:
      case ComponentType.batteryPack4_5V:
        return 'assets/components-low-poly/pilha-aa-1-5v-low-poly.png';
      case ComponentType.powerSupply:
        return 'assets/components-low-poly/fonte-dc-didatica-low-poly.png';
      case ComponentType.bulb:
        return isActive
            ? 'assets/components-low-poly/lampada-incandescente-ligada-low-poly.png'
            : 'assets/components-low-poly/lampada-incandescente-desligada-low-poly.png';
      case ComponentType.lampLed:
        return isActive
            ? 'assets/components-low-poly/lampada-led-ligada-low-poly.png'
            : 'assets/components-low-poly/lampada-led-desligada-low-poly.png';
      case ComponentType.led:
        return isActive
            ? 'assets/components-low-poly/led-vermelho-ligado-low-poly.png'
            : 'assets/components-low-poly/led-vermelho-desligado-low-poly.png';
      case ComponentType.motor:
        return 'assets/components-low-poly/motor-cc-helice.png';
      case ComponentType.buzzer:
        return 'assets/components-low-poly/buzzer-low-poly.png';
      case ComponentType.switchComponent:
      case ComponentType.masterSwitch:
        return isActive
            ? 'assets/components-low-poly/chave-spst-ligado.png'
            : 'assets/components-low-poly/chave-spst-desligado.png';
      case ComponentType.pushbutton:
      case ComponentType.limitSwitch:
        return isActive
            ? 'assets/components-low-poly/botao-pulsador-pressionado-low-poly.png'
            : 'assets/components-low-poly/botao-pulsador-solto-low-poly.png';
      case ComponentType.potentiometer:
        return 'assets/components-low-poly/potenciometro.png';
      case ComponentType.relay:
      case ComponentType.switchThreeWay:
      case ComponentType.switchFourWay:
      case ComponentType.hBridge:
        return 'assets/components-low-poly/rele-low-poly.png';
      case ComponentType.resistor:
        return 'assets/components-low-poly/resistor-fixo-low-poly.png';
      case ComponentType.fuse:
      case ComponentType.circuitBreaker:
        return 'assets/components-low-poly/fusivel-didatico-low-poly.png';
      case ComponentType.capacitor:
        return 'assets/components-low-poly/capacitor-eletrolitico-low-poly.png';
      case ComponentType.ceramicCapacitor:
        return 'assets/components-low-poly/capacitor-ceramico-low-poly.png';
      case ComponentType.diode:
        return 'assets/components-low-poly/diodo-1n4007-low-poly.png';
      case ComponentType.ldrSensor:
        return 'assets/components-low-poly/sensor-ldr-low-poly.png';
      case ComponentType.soilMoisture:
        return 'assets/components-low-poly/sonda-de-solo-resistiva-low-poly.png';
      case ComponentType.ntcThermistor:
        return 'assets/components-low-poly/termistor-ntc-low-poly.png';
      case ComponentType.transistorBjt:
        return 'assets/components-low-poly/transistor.png';
      case ComponentType.breadboard:
        return 'assets/components-low-poly/protoboard-low-poly.png';
      case ComponentType.multimeterTool:
        return 'assets/components-low-poly/multimetro-digital-low-poly.png';
      case ComponentType.connectingWire:
        return 'assets/components-low-poly/conector-wago-3-vias-low-poly.png';
      default:
        return getAssetPath(isActive);
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
        return getLowPolyAssetPath(isActive) ?? getAssetPath(isActive);
    }
  }
}
