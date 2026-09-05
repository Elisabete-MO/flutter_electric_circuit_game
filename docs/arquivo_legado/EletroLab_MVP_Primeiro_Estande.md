**ELETROLAB**

**Primeiro estande: iluminação da maquete**

*Documento de conceito e especificação do MVP jogável*

| **CONCEITO APROVADO** O aluno aprende do zero até conseguir montar e testar, sozinho, um circuito de corrente contínua para acender o primeiro ponto de luz de uma maquete. |
|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|

# 1. Visão do projeto

O EletroLab combina ensino guiado com uma bancada de experimentação. A experiência não começa exigindo que o aluno já saiba montar circuitos. Cada fase reduz gradualmente o apoio até chegar à construção independente.

| **Decisão**      | **Definição**                                                            |
|------------------|--------------------------------------------------------------------------|
| Público inicial  | Aluno sem contato prévio com circuitos elétricos.                        |
| Contexto         | Preparar a iluminação de uma pequena maquete para uma feira de ciências. |
| Tipo de circuito | Corrente contínua e baixa tensão, com componentes didáticos.             |
| Núcleo jogável   | Conhecer, inspecionar, representar, montar, prever e testar.             |
| Entrega imediata | Um primeiro estande curto, coerente e demonstrável em menos de 24 horas. |

# 2. Princípio pedagógico

A progressão parte do concreto e avança para a representação técnica e a aplicação prática. O aluno não recebe apenas textos e também não é lançado diretamente em um simulador aberto.

| **Etapa**       | **Ação do aluno**                               | **Aprendizado principal**                       |
|-----------------|-------------------------------------------------|-------------------------------------------------|
| 1\. Conhecer    | Explora componentes e responde a um quiz curto. | Nome, função, terminais e cuidados.             |
| 2\. Inspecionar | Analisa um circuito físico já montado.          | Segurança, polaridade, continuidade e resistor. |
| 3\. Representar | Relaciona cada componente ao símbolo elétrico.  | Leitura de diagramas.                           |
| 4\. Construir   | Monta e testa o circuito em uma bancada livre.  | Aplicação independente do conhecimento.         |

| **CICLO DE APRENDIZAGEM** Conhecer → inspecionar → representar → construir. |
|-----------------------------------------------------------------------------|

# 3. Componentes e parâmetros do MVP

| **Componente**   | **Função ensinada**                                   | **Regra no MVP**                                                    |
|------------------|-------------------------------------------------------|---------------------------------------------------------------------|
| Bateria de 9 V   | Fornecer diferença de potencial em corrente contínua. | Possui polos positivo e negativo.                                   |
| LED vermelho     | Converter energia elétrica em luz.                    | Vf didático de 2 V; ânodo voltado ao positivo e cátodo ao negativo. |
| Resistor         | Limitar a corrente e proteger o LED.                  | 680 Ω é o valor correto para a configuração ensinada.               |
| Interruptor SPST | Abrir ou fechar o caminho da corrente.                | Aberto: sem corrente; fechado: circuito energizado.                 |
| Fios             | Conectar terminais e formar o caminho condutor.       | Devem criar um percurso completo entre os dois polos.               |

# 4. Fase 1 — Conheça os componentes

## Objetivo

Apresentar os cinco componentes sem pressupor conhecimento anterior e confirmar o reconhecimento básico por meio de um quiz curto.

## Exploração

O aluno acessa um card para cada componente. Cada card apresenta nome, aparência, símbolo elétrico, função, terminais, polaridade quando aplicável e uma observação de segurança.

## Quiz

- Qual componente fornece energia ao circuito?

- Qual componente produz luz?

- Qual componente limita a corrente e protege o LED?

- Qual componente abre ou fecha o caminho da corrente?

- Qual elemento conecta os componentes?

## Regras de interação

- Perguntas de múltipla escolha com três alternativas.

- Feedback imediato e explicativo, sem apenas marcar certo ou errado.

- Nova tentativa permitida, sem penalidade.

- Conclusão após o aluno acertar todas as perguntas.

