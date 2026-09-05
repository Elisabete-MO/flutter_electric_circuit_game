# Conteúdo Pedagógico — Feira de Ciências da Comunidade

Este documento reúne o catálogo completo dos **10 Estandes**, as **50 Missões Reformuladas**, os diálogos do **Professor Volts** e os critérios da **Rubrica Avaliativa** do EletroLab.

---

## 🏛️ 1. Visão Geral dos 10 Estandes

| # | Estande | Equipe | Situação Central na Feira | Conceitos Didáticos Principais |
|---:|---|---|---|---|
| **01** | **Acende Aí** | Equipe Luz | Montar a iluminação da recepção da feira e evitar curtos. | Circuito fechado, percurso contínuo, fonte e lâmpada. |
| **02** | **Liga e Desliga** | Equipe Controle | Criar comandos acessíveis para os visitantes testarem a luz. | Chave SPST, estados ABERTO/FECHADO, desvios e push-buttons. |
| **03** | **Ruas da Maquete** | Equipe Bairro | Iluminar ruas e casas sem que uma falha apague toda a cidade. | Série vs. Paralelo, brilho e manutenção de ramos independentes. |
| **04** | **Letreiros de LED** | Equipe Sinalização | Construir placas luminosas de Entrada e Saída protegidas. | Polaridade (ânodo/cátodo), diodos LED e resistor limitador de 680 Ω. |
| **05** | **Movimento em Miniatura** | Equipe Mecânica | Controlar o sentido de um carrinho didático e ventilador. | Motor CC, inversão de rotação, pulso de partida e indicador. |
| **06** | **Mede, Testa e Explica** | Equipe Investigação | Usar medições exatas para solucionar o caso do LED fraco. | Tensão nodal (V), corrente (I), resistência (R) e Lei de Ohm. |
| **07** | **Circuito Seguro** | Equipe Segurança | Inspecionar montagens da feira antes de serem energizadas. | Curto-circuito, teste de continuidade e proteção com fusível. |
| **08** | **Horta Monitorada** | Equipe Ambiente | Fazer a iluminação da estufa responder ao anoitecer. | Potenciômetro, sensor LDR, capacitor e histerese. *(Backlog)* |
| **09** | **Portão da Escola** | Equipe Automação | Separar o botão de comando da carga mecânica potente. | Relé elétrico, circuito de comando (5V) vs. carga (12V). *(Backlog)* |
| **10** | **Praça da Maquete Coletiva** | Todas as Equipes | Integrar todos os subsistemas na maquete final comunitária. | Vistoria geral, eventos simultâneos e apresentação à banca. *(Backlog)* |

---

## 🎯 2. Catálogo das 50 Missões da Campanha

As missões seguem o ciclo obrigatório: **Preparar → Prever → Investigar → Projetar → Demonstrar**.

### Estande 01 — Acende Aí (Equipe Luz)
1. **Luz da Recepção** (`prepare`): Ligar a lâmpada principal da entrada com bateria de 4,5 V e condutores.
2. **Onde o Percurso Parou?** (`investigate`): Identificar qual terminal solto interrompeu a corrente na luminária.
3. **Duas Luzes, Uma Fonte** (`predict`): Prever se duas lâmpadas independentes funcionam com a mesma fonte e justificar.
4. **Antes de Energizar** (`design`): Prevenir uma ligação direta entre polos que causaria curto-circuito simulado.
5. **Explicação do Painel** (`demonstrate`): Demonstrar o circuito aos visitantes e explicar a necessidade de um percurso fechado.

### Estande 02 — Liga e Desliga (Equipe Controle)
1. **Interruptor em Série** (`prepare`): Instalar uma chave SPST no percurso da lâmpada.
2. **Aberto ou Fechado?** (`predict`): Prever o estado de condução da luz ao alternar a posição da alavanca.
3. **Mapeamento de Chaves** (`investigate`): Testar uma variável por vez para descobrir qual chave controla cada lâmpada.
4. **Correção de Desvio Inútil** (`design`): Remover uma chave montada em um ramo paralelo inútil e recolocá-la em série.
5. **Controle por Push-Button** (`demonstrate`): Montar botão de pressão que só mantém a lâmpada acesa sob toque contínuo do visitante.

### Estande 03 — Ruas da Maquete (Equipe Bairro)
1. **Primeiro Poste** (`prepare`): Ligar o primeiro poste de iluminação pública na maquete.
2. **Comparação Série vs. Paralelo** (`predict`): Prever o que acontece com o brilho e com o circuito ao retirar uma lâmpada em série e em paralelo.
3. **Casa em Manutenção** (`investigate`): Instalar uma chave que desliga uma residência para reparos sem apagar a vizinhança.
4. **Rede Completa do Bairro** (`design`): Projetar barramentos independentes para duas casas e dois postes com retornos protegidos.
5. **Demonstração de Confiabilidade** (`demonstrate`): Remover uma lâmpada durante a visita e explicar por que os demais pontos continuam acesos.

### Estande 04 — Letreiros de LED (Equipe Sinalização)
1. **Placa de Saída com LED** (`prepare`): Montar letreiro com LED, resistor de 680 Ω e bateria de 9 V respeitando a polaridade.
2. **Hipótese do LED Invertido** (`predict`): Formular e testar a hipótese de bloqueio de corrente por inversão de ânodo/cátodo.
3. **Escolha do Resistor** (`investigate`): Comparar resistores de 68 Ω (inseguro), 680 Ω (ideal) e 6,8 kΩ (fraco) antes de energizar.
4. **Entrada e Saída Independentes** (`design`): Construir dois letreiros paralelos, cada um com seu próprio resistor limitador de corrente.
5. **Revisão de Placa Defeituosa** (`demonstrate`): Corrigir letreiro com polaridade invertida e resistor incorreto perante o público.

