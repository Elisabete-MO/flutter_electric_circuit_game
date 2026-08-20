import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'package:flutter_electric_circuit_game/mvp/activity_controller.dart';
import 'package:flutter_electric_circuit_game/mvp/circuit_analysis_panel.dart';
import 'package:flutter_electric_circuit_game/mvp/diagram_game.dart';
import 'package:flutter_electric_circuit_game/mvp/diagram_workspace.dart';
import 'package:flutter_electric_circuit_game/mvp/eletrolab_game.dart';
import 'package:flutter_electric_circuit_game/mvp/mvp_contract.dart';

void main() => runApp(const EletroLabApp());

class EletroLabApp extends StatelessWidget {
  const EletroLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EletroLab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0284C7),
          primary: const Color(0xFF0284C7),
        ),
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
  ValidationStatus _lastStatus = ValidationStatus.idle;

  @override
  void initState() {
    super.initState();
    _controller = ActivityController();
    _game = EletroLabGame(controller: _controller);
    _diagramGame = CircuitDiagramGame(controller: _controller);
    _controller.addListener(_onStatusChange);
  }

  void _onStatusChange() {
    if (_controller.validationStatus != _lastStatus) {
      _lastStatus = _controller.validationStatus;
      if (_lastStatus != ValidationStatus.idle) {
        final message = _feedbackMessage(_lastStatus);
        final color = _lastStatus == ValidationStatus.correct
            ? const Color(0xFF10B981)
            : const Color(0xFFEF4444);

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: color,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onStatusChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('docs/EletroLab_AssetPack_v1/assets/ui/workshop_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildTopHeader(),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _HeaderPanel(
                            title: 'Circuito físico',
                            flex: 1,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: GameWidget(game: _game),
                            ),
                          ),
                          const SizedBox(width: 16),
                          _HeaderPanel(
                            title: 'Diagrama criado',
                            flex: 1,
                            child: DiagramWorkspace(
                              controller: _controller,
                              diagramGame: _diagramGame,
                            ),
                          ),
                          const SizedBox(width: 16),
                          _HeaderPanel(
                            title: 'Análise do circuito',
                            flex: 1,
                            child: CircuitAnalysisPanel(controller: _controller),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0284C7),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x20000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.bolt,
                  color: Color(0xFF0284C7),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'EletroLab',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildHeaderButton(Icons.menu_book),
              const SizedBox(width: 8),
              _buildHeaderButton(Icons.help_outline),
              const SizedBox(width: 8),
              _buildHeaderButton(Icons.settings),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withAlpha(140), width: 1.5),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: () {},
      ),
    );
  }
}

class _HeaderPanel extends StatelessWidget {
  const _HeaderPanel({
    required this.title,
    required this.child,
    this.flex = 1,
  });

  final String title;
  final Widget child;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0284C7),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
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
