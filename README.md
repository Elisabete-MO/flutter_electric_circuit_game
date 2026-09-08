# EletroLab

Jogo educacional de eletrônica que ensina conceitos de circuitos elétricos por meio de uma feira de ciências virtual. Desenvolvido em Flutter, combina uma experiência guiada por fases com uma Bancada Livre para exploração aberta. Dados persistidos localmente via SharedPreferences.

## Stack atual

- **Flutter** 3.44+ / Dart 3.12+
- **Riverpod** — estado e dependências
- **CustomPainter** — renderização de circuitos, fios e instrumentos
- **SharedPreferences** — persistência local
- **Google Fonts** — tipografia (Rajdhani, Outfit)
- **flutter_localizations** / **intl** — português e inglês

## Executar

```bash
flutter pub get
flutter run
```

## Qualidade

```bash
flutter analyze   # No issues found
flutter test      # 47 testes, todos passando
```

## Documentação

| Documento | Responsabilidade |
| --- | --- |
| `docs/ARCHITECTURE.md` | Estado técnico atual do sistema implementado |
| `docs/ROADMAP.md` | Trabalho futuro e frentes de desenvolvimento |
| `docs/CODEBASE_AUDIT.md` | Registro histórico/factual da auditoria e limpeza do repositório |

> `CODEBASE_AUDIT.md` é registro histórico e não especificação do produto futuro.
