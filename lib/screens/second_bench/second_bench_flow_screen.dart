import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/second_bench_flow.dart';
import '../../state/progress_controller.dart';
import '../../widgets/eletrolab_header_brand.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/tech_grid_background.dart';
import 'second_bench_phase1.dart';
import 'second_bench_phase2.dart';
import 'second_bench_phase3.dart';
import 'second_bench_phase4.dart';

/// Coordenador principal do fluxo do Segundo Estande - Acende Aí (4 Fases).
class SecondBenchFlowScreen extends ConsumerStatefulWidget {
  const SecondBenchFlowScreen({super.key});

  @override
  ConsumerState<SecondBenchFlowScreen> createState() => _SecondBenchFlowScreenState();
}

class _SecondBenchFlowScreenState extends ConsumerState<SecondBenchFlowScreen> {
  late SecondBenchFlowState _flowState;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final rawJson = prefs.getString(SecondBenchFlowState.storageKey);
      if (rawJson != null && rawJson.isNotEmpty) {
        final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
        _flowState = SecondBenchFlowState.fromJson(decoded);
      } else {
        _flowState = SecondBenchFlowState.safe();
      }
    } catch (_) {
      _flowState = SecondBenchFlowState.safe();
    } finally {
      if (mounted) {
        setState(() {
          _flowState = SecondBenchFlowState.safe();
          _isLoading = false;
        });
        _saveState();
      }
    }
  }

  Future<void> _saveState() async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final rawJson = jsonEncode(_flowState.toJson());
      await prefs.setString(SecondBenchFlowState.storageKey, rawJson);
    } catch (_) {}
  }

  void _onPhaseCompleted(int phaseId) async {
    final nextState = _flowState.markCompleted(phaseId);
    setState(() {
      _flowState = nextState;
    });
    await _saveState();
    if (!mounted) return;

    if (phaseId == 4) {
      // Concluiu o segundo estande por completo!
      ref.read(progressControllerProvider.notifier).markAsCompleted('second_bench', stars: 3);
      ref.read(progressControllerProvider.notifier).markAsCompleted('acende_ai', stars: 3);
      _showCompletionDialog();
    }
  }

  void _navigateToPhase(int phaseId) {
    if (_flowState.isUnlocked(phaseId)) {
      setState(() {
        _flowState = _flowState.advanceTo(phaseId);
      });
      _saveState();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: GlassContainer(
            borderRadius: 24,
            accentColor: const Color(0xFF00FF9D),
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lightbulb_rounded,
                  color: Color(0xFF00FF9D),
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'SEGUNDO ESTANDE CONCLUÍDO!',
                  style: TextStyle(
                    fontFamily: GoogleFonts.rajdhani().fontFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00FF9D),
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Você concluiu todas as 4 fases do Estande Acende Aí! O segundo ponto da Maquete Coletiva da Feira de Ciências foi iluminado com sucesso.',
                  style: TextStyle(
                    fontFamily: GoogleFonts.outfit().fontFamily,
                    fontSize: 15,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(); // Retorna ao mapa
                  },
                  icon: const Icon(Icons.map_rounded),
                  label: Text(
                    'RETORNAR AO MAPA',
                    style: TextStyle(
                      fontFamily: GoogleFonts.rajdhani().fontFamily,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF00FF9D),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF021712),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00FF9D)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF021712),
      body: TechGridBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Barra Superior de Controle e Progresso das Fases
              _buildHeaderBar(context),

              // Conteúdo da Fase Ativa
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildCurrentPhaseWidget(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
        border: const Border(
          bottom: BorderSide(color: Color(0xFF1E293B), width: 1.5),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 600;

          return Row(
            children: [
              // Botão de Voltar ao Mapa
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                tooltip: 'Voltar ao Mapa',
                onPressed: () => Navigator.of(context).pop(),
              ),

              if (!isCompact) ...[
                const EletroLabHeaderBrand(compact: true),
                const SizedBox(width: 16),
              ],

              // Indicadores de Progresso das 4 Fases
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final phaseId = index + 1;
                    final isCurrent = _flowState.currentPhaseId == phaseId;
                    final isCompleted = _flowState.completedPhaseIds.contains(phaseId);
                    final isUnlocked = _flowState.isUnlocked(phaseId);

                    Color stepColor;
                    if (isCurrent) {
                      stepColor = const Color(0xFF00FF9D);
                    } else if (isCompleted) {
                      stepColor = const Color(0xFF10B981);
                    } else if (isUnlocked) {
                      stepColor = Colors.white54;
                    } else {
                      stepColor = const Color(0xFF334155);
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: isUnlocked ? () => _navigateToPhase(phaseId) : null,
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(
                            horizontal: isCompact ? 8 : 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: stepColor.withValues(alpha: isCurrent ? 0.2 : 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: stepColor,
                              width: isCurrent ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isCompleted)
                                Icon(Icons.check_circle_rounded, size: 16, color: stepColor)
                              else if (!isUnlocked)
                                const Icon(Icons.lock_rounded, size: 14, color: Color(0xFF64748B))
                              else
                                Text(
                                  '$phaseId',
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.rajdhani().fontFamily,
                                    fontWeight: FontWeight.bold,
                                    color: stepColor,
                                    fontSize: 14,
                                  ),
                                ),
                              if (!isCompact) ...[
                                const SizedBox(width: 6),
                                Text(
                                  'Fase $phaseId',
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.rajdhani().fontFamily,
                                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                                    color: stepColor,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Botão Repetir Fase Atual (se concluída)
              if (_flowState.completedPhaseIds.contains(_flowState.currentPhaseId))
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Color(0xFF10B981)),
                  tooltip: 'Repetir esta fase',
                  onPressed: () {
                    setState(() {});
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCurrentPhaseWidget() {
    return switch (_flowState.currentPhaseId) {
      1 => SecondBenchPhase1(
          onPhaseComplete: () => _onPhaseCompleted(1),
        ),
      2 => SecondBenchPhase2(
          onPhaseComplete: () => _onPhaseCompleted(2),
        ),
      3 => SecondBenchPhase3(
          onPhaseComplete: () => _onPhaseCompleted(3),
        ),
      4 => SecondBenchPhase4(
          onPhaseComplete: () => _onPhaseCompleted(4),
        ),
      _ => SecondBenchPhase1(
          onPhaseComplete: () => _onPhaseCompleted(1),
        ),
    };
  }
}
