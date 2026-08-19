import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'mvp_contract.dart';

class ActivityController extends ChangeNotifier {
  bool _isSwitchClosed = false;
  final Map<SlotId, SymbolType?> _slotOccupancy = {
    for (final slot in SlotId.values) slot: null,
  };
  ValidationStatus _validationStatus = ValidationStatus.idle;
  Set<SlotId> _highlightedSlots = <SlotId>{};

  bool get isSwitchClosed => _isSwitchClosed;
  double get currentAmps => currentAmpsForSwitch(_isSwitchClosed);
  Map<SlotId, SymbolType?> get slotOccupancy =>
      UnmodifiableMapView(_slotOccupancy);
  ValidationStatus get validationStatus => _validationStatus;
  Set<SlotId> get highlightedSlots => UnmodifiableSetView(_highlightedSlots);

  void setSwitchClosed(bool isClosed) {
    if (_isSwitchClosed == isClosed) {
      return;
    }

    _isSwitchClosed = isClosed;
    notifyListeners();
  }

  void toggleSwitch() => setSwitchClosed(!_isSwitchClosed);

  void setSlotSymbol(SlotId slot, SymbolType? symbol) {
    if (symbol != null) {
      moveSymbol(symbol, slot);
      return;
    }

    if (_slotOccupancy[slot] == null) {
      return;
    }

    _slotOccupancy[slot] = null;
    _validationStatus = ValidationStatus.idle;
    _highlightedSlots = <SlotId>{};
    notifyListeners();
  }

  SlotId? slotForSymbol(SymbolType symbol) {
    for (final entry in _slotOccupancy.entries) {
      if (entry.value == symbol) {
        return entry.key;
      }
    }
    return null;
  }

  void moveSymbol(SymbolType symbol, SlotId targetSlot) {
    final sourceSlot = slotForSymbol(symbol);
    if (sourceSlot == targetSlot) {
      return;
    }

    final targetSymbol = _slotOccupancy[targetSlot];
    if (sourceSlot != null) {
      _slotOccupancy[sourceSlot] = targetSymbol;
    }
    _slotOccupancy[targetSlot] = symbol;
    _validationStatus = ValidationStatus.idle;
    _highlightedSlots = <SlotId>{};
    notifyListeners();
  }

  void verifyDiagram() {
    final emptySlots = _slotOccupancy.entries
        .where((entry) => entry.value == null)
        .map((entry) => entry.key)
        .toSet();

    if (emptySlots.isNotEmpty) {
      _validationStatus = ValidationStatus.incomplete;
      _highlightedSlots = emptySlots;
    } else {
      final incorrectSlots = expectedSymbolBySlot.entries
          .where((entry) => _slotOccupancy[entry.key] != entry.value)
          .map((entry) => entry.key)
          .toSet();
      _validationStatus = incorrectSlots.isEmpty
          ? ValidationStatus.correct
          : ValidationStatus.incorrect;
      _highlightedSlots = incorrectSlots;
    }

    notifyListeners();
  }
}
