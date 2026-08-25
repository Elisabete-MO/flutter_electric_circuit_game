# Visão geral do EletroLab

## O que é

**EletroLab** é um laboratório virtual de circuitos elétricos com fins
educacionais, desenvolvido com **Flutter + Flame**. Inspira-se no *conceito* de
simuladores educacionais interativos (como o PhET Circuit Construction Kit),
mas com **implementação, código, textos, assets e identidade visual próprios**.

> Não há qualquer código, asset ou texto copiado do PhET. A inspiração é
> apenas conceitual.

## Objetivo

Permitir que estudantes aprendam conceitos de eletricidade de forma visual e
interativa:

- montar circuitos;
- arrastar componentes e conectá-los por fios;
- alterar valores e ligar/desligar interruptores;
- observar a corrente elétrica e visualizar tensão/potência;
- medir grandezas com o multímetro;
- resolver desafios e experimentar livremente;
- receber feedback educacional e explicações.

## Público e abordagem

A aplicação deve ser **educacional, acessível e divertida** — não uma
ferramenta profissional de engenharia.

## Funcionalidades principais (v1)

1. **Menu inicial** com quatro opções:
   - ⚡ **Primeiros passos** — introdução interativa (tutorial).
   - 🔬 **Começar** — desafios educacionais progressivos.
   - 🧪 **Banqueta** — laboratório livre.
   - ⚙️ **Configurações** — aparência, simulação, acessibilidade e dados.

2. **Motor de simulação** separado da camada visual (Flame):
   `UI → Flame → Circuit Model → Circuit Solver → SimulationResult`.

3. **Componentes** (v1): bateria, resistor, lâmpada, interruptor, fio e
   multímetro.

4. **Grandezas**: `V = R × I`, `I = V / R`, `P = V × I`, com visualização no
   simulador.

5. **Corrente animada**: partículas nos fios com velocidade proporcional à
   corrente (representação didática).

6. **Persistência local** (sem backend): configurações, progresso e desafios
   concluídos.

7. **Responsividade**: celular, tablet, desktop e web (quando possível).

## Critérios de sucesso da v1

O usuário deve conseguir:

1. Abrir o EletroLab e visualizar o menu inicial.
2. Completar a introdução em "Primeiros passos".
3. Selecionar um desafio em "Começar".
4. Entrar na "Banqueta".
5. Adicionar e mover bateria, resistor, lâmpada e interruptor.
6. Conectar os componentes e fechar o circuito.
7. Iniciar a simulação e calcular a corrente.
8. Fazer a lâmpada acender.
9. Visualizar a corrente animada.
10. Usar o multímetro.
11. Abrir as configurações, alterar uma preferência e mantê-la após reabrir.

## Fora do escopo da v1

- Backend ou sincronização em nuvem.
- Persistência online de progresso.
- Identidade visual ou assets de terceiros.

## Referências

- [`estrutura.md`](estrutura.md) — arquitetura.
- [`roadmap.md`](roadmap.md) — planejamento por fases.
