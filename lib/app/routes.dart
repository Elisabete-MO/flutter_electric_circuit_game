import 'package:flutter/material.dart';

import '../screens/circuito_seguro/circuito_seguro_screen.dart';
import '../screens/first_steps/first_steps_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/horta_monitorada/horta_monitorada_screen.dart';
import '../screens/intro_screen.dart';
import '../screens/letreros_led/letreros_led_screen.dart';
import '../screens/liga_desliga/liga_desliga_screen.dart';
import '../screens/main_menu/main_menu_screen.dart';
import '../screens/mede_testa_explica/mede_testa_explica_screen.dart';
import '../screens/movimento_miniatura/movimento_miniatura_screen.dart';
import '../screens/portao_escola/portao_escola_screen.dart';
import '../screens/praca_maquete/praca_maquete_screen.dart';
import '../screens/ruas_maquete/ruas_maquete_screen.dart';
import '../screens/sandbox/sandbox_screen.dart';
import '../screens/second_bench/second_bench_flow_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/splash/splash_screen.dart';

/// Rotas nomeadas do EletroLab.
abstract final class Routes {
  static const String splash = '/';
  static const String menu = '/menu';
  static const String intro = '/intro';
  static const String home = '/home';
  static const String firstSteps = '/first-steps';
  static const String secondBench = '/second-bench';
  static const String ligaDesliga = '/liga-desliga';
  static const String ruasMaquete = '/ruas-maquete';
  static const String letrerosLed = '/letreros-led';
  static const String movimentoMiniatura = '/movimento-miniatura';
  static const String medeTestaExplica = '/mede-testa-explica';
  static const String circuitoSeguro = '/circuito-seguro';
  static const String hortaMonitorada = '/horta-monitorada';
  static const String portaoEscola = '/portao-escola';
  static const String pracaMaquete = '/praca-maquete';
  static const String sandbox = '/sandbox';
  static const String settings = '/settings';

  static final Map<String, WidgetBuilder> all = {
    splash: (_) => const SplashScreen(),
    menu: (_) => const MainMenuScreen(),
    intro: (_) => const IntroScreen(),
    home: (_) => const HomeScreen(),
    firstSteps: (_) => const FirstStepsScreen(),
    secondBench: (_) => const SecondBenchFlowScreen(),
    ligaDesliga: (_) => const LigaDesligaScreen(),
    ruasMaquete: (_) => const RuasMaqueteScreen(),
    letrerosLed: (_) => const LetrerosLedScreen(),
    movimentoMiniatura: (_) => const MovimentoMiniaturaScreen(),
    medeTestaExplica: (_) => const MedeTestaExplicaScreen(),
    circuitoSeguro: (_) => const CircuitoSeguroScreen(),
    hortaMonitorada: (_) => const HortaMonitoradaScreen(),
    portaoEscola: (_) => const PortaoEscolaScreen(),
    pracaMaquete: (_) => const PracaMaqueteScreen(),
    sandbox: (_) => const SandboxScreen(),
    settings: (_) => const SettingsScreen(),
  };
}


