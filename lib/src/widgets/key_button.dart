import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/keyboard_action_type.dart';
import '../models/key_model.dart';
import '../models/keyboard_state.dart';
import '../providers/keyboard_controller.dart';
import '../services/keyboard_overlay_service.dart';

class KeyButton extends ConsumerStatefulWidget {
  final KeyModel keyModel;
  final VoidCallback onTap;
  final bool isUppercase;
  final KeyboardActionType? actionType;

  const KeyButton({
    super.key,
    required this.keyModel,
    required this.onTap,
    this.isUppercase = false,
    this.actionType,
  });

  @override
  ConsumerState<KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends ConsumerState<KeyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  Timer? _longPressTimer;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    _longPressTimer?.cancel();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();

    if (widget.keyModel.action == KeyAction.backspace) {
      _startContinuousDelete();
    } else if (widget.keyModel.alternates != null) {
      _startLongPressExtension(details.globalPosition);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    _stopTimers();

    if (!KeyboardOverlayService.instance.isPopupShowing) {
      HapticFeedback.lightImpact();
      widget.onTap();
    }
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
    _stopTimers();
  }

  void _startContinuousDelete() {
    _longPressTimer = Timer(const Duration(milliseconds: 500), () {
      _longPressTimer = Timer.periodic(const Duration(milliseconds: 50), (
        timer,
      ) {
        HapticFeedback.selectionClick();
        widget.onTap();
      });
    });
  }

  void _startLongPressExtension(Offset globalPosition) {
    _longPressTimer = Timer(const Duration(milliseconds: 10), () {
      HapticFeedback.heavyImpact();
      _showExtensionPopup(globalPosition);
    });
  }

  void _showExtensionPopup(Offset globalPosition) {
    final alternates = widget.keyModel.alternates!;

    KeyboardOverlayService.instance.showPopup(
      context: context,
      position: globalPosition,
      items: alternates,
      onSelected: (value) {
        ref
            .read(keyboardControllerProvider.notifier)
            .onKeyTap(KeyModel(label: value, value: value));
        HapticFeedback.mediumImpact();
      },
    );
  }

  void _stopTimers() {
    _longPressTimer?.cancel();
    _longPressTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    final keyboardState = ref.watch(keyboardControllerProvider);

    return Expanded(
      flex: widget.keyModel.flex,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            margin: const EdgeInsets.all(3.0),
            decoration: BoxDecoration(
              color: _getKeyColor(keyboardState),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                if (_isPressed)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                    spreadRadius: 2,
                  )
                else
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 1,
                    offset: const Offset(0, 1),
                  ),
              ],
            ),
            child: Center(child: _buildLabel(keyboardState)),
          ),
        ),
      ),
    );
  }

  bool _isHighlightedEnter() {
    if (widget.keyModel.action != KeyAction.enter || widget.actionType == null)
      return false;
    final t = widget.actionType!;
    return t == KeyboardActionType.done ||
        t == KeyboardActionType.go ||
        t == KeyboardActionType.search ||
        t == KeyboardActionType.send;
  }

  Widget _buildLabel(KeyboardState state) {
    if (widget.keyModel.icon != null) {
      return Icon(
        widget.keyModel.icon,
        size: 20,
        color: _isHighlightedEnter() ? Colors.white : null,
      );
    }

    if (widget.keyModel.action == KeyAction.backspace) {
      return const Icon(Icons.backspace_outlined, size: 20);
    }

    if (widget.keyModel.action == KeyAction.shift) {
      return Icon(
        state.shiftState == ShiftState.capsLock
            ? Icons.keyboard_capslock
            : Icons.keyboard_arrow_up,
        size: 24,
        color: state.shiftState != ShiftState.off ? Colors.blue : null,
      );
    }

    String label = widget.keyModel.label;
    if (widget.isUppercase && widget.keyModel.type == KeyType.alpha) {
      label = label.toUpperCase();
    }

    return Text(
      label,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: _isHighlightedEnter() ? Colors.white : null,
      ),
    );
  }

  Color _getKeyColor(KeyboardState state) {
    if (_isPressed) {
      return Colors.grey[400]!;
    }
    if (widget.keyModel.action == KeyAction.shift) {
      if (state.shiftState == ShiftState.on)
        return Colors.blue.withValues(alpha: 0.1);
      if (state.shiftState == ShiftState.capsLock)
        return Colors.blue.withValues(alpha: 0.2);
    }
    if (_isHighlightedEnter()) {
      return Theme.of(context).colorScheme.primary;
    }
    if (widget.keyModel.type == KeyType.action) {
      return Colors.grey[300]!;
    }
    return Colors.white;
  }
}
