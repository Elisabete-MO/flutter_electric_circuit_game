import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../state/settings_controller.dart';
import 'routes.dart';
import 'theme.dart';

/// Widget raiz do EletroLab.
class EletroLabApp extends ConsumerWidget {
  const EletroLabApp({super.key});

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
      initialRoute: Routes.home,
      routes: Routes.all,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(1.05),
        ),
        child: child!,
      ),
    );
  }
}
