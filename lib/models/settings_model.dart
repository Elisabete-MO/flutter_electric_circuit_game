import 'package:flutter/material.dart';

/// Modo de tema da aplicação.
enum AppThemeMode {
  system,
  light,
  dark;

  ThemeMode get toFlutterThemeMode => switch (this) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      };

  String get label => switch (this) {
        AppThemeMode.system => 'Sistema',
        AppThemeMode.light => 'Claro',
        AppThemeMode.dark => 'Escuro',
      };

  static AppThemeMode fromName(String? name) =>
      AppThemeMode.values.firstWhere(
        (mode) => mode.name == name,
        orElse: () => AppThemeMode.system,
      );
}

/// Preferências da aplicação.
///
/// Este modelo é agnóstico de qualquer forma de persistência e pode ser
/// serializado para JSON e reconstruído a partir dele.
@immutable
class SettingsModel {
  /// Aparência e Idioma.
  final AppThemeMode themeMode;
  final String locale;

  /// Simulação.
  final bool showCurrent;
  final bool showValues;
  final bool showGrid;
  final bool showTerminals;
  final bool showCurrentAnimation;

  /// Acessibilidade.
  final double interfaceScale;
  final bool highContrast;
  final bool reduceAnimations;

  const SettingsModel({
    this.themeMode = AppThemeMode.system,
    this.locale = 'pt',
    this.showCurrent = true,
    this.showValues = true,
    this.showGrid = true,
    this.showTerminals = true,
    this.showCurrentAnimation = true,
    this.interfaceScale = 1.0,
    this.highContrast = false,
    this.reduceAnimations = false,
  });

  SettingsModel copyWith({
    AppThemeMode? themeMode,
    String? locale,
    bool? showCurrent,
    bool? showValues,
    bool? showGrid,
    bool? showTerminals,
    bool? showCurrentAnimation,
    double? interfaceScale,
    bool? highContrast,
    bool? reduceAnimations,
  }) {
    return SettingsModel(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      showCurrent: showCurrent ?? this.showCurrent,
      showValues: showValues ?? this.showValues,
      showGrid: showGrid ?? this.showGrid,
      showTerminals: showTerminals ?? this.showTerminals,
      showCurrentAnimation: showCurrentAnimation ?? this.showCurrentAnimation,
      interfaceScale: interfaceScale ?? this.interfaceScale,
      highContrast: highContrast ?? this.highContrast,
      reduceAnimations: reduceAnimations ?? this.reduceAnimations,
    );
  }

  /// Restaura as configurações padrão.
  SettingsModel reset() => const SettingsModel();

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode.name,
        'locale': locale,
        'showCurrent': showCurrent,
        'showValues': showValues,
        'showGrid': showGrid,
        'showTerminals': showTerminals,
        'showCurrentAnimation': showCurrentAnimation,
        'interfaceScale': interfaceScale,
        'highContrast': highContrast,
        'reduceAnimations': reduceAnimations,
      };

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      themeMode: AppThemeMode.fromName(json['themeMode'] as String?),
      locale: json['locale'] as String? ?? 'pt',
      showCurrent: json['showCurrent'] as bool? ?? true,
      showValues: json['showValues'] as bool? ?? true,
      showGrid: json['showGrid'] as bool? ?? true,
      showTerminals: json['showTerminals'] as bool? ?? true,
      showCurrentAnimation: json['showCurrentAnimation'] as bool? ?? true,
      interfaceScale: (json['interfaceScale'] as num?)?.toDouble() ?? 1.0,
      highContrast: json['highContrast'] as bool? ?? false,
      reduceAnimations: json['reduceAnimations'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SettingsModel &&
        other.themeMode == themeMode &&
        other.locale == locale &&
        other.showCurrent == showCurrent &&
        other.showValues == showValues &&
        other.showGrid == showGrid &&
        other.showTerminals == showTerminals &&
        other.showCurrentAnimation == showCurrentAnimation &&
        other.interfaceScale == interfaceScale &&
        other.highContrast == highContrast &&
        other.reduceAnimations == reduceAnimations;
  }

  @override
  int get hashCode => Object.hash(
        themeMode,
        locale,
        showCurrent,
        showValues,
        showGrid,
        showTerminals,
        showCurrentAnimation,
        interfaceScale,
        highContrast,
        reduceAnimations,
      );
}
