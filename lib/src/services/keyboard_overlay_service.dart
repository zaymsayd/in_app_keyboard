import 'package:flutter/material.dart';

/// Internal notifier to bridge navigation events and the keyboard controller.
class KeyboardDismissalNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

/// A global service to manage keyboard-related overlays (like key extensions)
class KeyboardOverlayService {
  static final KeyboardOverlayService instance = KeyboardOverlayService._internal();
  KeyboardOverlayService._internal();

  OverlayState? _overlayState;
  OverlayEntry? _currentEntry;

  /// Notifies listeners of the current keyboard height for UI adjustments.
  final ValueNotifier<double> keyboardHeight = ValueNotifier<double>(0);

  /// A private notifier used to trigger dismissal from global navigation events.
  final KeyboardDismissalNotifier dismissalNotifier = KeyboardDismissalNotifier();

  /// Initialize the service with the root overlay state.
  /// Should be called from a widget that has access to the [Overlay].
  void initialize(OverlayState? overlay) {
    _overlayState = overlay;
  }

  /// Show a popup at the specified position.
  void showPopup({
    required BuildContext context,
    required Offset position,
    required List<String> items,
    required Function(String) onSelected,
  }) {
    removePopup();

    final overlay = _overlayState ?? Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      debugPrint('KeyboardOverlayService: No Overlay found to show popup.');
      return;
    }

    _currentEntry = OverlayEntry(
      builder: (context) => _OverlayPopup(
        position: position,
        items: items,
        onSelected: (value) {
          onSelected(value);
          removePopup();
        },
        onDismiss: removePopup,
      ),
    );

    overlay.insert(_currentEntry!);
  }

  /// Remove the currently showing popup.
  void removePopup() {
    _currentEntry?.remove();
    _currentEntry = null;
  }

  bool get isPopupShowing => _currentEntry != null;
}

class _OverlayPopup extends StatefulWidget {
  final Offset position;
  final List<String> items;
  final ValueChanged<String> onSelected;
  final VoidCallback onDismiss;

  const _OverlayPopup({
    required this.position,
    required this.items,
    required this.onSelected,
    required this.onDismiss,
  });

  @override
  State<_OverlayPopup> createState() => _OverlayPopupState();
}

class _OverlayPopupState extends State<_OverlayPopup> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onDismiss,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          Positioned(
            left: widget.position.dx - (widget.items.length * 50 / 2),
            top: widget.position.dy - 80,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: GestureDetector(
                  onTap: () {}, // Prevent dismissal when tapping the menu
                  child: Material(
                    elevation: 12,
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    shadowColor: Colors.black45,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: widget.items.map((item) => _buildItem(item)).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(String label) {
    return InkWell(
      onTap: () => widget.onSelected(label),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
