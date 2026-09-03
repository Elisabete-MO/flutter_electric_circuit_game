import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/first_step_component.dart';
import '../../widgets/circuit_symbol_painter.dart';

/// Identificadores dos 4 encaixes do circuito em série da Fase 3.
enum SlotId {
  battery, // Lado esquerdo (Vertical)
  resistor, // Parte superior (Horizontal)
  led, // Lado direito (Vertical)
  switchComp, // Parte inferior (Horizontal)
}

/// Representação interna de um símbolo elétrico na biblioteca ou posicionado num encaixe.
class SymbolItemData {
  final String id;
  final ComponentType type;
  final bool isRotated; // Relevante para orientação do LED (false = anodo no topo, true = invertido)
  final bool isSwitchOpen; // Relevante para estado do interruptor (true = aberto)

  const SymbolItemData({
    required this.id,
    required this.type,
    this.isRotated = false,
    this.isSwitchOpen = true,
  });

  SymbolItemData copyWith({
    bool? isRotated,
    bool? isSwitchOpen,
  }) {
    return SymbolItemData(
      id: id,
      type: type,
      isRotated: isRotated ?? this.isRotated,
      isSwitchOpen: isSwitchOpen ?? this.isSwitchOpen,
    );
  }
}

/// Fase 3: Associação de componentes físicos a símbolos elétricos em um diagrama esquemático.
class FirstBenchPhase3 extends StatefulWidget {
  final VoidCallback onPhaseComplete;

  const FirstBenchPhase3({
    super.key,
    required this.onPhaseComplete,
  });

  @override
  State<FirstBenchPhase3> createState() => _FirstBenchPhase3State();
}

class _FirstBenchPhase3State extends State<FirstBenchPhase3> with SingleTickerProviderStateMixin {
  // Modo de visualização: Diagrama (padrão) ou Físico (apenas consulta)
  bool _isDiagramMode = true;

  // Os 4 encaixes do circuito fechado
  final Map<SlotId, SymbolItemData?> _slots = {
    SlotId.battery: null,
    SlotId.resistor: null,
    SlotId.led: null,
    SlotId.switchComp: null,
  };

  // Status individual de validação de cada slot (null = sem checagem, true = correto, false = incorreto)
  final Map<SlotId, bool?> _slotStatus = {
    SlotId.battery: null,
    SlotId.resistor: null,
    SlotId.led: null,
    SlotId.switchComp: null,
  };

  // Os 6 símbolos disponíveis na biblioteca (4 corretos + 2 distratores)
  late List<SymbolItemData> _availableLibrarySymbols;

  // Símbolo selecionado por toque (para acessibilidade/toque alternativo)
  SymbolItemData? _selectedLibrarySymbol;

  // Animação de vibração (shake) ao tentar verificar com erros
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _initLibrarySymbols();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _initLibrarySymbols() {
    final symbols = <SymbolItemData>[
      const SymbolItemData(id: 'battery_sym', type: ComponentType.battery),
      const SymbolItemData(id: 'resistor_sym', type: ComponentType.resistor),
      const SymbolItemData(id: 'led_sym', type: ComponentType.led, isRotated: false),
      const SymbolItemData(id: 'switch_sym', type: ComponentType.switchComponent, isSwitchOpen: true),
      const SymbolItemData(id: 'bulb_distractor', type: ComponentType.bulb), // Distrator 1
      const SymbolItemData(id: 'diode_distractor', type: ComponentType.diode), // Distrator 2
    ];
    symbols.shuffle();
    setState(() {
      _availableLibrarySymbols = symbols;
    });
  }

  void _resetPhase() {
    setState(() {
      for (final key in _slots.keys) {
        _slots[key] = null;
        _slotStatus[key] = null;
      }
      _selectedLibrarySymbol = null;
    });
    _initLibrarySymbols();
  }

  void _assignSymbolToSlot(SlotId slotKey, SymbolItemData symbol) {
    setState(() {
      // Se o mesmo símbolo já estava em outro slot, limpa o slot anterior
      _slots.forEach((key, val) {
        if (val?.id == symbol.id) {
          _slots[key] = null;
          _slotStatus[key] = null;
        }
      });

      _slots[slotKey] = symbol;
      _slotStatus[slotKey] = null;
      _selectedLibrarySymbol = null;
    });
  }

