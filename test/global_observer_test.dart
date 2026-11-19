import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_keyboard/in_app_keyboard.dart';
import 'package:in_app_keyboard/src/widgets/keyboard_widget.dart';

void main() {
  testWidgets('InAppKeyboardObserver hides keyboard globally on navigation', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          navigatorObservers: [InAppKeyboardObserver()],
          builder: (context, child) => KeyboardOverlay(child: child!),
          home: const Scaffold(
            body: Column(
              children: [
                InAppTextField(),
                _NextButton(),
              ],
            ),
          ),
        ),
      ),
    );

    // Show keyboard
    await tester.tap(find.byType(InAppTextField));
    await tester.pumpAndSettle();
    expect(find.byType(KeyboardWidget), findsOneWidget);

    // Navigate using standard Navigator (simulates GetX/GoRouter behavior)
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    await tester.pumpAndSettle();

    // Keyboard should be hidden automatically by the observer
    expect(find.byType(KeyboardWidget), findsNothing);
  });
}

class _NextButton extends StatelessWidget {
  const _NextButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const Scaffold(body: Text('Next Page'))),
        );
      },
      child: const Text('Go to next page'),
    );
  }
}
