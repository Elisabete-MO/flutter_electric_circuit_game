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
2. Validar um slice de representacao: circuito ghost, alvos semanticos de simbolo e botao Testar.
3. Evoluir para Conhecer, Inspecionar e Construir em Bancada restrita.
4. Validar montagem por topologia, teste, correcao e feedback causal.
5. Reparar a suite bloqueada por testes vazios e cobrir polaridade, protecao do LED, aberto/curto, snap, undo/redo e regras da missao antes de escalar conteudo.

> A ordem de evolução é técnica e não representa a ordem pedagógica apresentada ao aluno.

`FIRST_STAND.md` define o produto desta frente. Avaliacao e estrelas nao bloqueiam este roadmap: permanecem em validacao.

## Frente B - Proof of Architecture do Rele

Esta frente ocorre relativamente cedo e pode ser conduzida em paralelo por outro integrante. Ela nao depende de implementar os estandes 2-8. `PORTAO_DA_ESCOLA.md` e a especificacao em validacao desta frente.

Objetivo: uma unica missao avancada do Portao da Escola que prove evolucao para componente multipinos, bobina, contatos, circuitos de comando/carga relacionados e controle indireto de uma carga simulada.

Antes da implementacao, validar subtipo de rele, terminais, funcao de cada terminal, bobina, contatos, simbolo, faixa eletrica relevante, referencia real confiavel e papel pedagogico. O modelo A/B atual e a principal limitacao conhecida.

## Depois das validacoes

Com os dois slices avaliados, definir a ordem dos demais estandes, quantidade de missoes por estande, formato de avaliacao e quais experiencias serao Projeto para a Feira Real. Nenhuma dessas decisoes esta fechada neste roadmap.

## Regra de atualizacao

Este documento registra ordem e status de implementacao aprovados. Decisoes de produto, pedagogia, campanha, primeiro estande, arquitetura e referencias pertencem aos seus documentos canonicos.
