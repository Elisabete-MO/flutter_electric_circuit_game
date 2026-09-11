import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/routes.dart';
import '../../core/ui_scale.dart';
import '../../models/stand_data.dart';
import 'widgets/experimental_horizontal_map.dart';
import 'widgets/science_fair_map.dart';

/// Tela inicial gamificada do EletroLab: Mapa da Feira de Ciências da Comunidade no Ginásio.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// Flag de controle do Teste de Navegação Horizontal.
  /// Mude para `false` para retornar imediatamente à tela padrão aprovada.
  static const bool useExperimentalHorizontalMap = true;

  late List<StandData> _stands;
  StandData? _selectedStand;

  @override
  void initState() {
    super.initState();
    _stands = StandData.defaultStands;
    // Estande 01 ("Primeiros Passos") vem selecionado por padrão
    _selectedStand = _stands.firstWhere(
      (s) => s.number == 1,
      orElse: () => _stands.first,
    );
  }

  void _onSelectStand(StandData stand) {
    setState(() {
      _selectedStand = stand;
    });
  }

  void _onCloseCard() {
    setState(() {
      _selectedStand = null;
    });
  }

  void _onStartMission(StandData stand) {
    if (stand.isBancadaLivre) {
      Navigator.of(context).pushNamed(Routes.sandbox);
    } else if (stand.number == 1 || stand.id == 'primeiros_passos') {
      Navigator.of(context).pushNamed(Routes.firstSteps);
    } else if (stand.number == 2 || stand.id == 'acende_ai') {
      Navigator.of(context).pushNamed(Routes.secondBench);
    } else if (stand.number == 3 || stand.id == 'liga_desliga') {
      Navigator.of(context).pushNamed(Routes.ligaDesliga);
    } else if (stand.number == 4 || stand.id == 'ruas_maquete') {
      Navigator.of(context).pushNamed(Routes.ruasMaquete);
    } else if (stand.number == 5 || stand.id == 'letreros_led') {
      Navigator.of(context).pushNamed(Routes.letrerosLed);
    } else if (stand.number == 6 ||
        stand.id == 'movimento' ||
        stand.id == 'movimento_miniatura') {
      Navigator.of(context).pushNamed(Routes.movimentoMiniatura);
    } else if (stand.number == 7 || stand.id == 'mede_testa') {
      Navigator.of(context).pushNamed(Routes.medeTestaExplica);
    } else if (stand.number == 8 || stand.id == 'circuito_seguro') {
      Navigator.of(context).pushNamed(Routes.circuitoSeguro);
    } else if (stand.number == 9 || stand.id == 'horta_monitorada') {
      Navigator.of(context).pushNamed(Routes.hortaMonitorada);
    } else if (stand.number == 10 || stand.id == 'portao_escola') {
      Navigator.of(context).pushNamed(Routes.portaoEscola);
    } else if (stand.number == 11 || stand.id == 'praca_maquete') {
      Navigator.of(context).pushNamed(Routes.pracaMaquete);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Estande "${stand.name}" ainda não disponível.',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF1E293B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _onTapMaqueteColetiva() {
    final scale = context.uiScale;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(scale.size(20)),
            side: const BorderSide(color: Color(0xFF10B981), width: 2),
          ),
          title: Row(
            children: [
              Icon(
                Icons.location_city_rounded,
                color: const Color(0xFF10B981),
                size: scale.icon(28),
              ),
              SizedBox(width: scale.spacing(12)),
              Expanded(
                child: Text(
                  'Maquete Coletiva',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: scale.font(20),
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Integração Final da Comunidade',
                style: TextStyle(
                  color: const Color(0xFF10B981),
                  fontWeight: FontWeight.bold,
                  fontSize: scale.font(14),
                ),
              ),
              SizedBox(height: scale.spacing(10)),
              Text(
                'Conclua as missões dos estandes da Feira de Ciências para energizar a maquete coletiva completa do bairro com todas as equipes!',
                style: TextStyle(
                  color: const Color(0xFFCBD5E1),
                  fontSize: scale.font(14),
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Entendido',
                style: TextStyle(
                  color: const Color(0xFF94A3B8),
                  fontWeight: FontWeight.bold,
                  fontSize: scale.font(15),
                ),
              ),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(Routes.pracaMaquete);
              },
              icon: const Icon(Icons.location_city_rounded, size: 18),
              label: Text(
                'ABRIR PRAÇA DA MAQUETE',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: scale.font(14),
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;

    return Scaffold(
      backgroundColor: const Color(0xFF021712), // Fundo escuro esmeralda
      body: Stack(
        children: [
          // 1. Área Principal: Mapa Imersivo da Feira preenchendo toda a tela
          Positioned.fill(
            child: useExperimentalHorizontalMap
                ? ExperimentalHorizontalMap(
                    stands: _stands,
                    selectedStand: _selectedStand,
                    onSelectStand: _onSelectStand,
                    onStartMission: _onStartMission,
                    onCloseCard: _onCloseCard,
                    onTapMaqueteColetiva: _onTapMaqueteColetiva,
                  )
                : ScienceFairMap(
                    stands: _stands,
                    selectedStand: _selectedStand,
                    onSelectStand: _onSelectStand,
                    onStartMission: _onStartMission,
                    onCloseCard: _onCloseCard,
                    onTapMaqueteColetiva: _onTapMaqueteColetiva,
                  ),
          ),

          // 2. Ícones Flutuantes no Canto Inferior Direito (Voltar ao Menu Principal & Configurações)
          Positioned(
            bottom: scale.spacing(24),
            right: scale.spacing(24),
            child: SafeArea(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ícone de Voltar ao Menu Principal
                  _buildFloatingIconButton(
                    context,
                    icon: Icons.home_rounded,
                    tooltip: 'Menu Principal',
                    accentColor: const Color(0xFF10B981),
                    onTap: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(context).pushReplacementNamed(Routes.menu);
                      }
                    },
                  ),
                  SizedBox(width: scale.spacing(14)),
                  // Ícone de Configurações
                  _buildFloatingIconButton(
                    context,
                    icon: Icons.settings_rounded,
                    tooltip: 'Configurações',
                    accentColor: Colors.white,
                    onTap: () =>
                        Navigator.of(context).pushNamed(Routes.settings),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Botão Flutuante Estilizado no padrão Low-Poly 3D
  Widget _buildFloatingIconButton(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    final scale = context.uiScale;
    final double buttonSize = scale.size(54, min: 46, max: 68);
    final double bevel = scale.size(10, min: 8, max: 14);

    return Tooltip(
      message: tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: SizedBox(
          width: buttonSize,
          height: buttonSize + 3.0,
          child: Stack(
            children: [
              // Base 3D inferior
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: buttonSize,
                child: Material(
                  color: const Color(0xFF021B14),
                  shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.circular(bevel),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
              // Face frontal
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: buttonSize,
                child: Material(
                  color: const Color(0xFF063B2C),
                  shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.circular(bevel),
                    side: BorderSide(
                      color: const Color(0xFF10B981).withValues(alpha: 0.8),
                      width: 1.4,
                    ),
                  ),
                  elevation: 3,
                  child: InkWell(
                    onTap: onTap,
                    customBorder: BeveledRectangleBorder(
                      borderRadius: BorderRadius.circular(bevel),
                    ),
                    splashColor: const Color(0xFF10B981).withValues(alpha: 0.3),
                    child: Center(
                      child: Icon(
                        icon,
                        color: accentColor,
                        size: scale.icon(26),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
