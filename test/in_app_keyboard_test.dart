import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_keyboard/in_app_keyboard.dart';
import 'package:in_app_keyboard/src/widgets/keyboard_widget.dart';

void main() {
  testWidgets('KeyboardOverlay shows keyboard when InAppTextField is tapped', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: KeyboardOverlay(
            child: Scaffold(
              body: InAppTextField(
                decoration: InputDecoration(hintText: 'Enter text'),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(KeyboardWidget), findsNothing);

    await tester.tap(find.byType(InAppTextField));
    await tester.pumpAndSettle();

    expect(find.byType(KeyboardWidget), findsOneWidget);
    expect(find.text('q'), findsOneWidget);
  });

  testWidgets('KeyboardType.emailAddress shows email shortcuts', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: KeyboardOverlay(
            child: Scaffold(
              body: InAppTextField(
                keyboardType: KeyboardType.emailAddress,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(InAppTextField));
    await tester.pumpAndSettle();

    expect(find.text('@'), findsOneWidget);
    expect(find.text('.'), findsOneWidget);
  });

  testWidgets('KeyboardType.password automatically obscures text', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: KeyboardOverlay(
            child: Scaffold(
              body: InAppTextField(
                keyboardType: KeyboardType.password,
              ),
            ),
          ),
        ),
      ),
    );

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.obscureText, isTrue);
  });

  testWidgets('LayoutVariant.arabic applies RTL text direction', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: KeyboardOverlay(
            child: Scaffold(
              body: InAppTextField(
                layout: LayoutVariant.arabic,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(InAppTextField));
    await tester.pumpAndSettle();

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.textDirection, TextDirection.rtl);
  });

  testWidgets('Double tap Shift enables Caps Lock', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: KeyboardOverlay(
            child: Scaffold(
              body: InAppTextField(),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(InAppTextField));
    await tester.pumpAndSettle();

    final shiftFinder = find.byIcon(Icons.keyboard_arrow_up);
    
    // First tap
    await tester.tap(shiftFinder);
    await tester.pump(const Duration(milliseconds: 100));
    
    // Second tap within 300ms
    await tester.tap(shiftFinder);
    await tester.pumpAndSettle();

    // Icon should change to caps lock
    expect(find.byIcon(Icons.keyboard_capslock), findsOneWidget);
  });

  testWidgets('Long press on "." in email layout shows extensions', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: KeyboardOverlay(
            child: Scaffold(
              body: InAppTextField(
                keyboardType: KeyboardType.emailAddress,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(InAppTextField));
    await tester.pumpAndSettle();

    // Find the '.' key
    final dotFinder = find.text('.');
    
    // Long press
    await tester.longPress(dotFinder);
    await tester.pumpAndSettle();

    // Verify extensions are visible in overlay
    expect(find.text('.com'), findsOneWidget);
    expect(find.text('.org'), findsOneWidget);

    // Tap .com to insert
    await tester.tap(find.text('.com'));
    await tester.pumpAndSettle();

    final controller = tester.widget<TextField>(find.byType(TextField)).controller!;
    expect(controller.text, '.com');
  });

  testWidgets('Tap outside keyboard dismisses it', (WidgetTester tester) async {
    // Force small screen mode to enable outside tap dismissal
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: KeyboardOverlay(
            child: Scaffold(
              body: Column(
                children: [
                  InAppTextField(),
                  Expanded(child: SizedBox(key: Key('outside'))),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(InAppTextField));
    await tester.pumpAndSettle();
    expect(find.byType(KeyboardWidget), findsOneWidget);

    await tester.tap(find.byKey(const Key('outside')), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byType(KeyboardWidget), findsNothing);
  });
}
