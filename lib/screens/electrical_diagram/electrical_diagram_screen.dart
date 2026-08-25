import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/electrical_calculator.dart';
import '../../widgets/tech_grid_background.dart';

/// Tela da Calculadora Elétrica (Lei de Ohm e Lei da Potência).
class ElectricalDiagramScreen extends StatelessWidget {
  const ElectricalDiagramScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calculadora Elétrica',
          style: theme.textTheme.titleLarge?.copyWith(
            fontFamily: GoogleFonts.rajdhani().fontFamily,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: TechGridBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: const ElectricalCalculatorWidget(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}