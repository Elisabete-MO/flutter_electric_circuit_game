import 'package:flutter/material.dart';
import 'first_step_component.dart';

/// Categorias oficiais dos componentes da Bancada Livre
enum SandboxCategory {
  sources, // 🔋 1. Fontes de Energia
  loads, // 💡 2. Cargas e Atuadores
  switches, // 🎛️ 3. Chaves, Controles e Comutação
  passives, // 🛡️ 4. Componentes Passivos e de Proteção
  sensors, // 📡 5. Sensores
  tools, // 🔌 6. Ferramentas, Montagem e Medição
}

/// Item da Paleta de Componentes da Bancada Livre
class SandboxPaletteItem {
  final ComponentType type;
  final String name;
  final String unit;
  final double defaultValue;
  final SandboxCategory category;
  final String iconAsset;
  final String description;

  const SandboxPaletteItem({
    required this.type,
    required this.name,
    required this.unit,
    required this.defaultValue,
    required this.category,
    required this.iconAsset,
    required this.description,
  });
}

/// Lista completa dos componentes organizados pelas 6 categorias da Bancada Livre
const List<SandboxPaletteItem> allSandboxPaletteItems = [
  // 🔋 1. Fontes de Energia
  SandboxPaletteItem(
    type: ComponentType.batteryAA,
    name: 'Pilha AA (1.5V)',
    unit: 'V',
    defaultValue: 1.5,
    category: SandboxCategory.sources,
    iconAsset: 'assets/components-low-poly/pilha-aa-1-5v-low-poly.png',
    description: 'Pilha alcalina padrão de 1.5V para circuitos compactos.',
  ),
  SandboxPaletteItem(
    type: ComponentType.battery,
    name: 'Bateria 9V',
    unit: 'V',
    defaultValue: 9.0,
    category: SandboxCategory.sources,
    iconAsset: 'assets/components-low-poly/bateria-9v-low-poly.png',
    description: 'Bateria de 9V para alimentação geral de bancada.',
  ),
  SandboxPaletteItem(
    type: ComponentType.batteryPack4_5V,
    name: 'Bateria 4.5V (3x AA)',
    unit: 'V',
    defaultValue: 4.5,
    category: SandboxCategory.sources,
    iconAsset: 'assets/components-low-poly/pilha-aa-1-5v-low-poly.png',
    description: 'Conjunto de 3 pilhas AA em série fornecendo 4.5V.',
  ),
  SandboxPaletteItem(
    type: ComponentType.powerSupply,
    name: 'Fonte DC de Bancada',
    unit: 'V',
    defaultValue: 12.0,
    category: SandboxCategory.sources,
    iconAsset: 'assets/components-low-poly/fonte-dc-didatica-low-poly.png',
    description: 'Fonte didática regulável com ajuste fino de 0V a 24V.',
  ),

  // 💡 2. Cargas e Atuadores
  SandboxPaletteItem(
    type: ComponentType.bulb,
    name: 'Lâmpada Incandescente',
    unit: 'Ω',
    defaultValue: 5.0,
    category: SandboxCategory.loads,
    iconAsset: 'assets/components-low-poly/lampada-incandescente-desligada-low-poly.png',
    description: 'Lâmpada resistiva de filamento que brilha proporcionalmente à corrente.',
  ),
  SandboxPaletteItem(
    type: ComponentType.lampLed,
    name: 'Lâmpada LED',
    unit: 'V',
    defaultValue: 3.0,
    category: SandboxCategory.loads,
    iconAsset: 'assets/components-low-poly/lampada-led-desligada-low-poly.png',
    description: 'Lâmpada LED de alta eficiência com acendimento imediato.',
  ),
  SandboxPaletteItem(
    type: ComponentType.led,
    name: 'LED Vermelho',
    unit: 'V',
    defaultValue: 2.0,
    category: SandboxCategory.loads,
    iconAsset: 'assets/components-low-poly/led-vermelho-desligado-low-poly.png',
    description: 'Diodo Emissor de Luz com queda de 2.0V e proteção contra sobrecorrente.',
  ),
  SandboxPaletteItem(
    type: ComponentType.motor,
    name: 'Motor CC com Hélice',
    unit: 'Ω',
    defaultValue: 15.0,
    category: SandboxCategory.loads,
    iconAsset: 'assets/components-low-poly/motor-cc-helice.png',
    description: 'Motor elétrico de corrente contínua com rotação visível do rotor.',
  ),
  SandboxPaletteItem(
    type: ComponentType.buzzer,
    name: 'Buzzer / Sinalizador',
    unit: 'Ω',
    defaultValue: 8.0,
    category: SandboxCategory.loads,
    iconAsset: 'assets/components-low-poly/buzzer-low-poly.png',
    description: 'Emissor sonoro piezelétrico para alarmes e notificações.',
  ),

  // 🎛️ 3. Chaves, Controles e Comutação
  SandboxPaletteItem(
    type: ComponentType.switchComponent,
    name: 'Interruptor SPST',
    unit: 'status',
    defaultValue: 0.0,
    category: SandboxCategory.switches,
    iconAsset: 'assets/components-low-poly/chave-spst-desligado.png',
    description: 'Chave alavanca liga/desliga para abrir ou fechar o circuito.',
  ),
  SandboxPaletteItem(
    type: ComponentType.pushbutton,
    name: 'Botão Pulsador',
    unit: 'status',
    defaultValue: 0.0,
    category: SandboxCategory.switches,
    iconAsset: 'assets/components-low-poly/botao-pulsador-solto-low-poly.png',
    description: 'Botão de contato momentâneo (fecha o circuito enquanto pressionado).',
  ),
  SandboxPaletteItem(
    type: ComponentType.potentiometer,
    name: 'Potenciômetro',
    unit: 'Ω',
    defaultValue: 50.0,
    category: SandboxCategory.switches,
    iconAsset: 'assets/components-low-poly/potenciometro.png',
    description: 'Resistor variável para controle suave de brilho, som ou velocidade.',
  ),
  SandboxPaletteItem(
    type: ComponentType.relay,
    name: 'Relé Eletromecânico',
    unit: 'V',
    defaultValue: 12.0,
    category: SandboxCategory.switches,
    iconAsset: 'assets/components-low-poly/rele-low-poly.png',
    description: 'Chave eletromagnética acionada por bobina de comando.',
  ),

  // 🛡️ 4. Componentes Passivos e de Proteção
  SandboxPaletteItem(
    type: ComponentType.resistor,
    name: 'Resistor 220Ω',
    unit: 'Ω',
    defaultValue: 220.0,
    category: SandboxCategory.passives,
    iconAsset: 'assets/components-low-poly/resistor-fixo-low-poly.png',
    description: 'Resistor fixo para limitação de corrente e proteção de LEDs.',
  ),
  SandboxPaletteItem(
    type: ComponentType.fuse,
    name: 'Fusível Didático',
    unit: 'A',
    defaultValue: 2.0,
    category: SandboxCategory.passives,
    iconAsset: 'assets/components-low-poly/fusivel-didatico-low-poly.png',
    description: 'Fusível com filamento de segurança que queima sob sobrecorrente.',
  ),
  SandboxPaletteItem(
    type: ComponentType.capacitor,
    name: 'Capacitor Eletrolítico',
    unit: 'µF',
    defaultValue: 100.0,
    category: SandboxCategory.passives,
    iconAsset: 'assets/components-low-poly/capacitor-eletrolitico-low-poly.png',
    description: 'Capacitor polarizado de 100µF para armazenamento e filtragem de energia.',
  ),
  SandboxPaletteItem(
    type: ComponentType.ceramicCapacitor,
    name: 'Capacitor Cerâmico',
    unit: 'nF',
    defaultValue: 10.0,
    category: SandboxCategory.passives,
    iconAsset: 'assets/components-low-poly/capacitor-ceramico-low-poly.png',
    description: 'Capacitor cerâmico de resposta rápida.',
  ),
  SandboxPaletteItem(
    type: ComponentType.diode,
    name: 'Diodo 1N4007',
    unit: 'V',
    defaultValue: 0.7,
    category: SandboxCategory.passives,
    iconAsset: 'assets/components-low-poly/diodo-1n4007-low-poly.png',
    description: 'Semicondutor retificador que permite corrente somente em um sentido.',
  ),

  // 📡 5. Sensores
  SandboxPaletteItem(
    type: ComponentType.ldrSensor,
    name: 'Sensor LDR (Luz)',
    unit: 'Ω',
    defaultValue: 1000.0,
    category: SandboxCategory.sensors,
    iconAsset: 'assets/components-low-poly/sensor-ldr-low-poly.png',
    description: 'Fotoresistor cuja resistência varia conforme a intensidade luminosa.',
  ),
  SandboxPaletteItem(
    type: ComponentType.soilMoisture,
    name: 'Sonda de Umidade',
    unit: 'Ω',
    defaultValue: 500.0,
    category: SandboxCategory.sensors,
    iconAsset: 'assets/components-low-poly/sonda-de-solo-resistiva-low-poly.png',
    description: 'Sensor resistivo para detecção de umidade em solo ou água.',
  ),
  SandboxPaletteItem(
    type: ComponentType.ntcThermistor,
    name: 'Termistor NTC',
    unit: 'Ω',
    defaultValue: 10000.0,
    category: SandboxCategory.sensors,
    iconAsset: 'assets/components-low-poly/termistor-ntc-low-poly.png',
    description: 'Sensor resistivo de temperatura com coeficiente térmico negativo.',
  ),
  SandboxPaletteItem(
    type: ComponentType.transistorBjt,
    name: 'Transistor BJT',
    unit: 'hFE',
    defaultValue: 100.0,
    category: SandboxCategory.sensors,
    iconAsset: 'assets/components-low-poly/transistor.png',
    description: 'Componente ativo semicondutor para amplificação e chaveamento.',
  ),

  // 🔌 6. Ferramentas, Montagem e Medição
  SandboxPaletteItem(
    type: ComponentType.breadboard,
    name: 'Protoboard',
    unit: 'pts',
    defaultValue: 0.0,
    category: SandboxCategory.tools,
    iconAsset: 'assets/components-low-poly/protoboard-low-poly.png',
    description: 'Matriz de contatos para montagem rápida sem solda.',
  ),
  SandboxPaletteItem(
    type: ComponentType.multimeterTool,
    name: 'Multímetro Digital',
    unit: 'DMM',
    defaultValue: 0.0,
    category: SandboxCategory.tools,
    iconAsset: 'assets/components-low-poly/multimetro-digital-low-poly.png',
    description: 'Instrumento de medição de Tensão (V), Corrente (A) e Resistência (Ω).',
  ),
  SandboxPaletteItem(
    type: ComponentType.connectingWire,
    name: 'Conector WAGO / Fio',
    unit: 'm',
    defaultValue: 0.0,
    category: SandboxCategory.tools,
    iconAsset: 'assets/components-low-poly/conector-wago-3-vias-low-poly.png',
    description: 'Conector de derivação rápida de 3 vias para nós e junções elétricas.',
  ),
];

