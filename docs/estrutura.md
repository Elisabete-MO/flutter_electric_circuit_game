# Estrutura do projeto

## Arquitetura em camadas

O EletroLab mantém as camadas estritamente separadas. O motor matemático não
depende do visual do Flame, e o estado da simulação não depende do estado
visual.

```text
Flutter UI (widgets, telas)
     ↓
Flame (canvas, componentes visuais, câmera, partículas)
     ↓
Circuit Model (grafo: nodes, terminals, connections, components)
     ↓
Circuit Solver (matemática: Ohm, Kirchhoff, análise nodal)
     ↓
Simulation Result (tensões, correntes, potências, validação)
```

## Estrutura de pastas

Estrutura alvo (a implementar gradualmente):

```text
lib/
├── main.dart                 → inicialização + injeção de provedores
├── app/
│   ├── app.dart              → EletroLabApp (MaterialApp, tema, rotas)
│   ├── routes.dart           → rotas nomeadas
│   └── theme.dart            → identidade visual (claro/escuro)
├── screens/
│   ├── home/                 → menu inicial com as 4 opções
│   ├── first_steps/          → tutorial interativo        (Fase 2)
│   ├── challenges/           → lista + execução de desafios (Fase 8)
│   ├── sandbox/              → laboratório livre           (Fases 3–7)
│   └── settings/             → configurações               (Fase 9)
├── game/                     → camada Flame
│   ├── circuit_game.dart     → jogo/canvas principal
│   ├── components/           → componentes visuais
│   ├── wires/                → fios
│   ├── particles/            → animação de corrente
│   ├── camera/               → câmera, zoom, pan
│   └── interactions/         → arrastar, selecionar, conectar
├── simulation/               → modelo matemático
│   ├── circuit.dart          → grafo do circuito
│   ├── node.dart
│   ├── terminal.dart
│   ├── connection.dart
│   ├── solver/               → solvers (Ohm, Kirchhoff, nodal)
│   └── simulation_result.dart
├── models/                   → models de dados (agente de UI)
│   ├── component_model.dart
│   ├── challenge_model.dart
│   └── settings_model.dart   ✔ criado
├── state/                    → controladores/provedores Riverpod
│   └── settings_controller.dart ✔ criado
├── services/                 → persistência e repositórios
│   ├── settings_service.dart ✔ criado
│   └── progress_service.dart (a criar)
└── widgets/                  → widgets reutilizáveis
    ├── eletrolab_logo.dart   ✔ criado
    ├── home_option_card.dart ✔ criado
    ├── section_placeholder.dart ✔ criado
    ├── component_palette.dart (a criar)
    ├── toolbar.dart          (a criar)
    └── value_editor.dart     (a criar)

assets/
├── images/
├── icons/
├── sounds/
└── components/
```

Marcados com `✔` estão implementados na Fase 1; `(a criar)`/`(Fase X)`
indicam itens planejados.

## Gerenciamento de estado

- **Riverpod** (`flutter_riverpod`) é a solução de estado.
- O estado da simulação não depende do estado visual do Flame: o modelo do
  circuito vive em `simulation/` e é observado pela camada visual.

### Provedores existentes

| Provedor | Tipo | Função |
|---|---|---|
| `settingsRepositoryProvider` | `Provider<SettingsRepository>` | Repositório de configurações (sobrescrito em `main`/testes) |
| `settingsControllerProvider` | `NotifierProvider<SettingsController, SettingsModel>` | Estado das preferências |

### Padrão de controle

Controladores Riverpod recebem o estado inicial via **construtor** (não
setam `state` antes da inicialização do notifier). A persistência é feita no
repositório após cada atualização.

## Persistência

- **shared_preferences** é o armazenamento local.
- Chaves: `eletrolab.settings.v1` (configurações).
- A serialização é JSON com tolerância a dados inválidos (retorna defaults).
- Repositórios usam **interfaces abstratas** para permitir fakes em testes.

## Assets

O EletroLab usa formas vetoriais próprias ou placeholders. Os assets devem
poder ser **substituídos sem alterar a lógica do simulador** — a camada visual
depende apenas de nomes/registros de assets, não de imagens específicas.

## Padrões de código

- `Material 3`, tema por `ColorScheme.fromSeed` (seed azul elétrico).
- Sem comentários desnecessários; nomes e código em português quando faz
  sentido para o domínio educacional.
- Verificação obrigatória a cada etapa: `flutter analyze` e `flutter test`.