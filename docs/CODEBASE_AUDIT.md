# EletroLab — Auditoria do Código Atual

```text
Status: auditoria factual do código
Autoridade para estado implementado: código do commit auditado
Não é especificação de produto futuro
```

Auditoria exclusivamente de leitura/inspeção/execução não destrutiva.
Nenhum arquivo de código, teste, asset ou documentação existente foi alterado.
O único arquivo criado por esta tarefa é este `CODEBASE_AUDIT.md`.

Legenda de classificação usada nas tabelas:

* **VERIFICADO** — evidência direta lida no código (com local).
* **PARCIAL** — evidência direta cobre só parte da afirmação.
* **NÃO VERIFICADO** — sem evidência localizada; não afirmar como fato.
* **CONTRADITÓRIO** — duas evidências do repositório conflitam.
* **APROXIMAÇÃO** — modelo didático/simplificado assumido pelo código.
* **POSSIVELMENTE LEGADO** — código sem referência aparente, sem prova de uso em runtime.

---

## 1. Snapshot da auditoria

| Evidência | Estado | Local no código | Observação |
| --------- | ------ | --------------- | ---------- |
| Branch atual `refactor/tests` | **VERIFICADO** | `git branch --show-current` | — |
| Commit auditado (`HEAD`) `0a8885aa84bfa08b07473acf23486c46acc42b0a` | **VERIFICADO** | `git rev-parse HEAD` | Mensagem: `feat(ui): use floor.png (gym fair background) across stand screens` |
| Working tree limpo no início | **VERIFICADO** | `git status --porcelain` vazio; `git diff --stat` vazio | Nenhum modificado, nenhum não rastreado |
| `CODEBASE_AUDIT.md` parcial anterior inexistente | **VERIFICADO** | glob `CODEBASE_AUDIT.md` sem resultados antes da redação | Nada foi reaproveitado; auditoria refeita do zero |
| Flutter 3.44.9 (stable, revision `6b182d2c75`) | **VERIFICADO** | `flutter --version` | Engine `b9499e4c25`, DevTools 2.57.0 |
| Dart 3.12.2 | **VERIFICADO** | `dart --version` + `pubspec.yaml:22` (`sdk: ^3.12.2`) | — |
| SO/ambiente | **VERIFICADO** | `uname -a` / `lsb_release` | Debian 12 (bookworm), kernel 6.1.0-52-amd64, x86_64 |
| Versão do app `1.0.0+1` | **VERIFICADO** | `pubspec.yaml:19` | **CONTRADITÓRIO**: rodapé do menu exibe `EletroLab v1.2.0` (`lib/screens/main_menu/main_menu_screen.dart:226`) |
| Nenhuma operação mutante de git executada | **VERIFICADO** | — | Sem checkout/reset/clean/stash/rebase/merge/commit/push |

Escopo de arquivos inspecionados: `lib/` (196 arquivos `.dart`), `test/` (20 arquivos `.dart`),
`pubspec.yaml` / `pubspec.lock`, `analysis_options.yaml`, `assets/` (inventário + referências no código),
`docs/` + `README.md` (somente após concluir a análise do código, seção 20).

Diretórios ignorados por serem gerados/dependências: `.git/`, `.dart_tool/`, `build/`,
`android/.gradle/`, `.idea/`, `.omo/`, `.codegraph/`.

---

## 2. Resumo executivo

1. O app real é um aplicativo Flutter + Riverpod com 13 rotas nomeadas, tela inicial em
   `Routes.menu` (`MainMenuScreen`), mapa da feira (`HomeScreen`) e Bancada Livre (`SandboxScreen`).
2. O núcleo elétrico funcional é o trio `models/sandbox_*.dart` + `services/circuit_solver/*`
   (seletor DFS/MNA) + `state/sandbox_controller.dart`. Camadas com nomes promissores
   (`lib/domain/**`, `lib/application/**`, `lib/game/**`, `lib/mvp/**`,
   `lib/presentation/**`, `lib/infrastructure/**`) estão **vazias (0 bytes)** — ver seção 18.
3. `flame: ^1.38.0` está declarado no `pubspec.yaml` mas **nenhum arquivo `.dart` importa `package:flame`**;
   idem para `confetti` (só existe um overlay próprio com nome similar). `audioplayers` é usado só em
   `lib/services/audio_service.dart`, com sons **desabilitados por flag** e arquivos ausentes.
4. A rota `Routes.firstBench` (`/first-bench`) está registrada mas **nenhum código navega para ela**
   (grep sem ocorrências) — rota morta; as telas `first_bench_*` só são exercitadas por testes.
5. Estandes 8–11 do mapa exibem `SnackBar "... ainda não disponível."` (`home_screen.dart:66-77`);
   só os estandes 1–7 e a Bancada Livre (12) têm destino real.
6. Divergências modelo-vs-solver: `motor` default `15.0` mas solvers fixam `2.0 Ω`;
   `capacitor` default `100.0 µF` mas solvers usam `10.0 Ω`;
   LED usa `value` como ohms no DFS e como `2.0 Ω` no MNA, com limiares de queima separados;
   preset `led_resistor` cria LED com `value: 10.0` contra default `2.0`.
7. Potenciômetro é o único componente com 3 terminais (`A`, `B`, `W` em
   `models/component_terminals.dart:56-60`), mas fios (`SandboxWire`) e ambos os solvers só conhecem
   terminais `A`/`B` — o terminal `W` não participa da simulação.
8. `flutter analyze`: **No issues found**. `flutter test`: **80 testes, todos passaram (exit 0)**,
   incluindo 5 arquivos placeholder triviais (`expect(true, isTrue)`).
9. Referência quebrada verificada: `science_fair_map.dart:55` carrega
   `assets/stands/background2.png`, que **não existe no disco**. `assets/sounds/*.mp3`
   referenciados por `audio_service.dart` também não existem (só `.gitkeep`), com mitigação por
   `try/catch` + `isSoundEnabled = false`.
10. Persistência real é só `shared_preferences` (sem versionamento, exceto `snapshotVersion` no fluxo
    do Estande 1 e `storageKey` de settings). Valores de simulação, queimados e histórico de
    undo/redo **não** são restaurados.

---

## 3. Estrutura do repositório

```text
lib/
  app/            app.dart, routes.dart, theme.dart        (ativos)
  application/    editor/, session/, simulation/, validation/ (VAZIOS)
  components/     7 arquivos (VAZIOS — ex-Flame?)
  core/           4/5 vazios; ui_scale.dart ativo (ver abaixo)
  domain/         activities/, circuit/ (5), simulation/ (3), validation/ (2) — TODOS VAZIOS
  game/           2 arquivos VAZIOS
  infrastructure/ serialization/circuit_serializer.dart VAZIO
  l10n/           app_localizations*.dart + app_en/pt.arb (ativos, gerados)
  models/         13 ativos (sandbox_*, first_step_component, flows, settings, stand_*, ...)
                  4 vazios: phase1_circuit, terminal, terminal_id, wire_connection
  mvp/            6 arquivos VAZIOS
  presentation/   screens/ + theme/ + widgets/ VAZIOS (1+1+4 arquivos)
  screens/        assembly_screen.dart VAZIO; schematic_screen.dart VAZIO; demais ativos
  services/       audio, circuit_solver/ (4 ativos), circuit_validator, history, sandbox_persist, settings
  state/          4 ativos (sandbox, progress, settings, circuit_undo_redo)
  widgets/        ~32 ativos (*painters, Prof. Volts, workbench_*); 5 vazios
```

| Evidência | Estado | Local no código | Observação |
| --------- | ------ | --------------- | ---------- |
| 196 `.dart` em `lib/`, 20 em `test/` (216 total) | **VERIFICADO** | `find lib test -name '*.dart'` | — |
| 54 arquivos `.dart` com 0 bytes | **VERIFICADO** | `find lib -name '*.dart' -size 0` | Lista completa na seção 18 |
| `lib/domain/**` inteiro vazio (11 arquivos) | **VERIFICADO** | `wc -c lib/domain/...` = 0 | Nomes (MNA/netlist/equivalence) não têm implementação ali |
| `lib/application/**`, `lib/game/**`, `lib/mvp/**` vazios | **VERIFICADO** | idem | Arquitetura em camadas dos docs não existe no código |
| `lib/core/ui_scale.dart` é o único ativo de `core/` | **PARCIAL** | listagem `ls lib/core` + leitura parcial | `app_theme/constants/eletrolab_colors/phase1_navigator` vazios |
| `assembly_screen.dart` e `schematic_screen.dart` vazios e fora das rotas | **VERIFICADO** | `wc -c` = 0; `routes.dart` sem referência | Telas legadas/abandonadas prováveis |

---

## 4. Stack e runtime real

