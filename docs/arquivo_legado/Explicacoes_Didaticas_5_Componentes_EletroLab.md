# EletroLab — explicações didáticas dos cinco componentes

**Público:** alunos iniciantes, aproximadamente 9 a 11 anos  
**Uso previsto:** cards da Fase 1, painel de consulta da Fase 2 e feedbacks das Fases 3 e 4  
**Data da pesquisa:** 4 de setembro de 2026

## 1. Escopo e decisões pedagógicas

Este material segue o circuito definido na documentação do primeiro estande:

**bateria de 9 V + interruptor SPST + resistor de 680 Ω + LED vermelho + fios de conexão**, todos no mesmo caminho em série.

O modelo didático adota:

- tensão da bateria: **9 V**;
- tensão direta aproximada do LED vermelho: **2 V**;
- resistor adequado ao desafio: **680 Ω**;
- corrente aproximada: **10,3 mA**, pois \(I=(9-2)/680\).

Esses números descrevem o modelo do EletroLab. LEDs reais variam conforme o modelo, a corrente e a temperatura; por isso, “2 V” não deve ser apresentado como uma regra universal. O circuito também deve ser descrito como um **caminho fechado**: a bateria cria a diferença de potencial, mas a corrente somente se mantém quando existe uma volta completa entre os dois polos. Essa formulação é consistente com a documentação do projeto e com as explicações de circuitos em série da [OpenStax](https://openstax.org/books/physics/pages/19-2-series-circuits).

### Estrutura recomendada para a interface

Cada componente possui abaixo:

1. **texto curto**, para leitura imediata no card;
2. **explicação ampliada**, aberta por “Saiba mais”;
3. **o que observar**, ligando o conceito ao asset físico;
4. **cuidado**, em linguagem simples;
5. **checagem rápida**, para confirmar compreensão sem decorar frases.

---

## 2. Bateria de 9 V

### Texto curto para o card

**A bateria fornece a diferença de potencial que faz as cargas se moverem quando o circuito está fechado.** Ela possui dois polos: positivo (+) e negativo (−). No circuito do EletroLab, a corrente convencional sai do polo positivo, atravessa os componentes e retorna ao polo negativo. Se o caminho estiver interrompido, a bateria continua com tensão, mas não há corrente percorrendo todo o circuito.

### Explicação ampliada

Pense na bateria como uma pequena “bomba de energia”: as reações químicas em seu interior separam cargas e mantêm uma diferença de energia elétrica entre os dois polos. Essa diferença é chamada **tensão** e é medida em volts. A bateria alcalina usada como referência possui tensão nominal de **9,0 V** e conector do tipo snap, conforme a ficha técnica da [Energizer EN22](https://data.energizer.com/pdfs/en522.pdf).

A bateria não “empurra energia para dentro” de apenas um componente. Para a corrente circular, os fios e componentes precisam formar uma volta completa do polo positivo ao negativo. Em um circuito em série, a mesma corrente passa por todos os componentes do único caminho. A analogia da bomba e do circuito fechado é apresentada pela [OpenStax](https://openstax.org/books/physics/pages/19-2-series-circuits).

Nos diagramas, usamos a **corrente convencional**, indicada do positivo para o negativo. Nos fios metálicos, os elétrons se deslocam no sentido oposto. Essa distinção pode entrar em “Curiosidade”, sem ser cobrada no primeiro quiz; ela evita a ideia errada de que elétrons saem do polo positivo. A [OpenStax](https://openstax.org/books/university-physics-volume-2/pages/9-1-electrical-current) explica explicitamente essa convenção.

### O que observar no componente

- Os sinais **+** e **−** identificam os polos.
- A bateria de 9 V tem os dois contatos na parte superior.
- O encaixe deve respeitar a polaridade; o aluno nunca deve adivinhar apenas pela cor do fio.
- No jogo, o polo positivo inicia o caminho convencional e o negativo fecha a volta.

### Cuidado

**Nunca encoste um metal diretamente nos dois polos.** Isso cria um curto-circuito: um caminho de resistência muito baixa, capaz de descarregar e aquecer a bateria. A [Energizer](https://energizer.com/eu/turkey/dos-donts/) alerta que objetos metálicos podem causar curto, calor ou vazamento; a [Duracell](https://duracell.com/technology/battery-care-use-and-disposal) também orienta manter as baterias longe de objetos metálicos e não recarregar pilhas que não estejam identificadas como recarregáveis.

### Checagem rápida

**A bateria está conectada a um LED, mas existe uma abertura no caminho. O LED acende?**  
Não. A tensão existe entre os polos, porém falta um caminho completo para a corrente.

---

## 3. Interruptor SPST

### Texto curto para o card

**O interruptor funciona como uma porta no caminho da corrente.** SPST significa que ele controla um único caminho com uma única ação de ligar ou desligar. Aberto, seus contatos ficam separados e a corrente não completa a volta. Fechado, os contatos se unem e permitem que a corrente atravesse o circuito.

### Explicação ampliada

O interruptor não produz energia e não “gasta” a corrente. Ele apenas decide se o caminho condutor está unido ou interrompido. No estado **aberto**, existe uma lacuna entre os contatos; no estado **fechado**, os contatos encostam e passam a funcionar quase como uma continuação do fio. A [OpenStax](https://openstax.org/books/physics/pages/19-2-series-circuits) descreve o interruptor aberto como bloqueio da corrente e o fechado como parte do caminho condutor.

O nome **SPST** vem de *Single Pole, Single Throw*. Para o aluno iniciante, a tradução útil é: “um controle para um caminho, com duas situações: aberto ou fechado”. Interruptores de alavanca SPST normalmente têm dois terminais, como mostra o guia de botões e interruptores da [SparkFun](https://learn.sparkfun.com/tutorials/button-and-switch-basics/maintained-switches). Em um modelo de simulação, o estado fechado tem resistência muito pequena e o aberto tem resistência muito grande, conforme a explicação técnica da [National Instruments](https://knowledge.ni.com/KnowledgeArticleDetails?id=kA00Z000000P7e9SAC).

No EletroLab, o estado inicial deve ser **aberto**, deixando o LED apagado. Depois da inspeção e da previsão, o aluno fecha o interruptor para testar a montagem.

### O que observar no componente

- Dois terminais elétricos.
- Uma alavanca móvel.
- **Aberto:** a ponte metálica não toca o outro contato.
- **Fechado:** os contatos estão unidos.
- O interruptor não possui polo positivo ou negativo neste circuito simples.

### Cuidado

Antes de fechar o interruptor, confira se há resistor, se o LED está orientado corretamente e se não existe ligação direta entre os polos da bateria. O interruptor deve iniciar o teste, não substituir a inspeção.

### Checagem rápida

**Se todos os componentes estiverem corretos, mas o interruptor estiver aberto, o que acontece?**  
O circuito está montado, porém não há corrente no caminho completo e o LED permanece apagado.

---

## 4. Resistor

### Texto curto para o card

**O resistor limita a corrente e protege o LED.** Quanto maior sua resistência, mais ele dificulta a passagem de corrente. A resistência é medida em ohms (Ω). No desafio, o valor correto é **680 Ω**: com bateria de 9 V e LED vermelho de aproximadamente 2 V, a corrente fica perto de **10,3 mA**.

### Explicação ampliada

O resistor não “guarda” corrente. Ele oferece uma oposição controlada à passagem das cargas e transforma parte da energia elétrica em calor. Pela lei de Ohm, \(V=IR\); para uma mesma tensão disponível, aumentar a resistência reduz a corrente. A relação entre tensão, corrente e resistência, assim como a função do resistor em um circuito em série, é apresentada pela [OpenStax](https://openstax.org/books/physics/pages/19-2-series-circuits).

No EletroLab, o LED usa aproximadamente 2 V dos 9 V da bateria. Restam cerca de 7 V sobre o resistor:

\[
I=\frac{9\text{ V}-2\text{ V}}{680\,\Omega}\approx0{,}0103\text{ A}=10{,}3\text{ mA}
\]

Essa corrente é coerente com um pequeno LED vermelho indicador. A ficha de um LED vermelho de 5 mm da [SparkFun](https://www.sparkfun.com/led-basic-red-5mm.html) informa queda direta típica de 2,0 V e especifica limites próprios do componente; já a ficha do [Kingbright WP7113ID](https://www.kingbrightusa.com/images/catalog/SPEC/WP7113ID.pdf) mostra que corrente, tensão direta e brilho variam juntos. Portanto, o jogo deve dizer “valor adequado **para este desafio**”, não “680 Ω é sempre o resistor certo para qualquer LED”.

### Código de cores — como ler um resistor de quatro faixas

A norma [IEC 60062](https://webstore.iec.ch/en/publication/25395) define códigos de marcação, incluindo cores para valor e tolerância. Em um resistor comum de **quatro faixas**:

1. a primeira faixa fornece o primeiro algarismo;
2. a segunda fornece o segundo algarismo;
3. a terceira é o multiplicador;
4. a quarta indica a tolerância, isto é, quanto o valor real pode variar.

| Cor | Algarismo | Multiplicador | Tolerância comum |
|---|---:|---:|---:|
| Preto | 0 | ×1 | — |
| Marrom | 1 | ×10 | ±1% |
| Vermelho | 2 | ×100 | ±2% |
| Laranja | 3 | ×1.000 | — |
| Amarelo | 4 | ×10.000 | — |
| Verde | 5 | ×100.000 | ±0,5% |
| Azul | 6 | ×1.000.000 | ±0,25% |
| Violeta | 7 | ×10.000.000 | ±0,1% |
| Cinza | 8 | ×100.000.000 | ±0,05% |
| Branco | 9 | ×1.000.000.000 | — |
| Dourado | — | ×0,1 | ±5% |
| Prateado | — | ×0,01 | ±10% |

Os valores da tabela foram conferidos no calculador técnico da [DigiKey](https://www.digikey.com/en/resources/conversion-calculators/conversion-calculator-resistor-color-code) e no escopo normativo da IEC 60062.

### Exemplo principal: 680 Ω

**Azul – cinza – marrom – dourado**

- azul = 6;
- cinza = 8;
- marrom = multiplicar por 10;
- dourado = tolerância de ±5%;
- resultado: \(68\times10=680\,\Omega\), com valor real esperado entre **646 Ω e 714 Ω**.

### Os três resistores do desafio

| Valor | Faixas de 4 bandas (±5%) | Resultado no modelo didático |
|---:|---|---|
| 68 Ω | azul – cinza – preto – dourado | Corrente excessiva; teste seguro bloqueado. |
| 680 Ω | azul – cinza – marrom – dourado | Corrente aproximada de 10,3 mA; opção correta. |
| 6,8 kΩ | azul – cinza – vermelho – dourado | Corrente próxima de 1,03 mA; LED muito fraco ou apagado no modelo. |

### O que observar no componente

- O resistor possui dois terminais e **não tem polaridade**: pode ser colocado em qualquer sentido.
- Para começar a leitura, deixe a faixa de tolerância — muitas vezes dourada e mais afastada — à direita.
- O resistor pode ficar antes ou depois do LED, desde que ambos estejam no mesmo caminho em série.

### Cuidado

Nunca ligue o LED diretamente à bateria de 9 V. O LED precisa de um elemento que limite a corrente. Além do valor em ohms, resistores reais possuem potência máxima; no circuito didático, a potência aproximada no resistor é \(P=I^2R\approx0{,}072\text{ W}\), compatível com resistores educacionais comuns de 1/4 W, mas a implementação deve manter os componentes reais e suas especificações sob supervisão.

### Checagem rápida

**Qual sequência identifica 680 Ω em quatro faixas e tolerância de 5%?**  
Azul, cinza, marrom e dourado.

---

## 5. LED vermelho

### Texto curto para o card

**LED significa diodo emissor de luz.** Ele transforma parte da energia elétrica em luz e permite a corrente principalmente em um sentido. O terminal positivo é o **ânodo** e o negativo é o **cátodo**. No EletroLab, o ânodo aponta para o lado positivo da bateria e o cátodo para o lado negativo, sempre com um resistor em série.

### Explicação ampliada

O LED é um tipo de diodo feito de material semicondutor. Quando está polarizado no sentido correto e recebe corrente dentro de uma faixa adequada, libera energia em forma de luz. A [ENERGY STAR](https://www.energystar.gov/products/learn-about-led-lighting) descreve o LED como diodo emissor de luz e explica a conversão de energia elétrica em luz; para o componente de laboratório, a [SparkFun](https://learn.sparkfun.com/tutorials/light-emitting-diodes-leds/all) detalha ânodo, cátodo e polaridade.

Em muitos LEDs de 5 mm novos, a perna mais longa identifica o **ânodo (+)**, enquanto a perna mais curta e o lado achatado do encapsulamento indicam o **cátodo (−)**. Contudo, pernas podem ter sido cortadas e há diferentes encapsulamentos; por isso, o desenho do componente, a marca física e a ficha técnica devem prevalecer.

O LED vermelho usado como referência tem queda direta em torno de **2 V**. A [SparkFun](https://www.sparkfun.com/led-basic-red-5mm.html) especifica 1,8–2,2 V para seu modelo, e o gráfico do [Kingbright WP7113ID](https://www.kingbrightusa.com/images/catalog/SPEC/WP7113ID.pdf) mostra a relação não linear entre tensão direta e corrente. Isso explica por que o resistor é indispensável: uma pequena variação de tensão pode causar um aumento grande da corrente.

### O que observar no componente

- Perna longa: normalmente ânodo (+).
- Perna curta: normalmente cátodo (−).
- Lado achatado do corpo: normalmente marca o cátodo.
- No símbolo elétrico, o traço do diodo marca o lado do cátodo; as duas setas apontando para fora representam a luz emitida.
- LED invertido permanece apagado no modelo do jogo.

### Cuidado

Use sempre o resistor em série e não ultrapasse as especificações do LED real. A ficha da Kingbright alerta que corrente excessiva e temperatura elevada podem degradar seriamente a luz ou causar falha prematura. Também não se deve testar a polaridade conectando o LED repetidamente e sem limitação de corrente a uma bateria de 9 V.

### Checagem rápida

**O LED está com o cátodo voltado para o positivo. O que deve ser corrigido?**  
Inverta o LED: ânodo para o lado positivo e cátodo para o lado negativo.

---

## 6. Fios de conexão

### Texto curto para o card

**Os fios ligam os terminais e formam o caminho por onde as cargas se movem.** Por dentro, há um material condutor; por fora, uma camada isolante ajuda a impedir contatos indesejados. Um único fio ausente ou mal conectado abre o circuito e impede o LED de acender.

### Explicação ampliada

Os fios não criam energia e não “gastam” toda a tensão. Sua função é unir pontos do circuito com baixa resistência. Em modelos introdutórios, tratamos os fios como condutores quase perfeitos, embora fios reais tenham pequena resistência. A [OpenStax](https://openstax.org/books/physics/pages/19-2-series-circuits) usa linhas finas para representar o caminho condutor e ressalva que fios reais não são perfeitos, apenas suficientemente bons para esse modelo.

Muitos fios didáticos usam cobre porque ele conduz corrente muito bem. A [Copper Development Association](https://copper.org/resource-library/electrical-1/) o apresenta como referência de condutividade elétrica entre metais de uso comum. O plástico colorido ao redor não conduz a corrente nas condições normais: ele isola o condutor e ajuda a organizar a montagem.

**Continuidade** significa existir um caminho completo. Um teste de continuidade verifica se uma conexão, fio ou interruptor oferece esse caminho. A [Fluke](https://www.fluke.com/en-us/learn/blog/digital-multimeters/how-to-test-for-continuity) define continuidade como a presença de um percurso completo para a corrente e orienta realizar o teste com o circuito desenergizado.

As cores dos jumpers ajudam a ler a montagem, mas não mudam o comportamento elétrico. Adote uma convenção consistente — por exemplo, vermelho para o lado positivo e preto para o retorno negativo — sem ensinar que “fio vermelho é sempre positivo” por natureza. A conexão real é determinada pelos terminais aos quais o fio está ligado.

### O que observar no componente

- Duas extremidades condutoras, uma em cada ponta.
- Isolamento intacto no trecho central.
- Conector firmemente encaixado no terminal correto.
- Nenhuma ponta solta tocando outro polo ou terminal.
- Todos os trechos formam uma única volta, sem lacunas.

### Cuidado

Nunca una diretamente os polos positivo e negativo da bateria. Antes de testar continuidade com um multímetro real, desligue e desconecte a fonte de energia. No jogo, um fio ausente deve produzir “circuito aberto”; uma ligação direta entre os polos deve produzir “curto-circuito” e impedir a energização.

### Checagem rápida

**Todos os componentes estão corretos, mas um jumper está solto. O LED acende?**  
Não. O caminho perdeu continuidade e o circuito ficou aberto.

---

## 7. Como os cinco componentes trabalham juntos

Quando o interruptor é fechado e a montagem está correta:

1. a bateria mantém 9 V entre seus polos;
2. os fios formam o caminho condutor;
3. o interruptor fechado completa esse caminho;
4. o resistor limita a corrente;
5. o LED, orientado corretamente, emite luz;
6. a corrente retorna ao outro polo da bateria.

Em um circuito em série existe um único caminho, portanto a mesma corrente atravessa bateria, interruptor, resistor, LED e fios. A ordem física entre resistor e LED pode mudar sem alterar a corrente, desde que os dois continuem em série e a polaridade do LED permaneça correta. Esse princípio é sustentado pela explicação de circuitos em série da [OpenStax](https://openstax.org/books/physics/pages/19-2-series-circuits).

## 8. Recomendações para os cards do jogo

- Mostrar no primeiro nível apenas **função, terminais, polaridade e cuidado**.
- Abrir cálculo, corrente convencional e tolerância em uma camada “Saiba mais”.
- Usar animação de fluxo somente quando o circuito estiver fechado; não mostrar corrente atravessando uma interrupção.
- No resistor, desenhar as faixas com cores chapadas e incluir também os nomes das cores, para não depender apenas da percepção cromática.
- Oferecer alternativa acessível ao código de cores: valor “680 Ω” escrito e descrição textual das faixas.
- Evitar “a bateria contém eletricidade” e “o resistor consome corrente”. Preferir “a bateria mantém uma diferença de potencial” e “o resistor limita a corrente”.
- Tratar 2 V e 10,3 mA como **valores aproximados do modelo didático**.
- Não cobrar cálculo do resistor na Fase 2, conforme a documentação; mostrar o cálculo resolvido como explicação.

## 9. Matriz de cruzamento das fontes

| Componente | Fonte 1 | Fonte 2 | Fonte 3 | Fonte adicional | Conclusão cruzada |
|---|---|---|---|---|---|
| Bateria de 9 V | [Energizer EN22](https://data.energizer.com/pdfs/en522.pdf) | [Duracell — uso e cuidado](https://duracell.com/technology/battery-care-use-and-disposal) | [OpenStax — circuitos em série](https://openstax.org/books/physics/pages/19-2-series-circuits) | [OpenStax — corrente elétrica](https://openstax.org/books/university-physics-volume-2/pages/9-1-electrical-current) | 9 V nominal; polos definidos; energia química mantém tensão; corrente exige caminho fechado; curto deve ser evitado. |
| Interruptor SPST | [SparkFun — switches](https://learn.sparkfun.com/tutorials/button-and-switch-basics/maintained-switches) | [OpenStax — circuitos em série](https://openstax.org/books/physics/pages/19-2-series-circuits) | [NI — modelo SPST](https://knowledge.ni.com/KnowledgeArticleDetails?id=kA00Z000000P7e9SAC) | [Fluke — continuidade](https://www.fluke.com/en-us/learn/blog/digital-multimeters/how-to-test-for-continuity) | SPST controla um caminho; aberto interrompe; fechado oferece caminho de baixa resistência. |
| Resistor | [IEC 60062](https://webstore.iec.ch/en/publication/25395) | [DigiKey — código de cores](https://www.digikey.com/en/resources/conversion-calculators/conversion-calculator-resistor-color-code) | [OpenStax — circuitos e lei de Ohm](https://openstax.org/books/physics/pages/19-2-series-circuits) | [SparkFun — LED vermelho](https://www.sparkfun.com/led-basic-red-5mm.html) | Limita corrente; 680 Ω resulta em ~10,3 mA no modelo; azul-cinza-marrom-dourado identifica 680 Ω ±5%. |
| LED vermelho | [Kingbright WP7113ID](https://www.kingbrightusa.com/images/catalog/SPEC/WP7113ID.pdf) | [SparkFun — tutorial de LEDs](https://learn.sparkfun.com/tutorials/light-emitting-diodes-leds/all) | [SparkFun — LED vermelho 5 mm](https://www.sparkfun.com/led-basic-red-5mm.html) | [ENERGY STAR — LED](https://www.energystar.gov/products/learn-about-led-lighting) | É polarizado; converte energia elétrica em luz; queda direta depende do modelo e da corrente; requer limitação de corrente. |
| Fios | [OpenStax — circuitos em série](https://openstax.org/books/physics/pages/19-2-series-circuits) | [Fluke — continuidade](https://www.fluke.com/en-us/learn/blog/digital-multimeters/how-to-test-for-continuity) | [Copper Development Association](https://copper.org/resource-library/electrical-1/) | [Duracell — prevenção de curto](https://duracell.com/technology/battery-care-use-and-disposal) | Fios formam o caminho de baixa resistência; cobre é bom condutor; continuidade requer percurso completo; contato indevido pode causar curto. |

## 10. Limitações e ressalvas

- As características elétricas exatas variam entre fabricantes e modelos; consultar a ficha técnica do componente físico usado em sala.
- A fonte da IEC confirma o escopo normativo do código de cores; a tabela operacional foi conferida na ferramenta técnica da DigiKey porque o texto integral da norma é licenciado.
- A analogia com água ajuda a introduzir tensão e corrente, mas não deve ser tratada como uma descrição literal do movimento microscópico das cargas.
- O protótipo usa baixa tensão, porém ainda exige supervisão: curtos podem aquecer bateria e fios.
- O cálculo de 10,3 mA trata bateria e LED por aproximações didáticas; uma simulação avançada poderia incluir resistência interna da bateria e curva real do LED, mas isso não é necessário para o objetivo do primeiro estande.

## 11. Registro de afirmações e evidências

| Afirmação usada no conteúdo | Evidência principal | Confiança |
|---|---|---|
| A bateria de referência é alcalina e tem tensão nominal de 9,0 V. | Ficha Energizer EN22. | Alta |
| Corrente em um circuito simples exige caminho fechado. | OpenStax; Fluke. | Alta |
| Corrente convencional e elétrons em metais têm sentidos opostos. | OpenStax. | Alta |
| SPST abre ou fecha um único caminho. | SparkFun; OpenStax; NI. | Alta |
| 680 Ω produz cerca de 10,3 mA no modelo 9 V/2 V. | Lei de Ohm + parâmetros da documentação; cálculo reproduzido. | Alta no modelo |
| 680 Ω ±5% usa azul–cinza–marrom–dourado em quatro faixas. | IEC 60062; DigiKey. | Alta |
| Um LED vermelho de 5 mm pode ter queda direta próxima de 2 V. | SparkFun; Kingbright. | Alta para os modelos citados |
| LED exige polaridade correta e limitação de corrente. | SparkFun; Kingbright. | Alta |
| Continuidade é a presença de caminho completo. | Fluke; OpenStax. | Alta |
| A cor externa do jumper é convenção, não propriedade elétrica. | Inferência de engenharia baseada na função do condutor e das conexões. | Alta |

