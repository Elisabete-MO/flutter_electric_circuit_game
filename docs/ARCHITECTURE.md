# Arquitetura e Estado Técnico

## Autoridade e escopo

O código-fonte é a autoridade para o comportamento em runtime. Este documento resume o estado técnico implementado no momento da sua escrita. Decisões de produto, pedagógicas e de campanha pertencem ao `ROADMAP` e a especificações externas a serem adicionadas ao repositório.

## Runtime

| Camada | Tecnologia | Observação |
| --- | --- | --- |
| Framework | Flutter | Mobile, desktop, web |
| Estado | Riverpod | Providers para controllers e serviços |
| UI | MaterialApp + rotas nomeadas | Navegação declarativa |
| Renderização | CustomPainter | Circuitos, fios, instrumentos, backgrounds |
| Persistência | SharedPreferences | Progresso, settings, sandbox, histórico |
| Localização | flutter_localizations + intl | PT/EN, auto-gerado via `lib/l10n/` |
| Solver | Dart isolate via `compute()` | DFS ou MNA, selecionado por conveniência |

## Navegação

Rotas definidas em `lib/app/routes.dart`:

| Rota | Tela | Status |
| --- | --- | --- |
| `/` | MainMenuScreen | Ativa |
| `/intro` | IntroScreen | Ativa |
| `/home` | HomeScreen | Ativa |
| `/first-steps` | FirstStepsScreen | Ativa |
| `/second-bench` | SecondBenchFlowScreen | Ativa |
| `/liga-desliga` | LigaDesligaScreen | Ativa (estande 3) |
| `/ruas-maquete` | RuasMaqueteScreen | Ativa (estande 4) |
| `/letreros-led` | LetrerosLedScreen | Ativa (estande 5) |
| `/movimento-miniatura` | MovimentoMiniaturaScreen | Ativa (estande 6) |
| `/mede-testa-explica` | MedeTestaExplicaScreen | Ativa (estande 7) |
| `/sandbox` | SandboxScreen | Ativa |
| `/settings` | SettingsScreen | Ativa |

**Estandes ainda sem fluxo implementado:** 8–12 (definidos em `StandData` mas sem tela de missão).

## Estado

### Controllers

| Controller | Responsabilidade |
| --- | --- |
| `SandboxController` | Estado da Bancada Livre: componentes, fios, seleção, undo/redo, simulação |
| `ProgressController` | Progresso do aluno: fases concluídas, estandes desbloqueados |
| `SettingsController` | Preferências: tema, som, idioma |
| `CircuitUndoRedoController` | Pilhas de undo/redo para circuitos (usado por missões) |

### Modelos de estado

| Modelo | Uso |
| --- | --- |
| `SandboxState` | Snapshot completo do circuito (componentes, fios, wire mode) |
| `FirstBenchFlowState` | Fluxo do Primeiro Stand (legado, removido — dados em SharedPreferences podem persistir em dispositivos) |
| `SecondBenchFlowState` | Fluxo do Estande 2 com fases desbloqueáveis |
| `StandFlowState` | Fluxo genérico dos estandes 3–7 |
| `SettingsModel` | Configurações serializáveis |

## Bancada Livre

A Bancada Livre (`SandboxScreen`) é o modo de exploração aberta. Capacidades implementadas:

| Capacidade | Detalhe |
| --- | --- |
| Paleta de componentes | 14 tipos: resistor, LED, capacitor, diodo, motor, buzzer, fusível, potenciômetro, fonte, interruptor (SPST), lâmpada, fio,terminal, conectores |
| Colocação e arraste | Snap ao grid, rotação (0°/90°/180°/270°) |
| Conexão por fios | Fios com terminais, snap a terminais de componentes |
| Undo / redo | Pilha de ações por circuito |
| Presets | Circuitos pré-definidos para carregamento rápido |
| Persistência | Auto-save e restore via SharedPreferences |
| Instrumentos | Multímetro, osciloscópio, painel de métricas, mascot (Prof. Volts), inspetor inteligente, exportação |
| Renderização | Modo físico (imagens reais) e esquemático (símbolos IEC) |
| Solver | DFS ou MNA, executado em isolate |

> **Capacidade de UI ≠ fidelidade do modelo elétrico.** A interface permite montar circuitos que o solver pode não representar com precisão física completa (ver seção Solver).

## Topologia

| Conceito | Comportamento |
| --- | --- |
| Conectividade | Fios conectam terminais; posição visual não determina topologia |
| Série / Paralelo | Determinados pela conectividade do grafo, não pela posição espacial |
| Modelo predominante | Dois terminais por componente (A/B) |
| Limitação multipinos | Potenciômetro tem terminal visual W sem participação elétrica completa; relé e componentes multipinos não suportados |
| Polaridade | Respeitada para LED e fonte; `+`/`−` não representam sentido da corrente |
| Cores de fios | Informativas, não substituem conectividade |

## Solver

Dois algoritmos estão implementados:

| Algoritmo | Quando usado | Abordagem |
| --- | --- | --- |
| DFS | Selecionado por conveniência | Análise de conectividade e caminhos |
| MNA (Modified Nodal Analysis) | Selecionado por conveniência | Matrizes de conductância,resolve correntes e tensões |

O seletor escolhe o solver com base na conveniência para o circuito dado. Ambos são executados em `compute()` (Dart isolate) para não bloquear a UI.

> Este não é um SPICE nem um simulador universal. Trata-se de modelo didático com aproximações.

### Limitações elétricas conhecidas

| Item | Situação atual |
| --- | --- |
| LED | Comportamento/modelagem divergente entre DFS e MNA; `Vf`, corrente e resistência equivalente não coerentes entre caminhos |
| Motor | Resistência fixa usada no solver difere do valor default na UI |
| Capacitor | Sem modelo capacitivo/transiente; aproximado resistivamente |
| Potenciômetro | Terminal W exposto visualmente sem suporte elétrico completo |
| Curto-circuito | Critério resistivo (DFS) difere do critério por corrente (MNA) |
| Valores hardcoded | Diversos parâmetros (tensão da fonte, limites de corrente) fixos no código |

Essas limitações são alvos da **Frente 0** no ROADMAP.

## Persistência

| Dado | Key SharedPreferences | Ciclo de vida |
| --- | --- | --- |
| Progresso do aluno | `progress_v1` | Salvo a cada conclusão de fase |
| Settings | `settings_v1` | Salvo a cada mudança |
| Sandbox (circuito) | `sandbox_v1` | Auto-save a cada ação |
| Sandbox (wire mode) | `sandbox_wire_mode` | Salvo a cada toggle |
| Histórico de simulções | `simulation_history_v1` | Salvo a cada simulação |
| Flow Estande 2 | `second_bench_flow_v1` | Salvo a cada transição de fase |

## Testes

| Métrica | Valor |
| --- | --- |
| Arquivos de teste | 9 |
| Casos de teste | 47 |
| `flutter analyze` | No issues found |
| `flutter test` | All tests passed |

Cobertura: circuit validator, sandbox, fluxo do Estande 2 (fases 1–3), missões dos estandes 3–7, alinhamento de terminais, home/intro/settings.

> PLACEHOLDERs e testes exclusivos do Primeiro Stand foram removidos na limpeza estrutural.

---

> **Princípio de precisão elétrica:** Quando precisão elétrica e conveniência visual entrarem em conflito, preservar primeiro a precisão elétrica.
