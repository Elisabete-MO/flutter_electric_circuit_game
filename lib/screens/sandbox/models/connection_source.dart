class ConnectionSource {
  final String componentId;
  final String terminal; // 'A' ou 'B'

  const ConnectionSource(this.componentId, this.terminal);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectionSource &&
          runtimeType == other.runtimeType &&
          componentId == other.componentId &&
          terminal == other.terminal;

  @override
  int get hashCode => componentId.hashCode ^ terminal.hashCode;
}
