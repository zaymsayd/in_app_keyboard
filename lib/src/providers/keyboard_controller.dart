import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/keyboard_config.dart';
import '../models/keyboard_state.dart';
import '../models/key_model.dart';
import '../services/input_handler_service.dart';

part 'keyboard_controller.g.dart';

@Riverpod(keepAlive: true)
class KeyboardController extends _$KeyboardController {
  /// Stored outside immutable state so it never triggers unnecessary rebuilds.
  VoidCallback? _onSubmitted;

  @override
  KeyboardState build() => const KeyboardState();

  void registerField(
    TextEditingController controller, {
    KeyboardType? type,
    LayoutVariant? layout,
    bool isFloating = false,
    VoidCallback? onSubmitted,
  }) {
    _onSubmitted = onSubmitted;
    final effectiveType = type ?? state.currentType;
    final config = KeyboardConfig.fromType(effectiveType);

    state = state.copyWith(
      activeController: controller,
      currentType: effectiveType,
      currentLayout: layout ?? config.defaultLayout,
      isVisible: true,
      isFloating: isFloating,
    );
  }

  void unregisterField(TextEditingController controller) {
    if (state.activeController == controller) {
      _onSubmitted = null;
      state = state.copyWith(isVisible: false, activeController: null);
    }
  }

  void hide() {
    _onSubmitted = null;
    state = state.copyWith(isVisible: false);
  }

  void onKeyTap(KeyModel key) {
    final controller = state.activeController;
    if (controller == null) return;

    switch (key.action) {
      case KeyAction.none:
        String text = key.value ?? '';

        final allowed = state.config.allowedCharacters;
        if (allowed != null && !allowed.contains(text.toLowerCase())) return;

        if (state.isUppercase) text = text.toUpperCase();
        InputHandlerService.insertText(controller, text);

        if (state.shiftState == ShiftState.on) {
          state = state.copyWith(shiftState: ShiftState.off);
        }

      case KeyAction.backspace:
        InputHandlerService.backspace(controller);

      case KeyAction.space:
        InputHandlerService.insertText(controller, ' ');

      case KeyAction.enter:
        if (_onSubmitted != null) {
          _onSubmitted!();
          hide();
        } else {
          InputHandlerService.insertText(controller, '\n');
        }

      case KeyAction.shift:
        _handleShiftTap();

      case KeyAction.capsLock:
        _handleShiftTap();

      case KeyAction.switchLayout:
        if (key.actionPayload is LayoutVariant) {
          state = state.copyWith(currentLayout: key.actionPayload as LayoutVariant);
        }

      case KeyAction.language:
        final next = state.currentLayout == LayoutVariant.qwerty
            ? LayoutVariant.arabic
            : LayoutVariant.qwerty;
        state = state.copyWith(currentLayout: next);

      case KeyAction.dismiss:
        hide();
    }
  }

  void _handleShiftTap() {
    final now = DateTime.now();
    final last = state.lastShiftTap;

    if (last != null && now.difference(last).inMilliseconds < 300) {
      state = state.copyWith(shiftState: ShiftState.capsLock, lastShiftTap: null);
    } else {
      switch (state.shiftState) {
        case ShiftState.off:
          state = state.copyWith(shiftState: ShiftState.on, lastShiftTap: now);
        case ShiftState.on:
          state = state.copyWith(shiftState: ShiftState.off, lastShiftTap: null);
        case ShiftState.capsLock:
          state = state.copyWith(shiftState: ShiftState.off, lastShiftTap: null);
      }
    }
  }

  void updatePosition(Offset newPosition, Size screenSize, Size keyboardSize) {
    double x = newPosition.dx.clamp(0, screenSize.width - keyboardSize.width);
    double y = newPosition.dy.clamp(0, screenSize.height - keyboardSize.height);
    state = state.copyWith(position: Offset(x, y));
  }

  void toggleFloating(bool isFloating) {
    state = state.copyWith(isFloating: isFloating);
  }
}