| **TRANSIÇÃO** “Componentes reconhecidos! Agora vamos conferir se um circuito está pronto para ser ligado.” |
|------------------------------------------------------------------------------------------------------------|

# 5. Fase 2 — Inspecione o circuito

## Objetivo

Ensinar o aluno a observar e avaliar uma montagem real antes de energizá-la. O circuito já aparece pronto na bancada; o desafio é decidir se está seguro e funcional.

| **INSTRUÇÃO AO ALUNO** “Antes de ligar a iluminação, inspecione o circuito e confirme se a montagem é segura e funcional.” |
|----------------------------------------------------------------------------------------------------------------------------|

## Circuito apresentado

**Bateria (+) → Interruptor → Resistor → LED → Bateria (−)**

## Itens verificados

| **Verificação** | **O que o aluno deve analisar**                                                 |
|-----------------|---------------------------------------------------------------------------------|
| Componentes     | Bateria, interruptor, resistor, LED e fios estão presentes.                     |
| Resistor        | O valor instalado é 680 Ω e é adequado para o circuito ensinado.                |
| Bateria         | O circuito utiliza os polos positivo e negativo, sem ligação direta entre eles. |
| LED             | Ânodo orientado ao lado positivo e cátodo ao lado negativo.                     |
| Interruptor     | O aluno identifica se está aberto ou fechado e prevê o resultado.               |
| Continuidade    | Existe um caminho completo, sem fio ausente nem curto-circuito.                 |

## Mecânica

1.  O aluno observa o circuito e toca nos componentes para consultar seus dados.

2.  Responde a perguntas de inspeção antes de testar.

3.  Declara se acredita que o circuito está pronto para ser ligado.

4.  Fecha o interruptor e testa a previsão.

5.  Recebe uma explicação e corrige a montagem quando houver erro.

## Variações possíveis

- Circuito correto: o aluno aprova e observa o LED acender.

- LED invertido: identifica a polaridade incorreta antes de testar.

- Resistor inadequado ou ausente: identifica risco de corrente excessiva.

- Circuito aberto: encontra a conexão interrompida.

| **LIMITAÇÃO PEDAGÓGICA** Nesta fase o cálculo do resistor não é cobrado. O jogo apresenta 680 Ω como valor adequado e pode mostrar o cálculo já resolvido. O objetivo é interpretar, não calcular do zero. |
|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|

# 6. Fase 3 — Do componente ao símbolo

## Objetivo

Relacionar o circuito físico inspecionado na fase anterior à sua representação em um diagrama elétrico.

## Referência visual aprovada

A interface será inspirada no simulador analisado: circuito central sobre fundo quadriculado, biblioteca vertical de símbolos, alternância entre os modos Físico e Diagrama e botões Verificar e Reiniciar.

## Funcionamento

6.  No modo Físico, o aluno vê bateria, interruptor, resistor e LED conectados.

7.  No modo Diagrama, as conexões permanecem visíveis e as posições dos componentes ficam vazias.

8.  Os símbolos aparecem embaralhados na barra lateral.

9.  O aluno arrasta cada símbolo para a posição do componente correspondente.

10. O botão Verificar confere identidade, orientação e estado dos símbolos.

| **Manter da referência**              | **Adaptar para o EletroLab**                                  |
|---------------------------------------|---------------------------------------------------------------|
| Fundo quadriculado e circuito central | Usar bateria, interruptor, resistor e LED.                    |
| Biblioteca vertical de símbolos       | Exibir poucas alternativas e embaralhá-las.                   |
| Alternância Físico/Diagrama           | Permitir consulta à montagem física durante a aprendizagem.   |
| Verificar e Reiniciar                 | Acrescentar feedback educativo para cada erro.                |
| Componentes encaixados no circuito    | Preservar polaridade da bateria, LED e estado do interruptor. |

## Símbolos disponíveis

- Corretos: bateria, interruptor, resistor e LED.

- Distratores controlados: lâmpada e diodo comum.

- O símbolo do LED deve ser colocado na orientação correspondente ao circuito físico.

