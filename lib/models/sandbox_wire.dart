class SandboxWire {
  const SandboxWire({
    required this.id,
    required this.fromComponentId,
    required this.fromTerminal, // 'A' ou 'B'
    required this.toComponentId,
    required this.toTerminal,   // 'A' ou 'B'
  });

  final String id;
  final String fromComponentId;
  final String fromTerminal; // 'A' ou 'B'
  final String toComponentId;
  final String toTerminal; // 'A' ou 'B'

  SandboxWire copyWith({
    String? id,
    String? fromComponentId,
    String? fromTerminal,
    String? toComponentId,
    String? toTerminal,
  }) {
    return SandboxWire(
      id: id ?? this.id,
      fromComponentId: fromComponentId ?? this.fromComponentId,
      fromTerminal: fromTerminal ?? this.fromTerminal,
      toComponentId: toComponentId ?? this.toComponentId,
      toTerminal: toTerminal ?? this.toTerminal,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fromComponentId': fromComponentId,
      'fromTerminal': fromTerminal,
      'toComponentId': toComponentId,
      'toTerminal': toTerminal,
    };
  }

  factory SandboxWire.fromMap(Map<String, dynamic> map) {
    return SandboxWire(
      id: map['id'] as String,
      fromComponentId: map['fromComponentId'] as String,
      fromTerminal: map['fromTerminal'] as String,
      toComponentId: map['toComponentId'] as String,
      toTerminal: map['toTerminal'] as String,
    );
  }
}
