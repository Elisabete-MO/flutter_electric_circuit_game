# Arquitetura de Software — EletroLab

Este documento descreve o desenho técnico, as camadas de responsabilidade, o gerenciamento de estado e a estrutura de módulos do EletroLab.

---

## 🏛️ Visão Geral em Camadas

O EletroLab adota uma arquitetura em camadas estritamente desacoplada. O motor de cálculo físico e os validadores de circuito não possuem acoplamento com a camada visual ou com a biblioteca de rendering.

```text
┌────────────────────────────────────────────────────────────────────────┐
│                   Camada de Interface com o Usuário                    │
│      (Widgets Flutter, Telas de Estandes, HUDs, Modais e Botões)       │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ interage / lê estado
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                      Camada de Renderização Nativa                     │
│    (CustomPainter, RepaintBoundary, WiresPainter, CircuitPainters)     │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ consome dados de
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                 Camada de Controle e Estado (Riverpod)                 │
│      (StandFlowState, SandboxController, ProgressController)           │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ invoca regras de
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                 Camada de Domínio, Grafo e Física                      │
│     (Solver Elétrico, Graph Traversal DFS, Validador Topológico)       │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ serializa / desserializa
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                 Camada de Serviços e Persistência Local                │
│    (SharedPreferences, SettingsRepository, ProgressRepository, Audio)  │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 🧩 1. Arquitetura Modular dos Estandes (`common_stand`)

Para garantir escalabilidade e facilitar testes unitários, os Estandes da Feira de Ciências adotam o padrão de decomposição modular isolado:

```text
lib/screens/<nome_do_estande>/
├── <nome_do_estande>_screen.dart   # Coordenador Slim (~170 linhas)
├── missions/                       # Uma tela independente por missão
│   ├── <estande>_m1.dart           # Missão 1 (Preparar)
│   ├── <estande>_m2.dart           # Missão 2 (Prever)
│   ├── <estande>_m3.dart           # Missão 3 (Investigar)
│   ├── <estande>_m4.dart           # Missão 4 (Projetar)
│   └── <estande>_m5.dart           # Missão 5 (Demonstrar)
└── widgets/                        # Pintores vetoriais e sub-widgets
    └── <estande>_widgets.dart      # Painéis de telemetria, motores, etc.
```

### Componentes de Andaime Compartilhado ([lib/screens/common_stand/](file:///home/amanda/flutter_electric_circuit_game/lib/screens/common_stand/))
1. **`StandFlowState`**: Modelo imutável que gerencia a missão atual, o conjunto de missões liberadas (`unlockedMissionIds`) e missões completas (`completedMissionIds`).
2. **`StandFlowHeader`**: Cabeçalho de navegação responsivo com stepper de missões, selo do estande e botão de retorno.
3. **`StandFlowActionBar`**: Barra de rodapé integrada com suporte a Desfazer/Refazer e gatilho de avanço de missão.
4. **`StandFlowScaffold`**: Estrutura de layout visual que inclui o fundo tecnológico de grid (`TechGridBackground`) e tratamento de overflow em viewports pequenos.

---

## ⚡ 2. Arquitetura da Bancada Livre (Sandbox)

A Bancada Livre é projetada para manipular um grafo dinâmico de circuitos elétricos montado livremente pelo usuário:

```text
SandboxState (Imutável)
 ├── components         : List<SandboxComponent>  (posição no grid, rotação, tipo e parâmetros)
 ├── wires              : List<SandboxWire>       (conexões entre bornes de componentes)
 ├── simulationValues   : Map<String, double>     (corrente, queda de tensão e potência)
 ├── burnedComponentIds : Set<String>             (componentes destruídos por sobrecarga)
 └── isSimulating       : bool                    (estado do motor de simulação)