class SandboxComponent {
  SandboxComponent({
    required this.id,
    required this.type,
    required this.gridX,
    required this.gridY,
    this.rotation = 0.0, // Rotação em graus: 0, 90, 180, 270
    this.isActive = false, // Ex: interruptor aberto/fechado
    double? value, // Tensão para bateria, Resistência para resistores/cargas
  }) : value = value ?? _defaultValueForType(type);

  final String id;
  final ComponentType type;
  final int gridX;
  final int gridY;
  final double rotation;
  final bool isActive;
  final double value;

  static double _defaultValueForType(ComponentType type) {
    switch (type) {
      case ComponentType.battery:
        return 9.0; // 9V por padrão
      case ComponentType.batteryAA:
        return 1.5; // 1.5V pilha AA
      case ComponentType.batteryPack4_5V:
        return 4.5; // 4.5V pack 3x AA
      case ComponentType.powerSupply:
        return 12.0; // 12V regulável por padrão
      case ComponentType.resistor:
        return 220.0; // 220 Ohms por padrão
      case ComponentType.potentiometer:
        return 50.0; // 50 Ohms ajustável por padrão
      case ComponentType.bulb:
        return 5.0; // 5 Ohms
      case ComponentType.lampLed:
        return 3.0; // Lâmpada LED
      case ComponentType.motor:
        return 15.0; // 15 Ohms
      case ComponentType.led:
        return 2.0; // Queda de tensão de 2.0V
      case ComponentType.fuse:
      case ComponentType.circuitBreaker:
        return 2.0; // Limite de 2.0A antes de queimar/desarmar
      case ComponentType.capacitor:
        return 100.0; // 100 µF eletrolítico
      case ComponentType.ceramicCapacitor:
        return 10.0; // 10 nF cerâmico
      case ComponentType.buzzer:
        return 8.0; // 8 Ohms de impedância
      case ComponentType.relay:
        return 12.0; // Bobina 12V
      case ComponentType.ldrSensor:
        return 1000.0; // 1kΩ no escuro / sensível à luz
      case ComponentType.soilMoisture:
        return 500.0; // 500Ω
      case ComponentType.ntcThermistor:
        return 10000.0; // 10k NTC
      case ComponentType.transistorBjt:
        return 100.0; // Ganho hFE ~100
      default:
        return 1.0;
    }
  }

