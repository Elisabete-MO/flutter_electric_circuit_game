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
| [`bancada_livre.md`](bancada_livre.md) | Documentação completa da Bancada Livre / Bancada Online (arquitetura, solver, instrumentos, simulação física e diagnósticos). |
| [`configuracoes.md`](configuracoes.md) | Preferências, acessibilidade e persistência de configurações. |
| [`testes.md`](testes.md) | Estratégia de testes, casos do solver e comandos de verificação. |


## Estado atual do projeto

- **Todas as Fases (1 a 10) 100% Concluídas** — App navegável com identidade visual Cyberpunk, menu inicial Bento Grid com CyberHUD adaptado, primeiros passos interativo com quiz de reconhecimento, 3 desafios modulares completos (lâmpada, motor, resistor) com placar de estrelas e áudio, persistência local de tema, configurações e progresso via SharedPreferences.
- **Renderização Nativa e Partículas (Fase 3 & 6)** — Canvas de simulação customizado via CustomPainter com partículas de elétrons animadas ao longo dos fios energizados, otimizado com RepaintBoundary.
- **Motor de Simulação & Bancada Livre (Fases 5 & 7 - Sandbox)** — Laboratório livre totalmente funcional com resolvedor de circuitos em grafo, cálculo de grandezas elétricas em tempo real (Lei de Ohm e Kirchoff), lógica de sobrecarga/queima física (LED, Lâmpada, Motor), roteamento ortogonal inteligente de fios (Manhattan Routing), loader de circuitos predefinidos, atalhos de reparo e assistente HUD flutuante do Professor Volts no canto inferior direito.
- Consulte o [`roadmap.md`](roadmap.md) para o detalhamento completo de todas as fases.
