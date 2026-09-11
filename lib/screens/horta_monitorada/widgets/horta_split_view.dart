import 'package:flutter/material.dart';
import 'horta_circuit_painter.dart';
import 'horta_top_down_painter.dart';

/// Widget integrado que apresenta a Bancada de Circuito e a Maquete Top-Down lado a lado.
class HortaSplitView extends StatelessWidget {
  final int missionIndex;
  final double animValue;
  final bool usePhysicalStyle;
  final bool isSwitchClosed;
  final double potentiometerValue;
  final double soilMoisture;
  final bool isFanActive;
  final bool isIrrigating;
  final bool isMasterActive;

  const HortaSplitView({
    super.key,
    required this.missionIndex,
    required this.animValue,
    this.usePhysicalStyle = true,
    this.isSwitchClosed = true,
    this.potentiometerValue = 0.8,
    this.soilMoisture = 0.7,
    this.isFanActive = true,
    this.isIrrigating = false,
    this.isMasterActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Painel Esquerdo: Circuito Elétrico
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: CustomPaint(
                    painter: HortaCircuitPainter(
                      missionIndex: missionIndex,
                      animValue: animValue,
                      usePhysicalStyle: usePhysicalStyle,
                      isSwitchClosed: isSwitchClosed,
                      potentiometerValue: potentiometerValue,
                      soilMoistureLevel: soilMoisture,
                    ),
                  ),
                ),
              ),

              // Painel Direito: Maquete Vetorial Top-Down
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: CustomPaint(
                    painter: HortaTopDownPainter(
                      animValue: animValue,
                      showGrowLights: true,
                      growLightIntensity: isSwitchClosed ? potentiometerValue : 0.0,
                      showMoistureProbes: missionIndex >= 1,
                      soilMoisture: soilMoisture,
                      showCoolingFans: missionIndex >= 2,
                      isFanActive: isFanActive && isSwitchClosed,
                      showIrrigation: missionIndex >= 3,
                      isIrrigating: isIrrigating && isSwitchClosed,
                      showMasterBus: missionIndex >= 4,
                      isMasterActive: isMasterActive,
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          // Layout vertical compacto
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 1,
                child: CustomPaint(
                  painter: HortaCircuitPainter(
                    missionIndex: missionIndex,
                    animValue: animValue,
                    usePhysicalStyle: usePhysicalStyle,
                    isSwitchClosed: isSwitchClosed,
                    potentiometerValue: potentiometerValue,
                    soilMoistureLevel: soilMoisture,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                flex: 1,
                child: CustomPaint(
                  painter: HortaTopDownPainter(
                    animValue: animValue,
                    showGrowLights: true,
                    growLightIntensity: isSwitchClosed ? potentiometerValue : 0.0,
                    showMoistureProbes: missionIndex >= 1,
                    soilMoisture: soilMoisture,
                    showCoolingFans: missionIndex >= 2,
                    isFanActive: isFanActive && isSwitchClosed,
                    showIrrigation: missionIndex >= 3,
                    isIrrigating: isIrrigating && isSwitchClosed,
                    showMasterBus: missionIndex >= 4,
                    isMasterActive: isMasterActive,
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
