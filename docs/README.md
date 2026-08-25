# Documentação do EletroLab

Índice da documentação do projeto.

| Documento | Conteúdo |
|---|---|
| [`visao-geral.md`](visao-geral.md) | O que é o EletroLab, objetivo, público, escopo e critérios de sucesso da v1. |
| [`estrutura.md`](estrutura.md) | Estrutura de pastas, arquitetura em camadas, gerenciamento de estado e persistência. |
| [`roadmap.md`](roadmap.md) | Fases de desenvolvimento, status atual e o que ainda precisa ser feito. |
| [`especificacao-componentes.md`](especificacao-componentes.md) | Spec dos componentes do simulador (bateria, resistor, lâmpada, interruptor, fio, multímetro). |
| [`especificacao-simulacao.md`](especificacao-simulacao.md) | Motor de simulação: grafo, solver, grandezas e animação de corrente. |
| [`especificacao-desafios.md`](especificacao-desafios.md) | Sistema de desafios, feedback educacional e os desafios planejados. |
| [`interface.md`](interface.md) | Telas, interações, atalhos, câmera e responsividade. |
| [`configuracoes.md`](configuracoes.md) | Preferências, acessibilidade e persistência de configurações. |
| [`testes.md`](testes.md) | Estratégia de testes, casos do solver e comandos de verificação. |

## Estado atual do projeto

- **Fases 1, 2, 8, 9, 10: Concluídas** — App navegável com identidade visual Cyberpunk, menu inicial Bento Grid com CyberHUD adaptado, primeiros passos interativo com quiz de reconhecimento, 3 desafios modulares completos (lâmpada, motor, resistor) com placar de estrelas e áudio, persistência local de tema, configurações e progresso via SharedPreferences.
- **Fase 3: Concluída** — Migração do Flame para renderização customizada altamente otimizada via CustomPainter com isolamento de RepaintBoundary para as partículas móveis de corrente.
- **Fase 5, 7: Planejadas** — O motor de simulação matemática livre (Solver) está em planejamento e sua conclusão habilitará o laboratório livre (Banqueta).
- Consulte o [`roadmap.md`](roadmap.md) para o detalhamento das fases de desenvolvimento.
