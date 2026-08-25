# Roadmap do EletroLab

Desenvolvimento incremental. A cada fase concluída: `flutter analyze` + `flutter test`
sem erros.

## Status por fase

| Fase | Descrição | Status |
|---|---|---|
| 1 | **Fundação** — projeto, tema, navegação, menu inicial Bento Grid, configurações | ✔ Concluída |
| 2 | **Primeiros passos** — guia de símbolos esquemáticos, interatividade e quiz | ✔ Concluída |
| 3 | **Renderização Nativa** — migração de Flame para CustomPainter (canto chanfrado, partículas) | ✔ Concluída |
| 4 | **Componentes** — baterias, lâmpadas, motores, interruptores, resistores e fios 3D | ✔ Concluída |
| 5 | **Circuito/Solver** — grafo dinâmico, nós, conexões e Leis de Kirchhoff para Banqueta | ◻ Pendente |
| 6 | **Simulação Visual** — animação reativa da corrente, velocidade e lâmpada/motor ativos | ✔ Concluída |
| 7 | **Banqueta** — laboratório livre dinâmico (dependente da Fase 5) | ◻ Pendente |
| 8 | **Desafios (Começar)** — 3 desafios completos, validação de slots, cronômetro e estrelas | ✔ Concluída |
| 9 | **Configurações Completas** — persistência de progresso, volume de áudio e i18n | ✔ Concluída |
| 10 | **Refinamento** — UX Cyberpunk, partículas com RepaintBoundary, suíte de testes passando | ✔ Concluída |

## Detalhamento das fases

### Fase 1 — Fundação (concluída)

- Projeto Flutter (`eletrolab`) com `flame`, `flutter_riverpod`, `shared_preferences`.
- Tema Material 3 claro/escuro com identidade EletroLab.
- Navegação nomeada: `/`, `/first-steps`, `/challenges`, `/sandbox`, `/settings`.
- Menu inicial com as 4 opções e identidade visual.
- `SettingsModel` + `SettingsService` + `SettingsController`, com persistência.
- Tela de configurações funcional (tema, switches, dados, sobre).
- Placeholders navegáveis para First steps, Challenges e Sandbox.
- Estrutura de assets e README.

### Dependência entre Fases 2 e 3–6

A aplicação adotou a **Opção C**: uma fatia vertical visualmente rica foi implementada para as etapas interativas do tutorial (Primeiros Passos) e para os Desafios (1, 2 e 3), utilizando a API `CustomPainter` do Flutter e validação por slots. A implementação de um um motor matemático baseado em grafos (nodal) foi postergada e permanece como o principal requisito para a liberação da Bancada Livre (Banqueta).

## O que precisa ser feito (por fases)

### Fase 3 — Renderização Nativa (concluída)
- Canvas de simulação customizado com a API `CustomPainter` (ao invés de Flame).
- Desenho de malha/grade tecnológica e cantos chanfrados HUD de alta tecnologia.
- Otimização com `RepaintBoundary` para isolar a repintura das partículas móveis de corrente dos elementos estáticos do circuito.

### Fase 4 — Componentes (concluída para v1)
- Modelagem visual e animação via CustomPainter de:
  - **Battery**: fonte de energia com polo positivo/negativo e bornes 3D.
  - **Resistor**: corpo cilíndrico listrado com código de cores e terminais.
  - **Lamp**: lâmpada incandescente que acende reativamente.
  - **Motor**: motor elétrico com hélice rotativa que gira proporcionalmente ao fluxo de corrente.
  - **Switch**: interruptor tipo alavanca com estados físico aberto e fechado.
  - **Wire**: cabos flexíveis conectando os terminais com gradientes e sombras 3D tridimensionais.

### Fase 5 — Circuito/Solver (Pendente)
- Modelo em grafo dinâmico para a Banqueta: `Circuit { Nodes, Terminals, Connections, Components }`.
- Solver matemático generalizado utilizando as leis de Kirchhoff e análise nodal para suportar qualquer circuito livre criado pelo usuário.

### Fase 6 — Simulação Visual (concluída para v1)
- Fluxo de partículas animado nos fios com velocidade controlável e suspensão em circuito aberto.
- Reatividade visual imediata: fechando a chave, a lâmpada acende, o motor gira e a corrente flui.

### Fase 7 — Banqueta (Pendente)
- Liberação do laboratório livre, barra de ferramentas de edição, e drag-and-drop de múltiplos componentes na mesa livre. Depende do Solver da Fase 5.

### Fase 8 — Desafios (Começar) (concluída)
- 3 desafios totalmente desenvolvidos:
  - **Desafio 1**: Acender lâmpada e arrastar os símbolos corretos (Bateria, Chave, Lâmpada).
  - **Desafio 2**: Acionar o motor e arrastar os símbolos corretos (Bateria, Chave, Motor).
  - **Desafio 3**: Proteger circuito em série e arrastar os símbolos corretos (Bateria, Chave, Resistor, Lâmpada).
- Validação local e pontuação em estrelas baseada em tentativas e tempo decorrido.

### Fase 9 — Configurações (concluída)
- Temas: Claro, Escuro e integração dinâmica com o sistema.
- Idioma (i18n): Tradução completa em tempo real para Português (pt) e Inglês (en).
- Acessibilidade: Controle de velocidade de animações, tamanho da interface e alto contraste.
- Dados: Persistência local (tema, preferências e progresso/estrelas de desafios) via `SharedPreferences`.

### Fase 10 — Refinamento (concluída)
- Áudio: Efeitos sonoros de clique, drop e sucesso/erro + música de fundo (BGM).
- Efeitos visuais adicionais (confetes ao vencer).
- Cobertura de testes unitários e de integração garantindo robustez e sem travamentos.

## Verificação

- `flutter analyze` e `flutter test` após cada implementação.
- Build de referência: `flutter build web`.