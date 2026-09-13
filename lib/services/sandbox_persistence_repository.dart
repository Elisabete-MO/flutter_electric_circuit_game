import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sandbox_component.dart';
import '../models/sandbox_wire.dart';
import '../models/sandbox_state.dart';

class SavedProjectSummary {
  final String id;
  final String name;
  final int updatedAtMs;
  final int componentCount;
  final int wireCount;

  const SavedProjectSummary({
    required this.id,
    required this.name,
    required this.updatedAtMs,
    required this.componentCount,
    required this.wireCount,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'updatedAtMs': updatedAtMs,
        'componentCount': componentCount,
        'wireCount': wireCount,
      };

  factory SavedProjectSummary.fromMap(Map<String, dynamic> map) => SavedProjectSummary(
        id: map['id'] as String,
        name: map['name'] as String,
        updatedAtMs: (map['updatedAtMs'] as num).toInt(),
        componentCount: (map['componentCount'] as num).toInt(),
        wireCount: (map['wireCount'] as num).toInt(),
      );
}

class SandboxPersistenceRepository {
  final SharedPreferences _prefs;

  static const String _kIndexKey = 'sandbox_saved_projects_index';

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

  List<SavedProjectSummary> listSavedProjects() {
    final raw = _prefs.getString(_kIndexKey);
    if (raw == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded
          .map((e) => SavedProjectSummary.fromMap(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.updatedAtMs.compareTo(a.updatedAtMs));
    } catch (_) {
      return [];
    }
  }

  Future<void> saveProjectSlot({
    required String name,
    required SandboxState state,
    String? existingId,
  }) async {
    final id = existingId ?? 'proj_${DateTime.now().millisecondsSinceEpoch}';
    final summary = SavedProjectSummary(
      id: id,
      name: name.trim().isEmpty ? 'Projeto sem nome' : name.trim(),
      updatedAtMs: DateTime.now().millisecondsSinceEpoch,
      componentCount: state.components.length,
      wireCount: state.wires.length,
    );

    // Save project payload
    final compList = state.components.map((c) => c.toMap()).toList();
    final wireList = state.wires.map((w) => w.toMap()).toList();
    final payload = {
      'components': compList,
      'wires': wireList,
      'isSimulating': state.isSimulating,
    };
    await _prefs.setString('sandbox_project_$id', jsonEncode(payload));

    // Update index
    final list = listSavedProjects();
    final index = list.indexWhere((p) => p.id == id);
    if (index >= 0) {
      list[index] = summary;
    } else {
      list.insert(0, summary);
    }
    await _prefs.setString(
      _kIndexKey,
      jsonEncode(list.map((e) => e.toMap()).toList()),
    );
  }

  SandboxState? loadProjectSlot(String id) {
    final raw = _prefs.getString('sandbox_project_$id');
    if (raw == null) return null;
    try {
      final Map<String, dynamic> decoded = jsonDecode(raw);
      final List<dynamic> compList = decoded['components'] ?? [];
      final List<dynamic> wireList = decoded['wires'] ?? [];
      final bool isSimulating = decoded['isSimulating'] ?? true;

      final components = compList
          .map((item) => SandboxComponent.fromMap(item as Map<String, dynamic>))
          .toList();
      final wires = wireList
          .map((item) => SandboxWire.fromMap(item as Map<String, dynamic>))
          .toList();

      return SandboxState(
        components: components,
        wires: wires,
        isSimulating: isSimulating,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteProjectSlot(String id) async {
    await _prefs.remove('sandbox_project_$id');
    final list = listSavedProjects().where((p) => p.id != id).toList();
    await _prefs.setString(
      _kIndexKey,
      jsonEncode(list.map((e) => e.toMap()).toList()),
    );
  }
}