  void _removeSymbolFromSlot(SlotId slotKey) {
    setState(() {
      _slots[slotKey] = null;
      _slotStatus[slotKey] = null;
    });
  }

  void _toggleLedOrientation(SlotId slotKey) {
    final current = _slots[slotKey];
    if (current != null && current.type == ComponentType.led) {
      setState(() {
        _slots[slotKey] = current.copyWith(isRotated: !current.isRotated);
        _slotStatus[slotKey] = null;
      });
    }
  }

  void _checkSolution() {
    final batterySymbol = _slots[SlotId.battery];
    final resistorSymbol = _slots[SlotId.resistor];
    final ledSymbol = _slots[SlotId.led];
    final switchSymbol = _slots[SlotId.switchComp];

    final isBatteryCorrect = batterySymbol?.type == ComponentType.battery;
    final isResistorCorrect = resistorSymbol?.type == ComponentType.resistor;

    // LED: precisa ser LED e estar na orientação correta (ânodo positivo no topo / resistor)
    final isLedType = ledSymbol?.type == ComponentType.led;
    final isLedOrientationCorrect = isLedType && ledSymbol!.isRotated == false;
    final isLedCorrect = isLedType && isLedOrientationCorrect;

    // Interruptor: precisa ser interruptor e estar no estado aberto (matching físico)
    final isSwitchType = switchSymbol?.type == ComponentType.switchComponent;
    final isSwitchStateCorrect = isSwitchType && switchSymbol!.isSwitchOpen == true;
    final isSwitchCorrect = isSwitchType && isSwitchStateCorrect;

    final isAllCorrect = isBatteryCorrect && isResistorCorrect && isLedCorrect && isSwitchCorrect;

    setState(() {
      _slotStatus[SlotId.battery] = isBatteryCorrect;
      _slotStatus[SlotId.resistor] = isResistorCorrect;
      _slotStatus[SlotId.led] = isLedCorrect;
      _slotStatus[SlotId.switchComp] = isSwitchCorrect;
    });

    if (isAllCorrect) {
      _showFeedbackDialog(
        isSuccess: true,
        title: 'DIAGRAMA CORRETO!',
        message: 'Muito bem! Você representou o circuito da bancada. Agora monte esse circuito sozinho.',
        onAction: () {
          Navigator.of(context).pop();
          widget.onPhaseComplete();
        },
      );
    } else {
      _shakeController.forward(from: 0.0);

      String errorMessage = 'Revise os símbolos posicionados no circuito.';

      if (ledSymbol?.type == ComponentType.bulb) {
        errorMessage = 'Observe: o LED possui duas setas indicando a emissão de luz.';
      } else if (ledSymbol?.type == ComponentType.diode) {
        errorMessage = 'O LED é um tipo de diodo, mas seu símbolo possui setas de emissão.';
      } else if (isLedType && !isLedOrientationCorrect) {
        errorMessage = 'Confira a orientação do ânodo e do cátodo no LED.';
      } else if (switchSymbol != null && !isSwitchType) {
        errorMessage = 'O símbolo do interruptor deve controlar a abertura da corrente.';
      } else if (isSwitchType && !isSwitchStateCorrect) {
        errorMessage = 'O símbolo precisa representar o mesmo estado do circuito físico (aberto).';
      } else if (!isBatteryCorrect) {
        errorMessage = 'Verifique a representação da bateria com os polos positivo (+) e negativo (-).';
      } else if (!isResistorCorrect) {
        errorMessage = 'Verifique a representação do resistor no topo do circuito.';
      }

      _showFeedbackDialog(
        isSuccess: false,
        title: 'VERIFICAÇÃO DO DIAGRAMA',
        message: errorMessage,
        onAction: () {
          Navigator.of(context).pop();
        },
      );
    }
  }

