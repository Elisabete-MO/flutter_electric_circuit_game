import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sandbox_component.dart';
import '../models/sandbox_wire.dart';
import '../models/sandbox_state.dart';

class SandboxPersistenceRepository {
  final SharedPreferences _prefs;

  SandboxPersistenceRepository(this._prefs);

  SandboxState load() {
    final compString = _prefs.getString('sandbox_components');
    final wireString = _prefs.getString('sandbox_wires');
    final isSimulating = _prefs.getBool('sandbox_is_simulating') ?? false;

    List<SandboxComponent> components = [];
    List<SandboxWire> wires = [];

    if (compString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(compString);
        components = decoded
            .map((item) => SandboxComponent.fromMap(item as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    if (wireString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(wireString);
        wires = decoded
            .map((item) => SandboxWire.fromMap(item as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    return SandboxState(
      components: components,
      wires: wires,
      isSimulating: isSimulating,
    );
  }

  Future<void> save(SandboxState state) async {
    final compList = state.components.map((c) => c.toMap()).toList();
    final wireList = state.wires.map((w) => w.toMap()).toList();

    await _prefs.setString('sandbox_components', jsonEncode(compList));
    await _prefs.setString('sandbox_wires', jsonEncode(wireList));
    await _prefs.setBool('sandbox_is_simulating', state.isSimulating);
  }
}
