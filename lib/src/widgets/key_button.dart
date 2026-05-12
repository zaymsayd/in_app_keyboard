import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/key_model.dart';
import '../models/keyboard_state.dart';
import '../providers/keyboard_controller.dart';
import '../services/keyboard_overlay_service.dart';

class KeyButton extends ConsumerStatefulWidget {
  final KeyModel keyModel;
  final VoidCallback onTap;
  final bool isUppercase;

  const KeyButton({
    super.key,
    required this.keyModel,
    required this.onTap,
    this.isUppercase = false,
  });

  @override
  ConsumerState<KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends ConsumerState<KeyButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  Timer? _longPressTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    _longPressTimer?.cancel();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
    
    if (widget.keyModel.action == KeyAction.backspace) {
      _startContinuousDelete();
    } else if (widget.keyModel.alternates != null) {
      _startLongPressExtension(details.globalPosition);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    _stopTimers();
    
    if (!KeyboardOverlayService.instance.isPopupShowing) {
      HapticFeedback.lightImpact();
      widget.onTap();
    }
  }

  void _handleTapCancel() {
    _controller.reverse();
    _stopTimers();
  }

  void _startContinuousDelete() {
    _longPressTimer = Timer(const Duration(milliseconds: 500), () {
      _longPressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
        HapticFeedback.selectionClick();
        widget.onTap();
      });
    });
  }

  void _startLongPressExtension(Offset globalPosition) {
    _longPressTimer = Timer(const Duration(milliseconds: 500), () {
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
        ref.read(keyboardControllerProvider.notifier).onKeyTap(
          KeyModel(label: value, value: value),
        );
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
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Center(
              child: _buildLabel(keyboardState),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(KeyboardState state) {
    if (widget.keyModel.icon != null) {
      return Icon(widget.keyModel.icon, size: 20);
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
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Color _getKeyColor(KeyboardState state) {
    if (widget.keyModel.action == KeyAction.shift) {
      if (state.shiftState == ShiftState.on) return Colors.blue.withOpacity(0.1);
      if (state.shiftState == ShiftState.capsLock) return Colors.blue.withOpacity(0.2);
    }
    if (widget.keyModel.type == KeyType.action) {
      return Colors.grey[300]!;
    }
    return Colors.white;
  }
}
