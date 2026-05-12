import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'keyboard_layout.dart';

/// The actual keyboard widget.
class InAppKeyboard extends StatelessWidget {
  final TextEditingController controller;
  final Function(String)? onKeyPressed;
  final VoidCallback? onBackspacePressed;
  final VoidCallback? onSubmitted;
  final List<List<String>>? layout;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final double height;
  final BoxDecoration? keyDecoration;
  final EdgeInsetsGeometry keyPadding;
  final bool enableHapticFeedback;

  const InAppKeyboard({
    super.key,
    required this.controller,
    this.onKeyPressed,
    this.onBackspacePressed,
    this.onSubmitted,
    this.layout,
    this.backgroundColor,
    this.textStyle,
    this.height = 300,
    this.keyDecoration,
    this.keyPadding = const EdgeInsets.all(4.0),
    this.enableHapticFeedback = true,
  });

  void _handleKeyPress(String key) {
    if (enableHapticFeedback) HapticFeedback.lightImpact();

    final text = controller.text;
    final selection = controller.selection.isValid
        ? controller.selection
        : TextSelection.collapsed(offset: text.length);

    final newText = text.replaceRange(
      selection.start,
      selection.end,
      key,
    );

    controller.value = controller.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start + key.length,
      ),
    );

    onKeyPressed?.call(key);
  }

  void _handleBackspace() {
    if (enableHapticFeedback) HapticFeedback.mediumImpact();

    final text = controller.text;
    final selection = controller.selection.isValid
        ? controller.selection
        : TextSelection.collapsed(offset: text.length);

    if (selection.start == 0 && selection.end == 0) return;

    String newText;
    int newOffset;

    if (selection.start != selection.end) {
      newText = text.replaceRange(selection.start, selection.end, '');
      newOffset = selection.start;
    } else {
      newText = text.replaceRange(selection.start - 1, selection.start, '');
      newOffset = selection.start - 1;
    }

    controller.value = controller.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newOffset),
    );

    onBackspacePressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final currentLayout = layout ?? InAppKeyboardLayout.numeric;

    return Material(
      elevation: 8,
      child: Container(
        height: height,
        color: backgroundColor ?? Colors.grey[200],
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: currentLayout.map((row) => _buildRow(row)).toList(),
        ),
      ),
    );
  }

  Widget _buildRow(List<String> keys) {
    return Expanded(
      child: Row(
        children: keys.map((key) {
          if (key == '') {
            return const Expanded(child: SizedBox.shrink());
          }
          return Expanded(
            child: Padding(
              padding: keyPadding,
              child: KeyboardKey(
                label: key,
                onTap: () {
                  if (key == '⌫') {
                    _handleBackspace();
                  } else if (key == '↵') {
                    onSubmitted?.call();
                  } else {
                    _handleKeyPress(key);
                  }
                },
                textStyle: textStyle,
                decoration: keyDecoration,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class KeyboardKey extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final TextStyle? textStyle;
  final BoxDecoration? decoration;

  const KeyboardKey({
    super.key,
    required this.label,
    required this.onTap,
    this.textStyle,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: decoration?.borderRadius is BorderRadius
            ? decoration!.borderRadius as BorderRadius
            : BorderRadius.circular(8),
        child: Container(
          decoration: decoration ??
              BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 2,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
          child: Center(
            child: label == '⌫'
                ? const Icon(Icons.backspace_outlined)
                : label == '↵'
                    ? const Icon(Icons.keyboard_return)
                : label == ' '
                    ? Text(
                        'space',
                        style: textStyle ??
                            const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black54,
                            ),
                      )
                    : Text(
                        label,
                        style: textStyle ??
                            const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
          ),
        ),
      ),
    );
  }
}
