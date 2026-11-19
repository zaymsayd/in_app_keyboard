import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/keyboard_controller.dart';
import '../services/keyboard_overlay_service.dart';
import 'keyboard_widget.dart';

const double _kFloatingWidth = 460.0;

/// Root overlay widget. Wrap your MaterialApp's `builder` child with this.
///
/// Small screens (< 600 px wide): keyboard docks at the bottom.
/// Large screens (≥ 600 px wide): keyboard floats as a draggable panel.
class KeyboardOverlay extends ConsumerWidget {
  final Widget child;

  /// When `true` (default), tapping outside the bottom-docked keyboard
  /// dismisses it. Has no effect in floating mode — use the ✕ button instead.
  final bool dismissOnOutsideTap;

  const KeyboardOverlay({
    super.key,
    required this.child,
    this.dismissOnOutsideTap = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Select only the two booleans that control layout so that key-presses and
    // position updates do NOT cause this widget to rebuild.
    final isVisible = ref.watch(
      keyboardControllerProvider.select((s) => s.isVisible),
    );
    final isFloating = ref.watch(
      keyboardControllerProvider.select((s) => s.isFloating),
    );
    final isImmediate = ref.watch(
      keyboardControllerProvider.select((s) => s.isImmediate),
    );

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 600;

    // We no longer update height here with a hardcoded value.
    // Instead, _BottomKeyboard will report its actual height.
    if (!isVisible || isFloating || !isSmallScreen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (KeyboardOverlayService.instance.keyboardHeight.value != 0) {
          KeyboardOverlayService.instance.keyboardHeight.value = 0;
        }
      });
    }

