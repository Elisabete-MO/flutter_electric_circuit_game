import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/settings_model.dart';
import '../services/settings_service.dart';

/// Provider do repositório de configurações.
///
/// É sobrescrito na inicialização do aplicativo (e nos testes) com a
/// implementação desejada.
final settingsRepositoryProvider =
    Provider<SettingsRepository>((ref) => throw UnimplementedError());

/// Estado das configurações da aplicação.
final settingsControllerProvider =
    NotifierProvider<SettingsController, SettingsModel>(
  SettingsController.new,
);

class SettingsController extends Notifier<SettingsModel> {
  SettingsController({this.initial});

  /// Estado inicial carregado antes da inicialização do aplicativo.
  final SettingsModel? initial;

  @override
  SettingsModel build() => initial ?? const SettingsModel();

  Future<void> setThemeMode(AppThemeMode mode) =>
      _update(state.copyWith(themeMode: mode));

  Future<void> setLocale(String locale) =>
      _update(state.copyWith(locale: _validateLocale(locale)));

  Future<void> setShowCurrent(bool value) =>
      _update(state.copyWith(showCurrent: value));

  Future<void> setShowValues(bool value) =>
      _update(state.copyWith(showValues: value));

  Future<void> setShowGrid(bool value) =>
      _update(state.copyWith(showGrid: value));

  Future<void> setShowTerminals(bool value) =>
      _update(state.copyWith(showTerminals: value));

  Future<void> setShowCurrentAnimation(bool value) =>
      _update(state.copyWith(showCurrentAnimation: value));

  Future<void> setInterfaceScale(double value) =>
      _update(state.copyWith(interfaceScale: value.clamp(0.5, 2.0)));

  Future<void> setHighContrast(bool value) =>
      _update(state.copyWith(highContrast: value));

  Future<void> setReduceAnimations(bool value) =>
      _update(state.copyWith(reduceAnimations: value));

  Future<void> restoreDefaults() => _update(state.reset());

  String _validateLocale(String locale) {
    final validLocales = ['en', 'pt'];
    return validLocales.contains(locale) ? locale : 'pt';
  }

  Future<void> _update(SettingsModel next) async {
    state = next;
    try {
      await ref.read(settingsRepositoryProvider).save(next);
    } catch (_) {
      state = initial ?? const SettingsModel();
    }
  }
}
