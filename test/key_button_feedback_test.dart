import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_keyboard/src/widgets/key_button.dart';
import 'package:in_app_keyboard/src/models/key_model.dart';

void main() {
  testWidgets('KeyButton shows elevation feedback on tap', (WidgetTester tester) async {
    bool tapped = false;
    final keyModel = KeyModel(label: 'A', value: 'a');

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                KeyButton(
                  keyModel: keyModel,
                  onTap: () => tapped = true,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Initial state
    final containerBefore = tester.widget<Container>(
      find.descendant(
        of: find.byType(KeyButton),
        matching: find.byType(Container),
      ).first,
    );
    final decorationBefore = containerBefore.decoration as BoxDecoration;
    expect(decorationBefore.boxShadow!.first.blurRadius, 1.0);

    // Press down
    final gesture = await tester.startGesture(tester.getCenter(find.byType(KeyButton)));
    await tester.pump(); // Start animation and update state

    final containerPressed = tester.widget<Container>(
      find.descendant(
        of: find.byType(KeyButton),
        matching: find.byType(Container),
      ).first,
    );
    final decorationPressed = containerPressed.decoration as BoxDecoration;
    
    // Check for "pressed" state feedback (color and shadow)
    expect(decorationPressed.color, Colors.grey[400]);
    expect(decorationPressed.boxShadow!.first.blurRadius, 10.0);

    // Release
    await gesture.up();
    await tester.pump();

    final containerAfter = tester.widget<Container>(
      find.descendant(
        of: find.byType(KeyButton),
        matching: find.byType(Container),
      ).first,
    );
    final decorationAfter = containerAfter.decoration as BoxDecoration;
    expect(decorationAfter.boxShadow!.first.blurRadius, 1.0);
    expect(tapped, isTrue);
  });
}
