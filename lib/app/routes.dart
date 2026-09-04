import 'package:flutter/material.dart';

import '../screens/first_steps/first_steps_screen.dart';
import '../screens/second_bench/second_bench_flow_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/intro_screen.dart';
import '../screens/letreros_led/letreros_led_screen.dart';
import '../screens/liga_desliga/liga_desliga_screen.dart';
import '../screens/main_menu/main_menu_screen.dart';
import '../screens/mede_testa_explica/mede_testa_explica_screen.dart';
import '../screens/movimento_miniatura/movimento_miniatura_screen.dart';
import '../screens/ruas_maquete/ruas_maquete_screen.dart';
import '../screens/sandbox/sandbox_screen.dart';
import '../screens/settings/settings_screen.dart';

/// Rotas nomeadas do EletroLab.
abstract final class Routes {
  static const String menu = '/';
  static const String intro = '/intro';
  static const String home = '/home';
  static const String firstSteps = '/first-steps';
  static const String firstBench = '/first-bench';
  static const String secondBench = '/second-bench';
  static const String ligaDesliga = '/liga-desliga';
  static const String ruasMaquete = '/ruas-maquete';
  static const String letrerosLed = '/letreros-led';
  static const String movimentoMiniatura = '/movimento-miniatura';
  static const String medeTestaExplica = '/mede-testa-explica';
  static const String sandbox = '/sandbox';
  static const String settings = '/settings';

  static final Map<String, WidgetBuilder> all = {
    menu: (_) => const MainMenuScreen(),
    intro: (_) => const IntroScreen(),
    home: (_) => const HomeScreen(),
    firstSteps: (_) => const FirstStepsScreen(),
    firstBench: (_) => const FirstStepsScreen(),
    secondBench: (_) => const SecondBenchFlowScreen(),
    ligaDesliga: (_) => const LigaDesligaScreen(),
    ruasMaquete: (_) => const RuasMaqueteScreen(),
    letrerosLed: (_) => const LetrerosLedScreen(),
    movimentoMiniatura: (_) => const MovimentoMiniaturaScreen(),
    medeTestaExplica: (_) => const MedeTestaExplicaScreen(),
    sandbox: (_) => const SandboxScreen(),
    settings: (_) => const SettingsScreen(),
  };
}