- O símbolo do interruptor deve representar corretamente o estado aberto ou fechado.

## Decisões de escopo

- Os fios já ficam desenhados; o desafio é reconhecer os símbolos.

- Não há cronômetro no MVP.

- A posição visual é fixa nesta fase para facilitar a comparação entre físico e diagrama.

| **TRANSIÇÃO** “Muito bem! Você representou o circuito da bancada. Agora monte esse circuito sozinho.” |
|-------------------------------------------------------------------------------------------------------|

# 7. Fase 4 — Bancada livre

## Objetivo

Aplicar todo o conteúdo anterior em uma bancada vazia, permitindo que o aluno monte, conecte, preveja, teste e corrija o circuito sem posições predeterminadas.

| **MISSÃO FINAL** “Monte e teste sozinho o circuito responsável por acender o primeiro ponto de luz da maquete.” |
|-----------------------------------------------------------------------------------------------------------------|

## Biblioteca controlada

- Uma bateria de 9 V.

- Um interruptor SPST.

- Um LED vermelho.

- Resistores de 68 Ω, 680 Ω e 6,8 kΩ; o aluno deve escolher 680 Ω.

- Fios e ferramenta para remover conexões.

## Liberdade oferecida

- Posicionar os componentes em qualquer local da bancada.

- Escolher a organização visual e a ordem dos componentes no caminho em série.

- Conectar os terminais manualmente.

- Abrir e fechar o interruptor.

- Testar quantas vezes precisar e corrigir sem reiniciar toda a fase.

| **REGRA DE VALIDAÇÃO** A validade depende das conexões elétricas, e não das coordenadas dos componentes. Resistor antes ou depois do LED é válido se ambos estiverem no mesmo caminho em série. |
|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|

## Validações do simulador

| **Situação**              | **Resposta esperada**                                              |
|---------------------------|--------------------------------------------------------------------|
| Circuito correto          | LED e primeiro ponto da maquete acendem.                           |
| Interruptor aberto        | Circuito válido, porém sem corrente; LED apagado.                  |
| LED invertido             | LED permanece apagado e o jogo orienta conferir ânodo e cátodo.    |
| Resistor de 68 Ω          | Alerta de corrente excessiva e teste seguro bloqueado ou simulado. |
| Resistor de 6,8 kΩ        | Corrente baixa e LED muito fraco ou apagado no modelo didático.    |
| Resistor ausente          | Alerta de proteção ausente.                                        |
| Fio ausente               | Circuito aberto; trecho incompleto é indicado.                     |
| Polos ligados diretamente | Curto-circuito; energização bloqueada.                             |

## Ciclo final: previsão, teste e explicação

11. Depois de montar, o aluno pressiona Testar.

12. Antes da energização, prevê se o LED acenderá, ficará apagado, receberá corrente excessiva ou se existe curto-circuito.

13. Confirma em Energizar circuito.

14. Observa o interruptor, o caminho energizado e o comportamento do LED.

15. Corrige possíveis erros permanecendo na mesma bancada.

16. Quando a montagem estiver correta, consulta o painel de resultados.

## Painel de resultados

| **Grandeza**         | **Resultado didático**      |
|----------------------|-----------------------------|
| Tensão da bateria    | 9 V                         |
| Tensão direta do LED | 2 V                         |
| Resistor selecionado | 680 Ω                       |
| Corrente aproximada  | 10,3 mA                     |
| Avaliação            | Circuito seguro e funcional |

**I = (9 V − 2 V) ÷ 680 Ω ≈ 10,3 mA**

## Pergunta de conclusão

**“Por que o LED apagará quando o interruptor for aberto?”**

- Resposta correta: porque o caminho da corrente será interrompido.

## Sistema de pistas

17. Pista conceitual: “A corrente precisa percorrer um caminho completo.”

18. Pista direcionada: “Confira a orientação do LED e o valor do resistor.”

19. Pista visual: destacar os terminais ou o componente com problema.

## Conclusão visual

- O LED da bancada acende.

- O primeiro ponto de luz da maquete acende simultaneamente.

