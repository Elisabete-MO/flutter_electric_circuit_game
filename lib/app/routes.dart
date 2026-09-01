import 'package:flutter/material.dart';

import '../screens/first_steps/first_steps_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/sandbox/sandbox_screen.dart';
import '../screens/settings/settings_screen.dart';

/// Rotas nomeadas do EletroLab.
abstract final class Routes {
  static const String home = '/';
  static const String firstSteps = '/first-steps';
  static const String sandbox = '/sandbox';
  static const String settings = '/settings';

  static final Map<String, WidgetBuilder> all = {
    home: (_) => const HomeScreen(),
    firstSteps: (_) => const FirstStepsScreen(),
    sandbox: (_) => const SandboxScreen(),
    settings: (_) => const SettingsScreen(),
  };
}

