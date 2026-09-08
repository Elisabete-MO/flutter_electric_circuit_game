import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Utilitário central de responsividade e escala proporcional do EletroLab.
///
/// Adota como resolução de referência de design 1920 × 1080 px (onde scale = 1.0).
/// Em monitores maiores (2K, 4K), os elementos crescem proporcionalmente com
/// limites seguros (clamping). Em telas menores (laptops, tablets), reduzem de forma
/// utilizável sem overflow.
class UiScale {
  /// Resolução de referência (Design Space padrão)
  static const double designWidth = 1920.0;
  static const double designHeight = 1080.0;
  static const double designAspectRatio = designWidth / designHeight; // ~1.777 (16:9)

  final double screenWidth;
  final double screenHeight;

  UiScale._({
    required this.screenWidth,
    required this.screenHeight,
  });

  /// Factory a partir de BuildContext
  factory UiScale.of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return UiScale._(screenWidth: size.width, screenHeight: size.height);
  }

  /// Factory a partir de dimensões explícitas (ex: constraints de LayoutBuilder)
  factory UiScale.fromSize(double width, double height) {
    return UiScale._(
      screenWidth: width > 0 ? width : designWidth,
      screenHeight: height > 0 ? height : designHeight,
    );
  }

  /// Aspect Ratio atual da tela
  double get aspectRatio => screenHeight > 0 ? screenWidth / screenHeight : designAspectRatio;

  /// Fator de escala horizontal puro em relação à largura de referência (1920px)
  double get scaleX => screenWidth / designWidth;

  /// Fator de escala vertical puro em relação à altura de referência (1080px)
  double get scaleY => screenHeight / designHeight;

  /// Escala uniforme pura baseada na menor dimensão (evita corte em qualquer aspect ratio)
  double get rawUniformScale => math.min(scaleX, scaleY);

  /// Escala geral da interface (HUD, botões, cards, textos) com limites de proteção
  /// - Em 1920x1080: 1.0
  /// - Em 2560x1440 (2K): ~1.33
  /// - Em 3840x2160 (4K): ~2.0
  /// - Em 1366x768: ~0.72 (limitado a 0.72 para manter legibilidade)
  /// - Em 1280x720: ~0.72
  double get scale => rawUniformScale.clamp(0.72, 2.20);

  /// Mantido para compatibilidade com usos legados
  double get scaleFactor => scale;

  // ---------------------------------------------------------------------------
  // CLASSIFICAÇÃO DE DISPOSITIVOS E FORMATOS
  // ---------------------------------------------------------------------------

  /// Identifica se a tela é móvel / compacta (< 640px)
  bool get isMobile => screenWidth < 640 || screenHeight < 480;

  /// Identifica se a tela é tablet / intermediária (640px - 1024px)
  bool get isTablet => screenWidth >= 640 && screenWidth < 1024;

  /// Identifica se a tela é desktop / tela cheia (>= 1024px)
  bool get isDesktop => screenWidth >= 1024;

  /// Identifica monitores de altíssima densidade / resolução 4K (>= 3200px largura ou >= 1800px altura)
  bool get is4K => screenWidth >= 3200 || screenHeight >= 1800;

  /// Identifica monitores 2K / QHD (>= 2200px e < 3200px)
  bool get is2K => (screenWidth >= 2200 && screenWidth < 3200) || (screenHeight >= 1300 && screenHeight < 1800);

  /// Identifica telas ultrawide (21:9 ou maior)
  bool get isUltrawide => aspectRatio >= 2.0;

  // ---------------------------------------------------------------------------
  // MÉTODOS DE ESCALA PROPORCIONAL
  // ---------------------------------------------------------------------------

  /// Escala uma dimensão genérica (largura, altura, tamanho de card, raio de borda)
  /// com limites opcionais.
  double size(double baseSize, {double? min, double? max, double weight = 1.0}) {
    final effectiveScale = 1.0 + (scale - 1.0) * weight;
    final val = baseSize * effectiveScale;
    final lower = min ?? (baseSize * 0.65);
    final upper = max ?? (baseSize * 2.5);
    return val.clamp(lower, upper);
  }

  /// Escala de tipografia protegida contra corte em telas pequenas e gigantismo em 4K.
  double font(
    double baseFont, {
    double? min,
    double? max,
    double maxFactor = 1.9,
  }) {
    // Escala suave para tipografia (suaviza ligeiramente o crescimento extremo)
    final effectiveScale = 1.0 + (scale - 1.0) * 0.95;
    final scaled = baseFont * effectiveScale;
    final lower = min ?? (baseFont * 0.75).clamp(8.0, baseFont);
    final upper = max ?? (baseFont * maxFactor);
    return scaled.clamp(lower, upper);
  }

  /// Escala de espaçamentos, gaps e paddings
  double spacing(double baseSpacing, {double? min, double? max}) {
    final val = baseSpacing * (1.0 + (scale - 1.0) * 0.85);
    final lower = min ?? (baseSpacing * 0.7);
    final upper = max ?? (baseSpacing * 2.2);
    return val.clamp(lower, upper);
  }

  /// Escala de ícones
  double icon(double baseIconSize, {double? min, double? max}) {
    final val = baseIconSize * (1.0 + (scale - 1.0) * 0.9);
    final lower = min ?? (baseIconSize * 0.75);
    final upper = max ?? (baseIconSize * 2.2);
    return val.clamp(lower, upper);
  }

  /// Largura responsiva para diálogos e modais
  double dialogWidth(
    double baseWidth, {
    double maxPercent = 0.88,
    double? min,
    double? max,
  }) {
    final scaled = baseWidth * scale;
    final maxAllowed = screenWidth * maxPercent;
    final lower = min ?? (baseWidth * 0.85);
    final upper = max ?? maxAllowed;
    return scaled.clamp(lower, math.max(lower, upper));
  }

  /// Largura responsiva para cartões flutuantes (ex: StandInfoCard, painéis HUD)
  double cardWidth(
    double baseWidth, {
    double maxPercent = 0.40,
    double? min,
    double? max,
  }) {
    final scaled = baseWidth * scale;
    final maxAllowed = screenWidth * maxPercent;
    final lower = min ?? (baseWidth * 0.85);
    final upper = max ?? math.max(baseWidth, maxAllowed);
    return scaled.clamp(lower, math.max(lower, upper));
  }

  /// Helper para EdgeInsets.all escalado
  EdgeInsets insetsAll(double val) {
    final s = spacing(val);
    return EdgeInsets.all(s);
  }

  /// Helper para EdgeInsets.symmetric escalado
  EdgeInsets insetsSymmetric({double horizontal = 0.0, double vertical = 0.0}) {
    return EdgeInsets.symmetric(
      horizontal: spacing(horizontal),
      vertical: spacing(vertical),
    );
  }

  /// Helper para EdgeInsets.only escalado
  EdgeInsets insetsOnly({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) {
    return EdgeInsets.only(
      left: spacing(left),
      top: spacing(top),
      right: spacing(right),
      bottom: spacing(bottom),
    );
  }

  /// Mapeia coordenada X do espaço de design (1920) para o espaço real da tela
  double designX(double x) => x * scaleX;

  /// Mapeia coordenada Y do espaço de design (1080) para o espaço real da tela
  double designY(double y) => y * scaleY;

  /// Mapeia Ponto (X, Y) proporcional ao menor lado para manter proporção
  Offset uniformOffset(double x, double y) => Offset(x * scale, y * scale);

  /// Método legado compatível: escala com dynamic min/max
  double clampScaled(double baseValue, double minVal, double maxVal) {
    final expandedMax = maxVal * (isDesktop ? scale : 1.0);
    return (baseValue * (isDesktop ? scale : 1.0)).clamp(minVal, expandedMax);
  }
}

/// Extension ergonômica para fácil acesso no BuildContext:
/// `context.uiScale` ou `context.responsive`
extension UiScaleContext on BuildContext {
  UiScale get uiScale => UiScale.of(this);
  UiScale get responsive => UiScale.of(this);
}