| Dependência declarada | Estado de uso | Evidência |
| --------- | ------ | --------- |
| `flutter` / `flutter_localizations` (SDK) | **VERIFICADO** em uso | `app.dart:2-3`, l10n |
| `flutter_riverpod ^3.4.2` | **VERIFICADO** em uso | `main.dart`, `app.dart`, controllers, telas; `Notifier`/`NotifierProvider` |
| `shared_preferences ^2.5.5` | **VERIFICADO** em uso | `main.dart:9`, `progress_controller`, `sandbox_persistence_repository`, `settings_service`, telas de fluxo |
| `google_fonts ^8.2.1` | **VERIFICADO** em uso amplo | ~79 imports (`theme.dart`, telas, widgets) |
| `intl ^0.20.2` | **VERIFICADO** em uso | `lib/l10n/app_localizations*.dart` |
| `audioplayers ^6.8.1` | **PARCIAL** (código ativo, efeito nulo) | Só `services/audio_service.dart`; `isSoundEnabled = false` (linha 12); `sounds/*.mp3` inexistentes |
| `flame ^1.38.0` | **POSSIVELMENTE LEGADO** / sem uso | Declarado (`pubspec.yaml:38`, lock confirma); **zero** imports `package:flame` em `lib/` e `test/` |
| `confetti ^0.8.0` | **POSSIVELMENTE LEGADO** / sem uso | Declarado; **zero** imports `package:confetti`; `success_confetti_overlay.dart` é implementação própria |
| `cupertino_icons ^1.0.8` | **NÃO VERIFICADO** | Declarado; uso não rastreado nesta auditoria (sem evidência coletada) |
| `CustomPainter` | **VERIFICADO** em uso | `circuit_symbol_painter`, `component_physical_painter` (1434 linhas), `schematic_symbol_painters` (970), `realistic_wire_painter`, `burned_effects_painter`, `sandbox_grid_painters` (838), `ruas_maquete_painter`, etc. |
| `compute()` (isolate) no solver | **VERIFICADO** | `circuit_solver_service.dart:71-74` |

Mapa da arquitetura real observada (não a dos docs):

```text
main.dart (ProviderScope + SharedPreferences + SettingsService)
  -> EletroLabApp (MaterialApp, 13 rotas, LandscapeGuard, i18n pt/en)
    -> telas (StatefulWidget + Riverpod seletivo)
      -> SandboxController (Notifier<SandboxState>) -> CircuitSolverService (compute/isolate)
      -> ProgressController / SettingsController (Notifiers + SharedPreferences)
      -> validações locais por missão (CircuitValidator | MissionCircuitBuilder | booleanos locais)
    -> persistência direta: SharedPreferences (5 grupos de keys, seção 14)
```

---

## 5. Entry point e navegação

| Evidência | Estado | Local no código | Observação |
| --------- | ------ | --------------- | ---------- |
| Entry point `main()` trava orientação em landscape e injeta `SharedPreferences` + `SettingsService`/`SettingsController` | **VERIFICADO** | `lib/main.dart:11-35` | `landscapeLeft/Right` |
| Rota inicial `/` = `MainMenuScreen` | **VERIFICADO** | `lib/app/app.dart:34`, `lib/app/routes.dart:20,34` | — |
| 13 rotas registradas | **VERIFICADO** | `lib/app/routes.dart:33-47` | menu, intro, home, first-steps, first-bench, second-bench, liga-desliga, ruas-maquete, letreros-led, movimento-miniatura, mede-testa-explica, sandbox, settings |
| Menu navega para home/intro/sandbox/firstSteps/settings | **VERIFICADO** | `main_menu_screen.dart:106-108,121-123,176-178,192-194,207-209,256` | — |
| Mapa roteia estandes 1–7 + Bancada; 8–11 caem em SnackBar "ainda não disponível" | **VERIFICADO** | `home_screen.dart:48-78` | 1→firstSteps, 2→secondBench, 3→liga, 4→ruas, 5→letreros, 6→movimento, 7→mede_testa, 12→sandbox |
| `Routes.firstBench` sem nenhuma navegação | **VERIFICADO** | grep `Routes\.firstBench` em `lib/` = 0 ocorrências | Rota morta; `first_bench_*` só cobertos por testes |
| `IntroScreen` avança para `/home` | **VERIFICADO** | `intro_screen.dart:175` (`pushReplacementNamed(Routes.home)`) | — |
| `LandscapeGuard` envolve todas as rotas | **VERIFICADO** | `app.dart:36-41`, `widgets/landscape_guard.dart` | — |
| i18n pt/en com locale vindo de settings (`pt` default) | **VERIFICADO** | `app.dart:26-33`, `models/settings_model.dart:52`, `settings_controller.dart:62-65` | `l10n.yaml` + `lib/l10n/` |

---

## 6. Gerenciamento de estado

| Evidência | Estado | Local no código | Observação |
| --------- | ------ | --------------- | ---------- |
| `SandboxController extends Notifier<SandboxState>` com undo/redo (30), CRUD, presets, solver via `compute`, persistência a cada recálculo | **VERIFICADO** | `lib/state/sandbox_controller.dart` (310 linhas) | `HistoryManager<SandboxState>(maxDepth: 30)`; `_recalculateCircuit()` salva após resolver |
| `ProgressController` (concluídos + estrelas máx.) | **VERIFICADO** | `lib/state/progress_controller.dart` | Keys `completed_challenges`, `stars_<id>` |
| `SettingsController` + `SettingsRepository` (fakeável em testes) | **VERIFICADO** | `lib/state/settings_controller.dart`, `lib/services/settings_service.dart` | Falha de save restaura `initial`/default (linhas 67-74) |
| `CircuitUndoRedoController` + `CircuitAction` (insert/rotate) para missões hardcoded | **VERIFICADO** (uso; conteúdo do controller não lido a fundo) | `lib/state/circuit_undo_redo_controller.dart`, `lib/models/circuit_action.dart`, uso em `liga_desliga_m1.dart:37,78-100` | — |
| `StandFlowState` (`common_stand`) e `FirstBenchFlowState`/`SecondBenchFlowState` | **VERIFICADO** | `screens/common_stand/stand_flow_state.dart` (91), `models/first_bench_flow.dart` (147), `models/second_bench_flow.dart` (182) | Fluxo E1 com `snapshotVersion` e `fromJson` seguro |
| Estado local `setState` por missão (slots, chaves, previsão) | **VERIFICADO** | ex. `liga_desliga_m1.dart:39-46` (`_switchInserted`, `_batteryRotation`, …) | Padrão das missões hardcoded |

---

## 7. Telas e fluxos alcançáveis

| Tela/Fluxo | Alcançável? | Evidência |
| --------- | ------ | --------- |
| `MainMenuScreen` (`/`) | **VERIFICADO** sim (inicial) | `app.dart:34` |
| `IntroScreen` | **VERIFICADO** sim (menu + testes) | `main_menu_screen.dart:121-123` |
| `HomeScreen` (mapa, flag `useExperimentalHorizontalMap = true`) | **VERIFICADO** sim | `home_screen.dart:20`, menu + intro |
| `FirstStepsScreen` (catálogo/quiz) | **VERIFICADO** sim | menu + mapa estande 1 |
| `SecondBenchFlowScreen` (Estande 2 "Acende Aí", 4 fases) | **VERIFICADO** sim | mapa estande 2 |
| `LigaDesligaScreen` + M1–M5 | **VERIFICADO** sim | mapa estande 3 |
| `RuasMaqueteScreen` + M1–M5 | **VERIFICADO** sim | mapa estande 4 |
| `LetrerosLedScreen` + M1–M5 | **VERIFICADO** sim | mapa estande 5 |
| `MovimentoMiniaturaScreen` + M1–M5 | **VERIFICADO** sim | mapa estande 6 |
| `MedeTestaExplicaScreen` + M1–M5 | **VERIFICADO** sim | mapa estande 7 |
| `SandboxScreen` (Bancada Livre) | **VERIFICADO** sim | menu + mapa estande 12 |
| `SettingsScreen` | **VERIFICADO** sim | menu (`:256`) |
| `FirstBenchFlowScreen` (`/first-bench`, 4 fases) | **CONTRADITÓRIO** registrado porém inalcançável | Rota existe; zero navegações; fases grandes (1737/1552/1189/1677 linhas) e testes próprios |
| Estandes 8 (Circuito Seguro), 9 (Horta), 10 (Portão), 11 (Praça/Maquete) | **VERIFICADO** não implementados como fluxo | SnackBar em `home_screen.dart:66-77`; 11 abre só diálogo informativo (`_onTapMaqueteColetiva`) |
| `assembly_screen.dart`, `schematic_screen.dart` | **POSSIVELMENTE LEGADO** | Vazios e fora de `Routes.all` |

---

## 8. Componentes elétricos

Enum único: `ComponentType` (`lib/models/first_step_component.dart:2-16`):
`battery, connectingWire, switchComponent, bulb, resistor, diode, led, motor, potentiometer, powerSupply, fuse, capacitor, buzzer` (13 valores).

