import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_keyboard/in_app_keyboard.dart';
import 'package:in_app_keyboard/src/services/keyboard_overlay_service.dart';

void main() {
  testWidgets('KeyboardOverlay updates keyboardHeight on small screens', (WidgetTester tester) async {
    // Set small screen width
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: KeyboardOverlay(
            child: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 600),
                    InAppTextField(),
                    SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Initial height should be 0
    expect(KeyboardOverlayService.instance.keyboardHeight.value, 0);

    // Tap to show keyboard
    await tester.tap(find.byType(InAppTextField));
    await tester.pump(); // Start registration
    await tester.pumpAndSettle(); // Wait for post frame and animation

    // Height should now be dynamic (approx 212 for numeric layout in test)
    expect(KeyboardOverlayService.instance.keyboardHeight.value, greaterThan(0));
    final height = KeyboardOverlayService.instance.keyboardHeight.value;

    // Check if AnimatedPadding matches the reported height
    final animatedPadding = tester.widget<AnimatedPadding>(
      find.byType(AnimatedPadding).first,
    );
    expect((animatedPadding.padding as EdgeInsets).bottom, height);

    // Dismiss keyboard
    await tester.tapAt(const Offset(10, 10)); // Tap outside
    await tester.pump();
    await tester.pumpAndSettle();

    expect(KeyboardOverlayService.instance.keyboardHeight.value, 0);
    
    // Reset view
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
