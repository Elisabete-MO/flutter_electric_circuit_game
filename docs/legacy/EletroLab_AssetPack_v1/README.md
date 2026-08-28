# EletroLab Asset Pack v1

Pacote-base para os primeiros circuitos do EletroLab.

## Direção visual

- Componentes físicos em 2.5D moderadamente cartunizado.
- Fundo transparente e iluminação clara.
- Bases branco/cinza-azuladas, detalhes em ardósia e ciano.
- Símbolos técnicos separados dos componentes físicos.
- Energização representada por pontos luminosos, sem setas de corrente.

## Pastas

- `assets/components/`: componentes físicos em WebP transparente.
- `assets/symbols/`: símbolos técnicos em SVG e WebP.
- `assets/effects/`: ponto luminoso de energização.
- `assets/ui/`: grade e terminais reutilizáveis.
- `asset_manifest.json`: IDs, estados e usos dos arquivos.

## Primeiros circuitos cobertos

1. Bateria + interruptor + lâmpada.
2. Bateria + resistor + LED.
3. Bateria + resistor + diodo.
4. Bateria + interruptor + motor DC.
5. Circuitos resistivos em série, paralelo e mistos.
6. Medição com voltímetro e amperímetro.

## Regras de implementação

- Use a imagem física somente na bancada.
- Use o símbolo correspondente somente no editor de diagramas.
- Desenhe fios proceduralmente no Flame; `wire.svg/webp` serve como referência e miniatura.
- Renderize junções explicitamente. Cruzamentos sem ponto não são conexões.
- Troque `switch_open` por `switch_closed` conforme o estado elétrico.
- Troque `lamp_off/on` e `led_off/on` conforme o resultado do solver.
- A leitura dos instrumentos deve ser uma camada de texto dinâmica. Os sprites são a base visual.
- A rotação do motor deve ser animada pelo Flame; o sprite permanece estático.
- Não use o brilho dos sprites como fonte do estado elétrico.

## Tamanho e formato

- Componentes: até 640 px no maior lado, WebP com transparência.
- Símbolos: 256 × 128 px em WebP, com SVG original preservado.
- Efeitos: 64 × 64 px.
- Terminais: 96 × 96 px.

Os SVGs são a fonte preferencial para símbolos técnicos. Os WebPs existem para miniaturas, protótipos e fluxos que precisem de raster.
