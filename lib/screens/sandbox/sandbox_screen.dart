import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/section_placeholder.dart';

/// Seção "Banqueta" — laboratório livre (Fases 3 a 7).
class SandboxScreen extends StatelessWidget {
  const SandboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SectionPlaceholder(
      title: l10n.sandboxTitle,
      icon: Icons.biotech_rounded,
      description: l10n.sandboxDesc,
    );
  }
}