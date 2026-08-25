# Configurações e persistência

## Estado atual (Fase 1)

Tela de configurações funcional com:

- **Aparência**: tema Claro / Escuro / Sistema.
- **Simulação**: mostrar corrente, valores, grade, terminais, animar corrente.
- **Acessibilidade**: tamanho da interface (slider), alto contraste,
  reduzir animações.
- **Dados**: restaurar configurações padrão; resetar progresso (desabilitado —
  disponível nas próximas versões).
- **Sobre**: nome, descrição e versão (`Versão 1.0.0`).

## Modelo de configurações

```dart
class SettingsModel {
  AppThemeMode themeMode;        // system | light | dark
  bool showCurrent;
  bool showValues;
  bool showGrid;
  bool showTerminals;
  bool showCurrentAnimation;
  double interfaceScale;
  bool highContrast;
  bool reduceAnimations;
}
```

- `copyWith` para atualizações imutáveis.
- `reset()` restaura os padrões.
- `toJson` / `fromJson` para persistência.
- `fromJson` tolera dados ausentes/inválidos (usa default).

## Persistência

### Repositórios

- `SettingsRepository` (interface) → `SettingsService` via
  `shared_preferences`, chave `eletrolab.settings.v1`.
- Interface abstrata permite **fakes in-memory** nos testes.

### Riverpod

- `settingsRepositoryProvider`: injeção do repositório (sobrescrito em
  `main()` e nos testes).
- `settingsControllerProvider`: estado das preferências; o controller cria
  o estado inicial via construtor e persiste após cada atualização.

### Inicialização

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = SettingsService();
  final settings = await repository.load();
  runApp(ProviderScope(overrides: [...], child: const EletroLabApp()));
}
```

### Aplicação global

- `themeMode` define o tema do `MaterialApp`.
- `interfaceScale` aplica `TextScaler.linear` via `MediaQuery` (builder do
  `MaterialApp`).

## Tela "Sobre"

```text
EletroLab
Laboratório virtual de circuitos elétricos.

Versão X.X.X
```

## Estado de Implementação (Fase 9 — Concluída)

- **Persistência Completa**: Configurações gerais e progresso do jogador (desafios concluídos e número de estrelas obtidas) são mantidos com persistência reativa local.
- **Gerenciador de Progresso**: O `ProgressController` salva os desafios resolvidos localmente e atualiza dinamicamente as telas de listagem.
- **Redução de Animações**: O controle de acessibilidade "reduzir animações" afeta a taxa de atualização do `CustomPainter` e as velocidades de simulação visual (partículas e rotações).
- **Testabilidade**: Os testes contam com isolamento de `SharedPreferences` injetando instâncias falsas ou mockadas usando `ProviderScope`.