  SandboxComponent copyWith({
    String? id,
    ComponentType? type,
    int? gridX,
    int? gridY,
    double? rotation,
    bool? isActive,
    double? value,
  }) {
    return SandboxComponent(
      id: id ?? this.id,
      type: type ?? this.type,
      gridX: gridX ?? this.gridX,
      gridY: gridY ?? this.gridY,
      rotation: rotation ?? this.rotation,
      isActive: isActive ?? this.isActive,
      value: value ?? this.value,
    );
  }

  /// Retorna as coordenadas relativas dos terminais A (Entrada) e B (Saída) com base na rotação.
  /// A célula do grid tem tamanho unitário (1.0).
  Offset getTerminalAPosition() {
    final cx = gridX + 0.5;
    final cy = gridY + 0.5;

    if (rotation == 90.0) {
      return Offset(cx, cy - 0.5); // Topo
    } else if (rotation == 180.0) {
      return Offset(cx + 0.5, cy); // Direita
    } else if (rotation == 270.0) {
      return Offset(cx, cy + 0.5); // Base
    } else {
      return Offset(cx - 0.5, cy); // Esquerda
    }
  }

  Offset getTerminalBPosition() {
    final cx = gridX + 0.5;
    final cy = gridY + 0.5;

    if (rotation == 90.0) {
      return Offset(cx, cy + 0.5); // Base
    } else if (rotation == 180.0) {
      return Offset(cx - 0.5, cy); // Esquerda
    } else if (rotation == 270.0) {
      return Offset(cx, cy - 0.5); // Topo
    } else {
      return Offset(cx + 0.5, cy); // Direita
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'gridX': gridX,
      'gridY': gridY,
      'rotation': rotation,
      'isActive': isActive,
      'value': value,
    };
  }

  factory SandboxComponent.fromMap(Map<String, dynamic> map) {
    return SandboxComponent(
      id: map['id'] as String,
      type: ComponentType.values.byName(map['type'] as String),
      gridX: map['gridX'] as int,
      gridY: map['gridY'] as int,
      rotation: (map['rotation'] as num).toDouble(),
      isActive: map['isActive'] as bool,
      value: (map['value'] as num).toDouble(),
    );
  }
}
