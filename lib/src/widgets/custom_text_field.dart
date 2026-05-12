import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/keyboard_controller.dart';
import '../models/keyboard_config.dart';

class InAppTextField extends ConsumerStatefulWidget {
  final TextEditingController? controller;
  final InputDecoration decoration;
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
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool enabled;
  final TextStyle? style;

  const InAppTextField({
    super.key,
    this.controller,
    this.decoration = const InputDecoration(),
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
    }
  }

  void _registerField() {
    if (!_focusNode.hasFocus) _focusNode.requestFocus();
    _doRegister();
  }

  void _doRegister() {
    final isFloating = MediaQuery.of(context).size.width > 600;
    final onSubmitted = widget.onSubmitted != null
        ? () => widget.onSubmitted!(_controller.text)
        : null;
    ref.read(keyboardControllerProvider.notifier).registerField(
          _controller,
          type: widget.keyboardType,
          layout: widget.layout,
          isFloating: isFloating,
          onSubmitted: onSubmitted,
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
