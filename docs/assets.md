# Guia de Assets e Identidade Visual — EletroLab

Este documento lista os recursos gráficos, a paleta de cores oficial, as diretrizes de áudio e as convenções de renderização visual adotadas no EletroLab.

---

## 🎨 1. Paleta de Cores Oficial (Tech Lab & CyberHUD)

O sistema de cores do EletroLab é balanceado para contraste elevado, excelente legibilidade e imersão tecnológica:

### Cores de Fundo e Superfície
| Nome do Token | Hexadecimal | Uso Principal |
|---|---|---|
| `bgDark` | `#0B0F19` | Fundo principal da aplicação e canvas espacial. |
| `surfaceDark` | `#0F172A` | Superfície de cartões, Bento Grid e diálogos CyberHUD. |
| `surfaceElevated` | `#1E293B` | Cabeçalhos de painéis, toolbars e botões secundários. |
| `borderSubtle` | `#334155` | Bordas e divisores de elementos inativos. |

### Acentos de Status e Eletricidade
| Nome do Token | Hexadecimal | Uso Principal |
|---|---|---|
| `cyanElectric` | `#06B6D4` | Condutores energizados, partículas de elétrons e foco ativo. |
| `greenSuccess` | `#10B981` | Circuito fechado saudável, respostas corretas e selos de aprovação. |
| `amberWarning` | `#F59E0B` | Terminais flutuantes, chave aberta e alertas moderados de aquecimento. |
| `redHazard` | `#EF4444` | Curto-circuito, sobretensão, componente rompido e erro de polaridade. |
| `indigoAccent` | `#6366F1` | Destaques de navegação, botões primários de ação e cabeçalho da feira. |

---

## 📁 2. Inventário de Assets no Repositório

### 2.1. Componentes Físicos Transparentes (`assets/components/`)
Imagens em alta definição com canal alfa transparente utilizadas na Bancada Livre e nas missões práticas:

* `battery.png`: Bateria alcalina de 9 V com conectores de pressão (snap).
* `power_supply.png`: Fonte de bancada regulável com visor digital e bornes vermelho e preto.
* `bulb_off.png` / `bulb_on.png`: Lâmpada incandescente didática em estados inativo e iluminado.
* `led_off.png` / `led_on.png`: LED vermelho difuso em estados apagado e aceso.
* `resistor.png`: Resistor de filme de carbono com faixas de código de cores.
* `potentiometer.png`: Potenciômetro rotativo com botão graduado.
* `switch_open.png` / `switch_closed.png`: Interruptor de faca/alavanca nos estados aberto e fechado.
* `motor.png`: Mini motor de corrente contínua com eixo e suporte de fixação.
* `diode.png`: Diodo semicondutor cilíndrico com faixa de cátodo prateada.
* `fuse.png`: Fusível cilíndrico de vidro com filamento de proteção.
* `capacitor.png`: Capacitor eletrolítico cilíndrico com indicação de polo negativo.
* `buzzer.png`: Emissor sonoro piezoelétrico com bornes de alimentação.
* `wires.png`: Bobina de fios condutores coloridos.

### 2.2. Ilustrações dos Estandes da Feira (`assets/stands/`)
* `estande_01.png` até `estande_12.png`: Ilustrações isométricas exclusivas de cada estande da Feira de Ciências da Escola Comunitária.
* `quadra_trilha_esquerda_4k.png` e `quadra_trilha_direita_4k.png`: Imagens de fundo panorâmicas do ginásio escolar com a trilha de piso da feira.

### 2.3. Cenários e Personagens (`assets/intro/`)
* `gym_front.png` / `gym_front_open_door.png`: Fachada do ginásio da feira com portas fechadas e abertas.
* `spritesheet_nuri.png`: Animações da personagem estudante Nuri para introdução narrativa.

### 2.4. Fundos de Bancada (`assets/backgrounds/` e `assets/images/backgrounds/`)
* `background_fase_01_bancada.png`: Textura de bancada de madeira técnica.
* `background_fase_02_bancada.png`: Mesa de testes para inspeção guiada.
* `background_fase_03_prancheta_tecnica.png`: Prancheta com papel milimetrado para associação de símbolos esquemáticos.
* `mesa_eletrolab_vista_superior.png`: Visão superior da bancada de trabalho geral.

---

## 📐 3. Vetores Nativo vs. Imagens Rasterizadas

O EletroLab segue uma diretriz clara de renderização:
* **Assets Físicos (PNG 2D/3D)**: Utilizados quando se deseja familiarizar o aluno com o aspecto tangível dos componentes reais em laboratório.
* **Diagramas Esquemáticos (CustomPainter)**: Todos os símbolos esquemáticos (bateria, resistor em zigue-zague, lâmpada com "X", diodo com triângulo e barra, etc.) são **desenhados via código vetorial puro** na classe [`CircuitSymbolPainter`](file:///home/amanda/flutter_electric_circuit_game/lib/widgets/circuit_symbol_painter.dart). Isso garante:
  * Nitidez perfeita em qualquer nível de zoom ou densidade de tela (DPI).
  * Ausência de artefatos de compressão em cantos e linhas de $90^\circ$.
  * Cores dinâmicas reativas ao estado de energização do circuito.

---

## 🔊 4. Áudio e Efeitos Sonoros (`assets/audio/` e `assets/sounds/`)

* **Efeitos Curtos (SFX)**:
  * `click.mp3`: Feedback tátil ao pressionar interruptores e botões da bancada.
  * `snap.mp3`: Conexão magnética bem-sucedida de um fio condutor ao borne.
  * `success.mp3`: Conclusão bem-sucedida de uma missão ou quiz.
  * `short_circuit.mp3`: Alarme sutil de desarmamento por curto-circuito didático.
  * `burn.mp3`: Efeito de ruptura de filamento em lâmpada ou sobrecorrente em LED.
* **Trilha de Fundo (BGM)**: Música ambiente calma e futurista, com volume configurável e opção de desativação total nas Configurações.

---

## 🔗 Próximas Leituras

* [Backlog e Próximos Passos](backlog.md)
* [UX, Telas e Fluxos](ux-e-fluxos.md)
* [Conteúdo da Feira de Ciências](conteudo.md)