| Componente (nome no código) | Default (`sandbox_component.dart:23-48`) | Modelo no solver | Paleta Bancada | Assets | Observação |
| --------- | ------ | --------- | --------- | --------- | ---------- |
| `battery` | `9.0` V | Fonte ideal `src.value` (DFS e MNA) | **VERIFICADO** sim (`sandbox_toolbox.dart:27`) | `battery.png`, `component_battery_horizontal.png` | Pólos: fonte B(+)/A(−) nos solvers |
| `powerSupply` | `12.0` V | Fonte ideal `src.value` | **VERIFICADO** sim | `power_supply.png` | Terminais rotulados `-`/`+` em `component_terminals.dart:61-64` |
| `switchComponent` | `isActive=false` | Fechado `R=0.01` / aberto = circuito aberto (MNA `133`; DFS bloqueia em `214-218`) | **VERIFICADO** sim | `switch_open/closed.png` | Só SPST 2-terminais; sem SPDT/momentâneo no modelo |
| `bulb` | `5.0` Ω | `R=c.value` (ambos); queima se `power>15W` | **VERIFICADO** sim | `bulb_on/off.png` | Presets usam `10.0` (divergência de default) |
| `resistor` | `220.0` Ω | `R=c.value` (ambos) | **VERIFICADO** sim | `resistor.png` | Único sem aproximação no solver |
| `potentiometer` | `50.0` Ω | `R=c.value` (MNA `122-124`, DFS via `c.value`) | **VERIFICADO** sim | `potentiometer.png` | Terminal `W` ignorado (seção 9) |
| `motor` | `15.0` Ω (default) | **`R=2.0` fixo** (DFS `69,99`; MNA `125,253`); queima se `vDrop>18V` | **VERIFICADO** sim | `motor.png` | **CONTRADITÓRIO**: `value` do modelo ignorado |
| `led` | `2.0` (comentário: "queda de 2.0V") | DFS: `value` como **ohms**; MNA: **`2.0 Ω` fixo**; queima se `I>50mA` ou `vDrop>3.3V`; Vf 1.8V na iteração de diodos (MNA `193`) | **VERIFICADO** sim | `led_on/off.png` | **APROXIMAÇÃO**; preset usa `value: 10.0` |
| `diode` | `1.0` (default genérico) | DFS: `value` como ohms; MNA: `0.5 Ω` + Vf `0.7V` | **VERIFICADO** sim | `diode.png`, `component_diode.png` | Bloqueio reverso por rotação (ambos) |
| `fuse` | `2.0` A (limite) | `R=0.1`; queima se `I>value` | **VERIFICADO** sim | `fuse.png` | Modelo coerente entre UI e solver |
| `capacitor` | `100.0` µF | **`R=10.0 Ω` fixo** (DFS `67,95`; MNA `131,259`) | **VERIFICADO** sim | `capacitor.png` | **APROXIMAÇÃO**: tratado como resistor; µF nunca usados |
| `buzzer` | `8.0` Ω | `R=8.0` fixo | **VERIFICADO** sim | `buzzer.png` | Coerente com default |
| `connectingWire` | — (sem default; cai em `1.0`) | Sem modelo: fios ideais unem nós | **NÃO VERIFICADO** na paleta (`_availableTypes` não o inclui) | `wires.png` | Só aparece no catálogo Primeiros Passos |

Inconsistências modelo × solver × UI: ver seção 19.

---

## 9. Modelo de terminais, fios e topologia

| Evidência | Estado | Local no código | Observação |
| --------- | ------ | --------------- | ---------- |
| Fios ligam `componente+terminal` a `componente+terminal`, terminais `'A'`/`'B'` (strings livres) | **VERIFICADO** | `models/sandbox_wire.dart:1-51` | Sem tipo/nó/junção de primeira classe |
| Modelo sandbox assume 2 terminais (posições A/B por rotação 0/90/180/270) | **VERIFICADO** | `sandbox_component.dart:72-100` | — |
| Mapa visual de terminais com rótulos (`+`,`-`,`A`,`B`,`K`,`W`) e rotação trigonométrica | **VERIFICADO** | `models/component_terminals.dart:15-90` | Bateria `+`/`-`, LED `A`/`K`, diodo `A`/`K`, motor/buzzer/cap `+`/`-` |
| Potenciômetro tem 3º terminal `W` sem suporte em fios/solver | **VERIFICADO** | `component_terminals.dart:56-60` vs `sandbox_wire.dart` + solvers (`${id}_A/B` apenas) | Suporte multipino: **não** |
| Série/paralelo derivam só de conectividade (DSU sobre `${id}_{A,B}` + fios) | **VERIFICADO** | `circuit_solver_service.dart:28-69` (seletor), `mna_circuit_solver.dart:19-47`, DFS por travessia de fios | Posição no grid nunca é lida pelo solver |
| Validação antes de conectar: proíbe terminal-em-si e fio duplicado (bidirecional) | **VERIFICADO** | `sandbox_controller.dart:163-178` | Sem checagem de curto/loop na inserção |
| Validações após: solver marca curto, queimados, erros pedagógicos | **VERIFICADO** | `dfs_circuit_solver.dart:73-80,116-143`; `mna_circuit_solver.dart:283-333` | — |
| Rotação em graus múltiplos de 90, persistida | **VERIFICADO** | `sandbox_component.dart:10,102-124`; `rotateComponents` em `sandbox_controller.dart:123-135` | Rotação afeta polaridade de diodo/LED nos solvers |
| `+`/`-` = potencial/polaridade; cor de fio não indica sentido | **VERIFICADO** (convenção no código) | Solvers usam A(− terra)/B(+) só como referência nodal; `sandbox_screen.dart:325` cita terminais "vermelho/preto" como UI | Sem semântica de corrente por cor |
| Equivalência topológica dedicada | **NÃO VERIFICADO** | `domain/validation/equivalence_checker.dart` vazio; teste homônimo é placeholder | — |

Respostas objetivas: o modelo atual assume dois terminais; todos os componentes seguem isso no
runtime (exceção apenas visual do `W`); não há suporte real a multipinos; o solver usa
conectividade, não posição; série/paralelo emergem do grafo.

---

## 10. Solver e simulação

Arquivos: `services/circuit_solver/circuit_solver_service.dart` (seletor + `compute`),
`dfs_circuit_solver.dart` (257 linhas), `mna_circuit_solver.dart` (402 linhas),
`mission_circuit_builder.dart` (331 linhas, helper de missões), `circuit_solver_strategy.dart` (interface).

| Evidência | Estado | Local no código | Observação |
| --------- | ------ | --------------- | ---------- |
| Seletor: >1 fonte **ou** qualquer nó com >2 terminais → MNA; senão DFS | **VERIFICADO** | `circuit_solver_service.dart:15-69` | Heurística estrutural, não de tamanho |
| Execução em isolate via `compute(solveCircuitInIsolate, state)` | **VERIFICADO** | `circuit_solver_service.dart:9-12,71-74` | — |
| DFS: travessia a partir do terminal `B` da fonte; fecha loop ao retornar ao `A` da mesma fonte | **VERIFICADO** | `dfs_circuit_solver.dart:41-54,198-202` | `I = V/R` por loop; soma correntes de loops |
| DFS: sem fonte → `Sem fonte de energia no circuito.`; `R<=0.1` → curto | **VERIFICADO** | `dfs_circuit_solver.dart:22-27,73-80` | Só loops quase-ideais disparam curto no DFS |
| MNA: DSU de nós, GND = terminal A da primeira fonte, gmin `1e-9`, Gauss com pivô, até 10 iterações de diodos | **VERIFICADO** | `mna_circuit_solver.dart:99-213,344-392` | Implementação própria, sem pacote numérico |
| MNA: diodos/LED partem conduzindo; abrem se `vDiff<0`, fecham se `vDiff>Vf` (0.7/1.8) | **VERIFICADO** | `mna_circuit_solver.dart:178-208` | **APROXIMAÇÃO** didática |
| Limiares de queima idênticos nos dois solvers: LED `I>50mA` ou `V>3.3V`; lâmpada `P>15W`; motor `V>18V`; fusível `I>value` | **VERIFICADO** | DFS `118-143`; MNA `285-310` | Queimados viram circuito aberto (`211`, `113`) |
| Curto no MNA: corrente de fonte `>20A` | **VERIFICADO** | `mna_circuit_solver.dart:314-333` | Critério diferente do DFS |
| Saídas por componente: `active_`, `current_`, `voltage_drop_`, `power_`, `node_voltage_<id>_{A,B}` | **VERIFICADO** | DFS `105-114,147-150`; MNA `235-281` | Multímetro lê `node_voltage_*` (seção 11) |
| Sem fonte → erro e valores vazios; `isSimulating=false` limpa valores | **VERIFICADO** | DFS `10-27`; MNA `8-13,80-85` | — |
| `MissionCircuitBuilder` monta circuito ideal e resume `{isSuccess, hasClosedLoop, current, ...}` | **VERIFICADO** | `mission_circuit_builder.dart:244-280` | `isSuccess = error==null && !short`; usado pelas missões dos estandes 4–7 |
| `hasClosedLoop()` auxiliar só considera `battery` (ignora `powerSupply`) e chave aberta | **PARCIAL** | `mission_circuit_builder.dart:283-330` | Divergência menor vs solver completo |
| Constantes hardcoded: fuse `0.1`, capacitor `10.0`, buzzer `8.0`, motor `2.0`, diodo `0.5`, LED `2.0`, chave fechada `0.01`, gmin `1e-9`, curto `20A` | **VERIFICADO** | MNA `120-139,248-267`; DFS `66-71,93-101` | — |
| Valores de UI ignorados: `motor.value`, `capacitor.value`, `diode.value`, LED (MNA) | **VERIFICADO** | linhas acima | Edição de valor desses componentes não muda a física |

