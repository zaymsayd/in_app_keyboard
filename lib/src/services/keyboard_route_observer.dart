import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/keyboard_controller.dart';
import 'keyboard_overlay_service.dart';

/// A universal navigation observer that automatically hides the in-app 
/// keyboard on any route change (push, pop, etc.).
/// 
/// Works with standard [Navigator], [GetX], [GoRouter], [AutoRoute], etc.
/// 
/// Usage:
/// ```dart
/// MaterialApp(
///   navigatorObservers: [InAppKeyboardObserver()],
///   ...
/// )
/// ```
class InAppKeyboardObserver extends NavigatorObserver {
  InAppKeyboardObserver();

  static final instance = InAppKeyboardObserver();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _requestDismissal();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _requestDismissal();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _requestDismissal();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _requestDismissal();
  }

  void _requestDismissal() {
    // Notify the controller globally without needing access to BuildContext
    // or a ProviderContainer.
    KeyboardOverlayService.instance.dismissalNotifier.notify();
  }
}

/// Global observer to track route changes and manage keyboard visibility.
/// 
/// Add this to your [MaterialApp.navigatorObservers]:
/// ```dart
/// MaterialApp(
///   navigatorObservers: [keyboardRouteObserver],
///   ...
/// )
/// ```
final RouteObserver<ModalRoute> keyboardRouteObserver = RouteObserver<ModalRoute>();

/// A mixin that automatically hides the in-app keyboard when the route 
/// changes (push or pop).
/// 
/// Use this in your [State] class of a [StatefulWidget]:
/// ```dart
/// class _MyScreenState extends State<MyScreen> with RouteAware, InAppKeyboardRouteAware {
///   ...
/// }
/// ```
mixin InAppKeyboardRouteAware<T extends StatefulWidget> on State<T>, RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute != null) {
      keyboardRouteObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void dispose() {
    keyboardRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPushNext() {
    _hideKeyboard();
  }

  @override
  void didPopNext() {
    // When returning to this route, ensure we unfocus after the system 
    // potentially restores focus.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _hideKeyboard();
    });
  }

  @override
  void didPop() {
    _hideKeyboard();
  }

  void _hideKeyboard() {
    if (!mounted) return;
    
    final container = ProviderScope.containerOf(context);
    container.read(keyboardControllerProvider.notifier).clearActiveField();
    
    FocusScope.of(context).unfocus();
  }
}
