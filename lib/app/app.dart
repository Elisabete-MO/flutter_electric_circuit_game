import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../core/ui_scale.dart';
import '../state/settings_controller.dart';
import 'routes.dart';
import 'theme.dart';

import '../widgets/landscape_guard.dart';

/// Widget raiz do EletroLab.
class EletroLabApp extends ConsumerWidget {
  const EletroLabApp({
    super.key,
    this.initialRoute,
  });

  /// Rota inicial opcional (padrão: Routes.splash)
  final String? initialRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);

    return MaterialApp(
      title: 'EletroLab',
      debugShowCheckedModeBanner: false,
      theme: EletroLabTheme.light,
      darkTheme: EletroLabTheme.dark,
      themeMode: settings.themeMode.toFlutterThemeMode,
      locale: Locale(settings.locale),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: initialRoute ?? Routes.splash,
      onGenerateInitialRoutes: (initialRoute) {
        if (initialRoute == Routes.splash || initialRoute == '/') {
          return [
            MaterialPageRoute(
              settings: const RouteSettings(name: Routes.splash),
              builder: Routes.all[Routes.splash]!,
            ),
          ];
        }
        if (initialRoute != Routes.home &&
            initialRoute != Routes.menu &&
            Routes.all.containsKey(initialRoute)) {
          return [
            MaterialPageRoute(
              settings: const RouteSettings(name: Routes.home),
              builder: Routes.all[Routes.home]!,
            ),
            MaterialPageRoute(
              settings: RouteSettings(name: initialRoute),
              builder: Routes.all[initialRoute]!,
            ),
          ];
        }
        return [
          MaterialPageRoute(
            settings: RouteSettings(name: initialRoute),
            builder: Routes.all[initialRoute] ?? Routes.all[Routes.splash]!,
          ),
        ];
      },
      routes: Routes.all,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(context.uiScale.textScale),
          ),
          child: LandscapeGuard(child: child!),
        );
      },
    );
  }
}