LED (regras específicas): polaridade modelada por rotação (DFS `220-230`; MNA `187-190`;
MNA: ânodo em A se rotação 0/90); sem resistor dedicado obrigatório no solver — a proteção aparece
via limiar de 50 mA/3.3 V e mensagens pedagógicas; reverso bloqueia (circuito aberto ideal, sem
corrente de fuga). Fontes: tensão de `value` (defaults 9/12 V), terminais A(−)/B(+).
Interruptores: só SPST de 2 terminais com `isActive`; texto de missão cita "SPST" e
"botão de pressão", mas o modelo não tem tipo momentâneo.

---

## 11. Bancada Livre

`lib/screens/sandbox/sandbox_screen.dart` (1773 linhas) + 10 widgets + `sandbox_smart_inspector.dart`.

| Capacidade | Estado | Evidência |
| --------- | ------ | --------- |
| Paleta com 12 tipos (drag `Draggable<ComponentType>`) | **VERIFICADO** | `sandbox_toolbox.dart:26-39,222-229` (`connectingWire` excluído) |
| Inserção por arrasto, mover (unitário e múltiplo 20×16 com clamp), grade redimensionável 4×3–18×15 (default 8×5) | **VERIFICADO** | `sandbox_controller.dart:48-98`; `sandbox_screen.dart:39-40,570-667` |
| Rotação 90°, toggle ativo, edição de `value`, exclusão (unitária/múltipla), limpar tela | **VERIFICADO** | `sandbox_controller.dart:119-205` |
| Seleção simples e box-selection; atalhos Delete/R/setas/Esc/Ctrl-Z/Ctrl-Y/Espaço | **VERIFICADO** | `sandbox_screen.dart:48-49` (`_boxSelectionStart/Current`), `:361-424` (`CallbackShortcuts`) |
| Fios com snap em alvo (`_snappedTarget`), anti-duplicado | **VERIFICADO** | `sandbox_screen.dart:52`; `sandbox_controller.dart:163-191` |
| Undo/redo (profundidade 30) | **VERIFICADO** | `HistoryManager` + `sandbox_controller.dart:29-46` |
| 4 presets (`simple_bulb`, `switch_motor`, `led_resistor`, `parallel_bulbs`) | **VERIFICADO** | `sandbox_controller.dart:217-281` |
| Persistência de componentes/fios/`isSimulating` | **VERIFICADO** | `sandbox_persistence_repository.dart` |
| Multímetro (V DC, A DC, Ω) lendo `node_voltage_*` do solver + HOLD | **VERIFICADO** | `sandbox_multimeter.dart:8-59`; toggle em `sandbox_screen.dart:66-70,848-851` |
| Osciloscópio com canais CH1(V)/CH2(I), V/div, tempo/div | **PARCIAL** | `sandbox_oscilloscope.dart:1-60`; recebe `voltageSignal/currentSignal` (default 0.0) — fiação aos valores do solver **NÃO VERIFICADA** |
| Métricas por componente, mascote, HUD rápido, inspetor inteligente, exportar relatório | **VERIFICADO** (existência) | `sandbox_metrics_panel.dart` (308), `sandbox_mascot_panel.dart` (221), `sandbox_quick_hud.dart` (244), `sandbox_smart_inspector.dart` (164), `sandbox_export_dialog.dart` (318) |
| Modo diagrama + alternância realista/cartoon | **VERIFICADO** | `_isDiagramMode` / `_useRealisticAssets` (`sandbox_screen.dart:61-62,516-562`) |
| Responsividade (layouts horizontal/vertical, dark/light) | **VERIFICADO** (estrutura) | `sandbox_screen.dart:680-767`; `isDark` propagado |

Separação interface × elétrica: tudo acima da linha de "simulação" é UI; o eletricamente simulado
é só o que os dois solvers modelam (seção 8/10). Paleta ≠ suporte (ex.: `connectingWire` fora da
paleta; `W` do potenciômetro fora do solver; osciloscópio sem fonte de sinal confirmada).

---

## 12. Representação física, esquema e ghost

| Evidência | Estado | Local no código | Observação |
| --------- | ------ | --------------- | ---------- |
| Toggle físico ↔ esquemático na Bancada (`_isDiagramMode`) e nas missões (`_usePhysicalStyle`) | **VERIFICADO** | `sandbox_screen.dart:61,516-517,1321,1468-1513`; `liga_desliga_m1.dart:39`; testes `phase3_test`, `second_bench_phase3_test`, `liga_desliga_m3/m4_test` | — |
| Painters físicos (`ComponentPhysicalPainter`, 1434 linhas) e simbólicos (`CircuitSymbolPainter`, `SchematicSymbolPainters`, 970 linhas) separados | **VERIFICADO** | `widgets/component_physical_painter.dart`, `widgets/circuit_symbol_painter.dart`, `widgets/schematic_symbol_painters.dart` | + `component_vector_painters.dart` (880), `realistic_wire_painter.dart`, `circuit_wire_painter.dart` |
| Sobreposição ghost: asset físico com `Opacity` 0.25/0.30 sob o símbolo no modo diagrama da paleta | **VERIFICADO** | `sandbox_toolbox.dart:132-156` | Composição faded existe como técnica de render, não como missão |
| Sockets físicos/esquemáticos com terminais calibrados | **VERIFICADO** | `widgets/physical_blueprint_socket.dart`, `widgets/schematic_blueprint_socket.dart`, `models/component_terminals.dart` | Cobertos por `socket_terminal_alignment_test.dart` |
| Efeitos de queimado e fios realistas | **VERIFICADO** | `widgets/burned_effects_painter.dart` (128), `widgets/realistic_wire_painter.dart` (326) | — |
| "Missão ghost" pedagógica | **NÃO VERIFICADO** | — | Nada no código usa ghost como etapa de ensino |

---

## 13. Desafios guiados existentes

Todas as missões dos estandes 3–7 seguem o molde arquivo-por-missão + `_validate()` local
(hardcoded com widgets próprios); as fases dos estandes 1–2 são telas de fluxo com estado
persistido. Dados descritivos centrais só em `StandMission` (25 missões, 5 por estande, seção 6).

| Experiência | Arquivo(s)/rota | Validação | Solver? | Classificação |
| --------- | ------ | --------- | ------- | ------------- |
| Primeiros Passos (catálogo 8 itens + quiz) | `first_steps_screen.dart` (`/first-steps`); dados `FirstStepComponent.defaultList` | Quiz local (não lido a fundo) | Não | **PARCIAL** hardcoded/data mista |
| Estande 1 — fluxo 4 fases (montar/substituir, inspecionar 5 pontos, símbolos, bancada com `CircuitValidator`) | `first_bench/*` (`/first-bench` morta); fase 4 usa `CircuitValidator().validate` (`first_bench_phase4.dart:598-599`) | `CircuitValidator` + estados locais | Validador, não solver numérico | hardcoded |
| Estande 2 "Acende Aí" — 4 fases (montar, inspecionar, diagrama, livre) + `SecondBenchFlowState` em prefs | `second_bench/*` (`/second-bench`); fase 4 usa `CircuitValidator` (`second_bench_phase4.dart:554-555`); tokens em `second_bench_tokens.dart` | `CircuitValidator` + fluxo | Validador | hardcoded |
| Estande 3 Liga e Desliga M1–M5 (SPST, previsão, investigação 2 chaves, desvio paralelo, botão) | `liga_desliga/*` | Booleanos locais (`_isClosed` etc., M1 `:65-66`) + `onEnergizePressed: _validate` | Não (lógica local) | hardcoded |
| Estande 4 Ruas da Maquete M1–M5 (série/paralelo, postes, junções) | `ruas_maquete/*` + `ruas_maquete_painter.dart` | `MissionCircuitBuilder...simulate()` (M1,M3–M5) e lógica local (M2) | **VERIFICADO** sim (M1,M3–M5) | hardcoded com builder |
| Estande 5 Letreros LED M1–M5 (polaridade, 68/680/6k8, 2 ramos) | `letreros_led/*` | `MissionCircuitBuilder` (M1,M3–M5 `:100-146`) | **VERIFICADO** sim | hardcoded com builder |
| Estande 6 Movimento M1–M5 (motor, reversão, diagnóstico, push-button+LED) | `movimento_miniatura/*` | `MissionCircuitBuilder` | **VERIFICADO** sim | hardcoded com builder |
| Estande 7 Mede/Testa M1–M5 (V, queda, I com potenciômetro, escolha por medida) | `mede_testa_explica/*` | `MissionCircuitBuilder` + multímetro didático próprio | **VERIFICADO** sim | hardcoded com builder |
| Pontuação/tempo/tentativas | — | Estrelas máx. por desafio (`ProgressController.markAsCompleted(stars)`) | — | Sem tempo/tentativas no código lido |

Sem evidência de XP, sistema de campanha/Hub, relé ou "Portão da Escola" implementados
(estandes 8–10 sem fluxo). `StandData.defaultStands` lista 12 estandes, mas só 7 + Bancada têm destino.

---

## 14. Persistência

Tecnologia única: `shared_preferences` (sem SQLite/arquivos; sem migração versionada, salvo
`snapshotVersion` do fluxo E1).

