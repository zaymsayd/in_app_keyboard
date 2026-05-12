import 'package:flutter/material.dart';
import 'keyboard_widget.dart';
import 'keyboard_layout.dart';

/// A manager that should wrap your app or screen to handle the in-app keyboard globally.
class InAppKeyboardManager extends StatefulWidget {
  final Widget child;
  /// The layout of the keyboard for small screens. 
  /// Defaults to [InAppKeyboardLayout.numeric].
  final List<List<String>>? layout;
  
  /// Optional layout specifically for large screens. 
  /// Defaults to [InAppKeyboardLayout.numericLarge].
  final List<List<String>>? largeScreenLayout;
  
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final double keyboardHeight;
  final BoxDecoration? keyDecoration;
  final EdgeInsetsGeometry keyPadding;
  final bool enableHapticFeedback;

  /// The maximum width the keyboard will take on large screens.
  final double maxKeyboardWidth;

  /// The width threshold to switch between small and large screen layouts.
  final double largeScreenThreshold;

  const InAppKeyboardManager({
    super.key,
    required this.child,
    this.layout,
    this.largeScreenLayout,
    this.backgroundColor,
    this.textStyle,
    this.keyboardHeight = 280,
    this.keyDecoration,
    this.keyPadding = const EdgeInsets.all(4.0),
    this.enableHapticFeedback = true,
    this.maxKeyboardWidth = 500,
    this.largeScreenThreshold = 600,
  });

  static InAppKeyboardManagerState? of(BuildContext context) {
    return context.findAncestorStateOfType<InAppKeyboardManagerState>();
  }

  @override
  State<InAppKeyboardManager> createState() => InAppKeyboardManagerState();
}

class InAppKeyboardManagerState extends State<InAppKeyboardManager> {
  TextEditingController? _activeController;
  List<List<String>>? _activeLayout;
  VoidCallback? _activeOnSubmitted;
  bool _isVisible = false;

  void registerController(
    TextEditingController controller, {
    List<List<String>>? layout,
    VoidCallback? onSubmitted,
  }) {
    setState(() {
      _activeController = controller;
      _activeLayout = layout;
      _activeOnSubmitted = onSubmitted;
      _isVisible = true;
    });
  }

  void unregisterController(TextEditingController controller) {
    if (_activeController == controller) {
      setState(() {
        _isVisible = false;
        _activeController = null;
        _activeLayout = null;
        _activeOnSubmitted = null;
      });
    }
  }

  void hideKeyboard() {
    setState(() {
      _isVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > widget.largeScreenThreshold;

        return Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                behavior: HitTestBehavior.translucent,
                child: widget.child,
              ),
            ),
            if (_isVisible && _activeController != null)
              _buildKeyboardContainer(isLargeScreen),
          ],
        );
      },
    );
  }

  Widget _buildKeyboardContainer(bool isLargeScreen) {
    final effectiveLayout = _activeLayout ??
        (isLargeScreen
            ? (widget.largeScreenLayout ?? InAppKeyboardLayout.numericLarge)
            : (widget.layout ?? InAppKeyboardLayout.numeric));

    Widget keyboard = InAppKeyboard(
      controller: _activeController!,
      layout: effectiveLayout,
      backgroundColor: widget.backgroundColor,
      textStyle: widget.textStyle,
      height: widget.keyboardHeight,
      keyDecoration: widget.keyDecoration,
      keyPadding: widget.keyPadding,
      enableHapticFeedback: widget.enableHapticFeedback,
      onKeyPressed: (_) {},
      onSubmitted: _activeOnSubmitted,
    );

    if (isLargeScreen) {
      // For large screens, center the keyboard and constrain its width
      return Container(
        color: widget.backgroundColor ?? Colors.grey[200],
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: widget.maxKeyboardWidth),
            child: keyboard,
          ),
        ),
      );
    }

    // For small screens, it remains full width
    return keyboard;
  }
}
