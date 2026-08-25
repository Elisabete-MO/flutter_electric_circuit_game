import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../models/settings_model.dart';
import '../../state/settings_controller.dart';
import '../../widgets/eletrolab_logo.dart';
import '../../widgets/tech_grid_background.dart';

/// Tela de configurações do EletroLab.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(settingsControllerProvider.notifier);
    final settings = ref.watch(settingsControllerProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: TechGridBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
          _SettingsSection(
            title: l10n.settingsAppearanceLanguage,
            icon: Icons.palette_outlined,
            children: [
              _SectionTitle(l10n.settingsTheme),
              SegmentedButton<AppThemeMode>(
                segments: [
                  for (final mode in AppThemeMode.values)
                    ButtonSegment(
                      value: mode,
                      label: Text(mode.label),
                    ),
                ],
                selected: {settings.themeMode},
                onSelectionChanged: (selection) =>
                    controller.setThemeMode(selection.first),
              ),
              const SizedBox(height: 16),
              _SectionTitle(l10n.settingsLanguage),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'pt',
                    label: Text('Português'),
                    icon: Icon(Icons.language_rounded, size: 18),
                  ),
                  ButtonSegment(
                    value: 'en',
                    label: Text('English'),
                    icon: Icon(Icons.language_rounded, size: 18),
                  ),
                ],
                selected: {settings.locale},
                onSelectionChanged: (selection) =>
                    controller.setLocale(selection.first),
              ),
            ],
          ),
          _SettingsSection(
            title: l10n.settingsSimulation,
            icon: Icons.electric_bolt_outlined,
            children: [
              _SettingSwitch(
                title: l10n.settingsShowCurrent,
                value: settings.showCurrent,
                onChanged: controller.setShowCurrent,
              ),
              _SettingSwitch(
                title: l10n.settingsShowValues,
                value: settings.showValues,
                onChanged: controller.setShowValues,
              ),
              _SettingSwitch(
                title: l10n.settingsShowGrid,
                value: settings.showGrid,
                onChanged: controller.setShowGrid,
              ),
              _SettingSwitch(
                title: l10n.settingsShowTerminals,
                value: settings.showTerminals,
                onChanged: controller.setShowTerminals,
              ),
              _SettingSwitch(
                title: l10n.settingsAnimateCurrent,
                value: settings.showCurrentAnimation,
                onChanged: controller.setShowCurrentAnimation,
              ),
            ],
          ),
          _SettingsSection(
            title: l10n.settingsAccessibility,
            icon: Icons.accessibility_new_outlined,
            children: [
              _SectionTitle(l10n.settingsUiSize),
              Slider(
                value: settings.interfaceScale.clamp(0.9, 1.3).toDouble(),
                min: 0.9,
                max: 1.3,
                divisions: 8,
                label: '${(settings.interfaceScale * 100).round()}%',
                onChanged: controller.setInterfaceScale,
              ),
              _SettingSwitch(
                title: l10n.settingsHighContrast,
                value: settings.highContrast,
                onChanged: controller.setHighContrast,
              ),
              _SettingSwitch(
                title: l10n.settingsReduceAnimations,
                value: settings.reduceAnimations,
                onChanged: controller.setReduceAnimations,
              ),
            ],
          ),
          _SettingsSection(
            title: l10n.settingsData,
            icon: Icons.storage_outlined,
            children: [
              ListTile(
                leading: const Icon(Icons.restart_alt_rounded),
                title: Text(l10n.settingsRestoreDefaults),
                onTap: () => controller.restoreDefaults(),
              ),
              ListTile(
                leading: const Icon(Icons.delete_sweep_outlined),
                title: Text(l10n.settingsResetProgress),
                subtitle: Text(l10n.settingsResetProgressSubtitle),
                enabled: false,
              ),
            ],
          ),
          const _AboutSection(),
          const SizedBox(height: 24),
        ],
      ),
    ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 22),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _SettingSwitch extends StatelessWidget {
  const _SettingSwitch({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            const EletroLabLogo(),
            const SizedBox(height: 16),
            Text(
              'Laboratório virtual de circuitos elétricos.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Versão 1.0.0',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}