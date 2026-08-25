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
      case ComponentType.resistor:
        return 10.0; // 10 Ohms
      case ComponentType.bulb:
        return 5.0; // 5 Ohms
      case ComponentType.motor:
        return 15.0; // 15 Ohms
      case ComponentType.led:
        return 2.0; // Queda de tensão de 2.0V
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
