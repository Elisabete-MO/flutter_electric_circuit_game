import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Identidade visual moderna e tecnológica do EletroLab.
abstract final class EletroLabColors {
  // ── Cor semente do tema (azul elétrico) ─────────────────────────────────
  static const Color seed = Color(0xFF2979FF);

  // ── Paleta de acento — cada cor é claramente distinta ───────────────────
  static const Color electricBlue = Color(0xFF2979FF); // azul elétrico (base)
  static const Color neonCyan     = Color(0xFF00E5FF); // ciano neon
  static const Color cyan         = Color(0xFF00E5FF); // alias
  static const Color neonGreen    = Color(0xFF00E676); // verde neon
  static const Color neonPurple   = Color(0xFF7C4DFF); // violeta médio (harmônico)
  static const Color hotPink      = Color(0xFFFF4081); // rosa/magenta
  static const Color amber        = Color(0xFFFF9F1C); // âmbar
  static const Color success      = Color(0xFF00E676); // verde (sucesso)
  static const Color error        = Color(0xFFFF4081); // rosa (erro)

  // ── Fundos ───────────────────────────────────────────────────────────────
  /// Modo claro: branco azulado limpo
  static const Color benchLight = Color(0xFFF0F4FF);

  /// Modo escuro: azul marinho profundo (espaço)
  static const Color benchDark  = Color(0xFF080C1A);

  // ── Cores vibrantes de borda para cards — modo escuro ───────────────────
  static const List<Color> borderDarkColors = [
    Color(0xFFFF9F1C), // âmbar         — Tutorial / Desafio 1
    Color(0xFF2979FF), // azul elétrico — Campanha / Desafio 2
    Color(0xFF00E5FF), // ciano neon    — Sandbox  / Desafio 3
    Color(0xFF00E676), // verde neon    — Config
    Color(0xFF7C4DFF), // violeta       — extra
  ];

  // ── Cores vibrantes de borda para cards — modo claro ────────────────────
  static const List<Color> borderLightColors = [
    Color(0xFFF59E0B), // âmbar
    Color(0xFF3B82F6), // azul
    Color(0xFF06B6D4), // ciano
    Color(0xFF10B981), // verde
    Color(0xFF8B5CF6), // violeta
  ];
}

abstract final class EletroLabTheme {
  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final scheme = ColorScheme.fromSeed(
      seedColor: EletroLabColors.seed,
      brightness: brightness,
      // Modo claro: primário azul elétrico sólido; escuro: azul neon vibrante
      primary:    isLight ? const Color(0xFF1565C0) : EletroLabColors.electricBlue,
      onPrimary:  Colors.white,
      secondary:  EletroLabColors.neonCyan,
      tertiary:   EletroLabColors.amber,
      surface:    isLight ? Colors.white : const Color(0xFF0F1326),
      onSurface:  isLight ? const Color(0xFF0D1B3E) : const Color(0xFFE8EEF9),
    );

    final baseTextTheme = isLight ? Typography.blackMountainView : Typography.whiteMountainView;
    final bodyTextTheme = GoogleFonts.outfitTextTheme(baseTextTheme);
    final titleFontFamily = GoogleFonts.rajdhani().fontFamily;

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: bodyTextTheme,
      scaffoldBackgroundColor:
          isLight ? EletroLabColors.benchLight : EletroLabColors.benchDark,
    );

    return base.copyWith(
      textTheme: bodyTextTheme.copyWith(
        displayLarge: bodyTextTheme.displayLarge?.copyWith(fontSize: 59, fontFamily: titleFontFamily, fontWeight: FontWeight.bold, letterSpacing: 1.0),
        displayMedium: bodyTextTheme.displayMedium?.copyWith(fontSize: 47, fontFamily: titleFontFamily, fontWeight: FontWeight.bold, letterSpacing: 1.0),
        displaySmall: bodyTextTheme.displaySmall?.copyWith(fontSize: 38, fontFamily: titleFontFamily, fontWeight: FontWeight.bold, letterSpacing: 1.0),
        headlineLarge: bodyTextTheme.headlineLarge?.copyWith(fontSize: 34, fontFamily: titleFontFamily, fontWeight: FontWeight.bold, letterSpacing: 0.8),
        headlineMedium: bodyTextTheme.headlineMedium?.copyWith(fontSize: 30, fontFamily: titleFontFamily, fontWeight: FontWeight.bold, letterSpacing: 0.8),
        headlineSmall: bodyTextTheme.headlineSmall?.copyWith(fontSize: 26, fontFamily: titleFontFamily, fontWeight: FontWeight.bold, letterSpacing: 0.8),
        titleLarge: bodyTextTheme.titleLarge?.copyWith(fontSize: 24, fontFamily: titleFontFamily, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        titleMedium: bodyTextTheme.titleMedium?.copyWith(fontSize: 18, fontFamily: titleFontFamily, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        titleSmall: bodyTextTheme.titleSmall?.copyWith(fontSize: 16, fontFamily: titleFontFamily, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        bodyLarge: bodyTextTheme.bodyLarge?.copyWith(fontSize: 18),
        bodyMedium: bodyTextTheme.bodyMedium?.copyWith(fontSize: 16),
        bodySmall: bodyTextTheme.bodySmall?.copyWith(fontSize: 14),
        labelLarge: bodyTextTheme.labelLarge?.copyWith(fontSize: 16),
        labelMedium: bodyTextTheme.labelMedium?.copyWith(fontSize: 14),
        labelSmall: bodyTextTheme.labelSmall?.copyWith(fontSize: 13),
      ).apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: titleFontFamily,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          letterSpacing: 1.0,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: isLight ? Colors.white : const Color(0xFF1D1146),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isLight ? EletroLabColors.borderLightColors[0] : EletroLabColors.borderDarkColors[0],
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          textStyle: TextStyle(
            fontFamily: titleFontFamily,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
      ),
    );
  }
}
