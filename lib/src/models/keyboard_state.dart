import 'package:flutter/material.dart';
import 'keyboard_config.dart';

enum ShiftState { off, on, capsLock }

class KeyboardState {
  final bool isVisible;
  final KeyboardType currentType;
  final LayoutVariant currentLayout;
  final ShiftState shiftState;
  final DateTime? lastShiftTap;
  final Offset? position; 
  final bool isFloating;
  final double width;
  final TextEditingController? activeController;

  const KeyboardState({
    this.isVisible = false,
    this.currentType = KeyboardType.text,
    this.currentLayout = LayoutVariant.qwerty,
    this.shiftState = ShiftState.off,
    this.lastShiftTap,
    this.position,
    this.isFloating = false,
    this.width = double.infinity,
    this.activeController,
  });

  KeyboardState copyWith({
    bool? isVisible,
    KeyboardType? currentType,
    LayoutVariant? currentLayout,
    ShiftState? shiftState,
    DateTime? lastShiftTap,
    Offset? position,
    bool? isFloating,
    double? width,
    TextEditingController? activeController,
  }) {
    return KeyboardState(
      isVisible: isVisible ?? this.isVisible,
      currentType: currentType ?? this.currentType,
      currentLayout: currentLayout ?? this.currentLayout,
      shiftState: shiftState ?? this.shiftState,
      lastShiftTap: lastShiftTap ?? this.lastShiftTap,
      position: position ?? this.position,
      isFloating: isFloating ?? this.isFloating,
      width: width ?? this.width,
      activeController: activeController ?? this.activeController,
    );
  }

  /// Default position for floating keyboard (centered-ish)
  Offset get effectivePosition => position ?? const Offset(100, 100);

  KeyboardConfig get config => KeyboardConfig.fromType(currentType);

  bool get isUppercase => shiftState != ShiftState.off;

  TextDirection get textDirection =>
      currentLayout == LayoutVariant.arabic ? TextDirection.rtl : TextDirection.ltr;
}
