import 'package:flutter/material.dart';
import '../widgets/circuit_e_emblem.dart';

/// Serviço global de pré-carregamento de assets do EletroLab.
class Preloader {
  /// Lista completa de todos os assets de imagem do projeto.
  /// Deve estar sincronizada com os paths declarados no pubspec.yaml.
  static const List<String> allAppAssets = [
    // Cenários / Planos de fundo
    'assets/backgrounds/background_fase_02_bancada.png',
    'assets/backgrounds/background_fase_03_prancheta_tecnica.png',
    'assets/backgrounds/floor.png',
    'assets/images/backgrounds/mesa_eletrolab_vista_superior.png',

    // Componentes (físicos / realistas)
    'assets/components/battery.png',
    'assets/components/bulb_off.png',
    'assets/components/bulb_on.png',
    'assets/components/buzzer.png',
    'assets/components/capacitor.png',
    'assets/components/diode.png',
    'assets/components/fuse.png',
    'assets/components/led_off.png',
    'assets/components/led_on.png',
    'assets/components/motor.png',
    'assets/components/potentiometer.png',
    'assets/components/power_supply.png',
    'assets/components/resistor.png',
    'assets/components/switch_closed.png',
    'assets/components/switch_open.png',
    'assets/components/wires.png',

    // Componentes (modo diagrama / esquemático)
    'assets/images/component_battery_horizontal.png',
    'assets/images/component_bulb_off.png',
    'assets/images/component_bulb_on.png',
    'assets/images/component_diode.png',
    'assets/images/component_led_off.png',
    'assets/images/component_led_on.png',
    'assets/images/component_motor.png',
    'assets/images/component_resistor.png',
    'assets/images/component_switch_off.png',
    'assets/images/component_switch_on.png',
    'assets/images/concept.png',

    // Intro / Professora Nuri
    'assets/low-poly/ginasio-alpha-low-poly-portas-fechadas.png',
    'assets/low-poly/ginasio-alpha-low-poly-portas-abertas.png',
    'assets/low-poly/professora-nuri-sprites.png',

    // Referências e tutoriais
    'assets/references/referencia_tutorial_8_componentes.png',

    // Estandes da Feira de Ciências (Low-Poly 3D)
    'assets/low-poly/mesas-estandes/tutorial.png',
    'assets/low-poly/mesas-estandes/acende-ai.png',
    'assets/low-poly/mesas-estandes/liga-e-desliga.png',
    'assets/low-poly/mesas-estandes/ruas-da-maquete.png',
    'assets/low-poly/mesas-estandes/letreiros-de-led.png',
    'assets/low-poly/mesas-estandes/movimento-em-miniatura.png',
    'assets/low-poly/mesas-estandes/mede-testa-e-explica.png',
    'assets/low-poly/mesas-estandes/circuito-seguro.png',
    'assets/low-poly/mesas-estandes/horta-monitorada.png',
    'assets/low-poly/mesas-estandes/portao-da-escola.png',
    'assets/low-poly/mesas-estandes/maquete-coletiva.png',
    'assets/low-poly/mesas-estandes/bancada-livre.png',
    'assets/low-poly/quadra_trilha_direita.png',
    'assets/low-poly/quadra_trilha_esquerda.png',
  ];

  /// Pré-carrega imagens e dados na memória antes de navegar para uma tela.
  ///
  /// Todos os assets listados em [imageAssets] são carregados em paralelo
  /// e inseridos no [ImageCache] global do Flutter, garantindo que apareçam
  /// instantaneamente na primeira renderização.
  ///
  /// Se [blockInteractions] for `true`, exibe um overlay animado que impede
  /// cliques enquanto o carregamento ocorre.
  ///
  /// Chamada de uso típico (ex: ao abrir a Bancada Livre):
  /// ```dart
  /// await Preloader.preloadResources(context,
  ///   imageAssets: Preloader.allAppAssets,
  ///   blockInteractions: true,
  /// );
  /// ```
  static Future<void> preloadResources(
    BuildContext context, {
    List<String>? imageAssets,
    List<Future<dynamic>>? dataFutures,
    bool blockInteractions = false,
  }) async {
    OverlayEntry? overlayEntry;

    if (blockInteractions) {
      overlayEntry = OverlayEntry(
        builder: (_) => const _LoadingOverlay(),
      );
      Overlay.of(context).insert(overlayEntry);
    }

    try {
      final List<Future<void>> tasks = [];

      if (imageAssets != null) {
        for (final path in imageAssets) {
          tasks.add(precacheImage(AssetImage(path), context));
        }
      }

      if (dataFutures != null) {
        tasks.addAll(dataFutures.cast<Future<void>>());
      }

      if (tasks.isNotEmpty) {
        await Future.wait(tasks);
      }
    } finally {
      if (overlayEntry != null && overlayEntry.mounted) {
        overlayEntry.remove();
      }
    }
  }
}

// Overlay interno exibido quando blockInteractions = true.
class _LoadingOverlay extends StatefulWidget {
  const _LoadingOverlay();

  @override
  State<_LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<_LoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const ModalBarrier(
          dismissible: false,
          color: Color(0xCC021712),
        ),
        Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CircuitEEmblem(
                size: 96,
                progress: 0.3 + (_controller.value * 0.7),
                pulseGlow: true,
              );
            },
          ),
        ),
      ],
    );
  }
}