| O que | Keys / local | Estado |
| --------- | ------ | ------ |
| Settings (10 campos: tema, locale, 5 flags simulação, escala, contraste, animações) | `eletrolab.settings.v1` (`settings_service.dart:20`) | **VERIFICADO** |
| Bancada: componentes + fios + `isSimulating` (JSON) | `sandbox_components`, `sandbox_wires`, `sandbox_is_simulating` | **VERIFICADO** (`sandbox_persistence_repository.dart`) |
| Progresso: concluídos + estrelas | `completed_challenges`, `stars_<id>` | **VERIFICADO** (`progress_controller.dart:25,34,51`) |
| Fluxo Estande 1 (fase atual, concluídas, versão) | `first_bench_flow_v1` (`first_bench_flow.dart:11`) | **VERIFICADO** |
| Fluxo Estande 2 (lido/escrito direto nas telas) | via `sharedPreferencesProvider` em `second_bench_flow_screen.dart:35,56` | **PARCIAL** (modelo `second_bench_flow.dart` não detalhado aqui) |
| Valores de simulação, `burnedComponentIds`, curto, histórico undo/redo | — (memória) | **VERIFICADO** não persistidos: `load()` reconstrói só componentes/fios/`isSimulating` (`:12-43`); simulação recalculada no `build` (`sandbox_controller.dart:21-27`) |
| Resultados calculados, acessibilidade além de settings | — | **NÃO VERIFICADO** restauração; nada além do acima foi localizado |

---

## 15. Assets

| Categoria | Conteúdo no disco | Estado |
| --------- | ------ | ------ |
| `assets/components/` (15 PNG) | battery, bulb on/off, buzzer, capacitor, diode, fuse, led on/off, motor, potentiometer, power_supply, resistor, switch open/closed, wires | **VERIFICADO** referenciados por `ComponentTypeAssetX.getAssetPath` (`first_step_component.dart:153-184`) |
| `assets/images/` + `assets/images/backgrounds/` (11 PNG) | variantes de bancada/mesa + `component_*` (sem buzzer/cap/fuse/pot/power/wires) | **VERIFICADO** via `getChallengeAssetPath` (fallback para `getAssetPath`) |
| `assets/backgrounds/` (4 PNG) | `background_fase_01/02/03 + floor.png` | **VERIFICADO** em uso (commit HEAD aplica `floor.png`) |
| `assets/stands/` (14 PNG) | `estande_01..12` + 2 trilhas 4k | **PARCIAL**: `estande_10.png` sem referência; `background2.png` referenciado e **inexistente** |
| `assets/intro/` (3 PNG) | `gym_front`, `gym_front_open_door`, `spritesheet_nuri` | **VERIFICADO** (`gym_front.png` no menu `:34`) |
| `assets/references/` (4 PNG) | imagens de referência de layout | **POSSIVELMENTE LEGADO**: fora do `flutter.assets` do pubspec (não empacotadas); só citadas em comentário (`first_bench_phase1.dart:14`) |
| `assets/sounds/`, `assets/icons/` | só `.gitkeep` | **CONTRADITÓRIO**: `audio_service.dart` toca `sounds/{bgm,click,drop,success,error}.mp3` inexistentes (mitigado por flag+try/catch) |
| Fontes/áudio/sprites além disso | — | **NÃO VERIFICADO** existência; seção `fonts:` do pubspec comentada |

Divergência de empacotamento: `background_fase_01` e `background_fase_03` existem duplicados em
`assets/images/backgrounds/` e `assets/backgrounds/` (ambos os dirs declarados no pubspec).
Cor de fio/terminal na UI ("círculos vermelho/preto", `sandbox_screen.dart:324-325`) não tem
semântica elétrica — só UI.

---

## 16. Dependências

Declaradas (`pubspec.yaml:30-43`): flutter(SDK), flutter_localizations(SDK), intl, cupertino_icons,
flame, flutter_riverpod, shared_preferences, google_fonts, audioplayers, confetti.
Dev: flutter_test, flutter_lints. `pubspec.lock` confirma todas como `direct main` (verificado por grep).

| Dependência | Uso real | Classificação |
| --------- | ------ | ------------- |
| flutter_riverpod / shared_preferences / google_fonts / intl / flutter_localizations | Amplo / pontual conforme seção 4 | **VERIFICADO** |
| audioplayers | Só `audio_service.dart`, sons desligados e ausentes | **PARCIAL** |
| flame | Nenhum import em `lib/` ou `test/` | **POSSIVELMENTE LEGADO** (só `pubspec.yaml`+lock) |
| confetti | Nenhum import `package:confetti`; overlay próprio | **POSSIVELMENTE LEGADO** |
| cupertino_icons | Não rastreado | **NÃO VERIFICADO** |

`flutter analyze` resolveu dependências com aviso padrão de 30 pacotes com versões novas
incompatíveis com as restrições (não é erro; nenhuma alteração feita — proibido `pub upgrade`).

---

## 17. Testes

Inventário (`test/`, 20 arquivos). Todos possuem `main()`; nenhum `skip`/ignorado localizado;
nenhum teste de integração (`integration_test/` inexistente).

| Arquivo(s) | Tipo | Estado |
| --------- | ---- | ------ |
| `domain/circuit_solver_test.dart`, `domain/topological_equivalence_test.dart`, `infrastructure/circuit_serializer_test.dart`, `models/phase1_circuit_test.dart`, `widgets/intro_screen_test.dart` | placeholders `expect(true, isTrue)` | **VERIFICADO** ativos porém vazios de asserção útil (alvos: camadas vazias — ver seção 19) |
| `services/circuit_validator_test.dart` (9 testes: LED, resistor 68/6k8/ausente, invertido, aberto, curto) | unitário real | **VERIFICADO** |
| `models/first_bench_flow_test.dart` (5), `screens/second_bench/second_bench_flow_test.dart` (6, inclui serialização) | unit/widget real | **VERIFICADO** |
| `screens/first_bench/phase{1,2,3,4}_test.dart` + `flow_integration_test.dart` (23 no total) | widget/integração de fluxo | **VERIFICADO** |
| `screens/liga_desliga/liga_desliga_m{2,3,4}_test.dart` (13), `screens/second_bench/second_bench_phase{2,3}_test.dart` (7) | widget real | **VERIFICADO** |
| `widgets/socket_terminal_alignment_test.dart` (3: socket 95×95, terminais, bateria 270°) | widget/geometria real | **VERIFICADO** |
| `widget_test.dart` (9: intro, home, settings, sandbox persistência/drag) | widget real | **VERIFICADO** |

Resultados da execução (ambiente da seção 1):

* `flutter analyze` → **exit 0, `No issues found! (ran in 16.0s)`** (após `flutter pub get`
  automático; só avisos de versões disponíveis, sem erros).
* `flutter test` → **exit 0, `+80: All tests passed!`** (~48 s). Nenhum arquivo impediu a suíte;
  nenhum warning/falha/stack. Contagem por arquivo somada dos `test(`/`testWidgets(` ≈ 80.

Nada foi modificado, enfraquecido, removido ou criado em `test/` (proibido pela tarefa).

---

## 18. Código vazio, morto ou possivelmente legado

54 arquivos `.dart` com 0 bytes (**VERIFICADO** por `find -size 0`):

* `domain/`: `activities/pedagogical_task.dart`, `circuit/{circuit_document,component_model,component_type,terminal_model,wire_model}.dart`, `simulation/{circuit_solver,electrical_netlist,simulation_result}.dart`, `validation/{diagnostic_result,equivalence_checker}.dart`
* `application/`: `editor/{editor_notifier,editor_state}.dart`, `session/activity_session_notifier.dart`, `simulation/simulation_notifier.dart`, `validation/validation_notifier.dart`
* `game/`: `electric_circuit_game.dart`, `workbench_game.dart` (nomes sugerem Flame — compõe a evidência de Flame abandonado, **inferência razoável**)
* `mvp/`: `activity_controller, circuit_analysis_panel, diagram_game, diagram_workspace, eletrolab_game, mvp_contract.dart`
* `presentation/`: `screens/eletrolab_main_screen.dart`, `theme/eletrolab_theme.dart`, `widgets/{calculation_panel,json_dialog,schematic_editor,status_banner}_widget.dart`
* `infrastructure/serialization/circuit_serializer.dart` (alvo de teste placeholder — seção 19)
* `components/`: `battery_component, bench_background, glow_component, lamp_component, live_wire_component, moving_dots, terminal_component.dart` (nomes de `FlameGame`/`Component` — **inferência** de spike Flame removido)
* `models/`: `phase1_circuit, terminal, terminal_id, wire_connection.dart`
* `screens/`: `assembly_screen.dart`, `schematic_screen.dart`
* `widgets/`: `circular_carousel, component_card, distractor_symbols, result_modal, volt_widget.dart`
* `core/`: `app_theme, constants, eletrolab_colors, phase1_navigator.dart`

Outros sinais (sem remoção, só registro):

| Evidência | Estado | Local |
| --------- | ------ | ----- |
| Rota `/first-bench` sem navegação | **VERIFICADO** morta | seção 5 |
| `assets/stands/background2.png` referenciado e inexistente | **VERIFICADO** quebrado | `science_fair_map.dart:55` |
| `assets/stands/estande_10.png` sem referência | **VERIFICADO** não referenciado | grep `assets/stands/*` |
| `assets/sounds/*.mp3` inexistentes | **VERIFICADO** quebrado (mitigado) | `audio_service.dart:18,36,46,56,66` |
| `TODO/FIXME/HACK` no código | **VERIFICADO** ausentes | grep só achou "CÁTODO"/comentário de LED |
| `second_bench_tokens.dart` × `common_stand/stand_flow_tokens.dart` (possível duplicação de tokens) | **PARCIAL** (conteúdo não comparado) | arquivos de 33 e 33 linhas |
| `app/theme.dart` (ativo) × `core/app_theme.dart` (vazio) × `presentation/theme/eletrolab_theme.dart` (vazio) | **VERIFICADO** (existência) | triplicação de lugar de tema |
| Comentário de compatibilidade com "código legado" | **VERIFICADO** | `stand_mission.dart:202-204,264-266` |

