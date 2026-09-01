import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../models/stand_data.dart';
import 'widgets/science_fair_map.dart';

/// Tela inicial gamificada do EletroLab: Mapa da Feira de Ciências da Comunidade no Ginásio.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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
      Navigator.of(context).pushNamed(Routes.firstSteps);
    } else {
      Navigator.of(context).pushNamed(Routes.firstSteps);
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
      backgroundColor: const Color(0xFF071828),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Barra Superior (Header Bar)
            _buildHeader(context),

            // 2. Área Principal: Mapa da Feira preenchendo todo o espaço com o fundo
            Expanded(
              child: ScienceFairMap(
                stands: _stands,
                selectedStand: _selectedStand,
                onSelectStand: _onSelectStand,
                onStartMission: _onStartMission,
                onCloseCard: _onCloseCard,
                onTapMaqueteColetiva: _onTapMaqueteColetiva,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF0B2A4A),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF1E3A5F),
            width: 1.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // High-Contrast Header Logo
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bolt_rounded,
                color: EletroLabColors.neonCyan,
                size: 30,
                shadows: [
                  Shadow(
                    color: EletroLabColors.neonCyan.withValues(alpha: 0.6),
                    blurRadius: 10,
                  ),
                ],
              ),
              const SizedBox(width: 8),
              const Text(
                'EletroLab',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),

          // Título central
          const Expanded(
            child: Text(
              'Feira de Ciências da Comunidade · 1ª fase',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Color(0xFFE2E8F0),
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Ícone de Configurações
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed(Routes.settings),
            tooltip: 'Configurações',
            icon: const Icon(
              Icons.settings_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
