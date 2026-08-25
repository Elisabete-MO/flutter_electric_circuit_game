# Especificação de desafios

## Objetivo

O sistema de desafios deve ser **modular**, permitindo adicionar novos
desafios sem alterar a infraestrutura existente.

## Modelo do desafio

Cada desafio possui:

| Campo | Descrição |
|---|---|
| `id` | Identificador único |
| `título` | Nome exibido na lista |
| `descrição` | Texto do objetivo do desafio |
| `dificuldade` | Nível (iniciante, intermediário, avançado) |
| `componentes disponíveis` | Componentes liberados exatamente |
| `objetivo` | Condição a ser alcançada |
| `condição de vitória` | Regra verificada contra o `SimulationResult` |
| `feedback` | Mensagens (sucesso e erro) por situação |
| `progresso` | Estado de conclusão/avanço do usuário |

## Desafios implementados

### 1 — Acenda a lâmpada e monte o diagrama (Desafio 1 — concluído)
- **Objetivo:** testar o funcionamento do circuito fechando o interruptor e montar o diagrama esquemático com os símbolos correspondentes.
- **Componentes:** Bateria (4.5V), Interruptor, Lâmpada e Fios condutores.
- **Estrutura do Diagrama:** Bateria (esquerda), Interruptor (topo), Lâmpada (base).
- **Conceito:** verificação de circuitos fechados e associação da bancada física com a simbologia esquemática técnico-pedagógica.

### 2 — Circuito com Motor e Diagrama (Desafio 2 — concluído)
- **Objetivo:** acionar o motor elétrico pelo interruptor e reconhecer a simbologia de motores.
- **Componentes:** Bateria (4.5V), Interruptor, Motor Elétrico (com disco rotativo) e Fios condutores.
- **Estrutura do Diagrama:** Bateria (esquerda), Interruptor (topo), Motor (base).
- **Conceito:** conversão de energia elétrica em mecânica e identificação do símbolo técnico do motor.

### 3 — Circuito em Série com Resistor (Desafio 3 — concluído)
- **Objetivo:** observar a limitação e passagem de corrente em um circuito contendo resistor e montar o diagrama esquemático retangular de 4 elementos.
- **Componentes:** Bateria (4.5V), Lâmpada, Resistor, Chave Alavanca / Interruptor e Fios condutores.
- **Estrutura do Diagrama:** Bateria (esquerda), Lâmpada (topo), Resistor (direita), Interruptor/Chave (base).
- **Conceito:** circuito em série de 4 componentes e limitação da corrente pelo resistor.

### 4 — Lei de Ohm
- **Dado:** `V = 10 V`, `R = 100 Ω`.
- **Pergunta:** qual é a corrente?
- **Resposta:** `I = 0,1 A`.
- O desafio pode exigir montagem **e** resposta numérica.

### 5 — Resistores em série
- **Dado:** `R1 = 100 Ω`, `R2 = 200 Ω`, `V = 10 V`.
- **Conceito:** `Req = R1 + R2`.

### 6 — Circuito paralelo
- **Conceito:** ramificações e resistência equivalente em paralelo.

## Feedback educacional

O feedback nunca deve ser apenas "Errado." Deve explicar o problema. Exemplos:

> "A lâmpada não acendeu porque o circuito está aberto. Verifique as conexões."

> "O interruptor está aberto. Feche o interruptor para permitir a passagem de corrente."

> "O resistor possui um valor diferente do solicitado."

> "Não existe uma fonte de tensão conectada ao circuito."

Situações identificadas:

- circuito aberto;
- curto-circuito;
- componente desconectado;
- valor incorreto;
- ausência de fonte;
- resposta numérica incorreta.

## Como criar um novo desafio

1. Criar uma entrada com os campos do modelo.
2. Implementar a **condição de vitória** com base em `SimulationResult`
   (correntes, tensões, conexões e valores).
3. Mapear situações de erro para mensagens de feedback educacional.
4. Registrar o desafio no catálogo — o sistema é modular por construção.
5. Adicionar teste da condição de vitória, se aplicável.

## Progresso

- Nível de conclusão por seção (ex.: tutorial 100%, desafios 40%).
- Armazenado localmente.
- Evitar gamificação exagerada.