Confiança: alta para "vazio" e "sem referência" (medição direta); média para "legado/abandonado"
(intenção não é observável; nada deve ser excluído com base nisto).

---

## 19. Divergências internas encontradas

| # | Divergência | Evidência | Classe |
| - | ----------- | --------- | ------ |
| 1 | Versão `1.0.0+1` (pubspec) × `v1.2.0` (rodapé do menu) | `pubspec.yaml:19` × `main_menu_screen.dart:226` | **CONTRADITÓRIO** |
| 2 | `motor` default `15.0` ignorado; solvers usam `2.0` | `sandbox_component.dart:35-36` × DFS `69,99` × MNA `125,253` | **CONTRADITÓRIO** |
| 3 | `capacitor` `100 µF` tratado como `10 Ω`; unidade nunca usada | `sandbox_component.dart:41-42` × DFS `67,95` × MNA `131,259` | **APROXIMAÇÃO** |
| 4 | LED: `value` como ohms (DFS) × `2.0 Ω` fixo (MNA); limiar queima `3.3 V` × Vf `1.8 V` iteração | DFS `70,101,119` × MNA `137,193,286` | **CONTRADITÓRIO** interno |
| 5 | Preset `led_resistor` cria LED `value: 10.0` ≠ default `2.0` | `sandbox_controller.dart:252` × `sandbox_component.dart:37-38` | **CONTRADITÓRIO** |
| 6 | Presets usam lâmpada `10.0` ≠ default `5.0`; bateria `4.5` (simple_bulb) ≠ default `9.0` | `sandbox_controller.dart:226-271` | **PARCIAL** (presets são intencionais, mas divergem dos defaults) |
| 7 | Potenciômetro `W` existe no mapa visual, não em fios/solver | `component_terminals.dart:56-60` × `sandbox_wire.dart` × solvers | **CONTRADITÓRIO** |
| 8 | Curto: `R<=0.1` (DFS) × `I_fonte>20A` (MNA) | DFS `73` × MNA `319` | **CONTRADITÓRIO** (critérios distintos) |
| 9 | `hasClosedLoop()` só enxerga `battery`, solver enxerga `powerSupply` | `mission_circuit_builder.dart:284` × solvers | **PARCIAL** |
| 10 | Rota `/first-bench` registrada, inalcançável | `routes.dart:23,38` × grep zero | **CONTRADITÓRIO** |
| 11 | 12 estandes listados, 7 + Bancada funcionais | `stand_data.dart:57-217` × `home_screen.dart:48-78` | **PARCIAL** |
| 12 | `background2.png` referenciado, inexistente | `science_fair_map.dart:55` × `ls assets/stands` | **CONTRADITÓRIO** |
| 13 | `sounds/*.mp3` referenciados, inexistentes | `audio_service.dart` × `ls assets/sounds` | **CONTRADITÓRIO** (mitigado) |
| 14 | `docs/README.md` declara docs "fonte única de verdade" | `:5` × divergências das seções 5/8/10 e esta tabela | **CONTRADITÓRIO** metodológico |
| 15 | Testes placeholder miram módulos vazios (`circuit_solver`, `equivalence`, `serializer`, `phase1_circuit`) | `test/domain/*`, `test/infrastructure/*`, `test/models/phase1_circuit_test.dart` × arquivos 0 byte | **CONTRADITÓRIO** (cobertura aparente sem alvo) |
| 16 | Texto de missão cita "botão de pressão"/"SPST" sem tipo correspondente no enum | `stand_mission.dart:78` (`liga_desliga_m5`) × `ComponentType` | **PARCIAL** (implementação da M5 não auditada a fundo) |

---

## 20. Documentação existente versus código

Inventário (topo): `README.md` (104 linhas) + `docs/` (`README` 73, `arquitetura` 164,
`assets` 92, `backlog` 88, `conteudo` 114, `requisitos` 78, `ux-e-fluxos` 121, `visao-geral` 79)
+ `docs/referencias/` (5 md + README) + `docs/arquivo_legado/` (19 md). Lidos integralmente:
`docs/README.md` e `docs/arquitetura.md` (parcial, 60 linhas); demais classificados por
título/estrutura e confronto pontual — nenhum foi alterado.

| Documento | Afirmação relevante | Confronto com o código | Classe |
| --------- | ------ | ------ | ------ |
| `docs/README.md` | Docs são "fonte única de verdade"; `conteudo.md` = "10 estandes, 50 missões"; `ux-e-fluxos.md` = "tabela oficial de rotas" | Código: 12 estandes definidos, 7+Bancada funcionais, 25 missões em `StandMission` + fases; rota morta `/first-bench` | **CONTRADITÓRIO** em pontos centrais |
| `docs/arquitetura.md` | Camadas "estritamente desacopladas"; padrão `common_stand` + "coordenador slim"; "Grafo DFS e Riverpod" | `common_stand/` **VERIFICADO** existe e é usado; DFS+Riverpod **VERIFICADO**; `domain/application` vazios contradizem o desacoplamento em camadas | **PARCIAL** (módulos de estande ok; camadas não) |
| `docs/backlog.md` | Estandes 8–10 pendentes (pelo índice do README) | Consistente com SnackBar dos estandes 8–11 no mapa | **PARCIAL** aparentemente atual (não lido integralmente) |
| `docs/conteudo.md`, `requisitos.md`, `ux-e-fluxos.md`, `visao-geral.md`, `assets.md` | — (não lidos integralmente) | — | **NÃO VERIFICADO** linha a linha |
| `docs/referencias/` (5 docs técnicos) | Manuais de Bancada/solver/Estande 1 | Não confrontados item a item | **NÃO VERIFICADO** (possível sobreposição com `arquivo_legado/`) |
| `docs/arquivo_legado/` (19 docs: especificações, roteiros, roadmap, testes) | Títulos indicam propostas/histórico | Diretório auto-declarado legado; coexistência com `referencias/` sugere duplicação | **POSSIVELMENTE LEGADO** / sobreposto |
| `README.md` (raiz) | — (não lido integralmente) | — | **NÃO VERIFICADO** |

Nenhum documento foi escolhido como "verdade"; o código prevalece em cada conflito (regra da seção 1).

---

## 21. Riscos técnicos observados

1. **Camadas-fantasma**: `domain/application/game/mvp/presentation/infrastructure` vazios criam
   impressão de arquitetura que não existe; placeholders de teste reforçam a ilusão (seções 17–19).
2. **Dependências sem uso** (`flame`, `confetti`) aumentam superfície de build/vulnerabilidades sem benefício.
3. **Referências quebradas com `errorBuilder` silencioso** (`background2.png`, sons, possíveis PNGs):
   falhas visuais/sonoras degradam sem log — `science_fair_map.dart:55`, `audio_service.dart`.
4. **Divergências numéricas UI×solver** (motor, capacitor, LED, presets) ensinam física inconsistente
   com a interface — risco pedagógico, não só técnico.
5. **Critérios de curto distintos por solver** (R×I) podem dar vereditos diferentes para o mesmo circuito
   conforme a heurística do seletor.
6. **Rota morta + fases grandes inalcançáveis** (`first_bench/*`, ~6 mil linhas): custo de manutenção
   sem uso; testes as mantêm "vivas" artificialmente.
7. **Persistência sem versão e parcial**: corrupção de JSON é tolerada com `catch (_){}` silencioso
   (`sandbox_persistence_repository.dart:26,35`); queimados/valores/histórico se perdem.
8. **`compute()` com `SandboxState`**: hoje passa nos testes/widget tests, mas qualquer campo
   não transferível futuro quebraria o isolate em runtime.
9. **Texto pedagógico sem lastro no modelo** ("push-button", SPDT implícito, 10 estandes/50 missões):
   copys prometem o que o runtime não entrega.
10. ** Fundo `useExperimentalHorizontalMap = true`** (`home_screen.dart:20`): mapa experimental é o
    padrão; reversão exige edição de constante.

---

## 22. Lacunas e perguntas ainda sem resposta

1. Conteúdo intencional dos 54 arquivos vazios: scaffolding futuro, remoção interrompida ou spike
   Flame/MVP descartado? (git history poderia dizer; fora do escopo de leitura do estado atual.)
2. `cupertino_icons` é usado em algum lugar? Não rastreado.
3. O que `SandboxScreen` passa como `voltageSignal/currentSignal` ao osciloscópio? Fiação real da
   sonda vs. sinal sintético não foi traçada até o fim.
4. `second_bench_flow_screen.dart:35,56` lê prefs diretamente — qual o schema/keys do fluxo do Estande 2?
5. Missões M5 de `liga_desliga` ("botão momentâneo") usam que tipo/componente de fato?
6. Quiz e telemetria de `first_steps`/`mede_testa_explica` — regras completas não auditadas.
7. `second_bench_tokens.dart` vs `stand_flow_tokens.dart`: duplicação ou especialização?
8. Por que `connectingWire` está no catálogo mas fora da paleta/solvers?
9. `estande_10.png` e `assets/references/*` têm uso pretendido?
10. Docs `referencias/` × `arquivo_legado/`: qual é canônico? (Pergunta documental, não de código.)

