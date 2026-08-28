# ⚡ EletroLab — MVP

## 🎯 Objetivo desta entrega

O MVP do **EletroLab** tem como objetivo validar a experiência principal do projeto com o menor escopo funcional possível.

Nesta primeira versão, o aluno deverá:

1. observar um circuito físico já montado;
2. testar o comportamento do circuito abrindo e fechando o interruptor;
3. reconhecer os componentes apresentados;
4. identificar seus respectivos símbolos elétricos;
5. arrastar os símbolos para as posições correspondentes no diagrama;
6. verificar se a representação criada está correta;
7. observar uma medição e um cálculo elétrico básico.

O foco pedagógico desta versão é a **tradução de um circuito físico para sua representação por símbolos elétricos**.

---

## 👩‍🎓 Público inicial

O MVP é pensado inicialmente para estudantes do:

* 6º ano;
* 7º ano;
* 8º ano;
* 9º ano do Ensino Fundamental.

A interface deve ser simples, visual e acessível, mantendo os símbolos elétricos tecnicamente corretos.

---

# 🔌 Circuito do MVP

Será utilizado apenas um circuito:

**Bateria → Interruptor → Lâmpada → Bateria**

Componentes presentes:

* 1 bateria;
* 1 interruptor SPST;
* 1 lâmpada;
* fios condutores.

O circuito físico já estará montado quando a atividade começar.

O aluno **não monta nem reposiciona os componentes físicos nesta versão**.

---

# 🧪 Fluxo da atividade

## 1. Observar

A tela apresenta o circuito físico completo.

O aluno deve conseguir reconhecer visualmente:

* bateria;
* interruptor;
* lâmpada;
* fios.

---

## 2. Experimentar

O interruptor do circuito físico será interativo.

### Interruptor aberto

* lâmpada apagada;
* corrente igual a `0 A`;
* nenhuma animação de energização nos fios.

### Interruptor fechado

* lâmpada acesa;
* corrente circulando;
* pontos luminosos em ciano percorrem os fios.

Os pontos luminosos representam visualmente a energização do circuito e não devem utilizar setas direcionais.

---

# ✏️ Montar o diagrama

O aluno deverá representar o circuito físico utilizando símbolos elétricos.

A área do diagrama terá **três posições predefinidas**.

Exemplo conceitual:

```text
┌──────────────── MONTE O DIAGRAMA ────────────────┐

      ┌─────┐                  ┌─────┐
      │  ?  │──────────────────│  ?  │
      └─────┘                  └─────┘
         │                        │
         │       ┌─────┐          │
         └───────│  ?  │──────────┘
                 └─────┘

└──────────────────────────────────────────────────┘
```

Os fios do diagrama já estarão desenhados.

O aluno deverá posicionar apenas os símbolos.

---

# 🧩 Biblioteca de símbolos

Nesta versão estarão disponíveis somente:

* símbolo da bateria;
* símbolo do interruptor;
* símbolo da lâmpada.

Os símbolos devem permanecer técnicos, planos e padronizados.

Cada símbolo poderá ser utilizado apenas uma vez.

---

# 🖱️ Drag and Drop

O aluno poderá arrastar um símbolo da biblioteca até uma das posições do diagrama.

## Regras

* cada posição possui uma área de encaixe ampla;
* não deve ser necessário acertar um ponto exato;
* quando o símbolo entrar suficientemente na região, ocorre `snap`;
* o símbolo é centralizado automaticamente no slot;
* o usuário poderá trocar um símbolo de posição antes da verificação.

O objetivo é avaliar o reconhecimento da representação elétrica, e não a precisão motora do aluno.

---

# ✅ Verificação do diagrama

A tela terá um botão:

**Verificar diagrama**

Ao clicar, o sistema compara os símbolos posicionados com os componentes esperados em cada região.

## Estados possíveis

### Diagrama incompleto

Exemplo:

> Complete todas as posições antes de verificar.

### Símbolo incorreto

O slot correspondente será destacado.

Exemplo:

> Confira o símbolo utilizado nesta posição.

A resposta correta não deve ser mostrada imediatamente.

### Diagrama correto

Exemplo:

> Muito bem! O diagrama representa o circuito apresentado.

---

# 🧠 Validação utilizada no MVP

Nesta versão, a validação será simplificada.

