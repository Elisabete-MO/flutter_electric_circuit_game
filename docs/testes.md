# Testes

## Verificação obrigatória

A cada etapa de implementação:

```bash
flutter analyze
flutter test
```

Build de referência (compilação): `flutter build web`.

Não ignorar erros de análise ou testes quebrados.

## Testes existentes (Fase 1)

`test/widget_test.dart`:

- Identidade do EletroLab exibida na home.
- As quatro opções principais presentes.
- Navegação até uma seção e retorno à home.
- Tela de configurações abre com as seções esperadas.
- Alterar o tema para escuro persiste (`settings` recuperadas de volta).

### Notas de infraestrutura de teste

- `SharedPreferences.setMockInitialValues({})` para isolar a persistência.
- Repositório sobrescrito no `ProviderScope` com `SettingsService()` real
  sobre o mock — mantém fidelidade com a inicialização de `main()`.
- `setSurfaceSize` amplia o viewport (conteúdo abaixo da dobra em 800×600).
- `ensureVisible` para tocar em cartões fora da tela.

## Testes planejados para o solver (Fases 5–6)

Casos que **evitam regressões** no solver de circuitos:

| # | Cenário | Valores | Esperado |
|---|---|---|---|
| 1 | Lei de Ohm | `V = 10 V`, `R = 100 Ω` | `I = 0,1 A` |
| 2 | Lei de Ohm | `V = 10 V`, `R = 1 kΩ` | `I = 0,01 A` |
| 3 | Interruptor aberto | qualquer | `I = 0 A` |
| 4 | Resistores em série | `R1 = 100 Ω`, `R2 = 200 Ω`, `V = 10 V` | `Req = 300 Ω`, `I ≈ 0,0333 A` |

Testes adicionais recomendados:

- Curto-circuito detectado como erro (`isValid = false`).
- Circuito sem fonte → erro "ausência de fonte".
- Componente com terminal desconectado → erro "componente desconectado".
- Lâmpada acesa/apagada por potência (`P = V × I`).
- Multímetro reportando tensão/corrente corretas.
- Circuito paralelo (`Req` em paralelo).
- Condições de vitória dos desafios.

## Organização sugerida

```text
test/
├── widget_test.dart            → Fase 1 (UI/navegação/configurações)
└── simulation/
    ├── solver_test.dart        → casos 1–4 e variações (Fases 5–6)
    └── circuit_test.dart       → grafo, nós, conexões (Fase 5)
```

## Guia rápido

```bash
# Análise estática
flutter analyze

# Todos os testes
flutter test

# Um arquivo específico
flutter test test/simulation/solver_test.dart

# Compilação de referência (web)
flutter build web
```