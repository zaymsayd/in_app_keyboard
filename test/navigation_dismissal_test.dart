import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_keyboard/in_app_keyboard.dart';
import 'package:in_app_keyboard/src/widgets/keyboard_widget.dart';

void main() {
  testWidgets('Keyboard hides when navigating to another screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          navigatorObservers: [keyboardRouteObserver],
          builder: (context, child) => KeyboardOverlay(child: child!),
          home: const TestPage(),
        ),
      ),
    );

    // Show keyboard
    await tester.tap(find.byType(InAppTextField));
    await tester.pumpAndSettle();
    expect(find.byType(KeyboardWidget), findsOneWidget);

    // Navigate to next page
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(); // Start navigation
    await tester.pumpAndSettle(); // Finish transition

    // Keyboard should be hidden
    expect(find.byType(KeyboardWidget), findsNothing);
    expect(find.text('Second Page'), findsAtLeast(1));

    // Navigate back
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Keyboard should still be hidden on back
    expect(find.byType(KeyboardWidget), findsNothing);
  });
}

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> with RouteAware, InAppKeyboardRouteAware {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const InAppTextField(),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SecondPage()),
              );
            },
            child: const Text('Go to next page'),
          ),
        ],
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Second Page')),
      body: const Center(child: Text('Second Page')),
    );
  }
}