### Estande 05 — Movimento em Miniatura (Equipe Mecânica)
1. **Primeiro Giro do Motor** (`prepare`): Fazer a hélice do ventilador didático girar com motor de corrente contínua.
2. **Inversão de Sentido do Carrinho** (`predict`): Prever o deslocamento do carrinho e inverter os polos para fazê-lo retornar.
3. **Partida por Push-Button** (`investigate`): Instalar botão de partida momentâneo para acionamento sob demanda.
4. **LED Indicador em Paralelo** (`design`): Criar um ramo com LED protegido que acende apenas enquanto o motor estiver energizado.
5. **Diagnóstico do Mini Carrinho** (`demonstrate`): Seguir a sequência de testes (fonte, chave, terminais) para reparar um mau contato e demonstrar.

### Estande 06 — Mede, Testa e Explica (Equipe Investigação)
1. **Tensão da Bateria** (`prepare`): Medir a tensão de 9 V conectando o voltímetro em paralelo com a fonte.
2. **Queda de Tensão na Carga** (`predict`): Posicionar as ponteiras nos extremos da lâmpada e interpretar a queda de potencial.
3. **Corrente e Resistor Variável** (`investigate`): Inserir amperímetro em série com potenciômetro e registrar a variação da corrente ($I$).
4. **Dimensionamento Seguro** (`design`): Escolher o resistor que garante brilho perceptível sem exceder os 20 mA nominais do LED.
5. **O Caso do LED Fraco** (`demonstrate`): Usar dados de tensão e corrente para eliminar as hipóteses de bateria gasta ou resistor superdimensionado.

### Estande 07 — Circuito Seguro (Equipe Segurança)
1. **Detector de Curto** (`prepare`): Identificar visualmente e reprovar montagem com desvio de baixa resistência antes de ligar a chave.
2. **Ruptura Oculta** (`investigate`): Utilizar teste de continuidade trecho a trecho para localizar fio interrompido.
3. **Instalação de Fusível Didático** (`design`): Inserir fusível de proteção no ramo principal para prevenir sobrecorrentes.
4. **Proteção de Carga Sensível** (`predict`): Dimensionar a proteção correta para evitar queima de carga delicada.
5. **Vistoria Completa da Feira** (`demonstrate`): Resolver em sequência curto-circuito, LED invertido e fusível rompido para liberar o selo de segurança.

### Estandes 08 a 10 (Planejados no Backlog)
* **Estande 08 (Horta)**: Ajuste com potenciômetro, sensor LDR dia/noite, capacitor de estabilização e controle híbrido.
* **Estande 09 (Portão)**: Bobina de relé em 5 V, isolamento entre comando e motor de 12 V, acionamento por NA e alarme luminoso.
* **Estande 10 (Maquete Coletiva)**: Integração das redes de iluminação, estufa e portão, suportando eventos simultâneos (noite e manutenção).

---

## 📊 3. Rubrica de Avaliação (3 Estrelas)

| Dimensão | 1 Ponto (Básico) | 2 Pontos (Adequado) | 3 Pontos (Excelente) |
|---|---|---|---|
| **Funciona** | Circuito atende ao objetivo após usar a dica do mascote. | Conclui a missão após uma ou duas correções na bancada. | O circuito funciona perfeitamente na primeira tentativa de teste. |
| **Está seguro** | Reconhece o alerta de curto ou sobretensão emitido pelo app. | Corrige o circuito após receber o aviso educativo de risco. | Prevê a falha antes do teste e instala proteções adequadas. |
| **Consegue explicar** | Apenas nomeia as peças ou seleciona alternativas ao acaso. | Explica a relação de causa e efeito em linguagem cotidiana. | Justifica a solução com evidências (previsão, medição de V/I ou modelo físico). |

---

## 🎙️ 4. Falas Canônicas do Professor Volts

> **Abertura da Feira:**  
> *"Bem-vindos à nossa Feira de Ciências! Um experimento científico de verdade não é apenas algo que funciona por acaso: ele precisa demonstrar uma ideia clara, ser seguro e ajudar os visitantes a entenderem a física do nosso cotidiano. Vamos preparar cada estande e, no final, integrar tudo na Maquete Coletiva!"*

> **Estande 04 (Letreiros de LED):**  
> *"Componentes semicondutores como LEDs possuem polaridade obrigatória: a corrente só passa no sentido direto, do ânodo para o cátodo. Além disso, sem um resistor para limitar a corrente, eles queimam em instantes!"*

> **Estande 06 (Mede, Testa e Explica):**  
> *"Na ciência, quando duas explicações parecem possíveis, nós não adivinhamos: nós medimos! Dados de tensão e corrente são as evidências que revelam a verdade."*

> **Encerramento da Feira (Maquete Coletiva):**  
> *"Parabéns, cientistas! Vocês fizeram muito mais do que conectar fios: formularam previsões, investigaram defeitos com método, protegeram seus circuitos e explicaram a ciência com clareza para a comunidade!"*

---

## 🔗 Próximas Leituras

* [Guia de Assets e Identidade Visual](assets.md)
* [Backlog e Próximos Passos](backlog.md)
* [Circuitos e Esquemas Técnicos Detalhados](referencias/circuitos_detalhados.md)
