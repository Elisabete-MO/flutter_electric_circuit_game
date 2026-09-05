# Visão Geral do EletroLab

O **EletroLab** é um laboratório virtual educacional interativo para o aprendizado prático de circuitos elétricos em corrente contínua e baixa tensão. 

Construído em Flutter com renderização vetorial nativa e gerenciamento de estado previsível (Riverpod), o projeto une a experimentação livre de uma bancada de eletrônica a uma campanha pedagógica contextualizada em uma feira de ciências escolar.

---

## 🎯 Proposta e Princípios Pedagógicos

Diferente de ferramentas profissionais de CAD elétrico ou análise nodal voltadas para a engenharia (como SPICE), o EletroLab é concebido para ser **didático, acessível, visual e seguro**:

1. **Baixa Tensão Didática Simulada**: Todos os circuitos operam sob modelos pedagógicos de corrente contínua (ex.: pilhas de 1,5 V, baterias de 4,5 V e 9 V, LEDs de 2 V, fontes ajustáveis de até 30 V). Não há menção ou incentivo à manipulação de rede elétrica residencial ou alta tensão.
2. **Contexto Realista de Feira Escolar**: A experiência descarta clichês de magia, vilões ou poderes sobrenaturais. A narrativa se passa na preparação da *Feira de Ciências da Comunidade*, onde equipes de alunos preparam protótipos, cartazes e demonstrações sob a coordenação do **Professor Volts**.
3. **Ciclo de Investigação Científica**: Em vez de apenas montar circuitos prontos, o aluno é incentivado a seguir o método científico:
   $$\text{Preparar} \longrightarrow \text{Prever} \longrightarrow \text{Investigar} \longrightarrow \text{Projetar} \longrightarrow \text{Demonstrar}$$
4. **Tríade Avaliativa Formativa**: O sucesso em cada missão não se resume ao fechamento elétrico do circuito, sendo avaliado em três dimensões:
   * **Funciona**: A malha atende ao comportamento físico solicitado (ex.: lâmpada acende, motor gira).
   * **Está seguro**: O circuito previne sobrecorrentes, curtos-circuitos simulados e respeita limites de componentes.
   * **Consegue explicar**: O aluno sabe justificar o que aconteceu perante os visitantes da feira, utilizando previsões e evidências mensuráveis.

---

## 👥 Público-Alvo

* **Faixa etária principal**: Estudantes a partir do Ensino Fundamental II (9 a 14 anos) e iniciantes em física/eletrônica.
* **Pré-requisitos**: Nenhum conhecimento prévio de eletricidade é exigido. A jornada se inicia no reconhecimento tátil e visual dos componentes básicos.
* **Acessibilidade**: Projetado para interação tátil em smartphones e tablets, além de mouse e atalhos de teclado em computadores.

---

## 🗺️ Escopo do Produto

O EletroLab está estruturado em três eixos centrais de experiência:

### 1. Feira de Ciências da Comunidade (Modo Campanha)
Uma trilha progressiva composta por **10 estandes temáticos** (cada um com 5 missões práticas), cobrindo a evolução do conhecimento elétrico:
1. **Acende Aí**: Caminho fechado, fonte de alimentação e lâmpada incandescente.
2. **Liga e Desliga**: Chaves SPST, estados aberto/fechado e botões push-button.
3. **Ruas da Maquete**: Circuitos em série vs. circuitos em paralelo e manutenção de ramos independentes.
4. **Letreiros de LED**: Polaridade de semicondutores (ânodo e cátodo) e dimensionamento de resistor protetor.
5. **Movimento em Miniatura**: Motores CC, sentido de rotação por polaridade e comando mecânico.
6. **Mede, Testa e Explica**: Medição de grandezas com voltímetro/amperímetro e Lei de Ohm ($V = R \cdot I$).
7. **Circuito Seguro**: Diagnóstico de falhas, teste de continuidade e proteção com fusível didático.
8. **Horta Monitorada**: Sensores analógicos (LDR), potenciômetro e capacitores (*no backlog*).
9. **Portão da Escola**: Separação entre circuito de comando e carga com relé elétrico (*no backlog*).
10. **Praça da Maquete Coletiva**: Integração dos subsistemas na maquete final da comunidade (*no backlog*).

### 2. Primeiros Passos (Tutorial Essencial)
Guia inicial com os 8 componentes elementares da eletrônica (Bateria, Fio, Interruptor, Lâmpada, Resistor, Diodo, LED e Motor). Apresenta a dualidade visual entre a ilustração física 3D e o símbolo esquemático técnico (NBR/IEEE), acompanhado de um quiz formativo de fixação.

### 3. Bancada Livre (Modo Sandbox)
Ambiente de laboratório aberto para experimentação desimpedida:
* Adição e conexão livre de componentes no grid.
* Alternância instantânea entre modo Físico Realista e Diagrama Esquemático Técnico.
* Fiação com **Roteamento Ortogonal Inteligente (Manhattan Wire Routing)**.
* Instrumentos virtuais de bancada: **Cyber-Multímetro Digital 9000** e **Osciloscópio HUD**.
* Lógica didática de sobrecarga com queima visual de componentes (LED, lâmpada e motor).
* Assistente flutuante do Professor Volts com diagnósticos automáticos e botão de reparo instantâneo.

---

## 🏆 Critérios de Sucesso

A experiência é considerada bem-sucedida quando o aluno:
* Compreende que a corrente elétrica exige um percurso contínuo entre os polos da fonte.
* Diferencia montagens em série de montagens em paralelo, justificando a queda de tensão e a independência dos ramos.
* Reconhece a polaridade de componentes sensíveis e a necessidade de resistores para proteção de LEDs.
* Lê e correlaciona um esquema elétrico em diagrama técnico com a bancada física correspondente.
* Formula previsões antes de acionar um circuito e identifica a causa de uma anomalia elétrica através de testes metódicos.

---

## 🔗 Próximas Leituras

* [Requisitos Funcionais e Não Funcionais](requisitos.md)
* [Arquitetura Técnica e Módulos de Software](arquitetura.md)
* [Telas, UX e Fluxos de Navegação](ux-e-fluxos.md)
* [Conteúdo Detalhado dos Estandes e Missões](conteudo.md)
