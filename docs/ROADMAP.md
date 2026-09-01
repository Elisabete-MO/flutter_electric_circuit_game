# Roadmap

## Ponto de partida

O estado auditado inclui runtime Flutter/Riverpod/CustomPainter, tres desafios guiados legados e uma Bancada Livre funcional porem limitada. A campanha Feira e o Primeiro Estande ainda nao estao implementados. Detalhes tecnicos estao em `ARCHITECTURE.md`.

## Frente A - Primeiro Estande / MVP

Objetivo: validar a experiencia introdutoria completa.

```text
Conhecer
-> Inspecionar
-> Representar com circuito ghost
-> Construir em bancada controlada
```

Ordem de evolucao:

1. Confirmar regras pedagogicas e eletricas do circuito 9 V, SPST, 680 ohms e LED.
2. Validar representacao com circuito fisico faded sob simbolos/esquema.
3. Restringir conceitualmente a Bancada aos componentes, valores e regras da missao.
4. Validar montagem por topologia, teste, correcao e feedback causal.
5. Cobrir o comportamento eletrico e as interacoes relevantes com testes antes de escalar conteudo.

`FIRST_STAND.md` define o produto desta frente. Avaliacao e estrelas nao bloqueiam este roadmap: permanecem em validacao.

## Frente B - Proof of Architecture do Rele

Esta frente ocorre relativamente cedo e pode ser conduzida em paralelo por outro integrante. Ela nao depende de implementar os estandes 2-8.

Objetivo: uma unica missao avancada do Portao da Escola que prove evolucao para componente multipinos, bobina, contatos, circuitos de comando/carga relacionados e controle indireto de uma carga simulada.

Antes da implementacao, validar subtipo de rele, terminais, funcao de cada terminal, bobina, contatos, simbolo, faixa eletrica relevante, referencia real confiavel e papel pedagogico. O modelo A/B atual e a principal limitacao conhecida.

## Depois das validacoes

Com os dois slices avaliados, definir a ordem dos demais estandes, quantidade de missoes por estande, formato de avaliacao e quais experiencias serao Projeto para a Feira Real. Nenhuma dessas decisoes esta fechada neste roadmap.

## Regra de atualizacao

Este documento registra ordem e status de implementacao aprovados. Decisoes de produto, pedagogia, campanha, primeiro estande, arquitetura e referencias pertencem aos seus documentos canonicos.
