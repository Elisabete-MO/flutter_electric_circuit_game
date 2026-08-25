# Estrutura do projeto

## Arquitetura em camadas

O EletroLab mantém as camadas estritamente separadas. O motor de simulação e os widgets de rendering não dependem de frameworks externos como o Flame; tudo é desenhado usando o motor gráfico nativo do Flutter (`CustomPainter`).

```text
Flutter UI (widgets, telas)
     ↓
CustomPainter (canvas, componentes visuais, partículas de corrente)
     ↓
Circuit Model (grafo/slots: nodes, terminals, connections, components)
     ↓
Circuit Solver (matemática/validação: Ohm, Kirchhoff, análise nodal - planejada)
     ↓
Simulation Result (validação de desafios, estado ligado/desligado)
```

## Estrutura de pastas

A estrutura real do projeto está dividida da seguinte forma:

```text
lib/
├── main.dart                 → inicialização + injeção de provedores
├── app/
│   ├── app.dart              → EletroLabApp (MaterialApp, tema, rotas)
│   ├── routes.dart           → rotas nomeadas
│   └── theme.dart            → identidade visual (Cyberpunk claro/escuro)
├── screens/
│   ├── home/                 → menu inicial estilo Bento Grid com CyberHUD
│   ├── first_steps/          → tutorial interativo (símbolos e componentes)
│   ├── challenges/           → lista + execução de desafios (Desafios 1, 2, 3)
│   │   ├── challenges_screen.dart
│   │   ├── challenge_1_detail_screen.dart
│   │   ├── challenge_2_detail_screen.dart
│   │   └── challenge_3_detail_screen.dart
│   ├── electrical_diagram/   → visualizador do diagrama elétrico (painel retrátil)
│   ├── sandbox/              → laboratório livre (em construção)
│   └── settings/             → configurações e acessibilidade
├── models/                   → models de dados
│   ├── challenge.dart
│   ├── first_step_component.dart
│   └── settings_model.dart
├── state/                    → controladores/provedores Riverpod
│   ├── settings_controller.dart
│   └── progress_controller.dart → estado do progresso do usuário e persistência
├── services/                 → persistência e repositórios
│   ├── settings_service.dart
│   └── audio_service.dart     → efeitos sonoros e música de fundo
└── widgets/                  → widgets reutilizáveis e pintores customizados
    ├── challenge_layout_components.dart
    ├── circuit_symbol_painter.dart
    ├── component_physical_painter.dart
    ├── cyber_hud_container.dart
    ├── eletrolab_logo.dart
    ├── prof_volts_speech.dart
    └── tech_grid_background.dart

assets/
├── audio/                    → arquivos de som (.mp3) para cliques, acertos e erros
└── l10n/                     → traduções ARB (pt/en)
```

## Gerenciamento de estado

- **Riverpod** (`flutter_riverpod`) é a solução de gerenciamento de estado.
- O progresso do usuário e as configurações são injetados de forma assíncrona/síncrona e observados por toda a aplicação.

### Provedores existentes

| Provedor | Tipo | Função |
|---|---|---|
| `sharedPreferencesProvider` | `Provider<SharedPreferences>` | Instância global de SharedPreferences (sobrescrito em `main`/testes) |
| `settingsRepositoryProvider` | `Provider<SettingsRepository>` | Repositório de configurações (sobrescrito em `main`/testes) |
| `settingsControllerProvider` | `NotifierProvider<SettingsController, SettingsModel>` | Estado e manipulação de preferências do sistema |
| `progressControllerProvider` | `NotifierProvider<ProgressController, ProgressState>` | Estado de conclusão de desafios e estrelas obtidas |
| `audioServiceProvider` | `Provider<AudioService>` | Gerenciador do ciclo de vida de áudios (BGM e SFX) |

### Padrão de controle

Controladores Riverpod recebem o estado inicial via **construtor** (ou pelo método `build` no caso de `Notifier`). A persistência é realizada nos serviços e repositórios locais adequados após cada atualização.

## Persistência

- **shared_preferences** é o armazenamento local.
- Chaves:
  - `eletrolab.settings.v1` (configurações)
  - `completed_challenges` e `stars_{challenge_id}` (progresso do jogador)
- A serialização de configurações é feita via JSON com tolerância a dados inválidos (retorna defaults).
- Repositórios e provedores são facilmente mockáveis nos testes usando sobreposições (`overrides`).

## Assets

O EletroLab usa formas vetoriais próprias ou placeholders. Os assets devem
poder ser **substituídos sem alterar a lógica do simulador** — a camada visual
depende apenas de nomes/registros de assets, não de imagens específicas.

## Padrões de código

- `Material 3`, tema por `ColorScheme.fromSeed` (seed azul elétrico).
- Sem comentários desnecessários; nomes e código em português quando faz
  sentido para o domínio educacional.
- Verificação obrigatória a cada etapa: `flutter analyze` e `flutter test`.