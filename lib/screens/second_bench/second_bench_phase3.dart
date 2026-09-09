import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/first_step_component.dart';
import '../../widgets/component_physical_painter.dart';
import '../../widgets/prof_volts_feedback_dialog.dart';
import '../common_stand/stand_flow_tokens.dart';
import '../../widgets/workbench_components.dart';
import '../../widgets/workbench_sidebar_cards.dart';
import '../../widgets/workbench_table_frame.dart';
import 'widgets/second_bench_item_grid.dart';

/// Tipos de símbolos elétricos esquemáticos da Fase 3 (4 corretos + 2 distratores reais)
enum Phase3SymbolType {
  battery,         // Bateria (Pólos + e -)
  resistor,        // Resistor (Zigue-zague)
  led,             // LED (Diodo com setas de emissão)
  switchComponent, // Interruptor SPST aberto
  lamp,            // Lâmpada Incandescente (Círculo com X) - Distrator 1
  diode,           // Diodo Retificador (Diodo sem setas) - Distrator 2
}

/// Identificadores dos 4 encaixes do circuito em série na Fase 3
enum Phase3SlotId {
  battery,    // Lado Esquerdo (Vertical)
  resistor,   // Topo (Horizontal)
  led,        // Lado Direito (Vertical)
  switchComp, // Base (Horizontal)
}

/// Fase 3 do Segundo Estande (Acende Aí): Do componente ao símbolo esquemático.
class SecondBenchPhase3 extends StatefulWidget {
  final VoidCallback? onPhaseComplete;

  const SecondBenchPhase3({
    super.key,
    this.onPhaseComplete,
  });

  @override
  State<SecondBenchPhase3> createState() => _SecondBenchPhase3State();
}

class _SecondBenchPhase3State extends State<SecondBenchPhase3> {
  // Seletor de Modo: true = Diagrama (Interativo), false = Físico (Consulta)
  bool _isDiagramMode = true;

  // Mapa dos 4 Encaixes no Circuito
  final Map<Phase3SlotId, Phase3SymbolType?> _slots = {
    Phase3SlotId.battery: null,
    Phase3SlotId.resistor: null,
    Phase3SlotId.led: null,
    Phase3SlotId.switchComp: null,
  };

  // Status de validação individual de cada slot (null = não checado, true = OK, false = Erro)
  final Map<Phase3SlotId, bool?> _slotValidation = {
    Phase3SlotId.battery: null,
    Phase3SlotId.resistor: null,
    Phase3SlotId.led: null,
    Phase3SlotId.switchComp: null,
  };

  // Símbolo selecionado por toque na biblioteca para acessibilidade
  Phase3SymbolType? _selectedLibrarySymbol;

  // Lista dos 6 símbolos esquemáticos na biblioteca
  late List<Phase3SymbolType> _librarySymbols;

  @override
  void initState() {
    super.initState();
    _initLibrarySymbols();
  }

  void _initLibrarySymbols() {
    final list = [
      Phase3SymbolType.battery,
      Phase3SymbolType.resistor,
      Phase3SymbolType.led,
      Phase3SymbolType.switchComponent,
      Phase3SymbolType.lamp,
      Phase3SymbolType.diode,
    ];
    list.shuffle();
    _librarySymbols = list;
  }

  void _resetDiagram() {
    setState(() {
      for (final key in _slots.keys) {
        _slots[key] = null;
        _slotValidation[key] = null;
      }
      _selectedLibrarySymbol = null;
    });
  }

  void _assignSymbolToSlot(Phase3SlotId slot, Phase3SymbolType symbol) {
    setState(() {
      // Se o mesmo símbolo já estava em outro slot, remove do slot anterior
      _slots.forEach((key, val) {
        if (val == symbol) {
          _slots[key] = null;
          _slotValidation[key] = null;
        }
      });

      _slots[slot] = symbol;
      _slotValidation[slot] = null;
      _selectedLibrarySymbol = null;
    });
  }

  void _removeSymbolFromSlot(Phase3SlotId slot) {
    setState(() {
      _slots[slot] = null;
      _slotValidation[slot] = null;
    });
  }

  int get _filledSlotsCount => _slots.values.where((v) => v != null).length;
  bool get _isAllSlotsFilled => _filledSlotsCount == 4;

