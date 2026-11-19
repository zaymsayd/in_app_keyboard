import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/keyboard_action_type.dart';
import '../models/keyboard_config.dart';
import '../providers/keyboard_controller.dart';

class InAppTextField extends ConsumerStatefulWidget {
  final TextEditingController? controller;
  final InputDecoration? decoration;
  final KeyboardType keyboardType;
  final LayoutVariant? layout;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool? obscureText;

  // Extended passthrough params
  final int maxLines;
  final int minLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final KeyboardActionType? action;
  final VoidCallback? onSubmit;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool enabled;
  final TextStyle? style;

  const InAppTextField({
    super.key,
    this.controller,
    this.decoration,
    this.keyboardType = KeyboardType.text,
    this.layout,
    this.focusNode,
    this.autofocus = false,
    this.obscureText,
    this.maxLines = 1,
    this.minLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.action,
    this.onSubmit,
    this.onNext,
    this.onPrevious,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.style,
  });

  @override
  ConsumerState<InAppTextField> createState() => _InAppTextFieldState();
}

class _InAppTextFieldState extends ConsumerState<InAppTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  String _lastText = '';

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _lastText = _controller.text;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(InAppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller.removeListener(_onControllerChanged);
      if (oldWidget.controller == null) _controller.dispose();
      _controller = widget.controller ?? TextEditingController();
      _lastText = _controller.text;
      _controller.addListener(_onControllerChanged);
    }
    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode.removeListener(_onFocusChange);
      if (oldWidget.focusNode == null) _focusNode.dispose();
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_onFocusChange);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.removeListener(_onControllerChanged);
    if (widget.focusNode == null) _focusNode.dispose();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  // Only fires onChanged when text content actually changes (not cursor moves)
  void _onControllerChanged() {
    if (_controller.text != _lastText) {
      _lastText = _controller.text;
      widget.onChanged?.call(_controller.text);
    }
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _doRegister();
      // Delay allows the keyboard to slide in before we ensure the field is visible.
      Future.delayed(const Duration(milliseconds: 300), _scrollToField);
    }
  }

  void _registerField() {
    if (!_focusNode.hasFocus) _focusNode.requestFocus();
    _doRegister();
    // Also trigger scroll on tap to ensure visibility even if already focused.
    Future.delayed(const Duration(milliseconds: 300), _scrollToField);
  }

  void _scrollToField() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        alignment: 0.3,
      );
    });
  }

  KeyboardActionType get _effectiveAction {
    if (widget.action != null) return widget.action!;
    return switch (widget.keyboardType) {
      KeyboardType.multiline => KeyboardActionType.newline,
      KeyboardType.url => KeyboardActionType.go,
      _ => KeyboardActionType.done,
    };
  }

  void _doRegister() {
    final isFloating = MediaQuery.of(context).size.width > 600;
    final effectiveAction = _effectiveAction;

    final VoidCallback? actionCallback = switch (effectiveAction) {
      KeyboardActionType.next =>
        widget.onNext ?? () => FocusScope.of(context).nextFocus(),
      KeyboardActionType.previous =>
        widget.onPrevious ?? () => FocusScope.of(context).previousFocus(),
      KeyboardActionType.newline => null,
      _ => () {
        widget.onSubmit?.call();
        widget.onSubmitted?.call(_controller.text);
      },
    };

    ref.read(keyboardControllerProvider.notifier).registerField(
      _controller,
      type: widget.keyboardType,
      layout: widget.layout,
      isFloating: isFloating,
      actionType: effectiveAction,
      onAction: actionCallback,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(keyboardControllerProvider);
    final isCurrentField = state.activeController == _controller;

    final config = KeyboardConfig.fromType(widget.keyboardType);
    final obscureText = widget.obscureText ?? config.obscureText;
    final textDirection = isCurrentField ? state.textDirection : null;

    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      readOnly: true,
      showCursor: true,
      obscureText: obscureText,
      decoration: widget.decoration,
      autofocus: widget.autofocus,
      textDirection: textDirection,
      // obscureText forces single line
      maxLines: obscureText ? 1 : widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
      textCapitalization: widget.textCapitalization,
      textInputAction: widget.textInputAction,
      enabled: widget.enabled,
      style: widget.style,
      onSubmitted: widget.onSubmitted,
      onTap: _registerField,
    );
  }
}