---

## 23. Comandos/verificações executadas

| Comando | Resultado | Exit |
| ------- | --------- | ---- |
| `git branch --show-current` | `refactor/tests` | 0 |
| `git rev-parse HEAD` | `0a8885aa84bfa08b07473acf23486c46acc42b0a` | 0 |
| `git status --porcelain` / `git diff --stat` / `git diff --name-only` | vazios (tree limpa) | 0 |
| `flutter --version` | Flutter 3.44.9 stable, Dart 3.12.2, DevTools 2.57.0 | 0 |
| `dart --version` | Dart SDK 3.12.2 (linux_x64) | 0 |
| `uname -a && lsb_release -a` | Debian 12, kernel 6.1.0-52-amd64 | 0 |
| `flutter analyze` | **`No issues found! (ran in 16.0s)`** (+ `pub get` automático; 30 pacotes com updates disponíveis, sem erro) | 0 |
| `flutter test` | **`All tests passed!` — 80 testes** (~48 s), sem falhas/warnings/stacks | 0 |
| Leituras: `pubspec.yaml`, `main.dart`, `app.dart`, `routes.dart`, 4 solvers, `sandbox_controller`, `progress/settings` controllers, `settings_service`, `sandbox_persistence_repository`, `history_manager`, `audio_service`, `sandbox_component/state/wire`, `component_terminals`, `first_step_component`, `stand_data`, `stand_mission`, `first_bench_flow`, `settings_model`, `sandbox_toolbox/multimeter/oscilloscope`, `mission_circuit_builder`, telas (menu/home/sandbox parcial), `liga_desliga_m1` (parcial), placeholders de teste, `docs/README.md`, `docs/arquitetura.md` (parcial) | base factual deste relatório | — |
| Greps: `package:flame` (0), `package:confetti` (0), `Routes.firstBench` (0), `background2.png` (1, quebrado), `assets/references` (só comentário), providers/persistência, `_validate`/`MissionCircuitBuilder` por tela, TODO/FIXME (0) | ver tabelas | — |

Proibições respeitadas: sem `flutter pub upgrade`, sem edição de código/testes/assets/docs,
sem remoção/renomeação, sem migração; mutations de git não executadas.
Arquivo modificado/criado por esta tarefa: **apenas `CODEBASE_AUDIT.md`** (ver `git status` pós-tarefa).

---

## 24. Pós-auditoria — limpeza estrutural (conservadora)

| Verificação | Antes | Depois |
| --- | --- | --- |
| Arquivos `.dart` 0 bytes (`lib/`) | 51 | 0 |
| Diretórios vazios (`lib/`) | 19 | 0 |
| Testes placeholder (`expect(true, isTrue)`) | 5 | 0 |
| Dependências sem import (`flame`, `confetti`) | 2 | 0 (removeu `ordered_set` transitive) |
| `flutter analyze` | No issues | No issues |
| `flutter test` | 80 testes | 75 testes |

### 24.1 Arquivos removidos (51 arquivos .dart = 0 bytes, sem referências em lib/ ou test/)

| Diretório | Arquivos |
| --- | --- |
| `lib/application/editor/` | `editor_notifier.dart`, `editor_state.dart` |
| `lib/application/session/` | `activity_session_notifier.dart` |
| `lib/application/simulation/` | `simulation_notifier.dart` |
| `lib/application/validation/` | `validation_notifier.dart` |
| `lib/components/` | `battery_component.dart`, `bench_background.dart`, `glow_component.dart`, `lamp_component.dart`, `live_wire_component.dart`, `moving_dots.dart`, `terminal_component.dart` |
| `lib/core/` | `app_theme.dart`, `constants.dart`, `eletrolab_colors.dart`, `phase1_navigator.dart` |
| `lib/domain/activities/` | `pedagogical_task.dart` |
| `lib/domain/circuit/` | `circuit_document.dart`, `component_model.dart`, `component_type.dart`, `terminal_model.dart`, `wire_model.dart` |
| `lib/domain/simulation/` | `circuit_solver.dart`, `electrical_netlist.dart`, `simulation_result.dart` |
| `lib/domain/validation/` | `diagnostic_result.dart`, `equivalence_checker.dart` |
| `lib/game/` | `electric_circuit_game.dart`, `workbench_game.dart` |
| `lib/infrastructure/serialization/` | `circuit_serializer.dart` |
| `lib/models/` | `phase1_circuit.dart`, `terminal.dart`, `terminal_id.dart`, `wire_connection.dart` |
| `lib/mvp/` | `activity_controller.dart`, `circuit_analysis_panel.dart`, `diagram_game.dart`, `diagram_workspace.dart`, `eletrolab_game.dart`, `mvp_contract.dart` |
| `lib/presentation/screens/` | `eletrolab_main_screen.dart` |
| `lib/presentation/theme/` | `eletrolab_theme.dart` |
| `lib/presentation/widgets/` | `calculation_panel_widget.dart`, `json_dialog_widget.dart`, `schematic_editor_widget.dart`, `status_banner_widget.dart` |
| `lib/screens/` | `assembly_screen.dart`, `schematic_screen.dart` |
| `lib/widgets/` | `circular_carousel.dart`, `component_card.dart`, `distractor_symbols.dart`, `result_modal.dart`, `volt_widget.dart` |

**Diretórios removidos:** `application/editor`, `application/session`, `application/simulation`, `application/validation`, `application`, `components`, `domain/activities`, `domain/circuit`, `domain/simulation`, `domain/validation`, `domain`, `game`, `infrastructure/serialization`, `infrastructure`, `mvp`, `presentation/screens`, `presentation/theme`, `presentation/widgets`, `presentation`

### 24.2 Testes placeholder removidos (5 arquivos, `expect(true, isTrue)`)

| Arquivo | Alvo original |
| --- | --- |
| `test/domain/circuit_solver_test.dart` | `lib/domain/simulation/circuit_solver.dart` (vazio, removido) |
| `test/domain/topological_equivalence_test.dart` | `lib/domain/validation/equivalence_checker.dart` (vazio, removido) |
| `test/infrastructure/circuit_serializer_test.dart` | `lib/infrastructure/serialization/circuit_serializer.dart` (vazio, removido) |
| `test/models/phase1_circuit_test.dart` | `lib/models/phase1_circuit.dart` (vazio, removido) |
| `test/widgets/intro_screen_test.dart` | `lib/screens/intro_screen.dart` (código real, mas teste era só placeholder) |

**Diretórios de teste removidos:** `test/domain`, `test/infrastructure`, `test/models`

### 24.3 Dependências removidas do pubspec.yaml

| Pacote | Motivo |
| --- | --- |
| `flame: ^1.38.0` | Zero imports em lib/ ou test/ |
| `confetti: ^0.8.0` | Zero imports; projeto usa `success_confetti_overlay.dart` próprio |
| `ordered_set` (transitiva) | Removida automaticamente com `flutter pub get` |

### 24.4 Itens preservados (confirmados ativos)

| Item | Razão |
| --- | --- |
| `lib/core/ui_scale.dart` | Único não-vazio em `lib/core/`; referenciado em widgets ativos |
| `audioplayers` | Importado em `lib/services/audio_service.dart` |
| `cupertino_icons` | Dependência padrão Flutter |
| `flutter_riverpod` | Provider ativo em múltiplos arquivos |
| `shared_preferences` | Persistência ativa |
| `google_fonts` | Tipografia ativa |
| `flutter_localizations` | Localização ativa |

### 24.5 Bugs/testes quebrados

**Nenhum.** `flutter analyze` e `flutter test` (75 testes) passaram sem falhas. Nenhuma quebra de comportamento observada.

---

## 25. Snapshot atual após limpeza e remoção da documentação legada

> As seções 1–23 permanecem intencionalmente históricas e descrevem o commit originalmente auditado. Esta seção registra o estado posterior do repositório e não altera retroativamente aquela auditoria.

| Campo | Valor |
| --- | --- |
| Branch | `refactor/tests` |
| HEAD atual | `442136f00f608d478553118a18d4c9b39822b421` |
| Working tree | limpa (sem alterações unstaged/staged) |
| Commit originalmente auditado (seção 23) | `0a8885aa84bfa08b07473acf23486c46acc42b0a` — `feat(ui): use floor.png (gym fair background) across stand screens` |
| Commit de remoção da documentação Markdown legada | `e1f21c20bc832d7dd136adf48302c97efc953b7b` — `refactor: consolidate fragmented documentation into a single CODEBASE_AUDIT.md file by removing legacy files` |
| Commit de limpeza estrutural (seção 24) | `442136f00f608d478553118a18d4c9b39822b421` — `refactor: remove placeholder tests, unused dependencies, and redundant documentation files` |

### 25.1 Documentos Markdown existentes atualmente

