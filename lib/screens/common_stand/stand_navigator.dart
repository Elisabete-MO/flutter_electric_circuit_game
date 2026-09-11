import 'package:flutter/material.dart';

import '../../app/routes.dart';

/// Utilitário centralizado de navegação dos estandes do EletroLab.
/// Garante que o retorno dos estandes leve sempre com segurança para o Mapa da Feira de Ciências
/// (onde ficam as maquetes dos projetos), evitando que a navegação desça acidentalmente
/// para a tela de carregamento (SplashScreen).
abstract final class StandNavigator {
  /// Retorna com segurança para o Mapa da Feira de Ciências (Routes.home).
  static void navigateBackToFairMap(BuildContext context) {
    bool hasHomeRoute = false;

    Navigator.of(context).popUntil((route) {
      if (route.settings.name == Routes.home) {
        hasHomeRoute = true;
        return true;
      }
      return route.isFirst;
    });

    if (!hasHomeRoute) {
      Navigator.of(context).pushReplacementNamed(Routes.home);
    }
  }
}
