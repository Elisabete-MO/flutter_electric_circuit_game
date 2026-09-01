import 'package:flutter/material.dart';

import '../screens/challenges/challenges_screen.dart';
import '../screens/first_steps/first_steps_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/sandbox/sandbox_screen.dart';
import '../screens/sandbox/schematic_sandbox_screen.dart';
import '../screens/settings/settings_screen.dart';

/// Rotas nomeadas do EletroLab.
abstract final class Routes {
  static const String home = '/';
  static const String firstSteps = '/first-steps';
  static const String challenges = '/challenges';
  static const String sandbox = '/sandbox';
  static const String schematicSandbox = '/schematic_sandbox';
  static const String settings = '/settings';

  static final Map<String, WidgetBuilder> all = {
    home: (_) => const HomeScreen(),
    firstSteps: (_) => const FirstStepsScreen(),
    challenges: (_) => const ChallengesScreen(),
    sandbox: (_) => const SandboxScreen(),
    schematicSandbox: (_) => const SchematicSandboxScreen(),
    settings: (_) => const SettingsScreen(),
  };
}
