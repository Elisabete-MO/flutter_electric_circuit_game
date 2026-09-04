import 'package:flutter/material.dart';

/// Tokens de layout, medidas e cores padronizadas para o Estande 2 (Acende Aí).
abstract final class SecondBenchLayoutTokens {
  // Dimensões Máximas e Proporções em Desktop
  static const double desktopMaxWidth = 1600;
  static const double desktopMaxHeight = 900;
  static const double desktopPadding = 24;
  static const double sectionGap = 16;

  // Painel Lateral Padronizado
  static const double sidePanelWidth = 380;
  static const double sidePanelMinWidth = 340;
  static const double panelRadius = 20;

  // Cabeçalho e Barra Inferior
  static const double headerHeight = 72;
  static const double actionBarHeight = 64;
  static const double introMaxWidth = 720;
  static const double itemCardRadius = 14;
  static const double touchTargetMinSize = 44;

  // Cores Institucionais do EletroLab
  static const Color bgDark = Color(0xFF021712);
  static const Color panelBg = Color(0xFFFAF7EF); // Fundo creme institucional
  static const Color panelBorder = Color(0xFF1B4D3E); // Borda verde-escura
  static const Color panelHeaderBg = Color(0xFFF2EAD9);
  static const Color accentGreen = Color(0xFF00FF9D);
  static const Color primaryGreen = Color(0xFF10B981);
  static const Color darkGreen = Color(0xFF0F3D30);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textLight = Colors.white;
}
