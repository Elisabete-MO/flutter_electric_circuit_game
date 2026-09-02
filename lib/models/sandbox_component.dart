import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'first_step_component.dart';

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
      case ComponentType.powerSupply:
        return 12.0; // 12V regulável por padrão
      case ComponentType.resistor:
        return 220.0; // 220 Ohms por padrão (valor seguro para proteção de LEDs)
      case ComponentType.potentiometer:
        return 50.0; // 50 Ohms ajustável por padrão
      case ComponentType.bulb:
        return 5.0; // 5 Ohms
      case ComponentType.motor:
        return 15.0; // 15 Ohms
      case ComponentType.led:
        return 2.0; // Queda de tensão de 2.0V
      case ComponentType.fuse:
        return 2.0; // Limite de 2.0A antes de queimar
      case ComponentType.capacitor:
        return 100.0; // 100 µF
      case ComponentType.buzzer:
        return 8.0; // 8 Ohms de impedância
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

  /// Retorna os terminais disponíveis baseados no tipo do componente
  List<String> get availableTerminals {
    if (type == ComponentType.relay) {
      return ['C1', 'C2', 'COM', 'NO', 'NC'];
    }
    return ['A', 'B'];
  }

  /// Retorna as conexões internas possíveis para um dado terminal de entrada.
  List<String> getInternalConnections(String inputTerminal) {
    if (type == ComponentType.relay) {
      if (inputTerminal == 'C1') return ['C2'];
      if (inputTerminal == 'C2') return ['C1'];
      if (isActive) {
        if (inputTerminal == 'COM') return ['NO'];
        if (inputTerminal == 'NO') return ['COM'];
      } else {
        if (inputTerminal == 'COM') return ['NC'];
        if (inputTerminal == 'NC') return ['COM'];
      }
      return [];
    }

    // Padrão 2 terminais
    if (inputTerminal == 'A') return ['B'];
    if (inputTerminal == 'B') return ['A'];
    return [];
  }

  /// Retorna a posição relativa de um terminal específico com base na rotação.
  Offset getTerminalPosition(String terminalId) {
    Offset baseOffset = Offset.zero;

    if (type == ComponentType.relay) {
      switch (terminalId) {
        case 'C1': baseOffset = const Offset(-0.5, -0.25); break;
        case 'C2': baseOffset = const Offset(-0.5, 0.25); break;
        case 'COM': baseOffset = const Offset(0.5, 0.0); break;
        case 'NO': baseOffset = const Offset(0.5, -0.35); break;
        case 'NC': baseOffset = const Offset(0.5, 0.35); break;
        default: baseOffset = const Offset(0.0, 0.0);
      }
    } else {
      switch (terminalId) {
        case 'A': baseOffset = const Offset(-0.5, 0.0); break;
        case 'B': baseOffset = const Offset(0.5, 0.0); break;
        default: baseOffset = const Offset(0.0, 0.0);
      }
    }

    // Rotacionar em torno do centro (0, 0) local
    final rad = rotation * math.pi / 180.0;
    final dx = baseOffset.dx;
    final dy = baseOffset.dy;
    
    // Tratando imprecisões de ponto flutuante para ângulos ortogonais perfeitos
    double rotX = dx * math.cos(rad) - dy * math.sin(rad);
    double rotY = dx * math.sin(rad) + dy * math.cos(rad);
    
    rotX = (rotX * 1000).roundToDouble() / 1000;
    rotY = (rotY * 1000).roundToDouble() / 1000;

    final cx = gridX + 0.5;
    final cy = gridY + 0.5;

    return Offset(cx + rotX, cy + rotY);
  }

  // Deprecated compatibilidade (serão atualizados logo nas outras classes)
  Offset getTerminalAPosition() => getTerminalPosition('A');
  Offset getTerminalBPosition() => getTerminalPosition('B');

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
