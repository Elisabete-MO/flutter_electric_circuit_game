# EletroLab

**EletroLab — Laboratório Virtual Educacional de Circuitos Elétricos**

Aplicação educacional interativa de simulação de circuitos elétricos desenvolvida em **Flutter** (Material 3) com renderização gráfica nativa via **CustomPainter** e gerenciamento de estado previsível com **Riverpod**.

O EletroLab permite montar circuitos, arrastar componentes, conectar fios magnéticos, controlar chaves e interruptores, observar a corrente elétrica didática animada, medir grandezas com instrumentos virtuais e resolver missões práticas na **Feira de Ciências da Comunidade** ou experimentar livremente na **Bancada Livre**.

> O EletroLab possui identidade visual, textos, simulação e código próprios, inspirando-se puramente no *conceito* pedagógico de simuladores de circuitos em baixa tensão.

---

## 🎯 Proposta Pedagógica

O objetivo central é ensinar conceitos fundamentais de eletricidade e circuitos elétricos (Lei de Ohm, percurso fechado, circuitos em série e paralelo, polaridade e proteção) para estudantes e iniciantes a partir de 9 anos.

A experiência é guiada por três princípios avaliativos:
1. **Funciona**: O circuito fecha a malha e atende ao objetivo prático.
2. **Está seguro**: Previne danos, sobrecargas e curtos-circuitos antes de energizar.
3. **Consegue explicar**: O estudante prevê comportamentos, formula hipóteses e justifica suas observações para os visitantes da feira.

---

## 🕹️ Modos de Jogo e Funcionalidades

- **Feira de Ciências da Comunidade**: Campanha estruturada em 10 estandes temáticos (5 missões práticas por estande), coordenada pelo **Professor Volts**:
  - **Estande 01 — Acende Aí / Primeiro Estande**: Percurso fechado, lâmpada e jornada em 4 fases.
  - **Estande 02 — Liga e Desliga**: Chaves SPST, push-buttons e ramos de controle.
  - **Estande 03 — Ruas da Maquete**: Postes em série vs. paralelo e manutenção isolada.
  - **Estande 04 — Letreiros de LED**: Polaridade de semicondutores e resistor limitador de 680 Ω.
  - **Estande 05 — Movimento em Miniatura**: Motores CC, inversão de rotação e comando por botão.
  - **Estande 06 — Mede, Testa e Explica**: Medição de tensão com voltímetro, queda de tensão e Lei de Ohm.
  - **Estande 07 — Circuito Seguro**: Inspeção de curto-circuito, teste de continuidade e fusível didático.
  - **Estandes 08 a 10**: Horta monitorada (LDR/potenciômetro), portão automatizado (relé) e integração na Maquete Coletiva (*planejados no backlog*).
- **Primeiros Passos**: Guia visual e interativo aos 8 símbolos e componentes elétricos essenciais com visualização física 3D, simbologia esquemática e quiz de reconhecimento.
- **Bancada Livre (Sandbox)**: Laboratório livre com grade inteligente, bornes magnéticos (snap de 60 px), roteamento ortogonal de fios (Manhattan Routing), medição com o Cyber-Multímetro Digital 9000, Osciloscópio HUD, atalhos de teclado, seleção em lote e sistema de queima física de componentes.
- **Configurações e Acessibilidade**: Temas Claro / Escuro / Sistema, redutor de animações, escala de interface linear, alto contraste e persistência local 100% offline via `shared_preferences`.

---

## 🛠️ Tecnologias Utilizadas

- **Framework**: [Flutter](https://flutter.dev) (SDK ^3.12.2 / Flutter 3.44+)
- **Renderização Gráfica**: `CustomPainter` nativo com otimização por `RepaintBoundary`
- **Gerenciamento de Estado**: [Riverpod](https://riverpod.dev) (`flutter_riverpod: ^3.4.2`)
- **Persistência Local**: [shared_preferences](https://pub.dev/packages/shared_preferences)
- **Internacionalização**: Flutter Localizations (Suporte a Português e Inglês)
- **Áudio**: [audioplayers](https://pub.dev/packages/audioplayers)

---

## 🚀 Como Executar o Projeto

### Pré-requisitos
- Flutter SDK instalado e configurado (`flutter doctor`).
- Navegador Google Chrome, emulador Android/iOS ou ambiente de desktop (Linux/macOS/Windows).

### Instalação
```bash
git clone <url-do-repositorio>
cd flutter_electric_circuit_game
flutter pub get
```

### Execução em Desenvolvimento
```bash
# Execução padrão na plataforma conectada
flutter run

# No navegador (Web)
flutter run -d chrome

# No Linux Desktop
flutter run -d linux
```

### Testes e Análise de Qualidade
```bash
# Análise estática do código
flutter analyze

# Execução de toda a suíte de testes automatizados
flutter test
```

---

## 📚 Documentação Completa

A documentação detalhada do projeto está organizada no diretório [`docs/`](docs/README.md):

* [Visão Geral e Escopo](docs/visao-geral.md)
* [Requisitos Funcionais e Não Funcionais](docs/requisitos.md)
* [Arquitetura Técnica e Módulos](docs/arquitetura.md)
* [UX, Telas e Fluxos](docs/ux-e-fluxos.md)
* [Conteúdo: Estandes, Missões e Rubricas](docs/conteudo.md)
* [Guia de Assets e Identidade Visual](docs/assets.md)
* [Backlog e Próximos Passos](docs/backlog.md)
* [Documentos Técnicos de Referência](docs/referencias/README.md)

---

## 📄 Licença

Material educacional e de pesquisa do projeto EletroLab.