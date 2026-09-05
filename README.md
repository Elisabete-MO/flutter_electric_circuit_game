# EletroLab

EletroLab e um jogo educacional de eletrica e eletronica para estudantes de aproximadamente 9 a 15 anos. A campanha usa uma Feira de Ciencias como contexto: o estudante explora componentes, interpreta diagramas, testa circuitos e prepara demonstracoes para estandes e maquetes.

## Estado atual

O runtime ativo usa Flutter, Riverpod e `CustomPainter`. Ha tres desafios guiados legados e uma Bancada Livre reutilizavel com componentes, fios, simulacao e visualizacoes fisica/esquematica. Flame permanece declarado como dependencia/legado, mas nao e a base ativa do fluxo principal.

O proximo foco de produto e o Primeiro Estande: **Conhecer -> Inspecionar -> Representar -> Construir**. Nas fases de representacao, o circuito fisico permanece como referencia faded/ghost sob o diagrama tecnico.

## Tecnologias

- [Flutter](https://flutter.dev) (Material 3, mobile, desktop e web)
- [Riverpod](https://riverpod.dev) para estado reativo
- `CustomPainter` para circuitos, simbolos, fios e efeitos visuais
- [shared_preferences](https://pub.dev/packages/shared_preferences) para persistencia local
- Flame como dependencia/legado nao utilizado pelo runtime principal atual

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

## Documentacao

- [Produto e escopo](docs/PRODUCT.md)
- [Pedagogia e interacao](docs/PEDAGOGY.md)
- [Campanha Feira de Ciencias](docs/CAMPAIGN.md)
- [Primeiro Estande](docs/FIRST_STAND.md)
- [Arquitetura e estado tecnico](docs/ARCHITECTURE.md)
- [Referencias e estado da arte](docs/REFERENCES.md)
- [Roadmap](docs/ROADMAP.md)

## Como executar testes

```bash
flutter analyze
flutter test
```

Consulte `docs/ARCHITECTURE.md` para o estado da suite de testes observado na auditoria tecnica.

## Licença

Material educacional próprio do EletroLab. Nenhum asset, texto ou código do PhET foi utilizado.
