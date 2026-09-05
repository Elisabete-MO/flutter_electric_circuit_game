import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/second_bench_flow.dart';
import '../../state/progress_controller.dart';
import '../../widgets/glass_container.dart';
import 'second_bench_phase1.dart';
import 'second_bench_phase2.dart';
import 'second_bench_phase3.dart';
import 'second_bench_phase4.dart';
import 'widgets/second_bench_header.dart';

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
          _isLoading = false;
        });
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
      body: SafeArea(
        child: Column(
          children: [
            // Cabeçalho único padronizado no topo do Estande 2
            SecondBenchHeader(
              currentPhaseId: _flowState.currentPhaseId,
              completedPhaseIds: _flowState.completedPhaseIds,
              unlockedPhaseIds: _flowState.unlockedPhaseIds,
              onSelectPhase: _navigateToPhase,
              onBack: () => Navigator.of(context).maybePop(),
            ),

            // Conteúdo Ativo da Fase com Scaffold Compartilhado
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildCurrentPhaseWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPhaseWidget() {
    return switch (_flowState.currentPhaseId) {
      1 => SecondBenchPhase1(
          key: const ValueKey(1),
          onPhaseComplete: () => _onPhaseCompleted(1),
        ),
      2 => SecondBenchPhase2(
          key: const ValueKey(2),
          onPhaseComplete: () => _onPhaseCompleted(2),
        ),
      3 => SecondBenchPhase3(
          key: const ValueKey(3),
          onPhaseComplete: () => _onPhaseCompleted(3),
        ),
      4 => SecondBenchPhase4(
          key: const ValueKey(4),
          onPhaseComplete: () => _onPhaseCompleted(4),
        ),
      _ => SecondBenchPhase1(
          key: const ValueKey(1),
          onPhaseComplete: () => _onPhaseCompleted(1),
        ),
    };
  }
}
