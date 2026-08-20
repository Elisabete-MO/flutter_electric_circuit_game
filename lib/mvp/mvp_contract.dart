enum MvpAsset {
  batteryPhysical,
  switchOpenPhysical,
  switchClosedPhysical,
  lampOffPhysical,
  lampOnPhysical,
  resistorPhysical,
  batterySymbol,
  batteryVerticalPosUpSymbol,
  batteryVerticalPosDownSymbol,
  switchSymbol,
  switchOpenSymbol,
  switchClosedSymbol,
  lampSymbol,
  resistorSymbol,
  energyDot,
  woodTableBackground,
  workshopBackground,
}

const mvpAssetPaths = <MvpAsset, String>{
  MvpAsset.batteryPhysical:
      'docs/EletroLab_AssetPack_v1/assets/components/battery_dc.webp',
  MvpAsset.switchOpenPhysical:
      'docs/EletroLab_AssetPack_v1/assets/components/switch_open.webp',
  MvpAsset.switchClosedPhysical:
      'docs/EletroLab_AssetPack_v1/assets/components/switch_closed.webp',
  MvpAsset.lampOffPhysical:
      'docs/EletroLab_AssetPack_v1/assets/components/lamp_off.webp',
  MvpAsset.lampOnPhysical:
      'docs/EletroLab_AssetPack_v1/assets/components/lamp_on.webp',
  MvpAsset.resistorPhysical:
      'docs/EletroLab_AssetPack_v1/assets/components/resistor.webp',
  MvpAsset.batterySymbol:
      'docs/EletroLab_AssetPack_v1/assets/symbols/battery_dc.svg',
  MvpAsset.batteryVerticalPosUpSymbol:
      'docs/EletroLab_AssetPack_v1/assets/symbols/battery_dc_vertical_pos_up.svg',
  MvpAsset.batteryVerticalPosDownSymbol:
      'docs/EletroLab_AssetPack_v1/assets/symbols/battery_dc_vertical_pos_down.svg',
  MvpAsset.switchSymbol:
      'docs/EletroLab_AssetPack_v1/assets/symbols/switch_open.svg',
  MvpAsset.switchOpenSymbol:
      'docs/EletroLab_AssetPack_v1/assets/symbols/switch_open.svg',
  MvpAsset.switchClosedSymbol:
      'docs/EletroLab_AssetPack_v1/assets/symbols/switch_closed.svg',
  MvpAsset.lampSymbol: 'docs/EletroLab_AssetPack_v1/assets/symbols/lamp.svg',
  MvpAsset.resistorSymbol:
      'docs/EletroLab_AssetPack_v1/assets/symbols/resistor.svg',
  MvpAsset.energyDot:
      'docs/EletroLab_AssetPack_v1/assets/effects/energy_dot.webp',
  MvpAsset.woodTableBackground:
      'docs/EletroLab_AssetPack_v1/assets/ui/wood_table_texture.png',
  MvpAsset.workshopBackground:
      'docs/EletroLab_AssetPack_v1/assets/ui/workshop_background.png',
};

enum SymbolType {
  batteryPosUp,
  batteryPosDown,
  batteryHorizontal,
  switchSpst,
  lamp,
}

enum SlotId { battery, switchSpst, lamp }

enum ValidationStatus { idle, incomplete, incorrect, correct }

const expectedSymbolBySlot = <SlotId, SymbolType>{
  SlotId.battery: SymbolType.batteryPosUp,
  SlotId.switchSpst: SymbolType.switchSpst,
  SlotId.lamp: SymbolType.lamp,
};

const voltageVolts = 6.0;
const lampResistanceOhms = 12.0;

const analysisOptions = <String>['0,5 A', '2,0 A', '1,5 A'];
const correctAnalysisOption = '0,5 A';

double currentAmpsForSwitch(bool isSwitchClosed) {
  return isSwitchClosed ? voltageVolts / lampResistanceOhms : 0.0;
}

