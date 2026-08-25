import 'dart:convert';
import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

import '../models/settings_model.dart';

/// Interface de persistência das configurações.
///
/// Separada da implementação concreta para permitir o uso de
/// implementações falsas (in-memory) nos testes.
abstract class SettingsRepository {
  Future<SettingsModel> load();

  Future<void> save(SettingsModel settings);
}

/// Implementação real baseada em [SharedPreferences].
class SettingsService implements SettingsRepository {
  static const String storageKey = 'eletrolab.settings.v1';

  @override
  Future<SettingsModel> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      return const SettingsModel();
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return SettingsModel.fromJson(json);
    } catch (e, stackTrace) {
      developer.log('Failed to parse settings JSON: $e', error: e, stackTrace: stackTrace);
      return const SettingsModel();
    }
  }

  @override
  Future<void> save(SettingsModel settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKey, jsonEncode(settings.toJson()));
  }
}