Cada posição possui um tipo esperado.

Exemplo:

```text
slotBattery → battery
slotSwitch  → switch
slotLamp    → lamp
```

A validação verifica:

* se todos os slots estão preenchidos;
* se cada símbolo corresponde ao tipo esperado.

## Importante

A validação por slots é uma **simplificação deliberada do MVP**.

A visão completa do EletroLab prevê posteriormente:

* posicionamento livre dos símbolos;
* criação manual dos fios;
* conexão entre terminais;
* análise da topologia;
* validação por equivalência elétrica.

Portanto, o modelo utilizado neste MVP não substitui a arquitetura prevista para as versões futuras.

---

# 📏 Valores elétricos utilizados

Para manter a atividade simples e previsível, o circuito utilizará valores fixos.

### Bateria

```text
V = 6 V
```

### Lâmpada

Modelo resistivo simplificado:

```text
R = 12 Ω
```

---

# 🧮 Cálculo básico

Com o interruptor fechado:

```text
I = V / R
I = 6 / 12
I = 0,5 A
```

Resultado apresentado ao aluno:

* tensão: **6 V**;
* resistência: **12 Ω**;
* corrente: **0,5 A**.

Com o interruptor aberto:

```text
I = 0 A
```

O cálculo apresentado deve ser simples e adequado ao nível introdutório da atividade.

---

# 🎨 Direção visual

O MVP deverá seguir a identidade visual já definida para o EletroLab.

## Componentes físicos

* estilo 2.5D moderadamente cartunizado;
* formas simplificadas;
* terminais visíveis;
* sem rostos ou elementos infantis.

## Símbolos

* representação técnica;
* aparência plana;
* sem tratamento cartoon;
* boa legibilidade.

## Energização

* pontos luminosos em ciano;
* animação sobre os fios;
* sem setas indicando o sentido da corrente.

---

# 🧱 Estrutura mínima da tela

A tela deve possuir três regiões principais:

### Circuito físico

Exibe:

* bateria;
* interruptor;
* lâmpada;
* fios;
* animação de energização.

### Diagrama

Exibe:

* circuito esquemático;
* três slots;
* fios predefinidos;
* símbolos posicionados pelo aluno.

### Biblioteca de símbolos

Exibe:

* bateria;
* interruptor;
* lâmpada.

Também devem estar disponíveis:

* botão **Verificar diagrama**;
* controle do interruptor;
* área simples com os valores elétricos.

---

# 🚫 Fora do escopo deste MVP

Não fazem parte da entrega atual:

* montagem livre do circuito físico;
* posicionamento livre completo dos símbolos;
* desenho manual de fios;
* criação de conexões entre terminais;
* rotação de componentes;
* equivalência topológica;
* equivalência funcional;
* vários circuitos;
* resistores independentes;
* LED;
* diodo;
* motor;
* circuitos em paralelo;
* circuitos mistos;
* multímetro;
* wattímetro;
* modo professor;
* sistema de pontuação;
* níveis;
* progressão;
* salvamento;
* compartilhamento de desafios;
* editor completo de circuitos.

Esses recursos permanecem previstos para evolução do projeto.

---

# ✅ Critérios de aceite

O MVP será considerado funcional quando for possível executar completamente o seguinte fluxo:

1. abrir a tela da atividade;
2. visualizar o circuito físico;
3. clicar no interruptor;
4. observar a lâmpada apagar e acender;
5. observar a energização dos fios quando o circuito estiver fechado;
6. visualizar os três símbolos disponíveis;
7. arrastar cada símbolo;
8. encaixar os símbolos nos slots sem exigir precisão excessiva;
9. clicar em **Verificar diagrama**;
10. receber feedback para diagrama incompleto ou incorreto;
11. receber confirmação quando o diagrama estiver correto;
12. visualizar os valores de tensão, resistência e corrente;
13. visualizar o cálculo simples da Lei de Ohm.

---

# 🏁 Definição de pronto

O objetivo desta entrega não é implementar todo o simulador elétrico planejado.

O MVP estará pronto quando demonstrar, de forma estável e compreensível, a experiência:

**Observar → Experimentar → Representar → Verificar → Calcular**

A prioridade desta versão é possuir **um fluxo pequeno funcionando completamente**, em vez de vários recursos parcialmente implementados.