  void _verifyDiagram() {
    final batSym = _slots[Phase3SlotId.battery];
    final resSym = _slots[Phase3SlotId.resistor];
    final ledSym = _slots[Phase3SlotId.led];
    final swSym = _slots[Phase3SlotId.switchComp];

    final isBatOk = batSym == Phase3SymbolType.battery;
    final isResOk = resSym == Phase3SymbolType.resistor;
    final isLedOk = ledSym == Phase3SymbolType.led;
    final isSwOk = swSym == Phase3SymbolType.switchComponent;

    setState(() {
      _slotValidation[Phase3SlotId.battery] = isBatOk;
      _slotValidation[Phase3SlotId.resistor] = isResOk;
      _slotValidation[Phase3SlotId.led] = isLedOk;
      _slotValidation[Phase3SlotId.switchComp] = isSwOk;
    });

    final isAllCorrect = isBatOk && isResOk && isLedOk && isSwOk;

    if (isAllCorrect) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ProfVoltsFeedbackDialog(
          isCorrect: true,
          message: 'Parabéns! Você associou corretamente todos os componentes físicos aos seus símbolos esquemáticos técnicos.',
          onAction: () {
            Navigator.of(context).pop();
            widget.onPhaseComplete?.call();
          },
        ),
      );
    } else {
      String hint = 'Verifique a posição dos símbolos esquemáticos no circuito.';
      if (ledSym == Phase3SymbolType.lamp) {
        hint = 'Observe: a lâmpada incandescente (círculo com X) não é equivalente ao LED esquemático.';
      } else if (ledSym == Phase3SymbolType.diode) {
        hint = 'O LED é um diodo emissor de luz. Seu símbolo esquemático precisa ter as duas setas apontando para fora.';
      } else if (!isBatOk) {
        hint = 'Confira o símbolo da Bateria (duas linhas paralelas de comprimentos diferentes).';
      } else if (!isResOk) {
        hint = 'Confira o símbolo do Resistor (zigue-zague ou retângulo IEC).';
      } else if (!isSwOk) {
        hint = 'Confira o símbolo do Interruptor SPST (dois contatos e chave aberta).';
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ProfVoltsFeedbackDialog(
          isCorrect: false,
          message: hint,
          onAction: () {
            Navigator.of(context).pop();
          },
        ),
      );
    }
  }

  void _showHelpModal() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 460),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: StandFlowTokens.primaryGreen, width: 1.5),
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 16)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.schema_rounded, color: StandFlowTokens.primaryGreen, size: 26),
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
              _buildHelpBullet('Alternador de Modo: Alterne entre "Físico" para consultar a bancada real e "Diagrama" para preencher.'),
              _buildHelpBullet('Arrastre ou Toque: Arraste os símbolos esquemáticos da biblioteca para os 4 encaixes do circuito.'),
              _buildHelpBullet('Atenção aos Distratores: A lâmpada incandescente e o diodo simples possuem símbolos diferentes do LED.'),
              const SizedBox(height: 18),
              Center(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: StandFlowTokens.primaryGreen,
                    side: const BorderSide(color: StandFlowTokens.primaryGreen),
                  ),
                  child: const Text('ENTENDI'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: StandFlowTokens.primaryGreen, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13.5, color: Colors.white.withValues(alpha: 0.9)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Área Principal da Bancada
        Expanded(
          flex: 7,
          child: WorkbenchTableFrame(
            usePhysicalStyle: !_isDiagramMode,
            onStyleChanged: (isPhysical) =>
                setState(() => _isDiagramMode = !isPhysical),
            showModeSelector: true,
            leftHeaderWidget: _buildDiagramStatusBadge(),
            rightHeaderWidget: _buildDiagramProgressBadge(),
            bottomWidget: _buildResetButton(),
            child: _buildWorkspace(),
          ),
        ),
        const SizedBox(width: 16),
        // Painel Lateral (Objetivo + Biblioteca de Símbolos + Ação)
        Expanded(
          flex: 3,
          child: WorkbenchSidePanel(
            teamTitle: 'Painel da Equipe Iluminação',
            showTeamHeader: false,
            buttonColor: const Color(0xFF10B981),
            buttonLabel: 'VERIFICAR DIAGRAMA',
            toolboxItems: [
              const WorkbenchMissionObjectiveCard(
                missionNumber: 3,
                title: 'Do componente ao símbolo',
                description: 'Associe cada componente físico da bancada ao seu símbolo esquemático no diagrama elétrico.',
                voltsTip: 'Alterne entre o modo Físico e Esquemático. Arraste ou toque nos símbolos esquemáticos para completar o diagrama.',
                accentColor: Color(0xFF0284C7),
              ),
              const SizedBox(height: 12),
              _buildSidePanelContent(),
            ],
            onEnergizePressed: () {
              if (_isAllSlotsFilled) {
                _verifyDiagram();
              } else {
                _showHelpModal();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResetButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: OutlinedButton.icon(
        onPressed: _resetDiagram,
        icon: const Icon(Icons.refresh_rounded, size: 18, color: Color(0xFF0F172A)),
        label: Text(
          'REINICIAR DIAGRAMA',
          style: GoogleFonts.rajdhani(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildDiagramStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isDiagramMode ? Icons.schema_rounded : Icons.visibility_rounded,
            color: _isDiagramMode ? const Color(0xFF0284C7) : const Color(0xFF10B981),
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            _isDiagramMode ? 'MODO DIAGRAMA' : 'CONSULTA FÍSICA',
            style: GoogleFonts.rajdhani(
              color: _isDiagramMode ? const Color(0xFF0284C7) : const Color(0xFF10B981),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagramProgressBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFF00FF9D), size: 16),
          const SizedBox(width: 6),
          Text(
            '$_filledSlotsCount de 4 símbolos',
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ÁREA DA WORKSPACE (Circuito Esquemático ou Físico)
  // ==========================================
  Widget _buildWorkspace() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        // Posições dos 4 Encaixes no Circuito Fechado
        final batRect = Rect.fromCenter(center: Offset(w * 0.22, h * 0.50), width: w * 0.12, height: h * 0.28);
        final resRect = Rect.fromCenter(center: Offset(w * 0.50, h * 0.25), width: w * 0.24, height: h * 0.16);
        final ledRect = Rect.fromCenter(center: Offset(w * 0.78, h * 0.50), width: w * 0.12, height: h * 0.28);
        final swRect = Rect.fromCenter(center: Offset(w * 0.50, h * 0.75), width: w * 0.24, height: h * 0.16);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            if (_isDiagramMode) ...[
              // 1. Traçado ortogonal do circuito (CustomPainter)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _OrthogonalCircuitPainter(
                      batRect: batRect,
                      resRect: resRect,
                      ledRect: ledRect,
                      swRect: swRect,
                    ),
                  ),
                ),
              ),

              // Indicadores discretos de polaridade (+) e (-)
              Positioned(
                left: batRect.right + 6,
                top: batRect.top + 6,
                child: const Text('+', style: TextStyle(color: Color(0xFFEDE7D7), fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Positioned(
                left: batRect.right + 6,
                bottom: (h - batRect.bottom) + 6,
                child: const Text('−', style: TextStyle(color: Color(0xFFEDE7D7), fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              Positioned(
                right: (w - ledRect.left) + 6,
                top: ledRect.top + 6,
                child: const Text('+', style: TextStyle(color: Color(0xFFEDE7D7), fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Positioned(
                right: (w - ledRect.left) + 6,
                bottom: (h - ledRect.bottom) + 6,
                child: const Text('−', style: TextStyle(color: Color(0xFFEDE7D7), fontSize: 20, fontWeight: FontWeight.bold)),
              ),

              // 2. Os 4 Encaixes Interativos (Slots)
              _buildSlotWidget(Phase3SlotId.battery, batRect, isVertical: true),
              _buildSlotWidget(Phase3SlotId.resistor, resRect, isVertical: false),
              _buildSlotWidget(Phase3SlotId.led, ledRect, isVertical: true),
              _buildSlotWidget(Phase3SlotId.switchComp, swRect, isVertical: false),
            ] else ...[
              // Modo Físico de Consulta (Bancada Real)
              Positioned(
                left: batRect.left,
                top: batRect.top,
                width: batRect.width,
                height: batRect.height,
                child: CustomPaint(
                  painter: ComponentPhysicalPainter(
                    type: ComponentType.battery,
                    isActive: true,
                    isDarkMode: false,
                    value: 9.0,
                  ),
                ),
              ),
              Positioned(
                left: resRect.left,
                top: resRect.top,
                width: resRect.width,
                height: resRect.height,
                child: CustomPaint(
                  painter: ComponentPhysicalPainter(
                    type: ComponentType.resistor,
                    isActive: true,
                    isDarkMode: false,
                    value: 680.0,
                  ),
                ),
              ),
              Positioned(
                left: ledRect.left,
                top: ledRect.top,
                width: ledRect.width,
                height: ledRect.height,
                child: CustomPaint(
                  painter: ComponentPhysicalPainter(
                    type: ComponentType.led,
                    isActive: false,
                    isDarkMode: false,
                  ),
                ),
              ),
              Positioned(
                left: swRect.left,
                top: swRect.top,
                width: swRect.width,
                height: swRect.height,
                child: CustomPaint(
                  painter: ComponentPhysicalPainter(
                    type: ComponentType.switchComponent,
                    isActive: false,
                    isDarkMode: false,
                  ),
                ),
              ),
              Positioned(
                left: (w - 280) / 2,
                top: h * 0.48,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: StandFlowTokens.primaryGreen),
                  ),
                  child: const Text(
                    'Modo Físico de Consulta (Sem Edição)',
                    style: TextStyle(color: StandFlowTokens.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            ],

            // Seletor de Modo (Físico | Diagrama) no topo da área livre (sempre por cima para receber toques)
            Positioned(
              top: 14,
              left: (w - 200) / 2,
              child: _buildModeSelector(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF061811).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: StandFlowTokens.primaryGreen.withValues(alpha: 0.5)),
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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0A2E20) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: StandFlowTokens.primaryGreen, width: 1.2) : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: GoogleFonts.rajdhani().fontFamily,
            fontWeight: FontWeight.bold,
            fontSize: 13.5,
            color: isSelected ? Colors.white : Colors.white60,
          ),
        ),
      ),
    );
  }

  Widget _buildSlotWidget(Phase3SlotId slotKey, Rect rect, {required bool isVertical}) {
    final placedSymbol = _slots[slotKey];
    final validation = _slotValidation[slotKey];

    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: DragTarget<Phase3SymbolType>(
        onAcceptWithDetails: (details) {
          _assignSymbolToSlot(slotKey, details.data);
        },
        builder: (context, candidateData, rejectedData) {
          final isHovering = candidateData.isNotEmpty;

          Color borderColor;
          if (validation == true) {
            borderColor = StandFlowTokens.primaryGreen;
          } else if (validation == false) {
            borderColor = const Color(0xFFFF5252);
          } else if (isHovering) {
            borderColor = StandFlowTokens.primaryGreen;
          } else if (placedSymbol != null) {
            borderColor = const Color(0xFF38BDF8);
          } else {
            borderColor = const Color(0xFFD6CFC0).withValues(alpha: 0.6);
          }

          return InkWell(
            onTap: () {
              if (_selectedLibrarySymbol != null) {
                _assignSymbolToSlot(slotKey, _selectedLibrarySymbol!);
              } else if (placedSymbol != null) {
                _removeSymbolFromSlot(slotKey);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isHovering
                    ? StandFlowTokens.primaryGreen.withValues(alpha: 0.15)
                    : const Color(0xFF071B12).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: borderColor,
                  width: (isHovering || validation != null) ? 2.5 : 1.4,
                ),
                boxShadow: isHovering
                    ? [
                        BoxShadow(
                          color: StandFlowTokens.primaryGreen.withValues(alpha: 0.4),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ]
                    : const [
                        BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
                      ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (placedSymbol != null)
                    CustomPaint(
                      size: Size(rect.width * 0.8, rect.height * 0.8),
                      painter: _Phase3SymbolPainter(
                        symbolType: placedSymbol,
                        color: const Color(0xFFEDE7D7),
                        isVertical: isVertical,
                      ),
                    )
                  else
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle_outline_rounded,
                          size: 22,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Encaixe',
                          style: TextStyle(
                            fontFamily: GoogleFonts.rajdhani().fontFamily,
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // PAINEL LATERAL (Biblioteca Exclusiva de Símbolos Esquemáticos)
  // ==========================================
  Widget _buildSidePanelContent() {
    final gridItems = _librarySymbols.map((sym) {
      final label = switch (sym) {
        Phase3SymbolType.battery => 'Bateria',
        Phase3SymbolType.resistor => 'Resistor',
        Phase3SymbolType.led => 'LED',
        Phase3SymbolType.switchComponent => 'Interruptor',
        Phase3SymbolType.lamp => 'Lâmpada',
        Phase3SymbolType.diode => 'Diodo',
      };

      final isSelected = _selectedLibrarySymbol == sym;
      final isUsedInSlot = _slots.containsValue(sym);

      return SecondBenchGridItemData<Phase3SymbolType>(
        id: sym.name,
        value: sym,
        label: label,
        isSelected: isSelected,
        isDisabled: isUsedInSlot,
        customPainterWidget: CustomPaint(
          size: const Size(64, 40),
          painter: _Phase3SymbolPainter(
            symbolType: sym,
            color: isUsedInSlot ? Colors.grey : const Color(0xFF1E293B),
            strokeWidth: 2.2,
          ),
        ),
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFF0FDF4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome_mosaic_rounded, color: Color(0xFF10B981), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Biblioteca de Símbolos',
                      style: GoogleFonts.rajdhani(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Toque ou arraste os símbolos para os 4 encaixes.',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SecondBenchItemGrid<Phase3SymbolType>(
            items: gridItems,
            assetHeight: 52,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            onItemTap: (item) {
              setState(() {
                _selectedLibrarySymbol = item.isSelected ? null : item.value;
              });
            },
          ),
        ],
      ),
    );
  }
}

/// Painter ortogonal da linha do circuito fechado em formato retangular com cantos arredondados
class _OrthogonalCircuitPainter extends CustomPainter {
  final Rect batRect;
  final Rect resRect;
  final Rect ledRect;
  final Rect swRect;

  _OrthogonalCircuitPainter({
    required this.batRect,
    required this.resRect,
    required this.ledRect,
    required this.swRect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEDE7D7) // Linha creme com alto contraste
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    // Circuito ortogonal passando pelos centros das conexões dos 4 slots
    final leftX = batRect.center.dx;
    final topY = resRect.center.dy;
    final rightX = ledRect.center.dx;
    final bottomY = swRect.center.dy;

    const cornerRadius = 16.0;

    path.moveTo(leftX, topY + cornerRadius);
    path.quadraticBezierTo(leftX, topY, leftX + cornerRadius, topY);
    path.lineTo(rightX - cornerRadius, topY);
    path.quadraticBezierTo(rightX, topY, rightX, topY + cornerRadius);
    path.lineTo(rightX, bottomY - cornerRadius);
    path.quadraticBezierTo(rightX, bottomY, rightX - cornerRadius, bottomY);
    path.lineTo(leftX + cornerRadius, bottomY);
    path.quadraticBezierTo(leftX, bottomY, leftX, bottomY - cornerRadius);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _OrthogonalCircuitPainter oldDelegate) => false;
}

/// Painter para desenhar os símbolos esquemáticos vetoriais puros (técnicos)
class _Phase3SymbolPainter extends CustomPainter {
  final Phase3SymbolType symbolType;
  final Color color;
  final double strokeWidth;
  final bool isVertical;

  _Phase3SymbolPainter({
    required this.symbolType,
    required this.color,
    this.strokeWidth = 2.2,
    this.isVertical = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    if (isVertical) {
      canvas.save();
      canvas.translate(size.width / 2, size.height / 2);
      canvas.rotate(math.pi / 2);
      canvas.translate(-size.height / 2, -size.width / 2);
      final rotatedSize = Size(size.height, size.width);
      _drawSymbol(canvas, rotatedSize, rotatedSize.width / 2, rotatedSize.height / 2, paint, fillPaint);
      canvas.restore();
    } else {
      _drawSymbol(canvas, size, size.width / 2, size.height / 2, paint, fillPaint);
    }
  }

  void _drawSymbol(Canvas canvas, Size size, double cx, double cy, Paint paint, Paint fillPaint) {
    final w = size.width;

    switch (symbolType) {
      case Phase3SymbolType.battery:
        // Símbolo de Bateria DC: linha maior (+), linha menor (-)
        canvas.drawLine(Offset(0, cy), Offset(cx - 12, cy), paint);
        canvas.drawLine(Offset(cx + 12, cy), Offset(w, cy), paint);
        // Polo Negativo (-) linha curta e mais espessa
        canvas.drawLine(Offset(cx - 12, cy - 12), Offset(cx - 12, cy + 12), paint..strokeWidth = strokeWidth * 1.8);
        // Polo Positivo (+) linha longa e fina
        canvas.drawLine(Offset(cx + 12, cy - 20), Offset(cx + 12, cy + 20), paint..strokeWidth = strokeWidth);
        break;

      case Phase3SymbolType.resistor:
        // Símbolo de Resistor: zigue-zague IEEE
        canvas.drawLine(Offset(0, cy), Offset(cx - 24, cy), paint);
        canvas.drawLine(Offset(cx + 24, cy), Offset(w, cy), paint);

        final p = Path();
        p.moveTo(cx - 24, cy);
        p.lineTo(cx - 18, cy - 10);
        p.lineTo(cx - 10, cy + 10);
        p.lineTo(cx - 2, cy - 10);
        p.lineTo(cx + 6, cy + 10);
        p.lineTo(cx + 14, cy - 10);
        p.lineTo(cx + 20, cy + 10);
        p.lineTo(cx + 24, cy);
        canvas.drawPath(p, paint);
        break;

      case Phase3SymbolType.led:
        // Símbolo de LED: Diodo + 2 setas diagonais para fora
        _drawDiodeBase(canvas, size, cx, cy, paint, fillPaint);

        // Setas de emissão de luz
        final arrowPaint = Paint()
          ..color = color
          ..strokeWidth = strokeWidth * 0.8
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(Offset(cx - 4, cy - 14), Offset(cx + 6, cy - 24), arrowPaint);
        canvas.drawLine(Offset(cx + 6, cy - 24), Offset(cx + 2, cy - 24), arrowPaint);
        canvas.drawLine(Offset(cx + 6, cy - 24), Offset(cx + 6, cy - 20), arrowPaint);

        canvas.drawLine(Offset(cx + 6, cy - 10), Offset(cx + 16, cy - 20), arrowPaint);
        canvas.drawLine(Offset(cx + 16, cy - 20), Offset(cx + 12, cy - 20), arrowPaint);
        canvas.drawLine(Offset(cx + 16, cy - 20), Offset(cx + 16, cy - 16), arrowPaint);
        break;

      case Phase3SymbolType.switchComponent:
        // Símbolo de Interruptor SPST aberto
        final p1 = Offset(cx - 18, cy);
        final p2 = Offset(cx + 18, cy);

        canvas.drawLine(Offset(0, cy), p1, paint);
        canvas.drawLine(p2, Offset(w, cy), paint);

        canvas.drawCircle(p1, strokeWidth * 1.5, fillPaint);
        canvas.drawCircle(p2, strokeWidth * 1.5, fillPaint);

        // Haste inclinada aberta
        canvas.drawLine(p1, Offset(p1.dx + 22, cy - 16), paint);
        break;

      case Phase3SymbolType.lamp:
        // Símbolo de Lâmpada Incandescente (Círculo com X) - Distrator
        final radius = 16.0;
        canvas.drawLine(Offset(0, cy), Offset(cx - radius, cy), paint);
        canvas.drawLine(Offset(cx + radius, cy), Offset(w, cy), paint);

        canvas.drawCircle(Offset(cx, cy), radius, paint);

        final offset = radius * 0.707;
        canvas.drawLine(Offset(cx - offset, cy - offset), Offset(cx + offset, cy + offset), paint);
        canvas.drawLine(Offset(cx - offset, cy + offset), Offset(cx + offset, cy - offset), paint);
        break;

      case Phase3SymbolType.diode:
        // Símbolo de Diodo Retificador (sem setas) - Distrator
        _drawDiodeBase(canvas, size, cx, cy, paint, fillPaint);
        break;
    }
  }

  void _drawDiodeBase(Canvas canvas, Size size, double cx, double cy, Paint paint, Paint fillPaint) {
    final w = size.width;
    final triW = 24.0;
    final triH = 22.0;

    final pLeft = cx - triW / 2;
    final pRight = cx + triW / 2;

    canvas.drawLine(Offset(0, cy), Offset(pLeft, cy), paint);
    canvas.drawLine(Offset(pRight, cy), Offset(w, cy), paint);

    final path = Path()
      ..moveTo(pLeft, cy - triH / 2)
      ..lineTo(pRight, cy)
      ..lineTo(pLeft, cy + triH / 2)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawLine(Offset(pRight, cy - triH / 2), Offset(pRight, cy + triH / 2), paint..strokeWidth = strokeWidth * 1.4);
  }

  @override
  bool shouldRepaint(covariant _Phase3SymbolPainter oldDelegate) {
    return oldDelegate.symbolType != symbolType ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.isVertical != isVertical;
  }
}
