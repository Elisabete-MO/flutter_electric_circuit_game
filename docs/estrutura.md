# Estrutura do projeto (EletroLab v1.0.0)

## Arquitetura em camadas

O EletroLab mantém as camadas estritamente separadas. O motor de simulação e os widgets de rendering não dependem de frameworks externos como o Flame; tudo é desenhado usando o motor gráfico nativo do Flutter (`CustomPainter`) e gerenciado por Riverpod.

```text
Flutter UI (widgets, telas, overlays HUD)
     ↓
CustomPainter (canvas, WiresPainter, ComponentPhysicalPainter, CircuitSymbolPainter)
     ↓
SandboxController (Graph Traversal, busca em profundidade, detecção de loops)
     ↓
SandboxState / Circuit Models (components, wires, simulationValues, burnedComponentIds)
     ↓
Services & Repositories (AudioService, SettingsRepository, ProgressRepository)
```

## Estrutura de pastas

A estrutura real do projeto está dividida da seguinte forma:

```text
lib/
├── main.dart                 → inicialização + injeção de provedores Riverpod
├── app/
│   ├── app.dart              → EletroLabApp (MaterialApp, tema, rotas)
│   ├── routes.dart           → rotas nomeadas (/first-steps, /challenges, /sandbox, /settings)
│   └── theme.dart            → identidade visual (Cyberpunk claro/escuro)
├── screens/
│   ├── home/                 → menu inicial estilo Bento Grid com CyberHUD
│   ├── first_steps/          → tutorial interativo (símbolos, componentes e quiz)
│   ├── challenges/           → lista + execução de desafios (Desafios 1, 2, 3)
│   │   ├── challenges_screen.dart
│   │   ├── challenge_1_detail_screen.dart
│   │   ├── challenge_2_detail_screen.dart
│   │   └── challenge_3_detail_screen.dart
│   ├── electrical_diagram/   → visualizador do diagrama elétrico (painel retrátil)
│   ├── sandbox/              → bancada livre (laboratório de circuitos)
│   │   ├── sandbox_screen.dart
│   │   └── widgets/
│   │       ├── sandbox_control_bar.dart
│   │       ├── sandbox_grid_painters.dart (WiresPainter, GridPainter)
│   │       ├── sandbox_mascot_panel.dart  (Prof. Volts HUD overlay)
│   │       └── sandbox_metrics_panel.dart (Medições de V, I, P)
│   └── settings/             → configurações e acessibilidade
├── models/                   → modelos de dados
│   ├── challenge.dart
│   ├── first_step_component.dart
│   ├── sandbox_component.dart
│   ├── sandbox_state.dart
│   ├── sandbox_wire.dart
│   └── settings_model.dart
├── state/                    → controladores/provedores Riverpod
│   ├── sandbox_controller.dart  → motor de simulação, grafo e queima física
│   ├── settings_controller.dart → estado de preferências do usuário
│   └── progress_controller.dart → estado do progresso do usuário e estrelas
├── services/                 → persistência e repositórios
│   ├── settings_service.dart
│   └── audio_service.dart       → gerenciador de áudio (efeitos e BGM)
└── widgets/                  → widgets reutilizáveis e pintores customizados
    ├── challenge_layout_components.dart
    ├── circuit_symbol_painter.dart
    ├── component_detail_dialog.dart
    ├── component_physical_painter.dart
    ├── cyber_hud_container.dart
    ├── glass_container.dart
    ├── prof_volts_challenge_dialog.dart
    ├── prof_volts_feedback_dialog.dart
    ├── prof_volts_full_body.dart
    ├── prof_volts_speech.dart
    ├── symbol_card.dart
    └── tech_grid_background.dart

assets/
├── audio/                    → arquivos de som (.mp3) para cliques, acertos e erros
└── l10n/                     → traduções ARB (pt/en)
```

## Gerenciamento de estado

- **Riverpod** (`flutter_riverpod`) é a solução oficial de gerenciamento de estado.
- O estado da Bancada Livre é reativo e mantido por `sandboxControllerProvider`.

### Provedores existentes

| Provedor | Tipo | Função |
|---|---|---|
| `sharedPreferencesProvider` | `Provider<SharedPreferences>` | Instância global de SharedPreferences |
| `settingsRepositoryProvider` | `Provider<SettingsRepository>` | Repositório de configurações |
| `settingsControllerProvider` | `NotifierProvider<SettingsController, SettingsModel>` | Preferências do sistema (tema, áudio, i18n) |
| `progressControllerProvider` | `NotifierProvider<ProgressController, ProgressState>` | Conclusão de desafios e pontuação |
| `sandboxControllerProvider` | `NotifierProvider<SandboxController, SandboxState>` | Estado completo do circuito livre e simulação |
| `audioServiceProvider` | `Provider<AudioService>` | Gerenciador do ciclo de vida de áudios (BGM e SFX) |

## Persistência

- **shared_preferences** é o armazenamento local.
- Chaves:
  - `eletrolab.settings.v1` (configurações)
  - `completed_challenges` e `stars_{challenge_id}` (progresso de estrelas)