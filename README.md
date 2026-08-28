# EletroLab

**EletroLab — seu laboratório virtual de circuitos elétricos.**

Aplicação educacional de simulação de circuitos elétricos desenvolvida com
**Flutter + Flame**. O EletroLab permite montar circuitos, arrastar
componentes, conectar fios, controlar interruptores, observar a corrente
elétrica, medir grandezas e resolver desafios — com feedback visual e
explicações educacionais.

> O EletroLab é uma implementação e identidade visual próprias, inspirada
> apenas no *conceito* de simuladores educacionais interativos de circuitos.

## Objetivo

Oferecer um laboratório virtual acessível e divertido onde estudantes possam
aprender conceitos de eletricidade (Lei de Ohm, tensão, corrente, potência,
circuitos em série e paralelo) de forma visual e interativa.

## Funcionalidades

- **Primeiros passos** — guia visual e interativo aos 8 símbolos e componentes elétricos essenciais (Bateria, Fio, Interruptor, Lâmpada, Resistor, Diodo, LED e Motor) com renderizadores vetoriais em tempo real, simulação de estados, banner orientativo e modo Desafio/Quiz sem rótulos.
- **Começar** — 3 cards de desafios práticos e progressivos (Desafio 1: Acenda a Lâmpada, Desafio 2: Controle com Interruptor, Desafio 3: Proteção com Resistor).
- **Banqueta** — laboratório livre para experimentar circuitos.
- **Configurações** — aparência, simulação, acessibilidade e dados.

## Tecnologias

- [Flutter](https://flutter.dev) (Material 3, suporte a mobile, desktop e web)
- [Flame](https://flame-engine.org) — motor do simulador visual
- [Riverpod](https://riverpod.dev) — gerenciamento de estado
- [shared_preferences](https://pub.dev/packages/shared_preferences) —
  persistência local

## Requisitos

- Flutter SDK 3.44 ou superior (Dart 3.12)
- Um dispositivo, emulador ou navegador compatível

## Instalação

```bash
git clone <url-do-repositorio>
cd eletrolab
flutter pub get
```

## Execução

```bash
# Desenvolvimento
flutter run

# Plataforma específica
flutter run -d chrome
flutter run -d linux
flutter run -d android

# Build
flutter build web
```

## Arquitetura

O EletroLab mantém as camadas estritamente separadas:

```text
Flutter UI
     ↓
Flame (visual)
     ↓
Circuit Model (grafo do circuito)
     ↓
Circuit Solver (matemática)
     ↓
Simulation Result
```

> Veja também a [documentação detalhada](docs/README.md) do projeto.

Estrutura principal:

```text
lib/
├── main.dart
├── app/            → MaterialApp, rotas e tema (identidade EletroLab)
├── screens/        → home, first_steps, challenges, sandbox, settings
├── game/           → câmera, componentes, fios, partículas, interações (Flame)
├── simulation/     → circuit, nodes, terminais, conexões e solver
├── models/         → models de componentes, desafios e configurações
├── state/          → controladores Riverpod
├── services/       → persistência (configurações, progresso) e repositórios
└── widgets/        → widgets reutilizáveis
```

### Estado

O estado da simulação não depende do estado visual do Flame: o motor
matemático (solver) é independente e testável isoladamente.

### Persistência

Configurações e progresso são persistidos localmente via
`shared_preferences`, sem backend.

## Como adicionar componentes

1. Crie a classe do componente em `lib/simulation/` (modelo matemático) e o
   respectivo componente visual em `lib/game/components/`.
2. Defina seus terminais e propriedades.
3. Registre o componente no catálogo/banqueta, associando-o a um ícone e nome.
4. Adicione testes do solver se o componente alterar o comportamento do
   circuito.

## Como criar desafios

1. Crie uma entrada no sistema de desafios (id, título, descrição,
   dificuldade, componentes disponíveis, objetivo, condição de vitória,
   feedback e progresso).
2. Implemente a condição de vitória com base no `SimulationResult`.
3. Registre no catálogo de desafios — o sistema é modular para facilitar a
   adição de novos desafios.

## Como executar testes

```bash
flutter analyze
flutter test
```

Testes existentes:

- Identidade da tela inicial e as quatro opções principais.
- Navegação entre seções.
- Tela de configurações e persistência do tema.
- Testes do solver de circuitos (adição nas próximas fases).

## Roadmap

O projeto é desenvolvido incrementalmente:

1. **Fundação** — projeto, tema, navegação, menu inicial (*concluído*).
2. **Primeiros passos** — guia de símbolos esquemáticos e componentes físicos (*concluído*).
3. **Flame** — canvas, câmera, grade, pan/zoom e interações.
4. **Componentes** — bateria, resistor, lâmpada, interruptor e fio.
5. **Circuito** — terminais, nós, conexões, grafo e solver.
6. **Simulação** — corrente, tensão, potência e animação.
7. **Banqueta** — laboratório livre.
8. **Começar** — 3 desafios interativos com bancada e diagramas esquemáticos (*concluído*).
9. **Configurações** — preferências, acessibilidade e persistência completa.
10. **Refinamento** — UX, animações, feedback, responsividade e desempenho.

## Licença

Material educacional próprio do EletroLab. Nenhum asset, texto ou código do PhET foi utilizado.