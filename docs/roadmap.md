# Roadmap do EletroLab

Desenvolvimento incremental. A cada fase concluída: `flutter analyze` + `flutter test`
sem erros.

## Status por fase

| Fase | Descrição | Status |
|---|---|---|
| 1 | **Fundação** — projeto, tema, navegação, menu inicial, configurações básicas | ✔ Concluída |
| 2 | **Primeiros passos** — guia de símbolos esquemáticos e componentes físicos | ✔ Concluída |
| 3 | **Flame** — canvas, câmera, grid, pan, zoom, interação | ◻ Pendente |
| 4 | **Componentes** — bateria, resistor, lâmpada, interruptor, fio | ◻ Pendente |
| 5 | **Circuito** — terminais, nós, conexões, grafo, solver, Lei de Ohm | ◻ Pendente |
| 6 | **Simulação** — corrente, tensão, potência, animação, lâmpada acendendo | ◻ Pendente |
| 7 | **Banqueta** — simulador como laboratório livre | ◻ Pendente |
| 8 | **Começar** — desafios educacionais | ◻ Pendente |
| 9 | **Configurações** — preferências completas, acessibilidade, persistência | ◻ Pendente |
| 10 | **Refinamento** — UX, animações, feedback, responsividade, desempenho, testes | ◻ Pendente |

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

A fase 2 termina com a "Etapa 7 — Primeiro circuito" (`Bateria → Interruptor →
Lâmpada → Bateria`, lâmpada acende), o que **exige o núcleo do simulador**
(Fases 3–6). Sequência recomendada:

**Opção A (recomendada)** — motor primeiro, tutorial depois:
`3 → 4 → 5 → 6 → 2 → 7 → 8 → 9 → 10`.

**Opção B** — tutorial enxuto com etapa final usando um mock do circuito,
motor real depois (3–6). Mantém a ordem numérica, com risco de retrabalho.

**Opção C** — fatia vertical mínima do motor suficiente para a etapa 7 do
tutorial e depois expansão. Entrega o critério de sucesso mais cedo.

> Pendência de decisão: escolher a opção A, B ou C antes de iniciar a Fase 3.

## O que precisa ser feito (por fases)

### Fase 2 — Primeiros passos
- Etapas educacionais:
  1. O que é um circuito (caminho fechado para a corrente).
  2. Fonte (bateria) e sua função.
  3. Condutores (papel dos fios).
  4. Resistência (resistor).
  5. Corrente (explicação visual).
  6. Tensão (diferença entre tensão e corrente).
  7. Primeiro circuito interativo: `Bateria → Interruptor → Lâmpada → Bateria`.
- Botões: **Anterior**, **Próximo**, **Pular**, **Começar**.
- Conclusão: "Parabéns! Você já pode começar a experimentar no EletroLab."

### Fase 3 — Flame
- Canvas de simulação, câmera, grade opcional, pan e zoom (mouse/touch/trackpad),
  centralização, interação básica.

### Fase 4 — Componentes
- **Battery**: `voltage`, `internalResistance`.
- **Resistor**: `resistance`.
- **Lamp**: `resistance`, `brightness` (intensidade ∝ potência).
- **Switch**: estados aberto/fechado.
- **Wire**: conexão entre terminais.
- **Multimeter**: mede tensão e corrente (resistência depois).

### Fase 5 — Circuito
- Modelo em grafo: `Circuit { Nodes, Terminals, Connections, Components }`.
- Solver com Lei de Ohm, Leis de Kirchhoff e análise nodal quando necessário.
- `SimulationResult { nodeVoltages, componentCurrents, componentVoltages,
  componentPower, isValid, error }`.

### Fase 6 — Simulação
- Cálculo de `V`, `I`, `P` e visualização.
- Animação da corrente (partículas, velocidade ∝ corrente, pausa em aberto).
- Lâmpada acendendo conforme potência.

### Fase 7 — Banqueta
- Bancada livre, paleta de componentes, arrastar/selecionar/excluir/rotacionar,
  conectar/desconectar, editar valores, multímetro, controles
  (Simular/Pausar/Reiniciar/Limpar).

### Fase 8 — Começar
- Sistema modular de desafios: id, título, descrição, dificuldade,
  componentes, objetivo, condição de vitória, feedback, progresso.
- Desafios planejados:
  1. Acenda a lâmpada.
  2. Controle a luz (interruptor).
  3. Controle a corrente (resistor de 100 Ω, `V = R × I`).
  4. Lei de Ohm (`V = 10 V`, `R = 100 Ω` → `I = 0,1 A`).
  5. Resistores em série (`R1 = 100 Ω`, `R2 = 200 Ω`, `V = 10 V`, `Req = R1 + R2`).
  6. Circuito paralelo (ramificações e equivalente em paralelo).

### Fase 9 — Configurações
- Aparência: claro/escuro/sistema.
- Simulação: corrente, valores, grade, terminais, animação.
- Acessibilidade: tamanho da interface, alto contraste, reduzir animações.
- Dados: resetar progresso, restaurar padrões.
- Sobre: nome, descrição, versão.
- Persistência completa de configurações, progresso e desafios concluídos.

### Fase 10 — Refinamento
- Melhorar UX, animações, feedback, responsividade, desempenho e testes.
- Atalhos de teclado: `Delete` excluir, `Ctrl+Z` desfazer, `Ctrl+Y` refazer,
  `Space` iniciar/pausar, `R` rotacionar.

## Verificação

- `flutter analyze` e `flutter test` após cada implementação.
- Build de referência: `flutter build web`.
- Não ignorar erros de análise ou testes quebrados.