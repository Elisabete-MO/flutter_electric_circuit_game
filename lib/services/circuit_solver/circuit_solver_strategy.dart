import '../../models/first_step_component.dart';
import '../../models/sandbox_component.dart';
import '../../models/sandbox_state.dart';

abstract class CircuitSolverStrategy {
  SandboxState solve(SandboxState state);
}

class CircuitElectricalSupport {
  const CircuitElectricalSupport._();

  static bool isVoltageSource(ComponentType type) {
    return switch (type) {
      ComponentType.battery ||
      ComponentType.batteryAA ||
      ComponentType.batteryPack4_5V ||
      ComponentType.powerSupply => true,
      _ => false,
    };
  }

  static bool isDiodeLike(ComponentType type) {
    return type == ComponentType.diode || type == ComponentType.led;
  }

  static double? resistanceFor(
    SandboxComponent component, {
    bool diodeOpen = false,
  }) {
    switch (component.type) {
      case ComponentType.resistor:
      case ComponentType.bulb:
      case ComponentType.lampLed:
      case ComponentType.ldrSensor:
      case ComponentType.soilMoisture:
      case ComponentType.ntcThermistor:
        return component.value <= 0 ? 0.01 : component.value;
      case ComponentType.potentiometer:
        return component.value <= 0 ? 0.01 : component.value;
      case ComponentType.motor:
        return 2.0;
      case ComponentType.buzzer:
        return 8.0;
      case ComponentType.fuse:
        return 0.1;
      case ComponentType.capacitor:
      case ComponentType.ceramicCapacitor:
        return 10.0;
      case ComponentType.switchComponent:
      case ComponentType.pushbutton:
        return component.isActive ? 0.01 : null;
      case ComponentType.diode:
        return diodeOpen ? null : 0.5;
      case ComponentType.led:
        return diodeOpen ? null : 2.0;
      default:
        return null;
    }
  }

  static bool canConduct(SandboxComponent component, {bool diodeOpen = false}) {
    return isVoltageSource(component.type) ||
        resistanceFor(component, diodeOpen: diodeOpen) != null;
  }
}