- Uma animação curta confirma o resultado.

- O jogo mostra lado a lado a montagem física e o diagrama correspondente.

| **MENSAGEM FINAL** “Circuito concluído! Você identificou os componentes, inspecionou a montagem, interpretou o diagrama e construiu um circuito funcional.” |
|-------------------------------------------------------------------------------------------------------------------------------------------------------------|

# 8. Regras elétricas consolidadas

- O circuito é de corrente contínua e baixa tensão.

- O LED é polarizado e precisa estar orientado corretamente.

- O resistor deve estar em série com o LED, mas pode aparecer antes ou depois dele.

- O interruptor apenas abre ou fecha o caminho; ele não fornece energia.

- A corrente só circula quando existe um caminho fechado entre os dois polos da fonte.

- Ligação direta entre positivo e negativo deve ser tratada como curto-circuito.

- Transistor, relé, capacitor, fusível, disjuntor e microcontrolador não são necessários neste MVP.

# 9. Interface e experiência

| **Elemento**   | **Diretriz**                                                                    |
|----------------|---------------------------------------------------------------------------------|
| Linguagem      | Frases curtas, acessíveis e sem presumir vocabulário técnico.                   |
| Feedback       | Explicar a causa do erro e permitir nova tentativa.                             |
| Bancada        | Área central ampla, fundo quadriculado e terminais visíveis.                    |
| Biblioteca     | Vertical no desktop; horizontal e rolável no mobile.                            |
| Responsividade | Garantir funcionamento mínimo em 360 × 740.                                     |
| Tempo          | Sem cronômetro nas fases de aprendizagem do MVP.                                |
| Reinício       | Reiniciar quando solicitado; erros não apagam automaticamente a montagem.       |
| Visual         | O circuito é o foco; narrativa e textos não devem ocupar a maior parte da tela. |

# 10. Critérios de conclusão por fase

| **Fase**          | **Critério mínimo de conclusão**                                                      |
|-------------------|---------------------------------------------------------------------------------------|
| 1\. Componentes   | Visualizar os cinco cards e acertar as perguntas do quiz.                             |
| 2\. Inspeção      | Avaliar corretamente resistor, polaridade, continuidade e interruptor antes do teste. |
| 3\. Símbolos      | Posicionar os quatro símbolos, com orientação e estado corretos.                      |
| 4\. Bancada livre | Montar, prever e energizar um circuito seguro que acenda o LED.                       |

# 11. Prioridades para a apresentação

20. Garantir navegação completa pelas quatro fases.

21. Fazer o circuito físico responder ao interruptor e à polaridade do LED.

22. Validar presença e valor do resistor.

23. Implementar associação entre componentes e símbolos inspirada na referência aprovada.

24. Permitir montagem, conexão, teste e correção na bancada livre.

25. Acender visualmente o primeiro ponto da maquete ao concluir.

# 12. Fora do escopo imediato

Os itens abaixo permanecem como evolução do EletroLab, mas não devem comprometer a demonstração atual:

- LEDs em série e paralelo com múltiplos ramos.

- Baterias em série ou paralelo.

- Iluminação completa de vários setores da maquete.

- Quadro de distribuição, fusíveis e disjuntores.

- Transistores, sensores, motores, relés e capacitores.

- Cálculos avançados e instrumentos de medição.

- Cronômetro, pontuação complexa e campanha extensa.

# 13. Evidência que o MVP deve produzir

Ao final da apresentação, deve ficar comprovado que o EletroLab:

- ensina um aluno iniciante sem exigir conhecimento prévio;

- relaciona componente físico e símbolo elétrico;

- analisa conexões elétricas, e não apenas posições na tela;

- diferencia circuito correto, aberto, invertido e perigoso;

- permite experimentar, errar, corrigir e testar novamente;

- transforma o conhecimento guiado em uma montagem independente.

| **RESUMO DO MVP** Um primeiro estande com quatro fases jogáveis: estudo dos componentes, inspeção de um circuito pronto, associação com símbolos e montagem livre de um circuito completo para iluminar a maquete. |
|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