| Caminho | Presença |
| --- | --- |
| `docs/CODEBASE_AUDIT.md` | **EXISTE** (este arquivo) |
| `ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md` | **EXISTE** (asset padrão do Xcode, não do projeto) |
| `README.md` (raiz) | **REMOVIDO** (era 104 linhas, conforme seção 20) |
| `docs/README.md` | **REMOVIDO** (era 73 linhas) |
| `docs/arquitetura.md` | **REMOVIDO** (era 164 linhas) |
| `docs/assets.md` | **REMOVIDO** |
| `docs/backlog.md` | **REMOVIDO** |
| `docs/conteudo.md` | **REMOVIDO** |
| `docs/requisitos.md` | **REMOVIDO** |
| `docs/ux-e-fluxos.md` | **REMOVIDO** |
| `docs/visao-geral.md` | **REMOVIDO** |
| `docs/referencias/` (5 md + README) | **REMOVIDO** |
| `docs/arquivo_legado/` (19 md) | **REMOVIDO** |

**Resumo:** Dos ~28 documentos Markdown listados na seção 20, apenas `docs/CODEBASE_AUDIT.md` permanece. Todos os demais (`docs/README.md`, `docs/arquitetura.md`, `docs/assets.md`, `docs/backlog.md`, `docs/conteudo.md`, `docs/requisitos.md`, `docs/ux-e-fluxos.md`, `docs/visao-geral.md`, `docs/referencias/`, `docs/arquivo_legado/`) foram removidos no commit `e1f21c2`.

### 25.2 Inventário de código Dart

| Métrica | Valor |
| --- | --- |
| Arquivos `.dart` em `lib/` | 143 |
| Arquivos `.dart` com 0 bytes em `lib/` | 0 |
| Arquivos `.dart` em `test/` | 15 (todos com asserções reais) |

### 25.3 Dependências removidas na limpeza (seção 24)

| Pacote | Versão removida | Motivo |
| --- | --- | --- |
| `flame` | `^1.38.0` | Zero imports em `lib/` ou `test/` |
| `confetti` | `^0.8.0` | Zero imports; projeto usa implementação própria |
| `ordered_set` | (transitiva) | Removida automaticamente via `flutter pub get` |

### 25.4 Validação atual

| Verificação | Resultado |
| --- | --- |
| `flutter analyze` | **`No issues found!`** (exit 0) |
| `flutter test` | **`All tests passed!`** — **75 testes** (exit 0) |

### 25.5 Resumo executivo

| Item | Status |
| --- | --- |
| 1. HEAD atual | `442136f00f608d478553118a18d4c9b39822b421` |
| 2. Commit da remoção documental | `e1f21c20bc832d7dd136adf48302c97efc953b7b` |
| 3. Documentos Markdown existentes | `docs/CODEBASE_AUDIT.md` (único do projeto) + `ios/.../README.md` (asset Xcode) |
| 4. `flutter analyze` | No issues found |
| 5. `flutter test` | 75 testes, todos passando |
| 6. Somente `CODEBASE_AUDIT.md` foi alterado | **CONFIRMADO** — `git status --porcelain` retornou vazio antes desta edição; nenhum outro arquivo foi modificado nesta sessão |

---

### Errata factual de contagem

A seção 18 registra "54 arquivos `.dart` com 0 bytes" e a seção 3 repete esse número. A verificação retrospectiva com `git ls-tree` + `git cat-file -s` no commit original `0a8885aa` encontrou **53** arquivos de 0 bytes sob `lib/`.

| Fonte | Número registrado | Número real verificado |
| --- | --- | --- |
| Seção 3 (tabela resumo) | 54 | 53 |
| Seção 18 (lista nominal) | 54 | 53 |
| Seção 24 (pós-limpeza 1) | 51 | — (consistente: 53 − 2 preservados = 51) |

A divergência entre 54 e 53 é erro de contagem na auditoria original, não mudança de código. A seção 18 lista nominal correta contém 53 entradas; uma contagem manual incorreta produziu 54. A seção 24 está internamente consistente (51 = 53 − `ui_scale.dart` − `app.dart` que não eram de 0 bytes naquele momento). Esta errata é correção de registro, não alteração de estado.

---

## 26. Snapshot final pós-rebaseline estrutural

> As seções anteriores permanecem como registro dos estados em que foram produzidas. Esta seção registra a baseline final após a remoção do código legado comprovado e encerra a atualização operacional deste audit.

### 26.1 Identificação

| Campo | Valor |
| --- | --- |
| Branch | `refactor/tests` |
| HEAD | `b38f8b3a3decaa2621b8204aabfa7af2bcf305ae` |
| Commit original auditado | `0a8885aa84bfa08b07473acf23486c46acc42b0a` |
| Commit da remoção documental | `e1f21c20bc832d7dd136adf48302c97efc953b7b` |
| Commit da primeira limpeza | `442136f00f608d478553118a18d4c9b39822b421` |
| Commit da remoção de first_bench | `7842e59` |
| Working tree antes desta edição | limpa (sem alterações unstaged/staged) |

### 26.2 Estado estrutural final

| Métrica | Valor |
| --- | --- |
| Arquivos Dart em `lib/` | 132 |
| Arquivos Dart de 0 bytes em `lib/` | 0 |
| Arquivos Dart em `test/` | 9 |
| Casos de teste reais | 47 |
| Rotas ativas | 12 (`/`, `/intro`, `/home`, `/first-steps`, `/second-bench`, `/liga-desliga`, `/ruas-maquete`, `/letreros-led`, `/movimento-miniatura`, `/mede-testa-explica`, `/sandbox`, `/settings`) |
| Fluxo `first_bench` | **Ausente** — rota, screens, model e testes removidos |

### 26.3 Remoções finais confirmadas

Confirmadas por verificação filesystem + grep (todas as ausências verificadas):

| Categoria | Itens removidos |
| --- | --- |
| Fluxo `first_bench` | `lib/screens/first_bench/` (5 arquivos), `lib/models/first_bench_flow.dart`, rota `Routes.firstBench` |
| Testes exclusivos | `test/screens/first_bench/` (5 arquivos), `test/models/first_bench_flow_test.dart` |
| Widgets órfãos | `lib/widgets/home_option_card.dart`, `lib/widgets/cyber_hud_container.dart` |
| Services órfãos | `lib/services/audio_service.dart` |
| Common_stand não utilizado | `lib/screens/common_stand/stand_flow_scaffold.dart`, `lib/screens/common_stand/stand_flow_action_bar.dart` |
| Dependências | `flame`, `confetti`, `ordered_set` (limpeza 1); `audioplayers` + 7 plataformas, `cupertino_icons`, `synchronized` (limpeza 2) |
| Assets | `assets/stands/estande_10.png`, `assets/references/` (4 PNGs), `assets/sounds/.gitkeep`, `assets/icons/.gitkeep` |

### 26.4 Qualidade

| Verificação | Resultado |
| --- | --- |
| `flutter analyze` | **No issues found!** |
| `flutter test` | **All tests passed! — 47 testes** |

### 26.5 Pendências técnicas conhecidas

Itens confirmados ainda presentes no código atual:

| Pendência | Status |
| --- | --- |
| LED com comportamento/modelagem divergente entre DFS e MNA | PENDENTE |
| Motor com resistência fixa (`2.0 Ω`) ignorando default da UI (`15.0 Ω`) | PENDENTE |
| Capacitor aproximado resistivamente (`10.0 Ω` fixo) sem modelo capacitivo | PENDENTE |
| Potenciômetro com terminal W sem participação elétrica | PENDENTE |
| Curto-circuito com critérios distintos entre DFS (resistivo) e MNA (por corrente) | PENDENTE |
| MissionCircuitBuilder com divergências do solver geral | PENDENTE |
| Referência `background2.png` em `science_fair_map.dart:55` para asset inexistente | PENDENTE |
| `push-button` mencionado em missões sem subtipo correspondente no modelo `ComponentType` | PENDENTE |
| Diodo com comportamento simplificado (Vf fixo, sem curva IV) | PENDENTE |

Essas pendências são alvos da **Frente 0** no `ROADMAP.md`.

> A limpeza estrutural não introduziu regressões detectáveis por `flutter analyze` ou `flutter test`. As pendências listadas acima eram previamente conhecidas e já registradas na auditoria original (seções 8, 9, 19, 21).

### 26.6 Documentação atual

| Documento | Tipo | Status |
| --- | --- | --- |
| `README.md` | Documentação técnica | PRESENTE |
| `docs/ARCHITECTURE.md` | Documentação técnica | PRESENTE |
| `docs/ROADMAP.md` | Trabalho futuro | PRESENTE |
| `docs/CODEBASE_AUDIT.md` | Registro histórico (este arquivo) | PRESENTE |
| `ios/.../README.md` | Asset padrão Xcode | PRESENTE (não do projeto) |

**Ausentes (planejados para adição futura):** `PRODUCT.md`, `PEDAGOGY.md`, `CAMPAIGN.md`, `FIRST_STAND.md`, `PORTAO_DA_ESCOLA.md`, `REFERENCES.md`.

### 26.7 Encerramento do audit

> A partir deste snapshot, `CODEBASE_AUDIT.md` passa a ser registro histórico congelado. O estado arquitetural corrente deve ser mantido em `ARCHITECTURE.md`; trabalho futuro em `ROADMAP.md`; decisões de produto e pedagogia em seus documentos canônicos correspondentes. Alterações futuras ao estado do sistema devem ser refletidas em `ARCHITECTURE.md`, não neste arquivo.
