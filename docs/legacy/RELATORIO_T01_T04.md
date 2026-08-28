# Relatório de Implementação T01 a T04

## Escopo executado

Foram implementadas somente as tarefas T01 a T04 do MVP, conforme `mvp.md` e `IMPLEMENTATION.md`.

## Implementação realizada

### T01 - Mapa de assets

`lib/mvp/mvp_contract.dart` centraliza os caminhos dos nove arquivos necessários ao MVP:

- bateria física;
- interruptor físico aberto e fechado;
- lâmpada física apagada e acesa;
- símbolos técnicos de bateria, interruptor e lâmpada;
- ponto luminoso de energização.

Os assets permanecem em `docs/EletroLab_AssetPack_v1/assets/` e foram declarados individualmente em `pubspec.yaml`.

### T02 - Tipos e constantes

`lib/mvp/mvp_contract.dart` define:

- `SymbolType` e `SlotId` com somente bateria, interruptor SPST e lâmpada;
- `ValidationStatus`;
- mapa único `expectedSymbolBySlot`;
- `voltageVolts = 6.0`;
- `lampResistanceOhms = 12.0`;
- `currentAmpsForSwitch`, que retorna `0 A` para interruptor aberto e `0,5 A` para fechado.

### T03 - Estado central

`lib/mvp/activity_controller.dart` usa `ChangeNotifier`, sem Riverpod, para manter:

- estado aberto ou fechado do interruptor;
- ocupação dos três slots;
- resultado da validação;
- conjunto de slots destacados logicamente.

O controller limpa a validação ao alterar a ocupação de um slot e avalia diagramas incompletos, incorretos ou corretos por tipo esperado.

### T04 - Tela base Flutter + Flame

`lib/main.dart` substitui o contador padrão por uma tela com:

- `GameWidget` associado a `EletroLabGame`;
- áreas identificadas para circuito físico, diagrama e biblioteca de símbolos;
- painel de tensão, resistência e corrente;
- botão **Verificar diagrama**;
- área de feedback observando o mesmo `ActivityController` recebido pela cena Flame.

`lib/mvp/eletrolab_game.dart` contém apenas a casca de `FlameGame` com referência ao controller compartilhado.

## Arquivos criados

- `lib/mvp/mvp_contract.dart`
- `lib/mvp/activity_controller.dart`
- `lib/mvp/eletrolab_game.dart`

## Arquivos modificados

- `pubspec.yaml`
- `pubspec.lock`
- `lib/main.dart`
- `test/widget_test.dart`

## Verificação

- `flutter pub get`: concluído.
- `flutter analyze`: sem problemas.
- `flutter test`: todos os testes passaram.

O comando de dependências informou seis pacotes com versões mais novas incompatíveis com as restrições atuais. O aviso não impede análise ou testes.

## Fora do escopo nesta etapa

Não foram implementados circuito físico, renderização de componentes, slots visuais, drag-and-drop, partículas, controle visual do interruptor ou destaques visuais de validação. Esses itens pertencem às tarefas T05 em diante.
