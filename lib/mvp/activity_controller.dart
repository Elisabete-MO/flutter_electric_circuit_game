import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'mvp_contract.dart';

class ActivityController extends ChangeNotifier {
  bool _isSwitchClosed = false;
  final Map<SlotId, SymbolType?> _slotOccupancy = {
    for (final slot in SlotId.values) slot: null,
  };
  final Map<SlotId, int> _slotRotations = {
    for (final slot in SlotId.values) slot: 0,
  };
  final List<Map<SlotId, SymbolType?>> _history = [];
  SlotId? _selectedSlot;
  ValidationStatus _validationStatus = ValidationStatus.idle;
  Set<SlotId> _highlightedSlots = <SlotId>{};
  String? _selectedAnalysisOption;

  bool get isSwitchClosed => _isSwitchClosed;
  double get currentAmps => currentAmpsForSwitch(_isSwitchClosed);
  Map<SlotId, SymbolType?> get slotOccupancy =>
      UnmodifiableMapView(_slotOccupancy);
  Map<SlotId, int> get slotRotations => UnmodifiableMapView(_slotRotations);
  SlotId? get selectedSlot => _selectedSlot;
  ValidationStatus get validationStatus => _validationStatus;
  Set<SlotId> get highlightedSlots => UnmodifiableSetView(_highlightedSlots);
  bool get canUndo => _history.isNotEmpty;
  String? get selectedAnalysisOption => _selectedAnalysisOption;
  bool get isAnalysisAnswerCorrect =>
      _selectedAnalysisOption == correctAnalysisOption;

  void selectAnalysisOption(String option) {
    if (_selectedAnalysisOption == option) return;
    _selectedAnalysisOption = option;
    notifyListeners();
  }

  void selectSlot(SlotId? slot) {
    if (_selectedSlot == slot) return;
    _selectedSlot = slot;
    notifyListeners();
  }

  void _saveSnapshot() {
    _history.add(Map<SlotId, SymbolType?>.from(_slotOccupancy));
  }

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

    _saveSnapshot();
    _slotOccupancy[slot] = null;
    _highlightedSlots = <SlotId>{};
    verifyDiagram();
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

    _saveSnapshot();
    final targetSymbol = _slotOccupancy[targetSlot];
    if (sourceSlot != null) {
      _slotOccupancy[sourceSlot] = targetSymbol;
    }
    _slotOccupancy[targetSlot] = symbol;
    _selectedSlot = targetSlot;
    _highlightedSlots = <SlotId>{};
    verifyDiagram();
  }

  void rotateSelectedSlot() {
    if (_selectedSlot != null && _slotOccupancy[_selectedSlot] != null) {
      _slotRotations[_selectedSlot!] =
          ((_slotRotations[_selectedSlot!] ?? 0) + 90) % 360;
      verifyDiagram();
    } else {
      // Rotate all non-null slots if no slot is selected
      for (final slot in SlotId.values) {
        if (_slotOccupancy[slot] != null) {
          _slotRotations[slot] = ((_slotRotations[slot] ?? 0) + 90) % 360;
        }
      }
      verifyDiagram();
    }
  }

  void undo() {
    if (_history.isEmpty) return;
    final previousState = _history.removeLast();
    _slotOccupancy.clear();
    _slotOccupancy.addAll(previousState);
    _highlightedSlots = <SlotId>{};
    verifyDiagram();
  }

  void clear() {
    if (_slotOccupancy.values.every((symbol) => symbol == null)) return;
    _saveSnapshot();
    for (final slot in SlotId.values) {
      _slotOccupancy[slot] = null;
    }
    _selectedSlot = null;
    _highlightedSlots = <SlotId>{};
    _selectedAnalysisOption = null;
    verifyDiagram();
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
