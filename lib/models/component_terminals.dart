import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'first_step_component.dart';

/// Posição de um terminal elétrico relativa ao centro do componente.
class ComponentTerminal {
  final Offset offset;
  final String label;

  const ComponentTerminal({required this.offset, required this.label});
}

/// Terminais de cada tipo de componente (em rotação 0°).
/// Coordenadas relativas ao centro do componente no canvas físico.
final Map<ComponentType, List<ComponentTerminal>> componentTerminals = {
  ComponentType.battery: [
    ComponentTerminal(offset: Offset(-7.5, -25.0), label: '+'),
    ComponentTerminal(offset: Offset(7.5, -25.0), label: '-'),
  ],
  ComponentType.switchComponent: [
    ComponentTerminal(offset: Offset(-32, 0), label: 'A'),
    ComponentTerminal(offset: Offset(32, 0), label: 'B'),
  ],
  ComponentType.bulb: [
    ComponentTerminal(offset: Offset(-7, 24), label: 'A'),
    ComponentTerminal(offset: Offset(7, 24), label: 'B'),
  ],
  ComponentType.motor: [
    ComponentTerminal(offset: Offset(-32, 0), label: '+'),
    ComponentTerminal(offset: Offset(32, 0), label: '-'),
  ],
  ComponentType.led: [
    ComponentTerminal(offset: Offset(-6, 24), label: 'A'),
    ComponentTerminal(offset: Offset(6, 24), label: 'K'),
  ],
  ComponentType.resistor: [
    ComponentTerminal(offset: Offset(-34, 0), label: 'A'),
    ComponentTerminal(offset: Offset(34, 0), label: 'B'),
  ],
  ComponentType.diode: [
    ComponentTerminal(offset: Offset(-34, 0), label: 'A'),
    ComponentTerminal(offset: Offset(34, 0), label: 'K'),
  ],
  ComponentType.capacitor: [
    ComponentTerminal(offset: Offset(-18, 0), label: '+'),
    ComponentTerminal(offset: Offset(18, 0), label: '-'),
  ],
  ComponentType.fuse: [
    ComponentTerminal(offset: Offset(-34, 0), label: 'A'),
    ComponentTerminal(offset: Offset(34, 0), label: 'B'),
  ],
  ComponentType.buzzer: [
    ComponentTerminal(offset: Offset(-26, 0), label: '+'),
    ComponentTerminal(offset: Offset(26, 0), label: '-'),
  ],
  ComponentType.potentiometer: [
    ComponentTerminal(offset: Offset(-28, 10), label: 'A'),
    ComponentTerminal(offset: Offset(28, 10), label: 'B'),
    ComponentTerminal(offset: Offset(0, -28), label: 'W'),
  ],
  ComponentType.powerSupply: [
    ComponentTerminal(offset: Offset(-35, 0), label: '-'),
    ComponentTerminal(offset: Offset(35, 0), label: '+'),
  ],
};

/// Rotaciona um offset baseado no ângulo em graus.
Offset rotateTerminalOffset(Offset offset, double rotationDegrees) {
  final angle = rotationDegrees * math.pi / 180.0;
  return Offset(
    offset.dx * math.cos(angle) - offset.dy * math.sin(angle),
    offset.dx * math.sin(angle) + offset.dy * math.cos(angle),
  );
}

/// Retorna a posição absoluta de um terminal no canvas.
Offset getTerminalPosition({
  required Offset componentCenter,
  required ComponentType componentType,
  required int terminalIndex,
  required double rotationDegrees,
}) {
  final terminals = componentTerminals[componentType];
  if (terminals == null || terminalIndex >= terminals.length) {
    return componentCenter;
  }
  final terminal = terminals[terminalIndex];
  final rotatedOffset = rotateTerminalOffset(terminal.offset, rotationDegrees);
  return componentCenter + rotatedOffset;
}
