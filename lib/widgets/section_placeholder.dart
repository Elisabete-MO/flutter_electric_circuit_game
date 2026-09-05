import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'tech_grid_background.dart';

/// Tela provisória exibida enquanto uma seção ainda não é implementada.
///
/// Mantém a navegação funcional durante o desenvolvimento incremental.
class SectionPlaceholder extends StatelessWidget {
  const SectionPlaceholder({
    super.key,
    required this.title,
    required this.icon,
    required this.description,
  });

  final String title;
  final IconData icon;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: TechGridBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Chip(
                  label: Text(
                    Localizations.of<AppLocalizations>(context, AppLocalizations)?.underConstruction ?? 'Em construção',
                  ),
                  avatar: const Icon(Icons.construction_rounded, size: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }
}