    return PopScope(
      canPop: !isVisible,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && isVisible) {
          ref.read(keyboardControllerProvider.notifier).hide();
        }
      },
      child: Stack(
        children: [
          // ── Main content ──────────────────────────────────────────────────
          // AnimatedPadding shifts the content up when the keyboard appears on small screens.
          ValueListenableBuilder<double>(
            valueListenable: KeyboardOverlayService.instance.keyboardHeight,
            builder: (context, height, childWidget) {
              return AnimatedPadding(
                padding: EdgeInsets.only(bottom: height),
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                child: childWidget!,
              );
            },
            child: (dismissOnOutsideTap && isVisible && !isFloating)
                ? GestureDetector(
                    onTap: () {
                      ref.read(keyboardControllerProvider.notifier).hide();
                      FocusScope.of(context).unfocus();
                      KeyboardOverlayService.instance.removePopup();
                    },
                    behavior: HitTestBehavior.translucent,
                    child: child,
                  )
                : child,
          ),

          // ── Bottom-docked keyboard ────────────────────────────────────────
          if (!isFloating)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedSwitcher(
                duration: isImmediate 
                    ? Duration.zero 
                    : const Duration(milliseconds: 280),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  if (isImmediate) return child;

                  final offsetAnimation = Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(animation);
                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
                child: isVisible ? const _BottomKeyboard() : const SizedBox.shrink(),
              ),
            ),

          // ── Floating keyboard ─────────────────────────────────────────────
          if (isVisible && isFloating) const _FloatingKeyboard(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom-docked keyboard
// ─────────────────────────────────────────────────────────────────────────────

class _BottomKeyboard extends StatelessWidget {
  const _BottomKeyboard();

  void _reportHeight(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      final height = box.size.height;
      if (KeyboardOverlayService.instance.keyboardHeight.value != height) {
        // Use post-frame to avoid build-phase state updates
        WidgetsBinding.instance.addPostFrameCallback((_) {
          KeyboardOverlayService.instance.keyboardHeight.value = height;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: GestureDetector(
        onTap: () {}, // prevent tap bubbling to dismiss layer
        child: Material(
          elevation: 8,
          color: const Color(0xFFD1D5DB),
          child: Builder(
            builder: (ctx) {
              // Measure after each layout to catch height changes (e.g. QWERTY to numeric)
              WidgetsBinding.instance.addPostFrameCallback((_) => _reportHeight(ctx));

              WidgetsBinding.instance.addPostFrameCallback((_) {
                KeyboardOverlayService.instance.initialize(
                  Overlay.maybeOf(ctx, rootOverlay: true),
                );
              });
              return const KeyboardWidget();
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Floating keyboard
//
// Position is kept in LOCAL state — drags never touch Riverpod and therefore
// never cause KeyboardOverlay to rebuild. Only _FloatingKeyboard rebuilds on
// each pan frame, and only the Positioned parent-data is updated on RenderStack.
// ─────────────────────────────────────────────────────────────────────────────

class _FloatingKeyboard extends ConsumerStatefulWidget {
  const _FloatingKeyboard();

  @override
  ConsumerState<_FloatingKeyboard> createState() => _FloatingKeyboardState();
}

class _FloatingKeyboardState extends ConsumerState<_FloatingKeyboard> {
  Offset _position = const Offset(100, 300);
  Size _panelSize = const Size(_kFloatingWidth, 260);
  bool _ready = false; // hidden until centered on first frame

  final GlobalKey _panelKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    // If the user previously dragged the keyboard, restore that position.
    final saved = ref.read(keyboardControllerProvider).position;
    if (saved != null) {
      _position = saved;
      _ready = true;
    } else {
      // No saved position — centre after first layout.
      WidgetsBinding.instance.addPostFrameCallback(_centreOnFirstFrame);
    }
  }

  void _centreOnFirstFrame(_) {
    final box = _panelKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) _panelSize = box.size;

    final screen = MediaQuery.of(context).size;
    setState(() {
      _position = Offset(
        (screen.width - _panelSize.width) / 2,
        screen.height - _panelSize.height - 80,
      );
      _ready = true;
    });
  }

  Offset _clamp(Offset pos) {
    final screen = MediaQuery.of(context).size;
    return Offset(
      pos.dx.clamp(
        0.0,
        (screen.width - _panelSize.width).clamp(0.0, double.infinity),
      ),
      pos.dy.clamp(
        0.0,
        (screen.height - _panelSize.height).clamp(0.0, double.infinity),
      ),
    );
  }

  void _onPanUpdate(DragUpdateDetails d) {
    setState(() => _position = _clamp(_position + d.delta));
  }

  void _onPanEnd(DragEndDetails _) {
    // Persist final position so it survives hide/show within the same session.
    ref
        .read(keyboardControllerProvider.notifier)
        .updatePosition(_position, MediaQuery.of(context).size, _panelSize);
  }

  void _close() {
    ref.read(keyboardControllerProvider.notifier).hide();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final typeName = ref.watch(
      keyboardControllerProvider.select(
        (s) => s.currentType.name.toUpperCase(),
      ),
    );

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: Opacity(
        opacity: _ready ? 1.0 : 0.0,
        child: GestureDetector(
          onTap: () {}, // block dismiss-layer tap from bubbling
          child: Material(
            key: _panelKey,
            elevation: 16,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              width: _kFloatingWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DragHandle(
                    typeName: typeName,
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    onClose: _close,
                  ),
                  Builder(
                    builder: (ctx) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        KeyboardOverlayService.instance.initialize(
                          Overlay.maybeOf(ctx, rootOverlay: true),
                        );
                      });
                      return const KeyboardWidget();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Drag handle bar
// ─────────────────────────────────────────────────────────────────────────────

class _DragHandle extends StatelessWidget {
  final String typeName;
  final GestureDragUpdateCallback onPanUpdate;
  final GestureDragEndCallback onPanEnd;
  final VoidCallback onClose;

  const _DragHandle({
    required this.typeName,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 36,
        color: const Color(0xFFBBBFC7),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Text(
              typeName,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black38,
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            const Icon(Icons.drag_handle, color: Colors.black38, size: 22),
            const Spacer(),
            InkWell(
              onTap: onClose,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.close, color: Colors.black45, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
