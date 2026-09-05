# Documentos Técnicos e Pedagógicos de Referência — EletroLab

Este diretório preserva as especificações detalhadas, esquemas avançados de circuitos e pesquisas científicas que fundamentam a arquitetura e a didática do EletroLab.

---

## 📑 Índice de Referências Preservadas

| Documento | Assunto | Conteúdo Principal |
|---|---|---|
| [`bancada_livre.md`](bancada_livre.md) | **Manual Completo da Bancada Livre (Sandbox)** | Especificação de arquitetura, algoritmo de travessia DFS, instrumentação virtual (Multímetro 9000 e Osciloscópio HUD), Smart Inspector, seleção em lote (*marquee selection*) e atalhos de teclado. |
| [`circuitos_detalhados.md`](circuitos_detalhados.md) | **Esquemas Elétricos e Montagens Detalhadas** | Topologia detalhada dos circuitos de todas as 50 missões dos Estandes 1 a 10, com abreviações de bornes (B+, B-, L1, LED A/K, S1, PB1, M1, RL1), regras de validação e matriz de falhas didáticas. |
| [`estande1_quatro_fases.md`](estande1_quatro_fases.md) | **Especificação Técnica do Estande 01** | Arquitetura da jornada de 4 fases guiadas do Primeiro Estande (`FirstBenchFlowScreen`), modelo de estado `FirstBenchFlowState`, regras elétricas de 680 Ω e validação topológica. |
| [`explicacoes_componentes.md`](explicacoes_componentes.md) | **Fundamentação Pedagógica e Científica** | Pesquisa aprofundada dos 5 componentes básicos (Bateria 9V, Interruptor SPST, Resistor 680 Ω, LED Vermelho e Fios) com citações acadêmicas (OpenStax, Energizer, SparkFun, Duracell), textos curtos para cards e respostas para diálogos do mascote. |
| [`testes.md`](testes.md) | **Estratégia e Casos de Teste** | Estratégia de estabilização de animações (`pumpSettle`), injeção de dependências em testes de widgets com SharedPreferences e tabela de testes do solver físico da Lei de Ohm. |

---

## 🔙 Retornar à Documentação Principal

* [Visão Geral](../visao-geral.md)
* [Requisitos](../requisitos.md)
* [Arquitetura](../arquitetura.md)
* [UX e Fluxos](../ux-e-fluxos.md)
* [Conteúdo da Feira](../conteudo.md)
