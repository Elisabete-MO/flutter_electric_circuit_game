# Roadmap

## Estado de partida

O EletroLab é um jogo educacional de eletrônica em Flutter com 5 estandes funcionais (3–7), um modo Bancada Livre, e um Estande 2 com fluxo por fases. A limpeza estrutural do repositório foi concluída — dependências mortas, código órfão e testes placeholder foram removidos. O estado atual é funcional e testado (47 testes, `flutter analyze` limpo).

## Frente 0 — Estabilização técnica

Tarefas independentes para resolver divergências elétricas conhecidas antes de expandir funcionalidades.

### Modelo de LED

- Estabelecer comportamento coerente entre DFS, MNA, UI e missões.
- Distinguir `Vf`, corrente e resistência equivalente/aproximação.
- Preservar polaridade.
- Exigir limitação de corrente nos cenários pedagógicos apropriados.

**Critério de aceite:** mesmo circuito não recebe interpretações contraditórias dos dois solvers; testes documentam os casos aprovados.

### Curto-circuito

- Revisar diferença entre critério resistivo do DFS e critério por corrente do MNA.

**Critério de aceite:** comportamento didático consistente e testado.

### Motor

- Resolver divergência entre valor do modelo/UI e resistência fixa usada no solver.
- Definir qual modelo didático será adotado antes de implementar.

### Capacitor

- Estado atual não representa capacitância/transiente corretamente.
- Decidir explicitamente entre: implementar modelo adequado ao escopo pedagógico, restringir/desativar o comportamento simulado, ou manter somente como conteúdo futuro.
- Não ensinar `100 µF` como se fosse equivalente a `10 Ω`.

### Potenciômetro

- Resolver terminal visual `W` sem participação elétrica real.
- Frente também preparação para componentes multipinos.

### MissionCircuitBuilder

- Revisar divergências entre helper de missões e solver geral, incluindo suporte de fontes e loop.

### Assets/referências quebradas

- Investigar e corrigir `background2.png` com base no asset realmente pretendido.
- Não definir a solução sem verificar o código/assets.

### Cobertura elétrica

- Adicionar testes para comportamentos aprovados após cada correção.

---

## Frente A — Primeiro Stand / MVP

- Será definida pelo documento de produto específico a ser adicionado ao repositório.
- Deve reutilizar infraestrutura válida existente (components, solver, CommonStand, patterns).
- Não deve depender da conclusão de toda a Frente 0.
- Correções elétricas necessárias ao circuito escolhido são bloqueadoras para aquela missão específica.

---

## Frente B — Proof of Architecture do Relé

- O modelo atual de dois terminais (A/B) não suporta componentes multipinos.
- Relé exige terminais e estados internos coerentes (bobina, comum, NA, NF).
- Esta frente servirá como proof of architecture para multipinos.
- Não define modelo, fabricante, pinagem, tensão de bobina, nem SPDT/DPDT — essas decisões virão da especificação do Portão da Escola.

---

## Frente C — Hub da Feira

- Camada de navegação futura que conecta os estandes em uma campanha.
- Não descreve visual, quantidade de stands, mapas ou comportamento sem especificação de produto.

---

## Expansão posterior

- Novos estandes e missões.
- Expansão da Bancada Livre (novos componentes, instrumentos).
- Automação e novos modos de interação.

Somente após validação das frentes anteriores.

---

## Regra de atualização

Este roadmap é atualizado quando:
- Uma frente é concluída ou tem escopo alterado.
- Nova informação técnica é descoberta que muda prioridades.
- Especificação de produto é adicionada ao repositório.

Não contém datas nem estimativas.

---

> **Princípio de precisão elétrica:** Quando precisão elétrica e conveniência visual entrarem em conflito, preservar primeiro a precisão elétrica. Não inferir componente pela aparência; validar tipo e terminais; polaridade precisa ser respeitada; LED exige análise de limitação de corrente; série/paralelo dependem da topologia; `+`/`−` não representam sentido da corrente; cores de fios não substituem conectividade; componentes multipinos não podem ser reduzidos a dois terminais apenas para facilitar implementação.
