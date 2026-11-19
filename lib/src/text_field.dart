import 'package:flutter/material.dart';
import 'keyboard_layout.dart';
import 'keyboard_manager.dart';

/// A convenience TextField that automatically integrates with [InAppKeyboardManager].
class InAppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final InputDecoration decoration;
  final TextStyle? style;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final InAppKeyboardType keyboardType;
  final bool obscureText;
  final int? maxLines;
  final int? maxLength;
  final TextAlign textAlign;
  final bool? enabled;

  const InAppTextField({
    super.key,
    this.controller,
    this.decoration = const InputDecoration(),
    this.style,
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType = InAppKeyboardType.qwerty,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.textAlign = TextAlign.start,
    this.enabled,
  });

  @override
  State<InAppTextField> createState() => _InAppTextFieldState();
}

class _InAppTextFieldState extends State<InAppTextField> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode.addListener(_handleFocusChange);
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    widget.onChanged?.call(_controller.text);
  }

  void _handleFocusChange() {
    final manager = InAppKeyboardManager.of(context);
    if (manager == null) return;

    if (_focusNode.hasFocus) {
      manager.registerController(
        _controller,
        layout: widget.keyboardType.layout,
        onSubmitted: _handleSubmitted,
      );
    } else {
      manager.unregisterController(_controller);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller.removeListener(_onTextChanged);
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _handleSubmitted() {
    InAppKeyboardManager.of(context)?.hideKeyboard();
    _focusNode.unfocus();
    widget.onSubmitted?.call(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      readOnly: true,
      showCursor: true,
      autofocus: widget.autofocus,
      decoration: widget.decoration,
      style: widget.style,
      obscureText: widget.obscureText,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      textAlign: widget.textAlign,
      enabled: widget.enabled,
    );
  }
}
