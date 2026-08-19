import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'mvp/activity_controller.dart';
import 'mvp/diagram_game.dart';
import 'mvp/eletrolab_game.dart';
import 'mvp/mvp_contract.dart';

void main() => runApp(const EletroLabApp());

class EletroLabApp extends StatelessWidget {
  const EletroLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EletroLab',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        useMaterial3: true,
      ),
      home: const EletroLabActivityScreen(),
    );
  }
}

class EletroLabActivityScreen extends StatefulWidget {
  const EletroLabActivityScreen({super.key});

  @override
  State<EletroLabActivityScreen> createState() =>
      _EletroLabActivityScreenState();
}

class _EletroLabActivityScreenState extends State<EletroLabActivityScreen> {
  late final ActivityController _controller;
  late final EletroLabGame _game;
  late final CircuitDiagramGame _diagramGame;
  late final SymbolLibraryGame _libraryGame;

  @override
  void initState() {
    super.initState();
    _controller = ActivityController();
    _game = EletroLabGame(controller: _controller);
    _diagramGame = CircuitDiagramGame(controller: _controller);
    _libraryGame = SymbolLibraryGame();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EletroLab')),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Observe, experimente e represente o circuito.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Circuito físico',
                child: SizedBox(height: 220, child: GameWidget(game: _game)),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Monte o diagrama',
                child: SizedBox(
                  height: 230,
                  child: GameWidget(game: _diagramGame),
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Biblioteca de símbolos',
                child: SizedBox(
                  height: 90,
                  child: GameWidget(game: _libraryGame),
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Valores elétricos',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tensão: 6 V'),
                    const Text('Resistência: 12 Ω'),
                    Text(
                      'Corrente: ${_formatCurrent(_controller.currentAmps)}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _controller.verifyDiagram,
                child: const Text('Verificar diagrama'),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Feedback',
                child: Text(_feedbackMessage(_controller.validationStatus)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatCurrent(double currentAmps) {
  return currentAmps == 0 ? '0 A' : '0,5 A';
}

String _feedbackMessage(ValidationStatus status) {
  return switch (status) {
    ValidationStatus.idle => 'Posicione os símbolos e verifique o diagrama.',
    ValidationStatus.incomplete =>
      'Complete todas as posições antes de verificar.',
    ValidationStatus.incorrect => 'Confira o símbolo utilizado nesta posição.',
    ValidationStatus.correct =>
      'Muito bem! O diagrama representa o circuito apresentado.',
  };
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