```

### 2.1. Algoritmo de Fechamento de Malhas (DFS Graph Solver)
1. **Ponto de Partida**: O algoritmo identifica as fontes de alimentação no circuito (baterias ou fontes de bancada).
2. **Busca em Profundidade (DFS)**: Percorre a lista de `wires` a partir do terminal positivo em direção ao negativo.
3. **Detecção de Circuito Aberto**: Se um componente queimado (`burnedComponentIds`), chave aberta ou terminal solto for interceptado, a corrente é zerada imediatamente.
4. **Resistência Equivalente**: Calcula a soma das resistências no ramo fechado para obter a corrente total pela Lei de Ohm:
   $$I = \frac{V_{fonte}}{R_{total}}$$
5. **Potencial Nodal**: Cada borne conectado recebe seu respectivo potencial elétrico em relação ao polo de referência (0 V), permitindo medições precisas por ponteiras de multímetro.

### 2.2. Roteamento Ortogonal Inteligente (Manhattan Wire Routing)
No modo diagrama esquemático, os fios entre bornes não são desenhados em linha reta para evitar poluição visual:
* O `WiresPainter` calcula curvas ortogonais em ângulos retos de 90°.
* Quando o fio conecta o terminal direito de volta ao polo esquerdo da fonte, a trajetória contorna automaticamente por baixo da área ocupada pelos componentes.

---

## 📂 3. Organização de Pastas do Projeto (`lib/`)

```text
lib/
├── app/
│   ├── app.dart                   # MaterialApp, temas e internacionalização
│   ├── routes.dart                # Tabela de rotas nomeadas
│   └── theme.dart                 # Tokens de cores, tema claro e tema escuro
├── l10n/                          # Geradores e arquivos de tradução ARB
├── models/                        # Modelos de dados globais de fluxo e componentes
│   ├── first_bench_flow.dart      # Estado da jornada de 4 fases do Estande 1
│   ├── second_bench_flow.dart     # Estado do fluxo do Estande 2
│   ├── sandbox_component.dart     # Definição de componentes da Bancada Livre
│   └── settings_model.dart        # Modelo de configurações e acessibilidade
├── screens/
│   ├── common_stand/              # Andaime compartilhado dos Estandes
│   ├── first_bench/               # Estande 1 em 4 fases completas
│   ├── first_steps/               # Tutorial rápido e quiz de simbologia
│   ├── home/                      # Menu Bento Grid com lista de estandes
│   ├── liga_desliga/              # Estande 3 (modularizado)
│   ├── ruas_maquete/              # Estande 4 (modularizado)
│   ├── letreros_led/              # Estande 5 (modularizado)
│   ├── movimento_miniatura/       # Estande 6 (modularizado)
│   ├── mede_testa_explica/        # Estande 7 (modularizado)
│   ├── sandbox/                   # Bancada Livre e instrumentos
│   └── settings/                  # Tela de configurações
├── state/                         # Notifiers do Riverpod
│   ├── progress_controller.dart   # Conclusão de estandes e missões
│   ├── sandbox_controller.dart    # Motor de simulação da Bancada Livre
│   └── settings_controller.dart   # Reatividade de tema e acessibilidade
├── services/                      # Persistência e repositórios locais
│   ├── audio_service.dart         # Gerenciamento de trilha e efeitos sonoros
│   └── settings_service.dart      # Interface com SharedPreferences
└── widgets/                       # Widgets reutilizáveis (HUD, Prof. Volts, Backgrounds)
```

---

## 🔄 4. Provedores Riverpod Principais

| Provedor | Tipo | Responsabilidade |
|---|---|---|
| `sharedPreferencesProvider` | `Provider<SharedPreferences>` | Acesso à instância única do storage local. |
| `settingsRepositoryProvider` | `Provider<SettingsRepository>` | Abstração de persistência das configurações. |
| `settingsControllerProvider` | `NotifierProvider<SettingsController, SettingsModel>` | Reatividade de tema, escala de fonte e preferências. |
| `progressControllerProvider` | `NotifierProvider<ProgressController, ProgressState>` | Acompanhamento do progresso geral da feira e estrelas. |
| `sandboxControllerProvider` | `NotifierProvider<SandboxController, SandboxState>` | Estado reativo da Bancada Livre, grafo e solver. |
| `audioServiceProvider` | `Provider<AudioService>` | Reprodução de efeitos de clique, acerto e curto-circuito. |

---

## 💾 5. Persistência de Dados (`SharedPreferences`)

As informações são persistidas como JSON ou strings simples:

* `eletrolab.settings.v1`: Configurações de tema, escala de interface, alto contraste e animação.
* `eletrolab.first_bench_flow`: Estado da jornada do Estande 1 (`currentPhaseId`, `completedPhaseIds`).
* `eletrolab.second_bench_flow`: Estado da jornada do Estande 2.
* `sandbox_components` / `sandbox_wires`: Componentes e fios posicionados na Bancada Livre.
* `completed_challenges`: Identificadores de missões e estandes concluídos na feira.

---

## 🔗 Próximas Leituras

* [Telas, UX e Fluxos](ux-e-fluxos.md)
* [Conteúdo: Estandes, Missões e Rubricas](conteudo.md)
* [Requisitos do Sistema](requisitos.md)
