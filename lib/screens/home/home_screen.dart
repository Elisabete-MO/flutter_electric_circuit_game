import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/routes.dart';
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
    } else if (stand.number == 1) {
      Navigator.of(context).pushNamed(Routes.firstBench);
    } else if (stand.number == 3 || stand.id == 'liga_desliga') {
      Navigator.of(context).pushNamed(Routes.ligaDesliga);
    } else if (stand.number == 4 || stand.id == 'ruas_maquete') {
      Navigator.of(context).pushNamed(Routes.ruasMaquete);
    } else if (stand.number == 5 || stand.id == 'letreros_led') {
      Navigator.of(context).pushNamed(Routes.letrerosLed);
    } else {
      Navigator.of(context).pushNamed(Routes.firstBench);
    }
  }

  void _onTapMaqueteColetiva() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF10B981), width: 2),
          ),
          title: const Row(
            children: [
              Icon(Icons.location_city_rounded, color: Color(0xFF10B981), size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Maquete Coletiva',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Integração Final da Comunidade',
                style: TextStyle(
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Conclua as missões dos estandes da Feira de Ciências para energizar a maquete coletiva completa do bairro com todas as equipes!',
                style: TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Entendido',
                style: TextStyle(
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
            bottom: 24,
            right: 24,
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
                  const SizedBox(width: 12),
                  // Ícone de Configurações
                  _buildFloatingIconButton(
                    context,
                    icon: Icons.settings_rounded,
                    tooltip: 'Configurações',
                    accentColor: Colors.white,
                    onTap: () => Navigator.of(context).pushNamed(Routes.settings),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Botão Flutuante Circular com estilo Glassmorphic
  Widget _buildFloatingIconButton(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xEE03281E),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: accentColor,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