  void _showFeedbackDialog({
    required bool isSuccess,
    required String title,
    required String message,
    required VoidCallback onAction,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final accentColor = isSuccess ? const Color(0xFF00FF9D) : const Color(0xFFFF5252);

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF071C14),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accentColor, width: 1.5),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 16, offset: Offset(0, 6)),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSuccess ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                    size: 54,
                    color: accentColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: GoogleFonts.rajdhani().fontFamily,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    message,
                    style: TextStyle(
                      fontFamily: GoogleFonts.outfit().fontFamily,
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.45,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: onAction,
                      icon: Icon(isSuccess ? Icons.arrow_forward_rounded : Icons.replay_rounded),
                      label: Text(
                        isSuccess ? 'AVANÇAR PARA A FASE 4' : 'TENTAR NOVAMENTE',
                        style: TextStyle(
                          fontFamily: GoogleFonts.rajdhani().fontFamily,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          fontSize: 15,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF071C14),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF00FF9D), width: 1.5),
            ),
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.help_outline_rounded, color: Color(0xFF00FF9D)),
                    const SizedBox(width: 10),
                    Text(
                      'Ajuda — Fase 3',
                      style: TextStyle(
                        fontFamily: GoogleFonts.rajdhani().fontFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  '• Alternador de Modo:\nUtilize o seletor (Físico | Diagrama) no topo para consultar a montagem real da bancada.\n\n'
                  '• Associação de Símbolos:\nNo modo Diagrama, arraste cada símbolo da biblioteca à direita para o seu encaixe no circuito.\n\n'
                  '• Toque Alternativo:\nVocê também pode tocar num símbolo da biblioteca para selecioná-lo e depois tocar no encaixe desejado.\n\n'
                  '• Polaridade & Orientação:\nFique atento às setas do símbolo do LED e ao estado do interruptor (aberto/fechado).',
                  style: TextStyle(
                    fontFamily: GoogleFonts.outfit().fontFamily,
                    fontSize: 13.5,
                    color: Colors.white70,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF00FF9D),
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('ENTENDI'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filledCount = _slots.values.where((val) => val != null).length;
    final isAllFilled = filledCount == 4;

    return LayoutBuilder(
      builder: (context, constraints) {
        final containerW = constraints.maxWidth;
        final containerH = constraints.maxHeight;

        // Cálculo de escala proporcional BoxFit.cover do background (1672 x 941) sem margens pretas
        const bgWidth = 1672.0;
        const bgHeight = 941.0;
        final scale = math.max(containerW / bgWidth, containerH / bgHeight);
        final renderedBgW = bgWidth * scale;
        final renderedBgH = bgHeight * scale;
        final offsetX = (containerW - renderedBgW) / 2;
        final offsetY = (containerH - renderedBgH) / 2;

        double toX(double rx) => offsetX + rx * renderedBgW;
        double toY(double ry) => offsetY + ry * renderedBgH;
        double toW(double rw) => rw * renderedBgW;
        double toH(double rh) => rh * renderedBgH;

        // Coordenadas centrais do circuito na prancheta
        final batteryX = toX(0.185);
        final resistorY = toY(0.285);
        final ledX = toX(0.585);
        final switchY = toY(0.755);

        // Dimensões compactas dos 4 encaixes
        final vertSlotW = toW(0.068);
        final vertSlotH = toH(0.190);
        final horizSlotW = toW(0.108);
        final horizSlotH = toH(0.092);

        // Rects dos 4 encaixes para conexão exata dos fios aos terminais
        final batteryRect = Rect.fromCenter(
          center: Offset(batteryX, toY(0.520)),
          width: vertSlotW,
          height: vertSlotH,
        );
        final resistorRect = Rect.fromCenter(
          center: Offset(toX(0.385), resistorY),
          width: horizSlotW,
          height: horizSlotH,
        );
        final ledRect = Rect.fromCenter(
          center: Offset(ledX, toY(0.520)),
          width: vertSlotW,
          height: vertSlotH,
        );
        final switchRect = Rect.fromCenter(
          center: Offset(toX(0.385), switchY),
          width: horizSlotW,
          height: horizSlotH,
        );

        return AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            final shakeOffset = math.sin(_shakeController.value * math.pi * 6) * 6.0;
            return Transform.translate(
              offset: Offset(shakeOffset, 0),
              child: child,
            );
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. Fundo Oficial da Prancheta Técnica (sem faixas pretas laterais)
              Positioned.fill(
                child: Image.asset(
                  'assets/backgrounds/background_fase_03_prancheta_tecnica.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/backgrounds/background_fase_03_prancheta_tecnica.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // 2. Fios do circuito (CustomPainter) diretamente conectados aos terminais dos 4 encaixes
              Positioned.fill(
                child: CustomPaint(
                  painter: _Phase3TerminalConnectedWirePainter(
                    batteryRect: batteryRect,
                    resistorRect: resistorRect,
                    ledRect: ledRect,
                    switchRect: switchRect,
                    cornerRadius: toW(0.022),
                  ),
                ),
              ),

              // 3. Título e Subtítulo (Top Left da Prancheta) em branco/creme (sem neon)
              Positioned(
                left: toX(0.06),
                top: toY(0.045),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fase 3 — Do componente ao símbolo',
                      style: TextStyle(
                        fontFamily: GoogleFonts.rajdhani().fontFamily,
                        fontSize: math.max(16, toW(0.016)),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFEDE7D7),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Transforme o circuito físico em seu diagrama elétrico.',
                      style: TextStyle(
                        fontFamily: GoogleFonts.outfit().fontFamily,
                        fontSize: math.max(11, toW(0.010)),
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              // 4. Seletor de Modo (Físico | Diagrama) centralizado acima da prancheta
              Positioned(
                left: toX(0.40),
                top: toY(0.040),
                child: _buildModeSelector(),
              ),

              // 5. Circuito Central: Encaixes ou Componentes Físicos
              if (_isDiagramMode) ...[
                // Modo Diagrama: Exibe os 4 Encaixes com Pistas Transparentes & Símbolos
                _buildSlotWidget(
                  slotKey: SlotId.battery,
                  rect: batteryRect,
                  clueAsset: 'assets/components/battery.png',
                  isVertical: true,
                ),
                _buildSlotWidget(
                  slotKey: SlotId.resistor,
                  rect: resistorRect,
                  clueAsset: 'assets/components/resistor.png',
                  isVertical: false,
                ),
                _buildSlotWidget(
                  slotKey: SlotId.led,
                  rect: ledRect,
                  clueAsset: 'assets/components/led_off.png',
                  isVertical: true,
                  allowRotation: true,
                ),
                _buildSlotWidget(
                  slotKey: SlotId.switchComp,
                  rect: switchRect,
                  clueAsset: 'assets/components/switch_open.png',
                  isVertical: false,
                ),

                // Indicações de Polaridade discretas na Bateria e LED
                Positioned(
                  left: batteryRect.right + 6,
                  top: batteryRect.top + 2,
                  child: const Text(
                    '+',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFEDE7D7)),
                  ),
                ),
                Positioned(
                  left: batteryRect.right + 6,
                  bottom: (containerH - batteryRect.bottom) + 2,
                  child: const Text(
                    '−',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFEDE7D7)),
                  ),
                ),
                Positioned(
                  right: (containerW - ledRect.left) + 6,
                  top: ledRect.top + 2,
                  child: const Text(
                    '+',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFEDE7D7)),
                  ),
                ),
                Positioned(
                  right: (containerW - ledRect.left) + 6,
                  bottom: (containerH - ledRect.bottom) + 2,
                  child: const Text(
                    '−',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFEDE7D7)),
                  ),
                ),
              ] else ...[
                // Modo Físico de Consulta (Componentes reais totalmente opacos)
                _buildPhysicalComponentView(
                  asset: 'assets/components/battery.png',
                  rect: batteryRect,
                  isVertical: false, // asset battery.png já é vertical
                ),
                _buildPhysicalComponentView(
                  asset: 'assets/components/resistor.png',
                  rect: resistorRect,
                  isVertical: false,
                ),
                _buildPhysicalComponentView(
                  asset: 'assets/components/led_off.png',
                  rect: ledRect,
                  isVertical: false, // asset led_off.png já é vertical
                ),
                _buildPhysicalComponentView(
                  asset: 'assets/components/switch_open.png',
                  rect: switchRect,
                  isVertical: false,
                ),
                Positioned(
                  left: toX(0.22),
                  top: toY(0.50),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF00FF9D)),
                    ),
                    child: const Text(
                      'Modo Físico de Consulta (Sem edição)',
                      style: TextStyle(fontSize: 11, color: Color(0xFF00FF9D), fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],

              // 6. Biblioteca Lateral em Tom Creme na Área Livre à Direita da Bancada
              Positioned(
                left: toX(0.75),
                top: toY(0.12),
                width: toW(0.22),
                height: toH(0.74),
                child: _buildLateralLibraryPanel(),
              ),

              // 7. Rodapé Integrado de Ações (Progresso, Reiniciar, Verificar, Ajuda)
              Positioned(
                left: toX(0.04),
                bottom: toY(0.03),
                width: toW(0.93),
                child: _buildBottomControls(isAllFilled, filledCount),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- SELETOR DE MODO (Físico | Diagrama) ---
  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFF061811).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00FF9D).withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModeButton(
            title: 'Físico',
            isSelected: !_isDiagramMode,
            onTap: () => setState(() => _isDiagramMode = false),
          ),
          _buildModeButton(
            title: 'Diagrama',
            isSelected: _isDiagramMode,
            onTap: () => setState(() => _isDiagramMode = true),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0A2E20) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: const Color(0xFF00FF9D), width: 1.2) : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: GoogleFonts.rajdhani().fontFamily,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: isSelected ? Colors.white : Colors.white60,
          ),
        ),
      ),
    );
  }

  // --- COMPONENTE FÍSICO (Modo Físico de Consulta) ---
  Widget _buildPhysicalComponentView({
    required String asset,
    required Rect rect,
    required bool isVertical,
  }) {
    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: Center(
        child: Transform.rotate(
          angle: isVertical ? math.pi / 2 : 0,
          child: Image.asset(
            asset,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  // --- ENCAIXE (SLOT) COMPACTO DO CIRCUITO NO MODO DIAGRAMA ---
  Widget _buildSlotWidget({
    required SlotId slotKey,
    required Rect rect,
    required String clueAsset,
    required bool isVertical,
    bool allowRotation = false,
  }) {
    final symbolPlaced = _slots[slotKey];
    final validation = _slotStatus[slotKey];

    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: DragTarget<SymbolItemData>(
        onAcceptWithDetails: (details) {
          _assignSymbolToSlot(slotKey, details.data);
        },
        builder: (context, candidateData, rejectedData) {
          final isHovering = candidateData.isNotEmpty;

          Color borderColor;
          if (validation == true) {
            borderColor = const Color(0xFF00FF9D);
          } else if (validation == false) {
            borderColor = const Color(0xFFFF5252);
          } else if (isHovering) {
            borderColor = const Color(0xFF00FF9D);
          } else if (symbolPlaced != null) {
            borderColor = const Color(0xFF38BDF8);
          } else {
            borderColor = const Color(0xFFD6CFC0).withValues(alpha: 0.5);
          }

          return InkWell(
            onTap: () {
              if (_selectedLibrarySymbol != null) {
                _assignSymbolToSlot(slotKey, _selectedLibrarySymbol!);
              } else if (symbolPlaced != null) {
                if (allowRotation && symbolPlaced.type == ComponentType.led) {
                  _toggleLedOrientation(slotKey);
                } else {
                  _removeSymbolFromSlot(slotKey);
                }
              }
            },
            borderRadius: BorderRadius.circular(10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isHovering
                    ? const Color(0xFF00FF9D).withValues(alpha: 0.15)
                    : const Color(0xFF071B12).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: borderColor,
                  width: (isHovering || validation != null) ? 2.5 : 1.2,
                ),
                boxShadow: isHovering
                    ? [
                        BoxShadow(
                          color: const Color(0xFF00FF9D).withValues(alpha: 0.4),
                          blurRadius: 10,
                          spreadRadius: 2,
                        )
                      ]
                    : const [
                        BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
                      ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 1. Pista Física Transparente (28%-35% opacidade quando slot vazio)
                  Opacity(
                    opacity: symbolPlaced != null ? 0.05 : 0.30,
                    child: Image.asset(
                      clueAsset,
                      fit: BoxFit.contain,
                    ),
                  ),

                  // 2. Símbolo Elétrico Posicionado
                  if (symbolPlaced != null)
                    Transform.rotate(
                      angle: symbolPlaced.isRotated ? math.pi : 0,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: CustomPaint(
                          painter: CircuitSymbolPainter(
                            type: symbolPlaced.type,
                            isActive: symbolPlaced.isSwitchOpen,
                            color: validation == false
                                ? const Color(0xFFFF5252)
                                : const Color(0xFF00FF9D),
                            activeColor: const Color(0xFF00FF9D),
                            strokeWidth: 2.4,
                            isVertical: isVertical,
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),

                  // 3. Indicador visual de confirmação ou erro
                  if (validation == true)
                    const Positioned(
                      top: 3,
                      right: 3,
                      child: Icon(Icons.check_circle_rounded, color: Color(0xFF00FF9D), size: 14),
                    )
                  else if (validation == false)
                    const Positioned(
                      top: 3,
                      right: 3,
                      child: Icon(Icons.cancel_rounded, color: Color(0xFFFF5252), size: 14),
                    ),

                  // 4. Botão discreto para inverter rotação do LED (se aplicável)
                  if (allowRotation && symbolPlaced != null && symbolPlaced.type == ComponentType.led)
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: InkWell(
                        onTap: () => _toggleLedOrientation(slotKey),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF00FF9D)),
                          ),
                          child: const Icon(Icons.screen_rotation_rounded, size: 10, color: Color(0xFF00FF9D)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- PAINEL DA BIBLIOTECA LATERAL EM TOM CREME ---
  Widget _buildLateralLibraryPanel() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6EE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2C3E33), width: 1.2),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(
            'Símbolos disponíveis',
            style: TextStyle(
              fontFamily: GoogleFonts.rajdhani().fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1B2E24),
            ),
          ),
          const SizedBox(height: 10),

          // Grid de 6 Símbolos Embaralhados (2 colunas x 3 linhas)
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.0,
              ),
              itemCount: _availableLibrarySymbols.length,
              itemBuilder: (context, index) {
                final symbol = _availableLibrarySymbols[index];
                final isAssigned = _slots.values.any((val) => val?.id == symbol.id);
                final isSelected = _selectedLibrarySymbol?.id == symbol.id;

                return _buildLibrarySymbolCard(symbol, isAssigned, isSelected);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLibrarySymbolCard(SymbolItemData symbol, bool isAssigned, bool isSelected) {
    final cardWidget = Container(
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE5DEC9) : const Color(0xFFEFEAD8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF00FF9D) : const Color(0xFFD6CFC0),
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Center(
        child: CustomPaint(
          painter: CircuitSymbolPainter(
            type: symbol.type,
            isActive: symbol.isSwitchOpen,
            color: isAssigned ? const Color(0xFF9E988A) : const Color(0xFF0F1D15),
            strokeWidth: 2.2,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );

    if (isAssigned) {
      return Opacity(
        opacity: 0.25,
        child: cardWidget,
      );
    }

    return Draggable<SymbolItemData>(
      data: symbol,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFFAF6EE),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF00FF9D), width: 2.0),
            boxShadow: const [
              BoxShadow(color: Colors.black38, blurRadius: 12, offset: Offset(0, 4)),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: CustomPaint(
            painter: CircuitSymbolPainter(
              type: symbol.type,
              isActive: symbol.isSwitchOpen,
              color: const Color(0xFF0F1D15),
              strokeWidth: 2.5,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: cardWidget,
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedLibrarySymbol = isSelected ? null : symbol;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: cardWidget,
      ),
    );
  }

  // --- RODAPÉ INTEGRADO DE AÇÕES (Progresso, Reiniciar, Verificar, Ajuda) ---
  Widget _buildBottomControls(bool isAllFilled, int filledCount) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF082218).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1B382B), width: 1.2),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Ponto verde indicador e contador de progresso
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Color(0xFF00FF9D),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$filledCount de 4 símbolos posicionados',
            style: TextStyle(
              fontFamily: GoogleFonts.outfit().fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const Spacer(),

          // Botão Reiniciar
          OutlinedButton.icon(
            onPressed: _resetPhase,
            icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
            label: Text(
              'Reiniciar',
              style: TextStyle(
                fontFamily: GoogleFonts.outfit().fontFamily,
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: Colors.white,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF1B382B)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Botão Verificar diagrama
          FilledButton.icon(
            onPressed: isAllFilled ? _checkSolution : null,
            icon: Icon(
              isAllFilled ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
              size: 16,
            ),
            label: Text(
              'Verificar diagrama',
              style: TextStyle(
                fontFamily: GoogleFonts.outfit().fontFamily,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF00FF9D),
              foregroundColor: Colors.black,
              disabledBackgroundColor: const Color(0xFF132D21),
              disabledForegroundColor: const Color(0xFF4A6356),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Botão de Ajuda no Canto Direito do Rodapé
          IconButton(
            onPressed: _showHelpDialog,
            icon: const Icon(Icons.help_outline_rounded, color: Colors.white, size: 20),
            tooltip: 'Ajuda',
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF0F2D20),
              side: const BorderSide(color: Color(0xFF1B382B)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Painter que desenha os fios contínuos do circuito fechado em curva suave,
/// conectando-se exatamente aos terminais de entrada e saída dos 4 encaixes.
class _Phase3TerminalConnectedWirePainter extends CustomPainter {
  final Rect batteryRect;
  final Rect resistorRect;
  final Rect ledRect;
  final Rect switchRect;
  final double cornerRadius;

  _Phase3TerminalConnectedWirePainter({
    required this.batteryRect,
    required this.resistorRect,
    required this.ledRect,
    required this.switchRect,
    required this.cornerRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final wirePaint = Paint()
      ..color = const Color(0xFFEDE7D7) // Creme suave técnico
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final wireGlowPaint = Paint()
      ..color = const Color(0xFF00FF9D).withValues(alpha: 0.10)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final batteryX = batteryRect.center.dx;
    final resistorY = resistorRect.center.dy;
    final ledX = ledRect.center.dx;
    final switchY = switchRect.center.dy;

    final R = cornerRadius;

    final path = Path();

    // Seg. 1: Topo do Encaixe Bateria -> Canto Sup. Esq. -> Esquerda do Encaixe Resistor
    path.moveTo(batteryX, batteryRect.top);
    path.lineTo(batteryX, resistorY + R);
    path.arcToPoint(
      Offset(batteryX + R, resistorY),
      radius: Radius.circular(R),
      clockwise: true,
    );
    path.lineTo(resistorRect.left, resistorY);

    // Seg. 2: Direita do Encaixe Resistor -> Canto Sup. Dir. -> Topo do Encaixe LED
    path.moveTo(resistorRect.right, resistorY);
    path.lineTo(ledX - R, resistorY);
    path.arcToPoint(
      Offset(ledX, resistorY + R),
      radius: Radius.circular(R),
      clockwise: true,
    );
    path.lineTo(ledX, ledRect.top);

    // Seg. 3: Base do Encaixe LED -> Canto Inf. Dir. -> Direita do Encaixe Interruptor
    path.moveTo(ledX, ledRect.bottom);
    path.lineTo(ledX, switchY - R);
    path.arcToPoint(
      Offset(ledX - R, switchY),
      radius: Radius.circular(R),
      clockwise: true,
    );
    path.lineTo(switchRect.right, switchY);

    // Seg. 4: Esquerda do Encaixe Interruptor -> Canto Inf. Esq. -> Base do Encaixe Bateria
    path.moveTo(switchRect.left, switchY);
    path.lineTo(batteryX + R, switchY);
    path.arcToPoint(
      Offset(batteryX, switchY - R),
      radius: Radius.circular(R),
      clockwise: true,
    );
    path.lineTo(batteryX, batteryRect.bottom);

    canvas.drawPath(path, wireGlowPaint);
    canvas.drawPath(path, wirePaint);
  }

  @override
  bool shouldRepaint(covariant _Phase3TerminalConnectedWirePainter oldDelegate) {
    return oldDelegate.batteryRect != batteryRect ||
        oldDelegate.resistorRect != resistorRect ||
        oldDelegate.ledRect != ledRect ||
        oldDelegate.switchRect != switchRect ||
        oldDelegate.cornerRadius != cornerRadius;
  }
}

